/************************************************************************/
/*									*/
/*  This is the common header file for the CMEM_RCC driver & library	*/
/*									*/
/*  12. Dec. 01  MAJO  created						*/
/*									*/
/*******C 2005 - The software with that certain something****************/

#ifndef _CMEM_RCC_IOCTL_H
#define _CMEM_RCC_IOCTL_H

#include "cmem_rcc_common.h"

// Constants
#define MAX_BUFFS          1000    // Max. number of buffers for all processes
#define MAX_PROC_TEXT_SIZE 0x10000 // The output of "more /proc/cmem_rcc" must not generate more characters than that

/********/
/*Macros*/
/********/
#ifdef DRIVER_DEBUG
  #define kdebug(x) {if (debug) printk x;}
#else
  #define kdebug(x)
#endif

#ifdef DRIVER_ERROR
  #define kerror(x) {if (errorlog) printk x;}
#else
  #define kerror(x)
#endif


// Types
typedef struct
{
  u_int buffer[MAX_BUFFS];
} private_stuff;  

struct cmem_proc_data_t
{
  char name[10];
  char value[100];
};

typedef struct range_struct 
{
  struct range_struct *next;
  void *base;			// base of allocated block 
  size_t size;			// size in bytes 
} range_t;

#endif

