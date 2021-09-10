/*******************************************************************/
/*                                                                 */
/* This is the C++ source code of the wupper-irq-test application     */
/*                                                                 */
/* Author: Markus Joos, CERN                                       */
/*                                                                 */
/**C 2019 Ecosoft - Made from at least 80% recycled source code*****/


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

#include "version.h"
#include "DFDebug/DFDebug.h"
#include "wuppercard/WupperCard.h"
#include "wuppercard/WupperException.h"

#define APPLICATION_NAME    "wupper-irq-test"

//Globals
WupperCard wupperCard;

//arguments for wait_for_irq
struct arg_struct{
  int card;
  int interrupt;
  int thread_no;
  arg_struct(int c, int i, int t){card=c; interrupt=i; thread_no=t;}
};


/*************************/
void *wait_for_irq(void *a)
/*************************/
{
  WupperCard wupperCardpthread;
  
  struct arg_struct *args = (arg_struct*) a;

  int interrupt = args->interrupt;
  int card = args->card;
  int t_num = args->thread_no;

  printf("[Thread %i] waiting for interrupt %i on card %i \n", t_num, interrupt, card);
  
  wupperCardpthread.card_open(card, 0);
  printf("[Thread %i] card %d opened.\n", t_num, card);

  wupperCardpthread.irq_enable(interrupt);
  printf("[Thread %i] irq %d enabled on card = %d\n", t_num, interrupt, card);

  printf("[Thread %i] Waiting for interrupt %i on card %d ...\n", t_num,  interrupt, card);
  fflush(stdout);
  wupperCardpthread.irq_wait(interrupt);
  printf("[Thread %i] OK! Received interrupt %i from card %i\n", t_num, interrupt, card);
    
  wupperCardpthread.irq_disable(interrupt);
  printf("[Thread %i] irq %d disabled on card = %d\n", t_num, interrupt, card);
  
  wupperCardpthread.card_close();
  printf("[Thread %i] card %d closed.\n", t_num, card);
  
  return NULL;
}


/*****************/
void display_help()
/*****************/
{
  printf("Usage: %s [OPTIONS]\n", APPLICATION_NAME);
  printf("Waits for an interrupt.\n\n");
  printf("Options:\n");
  printf("  -i NUMBER      Wait for the interrupt indicated by NUMBER. Default: 5.\n");
  printf("  -d NUMBER      Use card indicated by NUMBER. Default: 0.\n");
  printf("  -t level       Create a S/W interrupt of the specified level (0..7))\n"); 
  printf("  -T             Start 2 pthreads, both waiting for IRQ 4 but on 2 different cards\n"); 
  printf("  -D level       Configure debug output at API level. 0=disabled, 5, 10, 20 progressively more verbose output. Default: 0.\n");
  printf("  -h             Display help.\n");
  printf("  -V             Display the version number\n");
}


/*****************************/
int main(int argc, char **argv)
/*****************************/
{
  int debuglevel, device_number = 0, irq_id = 5, opt, sw_irq = 9, dual_thread = 0, iret1, iret2;
  pthread_t thread1, thread2;

  while((opt = getopt(argc, argv, "hi:d:D:Vt:T")) != -1)
  {
    switch (opt)
    {
      case 'd':
	device_number = atoi(optarg);
	break;

      case 'i':
	irq_id = atoi(optarg);
	break;

      case 'D':
	debuglevel = atoi(optarg);
        DF::GlobalDebugSettings::setup(debuglevel, DFDB_FELIXCARD);
	break;

      case 'h':
	display_help();
	exit(0);

      case 't':
	sw_irq = atoi(optarg);
	break;
	
      case 'T':
	dual_thread = 1;
	break;
	
      case 'V':
        printf("This is version %s of %s\n", VERSION, APPLICATION_NAME);
	exit(0);

      default:
	fprintf(stderr, "Usage: %s COMMAND [OPTIONS]\nTry %s -h for more information.\n", APPLICATION_NAME, APPLICATION_NAME);
	exit(-1);
    }
  }

  if(dual_thread)
  {
    //first argument = card, second = interrupt, thid = thread number
    arg_struct arg1 = arg_struct(device_number, 4, 0);
    arg_struct arg2 = arg_struct(device_number, 7, 1);

    iret1 = pthread_create(&thread1, NULL, wait_for_irq, (void*)&arg1);
    //sleep(2);
    iret2 = pthread_create(&thread2, NULL, wait_for_irq, (void*)&arg2);
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL); 

    printf("[Main] Thread 0 returns: %d\n", iret1);
    printf("[Main] Thread 1 returns: %d\n", iret2);
  }
  else
  {
    try
    {   
      wupperCard.card_open(device_number, 0);
      if(sw_irq < 8)
      {       
	wupperCard.cfg_set_option(BF_INT_TEST_IRQ, sw_irq);
      }
      else
      {    
	wupperCard.irq_enable(irq_id);

	printf("Waiting for interrupt %d...", irq_id);
	fflush(stdout);
	wupperCard.irq_wait(irq_id);
	printf(" ok!\n");

	wupperCard.irq_disable(irq_id);
      }

      wupperCard.card_close();
    }
    catch(WupperException &ex)
    {
      std::cout << "ERROR. Exception thrown: " << ex.what() << std:: endl;
      exit(-1);
    }
  }

  return 0;
}

