#do_implementation_pre.tcl
#some defaults:


set STOP_TO_ADD_ILA 0

set BLOCKSIZE 1024


set NUMBER_OF_INTERRUPTS 8
#1 descriptor ToHost, 1 FromHost.
set NUMBER_OF_DESCRIPTORS 2

set PCIE_LANES 8
set DATA_WIDTH 256

set NUM_LEDS 8
#Number of PCIe endpoints in the design (Set to 2 for BNL711 / BNL712)
set ENDPOINTS 1

#Set to true to do a few more rounds of phys_opt_design and even route_design 
#if timing is not met (se do_implementation_finish.tcl)
set KEEP_TRYING_TO_MEET_TIMING false

source ../helper/vivado_set_severity.tcl

