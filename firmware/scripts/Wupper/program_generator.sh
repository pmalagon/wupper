#!/bin/sh

BITFILE=`ls -rt ../../output/*.bit | tail -n 1`
DEBUGFILE=${BITFILE%.bit}_debug_nets.ltx

echo "open_hw_manager" > program.tcl
echo "connect_hw_server" >> program.tcl
echo "open_hw_target" >> program.tcl
echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
echo "refresh_hw_device -update_hw_probes true [current_hw_device]" >> program.tcl
echo "set_property PROGRAM.FILE {$BITFILE} [current_hw_device]" >> program.tcl
echo "set_property PROBES.FILE {$DEBUGFILE} [current_hw_device]" >> program.tcl
echo "program_hw_devices [current_hw_device]" >> program.tcl
echo "exit" >> program.tcl
