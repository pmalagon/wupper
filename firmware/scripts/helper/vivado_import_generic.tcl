# Set the supportfiles directory path
set scriptdir [pwd]
set firmware_dir $scriptdir/../../
# Vivado project directory:
set GET_IPS_ARGS {-exclude_bd_ips}
set project_dir $firmware_dir/Projects/$PROJECT_NAME
if {$BOARD_TYPE == 711 || $BOARD_TYPE == 712} {
	set PART xcku115-flvf1924-2-e
	set core_dir $firmware_dir/sources/ip_cores/ku/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_KU]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_KU]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_KU]
    set BD_FILES [concat $BD_FILES $BD_FILES_KU]
} elseif {$BOARD_TYPE == 105} {
	set PART xcku040-ffva1156-2-e
	set core_dir $firmware_dir/sources/ip_cores/ku/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_KU]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_KU]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_KU]
    set BD_FILES [concat $BD_FILES $BD_FILES_KU]
} elseif {$BOARD_TYPE == 709 || $BOARD_TYPE == 710} {
	set PART xc7vx690tffg1761-2
	set core_dir $firmware_dir/sources/ip_cores/virtex7/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_V7]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_V7]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_V7]
    set BD_FILES [concat $BD_FILES $BD_FILES_V7]
} elseif {$BOARD_TYPE == 128} {
	if {$ENGINEERING_SAMPLE == true} {
		set PART xcvu37p-fsvh2892-2-e-es1
	} else {
		set PART xcvu37p-fsvh2892-2-e
	}
	set core_dir $firmware_dir/sources/ip_cores/VU37P/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_VU37P]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_VU37P]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_VU37P]
    set BD_FILES [concat $BD_FILES $BD_FILES_VU37P]
} elseif {$BOARD_TYPE == 800} {
    set GET_IPS_ARGS {-quiet}
	set PART xcvu9p-flgb2104-2-e
	set core_dir $firmware_dir/sources/ip_cores/VU9P/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_VU9P]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_VU9P]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_VU9P]
    set BD_FILES [concat $BD_FILES $BD_FILES_VU9P]
} elseif {$BOARD_TYPE == 801} {
    set GET_IPS_ARGS {-quiet}
	set PART xcvu9p-flgc2104-2-e
	set core_dir $firmware_dir/sources/ip_cores/VU9P/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_VU9P]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_VU9P]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_VU9P]
    set BD_FILES [concat $BD_FILES $BD_FILES_VU9P]
} elseif {$BOARD_TYPE == 180} {
	if {$ENGINEERING_SAMPLE == true} {
		set PART xcvm1802-vsva2197-2MP-e-S-es1
	} else {
		set PART xcvm1802-vsva2197-2MP-e-S
	}
	set core_dir $firmware_dir/sources/ip_cores/Versal/
	set XCI_FILES [concat $XCI_FILES $XCI_FILES_VERSAL]
	set VHDL_FILES [concat $VHDL_FILES $VHDL_FILES_VERSAL]
	set SIM_FILES [concat $SIM_FILES $SIM_FILES_VERSAL]
    set BD_FILES [concat $BD_FILES $BD_FILES_VERSAL]
} else {
	puts "Error: BOARD_TYPE should be 128, 709, 710, 711, 712, 128, 800, 801 or 180"
	return;
}

if {$BOARD_TYPE == 709} {
	set XDC_FILES $XDC_FILES_VC709
}
if {$BOARD_TYPE == 710} {
	set XDC_FILES $XDC_FILES_HTG710
}
if {$BOARD_TYPE == 105} {
	set XDC_FILES $XDC_FILES_KCU105
}
if {$BOARD_TYPE == 711} {
	set XDC_FILES $XDC_FILES_BNL711
}
if {$BOARD_TYPE == 712} {
	set XDC_FILES $XDC_FILES_BNL712
}
if {$BOARD_TYPE == 128} {
	set XDC_FILES $XDC_FILES_VCU128
}
if {$BOARD_TYPE == 800} {
	set XDC_FILES $XDC_FILES_XUPP3R_VU9P
}
if {$BOARD_TYPE == 801} {
	set XDC_FILES $XDC_FILES_BNL801
}
if {$BOARD_TYPE == 180} {
	set XDC_FILES $XDC_FILES_VMK180
}




close_project -quiet
create_project -force -part $PART $PROJECT_NAME $firmware_dir/Projects/$PROJECT_NAME
#if {$BOARD_TYPE == 180} {
#    set_property board_part xilinx.com:vmk180_es:part0:1.0 [current_project]
#}
set_property target_language VHDL [current_project]
set_property default_lib work [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]



foreach VHDL_FILE $VHDL_FILES {
	set file_path [file normalize ${firmware_dir}/sources/${VHDL_FILE}]
	if {!($file_path in [get_files])} {
		read_vhdl -library work $file_path
		set_property FILE_TYPE {VHDL 2008} [get_files ${file_path}]
	}		
}

foreach VERILOG_FILE $VERILOG_FILES {
	set file_path [file normalize ${firmware_dir}/sources/${VERILOG_FILE}]
	if {!($file_path in [get_files])} {
		read_verilog -library work $file_path
	}
}

foreach XCI_FILE $XCI_FILES {
	import_ip -quiet ${core_dir}/${XCI_FILE}
}

foreach BD_FILE $BD_FILES {
    import_files -norecurse ${core_dir}/${BD_FILE}
    set WRAPPER_FILE [make_wrapper -files [get_files $BD_FILE] -top]
    add_files -norecurse $WRAPPER_FILE
}

foreach XDC_FILE $XDC_FILES {
	read_xdc -verbose ${firmware_dir}/constraints/${XDC_FILE}
}

set_property SOURCE_SET sources_1 [get_filesets sim_1]

#These files are for synthesis only, they must have a replacement for simulation purposes.
foreach EXCLUDE_SIM_FILE $EXCLUDE_SIM_FILES {
	set_property used_in_simulation false [get_files  ${firmware_dir}/sources/$EXCLUDE_SIM_FILE]
}

#by default we are not including simulation files since UVVM is unsupported by the Vivado simulator
if {$VIVADO_ADD_SIM_FILES == true} {
    foreach SIM_FILE $SIM_FILES {
        add_files -fileset sim_1 -force -norecurse ${firmware_dir}/simulation/$SIM_FILE
        set_property library work [get_files  ${firmware_dir}/simulation/$SIM_FILE]
        set_property file_type {VHDL 2008} [get_files  ${firmware_dir}/simulation/$SIM_FILE]
    }
    
    foreach WCFG_FILE $WCFG_FILES {
        add_files -fileset sim_1 -force -norecurse ${firmware_dir}/simulation/$WCFG_FILE
    }

    if {[info exists TOPLEVEL_SIM]} {
        set_property top $TOPLEVEL_SIM [get_filesets sim_1]
    }
    update_compile_order -fileset sim_1

    set_property -name {xsim.simulate.runtime} -value {5 us} -objects [current_fileset -simset]
}


close [ open $firmware_dir/constraints/felix_probes.xdc w ]
read_xdc -verbose $firmware_dir/constraints/felix_probes.xdc
set_property target_constrs_file $firmware_dir/constraints/felix_probes.xdc [current_fileset -constrset]


set_property top $TOPLEVEL [current_fileset]
upgrade_ip [get_ips $GET_IPS_ARGS]
generate_target all [get_ips $GET_IPS_ARGS]
export_ip_user_files -of_objects [get_ips $GET_IPS_ARGS] -no_script -force -quiet
set MAX_IP_RUNS 6
set IP_RUNS 0

foreach ip [get_ips $GET_IPS_ARGS] {
    set run [create_ip_run [get_ips $ip]]
    launch_run $run
    if { $IP_RUNS < $MAX_IP_RUNS } {
        set IP_RUNS [expr $IP_RUNS + 1]
    } else {
        #Wait on run, only if IP_RUNS == 6, run 6 ip cores parallel.
        wait_on_run $run
        set IP_RUNS 0
    }
}
#wait for the last run.
wait_on_run $run
export_simulation -of_objects [get_ips $GET_IPS_ARGS] -force -quiet

