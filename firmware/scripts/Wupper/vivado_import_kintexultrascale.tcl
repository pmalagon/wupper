#
#	File import script for the PCIe DMA core hdl project
#
#	

#Script Configuration

set proj_name wupper_oc_top_ultrascale
# Set the supportfiles directory path
set scriptdir [pwd]
set proj_dir $scriptdir/../../

#Close currently open project and create a new one. (OVERWRITES PROJECT!!)
close_project -quiet


create_project -force -part xcku115-flvf1924-2-e $proj_name $proj_dir/Projects/$proj_name


set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# ----------------------------------------------------------
# PCIe DMA top module
# ----------------------------------------------------------
read_vhdl -library work $proj_dir/sources/shared/wupper_oc_top.vhd
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

#for Virtex7 parts
import_ip $proj_dir/sources/pcie/pcie_x8_gen3_3_0.xci
#for Artix Ultrascale parts
import_ip $proj_dir/sources/pcie/pcie3_ultrascale_7038.xci
import_ip $proj_dir/sources/pcie/pcie3_ultrascale_7039.xci
import_ip $proj_dir/sources/pcie/clk_wiz_40.xci

# ----------------------------------------------------------
# example application
# ----------------------------------------------------------

read_vhdl -library work $proj_dir/sources/application/application.vhd
read_vhdl -library work $proj_dir/sources/application/LFSR.vhd
read_vhdl -library work $proj_dir/sources/application/xadc_drp.vhd
import_ip $proj_dir/sources/application/fifo_256x256.xci
import_ip $proj_dir/sources/application/fifo_256x512.xci
import_ip $proj_dir/sources/application/xadc_wiz_0.xci
import_ip $proj_dir/sources/application/system_management_wiz_0.xci
import_ip $proj_dir/sources/application/multiplier.xci

upgrade_ip [get_ips  {pcie_x8_gen3_3_0 clk_wiz_40 fifo_256x256}]

read_xdc -verbose $proj_dir/constraints/pcie_dma_top_VC709.xdc
read_xdc -verbose $proj_dir/constraints/pcie_dma_top_HTG710.xdc
read_xdc -verbose $proj_dir/constraints/pcie_dma_top_kcu105.xdc
close [ open $proj_dir/constraints/probes.xdc w ]
read_xdc -verbose $proj_dir/constraints/probes.xdc
set_property target_constrs_file $proj_dir/constraints/probes.xdc [current_fileset -constrset]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE MoreGlobalIterations [get_runs impl_1]

set_property top wupper_oc_top [current_fileset]

puts "INFO: Done!"








