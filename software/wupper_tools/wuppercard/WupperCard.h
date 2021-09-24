/******************************************************************* 
 * \mainpage                                                       * 
 *                                                                 * 
 * @author: Markus Joos, CERN                                      *
 *  Maintainer: Henk Boterenbrood, Nikhef                          * 
 *                                                                 *
 * @brief                                                          *
 * This note defines an application program interface (API) for    *
 * the use of the WUPPER PCIe I/O card in the ATLAS read-out system.  *
 * The intention of the API is to satisfy the needs of simple      *
 * test programs as well as the requirements of the                *
 * FelixApplication.                                               *
 *                                                                 *
 * @copyright CERN, Nikhef                                         *
 ******************************************************************/ 

#ifndef WUPPERCARD_H
#define WUPPERCARD_H

#include <string>
#include <sys/types.h>
#include "cmem_rcc/cmem_rcc.h"
#include "wuppercard/wupper_common.h"

#include "regmap/regmap.h"

// Constants
#define WAIT_TIME                         600
#define NUM_INTERRUPTS                    8
#define MICRO_WAIT_TIME                   200
#define WUPPER_GBT_FILE_NOT_FOUND            -1
#define WUPPER_GBT_VERSION_NOT_FOUND         -2
#define WUPPER_GBT_TMODE_FEC                 0
#define WUPPER_GBT_ALIGNMENT_CONTINUOUS      0
#define WUPPER_DMA_WRAPAROUND                1
#define WUPPER_GBT_ALIGNMENT_ONE             1
#define WUPPER_GBT_CHANNEL_AUTO              1
#define WUPPER_GBT_TMODE_WideBus             1

// Board models
#define WUPPER_712                           712
#define WUPPER_711                           711
#define WUPPER_710                           710
#define WUPPER_709                           709
#define WUPPER_128                           128

// Firmware types
#define FIRMW_GBT                         0
#define FIRMW_FULL                        1
#define FIRMW_LTDB                        2
#define FIRMW_FEI4                        3
#define FIRMW_PIXEL                       4
#define FIRMW_STRIP                       5
#define FIRMW_FELIG                       6
#define FIRMW_FMEMU                       7
#define FIRMW_MROD                        8
#define FIRMW_LPGBT                       9

// I2C definitions
#define I2C_ADDR_SWITCH1_WUPPER_711          0x70
#define I2C_ADDR_SWITCH1_WUPPER_710          0x70
#define I2C_ADDR_SWITCH1_WUPPER_709          0x74
#define I2C_ADDR_SWITCH2_WUPPER_709          0x75
#define I2C_ADDR_SWITCH1_WUPPER_128          0x74
#define I2C_ADDR_SWITCH2_WUPPER_128          0x75
#define I2C_ADDR_SWITCH3_WUPPER_128          0x76
#define I2C_ADDR_CXP                      0x6E
#define I2C_FULL_FLAG                     (1 << 25)
#define I2C_EMPTY_FLAG                    (1 << 8)
#define I2C_DELAY                         1000
#define I2C_SLEEP                         100
#define I2C_SWITCH_CXP1                   (1 << 2)
#define I2C_SWITCH_CXP2                   (1 << 3)

// I2C error codes
#define I2C_DEVICE_ERROR_NOT_EXISTING     1
#define I2C_DEVICE_ERROR_INVALID_PORT     2
#define I2C_DEVICE_ERROR_INVALID_ADDRESS  3
#define I2C_DEVICE_ERROR_INVALID_REGISTER 4
#define I2C_DEVICE_ERROR_INVALID_DATA     5

// Interrupts
#define ALL_IRQS                          0xFFFFFFFF

// Monitoring devices
#define FPGA_MONITORING                   1
#define POD_MONITORING                    2
#define LTC_MONITORING                    4

// Resource locking
#define LOCK_NONE                         0
#define LOCK_DMA0                         1
#define LOCK_DMA1                         2
#define LOCK_I2C                          4
#define LOCK_FLASH                        8
#define LOCK_ELINK                        16
#define LOCK_ALL                          0xffffffff
#define LOCK_DMA(n)                       (1<<(16+n))

// Other constants
#define ALL_BITS                          0xFFFFFFFFFFFFFFFF

// Register model
typedef struct
{
  volatile u_long start_address;        /*  low half, bits  63:00 */
  volatile u_long end_address;          /*  low half, bits 127:64 */
  volatile u_long tlp         :11;      /* high half, bits  10:00 */
  volatile u_long read        : 1;      /* high half, bit      11 */
  volatile u_long wrap_around : 1;      /* high half, bit      12 */
  volatile u_long reserved    :51;      /* high half, bits  63:13 */
  volatile u_long read_ptr;             /* high half, bits 127:64 */
} dma_descriptor_t;

typedef struct
{
  volatile u_long current_address;      /* bits  63:00 */
  volatile u_long descriptor_done : 1;  /* bit      64 */
  volatile u_long even_addr_dma   : 1;  /* bit      65 */
  volatile u_long even_addr_pc    : 1;  /* bit      66 */
} dma_status_t;

typedef struct
{
  volatile u_int  control;              /* bits  63:00 */
  volatile u_int  data;                 /* bits  95:64 */
  volatile u_long address;              /* bits 127:96 */
} int_vec_t;

typedef struct
{
  volatile u_long date_time : 40;       /* bits  39:00 */
  volatile u_long reserved  : 24;       /* bits  63:40 */
  volatile u_long revision  : 16;       /* bits  79:64 */
} board_id_t;

typedef struct
{
  dma_descriptor_t DMA_DESC[8];         /* 0x000 - 0x0ff */
  u_char           unused1[256];        /* 0x100 - 0x1ff */
  dma_status_t     DMA_DESC_STATUS[8];  /* 0x200 - 0x27f */
  u_char           unused2[128];        /* 0x280 - 0x2ff */
  volatile u_int   BAR0_VALUE;          /* 0x300 - 0x303 */
  u_char           unused3[12];         /* 0x304 - 0x30f */
  volatile u_int   BAR1_VALUE;          /* 0x310 - 0x313 */
  u_char           unused4[12];         /* 0x314 - 0x31f */
  volatile u_int   BAR2_VALUE;          /* 0x320 - 0x323 */
  u_char           unused5[220];        /* 0x324 - 0x3ff */
  volatile u_int   DMA_DESC_ENABLE;     /* 0x400 - 0x403 */
  u_char           unused7[28];         /* 0x404 - 0x41f */
  volatile u_int   DMA_RESET;           /* 0x420 - 0x423 */
  u_char           unused8[12];         /* 0x424 - 0x42f */
  volatile u_int   SOFT_RESET;          /* 0x430 - 0x433 */
  u_char           unused9[12];         /* 0x434 - 0x43f */
  volatile u_int   REGISTERS_RESET;     /* 0x440 - 0x443 */
} wuppercard_bar0_regs_t;

typedef struct
{
  int_vec_t        INT_VEC[8];          /* 0x000 - 0x07f */
  u_char           unused1[128];        /* 0x080 - 0x0ff */
  volatile u_int   INT_TAB_ENABLE;      /* 0x100 - 0x103 */
} wuppercard_bar1_regs_t;

typedef struct
{
  const char *name;
  const char *description;
  u_char      address;
  u_char      switch_settings[3];
} i2c_device_t;

typedef struct
{
  float  temperature;
  float  vccint;
  float  vccaux;
  float  vccbram;
  u_long fanspeed;
  u_long dna;
} fpga_monitoring_data_t;

typedef struct
{
  const char *name;
  const char *description;
} minipod_device_t;

typedef struct
{
  const char *name;
  const char *description;
} ltc_device_t;

typedef struct
{
  bool  absent;
  char  name[10];
  int   temp;
  float v33;
  float v25;
  int   los;
  char  vname[16];
  char  voui[3];
  char  vpnum[16];
  char  vrev[2];
  char  vsernum[16];
  char  vdate[8];
  float optical_power[12];
} minipod_parameters_t;

typedef struct
{
  int number;
  const char *name;
  int offset;
} ltc_register_t;

typedef struct 
{
  float VCCINT_current;
  float VCCINT_voltage;
  float MGTAVCC_current;
  float MGTAVCC_voltage;
  float FPGA_internal_diode_temperature;
  float MGTAVTT_current;         //Only WUPPER-712
  float MGTAVTT_voltage;         //Only WUPPER-712
  float MGTAVTTC_voltage;        //Only WUPPER-711
  float MGTVCCAUX_voltage;       //Only WUPPER-711
  float LTC2991_1_internal_temperature;
  float vcc;
} ltc1_parameters_t;

typedef struct 
{
  float PEX0P9V_current;
  float PEX0P9V_voltage;
  float SYS18_current;
  float SYS18_voltage;
  float SYS12_voltage;           //Only WUPPER-711
  float SYS25_current;           //Only WUPPER-712 
  float SYS25_voltage;
  float PEX8732_internal_diode_temperature;
  float LTC2991_2_internal_temperature;
  float vcc;
} ltc2_parameters_t;

typedef struct
{
  fpga_monitoring_data_t fpga;
  minipod_parameters_t   minipod[8];
  ltc1_parameters_t      ltc1;
  ltc2_parameters_t      ltc2;
} monitoring_data_t;

typedef struct
{
  u_int n_devices;
  u_int cdmap[MAXCARDS][2];
} device_list_t;

// Macros
#define HEX(n) std::hex << n << std::dec

// External declarations          //MJ: review
extern i2c_device_t  i2c_devices_WUPPER_709[];
extern i2c_device_t  i2c_devices_WUPPER_710[];
extern i2c_device_t  i2c_devices_WUPPER_711[];
extern i2c_device_t  i2c_devices_WUPPER_128[];

class WupperCard
{
public:
    /// The constructor of an WupperCard object only initializes a few class variables. It does not interact with the FELIX H/W.
    WupperCard();
    
    /**
     * \defgroup DriverInteraction Driver interaction 
     * @{
     * A set of functions that interact with the driver, there are methods to open the API for instance, but also to open an alternative
     * (backdoor) way to reading and writing the registers by memory-mapping a struct directly on the register map (BAR space).
     */
    /**
     *  This method opens the \e wupper driver and links one Wupper PCIe card to the WupperCard object. 
     *  This method has to be called before any other reference to the method is made. 
     *  In case of problems, check (more /proc/wupper) if the driver is running and if it can see all cards. 
     *  The method also checks if the major version of the register map of the F/W running on the WUPPER card 
     *  matches with the version of the “regmap” library. This is to prevent running the API on incompatible WUPPER cards. 
     * 
     *  Each WUPPER device has a number of resources that cannot be shared by multiple processes,
     *  such as a DMA controller or the onboard I2C-bus. The purpose of the 
     *  resource locking bits is to allow a process to declare to the driver that it requires exclusive access to such a
     *  resource. If a resource is locked by a process, the driver will refuse other processes that request access to
     *  the same resource. In such a case card_open() throws an exception. The parameter \e lock_mask passes a collection
     *  of bits to the driver. These bits are defined in WupperCard.h. Currently the following resources are defined:  
     *
     *      #define LOCK_DMA0    1 
     *      #define LOCK_DMA1    2 
     *      #define LOCK_I2C     4 
     *      #define LOCK_FLASH   8 
     *      #define LOCK_ELINK   16 
     *      #define LOCK_ALL     0xffffffff 
     *
     *  Note that DMA-related lock bits are currently also located in bits 16 and up:
     *  there is copy of LOCK_DMA0 and LOCK_DMA1 (in bit 16 and 17 resp.)
     *  and space for more DMA lock bits (required for next-generation firmware versions).
     *
     *  Example: To lock access to DMA1 and the FLASH memory of the first WUPPER device:
     *
     *      card_open( 0, LOCK_DMA1 | LOCK_FLASH )
     *  The lock will be held until the owning process calls card_close(). If a process terminates with an error the driver will
     *  release the resources that were locked by that process. Users can find an overview of what resources are locked by
     *  looking at the content of \e /proc/wupper.
     *  Processes that do not request any locks still have full access to the respective resources. That is to say that a
     *  process that does not lock DMA1 still can call the DMA related methods of the API.
     *  The method get_lock_mask() can be called to figure out what resources are locked. This was done on purpose because
     *  the application programmers know best if their applications (for example for diagnostic purposes) should be able to run even
     *  if a resource is locked. Consequently, the application programmers bear the responsibility for using the resource locking
     *  in a correct way.
     *
     *  @b Errors
     *  In case of an error, this method throws an exception.
     *  @param device_nr The number of the WUPPER device (0…N-1) that is to be linked to the object
     *  @param lock_mask The resources that are to be locked, defined as a bit mask
     *  @param ignore_version For some tools it may be useful to be able to open the FELIX device despite a mismatch between software and firmware version (in that case results in a warning, but does not throw an exception)
     */
    void card_open( int device_nr, u_int lock_mask, bool ignore_version = false );
    
    /**
     * This method unlinks a Wupper PCIe card. It must be called before closing the application.
     * 
     * @b Errors
     * In case of an error this method throws an exception.
     */
    void card_close();
    
    /**
     * Please use WupperCard::number_of_devices() instead.
     */
    static u_int number_of_cards();
    
    /**
     * This method returns the number of WUPPER \e devices (PCIe endpoints) that are installed in the host computer. 
     * As it is a static method you do not have to instantiate an WupperCard object to call it.
     *
     * @b Errors
     * In case of an error the method will not throw an exception but return “0”.
     * Therefore “zero cards found” can also mean that: 
     * - the wupper driver was not running 
     * - the device node `/dev/wupper` was missing 
     * - the "GETCARDS" ioctl() of the wupper driver did not work
     */
    static u_int number_of_devices();

    /**
     * This method returns a structure with information about the cards and devices installed in the PC.
     * As it is a static method you do not have to instantiate an WupperCard object to call it.
     *
     * The parameter `device_list_t.n_devices` gives the total number of devices.
     * It is identical to the value returned by number_of_devices()
     * The value of `device_list_t.cdmap[device][0]` (with device = 0...(`device_list_t.n_devices`-1 )
     * is the type of the card as read from the \e CARD_TYPE register (offset 0xA0 of BAR2)
     * The value of `device_list_t.cdmap[device][1]` (with device = 0...(`device_list_t.n_devices`-1 )
     * is the relative number of the device with respect to the card.
     * That means that for a WUPPER-709 and WUPPER-710 it will always be "0" because
     * these are single device cards. For a WUPPER-711, WUPPER-712 or WUPPER-128 it can be "0" or "1".
     *
     * @b Errors 
     * In case of an error, this method throws an exception.
     */
    static device_list_t device_list();

    /**
     * This method returns the FELIX device number associated with the first device of the selected card number.
     * if for example the host machine contains two WUPPER-712 cards then card 0 is accessed through device 0,
     * and card 1 through device 2. If on the other hand there is one WUPPER-709 and one WUPPER-712 card in the machine,
     * then it could be either devices 0 and 1 or devices 0 and 2, depending on the order in which
     * the cards are enumerated by the host system.
     * This function is used by tools that act on a card rather than a device (for example,
     * card I2C-bus access is through device 0 of the card only).
     * @param card_number The number of the WUPPER card (0…N-1) in the host machine
     */
    static int card_to_device_number( int card_number );

    /**
     * This method returns information about a device's resources that are currently locked
     * by \e other instances of WupperCard objects,
     * which may reside in either the same process or in different processes.
     * The value returned is a global resource-lock value retrieved from the driver.
     * The individual lock bits are declared in WupperCard.h
     * @param device_nr The number of the WUPPER device (0…N-1)
     * 
     * Example:
     * @code
     *     WupperCard wuppercard; 
     *     u_int lock_bits = wuppercard.get_lock_mask( 0 );
     *     if( lock_mask & LOCK_DMA1 )
     *       cout << "Device 0 DMA1 is locked (by others)"
     * @endcode
     * @b Note
     * This method can be called without first calling open_card().
     * 
     * @b Errors
     * In case of an error, this method throws an exception.
     */
    u_int get_lock_mask( int device_nr );
    
    /**
     * This method returns the PCI base address of the specified PCI register block.
     * @param bar The number of a BAR register block; legal values are 0, 1 or 2
     * @return the PCI base address of the specified PCI register block
     */
    u_long openBackDoor( int bar );
    /**
     * This method is an alias for `openBackDoor(0)`.
     */
    u_long bar0Address() { return openBackDoor( 0 ); }
    /**
     * This method is an alias for `openBackDoor(1)`.
     */
    u_long bar1Address() { return openBackDoor( 1 ); }
    /**
     * This method is an alias for `openBackDoor(2)`.
     */
    u_long bar2Address() { return openBackDoor( 2 ); }
    /** @}*/
    
    /**
     * \defgroup DMA
     * @{
     * A set of functions to setup, start and stop DMA transfers and to interact with the circular buffer PC pointers.
     */
    /**
     * This method calls the wupper driver in order to determine the maximum number of TLP bytes that the H/W can support. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     */
    int  dma_max_tlp_bytes();
    
    /**
     * This method first stops the DMA channel identified by dma_id.
     * It does not check if the channel is busy.
     * Then it programs the channel and starts a new DMA from-device-to-host operation. 
     * 
     * Note: The bits 10:0 of the DMA descriptor (bitfield NUM_WORDS in the Wupper documentation)
     * will be set to the maximum TLP size supported by the system.
     * Therefore, the transfer size has to be a multiple of that value. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7 
     * @param dst The value for the start_address field of the descriptor.
     *            NOTE: You have to provide a physical memory address 
     * @param size The size of the transfer in bytes 
     * @param flags The value for the wrap_around field of the descriptor;
     *              "1" means: enable wrap around, i.e. use continuous DMA
     */
    void dma_to_host( u_int dma_id, u_long dst, size_t size, u_int flags );
    
    /**
     * This method first stops the DMA channel identified by \e dma_id.
     * It does not check if the channel is busy.
     * Then it programs the channel and starts a new DMA from-host-to-device operation. 
     * 
     * Note: The size of the transfer has to be a multiple of 32 bytes. 
     * 
     * The method internally computes the optimal value for the bits 10:0
     * of the DMA descriptor (bitfield NUM_WORDS in the Wupper documentation).  
     * 
     * The algorithm used is this: 
     *     1. if transfersize % 32 != 0: error("number of bytes transferred must be a multiple of 32") 
     *     2. tlp = get_max_tlp() 
     *     3. if transfersize % tlp == 0: do transfer 
     *     4. else: tlp = tlp >> 1 && goto 3
     * 
     * Note: The algorithm above is currently not used:
     * the transfer unit size is set to the minimum of 32 bytes,
     * to make sure small messages are always sent, in particular when continuous DMA is enabled.
     * The upper 16 bits of the flags parameter can be used to force a transfer size unequal to
     * (so larger than) 32 bytes (but must be a multiple of 32).
     *
     * @b Errors
     * In case of an error this method throws an exception.
     * 
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7 
     * @param src The value for the start_address field of the descriptor.
     *            NOTE: You have to provide a physical memory address 
     * @param size The size of the transfer in bytes 
     * @param flags The value for the wrap_around field of the descriptor. “1” means:
     *              enable wrap around, i.e. use continuous DMA
     */
    void dma_from_host( u_int dma_id, u_long src, size_t size, u_int flags );
    
    /**
     * This method returns whether the DMA channel identified by dma_id is enabled or not.
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7 
     */
    bool dma_enabled( u_int dma_id );

    /**
     * This method is blocking. It returns once the DMA on channel dma_id has ended.
     * The method has an internal (hard wired) time out of 1 second. 
     * 
     * @b Errors 
     * In case the DMA has not ended after 1 second this method throws an exception.
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7
     */
    void dma_wait( u_int dma_id );
    
    /**
     * This method clears the DMA channel identified by dma_id.
     * It does not check the status of that channel.
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7
     */
    void dma_stop( u_int dma_id );
    
    /**
     * Advances the internal read pointer of the DMA channel by the number of bytes given.
     * This is used when operating the DMA engine in "endless DMA" / "circular buffer" mode.
     * This method is to be called by the user after processing data at the head of the 
     * circular buffer to free the buffer for DMA writes or reads of the WUPPER card again. 
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7 
     * @param dst See below. NOTE: You have to provide a physical memory address 
     * @param size If the value of the read_ptr field, after adding bytes is larger than dst + size,
     *             size will be subtracted from read_ptr
     * @param bytes This value will be added to the \e read_ptr field of the DMA descriptor
     */
    void dma_advance_ptr( u_int dma_id, u_long dst, size_t size, size_t bytes );
    
    /**
     * This method directly writes the read pointer of a DMA channel.
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7 
     * @param dst The read pointer register of the DMA channel will be set to the value in \e dst
     */
    void dma_set_ptr( u_int dma_id, u_long dst );
    
    /**
     * This method returns the current value of the RD_POINTER.
     * That is to say the bits 127:64 of the DMA_DESC_[0..7]a as defined in the
     * <a href="https://gitlab.cern.ch/atlas-tdaq-felix/documents/blob/master/Wupper/wupper.pdf">Wupper</a>
     * documentation. 
     * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7
     */
    u_long dma_get_read_ptr( u_int dma_id );
    
    // This method sets the DMA_FIFO_FLUSH register to "1".
    //void dma_fifo_flush();  //MJ: disabled. See WupperCard.cpp
    
    /**
     * This method sets the DMA_RESET register to "1".
     */
    void dma_reset();
    
    /**
     * This method reads the status register of a DMA descriptor
     * (i.e. one of the DMA_DESC_STATUS_* registers)
     * and returns the value of the CURRENT_ADDRESS bit field (bits 63:0).
     * @param dma_id The DMA channel (descriptor) to be queried; valid numbers are 0..7
     */
    u_long dma_get_current_address( u_int dma_id );
    
    /**
    * This method reads the \e even_addr_dma and \e even_pc_dma bits of a DMA channel and compares them. 
    * @param dma_id The DMA channel (descriptor) to be used; valid numbers are 0..7 
    * @return Returns \e true if the bits have the same value and \e false if not.
    */
    bool dma_cmp_even_bits( u_int dma_id );

    /**
     * @}
     */
     
    /**
     * \defgroup I2C
     * @{
     * A set of functions that interact with the onboard I2C bus.
     */
        
    /**
     * These methods read or write one byte of data to/from an I2C address.
     * In case the I2C is stuck the method will abort after 1 second with a time-out error. 
     * Before transferring the byte the methods call private function \e i2c_wait_not_full()
     * in order to make sure that the I2C interface is not busy. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param dev_addr The address of the I2C device
     * @param byte The byte that is to be written to the I2C device
     */
    void i2c_write_byte( u_char dev_addr, u_char byte );
    
    /**
     * @param dev_addr The address of the I2C device 
     * @param reg_addr The register address inside the I2C device 
     * @param byte The byte that is to be written to the register in the I2C device
     */
    void i2c_write_byte( u_char dev_addr, u_char reg_addr, u_char byte );
    
    /**
     * @param dev_addr The address of the I2C device 
     * @param reg_addr The register address inside the I2C device to read from
     */
    u_char i2c_read_byte( u_char dev_addr, u_char reg_addr );
    
    /**
     * These methods read and write 8-bit data words from/to a I2C device.
     * 
     * @b Errors
     * In case of an error this method throws an exception.
     * @param *device_str A string of the form “p1:p2:p3:addr”: see table below for details.
     *                    Alternatively the string can be the name of the I2C endpoint device
     *                    You must use the predefined names: find out by running "wupper-i2c list"
     * @param reg_addr The address of the register within the device
     * @param data The data that is to be written to the register
     * @param value A pointer to a value that will be filled with the data read from the I2C device
     *
     * Description of the sub-parameters in parameter \e device_str:
     * | Sub-parameter | Description |
     * |---------------|--------------------------------------------------|
     * | p1            | The port number on the primary I2C switch to select; run "wupper-i2c list" to find out where the I2C device you want to access, is located in the I2C tree |
     * | p2            | In case of cascaded switches the secondary switch's port number to select |
     * | p3            | In case of cascaded switches this is the third switch's port number |  
     * | addr          | The I2C address of the endpoint device behind the switch(es) |
     *
     * As an alternative to a string of the format defined above, parameter \e device_str
     * can a symbolic name of an I2C endpoint device; get a listing of all available I2C devices
     * on all platforms by running "wupper-i2c list all".
     */
    void i2c_devices_read( const char *device_str, u_char reg_addr, u_char *value );
    
    /**
     * See i2c_devices_read() for details
     */
    void i2c_devices_write( const char *device_str, u_char reg_addr, u_char data );
     
    /**
     * @}
     */
     
     /**
     * \defgroup GBT GBT and transceiver related methods
     * @{
     * A set of functions dedicated to setting up GBT links.
     */
    
    /**
     * This method is used to initialize the GBT Wrapper registers, and to perform the TX and RX configuration. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param alignment Tx time domain crossing mode selection for each channel (GBT TX_TC_METHOD) 
     * @param channel_mode Set GBT mode (normal FEC or Wide-bus mode) for all channels.
     *                     (GBT_DATA_TXFORMAT, GBT_DATA_RXFORMAT) 
     */
    u_int gbt_setup( int alignment, int channel_mode );
    
    /**
     * This method is used to load the tx phase values from a file, for subsequent
     * configuration of the registers \e GBT_TX_TC_DLY_VALUE1 to \e GBT_TX_TC_DLY_VALUE4
     * before the GBT initialization. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param svn_version The current SVN (old) of GIT (new) version
     * @param filename The file to load the tx phase values from
     */
    long int gbt_version_delay( u_long svn_version, char *filename );
    
    /**
     * This function will select the channel through the register RXUSRCLK_FREQ_CHANNEL.
     * Then it will wait for the register RXUSRCLK_FREQ_VALID to go high,
     * indicating that the measurement is done. 
     * The return value will be read from RXUSRCLK_FREQ_VAL
     * and it represents the measured frequency in Hz.  
     * @b Errors 
     * In case of an error this method throws an exception;
     * if the functionality has not (yet) been implemented in the FPGA firmware, 
     * the function throws a TIMEOUT exception.
     * This also happens when a non-existing channel is selected.
     * @param channel The transceiver channel number on which the recovered receiver clock
     *                (rxusrclk) has to be measured
     * @param value Frequency of the recovered receiver clock of the selected channel in Hz
     */
    u_long get_rxusrclk_freq( u_int channel );
    
    /**
     * This method resets the GTH receivers. It method is meant for FULL mode F/W only. 
     * @param quad The quad to be reset; legal values are 0..5
     */
    void gth_rx_reset( int quad = -1 );

    /**
     * @}
     */

     /**
     * \defgroup Interrupt
     * @{
     * This section describes the interrupt handler (IRQ) related functions.
     */

    /**
     * This method enables one interrupt channel or all channels of one WUPPER card.
     * If called with interrupt set to the number of an interrupt
     * only this channel will be enabled.
     * If called with interrupt set to ALL_IRQS or if the interrupt parameter
     * is omitted, all channels of the given card will be enabled.
     *
     * This method calls a function of the wupper device driver.
     * @b Errors
     * In case of an error, this method throws an exception.
     * @param interrupt The number of the interrupt; legal values are 0..7 and ALL_IQRS
     */
    void irq_enable( u_int interrupt = ALL_IRQS );
    
    /**
     * This method disables one interrupt channel or all channels of one WUPPER card.
     * If called with interrupt set to the number of an interrupt
     * only this channel will be disabled.
     * If called with interrupt set to ALL_IRQS or if the interrupt parameter 
     * is omitted, all channels of the given card will be disabled. 
     * 
     * This method calls a function of the wupper device driver. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param interrupt The number of the interrupt; legal values are 0..7 and ALL_IRQS
     */
    void irq_disable( u_int interrupt = ALL_IRQS );
    
    /**
     * This method is blocking. It suspends the execution of a user application
     * until the interrupts of the number specified in 
     * interrupt has been received by the wupper driver. 
     * 
     * The waiting takes place in the driver. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be waited for
     */
    void irq_wait( u_int interrupt );
    
    /**
     * This method instructs the driver to clear unsolicited interrupts.
     * These are interrupts that may have been received by the driver
     * while no user application was waiting for them.
     * If the driver has received an unsolicited interrupt and irq_wait()
     * is called by an application without clearing the interrupt,
     * the application will continue immediately instead of waiting for an interrupt.  
     * 
     * As this method interferes with the interrupt flags of the device driver
     * it should only be called if no applications are waiting
     * for the interrupts specified in interrupt. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be cleared or ALL_IQRS
     *                  to clear all interrupts of that given card
     */
    void irq_clear( u_int interrupt = ALL_IRQS );
    
    /**
     * This method instructs the driver to cancel wait requests
     * for one particular interrupt or for all interrupts of one WUPPER card. 
     * It will therefore unblock applications that are waiting for an interrupt.
     * As the function is setting an internal flag of the 
     * driver in order to simulate an interrupt by S/W
     * it should only be called if an application is blocked. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be cancelled
     *                  or ALL_IQRS to cancel all interrupts of that given card
     */
    void irq_cancel( u_int interrupt = ALL_IRQS );
    
    /**
     * This method resets the counters of one or all interrupts of the given WUPPER card.
     * The counters count the number of times a given interrupt has been signalled.
     * Their values are shown in the file /proc/wupper. This method makes a call to the driver. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be reset
     *                  or ALL_IQRS to reset all interrupts of that given card
     */
    void irq_reset_counters( u_int interrupt = ALL_IRQS );
    
    /**
     * @}
     */
     
     /**
     * \defgroup REG Register and bitfield access
     * @{
     * A set of functions for looking up registers and bitfields by name (string)
     * and to get and set individual bitfields and full 64-bits registers, by name.
     */

    /**
     * This method reads the value of a bit field and returns its value as the value of the method.  
     * The method is only for the registers in BAR2.
     * For BAR0 and BAR1 register access use the bar0Address() and bar1Address() functions
     * and map the pointer to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param key A string with the name of the bit field
     * @param show_options If true displays (on standard output) a list of bitfield options
     *                     that match 'key' if a unique match was not found
     */
    u_long cfg_get_option( const char *key, bool show_options = false, int bar = 2);
    
    /**
     * This method writes a value to a bit field.
     * The method is only for the registers in BAR2. 
     * For BAR0 and BAR1 register access use the bar0Address() and bar1Address() functions
     * and map the pointer to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param *key A string with the name of the register or bit field 
     * @param value The value that is to be written to the register 
     * @param show_options If true displays (on standard output) a list of bitfield options
     *                     that match 'key', if a unique match was not found
     */
    void cfg_set_option( const char *key, u_long value, bool show_options = false, int bar = 2);
    
    /**
     * This method reads the value of a register or and returns its value as the value of the method.  
     * The method is only for the registers in BAR2.
     * For BAR0 and BAR1 register access use the bar0Address() and bar1Address() functions
     * and map the pointer to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param key A string with the name of the register
     */
    u_long cfg_get_reg( const char *key, int bar = 2 );

    /**
     * This method writes a value to a register.
     * The method is only for the registers in BAR2. 
     * For BAR0 and BAR1 register access use the bar0Address() and bar1Address() functions
     * and map the pointer to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method throws an exception.
     * @param *key A string with the name of the register or bit field 
     * @param value The value that is to be written to the register 
     */
    void cfg_set_reg( const char *key, u_long value, int bar = 2 );
    
    /**
     * This method sets the REGISTERS_RESET register to “1”.
     * This causes all registers in the BAR2 area to be reset to their power-on default values. 
     * The registers in BAR0 and BAR1 will keep their values.
     */
    void registers_reset();

    /**
     * This method returns a pointer to a `regmap_register_t` struct in the array of these structs
     * describing all the FELIX registers. Internally used by cfg_get_reg() and cfg_set_reg().
     * @param name The string containing the register name:
     *             is case-insensitive and '_' characters may be replaced by '-'
     */
    static regmap_register_t *cfg_register( const char *name, int bar = 2 );
    /**
     * This method returns a pointer to a `regmap_bitfield_t` struct in the array of these structs
     * describing all the FELIX register bitfield. Internally used by cfg_get_option() and cfg_set_option().
     * @param name The string containing the bitfield name:
     *             is case-insensitive and '_' characters may be replaced by '-'
     */
    static regmap_bitfield_t *cfg_bitfield( const char *name, int bar = 2 );
    /**
     * This method compiles and returns a string containing a list of register bitfield names
     * that match the given name, meaning that string 'name' is either a substring of the full bitfield name
     * or that the full bitfield name starts with 'name'.
     * Internally used by cfg_get_option() and cfg_set_option().
     * @param name The string with the name substring:
     *             is case-insensitive and '_' characters may be replaced by '-'
     * @param include_all_substr If false only bitfield names that start with the given substring
     *                           are returned, if true names are returned that contain the substring
     *                           anywhere in their name
     */
    static std::string cfg_bitfield_options( const char *name, bool include_all_substr = true, int bar = 2 );

    /**
     * @}
     */
     
     /**
     * \defgroup Tools
     * @{
     * A set of functions that can mostly be described as methods that interact with the card or device endpoint.
     */
    /**
     * This method determines the H/W type of the WUPPER card.
     * Currently 5 types are supported: WUPPER_709, WUPPER_710, WUPPER_711, WUPPER_712 and WUPPER_128
     * @return integer value of the card model, defined in WUPPER_709 etc.
     */
    int card_model();
    
    /**
     * This method sets the SOFT_RESET register in BAR0 to "1".  
     * 
     * @b Errors
     * In case of an error this method throws an exception.
     */
    void soft_reset();
    
    /**
     * This method retrieves monitoring data about the devices of the WUPPER card (FPGA, MiniPODs & LTCs),
     * like temperatures, currents, voltages or status bits.
     * The device_mask is defined as followed: 
     * - FPGA_MONITORING Retrieve information about the FPGA 
     * - POD_MONITORING  Retrieve information about the (upto 8) MiniPODs 
     * - LTC_MONITORING  Retrieve information about the 2 LTCs 
     * The method returns a structure of type `monitoring_data_t`.
     * See WupperCard.h for the organisation of the data and the names of the parameters. 
     * See application wupper-info.cpp for an example of decoding the structure. 
     * Note: It is likely that additional parameters will be added in the future. 
     * 
     * @b Errors 
     * In case of an error, this method throws an exception.
     * @param device_mask A mask of (currently) 3 bits to select the devices to be monitored 
     * @return The method returns a structure of type `monitoring_data_t`.
     */
    monitoring_data_t get_monitoring_data( u_int device_mask );
    
    /**
     * @return Number of physical links connected to the PCIe endpoint.
     * 
     **/
    u_int number_of_channels();

    /**
     * @}
     */
     
private:
    static int                      m_cardsOpen;
    int                             m_fd;
    int                             m_deviceNumber;
    int                             m_maxTlpBytes;
    int                             m_cardModel;
    u_long                          m_physStartAddressCmemBuf;
    u_long                          m_virtStartAddressCmemBuf;
    u_int                           m_myLocks;
    u_int                           m_myLockTag;  //MJ: do we still need the lock tag??
    u_long                          m_bar0Base;
    u_long                          m_bar1Base;
    u_long                          m_bar2Base;

public:
    /** @} */
    /** \defgroup MemberVariables Public member variables 
     * @{  
     * Public member variables of class WupperCard.
     */
    volatile wuppercard_bar0_regs_t    *m_bar0;
    volatile wuppercard_bar1_regs_t    *m_bar1;
    /**
     * @}
     */

private:    
    u_long map_memory_bar( u_long pci_addr, size_t size );
    void   unmap_memory_bar( u_long vaddr, size_t size );

    void   i2c_wait_not_full( );
    void   i2c_wait_not_empty( );
    int    i2c_parse_address_string( const char *str,
                                     u_char *port1, u_char *port2, u_char *port3,
                                     u_char *dev_addr );
    void   i2c_set_switches( u_char switch1_val, u_char switch2_val, u_char switch3_val );

    void   gbt_tx_configuration( int channel_tx_mode, int alignment );
    int    gbt_rx_configuration( int channel_rx_mode );
    int    gbt_software_alignment( int number_channels );
    int    gbt_channel_alignment( u_int channel );
    void   gbt_topbot_oddeven_set( u_int topbot, u_int oddeven, u_int ch );
    int    gbt_topbot_1_alignment( u_int ch, u_long *phase_found, u_int *oddeven_flag );
    int    gbt_topbot_0_alignment( u_int ch, u_long *phase_found, u_int *oddeven_flag );
    u_long gbt_shift_phase( u_int ch );

    int    check_digic_value2( const char *str, u_long *version, u_long *delay );
};


#endif // WUPPERCARD_H
