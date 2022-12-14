/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* DO NOT EDIT THIS FILE */
/*  */
/* This file was generated from template '../software/regmap/src/regmap-struct.h.template' */
/* and register map registers-2.0.yaml, version 2.0 */
/* by the script 'wuppercodegen', version: 0.8.4, */
/* using the following commandline: */
/*  */
/* ../software/wuppercodegen/wuppercodegen/cli.py registers-2.0.yaml ../software/regmap/src/regmap-struct.h.template ../software/regmap/regmap/regmap-struct.h */
/*  */
/* Please do NOT edit this file, but edit the source file at '../software/regmap/src/regmap-struct.h.template' */
/*  */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */


#ifndef REGMAP_STRUCT_H
#define REGMAP_STRUCT_H

#ifdef __KERNEL__
  #include <linux/types.h>
#else
  #include <sys/types.h>
#endif

#include "regmap/regmap-common.h"

#ifdef __cplusplus
extern "C" {
#endif

#pragma GCC diagnostic ignored "-Wpedantic"

/**************************************/
/* Bitfields                          */
/**************************************/

typedef struct
{
  volatile u_long DESCRIPTORS              :  8;  /* bits   7: 0 */
  volatile u_long INTERRUPTS               :  8;  /* bits  15: 8 */
} wuppercard_generic_constants_t;

typedef struct
{
  volatile u_long READ_NOT_WRITE           :  1;  /* bits   0: 0 */
  volatile u_long SLAVE_ADDRESS            :  7;  /* bits   7: 1 */
  volatile u_long DATA_BYTE1               :  8;  /* bits  15: 8 */
  volatile u_long DATA_BYTE2               :  8;  /* bits  23:16 */
  volatile u_long WRITE_2BYTES             :  1;  /* bits  24:24 */
  volatile u_long I2C_FULL                 :  1;  /* bits  25:25 */
} wuppercard_i2c_wr_t;

typedef struct
{
  volatile u_long I2C_DOUT                 :  8;  /* bits   7: 0 */
  volatile u_long I2C_EMPTY                :  1;  /* bits   8: 8 */
} wuppercard_i2c_rd_t;

typedef struct
{
  volatile u_long IRQ                      :  4;  /* bits   3: 0 */
} wuppercard_int_test_t;

typedef struct
{
  volatile u_long TOHOST_BUSY              :  1;  /* bits   0: 0 */
  volatile u_long FROMHOST_BUSY            :  1;  /* bits   1: 1 */
  volatile u_long FROMHOST_BUSY_LATCHED    :  1;  /* bits   2: 2 */
  volatile u_long TOHOST_BUSY_LATCHED      :  1;  /* bits   3: 3 */
  volatile u_long ENABLE                   :  1;  /* bits   4: 4 */
} wuppercard_dma_busy_status_t;

typedef struct
{
  volatile u_long ADDRESS                  : 32;  /* bits  31: 0 */
  volatile u_long WRITE_NOT_READ           :  1;  /* bits  32:32 */
} wuppercard_wishbone_control_t;

typedef struct
{
  volatile u_long DATA                     : 32;  /* bits  31: 0 */
  volatile u_long FULL                     :  1;  /* bits  32:32 */
} wuppercard_wishbone_write_t;

typedef struct
{
  volatile u_long DATA                     : 32;  /* bits  31: 0 */
  volatile u_long EMPTY                    :  1;  /* bits  32:32 */
  volatile u_long TRIGGER                  :  1;  /* bits  33:33 */
} wuppercard_wishbone_read_t;

typedef struct
{
  volatile u_long ERROR                    :  1;  /* bits   0: 0 */
  volatile u_long ACKNOWLEDGE              :  1;  /* bits   1: 1 */
  volatile u_long STALL                    :  1;  /* bits   2: 2 */
  volatile u_long RETRY                    :  1;  /* bits   3: 3 */
  volatile u_long INT                      :  1;  /* bits   4: 4 */
} wuppercard_wishbone_status_t;



/**************************************/
/* Structs for arrays                 */
/**************************************/




/**************************************/
/* Main struct                        */
/**************************************/

typedef struct
{
/* Bar2 */
/* GenericBoardInformation */
  volatile u_long                REG_MAP_VERSION;               /* 0x0000 - 0x0007 (8) */
  u_char                         unused0[8];                    /* 0x0008 - 0x000F (8) */

  volatile u_long                BOARD_ID_TIMESTAMP;            /* 0x0010 - 0x0017 (8) */
  u_char                         unused1[8];                    /* 0x0018 - 0x001F (8) */

  volatile u_long                GIT_COMMIT_TIME;               /* 0x0020 - 0x0027 (8) */
  u_char                         unused2[8];                    /* 0x0028 - 0x002F (8) */

  volatile u_long                GIT_TAG;                       /* 0x0030 - 0x0037 (8) */
  u_char                         unused3[8];                    /* 0x0038 - 0x003F (8) */

  volatile u_long                GIT_COMMIT_NUMBER;             /* 0x0040 - 0x0047 (8) */
  u_char                         unused4[8];                    /* 0x0048 - 0x004F (8) */

  volatile u_long                GIT_HASH;                      /* 0x0050 - 0x0057 (8) */
  u_char                         unused5[8];                    /* 0x0058 - 0x005F (8) */

  volatile u_long                STATUS_LEDS;                   /* 0x0060 - 0x0067 (8) */
  u_char                         unused6[8];                    /* 0x0068 - 0x006F (8) */

  wuppercard_generic_constants_t  GENERIC_CONSTANTS;             /* 0x0070 - 0x0077 (8) */
  u_char                         unused7[8];                    /* 0x0078 - 0x007F (8) */

  volatile u_long                CARD_TYPE;                     /* 0x0080 - 0x0087 (8) */
  u_char                         unused8[8];                    /* 0x0088 - 0x008F (8) */

  volatile u_long                PCIE_ENDPOINT;                 /* 0x0090 - 0x0097 (8) */
  u_char                         unused9[8];                    /* 0x0098 - 0x009F (8) */

  volatile u_long                NUMBER_OF_PCIE_ENDPOINTS;      /* 0x00A0 - 0x00A7 (8) */
  u_char                         unused10[8];                   /* 0x00A8 - 0x00AF (8) */

  u_char                         unused11[0x0F50];              /* 0x00B0 - 0x0FFF (3920) */

/* HouseKeepingControlsAndMonitors */
  u_char                         unused12[0x0300];              /* 0x1000 - 0x12FF (768) */

  volatile u_long                MMCM_MAIN_PLL_LOCK;            /* 0x1300 - 0x1307 (8) */
  u_char                         unused13[8];                   /* 0x1308 - 0x130F (8) */

  wuppercard_i2c_wr_t            I2C_WR;                        /* 0x1310 - 0x1317 (8) */
  u_char                         unused14[8];                   /* 0x1318 - 0x131F (8) */

  wuppercard_i2c_rd_t            I2C_RD;                        /* 0x1320 - 0x1327 (8) */
  u_char                         unused15[8];                   /* 0x1328 - 0x132F (8) */

  volatile u_long                FPGA_CORE_TEMP;                /* 0x1330 - 0x1337 (8) */
  u_char                         unused16[8];                   /* 0x1338 - 0x133F (8) */

  volatile u_long                FPGA_CORE_VCCINT;              /* 0x1340 - 0x1347 (8) */
  u_char                         unused17[8];                   /* 0x1348 - 0x134F (8) */

  volatile u_long                FPGA_CORE_VCCAUX;              /* 0x1350 - 0x1357 (8) */
  u_char                         unused18[8];                   /* 0x1358 - 0x135F (8) */

  volatile u_long                FPGA_CORE_VCCBRAM;             /* 0x1360 - 0x1367 (8) */
  u_char                         unused19[8];                   /* 0x1368 - 0x136F (8) */

  volatile u_long                FPGA_DNA;                      /* 0x1370 - 0x1377 (8) */
  u_char                         unused20[8];                   /* 0x1378 - 0x137F (8) */

  u_char                         unused21[0x0480];              /* 0x1380 - 0x17FF (1152) */

  wuppercard_int_test_t          INT_TEST;                      /* 0x1800 - 0x1807 (8) */
  u_char                         unused22[8];                   /* 0x1808 - 0x180F (8) */

  wuppercard_dma_busy_status_t   DMA_BUSY_STATUS;               /* 0x1810 - 0x1817 (8) */
  u_char                         unused23[8];                   /* 0x1818 - 0x181F (8) */

  u_char                         unused24[0x07E0];              /* 0x1820 - 0x1FFF (2016) */

/* Wishbone */
  wuppercard_wishbone_control_t  WISHBONE_CONTROL;              /* 0x2000 - 0x2007 (8) */
  u_char                         unused25[8];                   /* 0x2008 - 0x200F (8) */

  wuppercard_wishbone_write_t    WISHBONE_WRITE;                /* 0x2010 - 0x2017 (8) */
  u_char                         unused26[8];                   /* 0x2018 - 0x201F (8) */

  wuppercard_wishbone_read_t     WISHBONE_READ;                 /* 0x2020 - 0x2027 (8) */
  u_char                         unused27[8];                   /* 0x2028 - 0x202F (8) */

  wuppercard_wishbone_status_t   WISHBONE_STATUS;               /* 0x2030 - 0x2037 (8) */
  u_char                         unused28[8];                   /* 0x2038 - 0x203F (8) */

  u_char                         unused29[0x0FC0];              /* 0x2040 - 0x2FFF (4032) */

/* Application */
  volatile u_long                LOOPBACK;                      /* 0x3000 - 0x3007 (8) */
  u_char                         unused30[8];                   /* 0x3008 - 0x300F (8) */

} wuppercard_bar2_regs_t;


#pragma GCC diagnostic pop

#ifdef __cplusplus
}
#endif

#endif /* REGMAP_STRUCT_H */