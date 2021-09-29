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

#define  LOG20(txt)  DEBUG_TEXT(DFDB_FELIXCARD,20,txt)
#define  LOG15(txt)  DEBUG_TEXT(DFDB_FELIXCARD,15,txt)
#define  LOG5(txt)   DEBUG_TEXT(DFDB_FELIXCARD,5,txt)

int WupperCard::m_cardsOpen = 0;
static int m_timeout     = 0;

static const int MINIPOD_CNT = 8;
minipod_device_t minipod_devices[] =
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

ltc_device_t ltc_devices[] =
  {
    {"LTC2991_1", "First LTC2991"},
    {"LTC2991_2", "Second LTC2991"},
    {NULL,         NULL}
  };

i2c_device_t i2c_devices_WUPPER_709[] =
  {
    {"USR_CLK",         "SI570",                    0x5d, {  1,0,0} },
    {"ADN2814",         "ADN2814",                  0x40, {  2,0,0} },
    {"SI5345",          "SI5345",                   0x68, {  2,0,0} },
    {"FMC_TEMP_SENSOR", "TC74 (on CRORC TEST FMC)", 0x4A, {  2,0,0} },
    {"ID_EEPROM",       "M24C08-WDW6TP",            0x54, {  8,0,0} },
    {"SFP1-1",          "AFBR-709SMZ (Conven Mem)", 0x50, { 16,1,0} },
    {"SFP1-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, { 16,1,0} },
    {"SFP2-1",          "AFBR-709SMZ (Conven Mem)", 0x50, { 16,2,0} },
    {"SFP2-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, { 16,2,0} },
    {"SFP3-1",          "AFBR-709SMZ (Conven Mem)", 0x50, { 16,4,0} },
    {"SFP3-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, { 16,4,0} },
    {"SFP4-1",          "AFBR-709SMZ (Conven Mem)", 0x50, { 16,8,0} },
    {"SFP4-2",          "AFBR-709SMZ (Enhan Mem)",  0x51, { 16,8,0} },
    {"DDR3-1",          "SRAM-MT8KTF51264HZ",       0x51, { 64,0,0} },
    {"DDR3-2",          "SRAM-MT8KTF51264HZ",       0x52, { 64,0,0} },
    {"REC_CLOCK",       "SI5324",                   0x68, {128,0,0} },
    {NULL,              NULL,                       0,    {  0,0,0} }
  };

i2c_device_t i2c_devices_WUPPER_710[] =
  {
    {"CLOCK_RAM",       "ICS8N4Q001L IDT",          0x6e, {  1,0,0} },
    {"CLOCK_SYS",       "ICS8N4Q001L IDT",          0x6e, {  2,0,0} },
    {"CLOCK_CXP1",      "IDT 8N3Q001",              0x6e, {  4,0,0} },
    {"CLOCK_CXP2",      "IDT 8N3Q001",              0x6e, {  8,0,0} },
    {"ADN2814",         "ADN2814 (on TTCfx FMC)",   0x40, { 16,0,0} },
    {"SI5345",          "SI5345",                   0x68, { 16,0,0} },
    {"FMC_TEMP_SENSOR", "TC74 (on CRORC TEST FMC)", 0x4A, { 16,0,0} },
    {"CXP1_TX",         "AFBR-83PDZ",               0x50, { 32,0,0} },
    {"CXP1_RX",         "AFBR-83PDZ",               0x54, { 32,0,0} },
    {"CXP2_TX",         "AFBR-83PDZ",               0x50, { 64,0,0} },
    {"CXP2_RX",         "AFBR-83PDZ",               0x54, { 64,0,0} },
    {"DDR3-1",          "SRAM-MT16JTF25664HZ",      0x50, {128,0,0} },
    {"DDR3-2",          "SRAM-MT16JTF25664HZ",      0x51, {128,0,0} },
    {NULL,              NULL,                       0,    {  0,0,0} }
  };

i2c_device_t i2c_devices_WUPPER_711[] =
  {
    {"ADN2814",         "ADN2814",                  0x40, {2,0,0} },
    {"SIS53154",        "SI53154",                  0x6b, {2,0,0} },
    {"LTC2991_1",       "LTC2991",                  0x48, {2,0,0} },
    {"LTC2991_2",       "LTC2991",                  0x49, {2,0,0} },
    {"SI5345",          "SI5345",                   0x68, {4,0,0} },
    {"TCA6408A",        "TCA6408A",                 0x20, {4,0,0} },
    {"MINIPOD-TX1",     "AFBR-814PxyZ",             0x2c, {8,0,0} },
    {"MINIPOD-TX2",     "AFBR-814PxyZ",             0x2d, {8,0,0} },
    {"MINIPOD-TX3",     "AFBR-814PxyZ",             0x2e, {8,0,0} },
    {"MINIPOD-TX4",     "AFBR-814PxyZ",             0x2f, {8,0,0} },
    {"MINIPOD-RX1",     "AFBR-824PxyZ",             0x30, {8,0,0} },
    {"MINIPOD-RX2",     "AFBR-824PxyZ",             0x31, {8,0,0} },
    {"MINIPOD-RX3",     "AFBR-824PxyZ",             0x32, {8,0,0} },
    {"MINIPOD-RX4",     "AFBR-824PxyZ",             0x33, {8,0,0} },
    {NULL,              NULL,                       0,    {0,0,0} }
  };

i2c_device_t i2c_devices_WUPPER_128[] =
  {
    {"IO_EXTENDER",         "TCA6416A",             0x20, { 0,0,0} },
    {"PMBUS_VCCINT",        "INA226",               0x40, { 0,1,0} },
    {"PMBUS_VCCBRAM",       "INA226",               0x41, { 0,1,0} },
    {"PMBUS_VCCVCC1V8",     "INA226",               0x42, { 0,1,0} },
    {"PMBUS_MGTAVCC",       "INA226",               0x46, { 0,1,0} },
    {"PMBUS_MGTAVTT",       "INA226",               0x47, { 0,1,0} },
    {"PMBUS_MGTAVCC",       "INA226",               0x48, { 0,1,0} },
    {"PMBUS_VCCHBM",        "INA226",               0x4C, { 0,1,0} },
    {"PMBUS_VCCAUX_HBM",    "INA226",               0x4D, { 0,1,0} },
    {"MAIN_PMBUS_SYS1V8",   "ISL91211",             0x60, { 0,4,0} },
    {"MAIN_PMBUS_UTIL_1V35","ISL91302",             0x61, { 0,4,0} },
    {"MAIN_PMBUS_QDR_1V3",  "ISL91302",             0x62, { 0,4,0} },
    {"MAIN_PMBUS_VCC_VADJ", "ISL91302",             0x63, { 0,4,0} },
    {"MAIN_PMBUS_VDDQ",     "ISL91302",             0x64, { 0,4,0} },
    {"MAIN_PMBUS_VCCINT",   "ISL68127",             0x65, { 0,4,0} },
    {"MAIN_PMBUS_VCCHBM",   "ISL68301",             0x68, { 0,4,0} },
    {"MAIN_PMBUS_MGTAVTT",  "ISL68301",             0x69, { 0,4,0} },
    {"MAIN_PMBUS_UTIL_3V3", "ISL68301",             0x6A, { 0,4,0} },
    {"MAIN_PMBUS_UTIL_5V0", "ISL68301",             0x6B, { 0,4,0} },
    {"IIC_EEPROM",          "M24C08",               0x54, { 1,0,0} },
    {"SI5328",              "SI5328",               0x68, { 2,0,0} },
    {"QSFP1_SI570",         "SI570",                0x5D, { 8,0,0} },
    {"QSFP2_SI570",         "SI570",                0x5D, {16,0,0} },
    {"QSFP3_SI570",         "SI570",                0x5D, {32,0,0} },
    {"QSFP4_SI570",         "SI570",                0x5D, {64,0,0} },
    {"QSFP1_I2C",           "QSFP",                 0x50, { 0,0,16} },
    {"QSFP2_I2C",           "QSFP",                 0x50, { 0,0,32} },
    {"QSFP3_I2C",           "QSFP",                 0x50, { 0,0,64} },
    {"QSFP4_I2C",           "QSFP",                 0x50, { 0,0,128} },
    {NULL,                  NULL,                   0,    { 0,0,0} }
  };

// ----------------------------------------------------------------------------

void watchdogtimer_handler( int /*signum*/ )
{
  m_timeout = 1;
  LOG5( "WupperCard::watchdogtimer_handler: Timer expired. m_timeout = " << m_timeout);
}

// ----------------------------------------------------------------------------

WupperCard::WupperCard()
  : m_fd( -1 ),
    m_deviceNumber( -1 ),
    m_maxTlpBytes( 256 ),
    m_cardModel( 0 ),
    m_physStartAddressCmemBuf( 0 ),
    m_virtStartAddressCmemBuf( 0 ),
    m_myLocks( 0 ),
    m_myLockTag( 0 ),
    m_bar0Base( 0 ),
    m_bar1Base( 0 ),
    m_bar2Base( 0 ),
    m_bar0( 0 ),
    m_bar1( 0 )
{
}

// ----------------------------------------------------------------------------

void WupperCard::card_open( int device_nr, u_int lock_mask, bool ignore_version )
{
  LOG15( "WupperCard::card_open() called for device " << device_nr << " with lock_mask " << HEX(lock_mask));

  // Install a signal handler for the implementation of watchdog timers
  // Note: The signal handler should be installed only once
  if( m_cardsOpen == 0 )
    {
      LOG20( "WupperCard::card_open: Installing signal handler");
      struct sigaction sa;

      // Install timer_handler as the signal handler for SIGVTALRM
      memset( &sa, 0, sizeof(sa) );
      sa.sa_handler = watchdogtimer_handler;
      // MJ: According to http://www.gnu.org/software/libc/manual/html_node/Setting-an-Alarm.html
      //     SIGALRM may be better
      sigaction( SIGVTALRM, &sa, NULL );
    }
  else
    {
      LOG20( "WupperCard::card_open: Signal handler already installed");
    }
  ++m_cardsOpen;

  char nodename[30];
  sprintf( &nodename[0], "/dev/wupper%d", device_nr );
  LOG15( "WupperCard::card_open: nodename = " << nodename );

  m_fd = open( nodename, O_RDWR );

  if( m_fd < 0 )
    {
      if( m_cardsOpen == 1 )
        sigaction(SIGVTALRM, NULL, NULL); // Uninstall signal handler
      --m_cardsOpen;

      LOG5( "WupperCard::card_open: Failed to open " << nodename);
      THROW_WUPPER_EXCEPTION(NOTOPENED, "Failed to open " << nodename);
    }

  card_params_t card_data;
  card_data.slot      = device_nr;
  card_data.lock_mask = lock_mask;

  int iores = ioctl(m_fd, SETCARD, &card_data);
  LOG20( "WupperCard::card_open: card_data.lock_error  = " << card_data.lock_error);
  LOG20( "WupperCard::card_open: sizeof(card_params_t) = " << sizeof(card_params_t));

  if( iores < 0 )
    {
      // Clean up...
      close( m_fd );
      m_fd = -1;
      if( m_cardsOpen == 1 )
        sigaction(SIGVTALRM, NULL, NULL); // Uninstall signal handler
      --m_cardsOpen;
      // ...and exit
      LOG5( "WupperCard::card_open: Error from ioctl(SETCARD).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(SETCARD)");
    }
  if( card_data.lock_error )
    {
      // Clean up...
      close( m_fd );
      m_fd = -1;
      if( m_cardsOpen == 1 )
        sigaction(SIGVTALRM, NULL, NULL); // Uninstall signal handler
      --m_cardsOpen;
      // ...and exit
      LOG5( "WupperCard::card_open: Error from ioctl(SETCARD). "
            "Some resources already locked. card_data.lock_error = "
            << HEX(card_data.lock_error));
      THROW_WUPPER_EXCEPTION(LOCK_VIOLATION, "Error: Some resources already locked by other processes. "
                          "Locked resources: " << HEX(card_data.lock_error));
    }

  m_myLockTag = card_data.lock_tag;
  LOG20( "WupperCard::card_open: m_myLockTag is " << m_myLockTag);

  m_myLocks = lock_mask;
  m_deviceNumber = device_nr;

  m_bar0Base = map_memory_bar( card_data.baseAddressBAR0, 4096 );
  m_bar1Base = map_memory_bar( card_data.baseAddressBAR1, 4096 );
  m_bar2Base = map_memory_bar( card_data.baseAddressBAR2, 65536 );

  m_bar0 = (wuppercard_bar0_regs_t *) m_bar0Base;
  m_bar1 = (wuppercard_bar1_regs_t *) m_bar1Base;

  LOG15( "WupperCard::card_open: Obtaining max. TLP size from driver.");
  int tlp_bits;
  iores = ioctl( m_fd, GET_TLP, &tlp_bits );
  if( iores < 0 )
    {
      // Clean up...
      unmap_memory_bar( m_bar0Base, 4096 );
      unmap_memory_bar( m_bar1Base, 4096 );
      unmap_memory_bar( m_bar2Base, 65536 );
      close( m_fd );
      m_fd = -1;
      if( m_cardsOpen == 1 )
        sigaction(SIGVTALRM, NULL, NULL); // Uninstall signal handler
      --m_cardsOpen;
      // ...and exit
      LOG5( "WupperCard::card_open: Error from ioctl(GET_TLP).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(GET_TLP)");
    }

  m_maxTlpBytes = 128 << tlp_bits; // MJ: replace 128 by a constant?

  // Does the RM (register model) of the firmware match the RM of the software?
  u_long regmap_version_fw_major = cfg_get_reg(REG_REG_MAP_VERSION) >> 8 & 0xff;
  u_long regmap_version_sw_major = REGMAP_VERSION >> 8 & 0xff;
  if( regmap_version_sw_major != regmap_version_fw_major )
    {
      if( !ignore_version )
        {
          // Clean up...
          unmap_memory_bar( m_bar0Base, 4096 );
          unmap_memory_bar( m_bar1Base, 4096 );
          unmap_memory_bar( m_bar2Base, 65536 );
          close( m_fd );
          m_fd = -1;
          if( m_cardsOpen == 1 )
            sigaction(SIGVTALRM, NULL, NULL); // Uninstall signal handler
          --m_cardsOpen;
          // ...and exit
          LOG5( "WupperCard::card_open: FW Regmap = " << regmap_version_fw_major
                << " but SW Regmap = " << regmap_version_sw_major);
          //THROW_WUPPER_EXCEPTION(HW, "Regmap versions of HW (" << regmap_version_fw_major
          //                    << ") and SW (" << regmap_version_sw_major << ") do not match");
        }
      else
        {
          fprintf( stderr, "###WARNING: Regmap versions of HW (%lu) and SW (%lu) do not match\n",
                   regmap_version_fw_major, regmap_version_sw_major );
          // Continuing anyway, at your own risk...
        }
    }

  m_cardModel = card_model();

  LOG20( "WupperCard::card_open: done with m_cardsOpen = " << m_cardsOpen);
}

// ----------------------------------------------------------------------------

void WupperCard::card_close()
{
  LOG15( "WupperCard::card_close() called");

  if( m_fd < 0 )
    {
      LOG20( "WupperCard::card_close: not open" );
      //THROW_WUPPER_EXCEPTION(NOTOPENED, "The link to the driver is already closed "
      //                    "(or has never been opened)");
      return;
    }

  // Uninstall the signal handler when we close the last instance
  if( m_cardsOpen == 1 )
    {
      LOG20( "WupperCard::card_close: Uninstall signal handler");
      sigaction(SIGVTALRM, NULL, NULL); // Uninstall signal handler
    }
  --m_cardsOpen;
  LOG20( "WupperCard::card_close: m_cardsOpen = " << m_cardsOpen);

  LOG20( "WupperCard::card_close: returning locks for tag = "
         << m_myLockTag << ", device " << m_deviceNumber);

  lock_params_t lockparams;
  lockparams.lock_tag = m_myLockTag;
  lockparams.slot     = m_deviceNumber;
  int iores = ioctl(m_fd, RELEASELOCK, &lockparams);
  if( iores < 0 )
    {
      LOG5( "WupperCard::card_close: Error from ioctl(RELEASELOCK).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RELEASELOCK)");
    }

  unmap_memory_bar(m_bar0Base, 4096);
  unmap_memory_bar(m_bar1Base, 4096);
  unmap_memory_bar(m_bar2Base, 65536);

  close( m_fd );
  m_fd = -1;
}

// ----------------------------------------------------------------------------

u_int WupperCard::get_lock_mask( int device_nr )
{
  LOG15( "WupperCard::get_lock_mask() called" );

  bool close_it = false;
  if( m_fd < 0 )
    {
      LOG15( "WupperCard::get_lock_mask: We open the device file");

      char nodename[30];
      sprintf( &nodename[0], "/dev/wupper%d", device_nr );
      LOG15( "WupperCard::get_lock_mask: nodename = " << nodename );

      m_fd = open(nodename, O_RDWR);
      if( m_fd < 0 )
        {
          LOG5( "WupperCard::get_lock_mask: Failed to open " << nodename);
          THROW_WUPPER_EXCEPTION(NOTOPENED, "Failed to open " << nodename);
        }
      card_params_t card_data;
      card_data.slot      = device_nr;
      card_data.lock_mask = 0;

      int iores = ioctl(m_fd, SETCARD, &card_data);
      if( iores < 0 )
        {
          LOG5( "WupperCard::card_open: Error from ioctl(SETCARD).");
          THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(SETCARD)");
        }

      close_it = true;
    }

  // Usage of "val":
  // in call to the driver : device number
  // returned by the driver: resource lock bits of the device
  u_int val = device_nr;
  int iores = ioctl( m_fd, GETLOCK, &val );
  if( iores < 0 )
    {
      //LOG5( "WupperCard::get_lock_mask: Error from ioctl(GETLOCK)." );
      printf( "WupperCard::get_lock_mask: Error from ioctl(GETLOCK).\n" );
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(GETLOCK)");
    }

  LOG20( "WupperCard::get_lock_mask: Global locks for device " << device_nr << " = " << HEX(val));
  LOG20( "WupperCard::get_lock_mask:  Local locks for device " << m_deviceNumber << " = " << HEX(m_myLocks));

  // If applicable, remove any *locally assigned* lock bits
  u_int locks = val;
  if( device_nr == m_deviceNumber )
    locks = val ^ m_myLocks;

  LOG20( "WupperCard::get_lock_mask:  Locks for device " << device_nr << " = " << HEX(locks));

  if( close_it )
    {
      LOG15( "WupperCard::get_lock_mask: We close the device file again");
      close( m_fd );
      m_fd = -1;
    }

  return locks;
}

// ----------------------------------------------------------------------------

u_int WupperCard::number_of_cards()
{
  std::cout << "The method WupperCard::number_of_cards() is deprecated. "
            << "Please use WupperCard::number_of_devices() instead" << std::endl;
  return number_of_devices();
}

// ----------------------------------------------------------------------------

u_int WupperCard::number_of_devices()
{
  LOG15( "WupperCard::number_of_devices() called" );

  // Note: we always open /dev/wupper0 (and not one of /dev/wupper[n])
  //       because we want to get information for all cards / devices
  int fd = open( "/dev/wupper0", O_RDWR );
  if( fd < 0 )
    {
      LOG5( "WupperCard::number_of_devices: Failed to open /dev/wupper0");
      return 0;
    }

  u_int cdmap[MAXCARDS][2];
  int iores = ioctl(fd, GETCARDS, &cdmap);
  if( iores < 0 )
    {
      LOG5( "WupperCard::number_of_devices: Error from ioctl(GETCARDS).");
      close(fd);
      return 0;
    }

  int deviceCount = 0;
  u_int index;
  for( index=0; index<MAXCARDS; ++index )
    {
      if( cdmap[index][0] != 0 )
        {
          LOG5( "WupperCard::number_of_devices: cdmap[" << index << "] = "
                << HEX(cdmap[index][0]) << "," << cdmap[index][1]);
          ++deviceCount;
        }
    }

  close(fd);

  return deviceCount;
}

// ----------------------------------------------------------------------------

device_list_t WupperCard::device_list()
{
  LOG15( "WupperCard::device_list() called" );

  // Note: we always open /dev/wupper0 (and not one of /dev/wupper[n])
  //       because we want to get information for all cards / devices
  int fd = open( "/dev/wupper0", O_RDWR );
  if( fd < 0 )
    {
      LOG5( "WupperCard::device_list: Failed to open /dev/wupper0" );
      THROW_WUPPER_EXCEPTION(NOTOPENED, "Failed to open /dev/wupper0" );
    }

  u_int cdmap[MAXCARDS][2];
  int iores = ioctl( fd, GETCARDS, &cdmap );
  if( iores < 0 )
    {
      LOG5( "WupperCard::device_list: Error from ioctl(GETCARDS)." );
      close(fd);
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(GETCARDS)" );
    }

  device_list_t devlist;
  int deviceCount = 0;
  u_int index;
  for( index=0; index<MAXCARDS; ++index )
    {
      devlist.cdmap[index][0] = cdmap[index][0];
      devlist.cdmap[index][1] = cdmap[index][1];
      if( cdmap[index][0] != 0 )
        {
          ++deviceCount;
          LOG5( "WupperCard::device_list: cdmap[" << index << "] = "
                << HEX(cdmap[index][0]) << "," << cdmap[index][1] );
        }
    }
  devlist.n_devices = deviceCount;

  close( fd );

  return devlist;
}

// ----------------------------------------------------------------------------

int WupperCard::card_to_device_number( int card_number )
{
  // Maps a FELIX card number to a FELIX device number taking into account
  // that a WUPPER-712 consists of 2 devices and a 709 of 1 device
  // (this information is returned in the 'device list');
  // the card number maps to the first device of a dual-device card;
  // returns -1 if the card number is out-of-range or invalid
  int device_number = -1;
  if( card_number > 0 )
    {
      device_list_t devlist = WupperCard::device_list();
      int devicezero_cnt = 0;
      for( u_int index=0; index<devlist.n_devices; ++index )
        {
          if( devlist.cdmap[index][1] == 0 )
            {
              if( devicezero_cnt == card_number )
                {
                  // Found the first device (0) of the requested card number
                  device_number = index;
                  break;
                }
              ++devicezero_cnt;
            }
        }
    }
  else if( card_number == 0 )
    {
      device_number = 0;
    }
  return device_number;
}


// ----------------------------------------------------------------------------

int WupperCard::dma_max_tlp_bytes()
{
  LOG15( "WupperCard::dma_max_tlp_bytes() called" );
  return m_maxTlpBytes;
}

// ----------------------------------------------------------------------------

void WupperCard::dma_stop( u_int dma_id )
{
  LOG15( "WupperCard::dma_stop() called" );
  m_bar0->DMA_DESC_ENABLE &= ~(1 << dma_id);
}

// ----------------------------------------------------------------------------

void WupperCard::dma_to_host( u_int dma_id, u_long dst, size_t size, u_int flags )
{
  LOG15( "WupperCard::dma_to_host() called with dma_id = " << dma_id
         << ", dst = 0x" << HEX(dst) << ", size = " << size << ", flags = " << flags);
  dma_stop(dma_id);

  if( dst == 0 || size == 0 )
    {
      LOG5( "WupperCard::dma_to_host: dst or size is zero.");
      THROW_WUPPER_EXCEPTION(PARAM, "dst or size is zero");
    }

  if( (size % m_maxTlpBytes) != 0 )
    {
      LOG5( "WupperCard::dma_to_host: size is not a multiple of tlp.");
      THROW_WUPPER_EXCEPTION(PARAM, "size is not a multiple of tlp");
    }

  volatile dma_descriptor_t *pdma = &m_bar0->DMA_DESC[dma_id];
  pdma->start_address = dst;
  pdma->end_address   = dst + size;
  pdma->tlp           = m_maxTlpBytes / 4;
  LOG20( "WupperCard::dma_to_host: m_bar0->DMA_DESC[" << dma_id << "].tlp = " << m_maxTlpBytes / 4);
  pdma->read          = 0;
  pdma->wrap_around   = (flags & WUPPER_DMA_WRAPAROUND) ? 1 : 0;
  pdma->read_ptr      = dst;

  if(m_bar0->DMA_DESC_STATUS[dma_id].even_addr_pc == m_bar0->DMA_DESC_STATUS[dma_id].even_addr_dma)
    {
      // Make 'even_addr_pc' unequal to 'even_addr_dma', or a (circular) DMA won't start!?
      --pdma->read_ptr;
      ++pdma->read_ptr;
    }

  m_bar0->DMA_DESC_ENABLE |= 1 << dma_id;
  LOG15( "WupperCard::dma_to_host: DMA started");
}

// ----------------------------------------------------------------------------

void WupperCard::dma_from_host( u_int dma_id, u_long src, size_t size, u_int flags )
{
  LOG15( "WupperCard::dma_from_host() called");
  dma_stop(dma_id);

  if( src == 0 || size == 0 )
    {
      LOG5( "WupperCard::dma_from_host: src or size is zero.");
      THROW_WUPPER_EXCEPTION(PARAM, "src or size is zero");
    }

  if( (size % 32) != 0 )
    {
      LOG5( "WupperCard::dma_from_host: size is not a multiple of 32 bytes.");
      THROW_WUPPER_EXCEPTION(PARAM, "size is not a multiple of 32 bytes");
    }

  
  u_int best_tlp = m_maxTlpBytes;
  LOG20( "WupperCard::dma_from_host: first best_tlp = " << best_tlp);
  while(size % best_tlp)
    {
      best_tlp = best_tlp >> 1;
      LOG20( "WupperCard::dma_from_host: new best_tlp = " << best_tlp);
    }
  LOG20( "WupperCard::dma_from_host: size " << size << " best_tlp = " << best_tlp);

  volatile dma_descriptor_t *pdma = &m_bar0->DMA_DESC[dma_id];
  // To make sure each GBT-SCA command (fits in 32 bytes) is sent without delay
  // must set TLP size to 32 bytes in case of circular DMA (WUPPER-896);
  // in case of single-shot DMA there is an issue starting a DMA whose start address is not
  // aligned to the TLP size and crosses a 4K memory address boundary (WUPPER-937)
  // so for the time being FromHost TLP is set to 32 bytes only (Henk B, 16 Apr 2019)
  // User provided FromHost TLP parameter? (overruling the default setting)
  if( flags & 0xFFFF0000 )
    {
      int tlp = (flags & 0xFFFF0000) >> 16;
      if( tlp > m_maxTlpBytes )
        tlp = m_maxTlpBytes;
      pdma->tlp = tlp/4;
    }
  else
    {
      pdma->tlp = best_tlp/4;
    }
  pdma->start_address = src;
  pdma->end_address   = src + size;
  pdma->read          = 1;
  pdma->wrap_around   = (flags & WUPPER_DMA_WRAPAROUND) ? 1 : 0;
  pdma->read_ptr      = src;

  m_bar0->DMA_DESC_ENABLE |= 1 << dma_id;
}

// ----------------------------------------------------------------------------

bool WupperCard::dma_enabled( u_int dma_id )
{
  return( (m_bar0->DMA_DESC_ENABLE & (1 << dma_id)) != 0 );
}

// ----------------------------------------------------------------------------

void WupperCard::dma_wait( u_int dma_id )
{
  // Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec     = 1; // One second
  timer.it_value.tv_usec    = 0;
  timer.it_interval.tv_sec  = 0;
  timer.it_interval.tv_usec = 0; // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  LOG15( "WupperCard::dma_wait() called for dma_id = " << dma_id);
  while(m_bar0->DMA_DESC_ENABLE & (1 << dma_id))
    {
      LOG20( "WupperCard::dma_wait: m_timeout = " << m_timeout
             << " m_bar0->DMA_DESC_ENABLE = " << m_bar0->DMA_DESC_ENABLE);

      if( m_timeout )
        {
          LOG5( "WupperCard::dma_wait: ERROR: Timeout");
          THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout");
        }
    }
  // Stop watchdog
  timer.it_value.tv_usec = 0;
  timer.it_value.tv_sec = 0;
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
  LOG15( "WupperCard::dma_wait: Done");
}

// ----------------------------------------------------------------------------

u_long WupperCard::dma_get_current_address( u_int dma_id )
{
  LOG15( "WupperCard::dma_get_current_address() called with dma_id = " << dma_id);
  return(m_bar0->DMA_DESC_STATUS[dma_id].current_address);
}

// ----------------------------------------------------------------------------

bool WupperCard::dma_cmp_even_bits( u_int dma_id )
{
  u_long *ulp, lvalue, offset;

  // NOTE: I am not using the wuppercard_bar0_regs_t structure
  //       because the EVEN_PC and EVEN_DMA bits must read with one PCI cycle.
  //       This may not be guaranteed by accessing the fields of the stucture.

  LOG15( "WupperCard::dma_cmp_even_bits() called with dma_id = " << dma_id);

  // Note: This trick is to get the offset of the first STATUS register;
  //       that way we are safe against changes in the register model
  offset = (u_long)&m_bar0->DMA_DESC_STATUS[0] - (u_long)&m_bar0->DMA_DESC[0];
  LOG15( "WupperCard::dma_cmp_even_bits: offset = 0x" << HEX(offset));
  ulp = (u_long *)(m_bar0Base + offset);
  // Note: ulp[0] = FW_POINTER of channel 0, ulp[1] = status bits of channel 0,
  //       ul[[2] = FW_POINTER of channel 1, etc
  lvalue = ulp[1 + (dma_id * 2)];

  LOG20( "WupperCard::dma_cmp_even_bits: lvalue = 0x" << HEX(lvalue));
  u_int b1 = (lvalue >> 1) & 0x1;
  u_int b2 = (lvalue >> 2) & 0x1;
  LOG20( "WupperCard::dma_cmp_even_bits: EVEN_PC = " << b2 << ", EVEN_DMA = " << b1);

  return( b1 == b2 );
}

// ----------------------------------------------------------------------------

void WupperCard::dma_advance_ptr( u_int dma_id, u_long dst, size_t size, size_t bytes )
{
  LOG15( "WupperCard::dma_advance_from_host_ptr() called");

  u_long tmp_read_ptr = m_bar0->DMA_DESC[dma_id].read_ptr;
  tmp_read_ptr += bytes;
  if( tmp_read_ptr >= dst + size )
    tmp_read_ptr -= size;

  m_bar0->DMA_DESC[dma_id].read_ptr = tmp_read_ptr;
}

// ----------------------------------------------------------------------------

void WupperCard::dma_set_ptr( u_int dma_id, u_long dst )
{
  LOG15( "WupperCard::dma_set_ptr() called");
  m_bar0->DMA_DESC[dma_id].read_ptr = dst;
}

// ----------------------------------------------------------------------------

u_long WupperCard::dma_get_read_ptr( u_int dma_id )
{
  LOG15( "WupperCard::dma_get_read_ptr() called");

  return(m_bar0->DMA_DESC[dma_id].read_ptr);
}

// ----------------------------------------------------------------------------
// MJ: The method below has been temporarily disabled on the request of Frans
// because the DMA_FIFO_FLUSH register is currently not implemented

//void WupperCard::dma_fifo_flush()
//{
//  LOG15( "WupperCard::dma_fifo_flush() called");
//  m_bar0->DMA_FIFO_FLUSH = 1;
//}

// ----------------------------------------------------------------------------

void WupperCard::dma_reset()
{
  LOG15( "WupperCard::dma_reset() called");
  m_bar0->DMA_RESET = 1;
}

// ----------------------------------------------------------------------------

void WupperCard::soft_reset()
{
  LOG15( "WupperCard::soft_reset() called");
  m_bar0->SOFT_RESET = 1;
}

// ----------------------------------------------------------------------------

void WupperCard::registers_reset()
{
  LOG15( "WupperCard::registers_reset() called");
  m_bar0->REGISTERS_RESET = 1;
}


// ----------------------------------------------------------------------------

void WupperCard::i2c_write_byte( u_char dev_addr, u_char byte )
{
  LOG15( "WupperCard::i2c_write_byte(u_char,u_char) called");

  i2c_wait_not_full();

  u_long value = 0;
  value |= ((u_long) dev_addr << 1);
  value |= ((u_long) byte << 8);
  cfg_set_reg( REG_I2C_WR, value );
  usleep( I2C_DELAY );
}

// ----------------------------------------------------------------------------

void WupperCard::i2c_write_byte( u_char dev_addr, u_char reg_addr, u_char byte )
{
  LOG15( "WupperCard::i2c_write_byte(u_char,u_char,u_char) called");

  i2c_wait_not_full();

  u_long value = 0;
  value |= ((u_long) dev_addr << 1);
  value |= ((u_long) reg_addr << 8);
  value |= ((u_long) byte << 16);
  value |= (1 << 24);
  cfg_set_reg( REG_I2C_WR, value );
  usleep( I2C_DELAY );
}

// ----------------------------------------------------------------------------

u_char WupperCard::i2c_read_byte( u_char dev_addr, u_char reg_addr )
{
  LOG15( "WupperCard::i2c_read_byte() called, dev_addr="
         << (u_int) dev_addr << " reg_addr=" << (u_int) reg_addr );

  i2c_wait_not_full();

  u_long value = 1;
  value |= ((u_long) dev_addr << 1);
  value |= ((u_long) reg_addr << 8);
  value |= (1 << 24);

  LOG20( "WupperCard::i2c_read_byte: value = 0x" << HEX(value));

  cfg_set_reg( REG_I2C_WR, value );
  usleep( I2C_DELAY );
  i2c_wait_not_empty();
  usleep( I2C_DELAY );
  cfg_set_reg( REG_I2C_RD, 1 );
  usleep( I2C_DELAY );
  u_long result = cfg_get_reg( REG_I2C_RD );

  LOG20( "WupperCard::i2c_read_byte: result = 0x" << HEX(result)
         << " (I2C_EMPTY_FLAG = 0x" << HEX(I2C_EMPTY_FLAG) << ")");

  if( result & I2C_EMPTY_FLAG )
    {
      return( result & 0xff );
    }
  else
    {
      LOG5( "WupperCard::i2c_read_byte: failed because I2C_EMPTY_FLAG was not set");
      THROW_WUPPER_EXCEPTION(I2C, "i2c_read_byte failed because I2C_EMPTY_FLAG was not set");
    }
  return 0;
}

// ----------------------------------------------------------------------------

void WupperCard::i2c_devices_write( const char *device_str, u_char reg_addr, u_char data )
{
  LOG15( "WupperCard::i2c_devices_write() called, device_str="
         << device_str << " reg_addr=" << (u_int) reg_addr );

  u_char switch1_val = 0, switch2_val = 0, switch3_val = 0, dev_addr = 0;
  int result = i2c_parse_address_string( device_str, &switch1_val, &switch2_val, &switch3_val, &dev_addr );
  if( result == 0 )
    {
      i2c_set_switches( switch1_val, switch2_val, switch3_val );

      // Write device register
      i2c_write_byte( dev_addr, reg_addr, data );

      LOG20("WupperCard::i2c_devices_write: "
            << "dev_addr=" << (u_int) dev_addr << " reg_addr=" << (u_int) reg_addr
            << " data="    << (u_int) data << " ("
            << " switch1=" << (u_int) switch1_val
            << " switch2=" << (u_int) switch2_val
            << " switch3=" << (u_int) switch3_val << ")");
    }
  else
    {
      if( result == I2C_DEVICE_ERROR_INVALID_PORT )
        {
          LOG5( "WupperCard::i2c_devices_write: Invalid I2C port");
          THROW_WUPPER_EXCEPTION(I2C, "Invalid I2C port");
        }
      if( result == I2C_DEVICE_ERROR_INVALID_ADDRESS )
        {
          LOG5( "WupperCard::i2c_devices_write: Invalid I2C address");
          THROW_WUPPER_EXCEPTION(I2C, "Invalid I2C address");
        }

      LOG5( "WupperCard::i2c_devices_write: I2C device \"" << device_str << "\" does not exist");
      THROW_WUPPER_EXCEPTION(I2C, "I2C device \"" << device_str << "\" does not exist");
    }
}

// ----------------------------------------------------------------------------

void WupperCard::i2c_devices_read( const char *device_str, u_char reg_addr, u_char *value )
{
  LOG15( "WupperCard::i2c_devices_read() called, device_str="
         << device_str << " reg_addr=" << (u_int) reg_addr );

  u_char switch1_val = 0, switch2_val = 0, switch3_val = 0, dev_addr = 0;
  int result = i2c_parse_address_string( device_str, &switch1_val, &switch2_val, &switch3_val, &dev_addr );
  if( result == 0 )
    {
      i2c_set_switches( switch1_val, switch2_val, switch3_val );

      // Read device register
      *value = i2c_read_byte( dev_addr, reg_addr );

      LOG20("WupperCard::i2c_devices_read: "
            << "dev_addr=" << (u_int) dev_addr << " reg_addr=" << (u_int) reg_addr
            << " value="   << (u_int) *value << " ("
            << " switch1=" << (u_int) switch1_val
            << " switch2=" << (u_int) switch2_val
            << " switch3=" << (u_int) switch3_val << ")");
    }
  else
    {
      if( result == I2C_DEVICE_ERROR_INVALID_PORT )
        {
          LOG5( "WupperCard::i2c_devices_read: Invalid I2C port");
          THROW_WUPPER_EXCEPTION(I2C, "Invalid I2C port");
        }
      if( result == I2C_DEVICE_ERROR_INVALID_ADDRESS )
        {
          LOG5( "WupperCard::i2c_devices_read: Invalid I2C address");
          THROW_WUPPER_EXCEPTION(I2C, "Invalid I2C address");
        }

      LOG5( "WupperCard::i2c_devices_read: I2C device \"" << device_str << "\" does not exist");
      THROW_WUPPER_EXCEPTION(I2C, "I2C device \"" << device_str << "\" does not exist");
    }
}

// ----------------------------------------------------------------------------

regmap_register_t *WupperCard::cfg_register( const char *name, int bar)
{
  // Find register with name <name> (case-insensitive, '_' may be '-'),
  // return pointer to the struct with info
  std::string namestr( name );
  for( size_t i=0; i<namestr.size(); ++i )
    {
      namestr[i] = toupper( namestr[i] );
      if( namestr[i] == '-' ) namestr[i] = '_';
    }

  regmap_register_t *reg;

  if(bar == 0)reg = regmap_bar0_registers;
  if(bar == 1)reg = regmap_bar1_registers;
  if(bar == 2)reg = regmap_bar2_registers;
  if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");
  for( ; reg->name != NULL; ++reg )
    {
      if( strcmp(namestr.data(), reg->name) == 0 )
        return reg;
    }
  return NULL;
}

// ----------------------------------------------------------------------------

regmap_bitfield_t *WupperCard::cfg_bitfield( const char *name, int bar)
{
  // Find bitfield with name <name> (case-insensitive, '_' may be '-'),
  // return pointer to the struct with info
  std::string namestr( name );
  for( size_t i=0; i<namestr.size(); ++i )
    {
      namestr[i] = toupper( namestr[i] );
      if( namestr[i] == '-' ) namestr[i] = '_';
    }

  regmap_bitfield_t *bf;
  if(bar == 0)bf = regmap_bar0_bitfields;
  if(bar == 1)bf = regmap_bar1_bitfields;
  if(bar == 2)bf = regmap_bar2_bitfields;
  if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");
  for( ; bf->name != NULL; ++bf )
    {
      if( strcmp(namestr.data(), bf->name) == 0 )
        return bf;
    }
  return NULL;
}

// ----------------------------------------------------------------------------

std::string WupperCard::cfg_bitfield_options( const char *name,
                                           bool include_all_substr, int bar)
{
  // See if 'name' is a substring of one or more bitfields,
  // compile a list of bitfield name options and return it;
  // with 'include_all_substr' false, show only options that *start* with 'name'
  std::string namestr( name );
  for( size_t i=0; i<namestr.size(); ++i )
    {
      namestr[i] = toupper( namestr[i] );
      if( namestr[i] == '-' ) namestr[i] = '_';
    }

  size_t len = namestr.size();
  std::ostringstream oss;
  int cnt = 0;
  if( len >= 2 ) // Require at least 2 chars to compile an options list
    {
      // Check for bitfield names that match the substring from start of string
      regmap_bitfield_t *bf;
      if(bar == 0)bf = regmap_bar0_bitfields;
      if(bar == 1)bf = regmap_bar1_bitfields;
      if(bar == 2)bf = regmap_bar2_bitfields;
      if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");
      for( ; bf->name != NULL; ++bf )
        {
          if( strncmp(namestr.data(), bf->name, len) == 0 )
            {
              ++cnt;
              // Compiling a list of options
              oss << "  " << bf->name << std::endl;
            }
        }
      // Check if the substring is contained anywhere else within a bitfield
      // name, avoiding duplicates (condition: pos != 0)
      if( include_all_substr )
        {
          if(bar == 0)bf = regmap_bar0_bitfields;
          if(bar == 1)bf = regmap_bar1_bitfields;
          if(bar == 2)bf = regmap_bar2_bitfields;
          if(bar > 2)THROW_WUPPER_EXCEPTION(REG_ACCESS, "BAR " << bar << " not in range 0..2");
          for( ; bf->name != NULL; ++bf )
            {
              std::string n = std::string( bf->name );
              size_t pos = n.find( namestr );
              if( pos != std::string::npos && pos != 0 )
                {
                  ++cnt;
                  // Compiling a list of options
                  oss << "  " << bf->name << std::endl;
                }
            }
        }
    }
  if( cnt >= 1 )
    {
      // Found one or more options: return the compiled list
      return oss.str();
    }
  return std::string();
}

// ----------------------------------------------------------------------------

u_long WupperCard::cfg_get_reg( const char *key, int bar)
{
  LOG15( "WupperCard::cfg_get_reg(): register = " << key);

  regmap_register_t *reg = cfg_register( key , bar);
  if( reg )
    {
      if( !(reg->flags & REGMAP_REG_READ) )
        {
          LOG5( "WupperCard::cfg_get_reg: Register " << key << " not readable!");
          LOG5( "WupperCard::cfg_get_reg: reg->flags   = 0x" << HEX(reg->flags));
          LOG5( "WupperCard::cfg_get_reg: reg->address = 0x" << HEX(reg->address));
          LOG5( "WupperCard::cfg_get_reg: reg->name    = " << reg->name);
          LOG5( "WupperCard::cfg_get_reg: REGMAP_REG_READ = 0x" << HEX(REGMAP_REG_READ));
          THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register not readable!");
        }
      u_long *v = (u_long *)(m_bar2Base + reg->address);
      return(*v);
    }

  LOG5( "WupperCard::cfg_get_reg: Register \"" << key << "\" does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register \"" << key << "\" does not exist!");
}

// ----------------------------------------------------------------------------

u_long WupperCard::cfg_get_option( const char *key, bool show_options, int bar)
{
  LOG15( "WupperCard::cfg_get_option(): key = " << key);

  regmap_bitfield_t *bf = cfg_bitfield( key , bar);
  if( bf )
    {
      LOG20( "WupperCard::cfg_get_option: bitfield found");
      if( !(bf->flags & REGMAP_REG_READ) )
        {
          LOG5( "WupperCard::cfg_get_option: Bitfield " << key << " not readable!");
          THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << " not readable!");
        }

      LOG20( "WupperCard::cfg_get_option: m_bar2Base = 0x" << HEX(m_bar2Base));
      LOG20( "WupperCard::cfg_get_option: bf->address  = 0x" << HEX(bf->address));

      u_long *v = (u_long *)(m_bar2Base + bf->address);
      u_long regvalue = *v;
      LOG20( "WupperCard::cfg_get_option: regvalue(1)  = 0x" << HEX(regvalue));
      regvalue = (regvalue & bf->mask) >> bf->shift;
      LOG20( "WupperCard::cfg_get_option: bf->shift    = 0x" << HEX(bf->shift));
      LOG20( "WupperCard::cfg_get_option: bf->mask     = 0x" << HEX(bf->mask));
      LOG20( "WupperCard::cfg_get_option: regvalue(2)  = 0x" << HEX(regvalue));
      LOG15( "WupperCard::cfg_get_option: end of method");
      return regvalue;
    }

  if( show_options )
    {
      printf( "### Field name \"%s\" not found", key );
      std::string str = cfg_bitfield_options( key );
      if( !str.empty() )
        printf( ", suggestions are:\n%s", str.c_str() );
      else
        printf( "\n" );
    }

  LOG5( "WupperCard::cfg_get_option: Bitfield \"" << key << "\" does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield \"" << key << "\" does not exist!");
}

// ----------------------------------------------------------------------------

void WupperCard::cfg_set_reg( const char *key, u_long value , int bar)
{
  LOG15( "WupperCard::cfg_set_reg(): register = " << key << ", value = " << value);

  regmap_register_t *reg = cfg_register( key , bar);
  if( reg )
    {
      if( !(reg->flags & REGMAP_REG_WRITE) )
        {
          LOG5( "WupperCard::cfg_set_reg: Register \"" << key << "\" not writeable!");
          THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register \"" << key << "\" not writeable!");
        }
      u_long *v = (u_long *)(m_bar2Base + reg->address);
      *v = value;
      return;
    }

  LOG5( "WupperCard::cfg_set_reg: Register \"" << key << "\" does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Register \"" << key << "\" does not exist!");
}

// ----------------------------------------------------------------------------

void WupperCard::cfg_set_option( const char *key, u_long value, bool show_options , int bar)
{
  LOG15("WupperCard::cfg_set_option(): key = " << key << ", value = " << value);

  regmap_bitfield_t *bf = cfg_bitfield( key , bar);
  if( bf )
    {
      if( !(bf->flags & REGMAP_REG_WRITE) )
        {
          LOG5( "WupperCard::cfg_set_option: Bitfield " << key << " not writeable!");
          THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << " not writeable!");
        }

      // Check if provided value is in range
      u_long max = bf->mask >> bf->shift;
      if( value > max )
        {
          LOG5( "Bitfield " << key << ": value " << value
                << " out-of-range [0..0x" << std::hex << max << "]" );
          THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield " << key << ": value " << value
                              << std::hex << " (0x" << value << ") out-of-range [0..0x"
                              << std::uppercase << max << "]" );
        }

      u_long *v = (u_long *)(m_bar2Base + bf->address);

      u_long regvalue = *v;
      regvalue &=~ bf->mask;
      regvalue |= (value << bf->shift) & bf->mask;

      *v = regvalue;
      return;
    }

  if( show_options )
    {
      printf( "### Field name \"%s\" not found", key );
      std::string str = cfg_bitfield_options( key );
      if( !str.empty() )
        printf( ", suggestions are:\n%s", str.c_str() );
      else
        printf( "\n" );
    }

  LOG5( "WupperCard::cfg_set_option: Bitfield \"" << key << "\" does not exist!");
  THROW_WUPPER_EXCEPTION(REG_ACCESS, "Bitfield \"" << key << "\" does not exist!");
}

// ----------------------------------------------------------------------------

void WupperCard::irq_enable( u_int interrupt )
{
  LOG15( "WupperCard::irq_enable() called for interrupt " << interrupt);

  if( interrupt == ALL_IRQS )
    {
      LOG15( "WupperCard::irq_enable: Enabling all interrupts.");
      u_int i;
      for( i = 0; i < NUM_INTERRUPTS; ++i )
        {
          // Enable the interrupt by direct access to the register in the WUPPER card
          m_bar1->INT_TAB_ENABLE |= (1 << i);

          // ...and tell the driver the interrupt is denabled
          int iores = ioctl(m_fd, UNMASK_IRQ, &i);
          if( iores < 0 )
            {
              LOG5( "WupperCard::irq_enable: Error from ioctl(RESET_IRQ_COUNTERS).");
              THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)");
            }
        }
    }
  else
    {
      // Enable the interrupt by direct access to the register in the WUPPER card
      m_bar1->INT_TAB_ENABLE |= (1 << interrupt);

      // ...and tell the driver the interrupt is enabled
      int iores = ioctl(m_fd, UNMASK_IRQ, &interrupt);
      if( iores < 0 )
        {
          LOG5( "WupperCard::irq_enable: Error from ioctl(RESET_IRQ_COUNTERS).");
          THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)");
        }
    }
}

// ----------------------------------------------------------------------------

void WupperCard::irq_disable( u_int interrupt )
{
  LOG15( "WupperCard::irq_disable() called for interrupt " << interrupt);

  if( interrupt == ALL_IRQS )
    {
      LOG15( "WupperCard::irq_disable: Disabling all interrupts.");
      u_int i;
      for( i = 0; i < NUM_INTERRUPTS; ++i )
        {
          // Disable the interrupt by direct access to the register in the WUPPER card
          m_bar1->INT_TAB_ENABLE &= ~(1 << i);

          // ...and tell the driver the interrupt is disabled
          int iores = ioctl(m_fd, MASK_IRQ, &i);
          if( iores < 0 )
            {
              LOG5( "WupperCard::irq_disable: Error from ioctl(RESET_IRQ_COUNTERS).");
              THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)");
            }
        }
    }
  else
    {
      LOG15( "WupperCard::irq_disable: 111 ");
      // Disable the interrupt by direct access to the register in the WUPPER card
      m_bar1->INT_TAB_ENABLE &= ~(1 << interrupt);

      // ...and tell the driver the interrupt is disabled
      LOG15( "WupperCard::irq_disable: 222 ");

      int iores = ioctl(m_fd, MASK_IRQ, &interrupt);
      LOG15( "WupperCard::irq_disable: 333 ");
      if( iores < 0 )
        {
          LOG5( "WupperCard::irq_disable: Error from ioctl(RESET_IRQ_COUNTERS).");
          THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)");
        }
      LOG15( "WupperCard::irq_disable: 444 ");
    }
  LOG15( "WupperCard::irq_disable() done for interrupt " << interrupt);
}

// ----------------------------------------------------------------------------

void WupperCard::irq_wait( u_int interrupt )
{
  LOG15( "WupperCard::irq_wait() called for interrupt " << interrupt);

  int iores = ioctl(m_fd, WAIT_IRQ, &interrupt);
  if( iores < 0 )
    {
      LOG5( "WupperCard::irq_wait: Error from ioctl(WAIT_IRQ).");
      THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(WAIT_IRQ)");
    }
}

// ----------------------------------------------------------------------------

void WupperCard::irq_reset_counters( u_int interrupt )
{
  LOG15( "WupperCard::irq_reset_counters() called for interrupt " << interrupt);

  if( interrupt == ALL_IRQS )
    {
      LOG15( "WupperCard::irq_reset_counters: Clearing all interrupt counters.");
      u_int i;
      for( i = 0; i < NUM_INTERRUPTS; ++i )
        {
          int iores = ioctl(m_fd, RESET_IRQ_COUNTERS, &i);
          if( iores < 0 )
            {
              LOG5( "WupperCard::irq_reset_counters: Error from ioctl(RESET_IRQ_COUNTERS).");
              THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)");
            }
        }
    }
  else
    {
      int iores = ioctl(m_fd, RESET_IRQ_COUNTERS, &interrupt);
      if( iores < 0 )
        {
          LOG5( "WupperCard::irq_reset_counters: Error from ioctl(RESET_IRQ_COUNTERS).");
          THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(RESET_IRQ_COUNTERS)");
        }
    }
}

// ----------------------------------------------------------------------------

void WupperCard::irq_cancel( u_int interrupt )
{
  LOG15( "WupperCard::irq_cancel() called for interrupt " << interrupt);

  if( interrupt == ALL_IRQS )
    {
      LOG15( "WupperCard::irq_cancel: Clearing all interrupt counters.");
      u_int i;
      for( i = 0; i < NUM_INTERRUPTS; ++i )
        {
          int iores = ioctl(m_fd, CANCEL_IRQ_WAIT, &i);
          if( iores < 0 )
            {
              LOG5( "WupperCard::irq_cancel: Error from ioctl(CANCEL_IRQ_WAIT).");
              THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)");
            }
        }
    }
  else
    {
      int iores = ioctl(m_fd, CANCEL_IRQ_WAIT, &interrupt);
      if( iores < 0 )
        {
          LOG5( "WupperCard::irq_cancel: Error from ioctl(CANCEL_IRQ_WAIT).");
          THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)");
        }
    }
}

// ----------------------------------------------------------------------------

void WupperCard::irq_clear( u_int interrupt )
{
  LOG15( "WupperCard::irq_clear() called for interrupt " << interrupt);

  if( interrupt == ALL_IRQS )
    {
      LOG15( "WupperCard::irq_clear: Clearing all interrupt counters.");
      u_int i;
      for( i = 0; i < NUM_INTERRUPTS; ++i )
        {
          int iores = ioctl(m_fd, CLEAR_IRQ, &i);
          if( iores < 0 )
            {
              LOG5( "WupperCard::irq_clear: Error from ioctl(CANCEL_IRQ_WAIT).");
              THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)");
            }
        }
    }
  else
    {
      int iores = ioctl(m_fd, CLEAR_IRQ, &interrupt);
      if( iores < 0 )
        {
          LOG5( "WupperCard::irq_clear: Error from ioctl(CANCEL_IRQ_WAIT).");
          THROW_WUPPER_EXCEPTION(IOCTL, "Error from ioctl(CANCEL_IRQ_WAIT)");
        }
    }
}

// ----------------------------------------------------------------------------

int WupperCard::card_model()
{
  LOG15( "WupperCard::card_model() called");

  u_long card_type = 0;
  card_type = cfg_get_option(BF_CARD_TYPE);

  if( card_type != WUPPER_709 &&
      card_type != WUPPER_710 &&
      card_type != WUPPER_711 &&
      card_type != WUPPER_712 &&
      card_type != WUPPER_128 )
    {
      LOG5( "WupperCard::card_model: Unknown WUPPER-card ID " << card_type );
      //THROW_WUPPER_EXCEPTION(HW, "Cannot identify card");
      fprintf( stderr, "###WARNING: unknown WUPPER-card type = %lu\n", card_type );
    }

  return (int) card_type;
}

// ----------------------------------------------------------------------------

u_long WupperCard::openBackDoor( int bar )
{
  LOG15( "WupperCard::openBackDoor() called");

  if( bar == 0 )
    return m_bar0Base;
  else if( bar == 1 )
    return m_bar1Base;
  else if( bar == 2 )
    return m_bar2Base;
  else
    THROW_WUPPER_EXCEPTION(PARAM, "Parameter bar is out of range");
}

// ----------------------------------------------------------------------------
//Method coded by Anna Stollenwerk (and improved by M. Joos)

monitoring_data_t WupperCard::get_monitoring_data( u_int device_mask )
{
  LOG15( "WupperCard::get_monitoring_data() called");

  // Exception commented out: application needs to make sure it doesn't call
  // this function for an WUPPER_709, except for 'FPGA_MONITORING'
  //if( !(m_cardModel == WUPPER_711 || m_cardModel == WUPPER_712) )
  //  {
  //    LOG5( "WupperCard::get_monitoring_data: This method only supports the WUPPER-711 and WUPPER-712.");
  //    THROW_WUPPER_EXCEPTION(HW, "This method only supports the WUPPER-711 and WUPPER-712");
  //  }

  // Read the monitoring data of the FPGA
  u_long lvalue;//, number_channels;
  float  fvalue;
  monitoring_data_t mondata;

  if( device_mask & FPGA_MONITORING )
    {
      LOG20( "WupperCard::get_monitoring_data: Reading FPGA data");
      lvalue = cfg_get_option(BF_FPGA_CORE_TEMP);
      fvalue = (((float)lvalue * 503.975)/4096.0 - 273.15);
      mondata.fpga.temperature = fvalue;
      LOG20( "WupperCard::get_monitoring_data: fvalue (1) = " << fvalue);

      lvalue = cfg_get_option(BF_FPGA_CORE_VCCINT);
      fvalue = lvalue * 3.0 / 4096.0;
      mondata.fpga.vccint = fvalue;
      LOG20( "WupperCard::get_monitoring_data: fvalue (2) = " << fvalue);
      lvalue = cfg_get_option(BF_FPGA_CORE_VCCAUX);
      fvalue = lvalue * 3.0 / 4096.0;
      mondata.fpga.vccaux = fvalue;
      LOG20( "WupperCard::get_monitoring_data: fvalue (3) = " << fvalue);

      lvalue = cfg_get_option(BF_FPGA_CORE_VCCBRAM);
      fvalue = lvalue * 3.0 / 4096.0;
      mondata.fpga.vccbram = fvalue;
      LOG20( "WupperCard::get_monitoring_data: fvalue (4) = " << fvalue);

      lvalue = cfg_get_option(BF_FPGA_DNA);
      mondata.fpga.dna = lvalue;
    }

  // Read the monitoring data of the MiniPODs
  if( device_mask & POD_MONITORING )
    {
      LOG20( "WupperCard::get_monitoring_data: Reading MiniPod data");

      //number_channels = cfg_get_option(BF_NUM_OF_CHANNELS);
      //LOG20( "WupperCard::get_monitoring_data: BF_NUM_OF_CHANNELS = " << number_channels);

      u_char lsb, msb, cloop;
      minipod_device_t *pod;

      // Read the LOS bits once (the second read below will fetch the valid status)
      for( pod = minipod_devices; pod->name != NULL; ++pod )
        {
          // Reading again after a 1 second sleep. See WUPPER-393
          i2c_devices_read(pod->name, 0x09, &msb);
          i2c_devices_read(pod->name, 0x0a, &lsb);
        }

      sleep(1);

      // Check for presence of MiniPOD devices, based on reading a MiniPOD register
      // that should contain an ASCII character
      int podnum;
      for(podnum = 0; podnum < MINIPOD_CNT; ++podnum)
        mondata.minipod[podnum].absent = true;
      podnum = 0;
      for( pod = minipod_devices; pod->name != NULL; ++pod, ++podnum )
        {
          cloop = 152; // First char of 'vname'
          i2c_devices_read(pod->name, cloop, &lsb);
          if( isascii(lsb) ) {
            mondata.minipod[podnum].absent = false;
          } else {
            // Try one more time
            i2c_devices_read(pod->name, cloop, &lsb);
            if( isascii(lsb) )
              mondata.minipod[podnum].absent = false;
          }
        }

      podnum = 0;
      for( pod = minipod_devices; pod->name != NULL; ++pod, ++podnum )
        {
          strcpy(mondata.minipod[podnum].name, pod->description);

          // Skip reading registers from devices not present, i.e. not detected
          if( mondata.minipod[podnum].absent )
            continue;

          // As the temperature has a tolerance of +/- 3 C there is no point
          // in reading the digits after the comma from offset 0x1d
          i2c_devices_read(pod->name, 0x1c, &msb);
          //i2c_devices_read(pod->name, 0x1d, &lsb);

          LOG5("WupperCard::get_monitoring_data: tmp dev = "
               << pod->name << " msb = " << int(msb));

          //mondata.minipod[podnum].temp = msb + (float)lsb / 256.0;
          // Note: According to the manual the MSB provides the temperature as a signed 2's complement.
          //       Therefore this simple assignment will only work for positive temperatures
          mondata.minipod[podnum].temp = msb;

          i2c_devices_read(pod->name, 0x20, &msb);
          i2c_devices_read(pod->name, 0x21, &lsb);
          mondata.minipod[podnum].v33 = (float)((msb << 8) + lsb) * 0.0001;

          i2c_devices_read(pod->name, 0x22, &msb);
          i2c_devices_read(pod->name, 0x23, &lsb);
          mondata.minipod[podnum].v25 = (float)((msb << 8) + lsb) * 0.0001;

          i2c_devices_read(pod->name, 0x09, &msb);
          i2c_devices_read(pod->name, 0x0a, &lsb);
          mondata.minipod[podnum].los = (msb << 8) + lsb;

          for( cloop = 0; cloop < 12; ++cloop )
            {
              LOG20( "WupperCard::get_monitoring_data: Reading optical_power "
                     << 11 - cloop << " from registers " << 0x40 + (cloop * 2)
                     << " and " << 0x40 + (cloop * 1));
              i2c_devices_read(pod->name, 0x40 + (cloop * 2), &msb);
              i2c_devices_read(pod->name, 0x41 + (cloop * 2), &lsb);
              mondata.minipod[podnum].optical_power[11 - cloop] = ((msb << 8) + lsb) / 10.0;
            }

          for( cloop = 152; cloop < 168; ++cloop )
            {
              i2c_devices_read(pod->name, cloop, &lsb);
              mondata.minipod[podnum].vname[cloop - 152] = lsb;
            }
          mondata.minipod[podnum].vname[15] = 0;

          for( cloop = 168; cloop < 171; ++cloop )
            {
              i2c_devices_read(pod->name, cloop, &lsb);
              mondata.minipod[podnum].voui[cloop - 168] = lsb;
            }

          for( cloop = 171; cloop < 187; ++cloop )
            {
              i2c_devices_read(pod->name, cloop, &lsb);
              mondata.minipod[podnum].vpnum[cloop - 171] = lsb;
            }
          mondata.minipod[podnum].vpnum[15] = 0;

          for( cloop = 187; cloop < 189; ++cloop )
            {
              i2c_devices_read(pod->name, cloop, &lsb);
              mondata.minipod[podnum].vrev[cloop - 187] = lsb;
            }

          for( cloop = 189; cloop < 205; ++cloop )
            {
              i2c_devices_read(pod->name, cloop, &lsb);
              mondata.minipod[podnum].vsernum[cloop - 189] = lsb;
            }
          mondata.minipod[podnum].vsernum[15] = 0;

          for( cloop = 205; cloop < 213; ++cloop )
            {
              i2c_devices_read(pod->name, cloop, &lsb);
              mondata.minipod[podnum].vdate[cloop - 205] = lsb;
            }
          mondata.minipod[podnum].vdate[7] = 0;
        }
    }

  // Read the monitoring data of the LTCs
  if( device_mask & LTC_MONITORING )
    {
      LOG20( "WupperCard::get_monitoring_data: Reading LTC data");
      u_char lsb, msb;

      // Read the monitoring data of the LTC1
      i2c_devices_write(ltc_devices[0].name, 0x06, 0x00);
      i2c_devices_write(ltc_devices[0].name, 0x07, 0x03);
      i2c_devices_write(ltc_devices[0].name, 0x08, 0x10);
      i2c_devices_write(ltc_devices[0].name, 0x01, 0xf8);

      i2c_devices_read(ltc_devices[0].name, 0x0a, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x0b, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
      mondata.ltc1.VCCINT_current = fvalue;

      i2c_devices_read(ltc_devices[0].name, 0x0c, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x0d, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      mondata.ltc1.VCCINT_voltage = fvalue;

      i2c_devices_read(ltc_devices[0].name, 0x0e, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x0f, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
      mondata.ltc1.MGTAVCC_current = fvalue;

      i2c_devices_read(ltc_devices[0].name, 0x10, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x11, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      mondata.ltc1.MGTAVCC_voltage = fvalue;

      // First read - dummy
      // According to Kai, the data of the first read may not be correct:
      i2c_devices_read(ltc_devices[0].name, 0x12, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x13, &lsb);
      // Second read - get the real data
      i2c_devices_read(ltc_devices[0].name, 0x12, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x13, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.0625;
      mondata.ltc1.FPGA_internal_diode_temperature = fvalue;

      if( m_cardModel == WUPPER_712 )
        {
          i2c_devices_read(ltc_devices[0].name, 0x16, &msb);
          i2c_devices_read(ltc_devices[0].name, 0x17, &lsb);
          fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
          mondata.ltc1.MGTAVTT_current = fvalue;
        }
      else
        {
          i2c_devices_read(ltc_devices[0].name, 0x16, &msb);
          i2c_devices_read(ltc_devices[0].name, 0x17, &lsb);
          fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
          mondata.ltc1.MGTAVTTC_voltage = fvalue;
        }

      if( m_cardModel == WUPPER_712 )
        {
          i2c_devices_read(ltc_devices[0].name, 0x18, &msb);
          i2c_devices_read(ltc_devices[0].name, 0x19, &lsb);
          fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
          mondata.ltc1.MGTAVTT_voltage = fvalue;
        }
      else
        {
          i2c_devices_read(ltc_devices[0].name, 0x18, &msb);
          i2c_devices_read(ltc_devices[0].name, 0x19, &lsb);
          fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
          mondata.ltc1.MGTVCCAUX_voltage = fvalue;
        }

      i2c_devices_read(ltc_devices[0].name, 0x1a, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x1b, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.0625;
      mondata.ltc1.LTC2991_1_internal_temperature = fvalue;

      i2c_devices_read(ltc_devices[0].name, 0x1c, &msb);
      i2c_devices_read(ltc_devices[0].name, 0x1d, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 + 2.5;
      mondata.ltc1.vcc = fvalue;

      // Read the monitoring data of the LTC2
      i2c_devices_write(ltc_devices[1].name, 0x06, 0x00);
      i2c_devices_write(ltc_devices[1].name, 0x07, 0x30);
      i2c_devices_write(ltc_devices[1].name, 0x08, 0x10);
      i2c_devices_write(ltc_devices[1].name, 0x01, 0xf8);

      i2c_devices_read(ltc_devices[1].name, 0x0a, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x0b, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
      mondata.ltc2.PEX0P9V_current = fvalue;

      i2c_devices_read(ltc_devices[1].name, 0x0c, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x0d, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      mondata.ltc2.PEX0P9V_voltage = fvalue;

      i2c_devices_read(ltc_devices[1].name, 0x0e, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x0f, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;
      mondata.ltc2.SYS18_current = fvalue;

      i2c_devices_read(ltc_devices[1].name, 0x10, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x11, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      mondata.ltc2.SYS18_voltage = fvalue;

      if( m_cardModel == WUPPER_712 )
        {
          i2c_devices_read(ltc_devices[1].name, 0x12, &msb);
          i2c_devices_read(ltc_devices[1].name, 0x13, &lsb);
          fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 / 0.040215;;
          mondata.ltc2.SYS25_current = fvalue;
        }
      else
        {
          i2c_devices_read(ltc_devices[1].name, 0x12, &msb);
          i2c_devices_read(ltc_devices[1].name, 0x13, &lsb);
          fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
          mondata.ltc2.SYS12_voltage = fvalue;
        }

      i2c_devices_read(ltc_devices[1].name, 0x14, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x15, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518;
      mondata.ltc2.SYS25_voltage = fvalue;

      i2c_devices_read(ltc_devices[1].name, 0x16, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x17, &lsb);
      fvalue = ((((msb & 0x3f) << 8) + lsb) * 0.0625) - 24.0;
      mondata.ltc2.PEX8732_internal_diode_temperature = fvalue;

      i2c_devices_read(ltc_devices[1].name, 0x1a, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x1b, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.0625;
      mondata.ltc2.LTC2991_2_internal_temperature = fvalue;

      i2c_devices_read(ltc_devices[1].name, 0x1c, &msb);
      i2c_devices_read(ltc_devices[1].name, 0x1d, &lsb);
      fvalue = (((msb & 0x3f) << 8) + lsb) * 0.00030518 + 2.5;
      mondata.ltc2.vcc = fvalue;
    }

  LOG15( "WupperCard::get_monitoring_data() done.");
  return mondata;
}

// ----------------------------------------------------------------------------

u_long WupperCard::get_rxusrclk_freq( u_int channel )
{
  LOG15( "WupperCard::get_rxusrclk_freq() called");

  cfg_set_option("RXUSRCLK_FREQ_CHANNEL", channel&0x3F);

  // Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec     = 1; // One second
  timer.it_value.tv_usec    = 0;
  timer.it_interval.tv_sec  = 0;
  timer.it_interval.tv_usec = 0; // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  u_long valid;
  do
    {
      valid = cfg_get_option("RXUSRCLK_FREQ_VALID");
      if( m_timeout )
        {
          THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout");
        }
    } while( valid == 0 );

  // Stop watchdog
  timer.it_value.tv_usec = 0;
  timer.it_value.tv_sec = 0;
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  u_long value = cfg_get_option("RXUSRCLK_FREQ_VAL");
  return value;
}

// ----------------------------------------------------------------------------
// Private functions (not part of the user API)
// ----------------------------------------------------------------------------

u_long WupperCard::map_memory_bar( u_long pci_addr, size_t size )
{
  LOG15( "WupperCard::map_memory_bar() called");

  // Get system page size
  long pagesz = sysconf(_SC_PAGE_SIZE);
  LOG20( "WupperCard::map_memory_bar: pagesz = " << HEX(pagesz));

  // Sanity check
  if( pagesz == -1 )
    pagesz = 0x10000;

  // Turn value into its matching bitmask: mmap requires pagesize alignment
  u_long offset = pci_addr & (pagesz-1);
  pci_addr &= (0xffffffffffffffffL & (~(pagesz-1)));

  void *vaddr = mmap(0, size, (PROT_READ|PROT_WRITE), MAP_SHARED, m_fd, pci_addr);
  if( vaddr == MAP_FAILED )
    {
      LOG5( "WupperCard::map_memory_bar: Error from mmap for pci_addr = "
            << pci_addr << " and size = " << size);
      THROW_WUPPER_EXCEPTION(MAPERROR, "Error from mmap for pci_addr = "
                          << pci_addr << " and size = " << size);
    }

  return (u_long)vaddr + offset;
}

// ----------------------------------------------------------------------------

void WupperCard::unmap_memory_bar( u_long vaddr, size_t size )
{
  LOG15( "WupperCard::unmap_memory_bar() called");

  int ret = munmap((void *)vaddr, size);
  if( ret )
    {
      LOG5("unmap_memory_bar: Error from munmap, errno = 0x" << HEX(errno));
      THROW_WUPPER_EXCEPTION(UNMAPERROR, "Error from munmap, errno = 0x" << HEX(errno));
    }
}

// ----------------------------------------------------------------------------

void WupperCard::i2c_wait_not_full()
{
  LOG15( "WupperCard::i2c_wait_not_full() called");

  // Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec = 1;     // One second
  timer.it_value.tv_usec = 0;
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 0; // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  u_long status = cfg_get_reg(REG_I2C_WR);
  while( status & I2C_FULL_FLAG )
    {
      usleep(I2C_SLEEP);
      if( m_timeout )
        {
          THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout");
        }
      status = cfg_get_reg(REG_I2C_WR);
    }

  // Stop watchdog
  timer.it_value.tv_usec = 0;
  timer.it_value.tv_sec = 0;
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
}

// ----------------------------------------------------------------------------

void WupperCard::i2c_wait_not_empty()
{
  LOG15( "WupperCard::i2c_wait_not_empty() called");

  // Set up watchdog
  m_timeout = 0;
  struct itimerval timer;
  timer.it_value.tv_sec = 1;     // One second
  timer.it_value.tv_usec = 0;
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 0; // Only one shot
  setitimer(ITIMER_VIRTUAL, &timer, NULL);

  u_long status = cfg_get_reg(REG_I2C_RD);
  while( status & I2C_EMPTY_FLAG )
    {
      usleep(I2C_SLEEP);
      if( m_timeout )
        {
          THROW_WUPPER_EXCEPTION(TIMEOUT, "Timeout");
        }
      status = cfg_get_reg(REG_I2C_RD);
    }

  // Stop watchdog
  timer.it_value.tv_usec = 0;
  timer.it_value.tv_sec = 0;
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
}

// ----------------------------------------------------------------------------

int WupperCard::i2c_parse_address_string( const char *str,
                                       u_char     *switch1_val,
                                       u_char     *switch2_val,
                                       u_char     *switch3_val,
                                       u_char     *dev_addr )
{
  // This method understands three formats of device string
  // Format 1 is a symbolic name such as "ADN2814". The names are defined
  //          in the arrays i2c_devices_WUPPER_7[09,10,11] at the beginning of this file
  // Format 2 has the structure "P1:ADD" with P1 = Port number (of switch 1),
  //          ADDR = address of the I2C device
  // Format 3 has the structure "P1:P2:ADD" with P1 = Port number of switch 1,
  //          P2 = Port number of switch 3, ADDR = address of the i2c device
  //
  // The I2C-switches port numbers have two formats too.
  // In a device string of format 2 or 3 the port is decimal
  // (e.g. "4:0x70" refers to port 4 and address 0x70)
  // The port numbers as provided by the i2c_devices_WUPPER_7xx structures
  // are coded as a bit mask. e.g. 0x8 selectes the 4th port of the switch.
  // This function converts all switch port numbers to the binary format
  // (a value 'switchX_val' ready to write directly into the switch).

  LOG15("WupperCard::i2c_parse_address_string() called, string=" << str);

  // Initialize values to be returned
  *switch1_val = 0;
  *switch2_val = 0;
  *switch3_val = 0;
  *dev_addr = 0;

  // Check if we have a device of Format 1
  std::string namestr( str );
  for( size_t i=0; i<namestr.size(); ++i )
    namestr[i] = toupper( namestr[i] );

  i2c_device_t *devices = 0;
  if( m_cardModel == WUPPER_712 || m_cardModel == WUPPER_711 )
    // 711 and 712 have the same I2C devices
    devices = i2c_devices_WUPPER_711;
  else if( m_cardModel == WUPPER_710 )
    devices = i2c_devices_WUPPER_710;
  else if( m_cardModel == WUPPER_709 )
    devices = i2c_devices_WUPPER_709;
  else if( m_cardModel == WUPPER_128 )
    devices = i2c_devices_WUPPER_128;

  // Sanity
  if( devices == 0 )
    return -1;

  for( ; devices->name != NULL; ++devices )
    {
      if( strcmp(namestr.data(), devices->name) == 0 )
        {
          LOG20("WupperCard::i2c_parse_address_string: Device found!");
          LOG20("WupperCard::i2c_parse_address_string: devices->name        = " << devices->name);
          LOG20("WupperCard::i2c_parse_address_string: devices->description = " << devices->description);
          LOG20("WupperCard::i2c_parse_address_string: devices->address     = " << (u_int)devices->address);
          LOG20("WupperCard::i2c_parse_address_string: devices->switches    = "
                << (u_int)devices->switch_settings[0] << " "
                << (u_int)devices->switch_settings[1] << " "
                << (u_int)devices->switch_settings[2] );

          *switch1_val = devices->switch_settings[0];
          *switch2_val = devices->switch_settings[1];
          *switch3_val = devices->switch_settings[2];
          *dev_addr    = devices->address;

          return(0);
        }
    }

  // Check if we have a device of Format 2 or 3
  LOG20( "WupperCard::i2c_parse_address_string: Check if we have a device of Format 2 or 3");

  char *pcolon1 = strchr(const_cast<char*>(str), ':');
  if( pcolon1 == NULL )
    {
      LOG5( "WupperCard::i2c_parse_address_string: Failed to find a ':' character");
      return I2C_DEVICE_ERROR_NOT_EXISTING;
    }

  LOG20( "WupperCard::i2c_parse_address_string: rest string = " << pcolon1);

  unsigned long int val;
  char *pend;
  char *pcolon2 = strchr((pcolon1 + 1), ':');
  if( pcolon2 == NULL )
    {
      LOG20( "WupperCard::i2c_parse_address_string: Format 2 detected");

      val = strtoul( str, &pend, 0 );
      if( *pend != ':' )
        {
          LOG5( "WupperCard::i2c_parse_address_string: Invalid first I2C port number");
          return I2C_DEVICE_ERROR_INVALID_PORT;
        }
      *switch1_val = (u_char) (1 << val);

      val = strtoul( pcolon1 + 1, &pend, 0 );
      if( *pend != '\0' )
        {
          LOG5( "WupperCard::i2c_parse_address_string: Invalid I2C address");
          return I2C_DEVICE_ERROR_INVALID_ADDRESS;
        }
      *dev_addr = (u_char) val;
    }
  else
    {
      LOG20( "WupperCard::i2c_parse_address_string: Format 3 detected");

      val = strtoul(str, &pend, 0);
      if( *pend != ':' )
        {
          LOG5( "WupperCard::i2c_parse_address_string: Invalid first I2C port number (2)");
          return I2C_DEVICE_ERROR_INVALID_PORT;
        }
      *switch1_val = (u_char) (1 << val);

      val = strtoul( pcolon1 + 1, &pend, 0 );
      if( *pend != ':' )
        {
          LOG5( "WupperCard::i2c_parse_address_string: Invalid second I2C port number");
          return I2C_DEVICE_ERROR_INVALID_PORT;
        }
      *switch2_val = (u_char) (1 << val);

      val = strtoul( pcolon2 + 1, &pend, 0 );
      if( *pend != '\0' )
        {
          LOG5( "WupperCard::i2c_parse_address_string: Invalid I2C address");
          return I2C_DEVICE_ERROR_INVALID_ADDRESS;
        }
      *dev_addr = (u_char) val;
    }

  LOG20( "WupperCard::i2c_parse_address_string: binary *switch1_val = " << (u_int)*switch1_val);
  LOG20( "WupperCard::i2c_parse_address_string: binary *switch2_val = " << (u_int)*switch2_val);
  LOG20( "WupperCard::i2c_parse_address_string: *dev_addr     = " << (u_int)*dev_addr);

  return 0;
}

// ----------------------------------------------------------------------------

void WupperCard::i2c_set_switches( u_char switch1_val,
                                u_char switch2_val,
                                u_char switch3_val )
{
  if( m_cardModel == WUPPER_712 || m_cardModel == WUPPER_711 )
    {
      // Configure the switch: 711 and 712 are identical wrt I2C
      i2c_write_byte( I2C_ADDR_SWITCH1_WUPPER_711, switch1_val );
    }
  else if( m_cardModel == WUPPER_710 )
    {
      // Configure the switch
      i2c_write_byte( I2C_ADDR_SWITCH1_WUPPER_710, switch1_val );
    }
  else if( m_cardModel == WUPPER_709 )
    {
      // Configure the switch and switch2
      i2c_write_byte( I2C_ADDR_SWITCH1_WUPPER_709, switch1_val );
      i2c_write_byte( I2C_ADDR_SWITCH2_WUPPER_709, switch2_val );
    }
  else if( m_cardModel == WUPPER_128 )
    {
      // Configure switch1, switch2 and switch3
      i2c_write_byte( I2C_ADDR_SWITCH1_WUPPER_128, switch1_val );
      i2c_write_byte( I2C_ADDR_SWITCH2_WUPPER_128, switch2_val );
      i2c_write_byte( I2C_ADDR_SWITCH3_WUPPER_128, switch3_val );
    }
}


// ----------------------------------------------------------------------------

int WupperCard::check_digic_value2( const char *str, u_long *version, u_long *delay )
{
  char *pend   = NULL;
  char *pcolon = strchr(const_cast<char*>(str), ':');

  LOG15( "WupperCard::check_digic_value2() called");

  if( pcolon == NULL )
    return -1;

  *pcolon = '\0';

  *version = strtoul(str, &pend, 0);
  if( *pend != '\0' )
    return -2;

  *delay = strtoul(pcolon + 1, &pend, 0);
  if( *delay == 0 )
    return -3;

  return 0;
}

// ----------------------------------------------------------------------------
