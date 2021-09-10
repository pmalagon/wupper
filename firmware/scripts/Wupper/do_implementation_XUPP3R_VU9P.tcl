source ../helper/do_implementation_pre.tcl
#Uncomment in order to stop after synthesis, so ILA probes can be added.
#set STOP_TO_ADD_ILA 1
set CARD_TYPE 800
set NUM_LEDS 4
set PCIE_LANES 8
set DATA_WIDTH 512
set ENDPOINTS 1

source ../helper/do_implementation_post.tcl
