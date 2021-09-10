#reset_run $IMPL_RUN
launch_runs $IMPL_RUN -jobs $CORES
#launch_runs $IMPL_RUN  -to_step write_bitstream
#cd $HDLDIR/Synt/
wait_on_run $IMPL_RUN
set TIMESTAMP [clock format $systemTime -format {%y%m%d_%H_%M}]


open_run $IMPL_RUN
current_run $IMPL_RUN

set CREATE_CHECKPOINT 0

#Try 6 more rounds of phys_opt_design, and two more rounds of route_design in case timing is not met. If WNS < -0.4 it doesn't make sense to try at all.
if {$KEEP_TRYING_TO_MEET_TIMING == true} {
    set slack [get_property SLACK [get_timing_paths -delay_type min_max]]
    if {$slack < 0 && $slack > -0.4} {
        set CREATE_CHECKPOINT 1
        for {set i 0} {$i < 3} {incr i} {
            set slack [get_property SLACK [get_timing_paths -delay_type min_max]]
            set pass [expr {$slack >= 0}]
            if {$i > 0 && $pass != 1} {
                route_design -directive MoreGlobalIterations
            }
            set slack [get_property SLACK [get_timing_paths -delay_type min_max]]
            set pass [expr {$slack >= 0}]
            if { $pass != 1 } {
                phys_opt_design -directive Explore
            }
            set slack [get_property SLACK [get_timing_paths -delay_type min_max]]
            set pass [expr {$slack >= 0}]
            if { $pass != 1 } {
                phys_opt_design -directive AggressiveExplore
            }
        }
    }
}

file mkdir $HDLDIR/output/

set CARD_TYPE_STR $CARD_TYPE

set GIT_BRANCH [string map { / - } [exec git rev-parse --abbrev-ref HEAD]]

#In case of a Gitlab CI build, the branch defaults to HEAD with the above command, lets' get it from the environment variable CI_COMMIT_REF_NAME instead
if { [info exists ::env(CI_COMMIT_REF_NAME) ] } {
    set GIT_BRANCH [string map { / - } $env(CI_COMMIT_REF_NAME)]
}


set FileName WUPPER${CARD_TYPE_STR}_GIT_${GIT_BRANCH}_${git_tag_str}_${GIT_COMMIT_NUMBER}_${TIMESTAMP}

if {$CARD_TYPE == 180} {
    write_device_image -force $HDLDIR/output/${FileName}.pdi
} else { 
    write_bitstream -force $HDLDIR/output/${FileName}.bit
}


cd $HDLDIR/output/

set pass [expr {[get_property SLACK [get_timing_paths -delay_type min_max]] >= 0}]
set report [report_timing -slack_lesser_than 0 -return_string -nworst 10]
set check_timing_report [check_timing -return_string]
report_utilization -name ${FileName} -spreadsheet_table "Hierarchy" -spreadsheet_file ${HDLDIR}/output/${FileName}.xlsx -spreadsheet_depth 8 
set util [report_utilization -return_string]
set slack [get_property SLACK [get_timing_paths -delay_type min_max]]
#Add the complete GIT diff to the text file if not empty.
if {[string trim $GitDiff] != ""} {
    set GenericFileData  "There were uncommitted changes in the GIT repository while starting this build\n"    
    set gitdiffFileName "${FileName}_git.diff"
    set gitdiffFileId [open $gitdiffFileName "w"]
    puts -nonewline $gitdiffFileId $GitDiff
    close $gitdiffFileId
} else {
    set GenericFileData ""
}

set GenericFileData "$GenericFileData

Git submodule status:
$GitSubmoduleStatus

BUILD_DATETIME:                 $build_date 
COMMIT_DATETIME:                $COMMIT_DATETIME 
GIT_HASH:                       $GIT_HASH 
GIT_TAG:                        $GIT_TAG 
GIT_COMMIT_NUMBER:              $GIT_COMMIT_NUMBER 
NUMBER_OF_INTERRUPTS:           $NUMBER_OF_INTERRUPTS 
NUMBER_OF_DESCRIPTORS:          $NUMBER_OF_DESCRIPTORS
BLOCKSIZE:                      $BLOCKSIZE 
CARD_TYPE:                      $CARD_TYPE 
Timing met:                     $pass
WNS:                            $slack\n\n
Check Timing:\n
$check_timing_report\n\n
Timing Report:\n
$report\n
Utilization Report:\n
$util\n"

set GenericsFileName "${FileName}_generics_timing.txt"
set GenericsFileId [open $GenericsFileName "w"]
puts -nonewline $GenericsFileId $GenericFileData
close $GenericsFileId



set BitFile ${FileName}.bit
set IMPL_DIR [get_property DIRECTORY [current_run]]

write_debug_probes ${HDLDIR}/output/${FileName}_debug_nets.ltx -force

#Create MCS file. Not for VMK180, Versal has another concept.
if {$CARD_TYPE != 180} {
    if {$CARD_TYPE == 128 || $CARD_TYPE == 800 || $CARD_TYPE == 801} {
        write_cfgmem -force -format mcs -size 256 -interface SPIx4 -loadbit "up 0x00000000 ${FileName}.bit"  -file ${FileName}.mcs
    } else {
        write_cfgmem -force -format MCS -size 128 -interface BPIx16 -loadbit "up 0x00000000 ${FileName}.bit" ${FileName}.mcs
    }
}

cd ${HDLDIR}/output/
file delete ${FileName}.tar.gz
set ArchiveFiles [glob ${FileName}*]
if { [catch { eval exec tar -zcf ${FileName}.tar.gz ${ArchiveFiles} } msg] } {
    puts "error creating archive ${FileName}.tar.gz"
    puts $msg
}

if {$CREATE_CHECKPOINT == 1} {
    set IMPL_DIR [get_property DIRECTORY $IMPL_RUN]
    set TOPLEVEL [get_property top [current_fileset] ]
    write_checkpoint -force ${IMPL_DIR}/${TOPLEVEL}_postroute_physopt.dcp
}
cd $scriptdir
