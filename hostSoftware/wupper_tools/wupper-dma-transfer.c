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

#include "wupper.h"

#define APPLICATION_NAME "wupper-dma-transfer"
#define device_number     0

wupper_dev_t wupper;
cmem_buffer_t buffer1;
cmem_buffer_t buffer2;
cmem_dev_t cmem;
uint64_t t;



void
display_help()
{
  printf("\nUsage: %s [OPTIONS]\n"
	 "\n\n"
	 
	 "This application has a sequence: \n"
	 " 1 -Start with dma reset(-d)\n" 
	 " 2 -Flush the FIFO's(-f)\n"
	 " 3 -Then reset the application (-r)\n"  

	 "\n\n"
  
	 "Options:\n"
	 "  -l             Load pre-programmed seed.\n"
	 "  -q             Load and generate an unique seed.\n"
	 "  -g             Generate data from PCIe to PC.\n"
	 "  -b             Generate data from PC to PCIe.\n"
	 "  -s             Show application register.\n"
	 "  -r             Reset the application.\n"
	 "  -f             Flush the FIFO's.\n"
	 "  -d             Disable and reset the DMA controller.\n"
	 "  -h             Display help.\n\n",
	 APPLICATION_NAME);
}

void
application_reset()
{
  // Disable DMA controller
  wupper_dma_soft_reset(&wupper);
 }
 
 
 void
fifo_flush()
{
  // Flush FIFO's
  wupper_dma_fifo_flush(&wupper);
 }
 
 void
dma_reset()
{
  // Disable DMA controller
  *(wupper.dma_enable) = 0;
  wupper_dma_reset(&wupper);
 }

 
void
load_stdseed(uint64_t seed0, uint64_t seed1, uint64_t seed2, uint64_t seed3)
{
	printf("Writing seed to application register...");
    //set seed
    wupper_cfg_set_option(&wupper,"LFSR_SEED_0A",seed0);
    wupper_cfg_set_option(&wupper,"LFSR_SEED_0B",seed1);
    wupper_cfg_set_option(&wupper,"LFSR_SEED_1A",seed2);
    wupper_cfg_set_option(&wupper,"LFSR_SEED_1B",seed3);
    
  // reset LFSR with seed value
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",1);
   
  // release LFSR reset
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",0);
  printf("DONE! \n");
    
}

void
load_unqseed()
{
	
	//generate seed using rand()
	printf("generating new seed...");
	srand (time(NULL));
    uint64_t r0, r1, r2, r3;
    r0 = (uint64_t)rand()|((uint64_t)rand())<<32;
    r1 = (uint64_t)rand()|((uint64_t)rand())<<32;
    r2 = (uint64_t)rand()|((uint64_t)rand())<<32;
    r3 = (uint64_t)rand()|((uint64_t)rand())<<32;
    printf("DONE! \n");
    
    //set seed
    printf("Writing seed to application register...");
    wupper_cfg_set_option(&wupper,"LFSR_SEED_0A",r0);
    wupper_cfg_set_option(&wupper,"LFSR_SEED_0B",r1);
    wupper_cfg_set_option(&wupper,"LFSR_SEED_1A",r2);
    wupper_cfg_set_option(&wupper,"LFSR_SEED_1B",r3);
    
  // reset LFSR with seed value
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",1);
   
  // release LFSR reset
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",0);
  printf("DONE! \n");

}

void
start_application2pc()
{  
  int load_lfsr_seed = 1;
  int enable_datagen = 0;
  
  uint64_t *memptr;
  
  //select app mux 0 for LFSR
  wupper_cfg_set_option(&wupper,"APP_MUX",0);
  wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",01);

  int max_tlp = wupper_dma_max_tlp_bytes(&wupper);
  printf("Starting DMA write\n");
  wupper_dma_program_write(0, buffer1.phys_addr, 1024*1024, max_tlp, 0, &wupper, 1);
  wupper_dma_wait(0, &wupper);
  printf("done DMA write \n");
  
  printf("Buffer 1 addresses:\n");
  memptr = (uint64_t*)buffer1.virt_addr;
  int i;
  for(i=0; i<10;i++){
	  printf("%i: %lX \n",i, *(memptr++));
	  }  
	  
 wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
 fifo_flush();
 
 
}

void
start_application2PCIe()
{  
  uint64_t *memptr;
  
  //select app mux 1 for application in the firmware. 
  int max_tlp = wupper_dma_max_tlp_bytes(&wupper);
  
  printf("Reading data from buffer 1...\n");
  wupper_cfg_set_option(&wupper,"APP_MUX",1);
  wupper_dma_program_read(0, buffer1.phys_addr,  1024*1024, max_tlp, 0, &wupper, 0);
  wupper_dma_program_write(1, buffer2.phys_addr, 1024*1024, max_tlp, 0, &wupper, 0);
  wupper_dma_enable(&wupper, 3);
  //printf("DONE! \n");
  //printf("Writing multiplied data back ...");
  wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",10);
  
  wupper_dma_wait(0, &wupper);
  
  printf("DONE!\n");
    
  printf("Buffer 2 addresses:\n");
  memptr = (uint64_t*)buffer2.virt_addr;
  int i;
  for(i=0; i<10;i++){
	  printf("%i: %lX \n",i, *(memptr++));
	}


  //memptr = (uint64_t*)buffer1.virt_addr;
  //printf("\n%lX\n", *(memptr++) * *(memptr++));
wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
}

void
show_appreg()
{
  u_long reg_lfsr_seed_0a;
  u_long reg_lfsr_seed_0b;
  u_long reg_lfsr_seed_1a;
  u_long reg_lfsr_seed_1b;
  u_long reg_lfsr_load_seed;
  u_long reg_app_mux;
  
  printf("\nStatus application registers\n");
  printf("----------------------------\n");
  
  wupper_cfg_get_option(&wupper,"LFSR_SEED_0A",&reg_lfsr_seed_0a);
  printf("LFSR_SEED_0A:        %lX \n",reg_lfsr_seed_0a);
  wupper_cfg_get_option(&wupper,"LFSR_SEED_0B",&reg_lfsr_seed_0b);
  printf("LFSR_SEED_0B:        %lX \n",reg_lfsr_seed_0b);
  wupper_cfg_get_option(&wupper,"LFSR_SEED_1A",&reg_lfsr_seed_1a);
  printf("LFSR_SEED_1A:        %lX \n",reg_lfsr_seed_1a);
  wupper_cfg_get_option(&wupper,"LFSR_SEED_1B",&reg_lfsr_seed_1b);
  printf("LFSR_SEED_1B:        %lX \n",reg_lfsr_seed_1b);
  wupper_cfg_get_option(&wupper,"APP_MUX",&reg_app_mux);
  printf("APP_MUX:             %lX \n",reg_app_mux);
  wupper_cfg_get_option(&wupper,"LFSR_LOAD_SEED",&reg_lfsr_load_seed);
  printf("LFSR_LOAD_SEED:      %lX \n",reg_lfsr_load_seed);
  printf("\n");
  
 }

int
main(int argc, char** argv)
{
  u_int ret;
  int opt;
  
  if(cmem_open(&cmem)!=0){printf("Could not open CMEM");} 
	
  if(cmem_alloc(&buffer1, &cmem, 1024*1024)!=0)
  {
	printf("Could not allocate CMEM for buffer 1");
  }
 
	if(cmem_alloc(&buffer2, &cmem, 1024*1024)!=0)
	{
		printf("Could not allocate CMEMfor buffer 2");
	}
  
  //cmem_alloc(1024*1024, &buffer1);
  //cmem_alloc(1024*1024, &buffer2);
  

  while ((opt = getopt(argc, argv,"lgbqhsrfd")) != -1) {
    switch (opt) {
    case 'l':
// load pre-seed
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
     
	  load_stdseed(0xDEADBEEFABCD0123, 0x87613472FEDCABCD, 0xDEADFACEABCD0123, 0x12313472FEDCFFFF);
	  
	if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     }
      break;
      case 'q':
// load unique seed
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
     
	  load_unqseed();
	  
	if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     }
      break;
      case 'g':
// generate data from PCIe->PC
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
     
	  start_application2pc();
	  
	if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     }
      break;
      case 'b':
// read data from PC memory, multiplies the data and write back to PC memory.
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
     
	  start_application2PCIe();
	  
	if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     }
      break;
    case 's':
// show app registers
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
     
	  show_appreg();
	  
	if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     }
      break;
    case 'r':
// Reset the application
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
      printf("resetting application...");
      application_reset();

      printf("DONE! \n");
      
     if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     } 
      
      break;
      case 'f':
// Flush the FIFO's
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
      printf("Flushing the FIFO's...");
      fifo_flush();

      printf("DONE! \n");
      
     if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     } 
      
      break;
      case 'd':
// Disable and reset the DMA controller
	if(wupper_open(&wupper,  device_number))
	 {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
     }
      printf("Resetting the DMA controller...");
      dma_reset();

      printf("DONE! \n");
      
     if(wupper_close(&wupper))
     {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
     } 
      
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
  
  cmem_free(&buffer1);
  cmem_free(&buffer2);
  cmem_close(&cmem);

  return(0);
}
