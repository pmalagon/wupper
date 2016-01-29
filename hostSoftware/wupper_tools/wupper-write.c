/**
  *    ------------------------------------------------------------------------------
  *                                                              
  *            NIKHEF - National Institute for Subatomic Physics 
  *  
  *                        Electronics Department                
  *                                                              
  *  ----------------------------------------------------------------------------
  *  @class wupper-write
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
  *  @brief wupper-read.c writes pseudo randomdata to PC memory. 
  *  The size of the data is 256 bits. The datagenerator is based
  *  on a LFSR. User can give this application a seed or load
  *  a pre-programmed seed. 
  *
  * 
  * 
  *   
  *  @detail
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

#include "wupper.h"

#define APPLICATION_NAME "wupper-write"




void
display_help()
{
  printf("Usage: %s [OPTIONS]\n"
	 "loading seed.\n\n"
	 "Options:\n"
	 "  -l             load pre-programmed seed.\n"
	 "  -h             Display help.\n",
	 APPLICATION_NAME);
}

int
main(int argc, char** argv)
{
  u_int ret;
  int opt;
  int device_number = 0;
  wupper_dev_t wupper;
 
  
  u_long reg_lfsr_seed_0a;
  
  uint64_t *memptr;
  
  //standard seed (256bit) DEAD_BEEF_ABCD_0123_8761_3472_FEDC_ABCD_DEAD_BEEF_ABCD_0123_8761_3472_FEDC_ABCD
  uint64_t seed_0a = 0xDEADBEEFABCD0123;
  uint64_t seed_0b = 0x87613472FEDCABCD;
  uint64_t seed_1a = 0xDEADFACEABCD0123;
  uint64_t seed_1b = 0x12313472FEDCFFFF;
  
  int load_lfsr_seed = 1;
  int enable_datagen = 0;


  while ((opt = getopt(argc, argv,"lh:")) != -1) {
    switch (opt) {
    case 'l':
// load pre-seed
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
  

  if(wupper_open(&wupper,  device_number))
    {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
    }
  // Disable DMA controller
  *(wupper.dma_enable) = 0;
  wupper_dma_reset(&wupper);
  wupper_dma_soft_reset(&wupper);
  wupper_dma_fifo_flush(&wupper);
    
  // get info of seed  
  wupper_cfg_get_option(&wupper,"LFSR_SEED_0A",&reg_lfsr_seed_0a);
  printf("%lX \n",reg_lfsr_seed_0a);  
  
  //set seed
  wupper_cfg_set_option(&wupper,"LFSR_SEED_0A",seed_0a);
  wupper_cfg_set_option(&wupper,"LFSR_SEED_0B",seed_0b);
  wupper_cfg_set_option(&wupper,"LFSR_SEED_1A",seed_1a);
  wupper_cfg_set_option(&wupper,"LFSR_SEED_1B",seed_1b);
  
  // reset LFSR with seed value
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",1);
  // release LFSR reset
  wupper_cfg_set_option(&wupper,"LFSR_LOAD_SEED",0);
  
  //select app mux 0 for LFSR
  wupper_cfg_set_option(&wupper,"APP_MUX",0);
  
  // get info of seed  
  wupper_cfg_get_option(&wupper,"LFSR_SEED_0A",&reg_lfsr_seed_0a);
  printf("%lX \n",reg_lfsr_seed_0a);
  

  // Allocate memory in PC
  cmem_buffer_t buffer;
  cmem_dev_t cmem;
  
  if(cmem_open(&cmem)!=0){printf("Could not open CMEM");} 
	
	if(cmem_alloc(&buffer, &cmem, 1024*1024)!=0)
	{
		printf("Could not allocate CMEM for buffer 1");
    }

  //cmem_alloc(1024*1024, &buffer);
  printf("done cmem alloc \n");
  //cmem_buffer_t rd_buffer;
  //cmem_alloc(1024*1024, &rd_buffer);

  int max_tlp = wupper_dma_max_tlp_bytes(&wupper);

  wupper_dma_program_write(0, buffer.phys_addr, 1024*1024, max_tlp, 0, &wupper, 1);
  printf("done dma write \n");
  wupper_dma_wait(0, &wupper);
  printf("done waiting \n");
  //wupper_dma_program_read(1, rd_buffer.phys_addr, 1024*1024, max_tlp, 0, &wupper);
  memptr = (uint64_t*)buffer.virt_addr;
  int i;
  for(i=0; i<10;i++){
	  printf("%i: %lX \n",i, *(memptr++));
	  }
  cmem_free(&buffer);
  cmem_close(&cmem);
  //cmem_free(&rd_buffer);

  if(wupper_close(&wupper))
    {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
    }
  
  return(0);
}
