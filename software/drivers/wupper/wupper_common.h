/**
  *    ------------------------------------------------------------------------------
  *                                                              
  *            NIKHEF - National Institute for Subatomic Physics 
  *  
  *                        Electronics Department                
  *                                                              
  *  ----------------------------------------------------------------------------
  *  @class wupper_common
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
  *  @brief This is the common header file for the wupper
  *  driver, library & applications				                                     
  * 
  *  @detail
  *                                      
  *  ------------------------------------------------------------------------------
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
#ifndef _WUPPER_COMMON_H
#define _WUPPER_COMMON_H

#ifdef __KERNEL__
  #include <linux/types.h>
#else
  #include <sys/types.h>
#endif


/* ioctl "switch" flags */
#define WUPPER_MAGIC 'y'

#define GETCARDS            _IOW(WUPPER_MAGIC, 1, int)
#define SETCARD             _IOR(WUPPER_MAGIC, 2, card_params_t*)
#define GET_TLP             _IOW(WUPPER_MAGIC, 3, int)
#define WAIT_IRQ            _IOW(WUPPER_MAGIC, 4, u_int)
#define CANCEL_IRQ_WAIT     _IOW(WUPPER_MAGIC, 5, u_int)
#define CLEAR_IRQ           _IOW(WUPPER_MAGIC, 6, u_int)
#define RESET_IRQ_COUNTERS  _IOW(WUPPER_MAGIC, 7, u_int)
#define MASK_IRQ            _IOW(WUPPER_MAGIC, 8, int)
#define UNMASK_IRQ          _IOW(WUPPER_MAGIC, 9, int)
#define GETLOCK             _IOW(WUPPER_MAGIC, 10, u_int)
#define RELEASELOCK         _IOW(WUPPER_MAGIC, 11, u_int)
//#define WRITE_REGISTER      _IOW(WUPPER_MAGIC, 10, wupper_register_t*)
//#define READ_REGISTER       _IOW(WUPPER_MAGIC, 11, wupper_register_t*)

//typedef struct
//{
//  u_int handle;
//  u_int offs;
//  u_int func;
//  u_int data;
//  u_int size;
//} IO_PCI_CONF_t;

#define MAXCARDS	8   // Max. number of WUPPER cards
#define MAXLOCKBITS     32  // Max. number of lockable resources. NOTE: do not increase to more than 32 because global_locks in the driver is an int

typedef struct
{
    struct pci_dev *pciDevice;
    unsigned int slot;
    unsigned long int baseAddressBAR0;
    unsigned long int sizeBAR0;
    unsigned long int baseAddressBAR1;
    unsigned long int sizeBAR1;
    unsigned long int baseAddressBAR2;
    unsigned long int sizeBAR2;
    unsigned long int baseAddressBAR3;
    unsigned long int sizeBAR3;
    u_int lock_mask;          //used in the SETCARD ioctl to receive the lock bits form the user application
    u_int lock_tag;           //used to separate the locks of different WupperCard objects in the same thread
    u_int lock_error;         //used in the SETCARD ioctl to return locking related errors to the user code
} card_params_t;

typedef struct
{
    u_int slot;
    u_int lock_tag;           //used to separate the locks of different WupperCard objects in the same thread
} lock_params_t;


#endif



