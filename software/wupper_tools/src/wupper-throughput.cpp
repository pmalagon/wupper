/*******************************************************************/
/*                                                                 */
/* This is the C++ source code of the wupper-throughput application   */
/*                                                                 */
/* Author: Markus Joos, CERN                                       */
/*                                                                 */
/**C 2017 Ecosoft - Made from at least 80% recycled source code*****/


#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <time.h>
#include <signal.h>
#include "version.h"

#include "DFDebug/DFDebug.h"
#include "cmem_rcc/cmem_rcc.h"
#include "rcc_error/rcc_error.h"
#include "wuppercard/WupperCard.h"
#include "wuppercard/WupperException.h"

#define DMA_ID              0
#define BLOCKSIZE           1024
#define APPLICATION_NAME    "wupper-throughput"


//Globals
WupperCard wupperCard;
int cont;


//Prototypes
void SigQuitHandler(int /*signum*/);


/*********************************/
void SigQuitHandler(int /*signum*/)
/*********************************/
{
  cont = 0;
}


/*****************/
void display_help()
/*****************/
{
  printf("Usage: %s [OPTIONS]\n", APPLICATION_NAME);
  printf("Reads raw data from a WUPPER and writes them into a file.\n\n");
  printf("Options:\n");
  printf("  -d NUMBER      Use card indicated by NUMBER. Default: 0.\n");
  printf("  -b NUM         Use a buffer of size NUM blocks. Default: 100 blocks of 1 KB each.\n");
  printf("  -o NUM         Terminate the program after NUM DMAs. Default: (0), run forever\n");
  printf("  -w             Use circular buffer wraparound mechanism.\n");
  printf("  -D level       Configure debug output at API level. 0=disabled, 5, 10, 20 progressively more verbose output. Default: 0.\n");
  printf("  -h             Display help.\n");
  printf("  -V             Display the version number\n");
}


/**********/
double now()
/**********/
{
  struct timespec tp;

  clock_gettime(CLOCK_MONOTONIC, &tp);
  return tp.tv_sec + 1e-9 * tp.tv_nsec;
}


/*****************************/
int main(int argc, char **argv)
/*****************************/
{
  int debuglevel, handle, ret, loop, device_number = 0, nblocks = 100, wraparound = 0, opt, maxops = 0;
  double timedelta = 2, t0, t1;
  u_long bsize, paddr, blocks_read = 0;
  int sa_stat;
  static struct sigaction sa;
  
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = 0;
  sa.sa_handler = SigQuitHandler;
  sa_stat = sigaction(SIGINT, &sa, NULL);
  if (sa_stat < 0)
  {
    printf("Cannot install signal handler (error = %d)\n", sa_stat);
    exit(0);
  }

  while((opt = getopt(argc, argv, "hd:b:wD:Vo:")) != -1)
  {
    switch (opt)
    {
      case 'd':
        device_number = atoi(optarg);
        break;

      case 'b':
        nblocks = atoi(optarg);
        break;

      case 'o':
        maxops = atoi(optarg);
        break;

      case 'D':
        debuglevel = atoi(optarg);
        DF::GlobalDebugSettings::setup(debuglevel, DFDB_FELIXCARD);
        break;

      case 'w':
        wraparound = 1;
        break;

      case 'h':
        display_help();
        exit(0);

      case 'V':
        printf("This is version %s of %s\n", VERSION, APPLICATION_NAME);
        exit(0);

      default:
        fprintf(stderr, "Usage: %s [OPTIONS]\nTry %s -h for more information.\n", APPLICATION_NAME, APPLICATION_NAME);
        exit(-1);
    }
  }

  try
  {
    wupperCard.card_open(device_number, LOCK_DMA0); //Note: if DMA_ID is changed the lock bit has to be adapted

    for(loop = 0; loop < 8; loop++)
      wupperCard.dma_stop(loop);

    wupperCard.dma_reset();
    wupperCard.soft_reset();
    //wupperCard.dma_fifo_flush();

    ret = CMEM_Open();
    bsize = BLOCKSIZE * nblocks;
    if (!ret)
      ret = CMEM_GFPBPASegmentAllocate(bsize, (char *)"WupperThroughput", &handle);

    if (!ret)
      ret = CMEM_SegmentPhysicalAddress(handle, &paddr);

    if (ret)
    {
      rcc_error_print(stdout, ret);
      exit(-1);
    }

    t0 = now();
    t1 = now();
    cont = 1;

    if(wraparound)
    {
      printf("Terminate the program with ctrl-c\n");
      wupperCard.irq_clear(1); // A function to init/reset an interrupt (not available yet)
      wupperCard.irq_enable(1); // ToHost wrap-around interrupt
      wupperCard.dma_to_host(DMA_ID, paddr, bsize, WUPPER_DMA_WRAPAROUND);
    }

    while(cont)
    {
      if(wraparound)
      {
        wupperCard.irq_wait(1); // Wait for ToHost wrap-around
        wupperCard.dma_advance_ptr(DMA_ID, paddr, bsize, bsize);
        blocks_read += nblocks;
      }
      else
      {
        wupperCard.dma_to_host(DMA_ID, paddr, bsize, 0);
        wupperCard.dma_wait(DMA_ID);
        blocks_read += nblocks;
      }

      t1 = now();
      if(t1 - t0 > timedelta)
      {
        double delta = t1-t0;
        t0 = t1;
        printf("Blocks read:  %lu\n", blocks_read);
        printf("Blocks rate:  %.3f blocks/s\n", blocks_read / (delta));

        double dmaperformance =  ((double)blocks_read * (double)BLOCKSIZE) / (delta * 1024. * 1024.);
        printf("DMA Read:     %.3f MiB/s\n", dmaperformance);

        printf("\n");
        blocks_read = 0;
        
      }

      if(maxops)
      {
        maxops--;
         if(maxops == 0)
           cont = 0;
      }
    }

    printf("Loop terminated. Cleaning up....\n");
    
    wupperCard.irq_disable(1);                                                 // ToHost wrap-around interrupt

    ret = CMEM_SegmentFree(handle);
    if (!ret)
      ret = CMEM_Close();
    if (ret)
      rcc_error_print(stdout, ret);

    wupperCard.card_close();
  }
  catch(WupperException &ex)
  {
    std::cout << "ERROR. Exception thrown: " << ex.what() << std:: endl;
    exit(-1);
  }

  exit(0);
}
