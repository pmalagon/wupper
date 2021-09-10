/******************************************************************* 
 * \mainpage                                                       * 
 * This is the header file for the WupperCard object                  * 
 *                                                                 * 
 * @author: Markus Joos, CERN <Markus.Joos@cern.ch>                *
 *  +41 22 767 2364                                                * 
 *                                                                 *
 * @brief                                                          *
 * This note defines an application program interface (API) for    *
 * the use of the WUPPER PCIe I/O card in the ATLAS read-out system.  *
 * The intention of the API is to satisfy the needs of simple      *
 * test programs as well as the requirements of the                *
 * FelixApplication.                                               *
 *                                                                 *
 * @copyright  2015 Ecosoft - Made from at least 80%               *
 * recycled source code                                            *
 ******************************************************************/ 


#ifndef WUPPERCARD_H
#define WUPPERCARD_H

#include <sys/types.h>
#include "cmem_rcc/cmem_rcc.h"
#include "wuppercard/wupper_common.h"

#include "regmap/regmap.h"

//Constants
#define BAR0MAPSIZE                       0x500
#define BAR1MAPSIZE                       0x200
#define BAR2MAPSIZE                       0x8000
#define WAIT_TIME                         600
#define NUM_INTERRUPTS                    8
#define MICRO_WAIT_TIME                   200
#define WUPPER_DMA_WRAPAROUND                1
#define WUPPER_CFG_ERROR_NOT_WRITABLE        2
#define WUPPER_CFG_ERROR_NOT_WRITABLE        2
#define WUPPER_CFG_ERROR_NOT_READABLE        1

//Board models
#define WUPPER_712                           712
#define WUPPER_711                           711
#define WUPPER_710                           710
#define WUPPER_709                           709
#define WUPPER_128                           128

//I2C definitions
#define I2C_ADDR_SWITCH1_WUPPER_711          0x70
#define I2C_ADDR_SWITCH1_WUPPER_710          0x70
#define I2C_ADDR_SWITCH1_WUPPER_709          0x74
#define I2C_ADDR_SWITCH2_WUPPER_709          0x75
#define I2C_ADDR_SWITCH1_WUPPER_128          0x74
#define I2C_ADDR_SWITCH2_WUPPER_128          0x75
#define I2C_ADDR_SWITCH3_WUPPER_128          0x76
#define I2C_ADDR_CXP                      0x6e
#define I2C_ADDR_ADN                      0x40
#define I2C_FULL_FLAG                     (1 << 25)
#define I2C_EMPTY_FLAG                    (1 << 8)
#define I2C_DELAY                         1000
#define I2C_SLEEP                         100
#define I2C_SWITCH_CXP1                   (1 << 2)
#define I2C_SWITCH_CXP2                   (1 << 3)
#define I2C_SWITCH_ADN                    (1 << 4)

//I2C error codes
#define I2C_DEVICE_ERROR_NOT_EXIST        1
#define I2C_DEVICE_ERROR_INVALID_PORT     2
#define I2C_DEVICE_ERROR_INVALID_ADDRESS  3
#define I2C_DEVICE_ERROR_INVALID_REGISTER 4
#define I2C_DEVICE_ERROR_INVALID_DATA     5

//SPI
#define SPI_FULL_FLAG                     (1ul << 32)
#define SPI_EMPTY_FLAG                    (1ul << 32)
#define SPI_DELAY                         2000
#define SPI_SLEEP                         500

//Interrupts
#define ALL_IRQS                          0xffffffff

//Monitoring devices
#define FPGA_MONITORING                   1
#define POD_MONITORING                    2
#define LTC_MONITORING                    4

//Resource locking
#define LOCK_NONE                         0
#define LOCK_DMA0                         1
#define LOCK_DMA1                         2
#define LOCK_I2C                          4
#define LOCK_FLASH                        8
#define LOCK_ELINK                        16
#define LOCK_ALL                          0xffffffff

//Other constants
#define ALL_BITS                          0xffffffffffffffff


//Register model
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
  dma_descriptor_t DMA_DESC[8];	        /* 0x000 - 0x0ff */
  u_char           unused1[256];        /* 0x100 - 0x1ff */
  dma_status_t     DMA_DESC_STATUS[8];  /* 0x200 - 0x27f */
  u_char           unused2[128];	/* 0x280 - 0x2ff */
  volatile u_int   BAR0_VALUE;		/* 0x300 - 0x303 */
  u_char           unused3[12];		/* 0x304 - 0x30f */
  volatile u_int   BAR1_VALUE;		/* 0x310 - 0x313 */
  u_char           unused4[12];		/* 0x314 - 0x31f */
  volatile u_int   BAR2_VALUE;		/* 0x320 - 0x323 */
  u_char           unused5[220];	/* 0x324 - 0x3ff */
  volatile u_int   DMA_DESC_ENABLE;	/* 0x400 - 0x403 */
  u_char           unused6[12];	        /* 0x404 - 0x40f */
  volatile u_int   DMA_FIFO_FLUSH;	/* 0x410 - 0x413 */
  u_char           unused7[12];	        /* 0x414 - 0x41f */
  volatile u_int   DMA_RESET;           /* 0x420 - 0x423 */
  u_char           unused8[12];	        /* 0x424 - 0x42f */
  volatile u_int   SOFT_RESET;          /* 0x430 - 0x433 */
  u_char           unused9[12];	        /* 0x434 - 0x43f */
  volatile u_int   REGISTERS_RESET;     /* 0x440 - 0x443 */
} wuppercard_bar0_regs_t;


typedef struct
{
  int_vec_t        INT_VEC[8];		/* 0x000 - 0x07f */
  u_char           unused1[128];	/* 0x080 - 0x0ff */
  volatile u_int   INT_TAB_ENABLE;	/* 0x100 - 0x103 */
} wuppercard_bar1_regs_t;


typedef struct spi_device
{
  const char *name;
  const char *description;
  u_char address;
} spi_device_t;


typedef struct
{
  const char *name;
  const char *description;
  u_char address;
  const char *port;
} i2c_device_t;

typedef struct
{
  float temperature;
  float vccint;
  float vccaux;
  float vccbram;
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
  char name[10];
  int temp;
  float v33;
  float v25;
  int los;
  char vname[16];
  char voui[3];
  char vpnum[16];
  char vrev[2];
  char vsernum[16];
  char vdate[8];
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
  float	MGTAVTT_current;         //Only WUPPER-712   
  float	MGTAVTT_voltage;         //Only WUPPER-712   
  float	MGTAVTTC_voltage;        //Only WUPPER-711
  float	MGTVCCAUX_voltage;       //Only WUPPER-711
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
  u_int                  n_pods;
  ltc1_parameters_t      ltc1;
  ltc2_parameters_t      ltc2;
} monitoring_data_t;


//Macros
#define HEX(n) std::hex << n << std::dec

//External declarations          //MJ: review
extern i2c_device_t     i2c_devices_WUPPER_709[];
extern i2c_device_t     i2c_devices_WUPPER_710[];
extern i2c_device_t     i2c_devices_WUPPER_711[];
extern i2c_device_t     i2c_devices_WUPPER_128[];
extern spi_device_t     spi_devices[];


class WupperCard
{
public:
    /// The constructor of a WupperCard object only initializes a few class variables. It does not interact with the FELIX H/W at all.
    WupperCard();
    
    /**
     * \defgroup DriverInteraction Driver interaction 
     * @{
     * @details This group of methods interact with the driver, there are methods to open the API for instance, but also to open an alternative
     * (backdoor) way to reading and writing the registers by memory-mapping a struct directly on the register map (BAR).
     */
    /**
     *  @b Description
     *  This method opens the \e wupper \e driver and links one Wupper PCIe card to the WupperCard object. 
     *  This method has to be called before any other reference to the method is made. 
     *  In case of problems, check (more /proc/wupper) if the driver is running and if it can see all cards. 
     *  The method also checks if the major version of the register map of the F/W running on the WUPPER card 
     *  matches with the version of the “regmap” library. This is to prevent running the API on incompatible WUPPER cards. 
     * 
     *  @b Resource locking
     *  The WUPPER cards contain a number of resources that cannot be shared by multiple processes. The purpose of the 
     *  resource locking bits is to allow a process to declare to the driver that it requires exclusive access to such a
     *  resource. If a resource is locked by on process, the driver will reject other processes that request access to
     *  the same resource. In such a case card_open() will throw an exception. The parameter lock_mask passes a collection
     *  of bits to the driver. These bits are defined in WupperCard.h. Currently these resources are defined:  
     *
     *      #define LOCK_DMA0    1 
     *      #define LOCK_DMA1    2 
     *      #define LOCK_I2C     4 
     *      #define LOCK_FLASH   8 
     *      #define LOCK_ELINK   16 
     *      #define LOCK_ALL     0xffffffff 
     *
     *  Example: To lock access to DMA1 and the FLASH memory of the first WUPPER-711 card: 
     * 
     *      card_open(0, LOCK_DMA1 | LOCK_FLASH) 
     *  The lock will be held until the owning process calls card_close(). If a process terminates with an error the driver will
     *  release the resources that were locked by that process. Users can find an overview of what resources are locked by
     *  looking at the content of \e /proc/wupper \e . 
     *  Processes that do not request any locks still have full access to the respective resources. That is to say that a
     *  process that does not lock DMA1 still can call the DMA related methods of the API.  
     *  The method get_lock_mask can be called to figure out what resources are locked. This was done on purpose because
     *  the application programmers know best if their applications (for example for diagnostic purposes) should be able to run even
     *  if a resource is locked. Consequently, the application programmers bear the responsibility for using the resource locking
     *  in a correct way.  
     * 
     *  @b Errors
     *  In case of an error, this method will throw an exception. 
     *  @param n The number of the WUPPER card (0…N-1) that is to be linked to the object 
     *  @param lock_mask The resources that are to be locked 
     **/
    void card_open(int n, u_int lock_mask);
    
    /**
     * This method unlinks a Wupper PCIe card. It must be called before closing the application 
     * 
     * @b Errors
     * In case of an error this method will throw an exception
     */
    void card_close(void);
    
    /**
     * This method returns the number of WUPPER cards that are installed in the host computer. 
     * As it is a static method you do not have to instantiate a WupperCard object for calling it.
     * @b Errors 
     * In case of an error the method will not throw an exception but return “0”. Therefore “zero cards found” can also mean that: 
     * - the wupper driver was not running 
     * - the device node /dev/wupper was missing 
     * - the "GETCARDS" ioctl of the wupper driver did not work
     */
    static u_int number_of_cards(void);
    
    /**
     * This method returns information about the resources that are currently locked by other instances of WupperCard objects. 
     * It does not matter if these objects are in the same or in different processes. In addition, the bit mask that is 
     * returned to the users will only reflect the resources of the WUPPER card that is represented by the local object instance.
     * The individual lock bits are declared in WupperCard.h
     * 
     * Example: 
     *     WupperCard wuppercard; 
     *     u_int lock_bits = wuppercard.get_lock_mask(); 
     *     if (lock_mask & LOCK_DMA1) 
     *       cout << “DMA1 is locked by another object”
     * 
     * @b Note
     * In order to avoid a circular dependency on the locking bits, this method can be called at any time; even before the first call to WupperCard::open_card().
     * 
     * @b Errors
     * In case of an error, this method will throw an exception.
     */
    u_int get_lock_mask(int n);
    
    /**
     * This method returns the PCI base address of the specified PCI register block.
     * @param bar The number of a BAR register block. Legal values are 0, 1 or 2. 
     * @return the PCI base address of the specified PCI register block.
     */
    u_long openBackDoor(int bar);
    /** @}*/
    
    /**
     * \defgroup DMA
     * @{
     * @details This group of methods is meant to setup, start and stop DMA transfers and to interact with the circular buffer PC pointers.
     */
    /**
     * This method calls the wupper driver in order to determine the maximum number of TLP bytes that the H/W can support. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     */
    int  dma_max_tlp_bytes(void);
    
    /**
     * This method first stops the DMA channel identified by dma_id. It does not check if the channel is busy. Then it programs the channel and starts a new DMA write transaction. 
     * 
     * Note: The bits 10:0 of the DMA descriptor (bitfield NUM_WORDS in the Wupper documentation) will be set to the maximum TLP size supported by the system. Therefore, the transfer size has to be a multiple of that value. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7 
     * @param dst The value for the start_address field of the descriptor. NOTE: You have to provide a physical (PCI) address 
     * @param size The size of the transfer in bytes 
     * @param flags The value for the wrap_around filed of the descriptor. "1" means: enable wrap around 
     */
    void dma_to_host(u_int dma_id, u_long dst, size_t size, u_int flags);
    
    /**
     * This method first stops the DMA channel identified by dma_id. It does not check if the channel is busy. Then it programs the channel and starts a new DMA read transaction. 
     * 
     * Note: The size of the transfer has to be a multiple of 32 bytes. 
     * 
     * The method internally computes the optimal value for the bits 10:0 of the DMA descriptor (bitfield NUM_WORDS in the Wupper documentation).  
     * 
     * The algorithm used is this: 
     *     1. if transfersize % 32 != 0: error("number of bytes transferred must be a multiple of 32") 
     *     2. tlp = get_max_tlp() 
     *     3. if transfersize % tlp == 0: do transfer 
     *     4. else: tlp = tlp >> 1 && goto 3
     * 
     * @b Errors
     * In case of an error this method will throw an exception.
     * 
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7 
     * @param src The value for the start_address filed of the descriptor NOTE: You have to provide a physical (PCI) address 
     * @param size The size of the transfer in bytes 
     * @param flags The value for the wrap_around filed of the descriptor. “1” means: enable wrap around 
     */
    void dma_from_host(u_int dma_id, u_long src, size_t size, u_int flags);
    
    /**
     * This method is blocking. It returns once the DMA on channel dma_id has ended. The method has an internal (hard wired) time out of 1 second. 
     * 
     * @b Errors 
     * In case the DMA has not ended after 1 second this method will throw an exception.
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7
     */
    void dma_wait(u_int dma_id);
    
    /**
     * This method clears the DMA channel identified by dma_id. It does not check the status of that channel.
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7
     */
    void dma_stop(u_int dma_id);
    
    /**
     * Advances the internal read pointer of the DMA channel by the number of bytes given. This is used when operating the DMA engine 
     * in "endless DMA" / "circular buffer" mode. This method is to be called by the user after processing data at the head of the 
     * circular buffer to free the buffer for DMA writes or reads of the WUPPER card again. 
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7 
     * @param dst See below NOTE: You have to provide a physical (PCI) address 
     * @param size If the value of the read_ptr filed, after adding bytes is larger than dst + size, size will be subtracted from read_ptr. 
     * @param bytes This value will be added to the read_ptr filed of the DMA descriptor 
     */
    void dma_advance_ptr(u_int dma_id, u_long dst, size_t size, size_t bytes);
    
    /**
     * This method directly writes the read pointer of a DMA channel.
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7 
     * @param dst The read pointer register of the DMA channel will be set to the values in dst 
     */
    void dma_set_ptr(u_int dma_id, u_long dst);
    
    /**
     * This method returns the current value of the RD_POINTER. That is to say the bits 127:64 of the DMA_DESC_[0..7]a as defined in the
     * <a href="https://gitlab.cern.ch/atlas-tdaq-felix/documents/blob/master/Wupper/wupper.pdf">Wupper</a> documentation. 
     * @param dma_id The DMA channel (descriptor) to be used. Valid numbers are 0..7
     */
    u_long dma_get_read_ptr(u_int dma_id);
    
    /**
     * This method sets the DMA_FIFO_FLUSH register to "1".
     */
    void dma_fifo_flush(void);
    
    /**
     * This method sets the DMA_RESET register to "1".
     */
    void dma_reset(void);
    
    /**
     * This method reads the status register of a DMA descriptor (i.e. one of the DMA_DESC_STATUS_* registers) and returns the value of the CURRENT_ADDRESS bit field (bits 63:0).
     * @param dma_id The DMA channel (descriptor) to be queried. Valid numbers are 0..7
     */
    u_long dma_get_current_address(u_int dma_id);
    
    /**
    * This method reads the \e even_addr_dma \e and \e even_pc_dma \e bits of a DMA channel and compares them. 
    * @param dma_id: The DMA channel (descriptor) to be used. Valid numbers are 0..7 
    * @return It returns \e true \e if the bits have the same value and \e false \e if not.
    */
    bool dma_cmp_even_bits(u_int dma_id);

    /**
     * @}
     */
     
    /**
     * \defgroup I2C
     * @{
     * @details A group of functions to interact with the I2C bus on the board.
     */
        
    /**
     * These methods read or write one byte of data to / from an I2C address. In case the I2C is stuck the method will abort after 1 second with a time-out error. 
     * Before transferring the byte the methods call i2c_wait_not_full() in order to make sure that the I2C interface is not busy. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param slave_addr The address of the I2C slave device 
     * @param addr The register address inside the I2C slave device 
     * @param byte The byte that is to be written to the I2C slave 
     */
    void i2c_write_byte(u_char slave_addr, u_char byte);
    
    /**
     * See i2c_write_byte
     * @param slave_addr The address of the I2C slave device 
     * @param addr The register address inside the I2C slave device 
     * @param byte The byte that is to be written to the I2C slave 
     */
    void i2c_write_byte_to_addr(u_char slave_addr, u_char addr, u_char byte);
    
    /**
     * See i2c_write_byte
     * @param slave_addr The address of the I2C slave device 
     * @param addr The register address inside the I2C slave device 
     * @param byte The byte that is to be written to the I2C slave 
     */
    u_char i2c_read_byte(u_char slave_addr, u_char addr);
    
    /**
     * These methods read and write 8bit data words from / to a I2C device. 
     * Description of the sub-parameters "device" 
     * | Sub-parameter | Description                                                                                                                                                     |
     * |---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
     * | p1            | This is the port number on the primary I2C switch. Run “WupperI2c list” in order to find out how the I2C device that you want to access is linked to the I2C tree. |  
     * | p2            | In case of cascaded switches this is the secondary port number.                                                                                                 |  
     * | add           | This is the I2C address of the endpoint device behind the switch                                                                                                |  
     * Alternatively to a string of the format defined above *device can be set to the symbolic name of an I2C endpoint device; for example “CLOCK_RAM”. See also chapter 3 for additional detail. 
     * The chart below shows (to the curious expert) the interdependencies of the public and private methods that deal with I2C.
     * @image html images/i2c_doxygen.svg
     * @image latex images/i2c_doxygen.pdf width=\textwidth
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param *device The "device" is a string of the form “p1:p2:p3:add” with: See table below for details. Alternatively the string can be the name of the I2C endpoint device. 
     *   You must only use the names that are defined in the i2c_devie_t structures in WupperCard.cpp 
     * @param reg_addr The address of the register within the device 
     * @param data The data that is to be written to the register 
     * @param value A pointer to a value that will be filled with the data read from the I2C device 
     */
    void i2c_devices_read(const char *device, u_char reg_addr, u_char *value);
    
    /**
     * See i2c_devices_read for details
     */
    void i2c_devices_write(const char *device, u_char reg_addr, u_char data);
     
    
    /**
     * This function will select the channel through the register RXUSRCLK_FREQ_CHANNEL. Then it will wait for 
     * the register RXUSRCLK_FREQ_VALID to go high, indicating that the measurement is done. 
     * The return value will be read from RXUSRCLK_FREQ_VAL and it represents the measured frequency in Hz.  
     * @b Errors 
     * In case of an error this method will throw an exception, if the functionality has not (yet) been implemented in the FPGA firmware, 
     * the function will throw a TIMEOUT exception. This also happens when a non-existing channel is selected.
     * @param channel The transceiver channel number on which the recovered receiver clock (rxusrclk) has to be measured
     * @param value Frequency of the recovered receiver clock of the selected channel in Hz
     */
    u_long get_rxusrclk_freq(u_int channel);
    
    /**
     * This method resets the GTH receivers. It is meant for FULL mode F/W only. 
     */
    void gth_rx_reset(void);

    /**
     * @}
     */
     
     /**
     * \defgroup Interrupt
     * @{
     * @details All Interrupt handler (IRQ) related methods are described in this section.
     */

    /**
     * This method enables one interrupt channel or all channels of one WUPPER card. If called with interrupt set to the number of 
     * an interrupt only this channel will be enabled. If called with interrupt set to ALL_IRQS or if the interrupt parameter is
     * omitted, all channels of the given card will be enabled. 
     * 
     * This method calls a function of the wupper device driver. 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param interrupt The number of the interrupt. Legal values are 0..7 and ALL_IQRS
     */
    void irq_enable(u_int interrupt = ALL_IRQS);
    
    /**
     * This method disables one interrupt channel or all channels of one WUPPER card. If called with interrupt set to the number 
     * of an interrupt only this channel will be disabled. If called with interrupt set to ALL_IRQS or if the interrupt parameter 
     * is omitted, all channels of the given card will be disabled. 
     * 
     * This method calls a function of the wupper device driver. 
     * 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param interrupt The number of the interrupt. Legal values are 0..7 and ALL_IQRS 
     */
    void irq_disable(u_int interrupt = ALL_IRQS);
    
    /**
     * This method is blocking. It suspends the execution of a user application until the interrupts of the number specified in 
     * interrupt has been received by the wupper driver. 
     * 
     * The waiting takes place in the driver. 
     * 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be waited for. 
     */
    void irq_wait(u_int interrupt);
    
    /**
     * This method instructs the driver to clear unsolicited interrupts. These are interrupts that may have been received by the 
     * driver while no user application was waiting for them. If the driver has received an unsolicited interrupt and irq_wait() 
     * is called by an application without clearing the interrupt, the application will continue immediately instead of waiting 
     * for an interrupt.  
     * 
     * As this method interferes with the interrupt flags of the device driver it should only be called if no applications are 
     * waiting for the interrupts specified in interrupt. 
     * 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be cleared or ALL_IQRS to clear all interrupts of that given card.
     */
    void irq_clear(u_int interrupt = ALL_IRQS); 
    
    /**
     * This method instructs the driver to cancel wait requests for one particular interrupt or for all interrupts of one WUPPER card. 
     * It will therefore unblock applications that are waiting for an interrupt. As the function is setting an internal flag of the 
     * driver in order to simulate an interrupt by S/W it should only be called if an application is blocked. 
     * 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be cancelled or ALL_IQRS to cancel all interrupts of that given card.
     */
    void irq_cancel(u_int interrupt = ALL_IRQS);
    
    /**
     * This method resets the counters of one or all interrupts of the given WUPPER card. The counters count the number of times a given 
     * interrupt has been signalled. Their values are shown in the file /proc/wupper. This method makes a call to the driver. 
     * 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param interrupt The number (0..7) of the interrupt that is to be reset or ALL_IQRS to reset all interrupts of that given card.
     */
    void irq_reset_counters(u_int interrupt = ALL_IRQS);
    
    /**
     * @}
     */
     
     /**
     * \defgroup REG Register and bitfield access
     * @{
     * @details WupperCard has a way of looking up registers by name (string). The functions to get and set bitfields and complete 64b registers by name are 
     * described here.
     */
    /**
     * This method reads the value of a bit field and returns its value as the value of the method.  
     * The method is only recommended for use with the registers in BAR2. For BAR0 and BAR1 use the WupperCard::openBackDoor() and map the pointer 
     * to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param key A string with the name of the bit field
     */
    u_long cfg_get_option(const char *key, int bar = 2);
    
    /**
     * This method reads the value of a register or and returns its value as the value of the method.  
     * The method is only recommended for use with the registers in BAR2. For BAR0 and BAR1 use the WupperCard::openBackDoor() and map the pointer 
     * to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param key A string with the name of the register
     */
    u_long cfg_get_reg(const char *key, int bar = 2);
    
    /**
     * This method writes a value to a bit field. The method is only recommended for use with the registers in BAR2. 
     * For BAR0 and BAR1 use the WupperCard::openBackDoor() and map the pointer to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param *key A string with the name of the register or bit field 
     * @param value The value that is to be written to the register 
     */
    void cfg_set_option(const char *key, u_long value, int bar = 2);
    
    /**
     * This method writes a value to a register. The method is only recommended for use with the registers in BAR2. 
     * For BAR0 and BAR1 use the WupperCard::openBackDoor() and map the pointer to the respective structure from WupperCard.h. 
     * 
     * @b Errors 
     * In case of an error this method will throw an exception.
     * @param *key A string with the name of the register or bit field 
     * @param value The value that is to be written to the register 
     */
    void cfg_set_reg(const char *key, u_long value, int bar = 2);
    
    /**
     * This method sets the REGISTERS_RESET register to “1”. This causes all registers in the BAR2 area to be reset to their power-on default values. 
     * The registers in BAR0 and BAR1 will keep their values.
     */
    void registers_reset(void);

    /**
     * @}
     */
     
     /**
     * \defgroup Tools
     * @{
     * @details This group of methods can mostly be described as methods that interact with the card or device endpoint.
     */
    /**
     * This method determines the H/W type of the WUPPER card. Currently 5 types are supported: WUPPER_709, WUPPER_710, WUPPER_711, WUPPER_712 and WUPPER_128
     * @return integer value of the card model, defined in WUPPER_709 etc.
     */
    int card_model(void);
    
    /**
     * This method sets the SOFT_RESET register in BAR0 to "1".  
     * 
     * @b Errors
     * In case of an error this method will throw an exception.
     */
    void soft_reset(void);
    
    /**
     * This method retrieves monitoring data about the devices of the WUPPER card (FPGA, MiniPODs & LTCs), like temperatures, currents, 
     * voltages or status bits. The device_mask is defined as followed: 
     * - FPGA_MONITORING Retrieve information about the FPGA 
     * - POD_MONITORING Retrieve information about the 8 MiniPODs 
     * - LTC_MONITORING Retrieve information about the 2 LTCs 
     * The method returns a structure of type moitoring_data_t. See WupperCard.h for the organisation of the data and the names of the parameters. 
     * The application wupper-monitor.cpp can be used as an example for decoding the structure. 
     * Note: It is likely that additional parameters will be added in the future. 
     * 
     * @b Errors 
     * In case of an error, this method will throw an exception.
     * @param device_mask A mask of (currently) 3 bits to select the devices to be monitored 
     * @return The method returns a structure of type moitoring_data_t.
     */
    monitoring_data_t get_monitoring_data(u_int device_mask);
    
    /** @} */
    /** \defgroup ObjectVariables Public Object Variables 
     * @{  
     * @details WupperCard contains a set of public variables.
     */
    static int                      m_cards_open;
    int                             m_fd;
    int                             m_slotNumber;
    int                             m_maxTLPBytes;
    int                             m_fd_cmem;
    int                             m_card_model;
    card_params_t                   m_cardData;
    u_long                          m_Bar_0_Base;
    u_long                          m_Bar_1_Base;
    u_long                          m_Bar_2_Base;
    volatile wuppercard_bar0_regs_t    *m_bar0;
    volatile wuppercard_bar1_regs_t    *m_bar1;
    u_long                          m_physStartAddressCmemBuf;
    u_long                          m_virtStartAddressCmemBuf;
    u_int                           m_lastHandle;
    bool                            verboseFlag;
    u_int                           m_my_locks;
    u_int                           m_my_lock_tag;  //MJ: do we still need the lock tag??
    
    /**
     * @}
     */

private:
    void i2c_wait_not_full(void);
    void i2c_wait_not_empty(void);
    void i2c_write(u_char port1, u_char port2, u_char port3, u_char device, u_char reg, u_char data);
    u_char i2c_read(u_char port1, u_char port2, u_char port3, u_char device, u_char reg);
    int i2c_parse_address(const char *str, u_char *port1, u_char *port2, u_char *port3, u_char *address);

    int check_digic_value2(const char *str, u_long *version, u_long *delay);

    void str_upper(char *str);

    void eeprom_selection(char *eeprom);
    u_long map_memory_bar(u_long pci_addr, size_t size);
    void unmap_memory_bar(u_long vaddr, size_t size);
};


#endif // WUPPERCARD_H
