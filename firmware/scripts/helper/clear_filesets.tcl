set XCI_FILES ""
set VHDL_FILES ""
set VERILOG_FILES ""
set SIM_FILES ""
set EXCLUDE_SIM_FILES ""
set WCFG_FILES ""
set BD_FILES ""

set XCI_FILES_V7 ""
set VHDL_FILES_V7 ""
set SIM_FILES_V7 ""
set BD_FILES_V7 ""

set XCI_FILES_KU ""
set VHDL_FILES_KU ""
set SIM_FILES_KU ""
set BD_FILES_KU ""

set XCI_FILES_VU9P ""
set VHDL_FILES_VU9P ""
set SIM_FILES_VU9P ""
set BD_FILES_VU9P ""

set XCI_FILES_VU37P ""
set VHDL_FILES_VU37P ""
set SIM_FILES_VU37P ""
set BD_FILES_VU37P ""

set XCI_FILES_VERSAL ""
set VHDL_FILES_VERSAL ""
set SIM_FILES_VERSAL ""
set BD_FILES_VERSAL ""

set XDC_FILES_VC709 ""
set XDC_FILES_KCU105 ""
set XDC_FILES_HTG710 ""
set XDC_FILES_BNL711 ""
set XDC_FILES_BNL712 ""
set XDC_FILES_VCU128 ""
set XDC_FILES_XUPP3R_VU9P ""
set XDC_FILES_BNL801 ""
set XDC_FILES_VMK180 ""


#This property will be handled only in vivado_import_generic. Set to true to import also simulation only files. 
#Sim files that contain UVVM libraries are currently unsupported by Vivado and generate syntax errors. Use Modelsim/Questasim instead.
set VIVADO_ADD_SIM_FILES false
set ENGINEERING_SAMPLE false
