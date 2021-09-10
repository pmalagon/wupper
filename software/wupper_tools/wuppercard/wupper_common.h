/*************************************************************************/
/*                                                                       */
/* This is the common header file for the WupperCard library and wupper driver */
/*                                                                       */
/* Author: Markus Joos, CERN                                             */
/*                                                                       */
/**C 2017 Ecosoft - Made from at least 80% recycled source code**      ***/


#ifndef _WUPPER_COMMON_H
#define _WUPPER_COMMON_H

#ifdef __KERNEL__
  #include <linux/types.h>
#else
  #include <sys/types.h>
#endif


/* ioctl "switch" flags */
#define WUPPER_MAGIC 'y'

#define GETCARDS            _IOW(WUPPER_MAGIC, 1, int)
#define SETCARD             _IOR(WUPPER_MAGIC, 2, card_params_t*)
#define GET_TLP             _IOW(WUPPER_MAGIC, 3, int)
#define WAIT_IRQ            _IOW(WUPPER_MAGIC, 4, u_int)
#define CANCEL_IRQ_WAIT     _IOW(WUPPER_MAGIC, 5, u_int)
#define CLEAR_IRQ           _IOW(WUPPER_MAGIC, 6, u_int)
#define RESET_IRQ_COUNTERS  _IOW(WUPPER_MAGIC, 7, u_int)
#define MASK_IRQ            _IOW(WUPPER_MAGIC, 8, int)
#define UNMASK_IRQ          _IOW(WUPPER_MAGIC, 9, int)
#define GETLOCK             _IOW(WUPPER_MAGIC, 10, u_int)
#define RELEASELOCK         _IOW(WUPPER_MAGIC, 11, u_int)

//typedef struct
//{
//  u_int handle;
//  u_int offs;
//  u_int func;
//  u_int data;
//  u_int size;
//} IO_PCI_CONF_t;

#define MAXCARDS	8   // Max. number of WUPPER cards
#define MAXLOCKBITS     32  // Max. number of lockable resources. NOTE: do not increase to more than 32 because global_locks in the driver is an int

typedef struct
{
    struct pci_dev *pciDevice;
    u_int slot;
    u_int baseAddressBAR0;
    u_int sizeBAR0;
    u_int baseAddressBAR1;
    u_int sizeBAR1;
    u_int baseAddressBAR2;
    u_int sizeBAR2;
    u_int baseAddressBAR3;
    u_int sizeBAR3;
    u_int lock_mask;          //used in the SETCARD ioctl to receive the lock bits form the user application
    u_int lock_tag;           //used to separate the locks of different WupperCard objects in the same thread
    u_int lock_error;         //used in the SETCARD ioctl to return locking related errors to the user code
} card_params_t;

typedef struct
{
    u_int slot;
    u_int lock_tag;           //used to separate the locks of different WupperCard objects in the same thread
} lock_params_t;


#endif



