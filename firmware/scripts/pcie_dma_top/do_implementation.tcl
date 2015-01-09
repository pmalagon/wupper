set IMPL_RUN [get_runs impl*]
set SYNTH_RUN [get_runs synth*]
set PROJECT_NAME "pcie_dma_top"
set scriptdir [pwd]
set HDLDIR $scriptdir/../../

reset_run $SYNTH_RUN

launch_runs $SYNTH_RUN
launch_runs $IMPL_RUN
#launch_runs $IMPL_RUN  -to_step write_bitstream
#cd $HDLDIR/Synt/
wait_on_run $IMPL_RUN
set TIMESTAMP [clock format [clock seconds] -format {%y%m%d_%H_%M}]



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
