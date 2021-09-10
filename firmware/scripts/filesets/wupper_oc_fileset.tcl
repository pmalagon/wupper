#FPGA series specific files 
  
set VHDL_FILES [concat $VHDL_FILES \
  toplevel/wupper_oc_top.vhd \
  Wishbone/wb_intercon.vhd \
  Wishbone/wb_memory.vhd \
  Wishbone/wb_syscon.vhd \
  Wishbone/wishbone_pkg.vhd \
  Wishbone/wupper_to_wb.vhd \
  Wishbone/xwb_crossbar.vhd]
 
set XDC_FILES_KCU105 [concat $XDC_FILES_KCU105 \
  pcie_dma_top_KCU105.xdc]

set XDC_FILES_VCU128 [concat $XDC_FILES_VCU128 \
  pcie_dma_top_VCU128.xdc]
  
set XDC_FILES_XUPP3R_VU9P [concat $XDC_FILES_XUPP3R_VU9P \
  pcie_dma_top_VU9P.xdc]

set XDC_FILES_VMK180 [concat $XDC_FILES_VMK180 \
  pcie_dma_top_VMK180.xdc]

set XDC_FILES_VC709 [concat $XDC_FILES_VC709 \
  pcie_dma_top_VC709.xdc]

set XDC_FILES_HTG710 [concat $XDC_FILES_HTG710 \
  pcie_dma_top_HTG710.xdc]



