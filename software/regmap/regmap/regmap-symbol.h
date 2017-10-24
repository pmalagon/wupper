/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* DO NOT EDIT THIS FILE */
/*  */
/* This file was generated from template '../software/regmap/src/regmap-symbol.h.template' */
/* and register map registers-1.0.yaml, version 1.0 */
/* by the script 'wuppercodegen', version: 0.8.0, */
/* using the following commandline: */
/*  */
/* ../software/wuppercodegen/wuppercodegen/cli.py registers-1.0.yaml ../software/regmap/src/regmap-symbol.h.template ../software/regmap/regmap/regmap-symbol.h */
/*  */
/* Please do NOT edit this file, but edit the source file at '../software/regmap/src/regmap-symbol.h.template' */
/*  */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */
/* *************************************************************************** */


#ifndef REGMAP_SYMBOL_H
#define REGMAP_SYMBOL_H

#include <sys/types.h>

#include "regmap/regmap-common.h"

#ifdef __cplusplus
extern "C" {
#endif


/* Registers */
#define REGMAP_REG_READ               (1)
#define REGMAP_REG_WRITE              (2)
#define REGMAP_CFG_ERROR_NOT_READABLE (1)
#define REGMAP_CFG_ERROR_NOT_WRITABLE (2)
#define REGMAP_CFG_ERROR_NO_EXIST     (3)
#define REGMAP_ENDPOINT_0             (1)
#define REGMAP_ENDPOINT_1             (2)

/*****************************/
typedef struct regmap_register {
  const char* name;
  const char* description;
  u_long address;
  u_int flags;
  u_int endpoints;
} regmap_register_t;

extern regmap_register_t regmap_registers[];
/*****************************/
typedef struct regmap_bitfield {
  const char* name;
  const char* description;
  u_long address;
  u_long mask;
  u_int shift;
  u_int hi;
  u_int flags;
  u_int endpoints;
} regmap_bitfield_t;

extern regmap_bitfield_t regmap_bitfields[];
/*****************************/
typedef struct regmap_group {
  const char* name;
  const char* description;
  int index[MAX_ENTRIES_IN_GROUP];
} regmap_group_t;

extern regmap_group_t regmap_groups[];


/******************Register access*******************/
int regmap_cfg_get_option(u_long offset, const char* key, u_long* value);
int regmap_cfg_set_option(u_long offset, const char* key, u_long value);
int regmap_cfg_get_reg(u_long offset, const char* key, u_long* value);
int regmap_cfg_set_reg(u_long offset, const char* key, u_long value);


/* Registers */
#define REG_REG_MAP_VERSION                   "REG_MAP_VERSION"
#define REG_BOARD_ID_TIMESTAMP                "BOARD_ID_TIMESTAMP"
#define REG_BOARD_ID_SVN                      "BOARD_ID_SVN"
#define REG_STATUS_LEDS                       "STATUS_LEDS"
#define REG_GENERIC_CONSTANTS                 "GENERIC_CONSTANTS"
#define REG_CARD_TYPE                         "CARD_TYPE"
#define REG_LFSR_SEED_0                       "LFSR_SEED_0"
#define REG_LFSR_SEED_1                       "LFSR_SEED_1"
#define REG_LFSR_SEED_2                       "LFSR_SEED_2"
#define REG_LFSR_SEED_3                       "LFSR_SEED_3"
#define REG_APP_MUX                           "APP_MUX"
#define REG_LFSR_LOAD_SEED                    "LFSR_LOAD_SEED"
#define REG_APP_ENABLE                        "APP_ENABLE"
#define REG_MMCM_MAIN_PLL_LOCK                "MMCM_MAIN_PLL_LOCK"
#define REG_I2C_WR                            "I2C_WR"
#define REG_I2C_RD                            "I2C_RD"
#define REG_FPGA_CORE_TEMP                    "FPGA_CORE_TEMP"
#define REG_FPGA_CORE_VCCINT                  "FPGA_CORE_VCCINT"
#define REG_FPGA_CORE_VCCAUX                  "FPGA_CORE_VCCAUX"
#define REG_FPGA_CORE_VCCBRAM                 "FPGA_CORE_VCCBRAM"
#define REG_FPGA_DNA                          "FPGA_DNA"
#define REG_INT_TEST_4                        "INT_TEST_4"
#define REG_INT_TEST_5                        "INT_TEST_5"

/* Bitfields */
#define BF_REG_MAP_VERSION                    "REG_MAP_VERSION"
#define BF_BOARD_ID_TIMESTAMP                 "BOARD_ID_TIMESTAMP"
#define BF_BOARD_ID_SVN                       "BOARD_ID_SVN"
#define BF_STATUS_LEDS                        "STATUS_LEDS"
#define BF_GENERIC_CONSTANTS_INTERRUPTS       "GENERIC_CONSTANTS_INTERRUPTS"
#define BF_GENERIC_CONSTANTS_DESCRIPTORS      "GENERIC_CONSTANTS_DESCRIPTORS"
#define BF_CARD_TYPE                          "CARD_TYPE"
#define BF_LFSR_SEED_0                        "LFSR_SEED_0"
#define BF_LFSR_SEED_1                        "LFSR_SEED_1"
#define BF_LFSR_SEED_2                        "LFSR_SEED_2"
#define BF_LFSR_SEED_3                        "LFSR_SEED_3"
#define BF_APP_MUX                            "APP_MUX"
#define BF_LFSR_LOAD_SEED                     "LFSR_LOAD_SEED"
#define BF_APP_ENABLE                         "APP_ENABLE"
#define BF_MMCM_MAIN_PLL_LOCK                 "MMCM_MAIN_PLL_LOCK"
#define BF_I2C_WR_I2C_WREN                    "I2C_WR_I2C_WREN"
#define BF_I2C_WR_I2C_FULL                    "I2C_WR_I2C_FULL"
#define BF_I2C_WR_WRITE_2BYTES                "I2C_WR_WRITE_2BYTES"
#define BF_I2C_WR_DATA_BYTE2                  "I2C_WR_DATA_BYTE2"
#define BF_I2C_WR_DATA_BYTE1                  "I2C_WR_DATA_BYTE1"
#define BF_I2C_WR_SLAVE_ADDRESS               "I2C_WR_SLAVE_ADDRESS"
#define BF_I2C_WR_READ_NOT_WRITE              "I2C_WR_READ_NOT_WRITE"
#define BF_I2C_RD_I2C_RDEN                    "I2C_RD_I2C_RDEN"
#define BF_I2C_RD_I2C_EMPTY                   "I2C_RD_I2C_EMPTY"
#define BF_I2C_RD_I2C_DOUT                    "I2C_RD_I2C_DOUT"
#define BF_FPGA_CORE_TEMP                     "FPGA_CORE_TEMP"
#define BF_FPGA_CORE_VCCINT                   "FPGA_CORE_VCCINT"
#define BF_FPGA_CORE_VCCAUX                   "FPGA_CORE_VCCAUX"
#define BF_FPGA_CORE_VCCBRAM                  "FPGA_CORE_VCCBRAM"
#define BF_FPGA_DNA                           "FPGA_DNA"
#define BF_INT_TEST_4                         "INT_TEST_4"
#define BF_INT_TEST_5                         "INT_TEST_5"

/* Groups */
#define GRP_GEN                               "GEN"
#define GRP_APP                               "APP"
#define GRP_HKC                               "HKC"


#ifdef __cplusplus
}
#endif

#endif /* REGMAP_SYMBOL_H */