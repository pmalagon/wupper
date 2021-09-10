#
#  File import script for the FELIX hdl Vivado project
#  Board: VCU128
#

source ../helper/clear_filesets.tcl

set PROJECT_NAME VC709_WUPPER
set BOARD_TYPE 709
set TOPLEVEL wupper_oc_top

#Import blocks for different filesets

source ../filesets/housekeeping_fileset.tcl
source ../filesets/wupper_fileset.tcl
source ../filesets/wupper_oc_fileset.tcl


#Actually execute all the filesets
source ../helper/vivado_import_generic.tcl

puts "INFO: Done!"
