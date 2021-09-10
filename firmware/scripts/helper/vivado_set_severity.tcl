#Issue's that are rebranded

#NULL port ignored
set_msg_config -id {Synth 8-506} -new_severity {INFO}
#Checking whether we already executed this script, we can detect that if we get a warning Common 17-1361 from the previous line.
#You have specified a new message control rule that is equivalent to an existing rule with attributes
if { [get_msg_config -id {Common 17-1361} -count] == 0 } {
    set_msg_config -id {Synth 8-3919} -new_severity {INFO}
    #Tying undriven pin to constant 0
    set_msg_config -id {Synth 8-3295} -new_severity {INFO}
    #Unsused sequential element was removed
    set_msg_config -id {Synth 8-6014} -new_severity {INFO}
    #Register is trimmed in number of bits
    set_msg_config -id {Synth 8-3936} -new_severity {INFO}
    #RAM from abstract data type for this pattern is not supported, flipflops will be used.
    set_msg_config -id {Synth 8-5858} -new_severity {INFO}
    set_msg_config -id {Synth 8-5856} -new_severity {INFO}
    #Unused toplevel generic
    set_msg_config -id {Synth 8-3301} -new_severity {INFO}
    set_msg_config -id {Synth 8-3819} -new_severity {INFO}
    #Output port is driven by constant
    set_msg_config -id {Synth 8-3917} -new_severity {INFO}
    #Signal does not have a driver. This happens a lot for unused registers in the registermap. Discutable whether this is valid for other projects.
    set_msg_config -id {Synth 8-3848} -new_severity {INFO}
    set_msg_config -id {Synth 8-3848} -limit 1000
    #design ... has unconnected port
    set_msg_config -id {Synth 8-3331} -new_severity {INFO}
    #root scope declaration is not allowed in verilog 95/2K mode
    set_msg_config -id {Synth 8-2644} -new_severity {INFO}
    #Nets in constraints were not found
    set_msg_config -id {Vivado 12-507} -new_severity {INFO}
    #Clocks in constraints were not found
    set_msg_config -id {Vivado 12-627} -new_severity {INFO}
    set_msg_config -id {Vivado 12-4739} -new_severity {INFO}
    #Ports in constraints were not found
    set_msg_config -id {Vivado 12-508} -new_severity {INFO}
    set_msg_config -id {Vivado 12-584} -new_severity {INFO}
    #Inferring latch
    set_msg_config -id {Synth 8-327} -new_severity {CRITICAL WARNING}
    #Multidriven net will fail later on Opt Design anyway, let's stop already during synthesis
    set_msg_config -id {Synth 8-3352} -new_severity {ERROR}
    #Object in constraints not found
    #set_msg_config -id {Common 17-55} -new_severity {WARNING}
    #Creating clock with multiple sources
    set_msg_config -id {Constraints 18-633} -new_severity {INFO}
    #Component port with null array found, Will be ignored
    set_msg_config -id {Synth 8-6778} -new_severity {INFO}
    #Vivado Synthesis ignores library specification for Verilog or SystemVerilog files.
    set_msg_config -id {filemgmt 56-99} -new_severity {INFO}
    #Use of 'set_multicycle_path' with '-hold' is not supported by synthesis. The constraint will not be passed to synthesis.
    set_msg_config -id {Designutils 20-1567} -new_severity {INFO}
}
