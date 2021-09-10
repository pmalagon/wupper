/**
  *    ------------------------------------------------------------------------------
  *                                                              
  *            NIKHEF - National Institute for Subatomic Physics 
  *  
  *                        Electronics Department                
  *                                                              
  *  ----------------------------------------------------------------------------
  *  @class wupper driver
  *  
  *  
  *  @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
  *               Frans Schreuder (frans.schreuder@nikhef.nl)<br>
  *               Markus Joos<br>
  *               Jos Vermeulen<br>
  *               Oussama el Kharraz Alami<br>
  *  
  *  
  *  @date        08/09/2015    created
  *  
  *  @version     1.0
  *  
  *  @brief Original version (RobinNP driver) by Barry Green, Will Panduro (RHUL),
  *  Gordon Crone (UCL), Markus Joos (CERN)
  *  Adapted for WUPPER by Jos Vermeulen (Nikhef), Jan. 2015"); 
  * 
  *  @detail
  *  
  *  ----------------------------------------------------------------------------
  *  @TODO
  *   
  *  
  *  ------------------------------------------------------------------------------
  *  Wupper
  *  
  *  \copyright GNU LGPL License
  *  Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
  *  License as published by the Free Software Foundation; either
  *  version 3.0 of the License, or (at your option) any later version.
  *  This library is distributed in the hope that it will be useful,
  *  but WITHOUT ANY WARRANTY; without even the implied warranty of
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  *  Lesser General Public License for more details.<br>
  *  You should have received a copy of the GNU Lesser General Public
  *  License along with this library.
  */


#include <linux/version.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/pci.h>
#include <linux/mm.h>
#include <linux/proc_fs.h>
#include <linux/io.h>
#include <linux/errno.h>
#include <linux/types.h>
#include <linux/cdev.h>
#include <linux/pagemap.h>
#include <linux/page-flags.h>
#include <linux/sched.h>
#include <linux/interrupt.h>
#include <linux/time.h>
#include <linux/delay.h>
#include <linux/spinlock.h>       //For the spin-lock 

#include "wupper_common.h"
#include "regmap/regmap-struct.h"


/********/
/*Macros*/
/********/
#ifdef DRIVER_DEBUG
  #define kdebug(x) {if (debug) printk x;}
#else
  #define kdebug(x)
#endif

#ifdef DRIVER_ERROR
  #define kerror(x) {if (errorlog) printk x;}
#else
  #define kerror(x)
#endif


/***********/
/*Constants*/
/***********/
#define PROC_MAX_CHARS         0x10000      //The max. length of the output of /proc/wupper
#define PCI_VENDOR_ID_WUPPER_FW   0x10ee       //Note: The different H/W types (709, 710, 711 and 712) do not have specific F/W files
                                            //      Therefore the device ID refers to the F/W release, not to the type of PCIe device
#define PCI_DEVICE_ID_WUPPER_FW1  0x7038
#define PCI_DEVICE_ID_WUPPER_FW2  0x7039

#define PCI_VENDOR_ID_CERN_FW  0x10dc
#define PCI_DEVICE_ID_CERN_FW1 0x0427
#define PCI_DEVICE_ID_CERN_FW2 0x0428

#define FIRSTMINOR             0
#define MAXMSIX		       8            // Max. number of interrupts (MSI-X) per device


/************/
/*Prototypes*/
/************/
static int wupper_init(void);
static int wupper_Probe(struct pci_dev*, const struct pci_device_id*);
static int fill_proc_read_text(void);
static ssize_t wupper_write_procmem(struct file *file, const char *buffer, size_t count, loff_t *startOffset);
static ssize_t wupper_read_procmem(struct file *file, char *buf, size_t count, loff_t *startOffset);
static void wupper_exit(void);
static void wupper_Remove(struct pci_dev*);
int wupper_mmap(struct file*, struct vm_area_struct*);
static long wupper_ioctl(struct file *file, u_int cmd, u_long arg);
int wupper_open(struct inode*, struct file*);
int wupper_Release(struct inode*, struct file*);
void wupper_vmclose(struct vm_area_struct*);


/************/
/*Structures*/
/************/
static struct pci_device_id WUPPER_IDs[] =
{
  { PCI_DEVICE(PCI_VENDOR_ID_WUPPER_FW, PCI_DEVICE_ID_WUPPER_FW1) },
  { PCI_DEVICE(PCI_VENDOR_ID_WUPPER_FW, PCI_DEVICE_ID_WUPPER_FW2) },
  { PCI_DEVICE(PCI_VENDOR_ID_CERN_FW, PCI_DEVICE_ID_CERN_FW1) },
  { PCI_DEVICE(PCI_VENDOR_ID_CERN_FW, PCI_DEVICE_ID_CERN_FW2) },
  { 0, },
};

struct file_operations fops =
{
  .owner          = THIS_MODULE,
  .mmap           = wupper_mmap,
  .unlocked_ioctl = wupper_ioctl,
  .open           = wupper_open,
  .read           = wupper_read_procmem,
  .write          = wupper_write_procmem,
  .release        = wupper_Release,
};

// needed by pci_register_driver fcall
static struct pci_driver wupper_PCI_driver =
{
  .name     = "wupper",
  .id_table = WUPPER_IDs,
  .probe    = wupper_Probe,
  .remove   = wupper_Remove,
};

// memory handler functions used by mmap
static struct vm_operations_struct wupper_vm_ops =
{
  .close =  wupper_vmclose,             // mmap-close
};

struct irqInfo_struct
{
  int interrupt;
  int device;
};


/*********/
/*Globals*/
/*********/
char *devName = "wupper";  //the device name as it will appear in /proc/devices
static char *proc_read_text;
static int debug = 0, errorlog = 1, autoswap = 0, deviceNumberIndex = 0;
int devicesFound = 0, interruptCount = 0, cardsignored = 0;
int msixblock = MAXMSIX, irqFlag[MAXCARDS][MAXMSIX] = {{0}}, msixStatus[MAXCARDS];
int irqMasked[MAXCARDS][MAXMSIX];
u_int irqCount[MAXCARDS][MAXMSIX];
u_int cdmap[MAXCARDS][2];
uint32_t* msixBar[MAXCARDS], msixPbaOffset[MAXCARDS];  //MJ: msixPbaOffset is only used in debug commands. Is it needed in the driver? What is it for?
card_params_t devices[MAXCARDS];
struct cdev *wupper_cdev;
dev_t first_dev;
static struct irqInfo_struct irqInfo[MAXCARDS][MAXMSIX];

static u_int global_locks[MAXCARDS];
u_int lock_tag = 1, lock_tags[MAXCARDS][MAXLOCKBITS], lock_pid[MAXCARDS][MAXLOCKBITS];
static u_long lock_irq_flags;

static DECLARE_WAIT_QUEUE_HEAD(waitQueue);
static DEFINE_MUTEX(procMutex);
static DEFINE_SPINLOCK(lock_lock);    //The spinlock for the resource locking

module_init(wupper_init);
module_exit(wupper_exit);

MODULE_DESCRIPTION("WUPPER driver");
MODULE_AUTHOR("Jos Vermeulen (Nikhef) and Markus Joos (CERN)");
MODULE_LICENSE("Dual BSD/GPL");
//MODULE_DEVICE_TABLE(pci, WUPPER_IDs); //Disabled by MJ in order to prevent the driver from auto loading. The driver will be loaded by /etc/init.d/drivers_wupper

MODULE_PARM_DESC(msixblock, "size of MSI-X block to enable. Maximum value = MAXMSIX( = 8)");
module_param(msixblock, int, S_IRUGO);

MODULE_PARM_DESC(debug, "1 = enable debugging   0 = disable debugging");
module_param (debug, int, S_IRUGO | S_IWUSR);

MODULE_PARM_DESC(errorlog, "1 = enable error logging   0 = disable error logging");
module_param (errorlog, int, S_IRUGO | S_IWUSR);

MODULE_PARM_DESC(autoswap, "1 = enable reordering of 0x7038/0x7039 and 0x427/0x428   0 = disable reordering of 0x7038/0x7039 and 0x427/0x428");
module_param (autoswap, int, S_IRUGO | S_IWUSR);

struct msix_entry msixTable[MAXCARDS][MAXMSIX];


/***********************/
static int wupper_init(void)
/***********************/
{
  int stat, deviceNumber, lbit, interrupt, loop;
  struct proc_dir_entry *procDir;

  for (loop = 0; loop < MAXCARDS; loop++)
  {
    cdmap[loop][0] = 0;
    cdmap[loop][1] = 0;
  }

  for (deviceNumber = 0; deviceNumber < MAXCARDS; deviceNumber++)
  {
    devices[deviceNumber].pciDevice = NULL;
    for (interrupt = 0; interrupt < MAXMSIX; interrupt++)
    {
      kdebug(("wupper(wupper_init): initializing IRQ values for interrupt %d of device %d\n", interrupt, deviceNumber))
      irqCount[deviceNumber][interrupt] = 0;
      irqMasked[deviceNumber][interrupt] = 1;
      irqFlag[deviceNumber][interrupt] = 0;
    }
    global_locks[deviceNumber] = 0;

    for (lbit = 0; lbit < MAXLOCKBITS; lbit++)
    {
      lock_pid[deviceNumber][lbit] = 0;  
      lock_tags[deviceNumber][lbit] = 0;  
    }
  }

  if (msixblock > MAXMSIX)
  {
    kerror(("wupper(wupper_init):msixblock > MAXMSIX - setting to max (%d)\n", MAXMSIX))
    msixblock = MAXMSIX;  //MJ: We could be less friendly and cause the driver installation to fail if the user spceifies and out-of-bounds value
  }

  kdebug(("wupper(wupper_init): registering PCIDriver \n"))
  stat = pci_register_driver(&wupper_PCI_driver);
  if (stat < 0)
  {
    kerror(("wupper(wupper_init): Status %d from pci_register_driver\n", stat))
    return stat;
  }

  procDir = proc_create(devName, 0644, NULL, &fops);
  if (procDir == NULL)
  {
    kerror(("wupper(wupper_init): error from call to create_proc_entry\n"))
    return(-ENOMEM);     //MJ: The error code is a bit random. I have also seen -EINVAL in other driver. Many drivers just return -1
  }

  stat = alloc_chrdev_region(&first_dev, FIRSTMINOR, MAXCARDS, devName);
  if (stat == 0)
  {
    wupper_cdev = cdev_alloc();
    wupper_cdev->ops = &fops;
    wupper_cdev->owner = THIS_MODULE;

    for (deviceNumber = 0; deviceNumber < MAXCARDS; deviceNumber++)
    {
      kdebug(("wupper(wupper_init): calling cdev_add for device %d\n", deviceNumber))
      stat = cdev_add(wupper_cdev, first_dev + deviceNumber, 1);
      if (stat != 0)
      {
        kerror(("wupper(wupper_init): cdev_add failed at device %d, driver will not load\n", deviceNumber))  
        unregister_chrdev_region(first_dev, MAXCARDS);
        pci_unregister_driver(&wupper_PCI_driver);
        return(stat);
      }
    }
  }
  else
  {
    kerror(("wupper_init: registering WUPPER driver failed.\n"))
    pci_unregister_driver(&wupper_PCI_driver);
    return(stat);
  }

  proc_read_text = (char *)kmalloc(PROC_MAX_CHARS, GFP_KERNEL);
  if (proc_read_text == NULL)
  {
    kerror(("wupper_init: error from kmalloc\n"))  //MJ: Do we have to unregister the driver and pci device if the kmalloc fails?
    return(-ENOMEM);
  }

  kerror(("wupper_init: WUPPER driver loaded, found %d device(s)\n", devicesFound))  
  return 0;
}


/************************/
static void wupper_exit(void)
/************************/
{
  remove_proc_entry(devName, NULL /* parent dir */);
  kdebug(("wupper(wupper_exit): unregister device\n"))
  
  unregister_chrdev_region(first_dev, MAXCARDS);
  kdebug(("wupper(wupper_exit: unregister driver\n"))
  
  pci_unregister_driver(&wupper_PCI_driver);
  cdev_del(wupper_cdev);
  kfree(proc_read_text);
  kerror(("wupper(wupper__exit): driver removed\n"))
}


/***********************************************/
static irqreturn_t irqHandler(int irq, void *dev)
/***********************************************/
{
  struct irqInfo_struct *info;

  info = (struct irqInfo_struct*) dev;

  kdebug(("wupper(irqHandler, pid=%d): Interrupt %d received from device %d\n", current->pid, info->interrupt, info->device))

  irqCount[info->device][info->interrupt] += 1;
  irqFlag[info->device][info->interrupt] = 1;
  wake_up_interruptible(&waitQueue);      //MJ: would it have any performance advantages if we used one wait queue per device?
  return(IRQ_HANDLED);
}


/***********************************************************************/
static int wupper_Probe(struct pci_dev *dev, const struct pci_device_id *id)
/***********************************************************************/
{
  static int first_did = 0;
  int deviceNumber, ret, bufferNumber, interrupt, msixCapOffset, msixData, msixBarNumber, msixTableOffset, msixLength;
  uint32_t msixAddress;    
  u_long ldata;
  wuppercard_bar2_regs_t *rm;

  kdebug(("wupper(wupper_Probe): DID = 0x%08x, VID = 0x%08x\n", dev->device, dev->vendor))

  //Note: For the proper functioning of the wupper tools it is important that the wupper devices (remember: each PCIe module has got one or two) are properly ordered
  //      The device 7038 has to be before 7039. On some (maybe all?) PCs the 712 modules are presented to the driver in the wrong order.
  //      the code below remaps the devices.

  deviceNumber = deviceNumberIndex;
  kdebug(("wupper(wupper_Probe): deviceNumber = %d\n", deviceNumber))

  //In pc-tbed-felix-05 we have two modules that both only provide one end-pint with DID=7038. In such a case the auto-swap causes havoc
  if (first_did == 0)
  {
    if (dev->device == PCI_DEVICE_ID_WUPPER_FW2 || dev->device ==  PCI_DEVICE_ID_CERN_FW2)
    {
      autoswap = 1;
      kdebug(("wupper(wupper_Probe): auto swapping enabled\n"))   
    }      
    first_did = 1;
  }

  if (autoswap)
  {
    if (dev->device == PCI_DEVICE_ID_WUPPER_FW2 && !(deviceNumberIndex & 1))  //7039 and even index
    {
      kdebug(("wupper(wupper_Probe): auto remap 1\n"))   
      deviceNumber++;
    }

    if (dev->device == PCI_DEVICE_ID_WUPPER_FW1 && (deviceNumberIndex & 1))   //7038 and odd index
    {
      kdebug(("wupper(wupper_Probe): auto remap 2\n"))  
      deviceNumber--;
    }    

    if (dev->device == PCI_DEVICE_ID_CERN_FW2 && !(deviceNumberIndex & 1))  //428 and even index
    {
      kdebug(("wupper(wupper_Probe): auto remap 3\n"))   
      deviceNumber++;
    }

    if (dev->device == PCI_DEVICE_ID_CERN_FW1 && (deviceNumberIndex & 1))   //427 and odd index
    {
      kdebug(("wupper(wupper_Probe): auto remap 4\n"))   
      deviceNumber--;
    }   
    kdebug(("wupper(wupper_Probe): new deviceNumber = %d\n", deviceNumber))   
  }

  deviceNumberIndex++;

  if (deviceNumber < MAXCARDS)
  {
    kdebug(("wupper(wupper_Probe): Initialising logical device nr %d (counting from 0)\n", devicesFound))
    ret = pci_enable_device(dev); //according to https://www.kernel.org/doc/Documentation/PCI/pci.txt this function can fail
    if (ret)
    {
      kerror(("wupper(wupper_Probe): Error %d received from pci_enable_device. \n", ret))
      //Maybe the function pcibios_strerror() can be helpful to translate the error code into a string
      deviceNumberIndex--;
      return(-EINVAL);
    }   
  
    if (dev->current_state == PCI_D0)
      kdebug(("wupper(wupper_Probe): Power state is D0\n"))
    else
    {
      kerror(("wupper(wupper_Probe): Power state is not D0 but %d. Refusing to manage this device\n", dev->current_state))
      cardsignored++;
      pci_disable_device(dev);
      deviceNumberIndex--;
      return(-EINVAL);
    }

    devicesFound++;
    devices[deviceNumber].pciDevice = dev;
  }
  else
  {
    kerror(("wupper(wupper_Probe): Too many devices present, only %d is allowed\n", MAXCARDS))
    return(-EINVAL);
  }

  kdebug(("wupper(wupper_Probe): Reading configuration space for device %d :\n", deviceNumber))
  devices[deviceNumber].baseAddressBAR0 = pci_resource_start(dev, 0);
  devices[deviceNumber].sizeBAR0        = pci_resource_len(dev, 0);
  devices[deviceNumber].baseAddressBAR1 = pci_resource_start(dev, 1);
  devices[deviceNumber].sizeBAR1        = pci_resource_len(dev, 1);
  devices[deviceNumber].baseAddressBAR2 = pci_resource_start(dev, 2);
  devices[deviceNumber].sizeBAR2        = pci_resource_len(dev, 2);

  kdebug(("wupper(wupper_Probe): BAR0 start 0x%lx, end 0x%x, size 0x%lx \n", devices[deviceNumber].baseAddressBAR0, (u_int)pci_resource_end(dev, 0), devices[deviceNumber].sizeBAR0))
  kdebug(("wupper(wupper_Probe): BAR1 start 0x%lx, end 0x%x, size 0x%lx \n", devices[deviceNumber].baseAddressBAR1, (u_int)pci_resource_end(dev, 1), devices[deviceNumber].sizeBAR1))
  kdebug(("wupper(wupper_Probe): BAR2 start 0x%lx, end 0x%x, size 0x%lx \n", devices[deviceNumber].baseAddressBAR2, (u_int)pci_resource_end(dev, 2), devices[deviceNumber].sizeBAR2))

  msixCapOffset = pci_find_capability(dev, PCI_CAP_ID_MSIX);
  if (msixCapOffset == 0)
  {
    // module may not have wupper hardware loaded
    kerror(("wupper(wupper_Probe): Failed to map MSI-X BAR for device %d\n", deviceNumber))
    msixBar[deviceNumber] = NULL;
    return(-ENODEV);
  }

  // MSI-X table offset
  pci_read_config_dword(dev, msixCapOffset + PCI_MSIX_TABLE, &msixData);
  msixBarNumber = msixData & PCI_MSIX_TABLE_BIR;
  msixTableOffset = msixData & PCI_MSIX_TABLE_OFFSET;
  kdebug(("wupper(wupper_Probe): MSIX Vector table BAR %d, offset %08x\n", msixBarNumber, msixTableOffset))
  // MSI-X Pending Bit Array offset
  pci_read_config_dword(dev, msixCapOffset + PCI_MSIX_PBA, &msixData);
  msixBarNumber = msixData & PCI_MSIX_PBA_BIR;
  msixPbaOffset[deviceNumber] = msixData & PCI_MSIX_PBA_OFFSET;
  kdebug(("wupper(wupper_Probe): MSIX PBA: BAR %d, offset %08x\n", msixBarNumber, msixPbaOffset[deviceNumber]))
  msixAddress = pci_resource_start(dev, msixBarNumber);
  msixLength = pci_resource_len(dev, msixBarNumber);
    
  kdebug(("wupper(wupper_Probe): msixAddress = 0x%08x, msixLength = %d\n", msixAddress, msixLength))
  msixBar[deviceNumber] = ioremap(msixAddress, msixLength);

  if (msixBar[deviceNumber] == NULL)
  {
    kerror(("wupper(wupper_Probe): Failed to map MSI-X BAR\n for device %d\n", deviceNumber))
    return(-EINVAL);
  }

  if (debug)
  {
    bufferNumber = msixTableOffset / sizeof(uint32_t);
    for (interrupt = 0; interrupt < MAXMSIX; interrupt++)
    {
      kdebug(("wupper(wupper_Probe): MSI-X table[%d] %08x %08x  %08x  %08x\n", interrupt, msixBar[deviceNumber][bufferNumber], msixBar[deviceNumber][bufferNumber + 1], msixBar[deviceNumber][bufferNumber + 2], msixBar[deviceNumber][bufferNumber + 3]))
      bufferNumber += 4;
    }

    if (msixPbaOffset[deviceNumber] + 3 * sizeof(uint32_t) < msixLength)
    {
      kdebug(("wupper(wupper_Probe): MSI-X PBA      %08x %08x  %08x  %08x\n",
              msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t)],
              msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t) + 1],
              msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t) + 2],
              msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t) + 3]))
    }
    else
      kerror(("wupper(wupper_Probe): PBA offset 0x%x is outside of BAR%d, length=0x%x \n", msixPbaOffset[deviceNumber], msixBarNumber, msixLength))
  }

  // setup interrupts
  if (msixblock < MAXMSIX)
    kerror(("wupper(wupper_Probe): WARNING: msixblock(%d) < MAXMSIX(%d). I hope you know what you are doing\n", msixblock, MAXMSIX))

  for (interrupt = 0; interrupt < msixblock; interrupt++)
  {
    msixTable[deviceNumber][interrupt].entry = interrupt;  //MJ: If (msixblock < MAXMSIX) some elements of the array will not be initialized (which may not matter)
    kdebug(("wupper(wupper_Probe): filling interrupt table for interrupt %d, deviceNumber %d\n", interrupt, deviceNumber))
    kdebug(("wupper(wupper_Probe): entry in table %d\n", msixTable[deviceNumber][interrupt].entry))
  }

  msixStatus[deviceNumber] = pci_enable_msix_exact(dev, msixTable[deviceNumber], msixblock);

  if (debug)
  {
    kdebug(("wupper(wupper_Probe): msix address %08x, length %4x\n", msixAddress, msixLength))
    bufferNumber = msixTableOffset / sizeof(uint32_t);
    for (interrupt = 0; interrupt < msixblock; interrupt++)
    {
      kdebug(("wupper(wupper_Probe): MSI-X table[%d] %08x %08x  %08x  %08x\n", interrupt, msixBar[deviceNumber][bufferNumber], msixBar[deviceNumber][bufferNumber+1], msixBar[deviceNumber][bufferNumber+2], msixBar[deviceNumber][bufferNumber+3]))
      bufferNumber += 4;
    }
    if (msixPbaOffset[deviceNumber] + 3 * sizeof(uint32_t) < msixLength)
      kdebug(("wupper(wupper_Probe): MSI-X PBA %08x \n", msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t)]))
    else
      kerror(("wupper(wupper_Probe): PBA offset 0x%x is outside of BAR%d, length=0x%x \n", msixPbaOffset[deviceNumber], msixBarNumber, msixLength))
  }

  if (msixStatus[deviceNumber] != 0)
    kerror(("wupper(wupper_Probe): Failed to enable MSI-X interrupt block for device %d, enable returned %d\n", deviceNumber, msixStatus[deviceNumber]))
  else
  {
    for (interrupt = 0; interrupt < msixblock; interrupt++)
    {
      kdebug(("wupper(wupper_Probe): Trying to register IRQ vector %d\n", msixTable[deviceNumber][interrupt].vector))

      irqInfo[deviceNumber][interrupt].interrupt   = interrupt;     //MJ: If we have two devices then two elements of the array will have the same value (interrupt). Does that matter?
      irqInfo[deviceNumber][interrupt].device      = deviceNumber;    
      ret = request_irq(msixTable[deviceNumber][interrupt].vector, irqHandler, 0, devName, &irqInfo[deviceNumber][interrupt]);
      if (ret != 0)
          kerror(("wupper(wupper_Probe): Failed to register interrupt handler for MSI %d\n", interrupt))

      kdebug(("wupper(wupper_Probe): disable the interrupt. deviceNumber = %d, interrupt = %d, vector = %d\n", deviceNumber, interrupt, msixTable[deviceNumber][interrupt].vector)) 
      disable_irq(msixTable[deviceNumber][interrupt].vector);  //let the user enable the interrupt
    }
  }

  // do reset
  if (debug)
  {
    kdebug(("wupper(wupper_Probe): msix address %08x, length %4x\n", msixAddress, msixLength))
    bufferNumber = msixTableOffset / sizeof(uint32_t);
    for (interrupt = 0; interrupt < msixblock; interrupt++)
    {
      kdebug(("wupper(wupper_Probe): MSI-X table[%d] %08x %08x  %08x  %08x\n", interrupt, msixBar[deviceNumber][bufferNumber], msixBar[deviceNumber][bufferNumber+1], msixBar[deviceNumber][bufferNumber+2], msixBar[deviceNumber][bufferNumber+3]))
      bufferNumber += 4;
    }

    if (msixPbaOffset[deviceNumber] + 3 * sizeof(uint32_t) < msixLength)
    {
        kdebug(("wupper(wupper_Probe): MSI-X PBA %08x %08x  %08x  %08x\n",
                msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t)],
                msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t) + 1],
                msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t) + 2],
                msixBar[deviceNumber][msixPbaOffset[deviceNumber] / sizeof(uint32_t) + 3]))
    }
    else
      kerror(("wupper(wupper_Probe): PBA offset 0x%x is outside of BAR%d, length=0x%x \n", msixPbaOffset[deviceNumber], msixBarNumber, msixLength))
  }
  
  //Identify the card type. The CARD_TYPE register is at offset 0xA0 of BAR2
  
  rm = ioremap_nocache(devices[deviceNumber].baseAddressBAR2, devices[deviceNumber].sizeBAR2);
  ldata  = rm->CARD_TYPE;
  kdebug(("wupper(wupper_Probe): CARD_ID of device %d = 0x%016lx\n", deviceNumber, ldata));
  cdmap[deviceNumber][0] = ldata & 0xfff;  //card type
  
  if (dev->device == PCI_DEVICE_ID_WUPPER_FW1 || dev->device == PCI_DEVICE_ID_CERN_FW1)
  {
    cdmap[deviceNumber][1] = 0;               //device of card
    kdebug(("wupper(wupper_Probe): Relative device of device %d = 0\n", deviceNumber));
  } 

  if (dev->device == PCI_DEVICE_ID_WUPPER_FW2 || dev->device == PCI_DEVICE_ID_CERN_FW2)
  {
    cdmap[deviceNumber][1] = 1;               //device of card
    kdebug(("wupper(wupper_Probe): Relative device of device %d = 1\n", deviceNumber));
  }
 
  // other initialization ...
  return(0);
}


/*****************************************/
static void wupper_Remove(struct pci_dev *dev)
/*****************************************/
{
  int deviceNumber, interrupt;

  kdebug(("wupper(wupper_Remove):  called\n"))
  for(deviceNumber = 0; deviceNumber < MAXCARDS; deviceNumber++)
  {
    if (devices[deviceNumber].pciDevice == dev)
    {
      kdebug(("wupper(wupper_Remove): for device %d\n", deviceNumber))
      devices[deviceNumber].pciDevice = NULL;
      devicesFound--;
      deviceNumberIndex--;  //MJ: this is dangerous if devices are removed (and added) in random oder (reference: script pcie_hotplug_remove.sh)
      kdebug(("wupper(wupper_Remove): lowering  deviceNumberIndex to %d\n", deviceNumberIndex))

      if (msixStatus[deviceNumber] == 0)
      {
        for (interrupt = 0; interrupt < msixblock; interrupt++)
        {
          kdebug(("wupper(wupper_Remove): unregestering interrupt %d, vector %d\n", interrupt, msixTable[deviceNumber][interrupt].vector))
          free_irq(msixTable[deviceNumber][interrupt].vector, &irqInfo[deviceNumber][interrupt]);
        }
      }
      pci_disable_msix(dev);
    }
  }
}


/************************************************/
int wupper_open(struct inode *ino, struct file *file)
/************************************************/
{
  card_params_t *pdata;

  kdebug(("wupper(wupper_open): called for PID = %d\n", current->pid))
  pdata = (card_params_t *)kmalloc(sizeof(card_params_t), GFP_KERNEL);
  if (pdata == NULL)
  {
    kerror(("wupper(wupper_open): error from kmalloc\n"))
    return(-ENOMEM);
  }

  pdata->slot = 99;  //99 means: No process has connected itself to the respective device
  file->private_data = (char *)pdata;
  return(0);
}


/***************************************************/
int wupper_Release(struct inode *ino, struct file *file)
/***************************************************/
{
  card_params_t *pdata;
  int lbit;

  //MJ lock: Do we get into trouble if a PID links to both devices???
  kdebug(("wupper(wupper_release): called for PID = %d\n", current->pid))

  pdata = (card_params_t *)file->private_data;
  kdebug(("wupper(wupper_release): pdata->slot     = %d\n", pdata->slot))
  kdebug(("wupper(wupper_release): pdata->lock_tag = %d\n", pdata->lock_tag))
  kdebug(("wupper(wupper_release): current->pid    = %d\n", current->pid))

  //This function gets called when a process closes /dev/wupper. We should put here the garbage collection for the lock bits.
  //Orphaned locks must be released when the last WupperCard object of a process gets destroyed. 

  if(pdata->slot != 99)  //Only run this code fragment if a user process is attached to the device.
  {
    spin_lock_irqsave(&lock_lock, lock_irq_flags);   //Please do not disturb...
    kdebug(("wupper(wupper_release) Old global_locks[%d] = 0x%08x\n", pdata->slot, global_locks[pdata->slot]))
    for(lbit = 0; lbit < MAXLOCKBITS; lbit++)
    {
      kdebug(("wupper(wupper_release) lock_pid[%d][%d]  = %d, lock_tags[%d][%d] = %d\n", pdata->slot, lbit, lock_pid[pdata->slot][lbit], pdata->slot, lbit, lock_tags[pdata->slot][lbit]))

      if (lock_tags[pdata->slot][lbit] == pdata->lock_tag)
      {
        kdebug(("wupper(wupper_release) unregistering orphaned bit %d of device %d for PID %d\n", lbit, pdata->slot, current->pid))
        lock_pid[pdata->slot][lbit] = 0;
        lock_tags[pdata->slot][lbit] = 0;
        global_locks[pdata->slot] = global_locks[pdata->slot] & ~(1 << lbit);
      }
    }
    kdebug(("wupper(wupper_release) New global_locks[%d] = 0x%08x\n", pdata->slot, global_locks[pdata->slot]))
    spin_unlock_irqrestore(&lock_lock, lock_irq_flags);   
  }

  kfree(file->private_data);
  kdebug(("wupper(wupper_release): Resources of slot %d released\n", pdata->slot))
  return(0);
}


/**********************************************************************************************/
static ssize_t wupper_read_procmem(struct file *file, char *buf, size_t count, loff_t *startOffset)
/**********************************************************************************************/
{  
  static int merror, len = 0, bytes_copied = 0;
  u_long ret = 0;
  ssize_t retval = 0;
  
  kdebug(("wupper(wupper_read_proc): Called with buf         = 0x%016lx\n", (u_long)buf))
  kdebug(("wupper(wupper_read_proc): Called with startOffset = %lld\n", *startOffset))
  kdebug(("wupper(wupper_read_proc): Called with count       = %d\n", (int) count))

  merror = mutex_lock_interruptible(&procMutex);
  if (merror)
  {
    kdebug(("wupper(wupper_read_proc): mutex lock not OK. error = %d\n", merror))
    return(0);
  }
  kdebug(("wupper(wupper_read_proc): mutex lock OK\n"))

  if (*startOffset == 0)
  {
    bytes_copied = 0;
    len = fill_proc_read_text();
  }
  kdebug(("wupper(wupper_read_proc): len = %d\n", len))

  if (*startOffset >= len)
  {
    kdebug(("wupper(wupper_read_proc): thats it......\n"))
    mutex_unlock(&procMutex);
    kdebug(("wupper(wupper_read_proc): mutex unlock OK\n"))
    return(retval);
  } 
  
  if (*startOffset + count > len)
    count = len - *startOffset;

  ret = copy_to_user(buf, proc_read_text + bytes_copied, count);  // ret contains the amount of chars wasn't successfully written to `buf`
  kdebug(("wupper(wupper_read_proc): ret = %lu\n", ret))

  bytes_copied = bytes_copied + count - ret;
  kdebug(("wupper(wupper_read_proc): bytes_copied = %d\n", bytes_copied))

  *startOffset += count - ret;
  kdebug(("wupper(wupper_read_proc): *startOffset = %lld\n", *startOffset))
  
  retval = count - ret;
  kdebug(("wupper(wupper_read_proc): returning retval   = %ld\n", retval))
  
  mutex_unlock(&procMutex);
  kdebug(("wupper(wupper_read_proc): mutex unlock OK\n"))

  return(retval);
}


/********************************************************************************************************/
static ssize_t wupper_write_procmem(struct file *file, const char *buffer, size_t count, loff_t *startOffset)
/********************************************************************************************************/
{
  int len, loop, loop2;
  char textReceived[100];

  kdebug(("wupper(wupper_write_proc): robin_write_procmem called\n"))

  if (count > 99)
    len = 99;
  else
    len = count;

  if (copy_from_user(textReceived, buffer, len))
  {
    kerror(("wupper(wupper_write_proc): error from copy_from_user\n"))
    return(-EFAULT);
  }

  kdebug(("wupper(wupper_write_proc): len = %d\n", len))
  textReceived[len - 1] = '\0';
  kdebug(("wupper(wupper_write_proc): text passed = %s\n", textReceived))

  if (!strcmp(textReceived, "debug"))
  {
    debug = 1;
    kdebug(("wupper(wupper_write_proc): debugging enabled\n"))
  }

  if (!strcmp(textReceived, "nodebug"))
  {
    kdebug(("wupper(wupper_write_proc): debugging disabled\n"))
    debug = 0;
  }

  if (!strcmp(textReceived, "elog"))
  {
    kdebug(("wupper(wupper_write_proc): Error logging enabled\n"))
    errorlog = 1;
  }

  if (!strcmp(textReceived, "noelog"))
  {
    kdebug(("wupper(wupper_write_proc): Error logging disabled\n"))
    errorlog = 0;
  }
  
  if (!strcmp(textReceived, "swap"))
  {
    kdebug(("wupper(wupper_write_proc): Auto-swap enabled\n"))
    autoswap = 1;
  } 

  if (!strcmp(textReceived, "noswap"))
  {
    kdebug(("wupper(wupper_write_proc): Auto-swap disabled\n"))
    autoswap = 0;
  } 

  if (!strcmp(textReceived, "clearlock"))
  {
    kdebug(("wupper(wupper_write_proc): clearing all lock bits\n"))
    
    spin_lock_irqsave(&lock_lock, lock_irq_flags);   //Please do not disturb...
    
    for(loop = 0; loop < MAXCARDS; loop++)
    {
      global_locks[loop] = 0;
      for(loop2 = 0; loop2 < MAXLOCKBITS; loop2++)
      {
        lock_pid[loop][loop2] = 0;
        lock_tags[loop][loop2] = 0;
      }
    }

    lock_tag = 0;
    spin_unlock_irqrestore(&lock_lock, lock_irq_flags);   
	
    kdebug(("wupper(wupper_write_proc): lock bits hav been cleared\n"))
  } 
      
  return(len);
}


/**********************************/
static int fill_proc_read_text(void)
/**********************************/
{
  //MJ-SMP: protect this function (preferrably with a spinlock)  //MJ: Do we need the spinlock?
  int interrupt, deviceIndex[MAXCARDS], index, buildMonth, buildDay, buildHour, buildMinute;
  u_int len, device, lbit, git_commit_number, git_hash, device_type;
  u_long fpga_dna, jumpers;
  u_int nInterrrupts;
  u_int nDescriptors;
  int i;
  
  index = 0;
  for (device = 0; device < devicesFound; device++)
  {
    while (devices[index].pciDevice == NULL) index++;  //Look for the next device

    if (index < MAXCARDS)
    {
      deviceIndex[device] = index;
      index++;
      kdebug(("wupper(fill_proc_read_text): device %d has index %d\n", device, index))
    }
    else
    {
      kerror(("wupper(fill_proc_read_text): Device indexing error\n"))
      return(0);
    }
  }

  kdebug(("wupper(fill_proc_read_text): Creating text....\n"))
  len = 0;
  //len += sprintf(proc_read_text + len, "WUPPER driver 4.5.0 for RM4 F/W and TDAQ release %s. Distributed with driver RPM %s\n", RELEASE_NAME, WUPPER_TAG);
  len += sprintf(proc_read_text + len, "WUPPER driver 4.5.0 for RM4 F/W only\n");

  if(cardsignored)
    len += sprintf(proc_read_text + len, "ERROR: %d card(s) were ignored because of a problem with the power status\n", cardsignored);

  len += sprintf(proc_read_text + len, "\nDebug                         = %d\n", debug);
  len += sprintf(proc_read_text + len, "Number of devices detected    = %d\n\n", devicesFound);

  //First we show the global lock bits. This can be removed later
  len += sprintf(proc_read_text + len, "\nLocked resources\n");
  len += sprintf(proc_read_text + len, "      device | global_locks\n");
  len += sprintf(proc_read_text + len, "=============|=============\n");
  for (device = 0; device < devicesFound; device++)
    len += sprintf(proc_read_text + len, "           %d |   0x%08x\n", device, global_locks[device]);

  //And now the individual locks
  len += sprintf(proc_read_text + len, "\nLocked resources\n");
  len += sprintf(proc_read_text + len, "device | resource bit |     PID |  tag\n");
  len += sprintf(proc_read_text + len, "=======|==============|=========|=====\n");
  for (device = 0; device < devicesFound; device++)
  {
    for (lbit = 0; lbit < MAXLOCKBITS; lbit++)
      if (lock_pid[device][lbit] != 0)	
	len += sprintf(proc_read_text + len, "     %d |           %2d | %7d |%5d\n", device, lbit, lock_pid[device][lbit], lock_tags[device][lbit]); 
  }

  for (device = 0; device < devicesFound; device++)
  {
    // Addresses depend on firmware version
    wuppercard_bar2_regs_t *rm = ioremap_nocache(devices[device].baseAddressBAR2, devices[device].sizeBAR2);

    u_int regmap_version = rm->REG_MAP_VERSION;

    char rmbyte;
    uint64_t buildDate        = rm->BOARD_ID_TIMESTAMP;
    uint64_t buildYear        = (buildDate >> 32) & 0xff;
    uint64_t GIT_TAG         = rm->GIT_TAG;
    git_commit_number      = rm->GIT_COMMIT_NUMBER;
    git_hash               = rm->GIT_HASH;
    device_type            = rm->CARD_TYPE;
    jumpers                = 0;

    buildMonth  = (buildDate >> 24) & 0xff;
    buildDay    = (buildDate >> 16) & 0xff;
    buildHour   = (buildDate >> 8) & 0xff;
    buildMinute = buildDate & 0xff;
    len += sprintf(proc_read_text + len, "\nDevice %d: (BAR0 = 0x%lx)\n", deviceIndex[device], devices[device].baseAddressBAR0);

    len += sprintf(proc_read_text + len, "Card type                   : WUPPER-%d\n", device_type);
    len += sprintf(proc_read_text + len, "Device type                 : 0x%04x\n", devices[device].pciDevice->device);

    nInterrrupts = rm->GENERIC_CONSTANTS.INTERRUPTS;
    nDescriptors = rm->GENERIC_CONSTANTS.DESCRIPTORS;

    fpga_dna  = rm->FPGA_DNA;
    len += sprintf(proc_read_text + len, "FPGA_DNA                    : 0x%016lx\n", fpga_dna);

    len += sprintf(proc_read_text + len, "Reg Map Version             : %d.%d\n", (regmap_version & 0xFF00) >> 8, regmap_version & 0x00FF);

    len += sprintf(proc_read_text + len, "GIT tag                     : ");
    for(i=0; i<8; i++){ //Maximum 8 bytes in git tag
        rmbyte = (GIT_TAG >> (i*8))  & 0xff;  
        if (rmbyte) len += sprintf(proc_read_text + len, "%c", rmbyte);
    }
    len += sprintf(proc_read_text + len, "\n");

    len += sprintf(proc_read_text + len, "BUILD Date and time         : %x-%x-20%llx at %02xh%02x\n", buildDay, buildMonth, buildYear, buildHour, buildMinute);
    len += sprintf(proc_read_text + len, "GIT commit number           : %d\n", git_commit_number);
    len += sprintf(proc_read_text + len, "GIT hash                    : 0x%08x\n", git_hash);


    len += sprintf(proc_read_text + len, "F/W partition (jumpers)     : %lu\n", 3 - ((jumpers >> 18) & 0x3));
    //firmware_mode = rm->FIRMWARE_MODE;

    //len += sprintf(proc_read_text + len, "Firmware mode               : %d\n", firmware_mode);

    len += sprintf(proc_read_text + len, "Number of descriptors       : %d\n", nDescriptors);
    len += sprintf(proc_read_text + len, "Number of interrupts        : %d\n", nDescriptors);
    
    
    

    if (msixBar[deviceIndex[device]] != NULL)
    {
      len += sprintf(proc_read_text + len, "Interrupt count |");
      for (interrupt = 0; interrupt < msixblock; interrupt++)
        len += sprintf(proc_read_text + len, " %6d |", irqCount[deviceIndex[device]][interrupt]);

      len += sprintf(proc_read_text + len, "\nInterrupt flag  |");
      for (interrupt = 0; interrupt < msixblock; interrupt++)
        len += sprintf(proc_read_text + len, " %6d |", irqFlag[deviceIndex[device]][interrupt]);

      len += sprintf(proc_read_text + len, "\nInterrupt mask  |");
      for (interrupt = 0; interrupt < msixblock; interrupt++)
        len += sprintf(proc_read_text + len, " %6d |", irqMasked[deviceIndex[device]][interrupt]);

      len += sprintf(proc_read_text + len, "\nMSI-X PBA       %08x\n",  msixBar[deviceIndex[device]][msixPbaOffset[deviceIndex[device]] / sizeof(uint32_t)]);
      len += sprintf(proc_read_text + len, "\n");
    }
    else
      len += sprintf(proc_read_text + len, "No MSI-X interrupts for device %d\n\n", device);
  }

  len += sprintf(proc_read_text + len, " \n");
  len += sprintf(proc_read_text + len, "The command 'echo <action> > /proc/wupper', executed as root,\n");
  len += sprintf(proc_read_text + len, "allows you to interact with the driver. Possible actions are:\n");
  len += sprintf(proc_read_text + len, "debug     -> Enable debugging\n");
  len += sprintf(proc_read_text + len, "nodebug   -> Disable debugging\n");
  len += sprintf(proc_read_text + len, "elog      -> Log errors to /var/log/message\n");
  len += sprintf(proc_read_text + len, "noelog    -> Do not log errors to /var/log/message\n");
  len += sprintf(proc_read_text + len, "swap      -> Enable automatic swapping of 0x7038 / 0x7039 and 0x427 / 0x428\n");
  len += sprintf(proc_read_text + len, "noswap    -> Disable automatic swapping of 0x7038 / 0x7039 and 0x427 / 0x428\n");
  len += sprintf(proc_read_text + len, "clearlock -> Clear all lock bits (Attention: Close processes that hold lock bits before you do this)\n");

  kdebug(("wupper(fill_proc_read_text): Number of characters created = %d\n", len))
  return(len);
}


/*********************************************************/
int wupper_mmap(struct file *file, struct vm_area_struct *vma)
/*********************************************************/
{
  u32 moff, msize;

  // it should be "shared" memory
  if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
  {
    kerror(("wupper(wupper_mmap): writeable mappings must be shared, rejecting\n"))
    return(-EINVAL);
  }

  msize = vma->vm_end - vma->vm_start;
  moff = vma->vm_pgoff;
  kdebug(("wupper(wupper_mmap): offset: 0x%x, size: 0x%x\n", moff, msize))
  moff = moff << PAGE_SHIFT;
  if (moff & ~PAGE_MASK)
  {
    kerror(("wupper(wupper_mmap): offset not aligned: %u\n", moff))
    return(-EINVAL);
  }

#if LINUX_VERSION_CODE < KERNEL_VERSION(3,7,0)
  vma->vm_flags |= VM_RESERVED;
#else
  vma->vm_flags |= VM_DONTEXPAND;
  vma->vm_flags |= VM_DONTDUMP;
#endif

  // we do not want to have this area swapped out, lock it
  vma->vm_flags |= VM_LOCKED;
  if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff, msize, vma->vm_page_prot) != 0)
  {
    kerror(("wupper(wupper_mmap): remap page range failed\n"))
    return(-EAGAIN);
  }

  vma->vm_ops = &wupper_vm_ops;
  return(0);
}


/******************************************/
void wupper_vmclose(struct vm_area_struct *vma)
/******************************************/
{
  kdebug(("wupper(wupper_mmap): closing mmap memory\n"))
}


/*************************************************************/
static long wupper_ioctl(struct file *file, u_int cmd, u_long arg)
/*************************************************************/
{
  card_params_t *deviceParams;
  static struct vm_area_struct *vmas, uvmas;
  u_int interrupt, lbit, device, address, inout;
  u_char capabilityId, capabilityIdOffset;
  u_short deviceControlRegister;
  u_int tlp, count;
  card_params_t temp;
  lock_params_t lockparams;

  kdebug(("wupper(wupper_ioctl): entered\n"))
  vmas = &uvmas;   //MJ: purpose unclear

  deviceParams = (card_params_t *)file->private_data;
  kdebug(("wupper(wupper_ioctl, pid=%d) device is %d\n", current->pid, deviceParams->slot))

  switch(cmd)
  {
  case GETCARDS:
    kdebug(("wupper(wupper_ioctl, GETCARDS\n"))
    if (copy_to_user(((int*)arg), &cdmap, sizeof(int) * 2 * MAXCARDS) != 0)
    {
      kerror(("wupper(wupper_ioctl, GETCARDS) Copy devicesFound to user space failed!\n"))
      return(-EFAULT); 
    }
    break;

  case GET_TLP:
    kdebug(("wupper(wupper_ioctl, GET_TLP)\n"))
    deviceParams = (card_params_t *)file->private_data;
    device = deviceParams->slot;

    // Offset of first capability list entry
    address = PCI_CAPABILITY_LIST;
    pci_read_config_byte(devices[device].pciDevice, address, &capabilityIdOffset);
    kdebug(("wupper(wupper_ioctl, GET_TLP) first capabilityIdOffset 0x%x\n", capabilityIdOffset))
    // Count protects against loop not terminating
    count = 0;
    while (count < PCI_CAP_ID_MAX)
    {
      pci_read_config_byte(devices[device].pciDevice, (u_int) capabilityIdOffset, &capabilityId);
      kdebug(("wupper(wupper_ioctl, GET_TLP) capabilityIdOffset 0x%x capabilityId 0x%x\n", capabilityIdOffset, capabilityId))
      if (capabilityId == PCI_CAP_ID_EXP)
        break;

      // Get next capability list entry offset
      address = (u_int) (capabilityIdOffset + PCI_CAP_LIST_NEXT);
      pci_read_config_byte(devices[device].pciDevice, address, &capabilityIdOffset);
      kdebug(("wupper(wupper_ioctl, GET_TLP) next capabilityIdOffset 0x%x\n", capabilityIdOffset))
      ++count;
    }
    if (count == PCI_CAP_ID_MAX)
    {
      kerror(("wupper(wupper_ioctl, GET_TLP) Did not find capability with TLP id\n"))
      return(-EINVAL);
    }

    address = capabilityIdOffset + PCI_EXP_DEVCTL;
    pci_read_config_word(devices[device].pciDevice, address, &deviceControlRegister);
    kdebug(("wupper(wupper_ioctl, GET_TLP) new deviceControlRegister 0x%x\n", deviceControlRegister))

    tlp = (deviceControlRegister & PCI_EXP_DEVCTL_PAYLOAD) >> 5;
    if (copy_to_user(((int*)arg), &tlp, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, GET_TLP) Copy value of TLP to user space failed!\n"))
      return(-EFAULT);
    }
    break;

  case WAIT_IRQ:    //WAIT_DMA
    kdebug(("wupper(wupper_ioctl, WAIT_IRQ, pid=%d) Entered\n", current->pid))
    deviceParams = (card_params_t *)file->private_data;
    device = deviceParams->slot;
    if (copy_from_user(&interrupt, (void *)arg, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, WAIT_IRQ) error from copy_from_user\n"))
      return(-EFAULT);
    }
    if (interrupt >= msixblock)
    {
      kerror(("wupper(wupper_ioctl, WAIT_IRQ) invalid interrupt specified %d\n", interrupt))
      return(-EINVAL);
    }
    kdebug(("wupper(wupper_ioctl, WAIT_IRQ, pid=%d) Waiting for interrupt %d\n", current->pid, interrupt))
    wait_event_interruptible(waitQueue, irqFlag[device][interrupt] == 1);
    //MJ: Rubini recommends to check the return code of wait_event_interruptible.
    //MJ: in case of a non-zero value -ERESTARTSYS should be returned

    irqFlag[device][interrupt] = 0;  //MJ: if other processes are waiting for the same interrupt, setting irqFlag[device][interrupt] back to 0 may hide the interrupt from them (see below)
    //MJ: According to Rubini (page 150, 151 of LDD3) there can be problems with race conditions if two processes are waiting for the same interrupt.
    //MJ: Is that a requirement for us?

    kdebug(("wupper(wupper_ioctl, WAIT_IRQ, pid=%d) finished waiting for IRQ %d\n", current->pid, interrupt))
    break;

  case CANCEL_IRQ_WAIT:
    kdebug(("wupper(wupper_ioctl) CANCEL_IRQ_WAIT\n"))
    deviceParams = (card_params_t *)file->private_data;
    device = deviceParams->slot;

    if (copy_from_user(&interrupt, (void *)arg, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, CANCEL_IRQ_WAIT) error from copy_from_user\n"))
      return(-EFAULT);
    }
    if (interrupt >= msixblock)
    {
      kerror(("wupper(wupper_ioctl, CANCEL_IRQ_WAIT) invalid interrupt specified %d\n", interrupt))
      return(-EINVAL);
    }

    kdebug(("wupper(wupper_ioctl, CANCEL_IRQ_WAIT) Cancelling interrupt %d\n", interrupt))
    // set flag to 1, wake_up_interruptible will wake up a process if the flag specified in wait_event_interruptible is set to 1
    irqFlag[device][interrupt] = 1;          //MJ: The access to the interrupt related data structures seems to be vulnerable to race conditions (two processes callinh different ioctls ate the same time)

    // Wake up everybody who was waiting for an interrupt 
    wake_up_interruptible(&waitQueue);   //MJ: Woken up process will not know that the interrupt has not arrived.
    break;

   case CLEAR_IRQ:
     kdebug(("wupper(wupper_ioctl, CLEAR_IRQ)\n"))
     deviceParams = (card_params_t *)file->private_data;
     device = deviceParams->slot;

     if (copy_from_user(&interrupt, (void *)arg, sizeof(u_int)) != 0)
     {
       kerror(("wupper(wupper_ioctl, CLEAR_IRQ) error from copy_from_user\n"))
       return(-EFAULT);
     }
     if (interrupt >= msixblock)
     {
       kerror(("wupper(wupper_ioctl, CLEAR_IRQ) invalid interrupt specified %d\n", interrupt))
       return(-EINVAL);
     }

     kdebug(("wupper(wupper_ioctl, CLEAR_IRQ) Clearing interrupt %d\n", interrupt))

     // set flag to 0 to clear a potentially pending (unsolicited) interrupt. 
     irqFlag[device][interrupt] = 0;          //MJ: The access to the interrupt related data structures seems to be vulnerable to race conditions (two processes callinh different ioctls ate the same time)
     break;
	
  case RESET_IRQ_COUNTERS:
    kdebug(("wupper(wupper_ioctl, RESET_IRQ_COUNTERS)\n"))
    deviceParams = (card_params_t *)file->private_data;
    device = deviceParams->slot;

    if (copy_from_user(&interrupt, (void *)arg, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, RESET_IRQ_COUNTERS) error from copy_from_user\n"))
      return(-EFAULT);
    }
    if (interrupt >= msixblock)
    {
      kerror(("wupper(wupper_ioctl, RESET_IRQ_COUNTERS) invalid interrupt specified %d\n", interrupt))
      return(-EINVAL);
    }	

    kdebug(("wupper(wupper_ioctl, RESET_IRQ_COUNTERS) Resetting counters of interrupt %d\n", interrupt))	
    irqCount[device][interrupt] = 0;

    break;

  case MASK_IRQ:   
    deviceParams = (card_params_t *)file->private_data;
    kdebug(("wupper(wupper_ioctl, MASK_IRQ, pid=%d) called for device %d\n", current->pid, deviceParams->slot))
    device = deviceParams->slot;

    if (copy_from_user(&interrupt, (void *)arg, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, MASK_IRQ, pid=%d) error from copy_from_user\n", current->pid))
      return(-EFAULT);
    }
    if (interrupt >= msixblock)
    {
      kerror(("wupper(wupper_ioctl, MASK_IRQ, pid=%d) invalid interrupt specified %d\n", current->pid, interrupt))
      return(-EINVAL);
    }
    // check that interrupt was not already masked
    if (irqMasked[device][interrupt] == 0)
    {
      disable_irq(msixTable[device][interrupt].vector);
      irqMasked[device][interrupt] = 1;
      kdebug(("wupper(wupper_ioctl, MASK_IRQ, pid=%d) masked interrupt %d\n", current->pid, interrupt))
    }
    else
      kdebug(("wupper(wupper_ioctl, MASK_IRQ, pid=%d) interrupt %d already masked -> no action\n", current->pid, interrupt))

    break;

  case UNMASK_IRQ:
    deviceParams = (card_params_t *)file->private_data;
    kdebug(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) called for device %d\n", current->pid, deviceParams->slot))
    device = deviceParams->slot;
    if (copy_from_user(&interrupt, (void *)arg, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) error from copy_from_user\n", current->pid))
      return(-EFAULT);
    }

    if (interrupt >= msixblock)
    {
      kerror(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) invalid interrupt specified %d\n", current->pid, interrupt))
      return(-EINVAL);
    }

    // check that interrupt was not already unmasked
    if (irqMasked[device][interrupt] == 1)
    {
      kdebug(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) msixTable[%d][%d].vector = %d\n", current->pid, device, interrupt, msixTable[device][interrupt].vector))

      enable_irq(msixTable[device][interrupt].vector);
      irqMasked[device][interrupt] = 0;
      kdebug(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) unmasked interrupt %d\n", current->pid, interrupt))
    }
    else
    {
      kdebug(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) msixTable[%d][%d].vector = %d\n", current->pid, device, interrupt, msixTable[device][interrupt].vector))
      kdebug(("wupper(wupper_ioctl, UNMASK_IRQ, pid=%d) interrupt %d already unmasked -> no action\n", current->pid, interrupt))
    }

    break;

  case SETCARD:
    if (copy_from_user( (void *) &temp, (void *)arg, sizeof(card_params_t)) != 0)
    {
      kerror(("wupper(wupper_ioctl, SETCARD) error from copy_from_user\n"))
      return(-EFAULT);
    }

    deviceParams = (card_params_t *)file->private_data;
    device = temp.slot;
    kdebug(("wupper(wupper_ioctl, SETCARD) device = %d\n", device))

    if (device >= MAXCARDS)
    {
      kerror(("wupper(wupper_ioctl, SETCARD) Invalid (%d) slot number\n", device))
      return(-EINVAL);
    }
    if (devices[device].pciDevice == NULL)
    {
      kerror(("wupper(wupper_ioctl, SETCARD) No device at this (%d) slot!\n", device))
      return(-EINVAL);
    }

    kdebug(("wupper(wupper_ioctl, SETCARD) lock_mask = 0x%08x\n", temp.lock_mask))

    if (temp.lock_mask)  
    {
      spin_lock_irqsave(&lock_lock, lock_irq_flags);   //Please do not disturb...

      //Check if the bits requested by this process are already locked
      //Using global_locks is just for convenience. We could also search lock_pid bit by bit

      kdebug(("wupper(wupper_ioctl, SETCARD) Old global_locks[%d] is 0x%08x\n", temp.slot, global_locks[temp.slot]))
      kdebug(("wupper(wupper_ioctl, SETCARD) user lock_mask is 0x%08x\n", temp.lock_mask))

      temp.lock_error = 0;
      if (temp.lock_mask & global_locks[temp.slot])
      {
        kerror(("wupper(wupper_ioctl, SETCARD) ERROR(locking conflict): global_locks[%d] is 0x%08x and user lock_mask is 0x%08x\n", temp.slot, global_locks[temp.slot], temp.lock_mask))
        temp.lock_error = global_locks[temp.slot];
	devices[device].lock_error = temp.lock_error;
      }	  
      else
      {
        //No conflict. Remember the newly locked bits
	global_locks[temp.slot] |= temp.lock_mask;
        kdebug(("wupper(wupper_ioctl, SETCARD) New global_locks[%d] is 0x%08x\n", temp.slot, global_locks[temp.slot]))

	//Update the table for proc_read
	for(lbit = 0; lbit < MAXLOCKBITS; lbit++)
	{
	  if (temp.lock_mask & (1 << lbit))
	  {
            kdebug(("wupper(wupper_ioctl, SETCARD) registering bit %d of device %d for PID %d and tag %d\n", lbit, temp.slot, current->pid, lock_tag))
	    lock_pid[temp.slot][lbit] = current->pid;
	    lock_tags[temp.slot][lbit] = lock_tag;
	  }
	}
        deviceParams->lock_tag = lock_tag;
	devices[device].lock_tag = lock_tag;
	devices[device].lock_mask = temp.lock_mask;
	devices[device].lock_error = temp.lock_error;
	lock_tag++;
      }
      spin_unlock_irqrestore(&lock_lock, lock_irq_flags);   
    }
    else
    {
      kdebug(("wupper(wupper_ioctl, SETCARD) No locking requested\n"))
      deviceParams->lock_tag = lock_tag;
      devices[device].lock_tag = 0;
      devices[device].lock_mask = 0;
      devices[device].lock_error = 0;
    }

    deviceParams->slot = device;
    deviceParams->baseAddressBAR0 = devices[device].baseAddressBAR0;
    deviceParams->sizeBAR0 = devices[device].sizeBAR0;
    deviceParams->baseAddressBAR1 = devices[device].baseAddressBAR1;
    deviceParams->sizeBAR1 = devices[device].sizeBAR1;
    deviceParams->baseAddressBAR2 = devices[device].baseAddressBAR2;
    deviceParams->sizeBAR2 = devices[device].sizeBAR2;
    // OK, we have a valid slot, copy configuration back to user

    kdebug(("wupper(wupper_ioctl, SETCARD) devices[device].lock_error before copy_to_user is %d\n", devices[device].lock_error))
    kdebug(("wupper(wupper_ioctl, SETCARD) sizeof(card_params_t) is %ld\n", sizeof(card_params_t)))

    if (copy_to_user(((card_params_t *)arg), &devices[device], sizeof(card_params_t)) != 0)
    {
      kerror(("wupper(wupper_ioctl, SETCARD) Copy card_params_t to user space failed!\n"))
      return(-EFAULT);
    }
    kdebug(("wupper(wupper_ioctl, SETCARD) end of ioctl SETCARD\n"))
    break;

  case GETLOCK:
    if (copy_from_user((void *) &inout, (void *)arg, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, GETLOCK) error from copy_from_user\n"))
      return(-EFAULT);
    }

    kdebug(("wupper(wupper_ioctl, GETLOCK) inout = %d\n", inout))
    
    if (inout >= MAXCARDS)
    {
      kerror(("wupper(wupper_ioctl, GETLOCK) Invalid slot number %d\n", inout))
      return(-EINVAL);
    }

    address = inout;                  //just to avoid using "inout" for two different purposes
    inout = global_locks[address];    

    kdebug(("wupper(wupper_ioctl, GETLOCK) global_locks[%d] = 0x%08x\n", address, global_locks[address]))
    kdebug(("wupper(wupper_ioctl, GETLOCK) inout = 0x%08x\n", inout))

    if (copy_to_user(((u_int *)arg), &inout, sizeof(u_int)) != 0)
    {
      kerror(("wupper(wupper_ioctl, GETLOCK) Copy card_params_t to user space failed!\n"))
      return(-EFAULT);
    }
    kdebug(("wupper(wupper_ioctl, GETLOCK) end of ioctl GETLOCK\n"))   
    break;

	
    //MJ Note: technically the garbage collection in wupper_Release is able to return the resource locks. Therefore the RELEASELOCK ioctl
    //         is luxury and can be removed unless an explicit release of the resources is desired.
    //MJ: The explicit release have the (useful?) advantage that a process can close access to a WUPPER device and re-open it with 
    //    different locking parameters without a restart of that process. 	
  case RELEASELOCK:
    kdebug(("wupper(wupper_ioctl, RELEASELOCK): called\n"))
    if (copy_from_user((void *) &lockparams, (void *)arg, sizeof(lock_params_t)) != 0)
    {
      kerror(("wupper(wupper_ioctl, RELEASELOCK) error from copy_from_user\n"))
      return(-EFAULT);
    }
    kdebug(("wupper(wupper_ioctl, RELEASELOCK): called for PID = %d and lockparams.slot = %d and lockparams.lock_tag = %d \n", current->pid, lockparams.slot, lockparams.lock_tag))

    spin_lock_irqsave(&lock_lock, lock_irq_flags);   //Please do not disturb...

    kdebug(("wupper(wupper_ioctl, RELEASELOCK) Old global_locks[%d] is 0x%08x\n", lockparams.slot, global_locks[lockparams.slot]))
    for(lbit = 0; lbit < MAXLOCKBITS; lbit++)
    {
      if (lock_pid[lockparams.slot][lbit] == current->pid && lock_tags[lockparams.slot][lbit] == lockparams.lock_tag)
      {
        kdebug(("wupper(wupper_ioctl, RELEASELOCK) unregistering bit %d of device %d for PID %d\n", lbit, lockparams.slot, current->pid))
	lock_pid[lockparams.slot][lbit] = 0;
	lock_tags[lockparams.slot][lbit] = 0;
        global_locks[lockparams.slot] = global_locks[lockparams.slot] & ~(1 << lbit);
      }
    }
    kdebug(("wupper(wupper_ioctl, RELEASELOCK) New global_locks[%d] is 0x%08x\n", lockparams.slot, global_locks[lockparams.slot]))
    spin_unlock_irqrestore(&lock_lock, lock_irq_flags);   
    break;

  default:
    kerror(("wupper(wupper_ioctl, default) Unknown ioctl 0x%x\n", cmd))
    return(-EINVAL);
    }

  return 0;
}

