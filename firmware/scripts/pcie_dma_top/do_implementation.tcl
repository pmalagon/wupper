set IMPL_RUN [get_runs impl*]
set SYNTH_RUN [get_runs synth*]
set PROJECT_NAME "pcie_dma_top"
set scriptdir [pwd]
set HDLDIR $scriptdir/../../

reset_run $SYNTH_RUN

set svn_hash [exec svn info]
set svn_hash_lines [split $svn_hash "\n"]
set svn_version "0"
cd $HDLDIR
foreach line $svn_hash_lines {
   if [regexp {Last Changed Rev: } $line ] {
      set svn_version [ lindex [split $line] 3 ]
   }
}
cd $scriptdir

puts "SVN_VERSION = $svn_version"


set systemTime [clock seconds]
set build_date "40'h[clock format $systemTime -format %y%m%d%H%M]"
puts "BUILD_DATE = $build_date"



set_property generic "APP_CLK_FREQ=100 BUILD_DATETIME=$build_date SVN_VERSION=$svn_version" [current_fileset]

launch_runs $SYNTH_RUN
launch_runs $IMPL_RUN
#launch_runs $IMPL_RUN  -to_step write_bitstream
#cd $HDLDIR/Synt/
wait_on_run $IMPL_RUN
set TIMESTAMP [clock format $systemTime -format {%y%m%d_%H_%M}]



open_run $IMPL_RUN
current_run $IMPL_RUN

write_bitstream $HDLDIR/output/${PROJECT_NAME}_${TIMESTAMP}.bit

cd $HDLDIR/output/


set BitFile ${PROJECT_NAME}_$TIMESTAMP.bit

write_cfgmem -force -format MCS -size 128 -interface BPIx16 -loadbit "up 0x00000000 $BitFile" ${PROJECT_NAME}_$TIMESTAMP.mcs
if {[file exists $HDLDIR/Projects/${PROJECT_NAME}/${PROJECT_NAME}.runs/$IMPL_RUN/debug_nets.ltx] == 1} {
   file copy $HDLDIR/Projects/${PROJECT_NAME}/${PROJECT_NAME}.runs/$IMPL_RUN/debug_nets.ltx ${PROJECT_NAME}_debug_nets_$TIMESTAMP.ltx
}


cd $scriptdir
