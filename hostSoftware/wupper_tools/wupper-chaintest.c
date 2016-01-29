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
  *  @brief wupper-chaintest.c is for testing purpose. It multiplies the
  *  data in buffer 2 and compares it with the output of the multiplier. 
  * 
  *   
  *  @detail
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

#define APPLICATION_NAME "wupper-chaintest"
#define device_number     0

wupper_dev_t wupper;
cmem_dev_t cmem;
cmem_buffer_t buffer1;
cmem_buffer_t buffer2;
uint64_t t;



void
start_datagen()
{ 


  //generate seed using rand()
  srand (time(NULL));
  uint64_t r0, r1, r2, r3;
  r0 = (uint64_t)rand()|((uint64_t)rand())<<32;
  r1 = (uint64_t)rand()|((uint64_t)rand())<<32;
  r2 = (uint64_t)rand()|((uint64_t)rand())<<32;
  r3 = (uint64_t)rand()|((uint64_t)rand())<<32;
  
  //set seed
  //qDebug() << "Writing seed to application register...";
  wupper_cfg_set_option(&wupper,"LFSR_SEED_0A",r0);
  wupper_cfg_set_option(&wupper,"LFSR_SEED_0B",r1);
  wupper_cfg_set_option(&wupper,"LFSR_SEED_1A",r2);
  wupper_cfg_set_option(&wupper,"LFSR_SEED_1B",r3);
  
  // reset LFSR with seed value
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",1);
  
  // release LFSR reset
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",0);
  int load_lfsr_seed = 1;
  int enable_datagen = 0;
  
  uint64_t *memptr;
  
  //select app mux 0 for LFSR
  wupper_cfg_set_option(&wupper,"APP_MUX",0);
  wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",1);

  int max_tlp = wupper_dma_max_tlp_bytes(&wupper);
  wupper_dma_program_write(0, buffer1.phys_addr, 1024*1024, max_tlp, 0, &wupper, 1);
  wupper_dma_wait(0, &wupper);
  
	  
 wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",0);
 wupper_dma_fifo_flush(&wupper);
}

void
start_mul()
{  
  uint64_t *memptr;
  
  //select app mux 1 for application in the firmware. 
  int max_tlp = wupper_dma_max_tlp_bytes(&wupper);
  
  printf("Reading data from buffer 1...\n");
  wupper_cfg_set_option(&wupper,"APP_MUX",1);
  wupper_dma_program_read(0, buffer1.phys_addr,  1024*1024, max_tlp, 0, &wupper, 0);
  wupper_dma_program_write(1, buffer2.phys_addr, 1024*1024, max_tlp, 0, &wupper, 0);
  wupper_dma_enable(&wupper, 3);
  wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",2);
  wupper_dma_wait(0, &wupper);
  wupper_dma_wait(1, &wupper);
  printf("DONE!\n");
  printf("Buffer 2 addresses:\n");
  memptr = (uint64_t*)buffer2.virt_addr;
  int i;
  for(i=0; i<10;i++){
	  printf("%i: %lX \n",i, *(memptr++));
	}


	wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",0);
}

void 
compare_buf(void)
{
	uint64_t *memptr1;
	uint64_t *memptr2;
	memptr1 = (uint64_t*)buffer1.virt_addr;
	memptr2 = (uint64_t*)buffer2.virt_addr;
  int i;
  __uint128_t num1, num2, num3, num4, num5;
  int errors = 0;
  int j=0;
	  
  for(i=0; i<1024*64;i++){
	  num1 = (__uint128_t) *(memptr1++);
	  num2 = (__uint128_t) *(memptr1++);
	  num3 = num1 * num2;
	  
	  //printf("%i: %lX * %lX = %lX %lX\n",i, (uint64_t)num1, (uint64_t)num2, (uint64_t)num3, (uint64_t)(num3>>64));
	  
	  num4 = (__uint128_t) *(memptr2++);
	  num5 = (__uint128_t) *(memptr2++);
	  
	  num5 <<= 64;
	  num5 |= num4;
	  if (num3 != num5)
	  {
			uint64_t addr = (uint64_t)memptr1-0x10 - (uint64_t)buffer1.virt_addr+ (uint64_t)buffer1.phys_addr;
		  if(j<10)printf("%lX (%lX * %lX) = %lX %lX != %lX %lX\n", addr, (uint64_t)num1, (uint64_t)num2, (uint64_t)(num3>>64), (uint64_t)(num3), (uint64_t)(num5>>64), (uint64_t)(num5));
		  j++;
			errors++;
		  
	  } 
	  
	}
	
	printf("%i errors out of %i\n", errors, 1024*64);  
}

int
main(int argc, char** argv)
{
	// wupper openen
	if(cmem_open(&cmem)!=0){printf("Could not open CMEM");} 
	
	if(cmem_alloc(&buffer1, &cmem, 1024*1024)!=0)
	{
		printf("Could not allocate CMEM for buffer 1");
    }
        
	if(cmem_alloc(&buffer2, &cmem, 1024*1024)!=0)
	{
		printf("Could not allocate CMEM for buffer 2");
	}

  if(wupper_open(&wupper,  device_number))
  {
	fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
	//return 1;
  }

	
	start_datagen();
	start_mul();
	
	compare_buf();
	
	cmem_free(&buffer1);
	cmem_free(&buffer2);
    cmem_close(&cmem);

  wupper_close(&wupper);
    //wupper sluiten!
    
    return 0;
}
