/*******************************************************************/
/*                                                                 */
/* This is the C++ source code of the WupperCard object               */
/*                                                                 */
/* Author: Markus Joos, CERN                                       */
/*                                                                 */
/**C 2019 Ecosoft - Made from at least 80% recycled source code*****/


#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <stdexcept>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <linux/types.h>

#include "DFDebug/DFDebug.h"
#include "wuppercard/WupperCard.h"
#include "wuppercard/WupperException.h"

int WupperCard::m_cards_open = 0;
static int m_timeout      = 0;

minipod_device_t minipod_devices48[] =
{
  {"MINIPOD-TX1", " 1st TX"},
  {"MINIPOD-RX1", " 1st RX"},
  {"MINIPOD-TX2", " 2nd TX"},
  {"MINIPOD-RX2", " 2nd RX"},
  {"MINIPOD-TX3", " 3rd TX"},
  {"MINIPOD-RX3", " 3rd RX"},
  {"MINIPOD-TX4", " 4th TX"},
  {"MINIPOD-RX4", " 4th RX"},
  {NULL,              NULL}
};

minipod_device_t minipod_devices24[] =
{
  {"MINIPOD-TX1", " 1st TX"},
  {"MINIPOD-RX1", " 1st RX"},
  {"MINIPOD-TX2", " 2nd TX"},
  {"MINIPOD-RX2", " 2nd RX"},
  {NULL,              NULL}
};


ltc_device_t ltc_devices[] =
{
  {"LTC2991_1", "First LTC2991"},
  {"LTC2991_2", "Second LTC2991"},
  {NULL,         NULL}
};

/****************************************/
void watchdogtimer_handler(int /*signum*/)
/****************************************/
{
  m_timeout = 1;
  DEBUG_TEXT(DFDB_FELIXCARD, 10, "WupperCard::watchdogtimer_handler: Timer expired. m_timeout = " << m_timeout);
}


/****************/
WupperCard::WupperCard()
/****************/
{
  m_fd                   = 0;
  m_slotNumber           = -1;
  m_Bar_0_Base           = 0;
  m_Bar_1_Base           = 0;
  m_Bar_2_Base           = 0;
  m_card_model           = 0;
  verboseFlag            = false;
  m_my_locks             = 0;
  m_my_lock_tag          = 0;
}


i2c_device_t i2c_devices_WUPPER_709[] =
  {
    {"USR_CLK",         "SI570",                    0x5d, "1:0:0"},
    {"ADN2814",         "ADN2814",                  0x40, "2:0:0"},
    {"SI5345",          "SI5345",                   0x68, "2:0:0"},    
    {"FMC_TEMP_SENSOR", "TC74 (on CRORC TEST FMC)", 0x4A, "2:0:0"},
    {"ID_EEPROM",       "M24C08-WDW6TP",            0x54, "8:0:0"},
    {"SFP1-1",          "AFBR-709SMZ (Conven Mem)", 0x50, "16:1:0"},
    {"SFP1-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, "16:1:0"},
    {"SFP2-1",          "AFBR-709SMZ (Conven Mem)", 0x50, "16:2:0"},
    {"SFP2-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, "16:2:0"},
    {"SFP3-1",          "AFBR-709SMZ (Conven Mem)", 0x50, "16:4:0"},
    {"SFP3-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, "16:4:0"},
    {"SFP4-1",          "AFBR-709SMZ (Conven Mem)", 0x50, "16:8:0"},
    {"SFP4-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, "16:8:0"},
    {"DDR3-1",          "SRAM-MT8KTF51264HZ",       0x51, "64:0:0"},
    {"DDR3-2",          "SRAM-MT8KTF51264HZ",       0x52, "64:0:0"},
    {"REC_CLOCK",       "SI5324",                   0x68, "128:0:0"},
    {NULL,              NULL,                       0,    0}
  };


i2c_device_t i2c_devices_WUPPER_710[] =
  {
    {"CLOCK_RAM",       "ICS8N4Q001L IDT",          0x6e, "1:0:0"},
    {"CLOCK_SYS",       "ICS8N4Q001L IDT",          0x6e, "2:0:0"},
    {"CLOCK_CXP1",      "IDT 8N3Q001",              0x6e, "4:0:0"},
    {"CLOCK_CXP2",      "IDT 8N3Q001",              0x6e, "8:0:0"},
    {"ADN2814",         "ADN2814 (on TTCfx FMC)",   0x40, "16:0:0"},
    {"SI5345",          "SI5345",                   0x68, "16:0:0"},   
    {"FMC_TEMP_SENSOR", "TC74 (on CRORC TEST FMC)", 0x4A, "16:0:0"},
    {"CXP1_TX",         "AFBR-83PDZ",               0x50, "32:0:0"},
    {"CXP1_RX",         "AFBR-83PDZ",               0x54, "32:0:0"},
    {"CXP2_TX",         "AFBR-83PDZ",               0x50, "64:0:0"},
    {"CXP2_RX",         "AFBR-83PDZ",               0x54, "64:0:0"},
    {"DDR3-1",          "SRAM-MT16JTF25664HZ",      0x50, "128:0:0"},
    {"DDR3-2",          "SRAM-MT16JTF25664HZ",      0x51, "128:0:0"},
    {NULL,              NULL,                       0,    0}
  };


i2c_device_t i2c_devices_WUPPER_711[] =
  {
    {"ADN2814",         "ADN2814",                  0x40, "2:0:0"},
    {"SIS53154",        "SI53154",                  0x6b, "2:0:0"},
    {"LTC2991_1",       "LTC2991",                  0x48, "2:0:0"},
    {"LTC2991_2",       "LTC2991",                  0x49, "2:0:0"},
    {"SI5345",          "SI5345",                   0x68, "4:0:0"},
    {"TCA6408A",        "TCA6408A",                 0x20, "4:0:0"},
    {"MINIPOD-TX1",     "AFBR-814PxyZ",             0x2c, "8:0:0"},
    {"MINIPOD-TX2",     "AFBR-814PxyZ",             0x2d, "8:0:0"},
    {"MINIPOD-TX3",     "AFBR-814PxyZ",             0x2e, "8:0:0"},
    {"MINIPOD-TX4",     "AFBR-814PxyZ",             0x2f, "8:0:0"},
    {"MINIPOD-RX1",     "AFBR-824PxyZ",             0x30, "8:0:0"},
    {"MINIPOD-RX2",     "AFBR-824PxyZ",             0x31, "8:0:0"},
    {"MINIPOD-RX3",     "AFBR-824PxyZ",             0x32, "8:0:0"},
    {"MINIPOD-RX4",     "AFBR-824PxyZ",             0x33, "8:0:0"},
    {NULL,              NULL,                       0,    0}
  };
  
i2c_device_t i2c_devices_WUPPER_128[] =
  {
	{"IO_EXTENDER",         "TCA6416A",                 0x20, "0:0:0"},
	{"PMBUS_VCCINT",        "INA226",                   0x40, "0:1:0"},
	{"PMBUS_VCCBRAM",       "INA226",                   0x41, "0:1:0"},
	{"PMBUS_VCCVCC1V8",     "INA226",                   0x42, "0:1:0"},
	{"PMBUS_MGTAVCC",       "INA226",                   0x46, "0:1:0"},
	{"PMBUS_MGTAVTT",       "INA226",                   0x47, "0:1:0"},
	{"PMBUS_MGTAVCC",       "INA226",                   0x48, "0:1:0"},
	{"PMBUS_VCCHBM",        "INA226",                   0x4C, "0:1:0"},
	{"PMBUS_VCCAUX_HBM",    "INA226",                   0x4D, "0:1:0"},
	{"MAIN_PMBUS_SYS1V8",   "ISL91211",                 0x60, "0:4:0"},
	{"MAIN_PMBUS_UTIL_1V35","ISL91302",                 0x61, "0:4:0"},
	{"MAIN_PMBUS_QDR_1V3",  "ISL91302",                 0x62, "0:4:0"},
	{"MAIN_PMBUS_VCC_VADJ", "ISL91302",                 0x63, "0:4:0"},
	{"MAIN_PMBUS_VDDQ",     "ISL91302",                 0x64, "0:4:0"},
	{"MAIN_PMBUS_VCCINT",   "ISL68127",                 0x65, "0:4:0"},
	{"MAIN_PMBUS_VCCHBM",   "ISL68301",                 0x68, "0:4:0"},
	{"MAIN_PMBUS_MGTAVTT",  "ISL68301",                 0x69, "0:4:0"},
	{"MAIN_PMBUS_UTIL_3V3", "ISL68301",                 0x6A, "0:4:0"},
	{"MAIN_PMBUS_UTIL_5V0", "ISL68301",                 0x6B, "0:4:0"},
	{"IIC_EEPROM",          "M24C08",                   0x54, "1:0:0"},
	{"SI5328",              "SI5328",                   0x68, "2:0:0"},
	{"QSFP1_SI570",         "SI570",                    0x5D, "8:0:0"},
	{"QSFP2_SI570",         "SI570",                    0x5D, "16:0:0"},
	{"QSFP3_SI570",         "SI570",                    0x5D, "32:0:0"},
	{"QSFP4_SI570",         "SI570",                    0x5D, "64:0:0"},
	{"QSFP1_I2C",           "QSFP",                     0x50, "0:0:16"},
	{"QSFP2_I2C",           "QSFP",                     0x50, "0:0:32"},
	{"QSFP3_I2C",           "QSFP",                     0x50, "0:0:64"},
	{"QSFP4_I2C",           "QSFP",                     0x50, "0:0:128"},
	{NULL,                  NULL,                       0,    0}
  };


/*********************************************/
void WupperCard::card_open(int n, u_int lock_mask)
/*********************************************/
{
  card_params_t card_data;
  int tlp_bits;
  char nodename[30];

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::card_open: Method called for card " << n << " with lock_mask " << HEX(lock_mask));

  //Install a signal handler for the implementation of watchdog timers.  //Note: The signal handler must only be installed once.
  if (m_cards_open == 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_open: Installing signal handler");
    struct sigaction sa;

    // Install timer_handler as the signal handler for SIGVTALRM
    memset(&sa, 0, sizeof (sa));
    sa.sa_handler = watchdogtimer_handler;
    sigaction (SIGVTALRM, &sa, NULL);  //MJ: According to http://www.gnu.org/software/libc/manual/html_node/Setting-an-Alarm.html SIGALRM  may be better
    m_cards_open = 1;
  }
  else
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_open: Signal handler already installed");
    m_cards_open++;
  }

  sprintf(&nodename[0], "/dev/wupper%d", n);
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::card_open: nodename = " << nodename);

  m_fd = open(nodename, O_RDWR);
  
  if (m_fd < 0)
  {
    if (m_cards_open == 1)
      sigaction(SIGVTALRM, NULL, NULL);
    else
      m_cards_open--;

    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_open: Failed to open " << nodename);
    THROW_WUPPER_EXCEPTION(NOTOPENED, "Failed to open " << nodename)
  }
  card_data.slot      = n;
  card_data.lock_mask = lock_mask;

  int iores = ioctl(m_fd, SETCARD, &card_data);  
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_open: card_data.lock_error  = " << card_data.lock_error);
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_open: sizeof(card_params_t) = " << sizeof(card_params_t));

  if (iores < 0)
  {
    //Clean up...  
    close(m_fd);
    if (m_cards_open == 1)
      sigaction(SIGVTALRM, NULL, NULL);
    else
      m_cards_open--;
    //...and exit
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_open: Error from ioctl(SETCARD).");
    THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(SETCARD)")
  }
  if (card_data.lock_error)
  {
    //Clean up...  
    close(m_fd);
    if (m_cards_open == 1)
      sigaction(SIGVTALRM, NULL, NULL);
    else
      m_cards_open--;
    //...and exit
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_open: Error from ioctl(SETCARD). Some resources are already locked. card_data.lock_error = " << HEX(card_data.lock_error));
    THROW_WUPPER_EXCEPTION(LOCK_VIOLATION, "Error: Some resources are already locked by other processes. The set of locked resources is " << HEX(card_data.lock_error))
  }

  m_my_lock_tag = card_data.lock_tag;
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_open: m_my_lock_tag is " << m_my_lock_tag);
 
  m_my_locks = lock_mask;
  m_slotNumber = n;

  m_Bar_0_Base = map_memory_bar(card_data.baseAddressBAR0, 4096);
  m_Bar_1_Base = map_memory_bar(card_data.baseAddressBAR1, 4096);
  m_Bar_2_Base = map_memory_bar(card_data.baseAddressBAR2, 65536);

  m_bar0 = (wuppercard_bar0_regs_t *)m_Bar_0_Base;
  m_bar1 = (wuppercard_bar1_regs_t *)m_Bar_1_Base;

  m_card_model = card_model();

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::card_open: Obtaining max. TLP size from driver.");
  iores = ioctl(m_fd, GET_TLP, &tlp_bits);
  if(iores < 0)
  {
    //Clean up...  
    unmap_memory_bar(m_Bar_0_Base, 4096);
    unmap_memory_bar(m_Bar_1_Base, 4096);
    unmap_memory_bar(m_Bar_2_Base, 65536);      
    close(m_fd);
    if (m_cards_open == 1)
      sigaction(SIGVTALRM, NULL, NULL);
    else
      m_cards_open--;
    //...and exit
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_open: Error from ioctl(GET_TLP).");
    THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(GET_TLP)")
  }

  m_maxTLPBytes = 128 << tlp_bits;  //MJ: replace 128 by a constant??

  //Does the RM (register model) of the F/W match the RM of the S/W?
  
  u_long regmap_version_fw_major = cfg_get_reg(REG_REG_MAP_VERSION) >> 8 & 0xff;
  u_long regmap_version_sw_major = REGMAP_VERSION >> 8 & 0xff;
  if (regmap_version_sw_major != regmap_version_fw_major)
  {
    //Clean up...  
    unmap_memory_bar(m_Bar_0_Base, 4096);
    unmap_memory_bar(m_Bar_1_Base, 4096);
    unmap_memory_bar(m_Bar_2_Base, 65536);      
    close(m_fd);
    if (m_cards_open == 1)
      sigaction(SIGVTALRM, NULL, NULL);
    else
      m_cards_open--;
    //...and exit
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_open: F/W Regmap = " << regmap_version_fw_major << " but S/W Regmap = " << regmap_version_sw_major);
    THROW_WUPPER_EXCEPTION(HW, "Regmap versions of H/W and S/W do not match")
  }
   
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_open: done with m_cards_open = " << m_cards_open);
}


/****************************/
void WupperCard::card_close(void)
/****************************/
{
  lock_params_t lockparams;
  
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::card_close: Method called.");

  //Get rid of the signal handler when we close the last instance
  if (m_cards_open == 1)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_close: Removing signal handler");
    sigaction(SIGVTALRM, NULL, NULL);
  }
  else
  {
    m_cards_open--;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_close: m_cards_open = " << m_cards_open);
  }

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::card_close: returning locks for tag = " << m_my_lock_tag << " and slot " << m_slotNumber);
  
  lockparams.lock_tag = m_my_lock_tag;
  lockparams.slot     = m_slotNumber;
  int iores = ioctl(m_fd, RELEASELOCK, &lockparams);
  if(iores < 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_close: Error from ioctl(RELEASELOCK).");
    THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RELEASELOCK)")
  }  
  
  if (m_fd == 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_close: m_fd is zero");
    THROW_WUPPER_EXCEPTION(NOTOPENED, "The link to the driver is already closed (or has never been opened)")
  }

  unmap_memory_bar(m_Bar_0_Base, 4096);
  unmap_memory_bar(m_Bar_1_Base, 4096);
  unmap_memory_bar(m_Bar_2_Base, 65536);

  close(m_fd);
}


/*********************************/
u_int WupperCard::get_lock_mask(int n)
/*********************************/
{
  card_params_t card_data;
  u_int inout, other_locks;
  char nodename[30];

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::get_lock_mask: Method called with m_cards_open = " << m_cards_open);

  if (!m_cards_open)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::get_lock_mask: We have to open the device file");
 
    sprintf(&nodename[0], "/dev/wupper%d", n);
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::get_lock_mask: nodename = " << nodename);

    m_fd = open(nodename, O_RDWR);
    if (m_fd < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::get_lock_mask: Failed to open " << nodename);
      THROW_WUPPER_EXCEPTION(NOTOPENED, "Failed to open /dev/wupper " << nodename)
    }
    card_data.slot      = n;
    card_data.lock_mask = 0;

    int iores = ioctl(m_fd, SETCARD, &card_data);  
    if(iores < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_open: Error from ioctl(SETCARD).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(SETCARD)")
    }
  }
  
  //definition of "inout":
  //Into the driver: card number 
  //Out of the driver: lock_mask for the card
  inout = n;
  int iores = ioctl(m_fd, GETLOCK, &inout);
  if(iores < 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::get_lock_mask: Error from ioctl(GETLOCK).");
    THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(GETLOCK)")
  }
  
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_lock_mask: Global locks for card " << n << " = " << HEX(inout));
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_lock_mask:  Local locks for card " << n << " = " << HEX(m_my_locks));

  //remove the local locks
  other_locks = inout^m_my_locks;
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_lock_mask:  Other locks for card " << n << " = " << HEX(other_locks));

  if (!m_cards_open)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::get_lock_mask: We have to close the device file");
    close(m_fd);
  }
  
  return(other_locks);
}


/**********************************/
u_int WupperCard::number_of_cards(void)
/**********************************/
{
  int iores, numberOfCardsFound = 0;
  int fd;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::number_of_cards: Method called.");
 
  fd = open("/dev/wupper0", O_RDWR);
  if (fd < 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::number_of_cards: Failed to open /dev/wupper0");
    return 0;
  }
  
  iores = ioctl(fd, GETCARDS, &numberOfCardsFound);
  if(iores < 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::number_of_cards: Error from ioctl(GETCARDS).");
    close(fd);
    return 0;
  }
  
  close(fd);

  return numberOfCardsFound;
}


/**********************************/
int WupperCard::dma_max_tlp_bytes(void)
/**********************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_max_tlp_bytes: Method called.");
  return (m_maxTLPBytes);
}


/**********************************/
void WupperCard::dma_stop(u_int dma_id)
/**********************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_stop: Method called.");
  m_bar0->DMA_DESC_ENABLE &= ~(1 << dma_id);
}


/***************************************************************************/
void WupperCard::dma_to_host(u_int dma_id, u_long dst, size_t size, u_int flags)
/***************************************************************************/
{ 
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_to_host: Method called with dma_id = " << dma_id << ", dst = 0x" << HEX(dst) << ", size = " << size << ", flags = " << flags);
  dma_stop(dma_id);

  if (dst == 0 || size == 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::dma_to_host: dst or size is zero.");
    THROW_WUPPER_EXCEPTION(PARAM, "dst or size is zero")
  }
  
  if ((size % m_maxTLPBytes) != 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::dma_to_host: size is not a multiple of tlp.");
    THROW_WUPPER_EXCEPTION(PARAM, "size is not a multiple of tlp")
  }

  m_bar0->DMA_DESC[dma_id].start_address = dst;
  m_bar0->DMA_DESC[dma_id].end_address   = dst + size;
  m_bar0->DMA_DESC[dma_id].tlp           = m_maxTLPBytes / 4;
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_to_host: m_bar0->DMA_DESC[" << dma_id << "].tlp = " << m_maxTLPBytes / 4);
  m_bar0->DMA_DESC[dma_id].read          = 0;
  m_bar0->DMA_DESC[dma_id].wrap_around   = (flags & WUPPER_DMA_WRAPAROUND) ? 1 : 0;
  m_bar0->DMA_DESC[dma_id].read_ptr      = dst;

  if(m_bar0->DMA_DESC_STATUS[dma_id].even_addr_pc == m_bar0->DMA_DESC_STATUS[dma_id].even_addr_dma)
  {
    // Make 'even_addr_pc' unequal to 'even_addr_dma', or a (circular) DMA won't start!?
    --m_bar0->DMA_DESC[dma_id].read_ptr;
    ++m_bar0->DMA_DESC[dma_id].read_ptr;
  }

  m_bar0->DMA_DESC_ENABLE |= 1 << dma_id;
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_to_host: DMA started");
}


/*****************************************************************************/
void WupperCard::dma_from_host(u_int dma_id, u_long src, size_t size, u_int flags)
/*****************************************************************************/
{
  u_int best_tlp;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_from_host: Method called.");
  dma_stop(dma_id);
  
  if (src == 0 || size == 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::dma_from_host: src or size is zero.");
    THROW_WUPPER_EXCEPTION(PARAM, "src or size is zero")
  }
  
  if ((size % 32) != 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::dma_from_host: size is not a multiple of 32 bytes.");
    THROW_WUPPER_EXCEPTION(PARAM, "size is not a multiple of 32 bytes")
  } 

  best_tlp = m_maxTLPBytes;
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_from_host: first best_tlp = " << best_tlp);

  while(size % best_tlp)
  {  
    best_tlp = best_tlp >> 1; 
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_from_host: new best_tlp = " << best_tlp);
  }

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_from_host: size " << size << " best_tlp = " << best_tlp);
  
  m_bar0->DMA_DESC[dma_id].start_address = src;
  m_bar0->DMA_DESC[dma_id].end_address   = src + size;
  // To make sure each GBT-SCA command (fits in 32 bytes) is sent without delay
  // must set TLP size to 32 bytes in case of circular DMA (WUPPER-896);
  // in case of single-shot DMA there is an issue starting a DMA whose start address is not
  // aligned to the TLP size and crosses a 4K memory address boundary (WUPPER-937)
  // so for the time being FromHost TLP is set to 32 bytes only (Henk B, 16 Apr 2019)
  //if( (flags & WUPPER_DMA_WRAPAROUND) != 0 )
    m_bar0->DMA_DESC[dma_id].tlp         = 32 / 4;
  //else
  //  m_bar0->DMA_DESC[dma_id].tlp       = best_tlp / 4;
  m_bar0->DMA_DESC[dma_id].read          = 1;
  m_bar0->DMA_DESC[dma_id].wrap_around   = (flags & WUPPER_DMA_WRAPAROUND) ? 1 : 0;
  m_bar0->DMA_DESC[dma_id].read_ptr      = src;

  m_bar0->DMA_DESC_ENABLE |= 1 << dma_id;
}


/**********************************/
void WupperCard::dma_wait(u_int dma_id)
/**********************************/
{
  //Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec = 1;           // One second
  timer.it_value.tv_usec = 0;          
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 0;       // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_wait: Method called for dma_id = " << dma_id);
  while(m_bar0->DMA_DESC_ENABLE & (1 << dma_id))
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_wait: m_timeout = " << m_timeout << " m_bar0->DMA_DESC_ENABLE = " << m_bar0->DMA_DESC_ENABLE);
    
    if (m_timeout)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::dma_wait: ERROR: Timeout");
      THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout")
    }
  }
  //Stop watchdog
  timer.it_value.tv_usec = 0;    // Stop timer
  timer.it_value.tv_sec = 0;     // Stop timer
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_wait: Done");
}


/***************************************************/
u_long WupperCard::dma_get_current_address(u_int dma_id)
/***************************************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_get_current_address: Method called with dma_id = " << dma_id);
  return(m_bar0->DMA_DESC_STATUS[dma_id].current_address);
}


/*******************************************/
bool WupperCard::dma_cmp_even_bits(u_int dma_id)
/*******************************************/
{
  u_long *ulp, lvalue, offset;
  u_int b1, b2;
  
  //NOTE: I am not using the wuppercard_bar0_regs_t structure because the EVEN_PC and EVEN_DMA bits must read with one PCI cycle.
  //      This may not be guaranteed by accessing the fields of the stucture.
  
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_cmp_even_bits: Method called with dma_id = " << dma_id);
  offset = (u_long)&m_bar0->DMA_DESC_STATUS[0] - (u_long)&m_bar0->DMA_DESC[0];    //Note: This trick is to get the offset of the first STATUS register. 
                                                                                  //      That way we are safe agains changes in the register model  
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_cmp_even_bits: offset = 0x" << HEX(offset));
  ulp = (u_long *)(m_Bar_0_Base + offset);
  lvalue = ulp[1 + (dma_id * 2)];                                                 //Note: ulp[0] = FW_POINTER of channel 0, ulp[1] = status bits of channel 0, ul[[2] = FW_POINTER of channel 1, ect

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_cmp_even_bits: lvalue = 0x" << HEX(lvalue));
  b1 = (lvalue >> 1) & 0x1;
  b2 = (lvalue >> 2) & 0x1;
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::dma_cmp_even_bits: EVEN_PC = " << b2 << ", EVEN_DMA = " << b1);
 
  if(b1 == b2)
    return(true);
  else
    return(false);
}


/********************************************************************************/
void WupperCard::dma_advance_ptr(u_int dma_id, u_long dst, size_t size, size_t bytes)
/********************************************************************************/
{
  u_long tmp_read_ptr;
  
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_advance_from_host_ptr: Method called.");

  tmp_read_ptr = m_bar0->DMA_DESC[dma_id].read_ptr;
  tmp_read_ptr += bytes;
  if (tmp_read_ptr >= dst + size)
    tmp_read_ptr -= size;
  
  m_bar0->DMA_DESC[dma_id].read_ptr = tmp_read_ptr;
}


/*************************************************/
void WupperCard::dma_set_ptr(u_int dma_id, u_long dst)
/*************************************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_set_ptr: Method called.");
  m_bar0->DMA_DESC[dma_id].read_ptr = dst;
}


/********************************************/
u_long WupperCard::dma_get_read_ptr(u_int dma_id)
/********************************************/
{  
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_get_read_ptr: Method called.");

  return(m_bar0->DMA_DESC[dma_id].read_ptr);
}


/********************************/
void WupperCard::dma_fifo_flush(void)
/********************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_fifo_flush: Method called.");
  m_bar0->DMA_FIFO_FLUSH = 1;
}


/***************************/
void WupperCard::dma_reset(void)
/***************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::dma_reset: Method called.");
  m_bar0->DMA_RESET = 1;
}


/****************************/
void WupperCard::soft_reset(void)
/****************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::soft_reset: Method called.");
  m_bar0->SOFT_RESET = 1;
}


/*********************************/
void WupperCard::registers_reset(void)
/*********************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::registers_reset: Method called.");
  m_bar0->REGISTERS_RESET = 1;
}

/**********************************************************/
void WupperCard::i2c_write_byte(u_char slave_addr, u_char byte)
/**********************************************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_write_byte: Method called.");

  i2c_wait_not_full();

  u_long value = 0;
  value |= ((u_long)slave_addr << 1);
  value |= ((u_long)byte << 8);
  cfg_set_reg(REG_I2C_WR, value);
  usleep(I2C_DELAY);
}


/*******************************************************************************/
void WupperCard::i2c_write_byte_to_addr(u_char slave_addr, u_char addr, u_char byte)
/*******************************************************************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_write_byte_to_addr: Method called.");

  i2c_wait_not_full();

  u_long value = 0;
  value |= ((u_long)slave_addr << 1);
  value |= ((u_long)addr << 8);
  value |= ((u_long)byte << 16);
  value |= (1 << 24);
  cfg_set_reg(REG_I2C_WR, value);
  usleep(I2C_DELAY);
}


/***********************************************************/
u_char WupperCard::i2c_read_byte(u_char slave_addr, u_char addr)
/***********************************************************/
{
  u_long res;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_read_byte: Method called with slave_addr = " << (u_int)slave_addr << " and addr = " << (u_int)addr);

  i2c_wait_not_full();

  u_long value = 1;
  value |= ((u_long)slave_addr << 1);
  value |= ((u_long)addr << 8);
  value |= (1 << 24);

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_read_byte: value = 0x" << HEX(value));

  cfg_set_reg(REG_I2C_WR, value);
  usleep(I2C_DELAY);
  i2c_wait_not_empty();
  usleep(I2C_DELAY);
  cfg_set_reg(REG_I2C_RD, 1);
  usleep(I2C_DELAY);
  res = cfg_get_reg(REG_I2C_RD);

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_read_byte: res = 0x" << HEX(res));
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_read_byte: I2C_EMPTY_FLAG = 0x" << HEX(I2C_EMPTY_FLAG));

  if(res & I2C_EMPTY_FLAG)
    return(res & 0xff);
  else
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_read_byte: i2c_read_byte has failed because I2C_EMPTY_FLAG was not set");
    THROW_WUPPER_EXCEPTION(I2C, "i2c_read_byte has failed because I2C_EMPTY_FLAG was not set")
  }
  return 0;
}


/*******************************************************************************/
void WupperCard::i2c_devices_write(const char *device, u_char reg_addr, u_char data)
/*******************************************************************************/
{
  u_char bin_port1 = 0, bin_port2 = 0, bin_port3 = 0, address = 0;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_devices_write: method called with device = " << device << " and reg_addr = " << (u_int)reg_addr);

  int digics = i2c_parse_address(device, &bin_port1, &bin_port2, &bin_port3, &address);
  if(digics == 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_write: bin_port1 = " << (u_int)bin_port1);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_write: bin_port2 = " << (u_int)bin_port2);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_write: bin_port3 = " << (u_int)bin_port3);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_write: address   = " << (u_int)address);

    //Writing value.
    i2c_write(bin_port1, bin_port2, bin_port3, address, reg_addr, data);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_write: Writing " << data << " to register " << (u_int)reg_addr << " on port 1 " << (u_int)bin_port1 << " and port 2 " << (u_int)bin_port2 << " from device " << (u_int)address);
  }
  else
  {
    if(digics == I2C_DEVICE_ERROR_INVALID_PORT)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_devices_write: Invalid port.");
      THROW_WUPPER_EXCEPTION(I2C, "Invalid port")
    }
    if (digics == I2C_DEVICE_ERROR_INVALID_ADDRESS)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_devices_write: Invalid address.");
      THROW_WUPPER_EXCEPTION(I2C, "Invalid address")
    }

    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_devices_write: Device does not exist.");
    THROW_WUPPER_EXCEPTION(I2C, "Device does not exist")
  }
}


/********************************************************************************/
void WupperCard::i2c_devices_read(const char *device, u_char reg_addr, u_char *value)
/********************************************************************************/
{
  u_char bin_port1 = 0, bin_port2 = 0, bin_port3 = 0, address = 0;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_devices_read: method called with device = " << device << " and reg_addr = " << (u_int)reg_addr);

  int digics = i2c_parse_address(device, &bin_port1, &bin_port2, &bin_port3, &address);
  if(digics == 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_read: bin_port1 = " << (u_int)bin_port1);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_read: bin_port2 = " << (u_int)bin_port2);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_read: bin_port3 = " << (u_int)bin_port3);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_read: address   = " << (u_int)address);

    //Reading value.
    *value = i2c_read(bin_port1, bin_port2, bin_port3, address, reg_addr);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_devices_read: Register " << (u_int)reg_addr << " on port " << (u_int)bin_port1 << " and " << (u_int)bin_port2 << " from device " << (u_int)address << " = " << (u_int)*value);
  }
  else
  {
    if(digics == I2C_DEVICE_ERROR_INVALID_PORT)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_devices_read: Invalid port.");
      THROW_WUPPER_EXCEPTION(I2C, "Invalid address")
    }
    if (digics == I2C_DEVICE_ERROR_INVALID_ADDRESS)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_devices_read: Invalid address.");
      THROW_WUPPER_EXCEPTION(I2C, "Invalid address")
    }

    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_devices_read: Device does not exist.");
    THROW_WUPPER_EXCEPTION(I2C, "Device does not exist")
  }
}

/******************************************/
u_long WupperCard::cfg_get_reg(const char *key, int bar)
/******************************************/
{
  char *upper = strdup(key);
  regmap_register_t *reg;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::cfg_get_reg: method called for register " << key);
  str_upper(upper);
  
  if(bar == 0)reg = regmap_bar0_registers;
  if(bar == 1)reg = regmap_bar1_registers;
  if(bar == 2)reg = regmap_bar2_registers;
  if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");

  for(; reg->name != NULL; reg++)
  {
    if(strcmp(upper, reg->name) == 0)
    {
      if(!(reg->flags & REGMAP_REG_READ))
      {
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_reg: Register " << key << " not readable!");
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_reg: reg->flags   = 0x" << HEX(reg->flags));
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_reg: reg->address = 0x" << HEX(reg->address));
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_reg: reg->name    = " << reg->name);
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_reg: REGMAP_REG_READ = 0x" << HEX(REGMAP_REG_READ));
        THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register not readable!")
      }
     
      u_long *v = (u_long *)(m_Bar_2_Base + reg->address);
      free(upper);
      return(*v);
    }
  }

  free(upper);
  DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_reg: Register " << key << " does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register " << key << " does not exist!")
}


/*********************************************/
u_long WupperCard::cfg_get_option(const char *key, int bar)
/*********************************************/
{
  char *upper = strdup(key);
  regmap_bitfield_t *bf;
  u_long regvalue;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::cfg_get_option: method called with key = " << key);
  str_upper(upper);
  
  if(bar == 0)bf = regmap_bar0_bitfields;
  if(bar == 1)bf = regmap_bar1_bitfields;
  if(bar == 2)bf = regmap_bar2_bitfields;
  if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");
  for(; bf->name != NULL; bf++)
  {
    if(strcmp(upper, bf->name) == 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: bitfield found");
      if(!(bf->flags & REGMAP_REG_READ))
      {
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_option: Bitfield " << key << " not readable!");
        THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << " not readable!")
      }

      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: m_Bar_2_Base = 0x" << HEX(m_Bar_2_Base));
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: bf->address  = 0x" << HEX(bf->address));

      u_long *v = (u_long *)(m_Bar_2_Base + bf->address);
      regvalue = *v;
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: regvalue(1)  = 0x" << HEX(regvalue));
      regvalue = (regvalue & bf->mask) >> bf->shift;
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: bf->shift    = 0x" << HEX(bf->shift));
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: bf->mask     = 0x" << HEX(bf->mask));
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: regvalue(2)  = 0x" << HEX(regvalue));
      DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::cfg_get_option: end of method");
      free(upper);
      return(regvalue);
    }
  }

  free(upper);

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::cfg_get_option: upper freed");
  DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_get_option: Bitfield " << key << " does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << " does not exist!")
}


/******************************************************/
void WupperCard::cfg_set_reg(const char *key, u_long value, int bar)
/******************************************************/
{
  char *upper = strdup(key);
  regmap_register_t *reg;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::cfg_set_reg: method called for bit field " << key << " and value " << value);
  str_upper(upper);
  if(bar == 0)reg = regmap_bar0_registers;
  if(bar == 1)reg = regmap_bar1_registers;
  if(bar == 2)reg = regmap_bar2_registers;
  if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");
  
  for(; reg->name != NULL; reg++)
  {
    if(strcmp(upper, reg->name) == 0)
    {
      if(!(reg->flags & REGMAP_REG_WRITE))
      {
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_set_reg: Register " << key << " not writeable!");
        THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register " << key << " not writeable!")
      }

      u_long *v = (u_long *)(m_Bar_2_Base + reg->address);
      *v = value;
      free(upper);
      return;
    }
  }

  free(upper);
  DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_set_reg: Register " << key << " does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register " << key << " does not exist!")
}


/*********************************************************/
void WupperCard::cfg_set_option(const char *key, u_long value, int bar)
/*********************************************************/
{
  regmap_bitfield_t *bf;
  char *upper = strdup(key);
  u_long regvalue;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::cfg_set_option: method called for bit field " << key << " and value " << value);
  str_upper(upper);

  if(bar == 0)bf = regmap_bar0_bitfields;
  if(bar == 1)bf = regmap_bar1_bitfields;
  if(bar == 2)bf = regmap_bar2_bitfields;
  if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");

  for(; bf->name != NULL; bf++)
  {
    if(strcmp(upper, bf->name) == 0)
    {
      if(!(bf->flags & REGMAP_REG_WRITE))
      {
        DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_set_option: Bitfield " << key << " not writeable!");
        THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << " not writeable!")
      }
      u_long *v;
      if(bar==0)v = (u_long *)(m_Bar_0_Base + bf->address);
      if(bar==1)v = (u_long *)(m_Bar_1_Base + bf->address);
      if(bar==2)v = (u_long *)(m_Bar_2_Base + bf->address);
      if(bar>2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " outside range 0-2")

      regvalue = *v;
      regvalue &=~ bf->mask;
      regvalue |= (value << bf->shift) & bf->mask;

      *v = regvalue;
      free(upper);
      return;
    }
  }

  free(upper);
  DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::cfg_set_option: Bitfield " << key << " does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << " does not exist!")
}

    
/***************************************/
void WupperCard::irq_enable(u_int interrupt)
/***************************************/
{
  u_int i;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_enable: Method called for interrupt " << interrupt);
  if (interrupt == ALL_IRQS)
  {  
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_enable: Enabling all interrupts.");
    for(i = 0; i < NUM_INTERRUPTS; i++)
    {
      //Enable the interrupt by direct access to the register in the WUPPER card
      m_bar1->INT_TAB_ENABLE |= (1 << i);

      //...and tell the driver the interrupt is denabled
      int iores = ioctl(m_fd, UNMASK_IRQ, &i);
      if(iores < 0)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_enable: Error from ioctl(RESET_IRQ_COUNTERS).");
	THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)")
      } 
    }
  }
  else
  {
    //Enable the interrupt by direct access to the register in the WUPPER card
    m_bar1->INT_TAB_ENABLE |= (1 << interrupt);
    
    //...and tell the driver the interrupt is enabled
    int iores = ioctl(m_fd, UNMASK_IRQ, &interrupt);
    if(iores < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_enable: Error from ioctl(RESET_IRQ_COUNTERS).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)")
    } 
  }
}


/****************************************/
void WupperCard::irq_disable(u_int interrupt)
/****************************************/
{
  u_int i;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: Method called for interrupt " << interrupt);
  if (interrupt == ALL_IRQS)
  {  
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: Disabling all interrupts.");
    for(i = 0; i < NUM_INTERRUPTS; i++)
    {
      //Disable the interrupt by direct access to the register in the WUPPER card
      m_bar1->INT_TAB_ENABLE &= ~(1 << i);   
      
      //...and tell the driver the interrupt is disabled
      int iores = ioctl(m_fd, MASK_IRQ, &i);
      if(iores < 0)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_disable: Error from ioctl(RESET_IRQ_COUNTERS).");
	THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)")
      } 
    }
  }
  else
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: 111 ");
    //Disable the interrupt by direct access to the register in the WUPPER card
    m_bar1->INT_TAB_ENABLE &= ~(1 << interrupt);

    //...and tell the driver the interrupt is disabled
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: 222 ");
    
    int iores = ioctl(m_fd, MASK_IRQ, &interrupt);
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: 333 ");
    if(iores < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_disable: Error from ioctl(RESET_IRQ_COUNTERS).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)")
    } 
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: 444 ");
  }
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_disable: Method done for interrupt " << interrupt);
}


/*************************************/
void WupperCard::irq_wait(u_int interrupt)
/*************************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_wait: Method called for interrupt " << interrupt);

  int iores = ioctl(m_fd, WAIT_IRQ, &interrupt);
  if(iores < 0)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_wait: Error from ioctl(WAIT_IRQ).");
    THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(WAIT_IRQ)")
  }
}


/***********************************************/
void WupperCard::irq_reset_counters(u_int interrupt)
/***********************************************/
{
  u_int i;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_reset_counters: Method called for interrupt " << interrupt);

  if (interrupt == ALL_IRQS)
  {  
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_reset_counters: Clearing all interrupt counters.");
    for(i = 0; i < NUM_INTERRUPTS; i++)
    {
      int iores = ioctl(m_fd, RESET_IRQ_COUNTERS, &i);
      if(iores < 0)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_reset_counters: Error from ioctl(RESET_IRQ_COUNTERS).");
	THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)")
      }
    }
  }
  else
  {
    int iores = ioctl(m_fd, RESET_IRQ_COUNTERS, &interrupt);
    if(iores < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_reset_counters: Error from ioctl(RESET_IRQ_COUNTERS).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)")
    }
  }
}


/***************************************/
void WupperCard::irq_cancel(u_int interrupt)
/***************************************/
{
  u_int i;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_cancel: Method called for interrupt " << interrupt);

  if (interrupt == ALL_IRQS)
  {  
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_cancel: Clearing all interrupt counters.");
    for(i = 0; i < NUM_INTERRUPTS; i++)
    {
      int iores = ioctl(m_fd, CANCEL_IRQ_WAIT, &i);
      if(iores < 0)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_cancel: Error from ioctl(CANCEL_IRQ_WAIT).");
	THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)")
      }
    }
  }
  else
  {
    int iores = ioctl(m_fd, CANCEL_IRQ_WAIT, &interrupt);
    if(iores < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_cancel: Error from ioctl(CANCEL_IRQ_WAIT).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)")
    }
  }
}


/**************************************/
void WupperCard::irq_clear(u_int interrupt)
/**************************************/
{
  u_int i;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_clear: Method called for interrupt " << interrupt);

  if (interrupt == ALL_IRQS)
  {  
    DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::irq_clear: Clearing all interrupt counters.");
    for(i = 0; i < NUM_INTERRUPTS; i++)
    {
      int iores = ioctl(m_fd, CLEAR_IRQ, &i);
      if(iores < 0)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_clear: Error from ioctl(CANCEL_IRQ_WAIT).");
	THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)")
      }
    }
  }
  else
  {
    int iores = ioctl(m_fd, CLEAR_IRQ, &interrupt);
    if(iores < 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::irq_clear: Error from ioctl(CANCEL_IRQ_WAIT).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)")
    }
  }
}

/***************************/
int WupperCard::card_model(void)
/***************************/
{
  u_long card_id = 0;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::card_model: Method called.");

  card_id = cfg_get_option(BF_CARD_TYPE);

  if(card_id != WUPPER_709 && card_id != WUPPER_710 && card_id != WUPPER_711 && card_id != WUPPER_712 && card_id != WUPPER_128)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::card_model: Cannot identify card. Card ID " << card_id << " is unknown");
    THROW_WUPPER_EXCEPTION(HW, "Cannot identify card")
  }

  return (int)card_id;
}



/***********************************/
u_long WupperCard::openBackDoor(int bar)
/***********************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::openBackDoor: Method called.");

  if(bar == 0)
    return m_Bar_0_Base;
  else if(bar == 1)
    return m_Bar_1_Base;
  else if(bar == 2)
    return m_Bar_2_Base;
  else
    THROW_WUPPER_EXCEPTION(PARAM, "Parameter bar is out of range")
}


//Method coded by Anna Stollenwerk (and improved by M. Joos)
/***************************************************************/
monitoring_data_t WupperCard::get_monitoring_data(u_int device_mask)
/***************************************************************/
{  
  u_char lsb, msb;
  u_long lvalue;
  float fvalue;
  monitoring_data_t moda;
  
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::get_monitoring_data: method called.");
  
  if(m_card_model != WUPPER_711 && m_card_model != WUPPER_712)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::get_monitoring_data: This method only supports the WUPPER-711 and WUPPER-712.");
    THROW_WUPPER_EXCEPTION(HW, "This method only supports the WUPPER-711 and WUPPER-712")
  }

  //Read the monitoring data of the FPGA
  if(device_mask & FPGA_MONITORING)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: Reading FPGA data");
    lvalue = cfg_get_option(BF_FPGA_CORE_TEMP);
    fvalue = (((float)lvalue * 503.975)/4096.0 - 273.15);
    moda.fpga.temperature = fvalue;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: fvalue (1) = " << fvalue);

    lvalue = cfg_get_option(BF_FPGA_CORE_VCCINT);
    fvalue = lvalue * 3.0 / 4096.0;
    moda.fpga.vccint = fvalue;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: fvalue (2) = " << fvalue);
    lvalue = cfg_get_option(BF_FPGA_CORE_VCCAUX);
    fvalue = lvalue * 3.0 / 4096.0;
    moda.fpga.vccaux = fvalue;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: fvalue (3) = " << fvalue);

    lvalue = cfg_get_option(BF_FPGA_CORE_VCCBRAM);
    fvalue = lvalue * 3.0 / 4096.0;
    moda.fpga.vccbram = fvalue;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: fvalue (4) = " << fvalue);

    lvalue = cfg_get_option(BF_FPGA_DNA);
    moda.fpga.dna = lvalue;
  }
  
 
  //Read the monitoring data of the LTCs
  if(device_mask & LTC_MONITORING)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: Reading LTC data");
    //Read the monitoring data of the LTC1
    i2c_devices_write(ltc_devices[0].name, 0x06, 0x00);
    i2c_devices_write(ltc_devices[0].name, 0x07, 0x03);
    i2c_devices_write(ltc_devices[0].name, 0x08, 0x10);
    i2c_devices_write(ltc_devices[0].name, 0x01, 0xf8);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: 1111");

    i2c_devices_read(ltc_devices[0].name, 0x0a, &msb);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::get_monitoring_data: 2222");
    i2c_devices_read(ltc_devices[0].name, 0x0b, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215; 
    moda.ltc1.VCCINT_current = fvalue;

    i2c_devices_read(ltc_devices[0].name, 0x0c, &msb);
    i2c_devices_read(ltc_devices[0].name, 0x0d, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;      
    moda.ltc1.VCCINT_voltage = fvalue;

    i2c_devices_read(ltc_devices[0].name, 0x0e, &msb);
    i2c_devices_read(ltc_devices[0].name, 0x0f, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
    moda.ltc1.MGTAVCC_current = fvalue;

    i2c_devices_read(ltc_devices[0].name, 0x10, &msb);
    i2c_devices_read(ltc_devices[0].name, 0x11, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518; 
    moda.ltc1.MGTAVCC_voltage = fvalue; 

    i2c_devices_read(ltc_devices[0].name, 0x12, &msb);
    i2c_devices_read(ltc_devices[0].name, 0x13, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.0625; 
    moda.ltc1.FPGA_internal_diode_temperature = fvalue;    
    
    if (m_card_model == WUPPER_712)
    {
      i2c_devices_read(ltc_devices[0].name, 0x16, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x17, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
      moda.ltc1.MGTAVTT_current = fvalue;
    }
    else
    {
      i2c_devices_read(ltc_devices[0].name, 0x16, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x17, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518; 
      moda.ltc1.MGTAVTTC_voltage = fvalue;
    }

    if (m_card_model == WUPPER_712)
    {
      i2c_devices_read(ltc_devices[0].name, 0x18, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x19, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      moda.ltc1.MGTAVTT_voltage = fvalue;             
    }
    else
    {
      i2c_devices_read(ltc_devices[0].name, 0x18, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x19, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      moda.ltc1.MGTVCCAUX_voltage = fvalue;       
    }

    i2c_devices_read(ltc_devices[0].name, 0x1a, &msb);
    i2c_devices_read(ltc_devices[0].name, 0x1b, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.0625;   
    moda.ltc1.LTC2991_1_internal_temperature = fvalue;  

    i2c_devices_read(ltc_devices[0].name, 0x1c, &msb);
    i2c_devices_read(ltc_devices[0].name, 0x1d, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 + 2.5; 
    moda.ltc1.vcc = fvalue;
    
    //Read the monitoring data of the LTC2
    i2c_devices_write(ltc_devices[1].name, 0x06, 0x00);
    i2c_devices_write(ltc_devices[1].name, 0x07, 0x30);
    i2c_devices_write(ltc_devices[1].name, 0x08, 0x10);
    i2c_devices_write(ltc_devices[1].name, 0x01, 0xf8);

    i2c_devices_read(ltc_devices[1].name, 0x0a, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x0b, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
    moda.ltc2.PEX0P9V_current = fvalue;

    i2c_devices_read(ltc_devices[1].name, 0x0c, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x0d, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
    moda.ltc2.PEX0P9V_voltage = fvalue;

    i2c_devices_read(ltc_devices[1].name, 0x0e, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x0f, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
    moda.ltc2.SYS18_current = fvalue;

    i2c_devices_read(ltc_devices[1].name, 0x10, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x11, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
    moda.ltc2.SYS18_voltage = fvalue;

    if (m_card_model == WUPPER_712)
    {
      i2c_devices_read(ltc_devices[1].name, 0x12, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x13, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;;
      moda.ltc2.SYS25_current = fvalue;      
    }
    else
    {
      i2c_devices_read(ltc_devices[1].name, 0x12, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x13, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      moda.ltc2.SYS12_voltage = fvalue;
    }
    
    i2c_devices_read(ltc_devices[1].name, 0x14, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x15, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
    moda.ltc2.SYS25_voltage = fvalue;

    i2c_devices_read(ltc_devices[1].name, 0x16, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x17, &lsb);
    fvalue = ((((msb & 0x3f) << 8) + lsb) * 0.0625) - 24.0;
    moda.ltc2.PEX8732_internal_diode_temperature = fvalue;

    i2c_devices_read(ltc_devices[1].name, 0x1a, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x1b, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.0625;
    moda.ltc2.LTC2991_2_internal_temperature = fvalue;      

    i2c_devices_read(ltc_devices[1].name, 0x1c, &msb);
    i2c_devices_read(ltc_devices[1].name, 0x1d, &lsb);
    fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 + 2.5;
    moda.ltc2.vcc = fvalue;
  }
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::get_monitoring_data: method done.");
  return(moda);
}

u_long WupperCard::get_rxusrclk_freq(u_int channel)
{
  cfg_set_option("RXUSRCLK_FREQ_CHANNEL", channel&0x3F);
  u_long valid, value;
  //Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec = 1;           // One second
  timer.it_value.tv_usec = 0;    
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 0;       // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
  
  do
  {
    valid = cfg_get_option("RXUSRCLK_FREQ_VALID");
    if (m_timeout)
    {
      THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout")
    }
  } while(valid==0);
  //Stop watchdog
  timer.it_value.tv_usec = 0;    // Stop timer
  timer.it_value.tv_sec = 0;     // Stop timer
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  value = cfg_get_option("RXUSRCLK_FREQ_VAL");
  return value;
}

/************************************************/
/* Service functions (not part of the user API) */
/************************************************/


/**********************************************************/
u_long WupperCard::map_memory_bar(u_long pci_addr, size_t size) 
/**********************************************************/
{
  void *vaddr;
  u_long offset;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::map_memory_bar: method called.");
  
  long pagesz = sysconf(_SC_PAGE_SIZE);  // Get system page size
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::map_memory_bar: pagesz = " << HEX(pagesz));

  if(pagesz == -1)                       // Sanity check
    pagesz = 0x10000;
  
  pagesz -= 1;                           // Turn value into its matching bitmask
  offset = pci_addr & pagesz;            // mmap requires pagesize alignment
  pci_addr &= (0xffffffffffffffffL & (~pagesz)); 
  
  vaddr = mmap(0, size, (PROT_READ|PROT_WRITE), MAP_SHARED, m_fd, pci_addr);
  if (vaddr == MAP_FAILED)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::map_memory_bar: Error from mmap for pci_addr = " << pci_addr << " and size = " << size);
    THROW_WUPPER_EXCEPTION(MAPERROR, "Error from mmap for pci_addr = " << pci_addr << " and size = " << size)
  }

  return (u_long)vaddr + offset;
}  
  

/*******************************************************/
void WupperCard::unmap_memory_bar(u_long vaddr, size_t size)
/*******************************************************/
{
  int ret;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::unmap_memory_bar: method called.");

  ret = munmap((void *)vaddr, size);
  if (ret)
  {
    DEBUG_TEXT(DFDB_VMERCC, 5, "unmap_memory_bar: Error from munmap, errno = 0x" << HEX(errno));
    THROW_WUPPER_EXCEPTION(MAPERROR, "Error from munmap, errno = 0x" << HEX(errno))
  }
}


/***********************************/
void WupperCard::i2c_wait_not_full(void)
/***********************************/
{
  u_long status;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_wait_not_full: method called.");

  //Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec = 1;           // One second
  timer.it_value.tv_usec = 0;    
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 0;       // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  status = cfg_get_reg(REG_I2C_WR);
  while (status & I2C_FULL_FLAG)
  {
    usleep(I2C_SLEEP);
    if (m_timeout)
    {
      THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout")
    }
    status = cfg_get_reg(REG_I2C_WR);
  }

  //Stop watchdog
  timer.it_value.tv_usec = 0;    // Stop timer
  timer.it_value.tv_sec = 0;     // Stop timer
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
}


/************************************/
void WupperCard::i2c_wait_not_empty(void)
/************************************/
{
  u_long status;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_wait_not_empty: method called.");

  //Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec = 1;           // One second
  timer.it_value.tv_usec = 0;
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 0;       // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  status = cfg_get_reg(REG_I2C_RD);
  while (status & I2C_EMPTY_FLAG)
  {
    usleep(I2C_SLEEP);
    if (m_timeout)
    {
      THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout")
    }
    status = cfg_get_reg(REG_I2C_RD);
  }

  //Stop watchdog
  timer.it_value.tv_usec = 0;    // Stop timer
  timer.it_value.tv_sec = 0;     // Stop timer
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
}


/********************************************************************************************/
int WupperCard::i2c_parse_address(const char *str, u_char *port1, u_char *port2, u_char *port3, u_char *address)
/********************************************************************************************/
{
  //This method understands three formats of device strings
  //Format 1 is a symbolic name such as "ADN2814". The names are defined in the arrays i2c_devices_WUPPER_7[09,10,11] in beginning of this file
  //Format 2 has the structure "P1:ADD" with P1 = Port number, ADDR = address of the i2c device
  //Format 3 has the structure "P1:P2:ADD" with P1 = First port number, P2 = Second port number, ADDR = address of the i2c device
  //
  //The port numbers have two formats too.
  //In a device string of format 2 or 3 the port is decimal (e.g. "4:0x70" refers to port 4 and address 0x70)
  //The port numbers provided by the i2c_devices_WUPPER_7.. structures are binary encoded. e.g. 0x8 for the 4th port
  //This function converts all port numbers to the binary format


  char *p_aux = NULL;
  char portstr[6];
  unsigned long int convres;
  i2c_device_t *devices;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_parse_address: method called with string = " << str);

  //Check if we have a device of Format 1
  char *upper = strdup(str);
  str_upper(upper);

  if(m_card_model == WUPPER_712)
    devices = i2c_devices_WUPPER_711;  //711 and 712 have he same I2C devices

  if(m_card_model == WUPPER_711)
    devices = i2c_devices_WUPPER_711;

  if(m_card_model == WUPPER_710)
    devices = i2c_devices_WUPPER_710;

  if(m_card_model == WUPPER_709)
    devices = i2c_devices_WUPPER_709;

  if(m_card_model == WUPPER_128)
    devices = i2c_devices_WUPPER_128;

  for(; devices->name != NULL; devices++)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: devices->name        = " << devices->name);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: devices->description = " << devices->description);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: devices->address     = " << (u_int)devices->address);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: devices->port        = " << devices->port);
    if(strcmp(upper, devices->name) == 0)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: Device found!");
      sscanf(devices->port, "%s", portstr);

      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: portstr = " << portstr);

      char *portpos = strchr(const_cast<char*>(portstr), ':');
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: portpos = " << *portpos);

      if(portpos == NULL)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Device " << *portpos << " does not exist (port string lacks : character).");
	THROW_WUPPER_EXCEPTION(I2C, "Device " << *portpos << " does not exist")
      }

      convres = 999;
      convres = strtoul(portstr, &p_aux, 0);

      if(convres == 999)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the first port number");
	return I2C_DEVICE_ERROR_INVALID_PORT;
      }

      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: convres = " << convres);
      *port1 = (u_char)convres;
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: *port1 = " << (u_int)*port1);
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: *p_aux = " << p_aux);

      convres = 999;
      convres = strtoul(p_aux + 1, &p_aux, 0);

      if(convres == 999)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the second port number");
	return I2C_DEVICE_ERROR_INVALID_PORT;
      }

      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: convres = " << convres);
      *port2 = (u_char)convres;
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: *port2 = " << (u_int)*port2);
      
      convres = 999;
      convres = strtoul(p_aux + 1, &p_aux, 0);

      if(convres == 999)
      {
	DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the third port number");
	return I2C_DEVICE_ERROR_INVALID_PORT;
      }

      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: convres = " << convres);
      *port3 = (u_char)convres;
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: *port3 = " << (u_int)*port3);
      

      *address = devices->address;
      DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: *address = " << (u_int)*address);

      free(upper);
      return(0);
    }
  }

  //Check if we have a device of Format 2 or 3
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: Check if we have a device of Format 2 or 3");
  char *pos = strchr(const_cast<char*>(str), ':');
  if(pos == NULL)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to find a : character.");
    return I2C_DEVICE_ERROR_NOT_EXIST;
  }

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: rest string = " << pos);

  char *pos2 = strchr((pos + 1), ':');

  if(pos2 == NULL)
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: Format 2 detected");
    convres = 999;
    convres = strtoul(str, &p_aux, 0);

    if(convres == 999)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the first port number");
      return I2C_DEVICE_ERROR_INVALID_PORT;
    }
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: convres = " << convres);
    *port1 = 1 << ((u_char)convres);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: binary port1 = " << (u_int)*port1);

    convres = 999;
    convres = strtoul(pos + 1, &p_aux, 0);
    if(convres == 999)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the address");
      return I2C_DEVICE_ERROR_INVALID_ADDRESS;
    }
    *address = (u_char)convres;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: address = " << (u_int)*address);
  }
  else
  {
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: Format 3 detected");
    convres = 999;
    convres = strtoul(str, &p_aux, 0);
    if(convres == 999)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the first port number (2)");
      return I2C_DEVICE_ERROR_INVALID_PORT;
    }
    *port1 = 1 << ((u_char)convres);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: binary port1 = " << (u_int)*port1);

    convres = 999;
    convres = strtoul(pos + 1, &p_aux, 0);
    if(convres == 999)
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the second port number");
      return I2C_DEVICE_ERROR_INVALID_PORT;
    }
    *port2 = 1 << ((u_char)convres);
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: binary port2 = " << (u_int)*port2);

    convres = 999;
    convres = strtoul(pos2 + 1, &p_aux, 0);
    if(convres == 999)
    if(*p_aux != '\0')
    {
      DEBUG_TEXT(DFDB_FELIXCARD, 5, "WupperCard::i2c_parse_address: Failed to decode the address");
      return I2C_DEVICE_ERROR_INVALID_ADDRESS;
    }
    *address = (u_char)convres;
    DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: address = " << (u_int)*address);
  }

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: binary *port1 = " << (u_int)*port1);
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: binary *port2 = " << (u_int)*port2);
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_parse_address: *address = " << (u_int)*address);

  return 0;
}


/********************************/
void WupperCard::str_upper(char *str)
/********************************/
{
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::str_upper: method called.");
  do
  {
    *str = toupper((u_char) *str);
  } while (*str++);
}


/*****************************************************************************************/
void WupperCard::i2c_write(u_char port1, u_char port2, u_char port3, u_char device, u_char reg, u_char data)
/*****************************************************************************************/
{
  int cont1 = 0, cont2 = 0;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_write: method called.");

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_write: Port 1 = " << port1);
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_write: Port 2 = " << port2);
  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_write: Port 3 = " << port3);

  if(m_card_model == WUPPER_712)
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_711, port1);    //Configure the switch. 711 and 712 are identical wrt I2C
  if(m_card_model == WUPPER_711)
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_711, port1);    //Configure the switch
  if(m_card_model == WUPPER_710)
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_710, port1);    //Configure the switch
  if(m_card_model == WUPPER_709)
  {
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_709, port1);    //Configure the switch
    i2c_write_byte(I2C_ADDR_SWITCH2_WUPPER_709, port2);    //configure switch2
  }
  if(m_card_model == WUPPER_128)
  {
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_128, port1);    //Configure switch1
    i2c_write_byte(I2C_ADDR_SWITCH2_WUPPER_128, port2);    //configure switch2
    i2c_write_byte(I2C_ADDR_SWITCH3_WUPPER_128, port3);    //configure switch3
  }

  i2c_write_byte_to_addr(device, reg, data);

  for(cont1 = 0; port1 > 1; cont1++)
    port1 = port1 / 2;
  for(cont2 = 0; port2 > 1; cont2++)
    port2 = port2 / 2;

  DEBUG_TEXT(DFDB_FELIXCARD, 20, "WupperCard::i2c_write: Set port1 " << cont1 << " and port2 " << cont2 << " on swith to device " << device << " and register " << reg << " with data " << data);
}


/*****************************************************************************/
u_char WupperCard::i2c_read(u_char port1, u_char port2, u_char port3, u_char device, u_char reg)
/*****************************************************************************/
{
  u_char value = 0;
  int cont1 = 0, cont2 = 0;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_read: method called with port1 = " << (u_int)port1 << ", port2 = " << (u_int)port2 << ", device = " << (u_int)device << " and reg = " << (u_int)reg);

  if(m_card_model == WUPPER_712)
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_711, port1);    //Configure the switch
  if(m_card_model == WUPPER_711)
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_711, port1);    //Configure the switch
  if(m_card_model == WUPPER_710)
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_710, port1);    //Configure the switch
  if(m_card_model == WUPPER_709)
  {
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_709, port1);    //Configure the switch
    i2c_write_byte(I2C_ADDR_SWITCH2_WUPPER_709, port2);    //configure switch2
  }
  if(m_card_model == WUPPER_128)
  {
    i2c_write_byte(I2C_ADDR_SWITCH1_WUPPER_128, port1);    //Configure switch1
    i2c_write_byte(I2C_ADDR_SWITCH2_WUPPER_128, port2);    //configure switch2
    i2c_write_byte(I2C_ADDR_SWITCH3_WUPPER_128, port3);    //configure switch3
  }

  value = i2c_read_byte(device, reg);

  for(cont1 = 0; port1 > 1; cont1++)
    port1 = port1 / 2;
  for(cont2 = 0; port2 > 1; cont2++)
    port2 = port2 / 2;

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_read: Set port1 " << cont1 << " and port2 " << cont2 << " on swith to device " << (u_int)device << " and register " << (u_int)reg);
  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::i2c_read: Value read = " << (u_int)value);
  return value;
}



/******************************************************************************/
int WupperCard::check_digic_value2(const char *str, u_long *version, u_long *delay)
/******************************************************************************/
{
  char *p_aux = NULL, *pos = strchr(const_cast<char*>(str), ':');

  DEBUG_TEXT(DFDB_FELIXCARD, 15, "WupperCard::check_digic_value2: method called.");

  if(pos == NULL)
    return -1;

  *pos = '\0';

  *version = strtoul(str, &p_aux, 0);
  if(*p_aux != '\0')
    return -2;

  *delay = strtoul(pos + 1, &p_aux, 0);
  if(*delay == 0)
    return -3;

  return 0;
}


