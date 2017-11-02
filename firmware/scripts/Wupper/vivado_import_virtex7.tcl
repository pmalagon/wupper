#
#	File import script for the PCIe DMA core hdl project
#
#	

#Script Configuration

set proj_name wupper_oc_top_virtex7
# Set the supportfiles directory path
set scriptdir [pwd]
set proj_dir $scriptdir/../../

#Close currently open project and create a new one. (OVERWRITES PROJECT!!)
close_project -quiet

create_project -force -part xc7vx690tffg1761-2 $proj_name $proj_dir/Projects/$proj_name


set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# ----------------------------------------------------------
# PCIe DMA top module
# ----------------------------------------------------------
read_vhdl -library work $proj_dir/sources/shared/wupper_oc_top.vhd
read_vhdl -library work $proj_dir/sources/shared/housekeeping.vhd
read_vhdl -library work $proj_dir/sources/shared/i2c.vhd
read_vhdl -library work $proj_dir/sources/shared/i2c_interface.vhd
read_vhdl -library work $proj_dir/sources/shared/dna.vhd
import_ip $proj_dir/sources/ip_cores/virtex7/I2C_RDFifo.xci
import_ip $proj_dir/sources/ip_cores/virtex7/I2C_WRFifo.xci
# ----------------------------------------------------------
# packages
# ----------------------------------------------------------
read_vhdl -library work $proj_dir/sources/packages/pcie_package.vhd

# ----------------------------------------------------------
# dma sources
# ----------------------------------------------------------

read_vhdl -library work $proj_dir/sources/pcie/wupper_core.vhd
read_vhdl -library work $proj_dir/sources/pcie/dma_read_write.vhd
read_vhdl -library work $proj_dir/sources/pcie/intr_ctrl.vhd
read_vhdl -library work $proj_dir/sources/pcie/wupper.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_ep_wrap.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_init.vhd
read_vhdl -library work $proj_dir/sources/pcie/dma_control.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_clocking.vhd
read_vhdl -library work $proj_dir/sources/pcie/pcie_slow_clock.vhd

# ----------------------------------------------------------
# Wishbone
# ----------------------------------------------------------

read_vhdl -library work $proj_dir/sources/Wishbone/wb_intercon.vhd
read_vhdl -library work $proj_dir/sources/Wishbone/wb_memory.vhd
read_vhdl -library work $proj_dir/sources/Wishbone/wb_syscon.vhd
read_vhdl -library work $proj_dir/sources/Wishbone/wishbone_pkg.vhd
read_vhdl -library work $proj_dir/sources/Wishbone/genram_pkg.vhd
read_vhdl -library work $proj_dir/sources/Wishbone/wupper_to_wb.vhd
read_vhdl -library work $proj_dir/sources/Wishbone/xwb_crossbar.vhd

import_ip $proj_dir/sources/ip_cores/virtex7/wishbone_memory.xci
import_ip $proj_dir/sources/ip_cores/virtex7/wishbone_to_wupper_fifo.xci
import_ip $proj_dir/sources/ip_cores/virtex7/wupper_to_wishbone_fifo.xci



#for Virtex7 parts
import_ip $proj_dir/sources/ip_cores/virtex7/pcie_x8_gen3_3_0.xci
#for Artix Ultrascale parts
read_vhdl -library work $proj_dir/sources/ip_cores/virtex7/pcie3_ultrascale_7038_stub.vhdl
read_vhdl -library work $proj_dir/sources/ip_cores/virtex7/pcie3_ultrascale_7039_stub.vhdl
import_ip $proj_dir/sources/ip_cores/virtex7/clk_wiz_40.xci

# ----------------------------------------------------------
# example application
# ----------------------------------------------------------

read_vhdl -library work $proj_dir/sources/application/application.vhd
read_vhdl -library work $proj_dir/sources/application/LFSR.vhd
read_vhdl -library work $proj_dir/sources/application/xadc_drp.vhd
import_ip $proj_dir/sources/ip_cores/virtex7/xadc_wiz_0.xci
read_vhdl -library work $proj_dir/sources/ip_cores/virtex7/system_management_wiz_0_stub.vhdl

import_ip $proj_dir/sources/ip_cores/virtex7/fifo128KB_256bit.xci  
import_ip $proj_dir/sources/ip_cores/virtex7/fifo4KB_256bit.xci

upgrade_ip [get_ips  {I2C_RDFifo I2C_WRFifo pcie_x8_gen3_3_0 clk_wiz_40 xadc_wiz_0 fifo128KB_256bit fifo4KB_256bit}]

read_xdc -verbose $proj_dir/constraints/pcie_dma_top_VC709.xdc
read_xdc -verbose $proj_dir/constraints/pcie_dma_top_HTG710.xdc
#read_xdc -verbose $proj_dir/constraints/pcie_dma_top_kcu105.xdc
close [ open $proj_dir/constraints/probes.xdc w ]
read_xdc -verbose $proj_dir/constraints/probes.xdc
set_property target_constrs_file $proj_dir/constraints/probes.xdc [current_fileset -constrset]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE MoreGlobalIterations [get_runs impl_1]

set_property top wupper_oc_top [current_fileset]

puts "INFO: Done!"







