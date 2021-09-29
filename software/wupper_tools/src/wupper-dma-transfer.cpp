/**
  *    ------------------------------------------------------------------------------
  *                                                              
  *            NIKHEF - National Institute for Subatomic Physics 
  *  
  *                        Electronics Department                
  *                                                              
  *  ----------------------------------------------------------------------------
  *  @class wupper-dma-transfer
  *  
  *  
  *  @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
  *               Frans Schreuder (frans.schreuder@nikhef.nl)<br>
  * 			  Markus Joos<br>
  * 			  Jos Vermeulen<br>
  * 			  Oussama el Kharraz Alami<br>
  *  
  *  
  *  @date        08/09/2015    created
  *  
  *  @version     1.0
  *  
  *  @brief wupper-dma-transfer.c writes to and reads from PC memory. 
  *  The 256 bit datagenerator is based on a LFSR.
  *  User can set a seed or load a pre-programmed seed. After the DMA
  *  read, the data from the PC memory will be multiplied and write 
  *  back to the PC memory.
  *   
  *
  * 
  * 
  *   
  *  @detail
  *  This application has a sequence:
  *  1 -Start with dma reset(-d)
  *  2 -Then reset the application (-r)
  *  3 -Flush the FIFO's(-f)
  * 
  *  
  *  
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
  
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#include "cmem_rcc/cmem_rcc.h"
#include "rcc_error/rcc_error.h"
#include "DFDebug/DFDebug.h"
#include "wuppercard/WupperCard.h"
#include "wuppercard/WupperException.h"


#define APPLICATION_NAME "wupper-dma-transfer"
#define DMA_ID     0

int buffer1, buffer2;
u_long  paddr1, paddr2, vaddr1, vaddr2;
  
//Globals
WupperCard wupperCard;
int cont;

void
display_help()
{
  printf("\nUsage: %s [OPTIONS]\n"
	 "\n\n"
	 
	 "Options:\n"
	 "  -g             Generate data from internal counter in FPGA, to PC.\n"
	 "  -l             Generate data from PC to PCIe and loopback to PC\n"
	 "  -D level       Configure debug output at API level. 0=disabled, 5, 10, 20 progressively more verbose output. Default: 0.\n"
	 "  -h             Display help.\n\n",
	 APPLICATION_NAME);
}


void
start_application2pc()
{  
  uint64_t *memptr;
  
  wupperCard.cfg_set_option(BF_LOOPBACK,0);
  wupperCard.soft_reset();
  
  printf("Starting DMA write\n");
  wupperCard.dma_to_host(DMA_ID, paddr1, 1024*1024, 0);
  wupperCard.dma_wait(DMA_ID);
  printf("done DMA write \n");
  
  printf("Buffer 1 addresses:\n");
  memptr = (uint64_t*)vaddr1;
  int i;
  for(i=0; i<100;i++){
    printf("%i: %lX \n",i, *(memptr++));
  }  

  //wupperCard.cfg_set_option("APP_ENABLE",0);
}

void
start_loopback()
{  
  uint64_t *memptr, *memptr2;
  int i;
  bool Match = true;
  memptr = (uint64_t*)vaddr2;
  wupperCard.cfg_set_option(BF_LOOPBACK,1);
  wupperCard.soft_reset();
  for(i=0; i<1024*128;i++){
    *memptr = (uint64_t) i;
    memptr++;
  }
  printf("Fill fromHost buffer with 64b counterm send to PCIe and read back\n");
  
  wupperCard.dma_to_host(0, paddr1, 1024*1024, 0);
  wupperCard.dma_from_host(1, paddr2, 1024*1024, 0);
  printf("Waiting for toHost DMA to complete\n");
  wupperCard.dma_wait(0);
  printf("Waiting for fromHost DMA to complete\n");
  wupperCard.dma_wait(1);
  
  printf("DONE!\n");
    
  printf("Read back first 10 values:\n");
  memptr = (uint64_t*)vaddr1;
  memptr2 = (uint64_t*)vaddr2;
  for(i=0; i<100;i++){
    printf("%i: %lX %lX \n",i, *(memptr2++), *(memptr++));
  }
  memptr = (uint64_t*)vaddr1;
  memptr2 = (uint64_t*)vaddr2;
  printf("Comparing all %i counter values in both memory buffers to each other...\n", 1024*128);
  for(i=0; i<1024*128; i++){
    if(*(memptr2) != *(memptr))
    {
      printf("Mismatch at counter value %i: Expected %lX, Received %lX\n", i, *memptr2 ,*memptr);
      memptr2++;
      memptr++;
      Match = false;
      break;
    }
  }
  if(Match)
    printf("Comparing buffers OK.\n");
}

int
main(int argc, char** argv)
{
  u_int ret;
  int opt;
  int debuglevel;
  
  
  ret = CMEM_Open();
  int bsize = 1024*1024;
  if (!ret)
      ret = CMEM_SegmentAllocate(bsize, (char *)"Wupper-dma-transfer1", &buffer1);
  if (!ret)
      ret = CMEM_SegmentAllocate(bsize, (char *)"Wupper-dma-transfer2", &buffer2);
  
  if (!ret)
      ret = CMEM_SegmentPhysicalAddress(buffer1, &paddr1);
  
  if (!ret)
      ret = CMEM_SegmentVirtualAddress(buffer1, &vaddr1);
  
  if (!ret)
      ret = CMEM_SegmentPhysicalAddress(buffer2, &paddr2);
  
  if (!ret)
      ret = CMEM_SegmentVirtualAddress(buffer2, &vaddr2);
  
  
  if (ret)
  {
      rcc_error_print(stdout, ret);
      exit(-1);
  }


  while ((opt = getopt(argc, argv,"glD:h")) != -1) {
    switch (opt) {
    case 'g':
// generate data from PCIe->PC
      wupperCard.card_open(0,0);
      start_application2pc();
      wupperCard.card_close();  
      break;
    case 'l':
// read data from PC memory, and loop back.
      wupperCard.card_open(0,0);
      start_loopback();
      wupperCard.card_close();  
      break;
    case 'D':
      debuglevel = atoi(optarg);
      DF::GlobalDebugSettings::setup(debuglevel, DFDB_FELIXCARD);
      break;
    case 'h':  
      display_help();
      exit(EXIT_SUCCESS);
    default: /* '?' */
      fprintf(stderr, "Usage: %s COMMAND [OPTIONS]\nTry %s -h for more information.\n",
            APPLICATION_NAME, APPLICATION_NAME);
      exit(EXIT_FAILURE);
    }
  }
  
  ret = CMEM_SegmentFree(buffer1);
  if (!ret)
    ret = CMEM_SegmentFree(buffer2);
  if (!ret)
    ret = CMEM_Close();
  if (ret)
      rcc_error_print(stdout, ret);
  return(0);
}
