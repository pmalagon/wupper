/*******************************************************************/
/*                                                                 */
/* This is the C++ source code of the wupper-info application         */
/*                                                                 */
/* Author: Markus Joos, CERN                                       */
/* (based on code from a.rodriguez@cern.ch                         */
/*                                                                 */
/**C 2015 Ecosoft - Made from at least 80% recycled source code*****/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "version.h"

#include "DFDebug/DFDebug.h"
#include "wuppercard/WupperCard.h"
#include "wuppercard/WupperException.h"

#define APPLICATION_NAME    "wupper-info"


enum info_mode
{
  INFO_UNKNOWN,
  INFO_GBT,
  INFO_FMC_TEMP_SENSOR,
  INFO_ADN2814,
  INFO_LMK03200,
  INFO_CXP,
  INFO_DDR3,
  INFO_EGROUP,
  INFO_SFP,
  INFO_IDEEPROM,
  INFO_SI5324,
  INFO_SI5345,
  INFO_ICS8N4Q,
  INFO_ALL
};

//Globals
WupperCard wupperCard;
u_long baraddr2;
int verbose = 0;


/************************/
static void display_help()
/************************/
{
  printf("Usage: %s [OPTIONS] [COMMAND] [CMD ARGUMENTS]\n", APPLICATION_NAME);
  printf("Displays information about a WUPPER device.\n\n");
  printf("Options:\n");
  printf("  -d NUMBER                       Use card indicated by NUMBER. Default: 0.\n");
  printf("  -v                              Verbose mode.\n");
  printf("  -D level                        Configure debug output at API level. 0=disabled, 5, 10, 20 progressively more verbose output. Default: 0.\n");
  printf("  -h                              Display help.\n");
  printf("  -V                              Display the version number\n");
  printf("Commands:\n");
  printf("  GBT                             Shows GBT channel alignment status.\n");
  printf("  FMC_TEMP_SENSOR                 Display FMC temperature from TC74 sensor.\n");
  printf("  ADN2814                         Display ADN2814 register 0x4.\n");
  printf("  CXP                             Display temperature and voltage from CXP1 and CXP2\n");
  printf("  SFP                             Display information from Small Form Factor Pluggable transceivers\n");
  printf("  DDR3                            Display values from DDR3 RAM memory\n");
  printf("  ID_EEPROM                       Display the first 32 bytes of the eeprom memory\n");
  printf("  SI5324                          Display SI5324 status\n");
  printf("  SI5345                          Display SI5345 status\n");
  printf("  LMK03200                        Display LMK03200 status\n");
  printf("  ICS8N4Q                         Display ICS8N4Q status\n");
  printf("  EGROUP       [channel]  [RAW]   Display values from EGROUP registers:  \n");
  printf("                                      If no channel is specified, display all available.\n");
  printf("                                      Using Hexadecimal notation if RAW is specified.\n");
  printf("  ALL                             Display ALL information.\n");
}


/********************************/
static void display_fpga_dna(void)
/********************************/
{    
  u_long lvalue;
  
  lvalue = wupperCard.cfg_get_option(BF_FPGA_DNA);
  printf("FPGA DNA         : 0x%016lx\n", lvalue);
}


/*******************************/
static void display_card_id(void)
/*******************************/
{
  u_long card_id = 0, reg_map_version = 0, major, minor;
  int card_control = 0;

  printf("Card type        : ");
  card_id = wupperCard.cfg_get_option(BF_CARD_TYPE);
  if(card_id == 712)
  {
    printf("WUPPER-712\n");
    card_control = 1;
  }
  if(card_id == 711)
  {
    printf("WUPPER-711\n");
    card_control = 1;
  }
  if(card_id == 710)
  {
    printf("WUPPER-710\n");
    card_control = 1;
  }
  if(card_id == 709)
  {
    printf("WUPPER-709\n");
    card_control = 1;
  }
  if(card_id == 128)
  {
    printf("WUPPER-128\n");
    card_control = 1;
  }
  if(card_control == 0)
    printf("UNKNOWN\n");

  // Register map version stored as hex: 0x0300 -> 3.0
  reg_map_version = wupperCard.cfg_get_option(BF_REG_MAP_VERSION);
  major = (reg_map_version & 0xFF00) >> 8;
  minor = (reg_map_version & 0x00FF) >> 0;
  printf("Reg Map version  : %lx.%lx\n", major, minor);
}


/*******************************/
static void display_FW_date(void)
/*******************************/
{
  u_long date = 0;
  u_int version_day = 0, version_month = 0, version_year = 0, version_hour = 0, version_minute = 0;

  date = wupperCard.cfg_get_option(BF_BOARD_ID_TIMESTAMP);
  
  //Not very elegant
  version_year   = (date >> 32);
  version_month  = (0x00FF) & (date >> 24);
  version_day    = (0x0000FF) & (date >> 16);
  version_hour   = (0x000000FF) & (date >> 8);
  version_minute = (0x00000000FF) & date;

  printf("FW version date  : %02x/%02x/%02x %02x:%02x\n", version_year, version_month, version_day, version_hour, version_minute);
}


/**********************************/
static void display_FW_version(void)
/**********************************/
{
  u_long value = 0, loop;
  char git_tag[8];
  
  value = wupperCard.cfg_get_option(BF_GIT_TAG);
  
  for(loop = 0; loop < 8; loop++)
    git_tag[loop] = (value >> (8 * loop)) & 0xff;
  
  printf("GIT tag          : %s\n", git_tag);
   
  value = wupperCard.cfg_get_option(BF_GIT_COMMIT_NUMBER);
  printf("GIT commit number: %lu\n", value);
  value = wupperCard.cfg_get_option(BF_GIT_HASH);
  printf("GIT hash         : 0x%016lx\n", value);
  
}


/**********************************************/
static void display_interrupts_descriptors(void)
/**********************************************/
{
  u_long descriptors = 0, interrupts = 0;
  
  interrupts  = wupperCard.cfg_get_option(BF_GENERIC_CONSTANTS_INTERRUPTS);
  descriptors = wupperCard.cfg_get_option(BF_GENERIC_CONSTANTS_DESCRIPTORS);
  printf("Number of interrupts  : %ld\n", interrupts);
  printf("Number of descriptors : %ld\n", descriptors);
}


/********************************/
static void display_ideeprom(void)
/********************************/
{
  int cont = 0;
  char eeprom_device[15] = "\0";
  u_char character = 0;

  try
  {
    printf("First 32 bytes of the eeprom:\n");
    for(cont = 0; cont < 32; cont++)
    {
      wupperCard.i2c_devices_read(eeprom_device, cont, &character);
      printf("%c", character);
    }
    printf("\n\n");
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }
}


/****************************/
static void display_tc74(void)
/****************************/
{
  char device[] = "FMC_TEMP_SENSOR";
  u_char value = 0;

  try
  {
    wupperCard.i2c_devices_read(device, 0, &value);
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }

  printf("FMC Temperature = %d C\n", value);
}



/***************************/
static void display_cxp(void)
/***************************/
{
  int cont = 0, cont1 = 0;
  char valueMSB = 0;
  const char *device[4];
  float fractional = (float)1 / (float)256, voltage = 0, temperature = 0;
  u_char aux_value = 0, valueLSB = 0, voltageMSB = 0, voltageLSB = 0, LOS_status = 0;
  u_int um_voltage = 0;

  device[0] = "CXP1_TX";
  device[1] = "CXP1_RX";
  device[2] = "CXP2_TX";
  device[3] = "CXP2_RX";

  for(cont = 0; cont < 4; cont++)
  {
    try
    {
      wupperCard.i2c_devices_read(device[cont], 22, &aux_value);

      valueMSB = (char) aux_value;
      wupperCard.i2c_devices_read(device[cont], 23, &valueLSB);
      temperature = valueLSB * fractional;
      temperature = temperature + valueMSB;
      printf("\n%s 1st temperature monitor: %.2f C\n", device[cont], temperature);

      wupperCard.i2c_devices_read(device[cont], 26, &voltageMSB);
      wupperCard.i2c_devices_read(device[cont], 27, &voltageLSB);

      um_voltage = (voltageMSB << 8) + voltageLSB;
      voltage = (float)um_voltage / 10000;
      printf("%s voltage monitor 3.3 V: %.3f V\n", device[cont], voltage);

      printf("%s LOS channels status:\n", device[cont]);
      wupperCard.i2c_devices_read(device[cont], 0x08, &LOS_status);

      printf("                C0  C1  C2  C3  C4  C5  C6  C7  C8  C9  C10 C11 \n");
      printf("              --------------------------------------------------\n");
      printf("Signal Status |");

      for(cont1 = 0; cont1 < 8; cont1++)
      {
        if(((LOS_status & (1 << cont1)) >> cont1))
          printf(" -- ");
        else
          printf(" OK ");
      }

      wupperCard.i2c_devices_read(device[cont], 0x07, &LOS_status);
      for(cont1 = 0; cont1 < 4; cont1++)
      {
        if(((LOS_status & (1 << cont1)) >> cont1))
          printf(" -- ");
        else
          printf(" OK ");
      }
    }
    catch(WupperException &ex)
    {
      std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
      exit(-1);
    }
    printf("|\n");
    printf("              --------------------------------------------------\n");
  }
}



/******************************/
static void display_si5324(void)
/******************************/
{
  u_char result = 0;
  u_long card_model = 0;

  try
  {
    card_model = wupperCard.card_model();
    if(card_model != WUPPER_709)
    {
      printf("Sorry, this is not a WUPPER-709\n");
      return;
    }

    printf("Status of the SI5324\n");
    printf("--------------------\n");

    wupperCard.i2c_devices_read("REC_CLOCK", 0x81, &result);
    printf("Decoding register 129 (raw data = 0x%02x)\n", result);
    printf("LOS2_INT: %s\n", (result & 0x4)?"Error: CLK2 LOS":"CLK2 OK");

    wupperCard.i2c_devices_read("REC_CLOCK", 0x82, &result);
    printf("Decoding register 130 (raw data = 0x%02x)\n", result);
    printf("LOL_INT:  %s\n", (result & 0x1)?"PLL unlocked":"PLL locked");
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }
}


/***************************/
static void display_ics(void)
/***************************/
{
  u_char result = 0;
  u_long card_model = 0;
  u_int loop;

  try
  {
    card_model = wupperCard.card_model();
    if(card_model != WUPPER_710)
    {
      printf("Sorry, this is not a WUPPER-710\n");
      return;
    }

    printf("Status of the ICS8N4Q\n");
    printf("--------------------\n");

    for (loop = 0; loop < 24; loop++)
    {
      wupperCard.i2c_devices_read("CLOCK_RAM", loop, &result);
      printf("Raw data of register %d = 0x%02x\n", loop, result);
    }
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }
}


/******************************/
static void display_si5345(void)
/******************************/
{
  u_char result = 0;
  u_long card_model = 0;

  try
  {
    card_model = wupperCard.card_model();
    if(card_model != WUPPER_709 && card_model != WUPPER_711 && card_model != WUPPER_712)
    {
      printf("Sorry, this is not a WUPPER-709, WUPPER-711 or WUPPER-712\n");
      return;
    }

    printf("Status of the SI5345\n");
    printf("--------------------\n");

    wupperCard.i2c_devices_read("SI5345", 0xe, &result);
    printf("Loss of lock (LOL): %s\n", (result & 0x2)?"Yes":"No");

    wupperCard.i2c_devices_read("SI5345", 0xd, &result);

    printf("Loss of signal (LOS) of input 1: %s\n", (result & 0x1)?"Yes":"No");

    if (verbose)
    {
      printf("Loss of signal (LOS) of input 2: %s\n", (result & 0x2)?"Yes":"No");
      printf("Loss of signal (LOS) of input 3: %s\n", (result & 0x4)?"Yes":"No");
      printf("Loss of signal (LOS) of input 4: %s\n", (result & 0x8)?"Yes":"No");
    }
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }
}


/****************************/
static void display_ddr3(void)
/****************************/
{
  const char *device[2];
  int cont = 0, sel_device = 0;
  float timebase = 0;
  u_int sd_cap = 0, total_cap = 0;
  u_char part_number[40] = "\0", spd_revision = 0, dram_type = 0, module_type = 0, density = 0, ba_bits = 0;
  u_char mod_org = 0, n_ranks = 0, dev_width = 0, mod_width = 0, pb_width = 0, mtb_dividend = 0, mtb_divisor = 0;
  u_char tckmin = 0, taamin = 0, twrmin = 0, trcdmin = 0, trrdmin = 0, trpmin = 0, trasrcupper = 0, trasmin_aux = 0, trcmin_aux = 0;
  u_char trfcmin_aux1 = 0, trfcmin_aux2 = 0, twtrmin = 0, trtpmin = 0, tfawmin_aux1 = 0, tfawmin_aux2 = 0, tropts = 0;
  u_char cassupport_aux1 = 0, cassupport_aux2 = 0;
  u_short trasmin = 0, trcmin = 0, trfcmin = 0, tfawmin = 0, cassupport = 0;

  try
  {
    device[0] = "DDR3-1";
    device[1] = "DDR3-2";

    for(sel_device = 0; sel_device < 2; sel_device++)
    {
      for(cont = 128; cont < 145; cont++)
        wupperCard.i2c_devices_read(device[sel_device], cont, &part_number[cont - 128]);

      printf("Device %s\n", device[sel_device]);
      printf("----------------------------------------------\n");
      printf("Part number      : %s\n", part_number);

      wupperCard.i2c_devices_read(device[sel_device], 1, &spd_revision);
      printf("SPD Revision     : %d.%d\n", (spd_revision >> 4), (spd_revision & 0x0f));

      wupperCard.i2c_devices_read(device[sel_device], 2, &dram_type);
      printf("DRAM Device Type : 0x%x\n", dram_type);

      wupperCard.i2c_devices_read(device[sel_device], 3, &module_type);
      printf("Module Type      : 0x%x\n", module_type);

      wupperCard.i2c_devices_read(device[sel_device], 4, &density);
      ba_bits = (density & 0x70);
      ba_bits = (ba_bits >> 4);
      ba_bits = ba_bits + 3;
      sd_cap  = 256 * (1ul << (density & 0xf));

      printf("Bank Address     : %d bit\n", (int)ba_bits);
      printf("SDRAM Capacity   : %d Mbit\n", (int)sd_cap);

      wupperCard.i2c_devices_read(device[sel_device], 7, &mod_org);
      n_ranks = ((mod_org >> 3) & 0x7) + 1;
      dev_width = 4 * (1 << (mod_org & 0x07));
      printf("Number of Ranks  : %d \n", (int)n_ranks);
      printf("Device Width     : %d bit\n", (int)dev_width);

      wupperCard.i2c_devices_read(device[sel_device], 8, &mod_width);
      pb_width = (mod_width & 0x7);
      pb_width = (1 << pb_width);
      pb_width = pb_width * 8;
      printf("Bus Width        : %d bit\n", (int)pb_width);

      total_cap = sd_cap / 8 * pb_width / dev_width * n_ranks;
      printf("Total Capacity   : %d MB\n", total_cap);

      wupperCard.i2c_devices_read(device[sel_device], 10, &mtb_dividend);
      wupperCard.i2c_devices_read(device[sel_device], 11, &mtb_divisor);
      timebase = (float)mtb_dividend / (float)mtb_divisor;
      printf("Medium Timebase  : %.2f ns\n", timebase);

      wupperCard.i2c_devices_read(device[sel_device], 12, &tckmin);
      printf("tCKmin           : %.2f ns\n", tckmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 16, &taamin);
      printf("tAAmin           : %.2f ns\n", taamin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 17, &twrmin);
      printf("tWRmin           : %.2f ns\n", twrmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 18, &trcdmin);
      printf("tRCDmin          : %.2f ns\n", trcdmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 19, &trrdmin);
      printf("tRRDmin          : %.2f ns\n", trrdmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 20, &trpmin);
      printf("tRPmin           : %.2f ns\n", trpmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 21, &trasrcupper);
      wupperCard.i2c_devices_read(device[sel_device], 22, &trasmin_aux);
      trasmin = ((trasrcupper & 0x0f) << 8) |trasmin_aux;
      printf("tRASmin          : %.2f ns\n", trasmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 23, &trcmin_aux);
      trcmin = ((trasrcupper & 0xf0) << 4) | trcmin_aux;
      printf("tRCmin           : %.2f ns\n", trcmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 25, &trfcmin_aux1);
      wupperCard.i2c_devices_read(device[sel_device], 24, &trfcmin_aux2);
      trfcmin = (trfcmin_aux1 << 8) | trfcmin_aux2;
      printf("tRFCmin          : %.2f ns\n", trfcmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 26, &twtrmin);
      printf("tWTRmin          : %.2f ns\n", twtrmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 27, &trtpmin);
      printf("tRTPmin          : %.2f ns\n", trtpmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 28, &tfawmin_aux1);
      wupperCard.i2c_devices_read(device[sel_device], 29, &tfawmin_aux2);
      tfawmin = ((tfawmin_aux1 << 8) & 0x0f) | tfawmin_aux2;
      printf("tFAWmin          : %.2f ns\n", tfawmin * timebase);

      wupperCard.i2c_devices_read(device[sel_device], 32, &tropts);
      printf("Thermal Sensor   : %d\n", (tropts >> 7) & 1);

      wupperCard.i2c_devices_read(device[sel_device], 15, &cassupport_aux1);
      wupperCard.i2c_devices_read(device[sel_device], 14, &cassupport_aux2);
      cassupport = (cassupport_aux1 << 8) | cassupport_aux2;
      printf("CAS Latencies    : ");
      for(cont = 0; cont < 14; cont++)
      {
        if((cassupport >> cont) & 1)
          printf("CL %d  ", (cont + 4));
      }
      printf("\n");
    }
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }
}


/***********************/
static void display_sfp()
/***********************/
{
  int cont = 0, cont1 = 0, cont2 = 0;
  u_char valueMSB = 0, aux_value = 0, valueLSB = 0, voltageMSB = 0, voltageLSB = 0;
  u_char part_number[40] = "\0", tx_fault = 0, rx_lost = 0, loss_os[4], sfp_sequence[4];
  u_short u_temperature = 0;
  float fractional = (float)1 / (float)256, voltage = 0, temperature = 0;
  u_int um_voltage = 0;
  const char *device[8];

  device[2] = "SFP1-1";     //WUPPER-311
  device[1] = "SFP1-2";
  device[0] = "SFP2-1";     //WUPPER-311
  device[3] = "SFP2-2";
  device[4] = "SFP3-1";
  device[5] = "SFP3-2";
  device[6] = "SFP4-1";
  device[7] = "SFP4-2";
  loss_os[0] = 0;
  loss_os[1] = 0;
  loss_os[2] = 0;
  loss_os[3] = 0;

  try
  {    
    for(cont = 0; cont < 8; cont++)
    {
      wupperCard.i2c_devices_read(device[cont], 96, &valueMSB);
      for(cont1 = 20; cont1 < 26; cont1++)
        wupperCard.i2c_devices_read(device[cont], cont1, &part_number[cont1 - 20]);

      for(cont1 = 40; cont1 < 51; cont1++)
        wupperCard.i2c_devices_read(device[cont], cont1, &part_number[cont1 - 40 + 6]);

      if (verbose)
      {
        printf("Device %s\n", device[cont]);
        printf("----------------------------------------------\n");
        printf("Part number      : %s\n", part_number);
      }

      cont++; //Switch to enhanced memory.

      wupperCard.i2c_devices_read(device[cont], 96, &valueMSB);
      wupperCard.i2c_devices_read(device[cont], 97, &valueLSB);

      u_temperature = valueMSB;
      u_temperature = (u_temperature << 8);
      u_temperature = u_temperature + valueLSB;
      temperature = ((short)u_temperature * fractional);
      if (verbose)
        printf("\n%s temperature monitor: %.2f C\n", device[cont], temperature);

      wupperCard.i2c_devices_read(device[cont], 98, &voltageMSB);
      wupperCard.i2c_devices_read(device[cont], 99, &voltageLSB);

      um_voltage = voltageMSB;
      um_voltage = (um_voltage << 8) + voltageLSB;
      voltage = (float)um_voltage / 10000;
      if (verbose)
        printf("%s voltage monitor: %.3f V\n", device[cont], voltage);
  
      wupperCard.i2c_devices_read(device[cont], 110, &aux_value);

      tx_fault = ((aux_value & (1 << 2)) >> 2);
      rx_lost  = ((aux_value & (1 << 1)) >> 1);
      //data_ready = (aux_value & 1);

      if (verbose)
        printf("Transmission fault estate: %u", tx_fault);

      if (verbose)
      {
        if(tx_fault == 1)
          printf("    Fault on data transmission\n");
        else
          printf("    Transmitting data\n");
      }
      
      loss_os[cont2] = rx_lost;
      cont2++;
      if (verbose)
        printf("Loss of Signal estate: %u", rx_lost);

      if (verbose)
      {
        if(rx_lost == 1)
          printf("        Signal not received or under threshold\n");
        else
          printf("        Receiving signal\n");

        printf("Data ready: %u", tx_fault);

        if(tx_fault == 1)
          printf("                   Transceiver not ready\n");
        else
          printf("                   Transceiver ready\n");
        printf("\n");
      }
    }
    
    //WUPPER-311
    sfp_sequence[0] = 1;
    sfp_sequence[1] = 0;
    sfp_sequence[2] = 2;
    sfp_sequence[3] = 3;
    
    printf("               0    1    2    3\n");
    printf("---------------------------------\n");
    printf("Link Status  |");
    for(cont = 0; cont < 4; cont++)
    {
      if(loss_os[sfp_sequence[cont]] == 1)
        printf(" --  ");
      else
        printf(" Ok  ");
    }
    printf("\n\n");
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }
}



/*****************************/
int main(int argc, char **argv)
/*****************************/
{
  int device_number = 0, opt, tem_sensor_info = 0, common_info = 0, mode = INFO_UNKNOWN;
  int debuglevel, cxp_info = 0, si5324_info = 0, si5345_info = 0, ics_info = 0;
  int ddr3_info = 0, sfp_info = 0, id_eeprom_info = 0, arguments = 0;
  u_long card_model = 0;

  while((opt = getopt(argc, argv, "hvd:D:V")) != -1)
  {
    switch (opt)
    {
      case 'd':
        device_number = atoi(optarg);
        arguments = arguments + 2;
        break;

      case 'v':
        verbose++;
        arguments++;
        break;

      case 'D':
        debuglevel = atoi(optarg);
        DF::GlobalDebugSettings::setup(debuglevel, DFDB_FELIXCARD);
        break;

      case 'h':
        display_help();
        exit(0);

      case 'V':
        printf("This is version %s of %s\n", VERSION, APPLICATION_NAME);
        exit(0);

      default:
        fprintf(stderr, "Usage: %s COMMAND [OPTIONS]\nTry %s -h for more information.\n", APPLICATION_NAME, APPLICATION_NAME);
        exit(-1);
    }
  }

  if(optind != argc)
  {
    if(strcasecmp(argv[optind], "FMC_TEMP_SENSOR") == 0)  mode = INFO_FMC_TEMP_SENSOR;
    if(strcasecmp(argv[optind], "CXP") == 0)              mode = INFO_CXP;
    if(strcasecmp(argv[optind], "DDR3") == 0)             mode = INFO_DDR3;
    if(strcasecmp(argv[optind], "EGROUP") == 0)           mode = INFO_EGROUP;
    if(strcasecmp(argv[optind], "SFP") == 0)              mode = INFO_SFP;
    if(strcasecmp(argv[optind], "SI5324") == 0)           mode = INFO_SI5324;
    if(strcasecmp(argv[optind], "SI5345") == 0)           mode = INFO_SI5345;
    if(strcasecmp(argv[optind], "ICS8N4Q") == 0)          mode = INFO_ICS8N4Q;
    if(strcasecmp(argv[optind], "ID_EEPROM") == 0)        mode = INFO_IDEEPROM;
    if(strcasecmp(argv[optind], "ALL") == 0)              mode = INFO_ALL;

    if(mode == INFO_UNKNOWN)
    {
      fprintf(stderr, "Unrecognized command '%s'\n", argv[1]);
      fprintf(stderr, "Usage: " APPLICATION_NAME " COMMAND [OPTIONS]\nTry " APPLICATION_NAME " -h for more information.\n");
      exit(-1);
    }
  }

  switch(mode)
  {
    

    case INFO_FMC_TEMP_SENSOR:
      tem_sensor_info = 1;
      break;

    case INFO_CXP:
      cxp_info = 1;
      break;

    case INFO_DDR3:
      ddr3_info = 1;
      break;

    case INFO_SFP:
      sfp_info = 1;
      break;

    case INFO_IDEEPROM:
      id_eeprom_info = 1;
      break;

    case INFO_SI5324:
      si5324_info = 1;
      break;
    
    case INFO_SI5345:
      si5345_info = 1;
      break;
          
    case INFO_ICS8N4Q:
      ics_info = 1;
      break;

      
    case INFO_ALL:
      id_eeprom_info  = 1;
      tem_sensor_info = 1;
      common_info     = 1;
      cxp_info        = 1;
      ddr3_info       = 1;
      sfp_info        = 1;
      si5324_info     = 1;
      si5345_info     = 1;
      break;

    default:
      common_info = 1;
  }
  
  try
  {
    wupperCard.card_open(device_number, 0);
    baraddr2 = wupperCard.openBackDoor(2);
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }

  card_model = wupperCard.card_model();
  if(card_model != WUPPER_712 && card_model != WUPPER_711 && card_model != WUPPER_710 && card_model != WUPPER_709 && card_model != WUPPER_128)
  {
    fprintf(stderr, APPLICATION_NAME " error: Card model not recognized\n");
    exit(-1);
  }

  if(common_info)
  {
    u_int noc;
    
    printf("\nGeneral information\n");
    printf("----------------------------------\n");
    
    noc = WupperCard::number_of_devices();
    printf("WUPPER cards     : %d\n", noc);
    
    display_card_id();
    if (verbose) display_fpga_dna();
    display_FW_date();
    display_FW_version();
    
    printf("\nOutput of lspci: \n");
    system("lspci | grep -e Xil -e CERN");
    printf("\n");
   
    printf("Interrupts, descriptors & channels\n");
    printf("----------------------------------\n");
    display_interrupts_descriptors();
    
  }

  if(si5324_info)     display_si5324();
  if(si5345_info)     display_si5345();
  if(ics_info)        display_ics();
  if(tem_sensor_info) display_tc74();
  if(cxp_info)        display_cxp();
  if(ddr3_info)       display_ddr3();
  if(sfp_info)        display_sfp();
  if(id_eeprom_info)  display_ideeprom();

  try
  {
    wupperCard.card_close();
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std::endl;
    exit(-1);
  }

  exit(0);
}
