#file: do_implementation_post.tcl

set GIT_HASH [exec git rev-parse HEAD]
set GIT_HASH "160'h$GIT_HASH"
#set GIT_BRANCH [string map { / - } [exec git rev-parse --abbrev-ref HEAD]]
set COMMIT_DATETIME [exec git show -s --format=%cd --date=iso]
set YY [string range $COMMIT_DATETIME 2 3]
set MM [string range $COMMIT_DATETIME 5 6]
set DD [string range $COMMIT_DATETIME 8 9]
set hh [string range $COMMIT_DATETIME 11 12]
set mm [string range $COMMIT_DATETIME 14 15]
 
set COMMIT_DATETIME 40'h${YY}${MM}${DD}${hh}${mm}

set git_tag_str [exec git describe --abbrev=0 --tags --match rm*]
set GIT_COMMIT_NUMBER [exec git rev-list ${git_tag_str}..HEAD]
set GIT_COMMIT_NUMBER [expr [regexp -all {[\n]+} $GIT_COMMIT_NUMBER ] +1]
binary scan [string reverse ${git_tag_str}] H* t
set GIT_TAG "128'h$t"
puts $GIT_TAG          

set scriptdir [pwd]
set HDLDIR $scriptdir/../../


#Copy back all the IP cores from the project back into the repository
set XCI_FILES [get_files *.xci]
set BD_FILES [get_files *.bd]
set PART [get_property part [current_project]]

if {$PART == "xcku115-flvf1924-2-e"} {
  set core_dir $HDLDIR/sources/ip_cores/ku/
} elseif {$PART == "xcku040-ffva1156-2-e"} {
  set core_dir $HDLDIR/sources/ip_cores/ku/
} elseif {$PART == "xc7vx690tffg1761-2"} {
  set core_dir $HDLDIR/sources/ip_cores/virtex7/
} elseif {$PART == "xcvu37p-fsvh2892-2-e-es1"} {
  set core_dir $HDLDIR/sources/ip_cores/VU37P/
} elseif {$PART == "xcvu37p-fsvh2892-2-e"} {
  set core_dir $HDLDIR/sources/ip_cores/VU37P/
} elseif {$PART == "xcvu9p-flgb2104-2-e"} {
  set core_dir $HDLDIR/sources/ip_cores/VU9P/
} elseif {$PART == "xcvm1802-vsva2197-2MP-e-S-es1"} {
  set core_dir $HDLDIR/sources/ip_cores/Versal/
} else {
	puts "Error: Unsupported part: $PART"
	return
}

foreach XCI_FILE $XCI_FILES {
  file copy -force $XCI_FILE $core_dir
}

foreach BD_FILE $BD_FILES {
  file copy -force $BD_FILE $core_dir
}


#Check if there are no uncommitted changes in the GIT repository, otherwise show the diff
#in generics_timing.txt, done in do_implementation_finish.tcl, here we raise a critical warning
# Use -G. to ignore git seeing 755 file access attributes on Windows filesystems on each file
set GitDiff [exec git diff -G.]
if {[string trim $GitDiff] != ""} {
    set MsgString "There were uncommitted changes in the GIT repository while starting this build:

$GitDiff

"
     
    send_msg_id {GitDiff-1} {CRITICAL WARNING} $MsgString
}

cd ../../
set GitSubmoduleStatus [exec git submodule status]
cd $scriptdir


set systemTime [clock seconds]
set build_date "40'h[clock format $systemTime -format %y%m%d%H%M]"
puts "BUILD_DATE = $build_date"

#For 711 / 712 cards the core location in the PCIe endpoint must be selected correctly.
if {$CARD_TYPE == 711} {
    set loc_7039 [get_property CONFIG.pcie_blk_locn [get_ips pcie3_ultrascale_7039]]
    if { $loc_7039 != "X0Y1" } {
        set_property -dict [list CONFIG.pcie_blk_locn {X0Y0} CONFIG.gen_x0y1 {false} CONFIG.gen_x0y0 {true} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.mcap_enablement {None}] [get_ips pcie3_ultrascale_7038]
        set_property -dict [list CONFIG.pcie_blk_locn {X0Y1} CONFIG.gen_x0y1 {true} CONFIG.gen_x0y3 {false} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.mcap_enablement {None}] [get_ips pcie3_ultrascale_7039]
        set_property -dict [list CONFIG.dedicate_perst {false}] [get_ips pcie3_ultrascale_7038]
        generate_target all [get_files pcie3_ultrascale_7038.xci]
        export_ip_user_files -of_objects [get_files pcie3_ultrascale_7038.xci] -no_script -force -quiet
        reset_run pcie3_ultrascale_7038_synth_1
        launch_run -jobs 12 pcie3_ultrascale_7038_synth_1
        generate_target all [get_files pcie3_ultrascale_7039.xci]
        export_ip_user_files -of_objects [get_files pcie3_ultrascale_7039.xci] -no_script -force -quiet
        reset_run pcie3_ultrascale_7039_synth_1
        launch_run -jobs 12 pcie3_ultrascale_7039_synth_1
    }
} 
if {$CARD_TYPE == 712} {
    set loc_7039 [get_property CONFIG.pcie_blk_locn [get_ips pcie3_ultrascale_7039]]
    if { $loc_7039 != "X0Y3" } {
        set_property -dict [list CONFIG.pcie_blk_locn {X0Y1} CONFIG.gen_x0y0 {false} CONFIG.gen_x0y1 {true} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.mcap_enablement {None}] [get_ips pcie3_ultrascale_7038]
        set_property -dict [list CONFIG.pcie_blk_locn {X0Y3} CONFIG.gen_x0y1 {false} CONFIG.gen_x0y3 {true} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.mcap_enablement {None}] [get_ips pcie3_ultrascale_7039]
        set_property -dict [list CONFIG.dedicate_perst {false}] [get_ips pcie3_ultrascale_7038]
        generate_target all [get_files pcie3_ultrascale_7038.xci]
        export_ip_user_files -of_objects [get_files pcie3_ultrascale_7038.xci] -no_script -force -quiet
        reset_run pcie3_ultrascale_7038_synth_1
        launch_run -jobs 12 pcie3_ultrascale_7038_synth_1
        generate_target all [get_files pcie3_ultrascale_7039.xci]
        export_ip_user_files -of_objects [get_files pcie3_ultrascale_7039.xci] -no_script -force -quiet
        reset_run pcie3_ultrascale_7039_synth_1
        launch_run -jobs 12 pcie3_ultrascale_7039_synth_1
    }
}



set IMPL_RUN [get_runs impl*]
set SYNTH_RUN [get_runs synth*]

reset_run $SYNTH_RUN

foreach design [get_designs] {
   puts "Closing design: $design"
   current_design $design
   close_design
}



## PCIe EndPoint constraints
#For BNL711 v1p5 hardware
set SLR0 0
#For BNL711 v2p0 hardware
set SLR1 1

## BNL-711 PCIe location constraints
if {$CARD_TYPE == 712} {
    set PCIE_PLACEMENT $SLR1
} else {
    set PCIE_PLACEMENT $SLR0
}
#GBT mode seems to benefit more from AreaOptimized_medium, FULL mode is better with PerfOptimized_high
set_property strategy Flow_PerfOptimized_high $SYNTH_RUN
## Optimize place and route algorithm
set_property strategy Performance_ExplorePostRoutePhysOpt $IMPL_RUN
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE ExploreWithRemap $IMPL_RUN
#set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE SpreadLogic_high $IMPL_RUN
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveFanoutOpt $IMPL_RUN
#set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE MoreGlobalIterations $IMPL_RUN
#set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE HigherDelayCost $IMPL_RUN
#set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore $IMPL_RUN
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE NoTimingRelaxation $IMPL_RUN
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AddRetime $IMPL_RUN

# Quick build to find time constrained paths fast E.Z.
# set_property strategy Performance_Explore $IMPL_RUN
# set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Default $IMPL_RUN
# set_property STEPS.OPT_DESIGN.IS_ENABLED false $IMPL_RUN
# set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED false $IMPL_RUN
# set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Default $IMPL_RUN
# set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Default $IMPL_RUN
# set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE Default $IMPL_RUN


set_property generic "
BUILD_DATETIME=$build_date \
COMMIT_DATETIME=$COMMIT_DATETIME \           
GIT_HASH=$GIT_HASH \
GIT_TAG=$GIT_TAG \
GIT_COMMIT_NUMBER=$GIT_COMMIT_NUMBER \
NUMBER_OF_INTERRUPTS=$NUMBER_OF_INTERRUPTS \
NUMBER_OF_DESCRIPTORS=$NUMBER_OF_DESCRIPTORS \
ENDPOINTS=$ENDPOINTS \
CARD_TYPE=$CARD_TYPE \
PCIE_LANES=$PCIE_LANES \
DATA_WIDTH=$DATA_WIDTH \
NUM_LEDS=$NUM_LEDS \
" [current_fileset]

set CORES 16
puts "INFO: $CORES cores are in use"

launch_runs $SYNTH_RUN  -jobs $CORES
wait_on_run $SYNTH_RUN

if {$STOP_TO_ADD_ILA == 1} {
open_run $SYNTH_RUN -name $SYNTH_RUN
# wait to: open_run $SYNTH_RUN, to finish
wait_on_run $SYNTH_RUN
set STOP_TO_ADD_ILA 0
puts ""
puts ""
puts "*** ============================================================ ***"
puts "*** The script stopped in order to provide the ability to add an ***"
puts "*** ila after you finish with defining the debug ports, run the  ***"
puts "*** tcl command: source ./../helper/do_implementation_finish.tcl ***"
puts "*** ============================================================ ***"
puts ""
puts ""
break
} else {
    source ../helper/do_implementation_finish.tcl
};
