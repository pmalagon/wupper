# Set the supportfiles directory path
set scriptdir [pwd]
#Download SigasiProjectCreator from https://github.com/sigasi/SigasiProjectCreator 
#Extract it in the directory below (/opt by default).
set SigasiProjectCreator /eda/fpga/SigasiProjectCreator/
set firmware_dir $scriptdir/../../
# Vivado project directory:
set project_dir $firmware_dir/Projects/$PROJECT_NAME

set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_KU]
set SIM_FILES [concat $SIM_FILES $SIM_FILES_KU]
set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_V7]
set SIM_FILES [concat $SIM_FILES $SIM_FILES_V7]
set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_VU9P]
set SIM_FILES [concat $SIM_FILES $SIM_FILES_VU9P]
set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_VU37P]
set SIM_FILES [concat $SIM_FILES $SIM_FILES_VU37P]

set XCI_FILES [concat $XCI_FILES $XCI_FILES_KU]

file mkdir $project_dir

set CSV_FILE [open $project_dir/$PROJECT_NAME.csv w]


foreach VHDL_FILE $VHDL_FILES {
    if {[string first "data_width_package_512.vhd" $VHDL_FILE] == -1} {
        puts $CSV_FILE "work, ${firmware_dir}/sources/${VHDL_FILE}"
    }

}

foreach SIM_FILE $SIM_FILES {
	puts $CSV_FILE "work, ${firmware_dir}/simulation/${SIM_FILE}"
}
#puts $CSV_FILE "unisim, SIGASI_TOOLCHAIN_XILINX_VIVADO/data/vhdl/src/unisims"

foreach XCI_FILE $XCI_FILES {
	set XCI_FILE [string trimright $XCI_FILE .xci]
	puts $CSV_FILE "work, ${firmware_dir}/sources/ip_cores/stub/${XCI_FILE}_stub.vhdl"
}


foreach VERILOG_FILE $VERILOG_FILES {
	puts $CSV_FILE "work, ${firmware_dir}/sources/${VERILOG_FILE}"
}

close $CSV_FILE

cd $project_dir
exec python ${SigasiProjectCreator}/src/SigasiProjectCreator/convertCsvFileToLinks.py ${PROJECT_NAME} ${PROJECT_NAME}.csv
#exec ../../scripts/helper/patch_sigasi_unisim.sh
