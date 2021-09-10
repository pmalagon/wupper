source ./Wupper_import_questa.tcl
vsim -t 1ps -voptargs="+acc" work.Wupper_tb  work.glbl
run -all
quit
