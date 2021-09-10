set VHDL_FILES [concat $VHDL_FILES \
  pcie/pcie_package.vhd \
  pcie/dma_control.vhd \
  pcie/register_map_sync.vhd \
  pcie/wupper.vhd \
  pcie/pcie_clocking.vhd \
  pcie/pcie_slow_clock.vhd \
  pcie/dma_read_write.vhd \
  pcie/intr_ctrl.vhd \
  pcie/wupper_core.vhd \
  pcie/pcie_ep_wrap.vhd \
  pcie/pcie_init.vhd \
  pcie/WupperFifos.vhd]

set SIM_FILES [concat $SIM_FILES \
  Wupper/wupper_tb.vhd \
  Wupper/pcie_ep_sim_model.vhd]
  
  
set XCI_FILES [concat $XCI_FILES \
  clk_wiz_regmap.xci]

#Kintex Ultrascale specific files
set VHDL_FILES_KU [concat $VHDL_FILES_KU \
  pcie/data_width_package_256.vhd]

set XCI_FILES_KU [concat $XCI_FILES_KU \
  pcie3_ultrascale_7038.xci \
  pcie3_ultrascale_7039.xci]

#Virtex 7 specific files
set VHDL_FILES_V7 [concat $VHDL_FILES_V7 \
  pcie/data_width_package_256.vhd]

set XCI_FILES_V7 [concat $XCI_FILES_V7 \
  pcie_x8_gen3_3_0.xci]

#Virtex Ultrascale+ VU9P specific files
set XCI_FILES_VU9P [concat $XCI_FILES_VU9P \
  pcie4c_uscale_plus_0.xci \
  pcie4c_uscale_plus_1.xci ]
  
set VHDL_FILES_VU9P [concat $VHDL_FILES_VU9P \
  pcie/data_width_package_512.vhd]

#Virtex Ultrascale+ VU37P specific files
set XCI_FILES_VU37P [concat $XCI_FILES_VU37P \
  pcie4c_uscale_plus_0.xci \
  pcie4c_uscale_plus_1.xci]
  
set VHDL_FILES_VU37P [concat $VHDL_FILES_VU37P \
  pcie/data_width_package_512.vhd]
#set XCI_FILES_VERSAL [concat $XCI_FILES_VERSAL \
#  ila_0.xci]

set VHDL_FILES_VERSAL [concat $VHDL_FILES_VERSAL \
  pcie/data_width_package_512.vhd]
  
set BD_FILES_VERSAL [concat $BD_FILES_VERSAL \
  versal_pcie_block.bd]

