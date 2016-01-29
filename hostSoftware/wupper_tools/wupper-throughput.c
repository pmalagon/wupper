/**
  *    ------------------------------------------------------------------------------
  *                                                              
  *            NIKHEF - National Institute for Subatomic Physics 
  *  
  *                        Electronics Department                
  *                                                              
  *  ----------------------------------------------------------------------------
  *  @class wupper-througput
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
  *  @brief wupper-througput.c is an application that measures the
  *  throughput of the DMA engine. The unity is in GigaBytes per 
  *  second.
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
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#include "wupper.h"


#define DMA_ID (0)
#define BUFSIZE (65536)
#define APPLICATION_NAME "wupper-throughput"
wupper_dev_t wupper;
cmem_buffer_t buffer;
cmem_dev_t cmem;

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
  //select app mux 0 for LFSR
  wupper_cfg_set_option(&wupper,"APP_MUX",0);
  wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",01);
  //wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
}


void
display_help()
{
  printf("Usage: %s [OPTIONS]\n"
	 "Reads raw data from a WUPPER and writes them into a file.\n\n"
	 "Options:\n"
	 "  -d NUMBER      Use card indicated by NUMBER. Default: 0.\n"
	 "  -b NUM         Use a buffer of size NUM blocks. Default: 100.\n"
	 "  -w             Use circular buffer wraparound mechanism.\n"
	 "  -h             Display help.\n",
	 APPLICATION_NAME);
}

extern double now();

int
main(int argc, char** argv)
{
  int device_number = 0;
  int nblocks = 100;
  int wraparound = 0;
  int opt;

  

  while ((opt = getopt(argc, argv, "hd:b:w")) != -1) {
    switch (opt) {
    case 'd':
      device_number = atoi(optarg);
      break;
    case 'b':
      nblocks = atoi(optarg);
      break;
    case 'w':
      wraparound = 1;
      break;
    case 'h':
      display_help();
      exit(EXIT_SUCCESS);
    default: /* '?' */
      fprintf(stderr, "Usage: %s [OPTIONS]\nTry %s -h for more information.\n",
	      APPLICATION_NAME, APPLICATION_NAME);
      exit(EXIT_FAILURE);
    }
  }


  if(wupper_open(&wupper,  device_number))
    {
      fprintf(stderr, APPLICATION_NAME": error: could not open WUPPER %d\n", device_number);
      return 1;
    }

  wupper_dma_stop(DMA_ID, &wupper);
  *(wupper.dma_enable) = 0;
  wupper_dma_reset(&wupper);
  wupper_dma_soft_reset(&wupper);
  wupper_dma_fifo_flush(&wupper);

  
  // start LFSR
  load_unqseed();
  if(cmem_open(&cmem)!=0){printf("Could not open CMEM");} 
  
  if(cmem_alloc(&buffer, &cmem, BUFSIZE*nblocks)!=0)
	{
		printf("Could not allocate CMEM for buffer 1");
    }
  
  //cmem_alloc(BUFSIZE*nblocks, &buffer);
  int max_tlp = wupper_dma_max_tlp_bytes(&wupper);

  double timedelta = 2;
  double t0 = now();
  unsigned long long blocks_read = 0;
   printf("start app\n");
   start_application2pc();
  
  if(wraparound)
    {
      fprintf(stderr, "TODO: wraparound support not fully implemented yet.\n");
      wupper_dma_program_write(DMA_ID, buffer.phys_addr, BUFSIZE*nblocks, max_tlp, WUPPER_DMA_WRAPAROUND, &wupper, 1);
    }

  while(1)
    {
      if(wraparound)
	{
	  // TODO: Wait for data interrupt
	  wupper_dma_advance_read_ptr(DMA_ID, buffer.phys_addr, buffer.size,
				    BUFSIZE*nblocks, &wupper);
	  blocks_read += nblocks;
	}
      else
	{
	  wupper_dma_program_write(DMA_ID, buffer.phys_addr, BUFSIZE*nblocks, max_tlp, 0, &wupper, 1);
	  wupper_dma_wait(DMA_ID, &wupper);
	  blocks_read += nblocks;
	}

      double t1 = now();
      if(t1-t0 > timedelta)
	{
	  printf("Blocks read:  %lld\n", blocks_read);
	  printf("Blocks rate:  %f blocks/s\n", blocks_read/(t1-t0));
	  //printf("DMA Read:     %f GiB/s\n", blocks_read/((1024.*1024.)/(t1-t0)));
	  printf("DMA Read:     %lf GiB/s\n", (double)blocks_read*BUFSIZE/((t1-t0)*1024*1024*1024));
	  printf("\n");
	  blocks_read = 0;
	  t0 = t1;
	  
	}
    }

  wupper_cfg_set_option(&wupper,"ENABLE_APPLICATION",00);
  
  if(cmem_free(&buffer))
 {
  fprintf(stderr, APPLICATION_NAME": error: could not free CMEM buffer\n");
  return 1;
 }
  
  cmem_close(&cmem);

  if(wupper_close(&wupper))
    {
      fprintf(stderr, APPLICATION_NAME": error: could not close WUPPER %d\n", device_number);
      return 1;
    }
}

