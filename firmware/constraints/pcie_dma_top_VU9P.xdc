#**************************************************************************
#*************             BittWare Incorporated              *************
#*************      45 S. Main Street, Concord, NH 03301      *************
#**************************************************************************
# LEGAL NOTICE:
#                 Copyright (c) 2018 BittWare, Inc.
#   The user is hereby granted a non-exclusive license to use and or
#     modify this code provided that it runs on BittWare hardware.
#   Usage of this code on non-BittWare hardware without the express
#      written permission of BittWare is strictly prohibited.
#
# E-mail: support@bittware.com                    Tel: 603-226-0404
#**************************************************************************

##############################################
##########      Configuration       ##########
##############################################
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
# Bitstream configuration settings
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
# Must set to "NO" if loading from backup flash partition
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]

set_property LOC PCIE40E4_X0Y3 [get_cells g_endpoints[1].pcie0/ep0/g_NoSim.g_ultrascale_plus.g_ep1.u1/inst/pcie_4_0_pipe_inst/pcie_4_0_e4_inst]

##############################################
##########    Board Clocks/Reset    ##########
##############################################
#set_property IOSTANDARD LVCMOS18 [get_ports sys_reset_n] # Active Low Global Reset
#set_property PACKAGE_PIN AT23 [get_ports sys_reset_n]

#set_property IOSTANDARD LVCMOS18 [get_ports clk_48_mhz] # Fixed on-board 48.00 MHz clock
#set_property PACKAGE_PIN AV23 [get_ports clk_48_mhz]
#create_clock -period 20.833 -name clk_48_mhz [get_ports clk_48_mhz]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets g_endpoints[1].pcie0/u1/sys_clk_gt]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets g_endpoints[1].pcie0/u1/sys_clk_gt]


##############################################
##########   Misc. Board-specific   ##########
##############################################
#set_property IOSTANDARD LVCMOS18 [get_ports fpga_i2c_master_l] # FPGA I2C Master. 0 = FPGA has control of I2C chains shared with the BMC.
#set_property PACKAGE_PIN AT24 [get_ports fpga_i2c_master_l]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_ctl_en] # QSFP I2C Control Enable
#set_property PACKAGE_PIN AN23 [get_ports qsfp_ctl_en]
#set_property IOSTANDARD LVCMOS18 [get_ports rd_prsnt_l_1] # Active Low RDIMM 1 Presence
#set_property PACKAGE_PIN AM21 [get_ports rd_prsnt_l_1]
#set_property IOSTANDARD LVCMOS18 [get_ports rd_prsnt_l_2] # Active Low RDIMM 2 Presence
#set_property PACKAGE_PIN AP21 [get_ports rd_prsnt_l_2]
#set_property IOSTANDARD LVCMOS18 [get_ports rd_prsnt_l_3] # Active Low RDIMM 3 Presence
#set_property PACKAGE_PIN AL21 [get_ports rd_prsnt_l_3]
#set_property IOSTANDARD LVCMOS18 [get_ports rd_prsnt_l_4] # Active Low RDIMM 4 Presence
#set_property PACKAGE_PIN AP24 [get_ports rd_prsnt_l_4]
#set_property IOSTANDARD LVCMOS18 [get_ports sep_prsnt_l] # Active Low SEP Presence
#set_property PACKAGE_PIN AL22 [get_ports sep_prsnt_l]
#set_property IOSTANDARD LVCMOS18 [get_ports pcie_bp_l] # Active Low Back Plane Detect
#set_property PACKAGE_PIN AM22 [get_ports pcie_bp_l]

##############################################
##########     UART & I2C I/F's     ##########
##############################################
#set_property IOSTANDARD LVCMOS18 [get_ports avr_rxd] # AVR UART Rx Data
#set_property PACKAGE_PIN AU24 [get_ports avr_rxd]
#set_property IOSTANDARD LVCMOS18 [get_ports avr_txd] # AVR UART Tx Data
#set_property PACKAGE_PIN AR21 [get_ports avr_txd]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_3] # I2C SDA 3 MAC-ID
#set_property PACKAGE_PIN AP23 [get_ports i2c_sda_3]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_scl_3] # I2C SCL 3 MAC-ID
#set_property PACKAGE_PIN AN24 [get_ports i2c_scl_3]
#set_property IOSTANDARD LVCMOS18 [get_ports usb_uart_txd] # FTDI UART Tx Data
#set_property PACKAGE_PIN AL24 [get_ports usb_uart_txd]
#set_property IOSTANDARD LVCMOS18 [get_ports usb_uart_rxd] # FTDI UART Rx Data
#set_property PACKAGE_PIN AM24 [get_ports usb_uart_rxd]
#set_property IOSTANDARD LVCMOS18 [get_ports avr_uart_rx_dir] # AVR UART Rx Direction
#set_property PACKAGE_PIN AN22 [get_ports rxd_dir]
#set_property IOSTANDARD LVCMOS18 [get_ports avr_uart_tx_dir] # AVR UART Tx Direction
#set_property PACKAGE_PIN AN21 [get_ports usb_txd_dir]

##############################################
##########  QSFP Status & Control   ##########
##############################################
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_prsnt_l_1] # QSFP 1 Active Low Present
#set_property PACKAGE_PIN BD23 [get_ports qsfp_prsnt_l_1]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_rst_l_1] # QSFP 1 Active Low Reset
#set_property PACKAGE_PIN BD24 [get_ports qsfp_rst_l_1]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_lp_1] # QSFP 1 Active Low Low Power
#set_property PACKAGE_PIN BC24 [get_ports qsfp_lp_1]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_int_l_1] # QSFP 1 Active Low Interrupt
#set_property PACKAGE_PIN BE23 [get_ports qsfp_int_l_1]

#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_prsnt_l_2] # QSFP 2 Active Low Present
#set_property PACKAGE_PIN BD21 [get_ports qsfp_prsnt_l_2]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_rst_l_2] # QSFP 2 Active Low Reset
#set_property PACKAGE_PIN BE20 [get_ports qsfp_rst_l_2]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_lp_2] # QSFP 2 Active Low Low Power
#set_property PACKAGE_PIN BD20 [get_ports qsfp_lp_2]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_int_l_2] # QSFP 2 Active Low Interrupt
#set_property PACKAGE_PIN BE21 [get_ports qsfp_int_l_2]

#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_prsnt_l_3] # QSFP 3 Active Low Present
#set_property PACKAGE_PIN BB20 [get_ports qsfp_prsnt_l_3]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_rst_l_3] # QSFP 3 Active Low Reset
#set_property PACKAGE_PIN BB22 [get_ports qsfp_rst_l_3]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_lp_3] # QSFP 3 Active Low Low Power
#set_property PACKAGE_PIN BC21 [get_ports qsfp_lp_3]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_int_l_3] # QSFP 3 Active Low Interrupt
#set_property PACKAGE_PIN BB21 [get_ports qsfp_int_l_3]

#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_prsnt_l_4] # QSFP 4 Active Low Present
#set_property PACKAGE_PIN BB24 [get_ports qsfp_prsnt_l_4]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_rst_l_4] # QSFP 4 Active Low Reset
#set_property PACKAGE_PIN BC23 [get_ports qsfp_rst_l_4]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_lp_4] # QSFP 4 Active Low Low Power
#set_property PACKAGE_PIN BA22 [get_ports qsfp_lp_4]
#set_property IOSTANDARD LVCMOS18 [get_ports qsfp_int_l_4] # QSFP 4 Active Low Interrupt
#set_property PACKAGE_PIN AY22 [get_ports qsfp_int_l_4]

###############################################
###########       QSFP I2C I/F       ##########
###############################################
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_scl_4] # QSFP Port 0 I2C SCL
#set_property PACKAGE_PIN BF24 [get_ports i2c_scl_4]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_4] # QSFP Port 0 I2C SDA
#set_property PACKAGE_PIN BF23 [get_ports i2c_sda_4]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_scl_5] # QSFP Port 1 I2C SCL
#set_property PACKAGE_PIN BE22 [get_ports i2c_scl_5]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_5] # QSFP Port 1 I2C SDA
#set_property PACKAGE_PIN BF22 [get_ports i2c_sda_5]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_6] # QSFP Port 2 I2C SCL
#set_property PACKAGE_PIN BF20 [get_ports i2c_scl_6]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_6] # QSFP Port 2 I2C SDA
#set_property PACKAGE_PIN BA20 [get_ports i2c_sda_6]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_scl_7] # QSFP Port 3 I2C SCL
#set_property PACKAGE_PIN BC22 [get_ports i2c_scl_7]
#set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_7] # QSFP Port 3 I2C SDA
#set_property PACKAGE_PIN BA24 [get_ports i2c_sda_7]

###############################################
###########           LEDs           ##########
###############################################
# Active Low Led 0
set_property IOSTANDARD LVCMOS18 [get_ports {leds[0]}]
set_property PACKAGE_PIN AR22 [get_ports {leds[0]}]
# Active Low Led 1
set_property IOSTANDARD LVCMOS18 [get_ports {leds[1]}]
set_property PACKAGE_PIN AT22 [get_ports {leds[1]}]
# Active Low Led 2
set_property IOSTANDARD LVCMOS18 [get_ports {leds[2]}]
set_property PACKAGE_PIN AR23 [get_ports {leds[2]}]
# Active Low Led 3
set_property IOSTANDARD LVCMOS18 [get_ports {leds[3]}]
set_property PACKAGE_PIN AV22 [get_ports {leds[3]}]

##############################################
##########           PCIe           ##########
##############################################
#set_property PACKAGE_PIN AY23 [get_ports progclk_b1_p]
#set_property PACKAGE_PIN BA23 [get_ports progclk_b1_n]
#set_property IOSTANDARD DIFF_SSTL18_I [get_ports progclk_b1_p]
# PCIE Active Low Reset

set_property PACKAGE_PIN AR26 [get_ports sys_reset_n]
set_property IOSTANDARD LVCMOS12 [get_ports sys_reset_n]
set_property PULLUP true [get_ports sys_reset_n]
set_false_path -from [get_ports sys_reset_n]
# PCIE Reference Clock 0
set_property PACKAGE_PIN AT10 [get_ports sys_clk_n[0]]
set_property PACKAGE_PIN AT11 [get_ports sys_clk_p[0]]
#set_property PACKAGE_PIN AH10 [get_ports pcie_sys_clkn] # PCIE Reference Clock 1
#set_property PACKAGE_PIN AH11 [get_ports pcie_sys_clkp]
create_clock -period 10.000 -name sys_clk [get_ports sys_clk_p]

set_clock_groups -name async18 -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -name async19 -asynchronous -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks {sys_clk}]
set_clock_groups -name async5 -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_clock_groups -name async6 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -group [get_clocks {sys_clk}]
set_clock_groups -name async1 -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]]
set_clock_groups -name async2 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]] -group [get_clocks {sys_clk}]
set_clock_groups -name async24 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]] -group [get_clocks {sys_clk}]


# PCIE Reference Clock Frequency

# NOTE: All GTY pins are automatically assigned by Vivado. Shown here for reference only.
#GTH BANK 227 PCIE 3:0
set_property PACKAGE_PIN AF2 [get_ports pcie_rxp[0]] 
set_property PACKAGE_PIN AF1 [get_ports pcie_rxn[0]] 
set_property PACKAGE_PIN AG4 [get_ports pcie_rxp[1]] 
set_property PACKAGE_PIN AG3 [get_ports pcie_rxn[1]] 
set_property PACKAGE_PIN AH2 [get_ports pcie_rxp[2]] 
set_property PACKAGE_PIN AH1 [get_ports pcie_rxn[2]] 
set_property PACKAGE_PIN AJ4 [get_ports pcie_rxp[3]] 
set_property PACKAGE_PIN AJ3 [get_ports pcie_rxn[3]] 
set_property PACKAGE_PIN AF7 [get_ports pcie_txp[0]] 
set_property PACKAGE_PIN AF6 [get_ports pcie_txn[0]] 
set_property PACKAGE_PIN AG9 [get_ports pcie_txp[1]] 
set_property PACKAGE_PIN AG8 [get_ports pcie_txn[1]] 
set_property PACKAGE_PIN AH7 [get_ports pcie_txp[2]] 
set_property PACKAGE_PIN AH6 [get_ports pcie_txn[2]] 
set_property PACKAGE_PIN AJ9 [get_ports pcie_txp[3]] 
set_property PACKAGE_PIN AJ8 [get_ports pcie_txn[3]] 

#GTH BANK 226 PCIE 7:4
set_property PACKAGE_PIN AK2 [get_ports pcie_rxp[4]] 
set_property PACKAGE_PIN AK1 [get_ports pcie_rxn[4]] 
set_property PACKAGE_PIN AL4 [get_ports pcie_rxp[5]] 
set_property PACKAGE_PIN AL3 [get_ports pcie_rxn[5]] 
set_property PACKAGE_PIN AM2 [get_ports pcie_rxp[6]] 
set_property PACKAGE_PIN AM1 [get_ports pcie_rxn[6]] 
set_property PACKAGE_PIN AN4 [get_ports pcie_rxp[7]] 
set_property PACKAGE_PIN AN3 [get_ports pcie_rxn[7]] 
set_property PACKAGE_PIN AK7 [get_ports pcie_txp[4]] 
set_property PACKAGE_PIN AK6 [get_ports pcie_txn[4]] 
set_property PACKAGE_PIN AL9 [get_ports pcie_txp[5]] 
set_property PACKAGE_PIN AL8 [get_ports pcie_txn[5]] 
set_property PACKAGE_PIN AM7 [get_ports pcie_txp[6]] 
set_property PACKAGE_PIN AM6 [get_ports pcie_txn[6]] 
set_property PACKAGE_PIN AN9 [get_ports pcie_txp[7]] 
set_property PACKAGE_PIN AN8 [get_ports pcie_txn[7]] 

#GTH BANK 225 PCIE Lanes 11:8
set_property PACKAGE_PIN AP2 [get_ports pcie_rxp[8]]  
set_property PACKAGE_PIN AP1 [get_ports pcie_rxn[8]]  
set_property PACKAGE_PIN AR4 [get_ports pcie_rxp[9]]  
set_property PACKAGE_PIN AR3 [get_ports pcie_rxn[9]]  
set_property PACKAGE_PIN AT2 [get_ports pcie_rxp[10]] 
set_property PACKAGE_PIN AT1 [get_ports pcie_rxn[10]] 
set_property PACKAGE_PIN AU4 [get_ports pcie_rxp[11]] 
set_property PACKAGE_PIN AU3 [get_ports pcie_rxn[11]] 
set_property PACKAGE_PIN AP7 [get_ports pcie_txp[8]]  
set_property PACKAGE_PIN AP6 [get_ports pcie_txn[8]]  
set_property PACKAGE_PIN AR9 [get_ports pcie_txp[9]]  
set_property PACKAGE_PIN AR8 [get_ports pcie_txn[9]]  
set_property PACKAGE_PIN AT7 [get_ports pcie_txp[10]] 
set_property PACKAGE_PIN AT6 [get_ports pcie_txn[10]] 
set_property PACKAGE_PIN AU9 [get_ports pcie_txp[11]] 
set_property PACKAGE_PIN AU8 [get_ports pcie_txn[11]] 

#GTH BANK 224 PCIE Lanes 15:12
set_property PACKAGE_PIN AV2 [get_ports pcie_rxp[12]] 
set_property PACKAGE_PIN AV1 [get_ports pcie_rxn[12]] 
set_property PACKAGE_PIN AW4 [get_ports pcie_rxp[13]] 
set_property PACKAGE_PIN AW3 [get_ports pcie_rxn[13]] 
set_property PACKAGE_PIN BA2 [get_ports pcie_rxp[14]] 
set_property PACKAGE_PIN BA1 [get_ports pcie_rxn[14]] 
set_property PACKAGE_PIN BC2 [get_ports pcie_rxp[15]] 
set_property PACKAGE_PIN BC1 [get_ports pcie_rxn[15]] 
set_property PACKAGE_PIN AV7 [get_ports pcie_txp[12]] 
set_property PACKAGE_PIN AV6 [get_ports pcie_txn[12]] 
set_property PACKAGE_PIN BB5 [get_ports pcie_txp[13]] 
set_property PACKAGE_PIN BB4 [get_ports pcie_txn[13]] 
set_property PACKAGE_PIN BD5 [get_ports pcie_txp[14]] 
set_property PACKAGE_PIN BD4 [get_ports pcie_txn[14]] 
set_property PACKAGE_PIN BF5 [get_ports pcie_txp[15]] 
set_property PACKAGE_PIN BF4 [get_ports pcie_txn[15]] 

##############################################
##########      Memory Clocks       ##########
##############################################
#set_property PACKAGE_PIN AV18 [get_ports ddr4_sys_clk_1_p] # DIMM 1 Reference Clock
#set_property PACKAGE_PIN AW18 [get_ports ddr4_sys_clk_1_n]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_1_p]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_1_n]
#set_property ODT RTT_48 [get_ports ddr4_sys_clk_1_p]

#set_property PACKAGE_PIN BB36 [get_ports ddr4_sys_clk_2_p] # DIMM 2 Reference Clock
#set_property PACKAGE_PIN BC36 [get_ports ddr4_sys_clk_2_n]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_2_p]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_2_n]
#set_property ODT RTT_48 [get_ports ddr4_sys_clk_2_p]

#set_property PACKAGE_PIN E38  [get_ports ddr4_sys_clk_3_p] # DIMM 3 Reference Clock
#set_property PACKAGE_PIN D38  [get_ports ddr4_sys_clk_3_n]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_3_p]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_3_n]
#set_property ODT RTT_48 [get_ports ddr4_sys_clk_3_p]

#set_property PACKAGE_PIN K18  [get_ports ddr4_sys_clk_4_p] # DIMM 4 Reference Clock
#set_property PACKAGE_PIN J18  [get_ports ddr4_sys_clk_4_n]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_4_p]
#set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_sys_clk_4_n]
#set_property ODT RTT_48 [get_ports ddr4_sys_clk_4_p]

##############################################
##########   Memory DIMM Pins       ##########
##############################################
# NOTE: The following assignments are for four 32GB RDIMMs. Please see example projects for other memory type pinouts
### RDIMM 1
#set_property PACKAGE_PIN BE17 [ get_ports "m0_ddr4_dqs_t[17]" ] # Dimm 1 Data Strobe 17
#set_property PACKAGE_PIN BF17 [ get_ports "m0_ddr4_dqs_c[17]" ] # Dimm 1 Data Strobe 17
#set_property PACKAGE_PIN BF19 [ get_ports "m0_ddr4_dq[71]" ] # Dimm 1 Data pin 71
#set_property PACKAGE_PIN BF18 [ get_ports "m0_ddr4_dq[70]" ] # Dimm 1 Data pin 70
#set_property PACKAGE_PIN BD18 [ get_ports "m0_ddr4_dq[69]" ] # Dimm 1 Data pin 69
#set_property PACKAGE_PIN BE18 [ get_ports "m0_ddr4_dq[68]" ] # Dimm 1 Data pin 68
#set_property PACKAGE_PIN BC19 [ get_ports "m0_ddr4_dqs_t[16]" ] # Dimm 1 Data Strobe 16
#set_property PACKAGE_PIN BD19 [ get_ports "m0_ddr4_dqs_c[16]" ] # Dimm 1 Data Strobe 16
#set_property PACKAGE_PIN BB17 [ get_ports "m0_ddr4_dq[67]" ] # Dimm 1 Data pin 67
#set_property PACKAGE_PIN BC17 [ get_ports "m0_ddr4_dq[66]" ] # Dimm 1 Data pin 66
#set_property PACKAGE_PIN BB19 [ get_ports "m0_ddr4_dq[65]" ] # Dimm 1 Data pin 65
#set_property PACKAGE_PIN BC18 [ get_ports "m0_ddr4_dq[64]" ] # Dimm 1 Data pin 64
#set_property PACKAGE_PIN BF14 [ get_ports "m0_ddr4_dqs_t[15]" ] # Dimm 1 Data Strobe 15
#set_property PACKAGE_PIN BF13 [ get_ports "m0_ddr4_dqs_c[15]" ] # Dimm 1 Data Strobe 15
#set_property PACKAGE_PIN BE15 [ get_ports "m0_ddr4_dq[63]" ] # Dimm 1 Data pin 63
#set_property PACKAGE_PIN BF15 [ get_ports "m0_ddr4_dq[62]" ] # Dimm 1 Data pin 62
#set_property PACKAGE_PIN BD16 [ get_ports "m0_ddr4_dq[61]" ] # Dimm 1 Data pin 61
#set_property PACKAGE_PIN BE16 [ get_ports "m0_ddr4_dq[60]" ] # Dimm 1 Data pin 60
#set_property PACKAGE_PIN BD13 [ get_ports "m0_ddr4_dqs_t[14]" ] # Dimm 1 Data Strobe 14
#set_property PACKAGE_PIN BE13 [ get_ports "m0_ddr4_dqs_c[14]" ] # Dimm 1 Data Strobe 14
#set_property PACKAGE_PIN BD15 [ get_ports "m0_ddr4_dq[59]" ] # Dimm 1 Data pin 59
#set_property PACKAGE_PIN BD14 [ get_ports "m0_ddr4_dq[58]" ] # Dimm 1 Data pin 58
#set_property PACKAGE_PIN BC14 [ get_ports "m0_ddr4_dq[57]" ] # Dimm 1 Data pin 57
#set_property PACKAGE_PIN BC13 [ get_ports "m0_ddr4_dq[56]" ] # Dimm 1 Data pin 56
#set_property PACKAGE_PIN BA12 [ get_ports "m0_ddr4_dqs_t[13]" ] # Dimm 1 Data Strobe 13
#set_property PACKAGE_PIN BB12 [ get_ports "m0_ddr4_dqs_c[13]" ] # Dimm 1 Data Strobe 13
#set_property PACKAGE_PIN AY12 [ get_ports "m0_ddr4_dq[55]" ] # Dimm 1 Data pin 55
#set_property PACKAGE_PIN AY11 [ get_ports "m0_ddr4_dq[54]" ] # Dimm 1 Data pin 54
#set_property PACKAGE_PIN AY16 [ get_ports "m0_ddr4_dq[53]" ] # Dimm 1 Data pin 53
#set_property PACKAGE_PIN AY15 [ get_ports "m0_ddr4_dq[52]" ] # Dimm 1 Data pin 52
#set_property PACKAGE_PIN BB15 [ get_ports "m0_ddr4_dqs_t[12]" ] # Dimm 1 Data Strobe 12
#set_property PACKAGE_PIN BB14 [ get_ports "m0_ddr4_dqs_c[12]" ] # Dimm 1 Data Strobe 12
#set_property PACKAGE_PIN BA15 [ get_ports "m0_ddr4_dq[51]" ] # Dimm 1 Data pin 51
#set_property PACKAGE_PIN BA14 [ get_ports "m0_ddr4_dq[50]" ] # Dimm 1 Data pin 50
#set_property PACKAGE_PIN AY13 [ get_ports "m0_ddr4_dq[49]" ] # Dimm 1 Data pin 49
#set_property PACKAGE_PIN BA13 [ get_ports "m0_ddr4_dq[48]" ] # Dimm 1 Data pin 48
#set_property PACKAGE_PIN AW14 [ get_ports "m0_ddr4_dqs_t[11]" ] # Dimm 1 Data Strobe 11
#set_property PACKAGE_PIN AW13 [ get_ports "m0_ddr4_dqs_c[11]" ] # Dimm 1 Data Strobe 11
#set_property PACKAGE_PIN AW16 [ get_ports "m0_ddr4_dq[47]" ] # Dimm 1 Data pin 47
#set_property PACKAGE_PIN AW15 [ get_ports "m0_ddr4_dq[46]" ] # Dimm 1 Data pin 46
#set_property PACKAGE_PIN AU13 [ get_ports "m0_ddr4_dq[45]" ] # Dimm 1 Data pin 45
#set_property PACKAGE_PIN AV13 [ get_ports "m0_ddr4_dq[44]" ] # Dimm 1 Data pin 44
#set_property PACKAGE_PIN AU14 [ get_ports "m0_ddr4_dqs_t[10]" ] # Dimm 1 Data Strobe 10
#set_property PACKAGE_PIN AV14 [ get_ports "m0_ddr4_dqs_c[10]" ] # Dimm 1 Data Strobe 10
#set_property PACKAGE_PIN AT15 [ get_ports "m0_ddr4_dq[43]" ] # Dimm 1 Data pin 43
#set_property PACKAGE_PIN AU15 [ get_ports "m0_ddr4_dq[42]" ] # Dimm 1 Data pin 42
#set_property PACKAGE_PIN AU16 [ get_ports "m0_ddr4_dq[41]" ] # Dimm 1 Data pin 41
#set_property PACKAGE_PIN AV16 [ get_ports "m0_ddr4_dq[40]" ] # Dimm 1 Data pin 40
#set_property PACKAGE_PIN AR16 [ get_ports "m0_ddr4_dqs_t[9]" ] # Dimm 1 Data Strobe 9
#set_property PACKAGE_PIN AR15 [ get_ports "m0_ddr4_dqs_c[9]" ] # Dimm 1 Data Strobe 9
#set_property PACKAGE_PIN AP15 [ get_ports "m0_ddr4_dq[39]" ] # Dimm 1 Data pin 39
#set_property PACKAGE_PIN AP14 [ get_ports "m0_ddr4_dq[38]" ] # Dimm 1 Data pin 38
#set_property PACKAGE_PIN AN14 [ get_ports "m0_ddr4_dq[37]" ] # Dimm 1 Data pin 37
#set_property PACKAGE_PIN AN13 [ get_ports "m0_ddr4_dq[36]" ] # Dimm 1 Data pin 36
#set_property PACKAGE_PIN AP13 [ get_ports "m0_ddr4_dqs_t[8]" ] # Dimm 1 Data Strobe 8
#set_property PACKAGE_PIN AR13 [ get_ports "m0_ddr4_dqs_c[8]" ] # Dimm 1 Data Strobe 8
#set_property PACKAGE_PIN AL15 [ get_ports "m0_ddr4_dq[35]" ] # Dimm 1 Data pin 35
#set_property PACKAGE_PIN AM15 [ get_ports "m0_ddr4_dq[34]" ] # Dimm 1 Data pin 34
#set_property PACKAGE_PIN AL14 [ get_ports "m0_ddr4_dq[33]" ] # Dimm 1 Data pin 33
#set_property PACKAGE_PIN AM14 [ get_ports "m0_ddr4_dq[32]" ] # Dimm 1 Data pin 32
#set_property PACKAGE_PIN BF28 [ get_ports "m0_ddr4_dqs_t[7]" ] # Dimm 1 Data Strobe 7
#set_property PACKAGE_PIN BF29 [ get_ports "m0_ddr4_dqs_c[7]" ] # Dimm 1 Data Strobe 7
#set_property PACKAGE_PIN BE27 [ get_ports "m0_ddr4_dq[31]" ] # Dimm 1 Data pin 31
#set_property PACKAGE_PIN BF27 [ get_ports "m0_ddr4_dq[30]" ] # Dimm 1 Data pin 30
#set_property PACKAGE_PIN BD28 [ get_ports "m0_ddr4_dq[29]" ] # Dimm 1 Data pin 29
#set_property PACKAGE_PIN BE28 [ get_ports "m0_ddr4_dq[28]" ] # Dimm 1 Data pin 28
#set_property PACKAGE_PIN BD26 [ get_ports "m0_ddr4_dqs_t[6]" ] # Dimm 1 Data Strobe 6
#set_property PACKAGE_PIN BE26 [ get_ports "m0_ddr4_dqs_c[6]" ] # Dimm 1 Data Strobe
#set_property PACKAGE_PIN BE25 [ get_ports "m0_ddr4_dq[27]" ] # Dimm 1 Data pin 27
#set_property PACKAGE_PIN BF25 [ get_ports "m0_ddr4_dq[26]" ] # Dimm 1 Data pin 26
#set_property PACKAGE_PIN BC26 [ get_ports "m0_ddr4_dq[25]" ] # Dimm 1 Data pin 25
#set_property PACKAGE_PIN BC27 [ get_ports "m0_ddr4_dq[24]" ] # Dimm 1 Data pin 24
#set_property PACKAGE_PIN BA25 [ get_ports "m0_ddr4_dqs_t[5]" ] # Dimm 1 Data Strobe 5
#set_property PACKAGE_PIN BB25 [ get_ports "m0_ddr4_dqs_c[5]" ] # Dimm 1 Data Strobe 5
#set_property PACKAGE_PIN BB26 [ get_ports "m0_ddr4_dq[23]" ] # Dimm 1 Data pin 23
#set_property PACKAGE_PIN BB27 [ get_ports "m0_ddr4_dq[22]" ] # Dimm 1 Data pin 22
#set_property PACKAGE_PIN BA27 [ get_ports "m0_ddr4_dq[21]" ] # Dimm 1 Data pin 21
#set_property PACKAGE_PIN BA28 [ get_ports "m0_ddr4_dq[20]" ] # Dimm 1 Data pin 20
#set_property PACKAGE_PIN AW25 [ get_ports "m0_ddr4_dqs_t[4]" ] # Dimm 1 Data Strobe 4
#set_property PACKAGE_PIN AY25 [ get_ports "m0_ddr4_dqs_c[4]" ] # Dimm 1 Data Strobe 4
#set_property PACKAGE_PIN AY26 [ get_ports "m0_ddr4_dq[19]" ] # Dimm 1 Data pin 19
#set_property PACKAGE_PIN AY27 [ get_ports "m0_ddr4_dq[18]" ] # Dimm 1 Data pin 18
#set_property PACKAGE_PIN AW28 [ get_ports "m0_ddr4_dq[17]" ] # Dimm 1 Data pin 17
#set_property PACKAGE_PIN AY28 [ get_ports "m0_ddr4_dq[16]" ] # Dimm 1 Data pin 16
#set_property PACKAGE_PIN AV26 [ get_ports "m0_ddr4_dqs_t[3]" ] # Dimm 1 Data Strobe 3
#set_property PACKAGE_PIN AW26 [ get_ports "m0_ddr4_dqs_c[3]" ] # Dimm 1 Data Strobe 3
#set_property PACKAGE_PIN AV27 [ get_ports "m0_ddr4_dq[15]" ] # Dimm 1 Data pin 15
#set_property PACKAGE_PIN AV28 [ get_ports "m0_ddr4_dq[14]" ] # Dimm 1 Data pin 14
#set_property PACKAGE_PIN AU26 [ get_ports "m0_ddr4_dq[13]" ] # Dimm 1 Data pin 13
#set_property PACKAGE_PIN AU27 [ get_ports "m0_ddr4_dq[12]" ] # Dimm 1 Data pin 12
#set_property PACKAGE_PIN AR25 [ get_ports "m0_ddr4_dqs_t[2]" ] # Dimm 1 Data Strobe 2
#set_property PACKAGE_PIN AT25 [ get_ports "m0_ddr4_dqs_c[2]" ] # Dimm 1 Data Strobe 2
#set_property PACKAGE_PIN AR27 [ get_ports "m0_ddr4_dq[11]" ] # Dimm 1 Data pin 11
#set_property PACKAGE_PIN AT27 [ get_ports "m0_ddr4_dq[10]" ] # Dimm 1 Data pin 10
#set_property PACKAGE_PIN AR28 [ get_ports "m0_ddr4_dq[9]" ] # Dimm 1 Data pin 9
#set_property PACKAGE_PIN AT28 [ get_ports "m0_ddr4_dq[8]" ] # Dimm 1 Data pin 8
#set_property PACKAGE_PIN AP25 [ get_ports "m0_ddr4_dqs_t[1]" ] # Data Strobe 1 # Dimm 1 Data Strobe 1
#set_property PACKAGE_PIN AP26 [ get_ports "m0_ddr4_dqs_c[1]" ] # Data Strobe 1 # Dimm 1 Data Strobe 1
#set_property PACKAGE_PIN AN28 [ get_ports "m0_ddr4_dq[7]" ] # Dimm 1 Data pin 7
#set_property PACKAGE_PIN AP28 [ get_ports "m0_ddr4_dq[6]" ] # Dimm 1 Data pin 6
#set_property PACKAGE_PIN AL25 [ get_ports "m0_ddr4_dq[5]" ] # Dimm 1 Data pin 5
#set_property PACKAGE_PIN AM25 [ get_ports "m0_ddr4_dq[4]" ] # Dimm 1 Data pin 4
#set_property PACKAGE_PIN AM26 [ get_ports "m0_ddr4_dqs_t[0]" ] # Dimm 1 Data Strobe 0
#set_property PACKAGE_PIN AN26 [ get_ports "m0_ddr4_dqs_c[0]" ] # Dimm 1 Data Strobe 0
#set_property PACKAGE_PIN AM27 [ get_ports "m0_ddr4_dq[3]" ] # Dimm 1 Data pin 3
#set_property PACKAGE_PIN AN27 [ get_ports "m0_ddr4_dq[2]" ] # Dimm 1 Data pin 2
#set_property PACKAGE_PIN AL27 [ get_ports "m0_ddr4_dq[1]" ] # Dimm 1 Data pin 1
#set_property PACKAGE_PIN AL28 [ get_ports "m0_ddr4_dq[0]" ] # Dimm 1 Data pin 0
#set_property PACKAGE_PIN AY17 [ get_ports "m0_ddr4_reset_n" ] # Dimm 1 Active Low Reset
##set_property PACKAGE_PIN BA17 [ get_ports "m0_ddr4_c[0]" ] # Dimm 1 Active Low Chip Select 2
##set_property PACKAGE_PIN AY18 [ get_ports "m0_ddr4_c[1]" ] # Dimm 1 Active Low Chip Select 3
##set_property PACKAGE_PIN AM17 [ get_ports "m0_ddr4_c[2]" ] # Dimm 1 Die Select
##set_property PACKAGE_PIN AU25 [ get_ports "m0_ddr4_c[3]" ] # Dimm 1 RFU
##set_property PACKAGE_PIN AT14 [ get_ports "m0_ddr4_c[4]" ] # Dimm 1 RFU
#set_property PACKAGE_PIN BA18 [ get_ports "m0_ddr4_cs_n[0]" ] # Dimm 1 Active Low Chip Select 0
#set_property PACKAGE_PIN AW20 [ get_ports "m0_ddr4_cs_n[1]" ] # Dimm 1 Active Low Chip Select 1
#set_property PACKAGE_PIN AY20 [ get_ports "m0_ddr4_cke[0]" ] # Dimm 1 Clock Enable 0
#set_property PACKAGE_PIN AV21 [ get_ports "m0_ddr4_cke[1]" ] # Dimm 1 Clock Enable 1
#set_property PACKAGE_PIN AW21 [ get_ports "m0_ddr4_odt[0]" ] # Dimm 1 On Die Termination 0
#set_property PACKAGE_PIN AV19 [ get_ports "m0_ddr4_odt[1]" ] # Dimm 1 On Die Termination 1
#set_property PACKAGE_PIN AW19 [ get_ports "m0_ddr4_parity" ] # Dimm 1 Parity
#set_property PACKAGE_PIN AV17 [ get_ports "m0_ddr4_act_n" ] # Dimm 1 Activation Command Low
#set_property PACKAGE_PIN AT19 [ get_ports "m0_ddr4_ba[0]" ] # Dimm 1 Bank Address 0
#set_property PACKAGE_PIN AU19 [ get_ports "m0_ddr4_ba[1]" ] # Dimm 1 Bank Address 1
#set_property PACKAGE_PIN AT20 [ get_ports "m0_ddr4_bg[0]" ] # Dimm 1 Bank Group 0
#set_property PACKAGE_PIN AU20 [ get_ports "m0_ddr4_bg[1]" ] # Dimm 1 Bank Address 1
#set_property PACKAGE_PIN AR17 [ get_ports "m0_ddr4_ck_t" ] # Dimm 1 Clock
#set_property PACKAGE_PIN AT17 [ get_ports "m0_ddr4_ck_c" ] # Dimm 1 Clock
#set_property PACKAGE_PIN AT18 [ get_ports "m0_ddr4_adr[0]" ] # Dimm 1 Address Pin 0
#set_property PACKAGE_PIN AU17 [ get_ports "m0_ddr4_adr[1]" ] # Dimm 1 Address Pin 1
#set_property PACKAGE_PIN AP18 [ get_ports "m0_ddr4_adr[2]" ] # Dimm 1 Address Pin 2
#set_property PACKAGE_PIN AR18 [ get_ports "m0_ddr4_adr[3]" ] # Dimm 1 Address Pin 3
#set_property PACKAGE_PIN AP20 [ get_ports "m0_ddr4_adr[4]" ] # Dimm 1 Address Pin 4
#set_property PACKAGE_PIN AR20 [ get_ports "m0_ddr4_adr[5]" ] # Dimm 1 Address Pin 5
#set_property PACKAGE_PIN AU21 [ get_ports "m0_ddr4_adr[6]" ] # Dimm 1 Address Pin 6
#set_property PACKAGE_PIN AN18 [ get_ports "m0_ddr4_adr[7]" ] # Dimm 1 Address Pin 7
#set_property PACKAGE_PIN AN17 [ get_ports "m0_ddr4_adr[8]" ] # Dimm 1 Address Pin 8
#set_property PACKAGE_PIN AN19 [ get_ports "m0_ddr4_adr[9]" ] # Dimm 1 Address Pin 9
#set_property PACKAGE_PIN AP19 [ get_ports "m0_ddr4_adr[10]" ] # Dimm 1 Address Pin 10
#set_property PACKAGE_PIN AM16 [ get_ports "m0_ddr4_adr[11]" ] # Dimm 1 Address Pin 11
#set_property PACKAGE_PIN AN16 [ get_ports "m0_ddr4_adr[12]" ] # Dimm 1 Address Pin 12
#set_property PACKAGE_PIN AL19 [ get_ports "m0_ddr4_adr[13]" ] # Dimm 1 Address Pin 13
#set_property PACKAGE_PIN AM19 [ get_ports "m0_ddr4_adr[14]" ] # Dimm 1 Address Pin 14
#set_property PACKAGE_PIN AL20 [ get_ports "m0_ddr4_adr[15]" ] # Dimm 1 Address Pin 15
#set_property PACKAGE_PIN AM20 [ get_ports "m0_ddr4_adr[16]" ] # Dimm 1 Address Pin 16
#set_property PACKAGE_PIN AP16 [ get_ports "m0_ddr4_adr[17]" ] # Dimm 1 Address Pin 17

#### RDIMM 2
#set_property PACKAGE_PIN BF39 [ get_ports "m1_ddr4_dqs_t[17]" ] # Dimm 2 Data Strobe 17
#set_property PACKAGE_PIN BF40 [ get_ports "m1_ddr4_dqs_c[17]" ] # Dimm 2 Data Strobe 17
#set_property PACKAGE_PIN BE38 [ get_ports "m1_ddr4_dq[71]" ] # Dimm 2 Data Pin 71
#set_property PACKAGE_PIN BF38 [ get_ports "m1_ddr4_dq[70]" ] # Dimm 2 Data Pin 70
#set_property PACKAGE_PIN BE37 [ get_ports "m1_ddr4_dq[69]" ] # Dimm 2 Data Pin 69
#set_property PACKAGE_PIN BF37 [ get_ports "m1_ddr4_dq[68]" ] # Dimm 2 Data Pin 68
#set_property PACKAGE_PIN BD40 [ get_ports "m1_ddr4_dqs_t[16]" ] # Dimm 2 Data Strobe 16
#set_property PACKAGE_PIN BE40 [ get_ports "m1_ddr4_dqs_c[16]" ] # Dimm 2 Data Strobe 16
#set_property PACKAGE_PIN BC39 [ get_ports "m1_ddr4_dq[67]" ] # Dimm 2 Data Pin 67
#set_property PACKAGE_PIN BD39 [ get_ports "m1_ddr4_dq[66]" ] # Dimm 2 Data Pin 66
#set_property PACKAGE_PIN BB38 [ get_ports "m1_ddr4_dq[65]" ] # Dimm 2 Data Pin 65
#set_property PACKAGE_PIN BC38 [ get_ports "m1_ddr4_dq[64]" ] # Dimm 2 Data Pin 64
#set_property PACKAGE_PIN BF32 [ get_ports "m1_ddr4_dqs_t[15]" ] # Dimm 2 Data Strobe 15
#set_property PACKAGE_PIN BF33 [ get_ports "m1_ddr4_dqs_c[15]" ] # Dimm 2 Data Strobe 15
#set_property PACKAGE_PIN BE31 [ get_ports "m1_ddr4_dq[63]" ] # Dimm 2 Data Pin 63
#set_property PACKAGE_PIN BE32 [ get_ports "m1_ddr4_dq[62]" ] # Dimm 2 Data Pin 62
#set_property PACKAGE_PIN BE30 [ get_ports "m1_ddr4_dq[61]" ] # Dimm 2 Data Pin 61
#set_property PACKAGE_PIN BF30 [ get_ports "m1_ddr4_dq[60]" ] # Dimm 2 Data Pin 60
#set_property PACKAGE_PIN BD30 [ get_ports "m1_ddr4_dqs_t[14]" ] # Dimm 2 Data Strobe 14
#set_property PACKAGE_PIN BD31 [ get_ports "m1_ddr4_dqs_c[14]" ] # Dimm 2 Data Strobe 14
#set_property PACKAGE_PIN BD33 [ get_ports "m1_ddr4_dq[59]" ] # Dimm 2 Data Pin 59
#set_property PACKAGE_PIN BE33 [ get_ports "m1_ddr4_dq[58]" ] # Dimm 2 Data Pin 58
#set_property PACKAGE_PIN BC29 [ get_ports "m1_ddr4_dq[57]" ] # Dimm 2 Data Pin 57
#set_property PACKAGE_PIN BD29 [ get_ports "m1_ddr4_dq[56]" ] # Dimm 2 Data Pin 56
#set_property PACKAGE_PIN BC31 [ get_ports "m1_ddr4_dqs_t[13]" ] # Dimm 2 Data Strobe 13
#set_property PACKAGE_PIN BC32 [ get_ports "m1_ddr4_dqs_c[13]" ] # Dimm 2 Data Strobe 13
#set_property PACKAGE_PIN BB30 [ get_ports "m1_ddr4_dq[55]" ]  # Dimm 2 Data Pin 55
#set_property PACKAGE_PIN BB31 [ get_ports "m1_ddr4_dq[54]" ] # Dimm 2 Data Pin 54
#set_property PACKAGE_PIN BA29 [ get_ports "m1_ddr4_dq[53]" ] # Dimm 2 Data Pin 53
#set_property PACKAGE_PIN BB29 [ get_ports "m1_ddr4_dq[52]" ] # Dimm 2 Data Pin 52
#set_property PACKAGE_PIN BA32 [ get_ports "m1_ddr4_dqs_t[12]" ] # Dimm 2 Data Strobe 12
#set_property PACKAGE_PIN BB32 [ get_ports "m1_ddr4_dqs_c[12]" ] # Dimm 2 Data Strobe 12
#set_property PACKAGE_PIN AY30 [ get_ports "m1_ddr4_dq[51]" ] # Dimm 2 Data Pin 51
#set_property PACKAGE_PIN BA30 [ get_ports "m1_ddr4_dq[50]" ] # Dimm 2 Data Pin 50
#set_property PACKAGE_PIN AY31 [ get_ports "m1_ddr4_dq[49]" ] # Dimm 2 Data Pin 49
#set_property PACKAGE_PIN AY32 [ get_ports "m1_ddr4_dq[48]" ] # Dimm 2 Data Pin 48
#set_property PACKAGE_PIN AW29 [ get_ports "m1_ddr4_dqs_t[11]" ] # Dimm 2 Data Strobe 11
#set_property PACKAGE_PIN AW30 [ get_ports "m1_ddr4_dqs_c[11]" ] # Dimm 2 Data Strobe 11
#set_property PACKAGE_PIN AV31 [ get_ports "m1_ddr4_dq[47]" ] # Dimm 2 Data Pin 47
#set_property PACKAGE_PIN AW31 [ get_ports "m1_ddr4_dq[46]" ] # Dimm 2 Data Pin 46
#set_property PACKAGE_PIN AU32 [ get_ports "m1_ddr4_dq[45]" ] # Dimm 2 Data Pin 45
#set_property PACKAGE_PIN AV32 [ get_ports "m1_ddr4_dq[44]" ] # Dimm 2 Data Pin 44
#set_property PACKAGE_PIN AU29 [ get_ports "m1_ddr4_dqs_t[10]" ] # Dimm 2 Data Strobe 10
#set_property PACKAGE_PIN AV29 [ get_ports "m1_ddr4_dqs_c[10]" ] # Dimm 2 Data Strobe 10
#set_property PACKAGE_PIN AU30 [ get_ports "m1_ddr4_dq[43]" ] # Dimm 2 Data Pin 43
#set_property PACKAGE_PIN AU31 [ get_ports "m1_ddr4_dq[42]" ] # Dimm 2 Data Pin 42
#set_property PACKAGE_PIN AT29 [ get_ports "m1_ddr4_dq[41]" ] # Dimm 2 Data Pin 41
#set_property PACKAGE_PIN AT30 [ get_ports "m1_ddr4_dq[40]" ] # Dimm 2 Data Pin 40
#set_property PACKAGE_PIN AP31 [ get_ports "m1_ddr4_dqs_t[9]" ] # Dimm 2 Data Strobe 9
#set_property PACKAGE_PIN AR31 [ get_ports "m1_ddr4_dqs_c[9]" ] # Dimm 2 Data Strobe 9
#set_property PACKAGE_PIN AP30 [ get_ports "m1_ddr4_dq[39]" ] # Dimm 2 Data Pin 39
#set_property PACKAGE_PIN AR30 [ get_ports "m1_ddr4_dq[38]" ] # Dimm 2 Data Pin 38
#set_property PACKAGE_PIN AN29 [ get_ports "m1_ddr4_dq[37]" ] # Dimm 2 Data Pin 37
#set_property PACKAGE_PIN AP29 [ get_ports "m1_ddr4_dq[36]" ] # Dimm 2 Data Pin 36
#set_property PACKAGE_PIN AM29 [ get_ports "m1_ddr4_dqs_t[8]" ] # Dimm 2 Data Strobe 8
#set_property PACKAGE_PIN AM30 [ get_ports "m1_ddr4_dqs_c[8]" ] # Dimm 2 Data Strobe 8
#set_property PACKAGE_PIN AM31 [ get_ports "m1_ddr4_dq[35]" ] # Dimm 2 Data Pin 35
#set_property PACKAGE_PIN AN31 [ get_ports "m1_ddr4_dq[34]" ] # Dimm 2 Data Pin 34
#set_property PACKAGE_PIN AL29 [ get_ports "m1_ddr4_dq[33]" ] # Dimm 2 Data Pin 33
#set_property PACKAGE_PIN AL30 [ get_ports "m1_ddr4_dq[32]" ] # Dimm 2 Data Pin 32
#set_property PACKAGE_PIN AJ27 [ get_ports "m1_ddr4_dqs_t[7]" ] # Dimm 2 Data Strobe 7
#set_property PACKAGE_PIN AK27 [ get_ports "m1_ddr4_dqs_c[7]" ] # Dimm 2 Data Strobe 7
#set_property PACKAGE_PIN AJ28 [ get_ports "m1_ddr4_dq[31]" ] # Dimm 2 Data Pin 31
#set_property PACKAGE_PIN AK28 [ get_ports "m1_ddr4_dq[30]" ] # Dimm 2 Data Pin 30
#set_property PACKAGE_PIN AJ29 [ get_ports "m1_ddr4_dq[29]" ] # Dimm 2 Data Pin 29
#set_property PACKAGE_PIN AJ30 [ get_ports "m1_ddr4_dq[28]" ] # Dimm 2 Data Pin 28
#set_property PACKAGE_PIN AH28 [ get_ports "m1_ddr4_dqs_t[6]" ] # Dimm 2 Data Strobe 6
#set_property PACKAGE_PIN AH29 [ get_ports "m1_ddr4_dqs_c[6]" ] # Dimm 2 Data Strobe 6
#set_property PACKAGE_PIN AG29 [ get_ports "m1_ddr4_dq[27]" ] # Dimm 2 Data Pin 27
#set_property PACKAGE_PIN AG30 [ get_ports "m1_ddr4_dq[26]" ] # Dimm 2 Data Pin 26
#set_property PACKAGE_PIN AJ31 [ get_ports "m1_ddr4_dq[25]" ] # Dimm 2 Data Pin 25
#set_property PACKAGE_PIN AK31 [ get_ports "m1_ddr4_dq[24]" ] # Dimm 2 Data Pin 24
#set_property PACKAGE_PIN AH34 [ get_ports "m1_ddr4_dqs_t[5]" ] # Dimm 2 Data Strobe 5
#set_property PACKAGE_PIN AJ34 [ get_ports "m1_ddr4_dqs_c[5]" ] # Dimm 2 Data Strobe 5
#set_property PACKAGE_PIN AH33 [ get_ports "m1_ddr4_dq[23]" ] # Dimm 2 Data Pin 23
#set_property PACKAGE_PIN AJ33 [ get_ports "m1_ddr4_dq[22]" ] # Dimm 2 Data Pin 22
#set_property PACKAGE_PIN AF34 [ get_ports "m1_ddr4_dq[21]" ] # Dimm 2 Data Pin 21
#set_property PACKAGE_PIN AG34 [ get_ports "m1_ddr4_dq[20]" ] # Dimm 2 Data Pin 20
#set_property PACKAGE_PIN AH31 [ get_ports "m1_ddr4_dqs_t[4]" ] # Dimm 2 Data Strobe 4
#set_property PACKAGE_PIN AH32 [ get_ports "m1_ddr4_dqs_c[4]" ] # Dimm 2 Data Strobe 4
#set_property PACKAGE_PIN AG31 [ get_ports "m1_ddr4_dq[19]" ] # Dimm 2 Data Pin 19
#set_property PACKAGE_PIN AG32 [ get_ports "m1_ddr4_dq[18]" ] # Dimm 2 Data Pin 18
#set_property PACKAGE_PIN AF32 [ get_ports "m1_ddr4_dq[17]" ] # Dimm 2 Data Pin 17
#set_property PACKAGE_PIN AF33 [ get_ports "m1_ddr4_dq[16]" ] # Dimm 2 Data Pin 16
#set_property PACKAGE_PIN AE31 [ get_ports "m1_ddr4_dqs_t[3]" ] # Dimm 2 Data Strobe 3
#set_property PACKAGE_PIN AE32 [ get_ports "m1_ddr4_dqs_c[3]" ] # Dimm 2 Data Strobe 3
#set_property PACKAGE_PIN AD33 [ get_ports "m1_ddr4_dq[15]" ] # Dimm 2 Data Pin 15
#set_property PACKAGE_PIN AE33 [ get_ports "m1_ddr4_dq[14]" ] # Dimm 2 Data Pin 14
#set_property PACKAGE_PIN AE30 [ get_ports "m1_ddr4_dq[13]" ] # Dimm 2 Data Pin 13
#set_property PACKAGE_PIN AF30 [ get_ports "m1_ddr4_dq[12]" ] # Dimm 2 Data Pin 12
#set_property PACKAGE_PIN AC31 [ get_ports "m1_ddr4_dqs_t[2]" ] # Dimm 2 Data Strobe 2
#set_property PACKAGE_PIN AD31 [ get_ports "m1_ddr4_dqs_c[2]" ] # Dimm 2 Data Strobe 2
#set_property PACKAGE_PIN AC32 [ get_ports "m1_ddr4_dq[11]" ] # Dimm 2 Data Pin 11
#set_property PACKAGE_PIN AC33 [ get_ports "m1_ddr4_dq[10]" ] # Dimm 2 Data Pin 10
#set_property PACKAGE_PIN AC34 [ get_ports "m1_ddr4_dq[9]" ] # Dimm 2 Data Pin 9
#set_property PACKAGE_PIN AD34 [ get_ports "m1_ddr4_dq[8]" ] # Dimm 2 Data Pin 8
#set_property PACKAGE_PIN AA32 [ get_ports "m1_ddr4_dqs_t[1]" ] # Dimm 2 Data Strobe 1
#set_property PACKAGE_PIN AA33 [ get_ports "m1_ddr4_dqs_c[1]" ] # Dimm 2 Data Strobe 1
#set_property PACKAGE_PIN AA34 [ get_ports "m1_ddr4_dq[7]" ] # Dimm 2 Data Pin 7
#set_property PACKAGE_PIN AB34 [ get_ports "m1_ddr4_dq[6]" ] # Dimm 2 Data Pin 6
#set_property PACKAGE_PIN W30 [ get_ports "m1_ddr4_dq[5]" ] # Dimm 2 Data Pin 5
#set_property PACKAGE_PIN Y30 [ get_ports "m1_ddr4_dq[4]" ] # Dimm 2 Data Pin 4
#set_property PACKAGE_PIN W31 [ get_ports "m1_ddr4_dqs_t[0]" ] # Dimm 2 Data Strobe 0
#set_property PACKAGE_PIN Y31 [ get_ports "m1_ddr4_dqs_c[0]" ] # Dimm 2 Data Strobe 0
#set_property PACKAGE_PIN Y32 [ get_ports "m1_ddr4_dq[3]" ] # Dimm 2 Data Pin 3
#set_property PACKAGE_PIN Y33 [ get_ports "m1_ddr4_dq[2]" ] # Dimm 2 Data Pin 2
#set_property PACKAGE_PIN W33 [ get_ports "m1_ddr4_dq[1]" ] # Dimm 2 Data Pin 1
#set_property PACKAGE_PIN W34 [ get_ports "m1_ddr4_dq[0]" ] # Dimm 2 Data Pin 0
#set_property PACKAGE_PIN BC34 [ get_ports "m1_ddr4_reset_n" ] # Dimm 2 Active Low Reset
## Dimm 2set_property PACKAGE_PIN BD34 [ get_ports "m1_ddr4_c[0]" ] # Dimm 2 Active Low Chip Select 2
## Dimm 2set_property PACKAGE_PIN BD35 [ get_ports "m1_ddr4_c[1]" ] # Dimm 2 Active Low Chip Select 3
## Dimm 2set_property PACKAGE_PIN AN33 [ get_ports "m1_ddr4_c[2]" ] # Dimm 2 Die Select
## Dimm 2set_property PACKAGE_PIN AD30 [ get_ports "m1_ddr4_c[3]" ] # Dimm 2 RFU
## Dimm 2set_property PACKAGE_PIN AT32 [ get_ports "m1_ddr4_c[4]" ] # Dimm 2 RFU
#set_property PACKAGE_PIN BE35 [ get_ports "m1_ddr4_cs_n[0]" ] # Dimm 2 Active Low Chip Select 0
#set_property PACKAGE_PIN BD36 [ get_ports "m1_ddr4_cs_n[1]" ] # Dimm 2 Active Low Chip Select 1
#set_property PACKAGE_PIN BE36 [ get_ports "m1_ddr4_cke[0]" ] # Dimm 2 Clock Enable 0
#set_property PACKAGE_PIN BB37 [ get_ports "m1_ddr4_cke[1]" ] # Dimm 2 Clock Enable 1
#set_property PACKAGE_PIN BC37 [ get_ports "m1_ddr4_odt[0]" ] # Dimm 2 On Die Termination 0
#set_property PACKAGE_PIN BA35 [ get_ports "m1_ddr4_odt[1]" ] # Dimm 2 On Die Termination 1
#set_property PACKAGE_PIN BB35 [ get_ports "m1_ddr4_parity" ] # Dimm 2 Parity
#set_property PACKAGE_PIN BF35 [ get_ports "m1_ddr4_act_n" ] # Dimm 2 Activation Command Low
#set_property PACKAGE_PIN BA34 [ get_ports "m1_ddr4_ba[0]" ] # Dimm 2 Bank Address 0
#set_property PACKAGE_PIN BB34 [ get_ports "m1_ddr4_ba[1]" } # Dimm 2 Bank Address 1
#set_property PACKAGE_PIN AY35 [ get_ports "m1_ddr4_bg[0]" } # Dimm 2 Bank Group 0
#set_property PACKAGE_PIN AY36 [ get_ports "m1_ddr4_bg[1]" } # Dimm 2 Bank Group 1
#set_property PACKAGE_PIN AW35 [ get_ports "m1_ddr4_ck_t" } # Dimm 2 Clock
#set_property PACKAGE_PIN AW36 [ get_ports "m1_ddr4_ck_c" } # Dimm 2 Clock
#set_property PACKAGE_PIN AY33 [ get_ports "m1_ddr4_adr[0]" } # Dimm 2 Address 0
#set_property PACKAGE_PIN BA33 [ get_ports "m1_ddr4_adr[1]" } # Dimm 2 Address 1
#set_property PACKAGE_PIN AV34 [ get_ports "m1_ddr4_adr[2]" } # Dimm 2 Address 2
#set_property PACKAGE_PIN AW34 [ get_ports "m1_ddr4_adr[3]" } # Dimm 2 Address 3
#set_property PACKAGE_PIN AV33 [ get_ports "m1_ddr4_adr[4]" } # Dimm 2 Address 4
#set_property PACKAGE_PIN AW33 [ get_ports "m1_ddr4_adr[5]" } # Dimm 2 Address 5
#set_property PACKAGE_PIN AU34 [ get_ports "m1_ddr4_adr[6]" } # Dimm 2 Address 6
#set_property PACKAGE_PIN AT33 [ get_ports "m1_ddr4_adr[7]" } # Dimm 2 Address 7
#set_property PACKAGE_PIN AT34 [ get_ports "m1_ddr4_adr[8]" } # Dimm 2 Address 8
#set_property PACKAGE_PIN AP33 [ get_ports "m1_ddr4_adr[9]" } # Dimm 2 Address 9
#set_property PACKAGE_PIN AR33 [ get_ports "m1_ddr4_adr[10]" } # Dimm 2 Address 10
#set_property PACKAGE_PIN AN34 [ get_ports "m1_ddr4_adr[11]" } # Dimm 2 Address 11
#set_property PACKAGE_PIN AP34 [ get_ports "m1_ddr4_adr[12]" } # Dimm 2 Address 12
#set_property PACKAGE_PIN AL32 [ get_ports "m1_ddr4_adr[13]" } # Dimm 2 Address 13
#set_property PACKAGE_PIN AM32 [ get_ports "m1_ddr4_adr[14]" } # Dimm 2 Address 14
#set_property PACKAGE_PIN AL34 [ get_ports "m1_ddr4_adr[15]" } # Dimm 2 Address 15
#set_property PACKAGE_PIN AM34 [ get_ports "m1_ddr4_adr[16]" } # Dimm 2 Address 16
#set_property PACKAGE_PIN AL33 [ get_ports "m1_ddr4_adr[17]" } # Dimm 2 Address 17

####RDIMM 3
#set_property PACKAGE_PIN H37 [ get_ports "m2_ddr4_dqs_t[17]" ] # Dimm 3 Data Strobe 17
#set_property PACKAGE_PIN H38 [ get_ports "m2_ddr4_dqs_c[17]" ] # Dimm 3 Data Strobe 17
#set_property PACKAGE_PIN G37 [ get_ports "m2_ddr4_dq[71]" ] # Dimm 3 Data Pin 71
#set_property PACKAGE_PIN F37 [ get_ports "m2_ddr4_dq[70]" ] # Dimm 3 Data Pin 70
#set_property PACKAGE_PIN J35 [ get_ports "m2_ddr4_dq[69]" ] # Dimm 3 Data Pin 69
#set_property PACKAGE_PIN J36 [ get_ports "m2_ddr4_dq[68]" ] # Dimm 3 Data Pin 68
#set_property PACKAGE_PIN H36 [ get_ports "m2_ddr4_dqs_t[16]" ] # Dimm 3 Data Strobe 16
#set_property PACKAGE_PIN G36 [ get_ports "m2_ddr4_dqs_c[16]" ] # Dimm 3 Data Strobe 16
#set_property PACKAGE_PIN H34 [ get_ports "m2_ddr4_dq[67]" ] # Dimm 3 Data Pin 67
#set_property PACKAGE_PIN G34 [ get_ports "m2_ddr4_dq[66]" ] # Dimm 3 Data Pin 66
#set_property PACKAGE_PIN F34 [ get_ports "m2_ddr4_dq[65]" ] # Dimm 3 Data Pin 65
#set_property PACKAGE_PIN F35 [ get_ports "m2_ddr4_dq[64]" ] # Dimm 3 Data Pin 64
#set_property PACKAGE_PIN T28 [ get_ports "m2_ddr4_dqs_t[15]" ] # Dimm 3 Data Strobe 15
#set_property PACKAGE_PIN R28 [ get_ports "m2_ddr4_dqs_c[15]" ] # Dimm 3 Data Strobe 15
#set_property PACKAGE_PIN T27 [ get_ports "m2_ddr4_dq[63]" ] # Dimm 3 Data Pin 63
#set_property PACKAGE_PIN R27 [ get_ports "m2_ddr4_dq[62]" ] # Dimm 3 Data Pin 62
#set_property PACKAGE_PIN T26 [ get_ports "m2_ddr4_dq[61]" ] # Dimm 3 Data Pin 61
#set_property PACKAGE_PIN R26 [ get_ports "m2_ddr4_dq[60]" ] # Dimm 3 Data Pin 60
#set_property PACKAGE_PIN P29 [ get_ports "m2_ddr4_dqs_t[14]" ] # Dimm 3 Data Strobe 14
#set_property PACKAGE_PIN N29 [ get_ports "m2_ddr4_dqs_c[14]" ] # Dimm 3 Data Strobe 14
#set_property PACKAGE_PIN P28 [ get_ports "m2_ddr4_dq[59]" ] # Dimm 3 Data Pin 59
#set_property PACKAGE_PIN N28 [ get_ports "m2_ddr4_dq[58]" ] # Dimm 3 Data Pin 58
#set_property PACKAGE_PIN P26 [ get_ports "m2_ddr4_dq[57]" ] # Dimm 3 Data Pin 57
#set_property PACKAGE_PIN N26 [ get_ports "m2_ddr4_dq[56]" ] # Dimm 3 Data Pin 56
#set_property PACKAGE_PIN M29 [ get_ports "m2_ddr4_dqs_t[13]" ] # Dimm 3 Data Strobe 13
#set_property PACKAGE_PIN L29 [ get_ports "m2_ddr4_dqs_c[13]" ] # Dimm 3 Data Strobe 13
#set_property PACKAGE_PIN L28 [ get_ports "m2_ddr4_dq[55]" ] # Dimm 3 Data Pin 55
#set_property PACKAGE_PIN K28 [ get_ports "m2_ddr4_dq[54]" ] # Dimm 3 Data Pin 54
#set_property PACKAGE_PIN M27 [ get_ports "m2_ddr4_dq[53]" ] # Dimm 3 Data Pin 53
#set_property PACKAGE_PIN L27 [ get_ports "m2_ddr4_dq[52]" ] # Dimm 3 Data Pin 52
#set_property PACKAGE_PIN K26 [ get_ports "m2_ddr4_dqs_t[12]" ] # Dimm 3 Data Strobe 12
#set_property PACKAGE_PIN K27 [ get_ports "m2_ddr4_dqs_c[12]" ] # Dimm 3 Data Strobe 12
#set_property PACKAGE_PIN H27 [ get_ports "m2_ddr4_dq[51]" ] # Dimm 3 Data Pin 51
#set_property PACKAGE_PIN H28 [ get_ports "m2_ddr4_dq[50]" ] # Dimm 3 Data Pin 50
#set_property PACKAGE_PIN J28 [ get_ports "m2_ddr4_dq[49]" ] # Dimm 3 Data Pin 49
#set_property PACKAGE_PIN J29 [ get_ports "m2_ddr4_dq[48]" ] # Dimm 3 Data Pin 48
#set_property PACKAGE_PIN J26 [ get_ports "m2_ddr4_dqs_t[11]" ] # Dimm 3 Data Strobe 11
#set_property PACKAGE_PIN H26 [ get_ports "m2_ddr4_dqs_c[11]" ] # Dimm 3 Data Strobe 11
#set_property PACKAGE_PIN G26 [ get_ports "m2_ddr4_dq[47]" ] # Dimm 3 Data Pin 47
#set_property PACKAGE_PIN G27 [ get_ports "m2_ddr4_dq[46]" ] # Dimm 3 Data Pin 46
#set_property PACKAGE_PIN H29 [ get_ports "m2_ddr4_dq[45]" ] # Dimm 3 Data Pin 45
#set_property PACKAGE_PIN G29 [ get_ports "m2_ddr4_dq[44]" ] # Dimm 3 Data Pin 44
#set_property PACKAGE_PIN F28 [ get_ports "m2_ddr4_dqs_t[10]" ] # Dimm 3 Data Strobe 10
#set_property PACKAGE_PIN F29 [ get_ports "m2_ddr4_dqs_c[10]" ] # Dimm 3 Data Strobe 10
#set_property PACKAGE_PIN F27 [ get_ports "m2_ddr4_dq[43]" ] # Dimm 3 Data Pin 43
#set_property PACKAGE_PIN E27 [ get_ports "m2_ddr4_dq[42]" ] # Dimm 3 Data Pin 42
#set_property PACKAGE_PIN E28 [ get_ports "m2_ddr4_dq[41]" ] # Dimm 3 Data Pin 41
#set_property PACKAGE_PIN D28 [ get_ports "m2_ddr4_dq[40]" ] # Dimm 3 Data Pin 40
#set_property PACKAGE_PIN C27 [ get_ports "m2_ddr4_dqs_t[9]" ] # Dimm 3 Data Strobe 9
#set_property PACKAGE_PIN B27 [ get_ports "m2_ddr4_dqs_c[9]" ] # Dimm 3 Data Strobe 9
#set_property PACKAGE_PIN D29 [ get_ports "m2_ddr4_dq[39]" ] # Dimm 3 Data Pin 39
#set_property PACKAGE_PIN C29 [ get_ports "m2_ddr4_dq[38]" ] # Dimm 3 Data Pin 38
#set_property PACKAGE_PIN E30 [ get_ports "m2_ddr4_dq[37]" ] # Dimm 3 Data Pin 37
#set_property PACKAGE_PIN D30 [ get_ports "m2_ddr4_dq[36]" ] # Dimm 3 Data Pin 36
#set_property PACKAGE_PIN A27 [ get_ports "m2_ddr4_dqs_t[8]" ] # Dimm 3 Data Strobe 8
#set_property PACKAGE_PIN A28 [ get_ports "m2_ddr4_dqs_c[8]" ] # Dimm 3 Data Strobe 8
#set_property PACKAGE_PIN B29 [ get_ports "m2_ddr4_dq[35]" ] # Dimm 3 Data Pin 35
#set_property PACKAGE_PIN A29 [ get_ports "m2_ddr4_dq[34]" ] # Dimm 3 Data Pin 34
#set_property PACKAGE_PIN B30 [ get_ports "m2_ddr4_dq[33]" ] # Dimm 3 Data Pin 33
#set_property PACKAGE_PIN A30 [ get_ports "m2_ddr4_dq[32]" ] # Dimm 3 Data Pin 32
#set_property PACKAGE_PIN U34 [ get_ports "m2_ddr4_dqs_t[7]" ] # Dimm 3 Data Strobe 7
#set_property PACKAGE_PIN T34 [ get_ports "m2_ddr4_dqs_c[7]" ] # Dimm 3 Data Strobe 7
#set_property PACKAGE_PIN T33 [ get_ports "m2_ddr4_dq[31]" ] # Dimm 3 Data Pin 31
#set_property PACKAGE_PIN R33 [ get_ports "m2_ddr4_dq[30]" ] # Dimm 3 Data Pin 30
#set_property PACKAGE_PIN U32 [ get_ports "m2_ddr4_dq[29]" ] # Dimm 3 Data Pin 29
#set_property PACKAGE_PIN T32 [ get_ports "m2_ddr4_dq[28]" ] # Dimm 3 Data Pin 28
#set_property PACKAGE_PIN V32 [ get_ports "m2_ddr4_dqs_t[6]" ] # Dimm 3 Data Strobe 6
#set_property PACKAGE_PIN V33 [ get_ports "m2_ddr4_dqs_c[6]" ] # Dimm 3 Data Strobe 6
#set_property PACKAGE_PIN V31 [ get_ports "m2_ddr4_dq[27]" ] # Dimm 3 Data Pin 27
#set_property PACKAGE_PIN U31 [ get_ports "m2_ddr4_dq[26]" ] # Dimm 3 Data Pin 26
#set_property PACKAGE_PIN U30 [ get_ports "m2_ddr4_dq[25]" ] # Dimm 3 Data Pin 25
#set_property PACKAGE_PIN T30 [ get_ports "m2_ddr4_dq[24]" ] # Dimm 3 Data Pin 24
#set_property PACKAGE_PIN R30 [ get_ports "m2_ddr4_dqs_t[5]" ] # Dimm 3 Data Strobe 6
#set_property PACKAGE_PIN P30 [ get_ports "m2_ddr4_dqs_c[5]" ] # Dimm 3 Data Strobe 6
#set_property PACKAGE_PIN R31 [ get_ports "m2_ddr4_dq[23]" ] # Dimm 3 Data Pin 23
#set_property PACKAGE_PIN R32 [ get_ports "m2_ddr4_dq[22]" ] # Dimm 3 Data Pin 22
#set_property PACKAGE_PIN P34 [ get_ports "m2_ddr4_dq[21]" ] # Dimm 3 Data Pin 21
#set_property PACKAGE_PIN N34 [ get_ports "m2_ddr4_dq[20]" ] # Dimm 3 Data Pin 20
#set_property PACKAGE_PIN M34 [ get_ports "m2_ddr4_dqs_t[4]" ] # Dimm 3 Data Strobe 4
#set_property PACKAGE_PIN L34 [ get_ports "m2_ddr4_dqs_c[4]" ] # Dimm 3 Data Strobe 4
#set_property PACKAGE_PIN P31 [ get_ports "m2_ddr4_dq[19]" ] # Dimm 3 Data Pin 19
#set_property PACKAGE_PIN N31 [ get_ports "m2_ddr4_dq[18]" ] # Dimm 3 Data Pin 18
#set_property PACKAGE_PIN N32 [ get_ports "m2_ddr4_dq[17]" ] # Dimm 3 Data Pin 17
#set_property PACKAGE_PIN N33 [ get_ports "m2_ddr4_dq[16]" ] # Dimm 3 Data Pin 16
#set_property PACKAGE_PIN M31 [ get_ports "m2_ddr4_dqs_t[3]" ] # Dimm 3 Data Strobe 3
#set_property PACKAGE_PIN M32 [ get_ports "m2_ddr4_dqs_c[3]" ] # Dimm 3 Data Strobe 3
#set_property PACKAGE_PIN L32 [ get_ports "m2_ddr4_dq[15]" ] # Dimm 3 Data Pin 15
#set_property PACKAGE_PIN K32 [ get_ports "m2_ddr4_dq[14]" ] # Dimm 3 Data Pin 14
#set_property PACKAGE_PIN M30 [ get_ports "m2_ddr4_dq[13]" ] # Dimm 3 Data Pin 13
#set_property PACKAGE_PIN L30 [ get_ports "m2_ddr4_dq[12]" ] # Dimm 3 Data Pin 12
#set_property PACKAGE_PIN K30 [ get_ports "m2_ddr4_dqs_t[2]" ] # Dimm 3 Data Strobe 2
#set_property PACKAGE_PIN J30 [ get_ports "m2_ddr4_dqs_c[2]" ] # Dimm 3 Data Strobe 2
#set_property PACKAGE_PIN K31 [ get_ports "m2_ddr4_dq[11]" ] # Dimm 3 Data Pin 11
#set_property PACKAGE_PIN J31 [ get_ports "m2_ddr4_dq[10]" ] # Dimm 3 Data Pin 10
#set_property PACKAGE_PIN L33 [ get_ports "m2_ddr4_dq[9]" ] # Dimm 3 Data Pin 9
#set_property PACKAGE_PIN K33 [ get_ports "m2_ddr4_dq[8]" ] # Dimm 3 Data Pin 8
#set_property PACKAGE_PIN G30 [ get_ports "m2_ddr4_dqs_t[1]" ] # Dimm 3 Data Strobe 1
#set_property PACKAGE_PIN F30 [ get_ports "m2_ddr4_dqs_c[1]" ] # Dimm 3 Data Strobe 1
#set_property PACKAGE_PIN H31 [ get_ports "m2_ddr4_dq[7]" ] # Dimm 3 Data Pin 7
#set_property PACKAGE_PIN G31 [ get_ports "m2_ddr4_dq[6]" ] # Dimm 3 Data Pin 6
#set_property PACKAGE_PIN H32 [ get_ports "m2_ddr4_dq[5]" ] # Dimm 3 Data Pin 5
#set_property PACKAGE_PIN G32 [ get_ports "m2_ddr4_dq[4]" ] # Dimm 3 Data Pin 4
#set_property PACKAGE_PIN J33 [ get_ports "m2_ddr4_dqs_t[0]" ] # Dimm 3 Data Strobe 0
#set_property PACKAGE_PIN H33 [ get_ports "m2_ddr4_dqs_c[0]" ] # Dimm 3 Data Strobe 0
#set_property PACKAGE_PIN F32 [ get_ports "m2_ddr4_dq[3]" ] # Dimm 3 Data Pin 3
#set_property PACKAGE_PIN E32 [ get_ports "m2_ddr4_dq[2]" ] # Dimm 3 Data Pin 2
#set_property PACKAGE_PIN F33 [ get_ports "m2_ddr4_dq[1]" ] # Dimm 3 Data Pin 1
#set_property PACKAGE_PIN E33 [ get_ports "m2_ddr4_dq[0]" ] # Dimm 3 Data Pin 0
#set_property PACKAGE_PIN E40 [ get_ports "m2_ddr4_reset_n" ] # Dimm 3 Active Low Reset
#set_property PACKAGE_PIN D40 [ get_ports "m2_ddr4_c[0]" ] # Dimm 3 Active Low Chip Select 2
#set_property PACKAGE_PIN E39 [ get_ports "m2_ddr4_c[1]" ] # Dimm 3 Active Low Chip Select 3
#set_property PACKAGE_PIN A33 [ get_ports "m2_ddr4_c[2]" ] # Dimm 3 Die Select
#set_property PACKAGE_PIN K34 [ get_ports "m2_ddr4_c[3]" ] # Dimm 3 RFU
#set_property PACKAGE_PIN E26 [ get_ports "m2_ddr4_c[4]" ] # Dimm 3 RFU
#set_property PACKAGE_PIN D39 [ get_ports "m2_ddr4_cs_n[0]" ]# Dimm 3 Active Low Chip Select 0
#set_property PACKAGE_PIN B40 [ get_ports "m2_ddr4_cs_n[1]" ] # Dimm 3 Active Low Chip Select 1
#set_property PACKAGE_PIN A40 [ get_ports "m2_ddr4_cke[0]" ] # Dimm 3 Clock Enable 0
#set_property PACKAGE_PIN B39 [ get_ports "m2_ddr4_cke[1]" ] # Dimm 3 Clock Enable 1
#set_property PACKAGE_PIN A39 [ get_ports "m2_ddr4_odt[0]" ] # Dimm 3 On Die Termination 0
#set_property PACKAGE_PIN C38 [ get_ports "m2_ddr4_odt[1]" ] # Dimm 3 On Die Termination 1
#set_property PACKAGE_PIN C39 [ get_ports "m2_ddr4_parity" ] # Dimm 3 Parity
#set_property PACKAGE_PIN F38 [ get_ports "m2_ddr4_act_n" ] # Dimm 3 Activation Command Low
#set_property PACKAGE_PIN C36 [ get_ports "m2_ddr4_ba[0]" ] # Dimm 3 Bank Address 0
#set_property PACKAGE_PIN C37 [ get_ports "m2_ddr4_ba[1]" ] # Dimm 3 Bank Address 1
#set_property PACKAGE_PIN E36 [ get_ports "m2_ddr4_bg[0]" ] # Dimm 3 Bank Group 0
#set_property PACKAGE_PIN D36 [ get_ports "m2_ddr4_bg[1]" ] # Dimm 3 Bank Group 1
#set_property PACKAGE_PIN B36 [ get_ports "m2_ddr4_ck_t" ] # Dimm 3 Clock
#set_property PACKAGE_PIN B37 [ get_ports "m2_ddr4_ck_c" ] # Dimm 3 Clock
#set_property PACKAGE_PIN A37 [ get_ports "m2_ddr4_adr[0]" ] # Dimm 3 Address 0
#set_property PACKAGE_PIN A38 [ get_ports "m2_ddr4_adr[1]" ] # Dimm 3 Address 1
#set_property PACKAGE_PIN B35 [ get_ports "m2_ddr4_adr[2]" ] # Dimm 3 Address 2
#set_property PACKAGE_PIN A35 [ get_ports "m2_ddr4_adr[3]" ] # Dimm 3 Address 3
#set_property PACKAGE_PIN E35 [ get_ports "m2_ddr4_adr[4]" ] # Dimm 3 Address 4
#set_property PACKAGE_PIN D35 [ get_ports "m2_ddr4_adr[5]" ] # Dimm 3 Address 5
#set_property PACKAGE_PIN E37 [ get_ports "m2_ddr4_adr[6]" ] # Dimm 3 Address 6
#set_property PACKAGE_PIN B34 [ get_ports "m2_ddr4_adr[7]" ] # Dimm 3 Address 7
#set_property PACKAGE_PIN A34 [ get_ports "m2_ddr4_adr[8]" ] # Dimm 3 Address 8
#set_property PACKAGE_PIN D34 [ get_ports "m2_ddr4_adr[9]" ] # Dimm 3 Address 9
#set_property PACKAGE_PIN C34 [ get_ports "m2_ddr4_adr[10]" ] # Dimm 3 Address 10
#set_property PACKAGE_PIN D33 [ get_ports "m2_ddr4_adr[11]" ] # Dimm 3 Address 11
#set_property PACKAGE_PIN C33 [ get_ports "m2_ddr4_adr[12]" ] # Dimm 3 Address 12
#set_property PACKAGE_PIN C32 [ get_ports "m2_ddr4_adr[13]" ] # Dimm 3 Address 13
#set_property PACKAGE_PIN B32 [ get_ports "m2_ddr4_adr[14]" ] # Dimm 3 Address 14
#set_property PACKAGE_PIN D31 [ get_ports "m2_ddr4_adr[15]" ] # Dimm 3 Address 15
#set_property PACKAGE_PIN C31 [ get_ports "m2_ddr4_adr[16]" ] # Dimm 3 Address 16
#set_property PACKAGE_PIN B31 [ get_ports "m2_ddr4_adr[17]" ] # Dimm 3 Address 17

#### RDIMM 4
#set_property PACKAGE_PIN N17 [ get_ports "m3_ddr4_dqs_t[17]" ] # Dimm 4 Data Strobe 17
#set_property PACKAGE_PIN M17 [ get_ports "m3_ddr4_dqs_c[17]" ] # Dimm 4 Data Strobe 17
#set_property PACKAGE_PIN P18 [ get_ports "m3_ddr4_dq[71]" ] # Dimm 4 Data Pin 71
#set_property PACKAGE_PIN N18 [ get_ports "m3_ddr4_dq[70]" ] # Dimm 4 Data Pin 70
#set_property PACKAGE_PIN M20 [ get_ports "m3_ddr4_dq[69]" ] # Dimm 4 Data Pin 69
#set_property PACKAGE_PIN M19 [ get_ports "m3_ddr4_dq[68]" ] # Dimm 4 Data Pin 68
#set_property PACKAGE_PIN P19 [ get_ports "m3_ddr4_dqs_t[16]" ] # Dimm 4 Data Strobe 16
#set_property PACKAGE_PIN N19 [ get_ports "m3_ddr4_dqs_c[16]" ] # Dimm 4 Data Strobe 16
#set_property PACKAGE_PIN R20 [ get_ports "m3_ddr4_dq[67]" ] # Dimm 4 Data Pin 67
#set_property PACKAGE_PIN P20 [ get_ports "m3_ddr4_dq[66]" ] # Dimm 4 Data Pin 66
#set_property PACKAGE_PIN N21 [ get_ports "m3_ddr4_dq[65]" ] # Dimm 4 Data Pin 65
#set_property PACKAGE_PIN M21 [ get_ports "m3_ddr4_dq[64]" ] # Dimm 4 Data Pin 64
#set_property PACKAGE_PIN P13 [ get_ports "m3_ddr4_dqs_t[15]" ] # Dimm 4 Data Strobe 15
#set_property PACKAGE_PIN N13 [ get_ports "m3_ddr4_dqs_c[15]" ] # Dimm 4 Data Strobe 15
#set_property PACKAGE_PIN P14 [ get_ports "m3_ddr4_dq[63]" ] # Dimm 4 Data Pin 63
#set_property PACKAGE_PIN N14 [ get_ports "m3_ddr4_dq[62]" ] # Dimm 4 Data Pin 62
#set_property PACKAGE_PIN R15 [ get_ports "m3_ddr4_dq[61]" ] # Dimm 4 Data Pin 61
#set_property PACKAGE_PIN P15 [ get_ports "m3_ddr4_dq[60]" ] # Dimm 4 Data Pin 60
#set_property PACKAGE_PIN R16 [ get_ports "m3_ddr4_dqs_t[14]" ] # Dimm 4 Data Strobe 14
#set_property PACKAGE_PIN P16 [ get_ports "m3_ddr4_dqs_c[14]" ] # Dimm 4 Data Strobe 14
#set_property PACKAGE_PIN M14 [ get_ports "m3_ddr4_dq[59]" ] # Dimm 4 Data Pin 59
#set_property PACKAGE_PIN L14 [ get_ports "m3_ddr4_dq[58]" ] # Dimm 4 Data Pin 58
#set_property PACKAGE_PIN N16 [ get_ports "m3_ddr4_dq[57]" ] # Dimm 4 Data Pin 57
#set_property PACKAGE_PIN M16 [ get_ports "m3_ddr4_dq[56]" ] # Dimm 4 Data Pin 56
#set_property PACKAGE_PIN L13 [ get_ports "m3_ddr4_dqs_t[13]" ] # Dimm 4 Data Strobe 13
#set_property PACKAGE_PIN K13 [ get_ports "m3_ddr4_dqs_c[13]" ] # Dimm 4 Data Strobe 13
#set_property PACKAGE_PIN K16 [ get_ports "m3_ddr4_dq[55]" ] # Dimm 4 Data Pin 55
#set_property PACKAGE_PIN K15 [ get_ports "m3_ddr4_dq[54]" ] # Dimm 4 Data Pin 54
#set_property PACKAGE_PIN J13 [ get_ports "m3_ddr4_dq[53]" ] # Dimm 4 Data Pin 53
#set_property PACKAGE_PIN H13 [ get_ports "m3_ddr4_dq[52]" ] # Dimm 4 Data Pin 52
#set_property PACKAGE_PIN H17 [ get_ports "m3_ddr4_dqs_t[12]" ] # Dimm 4 Data Strobe 12
#set_property PACKAGE_PIN H16 [ get_ports "m3_ddr4_dqs_c[12]" ] # Dimm 4 Data Strobe 12
#set_property PACKAGE_PIN J14 [ get_ports "m3_ddr4_dq[51]" ] # Dimm 4 Data Pin 51
#set_property PACKAGE_PIN H14 [ get_ports "m3_ddr4_dq[50]" ] # Dimm 4 Data Pin 50
#set_property PACKAGE_PIN J16 [ get_ports "m3_ddr4_dq[49]" ] # Dimm 4 Data Pin 49
#set_property PACKAGE_PIN J15 [ get_ports "m3_ddr4_dq[48]" ] # Dimm 4 Data Pin 48
#set_property PACKAGE_PIN G14 [ get_ports "m3_ddr4_dqs_t[11]" ] # Dimm 4 Data Strobe 11
#set_property PACKAGE_PIN F14 [ get_ports "m3_ddr4_dqs_c[11]" ] # Dimm 4 Data Strobe 11
#set_property PACKAGE_PIN G15 [ get_ports "m3_ddr4_dq[47]" ] # Dimm 4 Data Pin 47
#set_property PACKAGE_PIN F15 [ get_ports "m3_ddr4_dq[46]" ] # Dimm 4 Data Pin 46
#set_property PACKAGE_PIN F13 [ get_ports "m3_ddr4_dq[45]" ] # Dimm 4 Data Pin 45
#set_property PACKAGE_PIN E13 [ get_ports "m3_ddr4_dq[44]" ] # Dimm 4 Data Pin 44
#set_property PACKAGE_PIN G17 [ get_ports "m3_ddr4_dqs_t[10]" ] # Dimm 4 Data Strobe 10
#set_property PACKAGE_PIN G16 [ get_ports "m3_ddr4_dqs_c[10]" ] # Dimm 4 Data Strobe 10
#set_property PACKAGE_PIN E15 [ get_ports "m3_ddr4_dq[43]" ] # Dimm 4 Data Pin 43
#set_property PACKAGE_PIN D15 [ get_ports "m3_ddr4_dq[42]" ] # Dimm 4 Data Pin 42
#set_property PACKAGE_PIN E16 [ get_ports "m3_ddr4_dq[41]" ] # Dimm 4 Data Pin 41
#set_property PACKAGE_PIN D16 [ get_ports "m3_ddr4_dq[40]" ] # Dimm 4 Data Pin 40
#set_property PACKAGE_PIN D13 [ get_ports "m3_ddr4_dqs_t[9]" ] # Dimm 4 Data Strobe 9
#set_property PACKAGE_PIN C13 [ get_ports "m3_ddr4_dqs_c[9]" ] # Dimm 4 Data Strobe 9
#set_property PACKAGE_PIN C14 [ get_ports "m3_ddr4_dq[39]" ] # Dimm 4 Data Pin 39
#set_property PACKAGE_PIN B14 [ get_ports "m3_ddr4_dq[38]" ] # Dimm 4 Data Pin 38
#set_property PACKAGE_PIN A14 [ get_ports "m3_ddr4_dq[37]" ] # Dimm 4 Data Pin 37
#set_property PACKAGE_PIN A13 [ get_ports "m3_ddr4_dq[36]" ] # Dimm 4 Data Pin 36
#set_property PACKAGE_PIN B15 [ get_ports "m3_ddr4_dqs_t[8]" ] # Dimm 4 Data Strobe 8
#set_property PACKAGE_PIN A15 [ get_ports "m3_ddr4_dqs_c[8]" ] # Dimm 4 Data Strobe 8
#set_property PACKAGE_PIN C16 [ get_ports "m3_ddr4_dq[35]" ] # Dimm 4 Data Pin 35
#set_property PACKAGE_PIN B16 [ get_ports "m3_ddr4_dq[34]" ] # Dimm 4 Data Pin 34
#set_property PACKAGE_PIN B17 [ get_ports "m3_ddr4_dq[33]" ] # Dimm 4 Data Pin 33
#set_property PACKAGE_PIN A17 [ get_ports "m3_ddr4_dq[32]" ] # Dimm 4 Data Pin 32
#set_property PACKAGE_PIN R21 [ get_ports "m3_ddr4_dqs_t[7]" ] # Dimm 4 Data Strobe 7
#set_property PACKAGE_PIN P21 [ get_ports "m3_ddr4_dqs_c[7]" ] # Dimm 4 Data Strobe 7
#set_property PACKAGE_PIN N22 [ get_ports "m3_ddr4_dq[31]" ] # Dimm 4 Data Pin 31
#set_property PACKAGE_PIN M22 [ get_ports "m3_ddr4_dq[30]" ] # Dimm 4 Data Pin 30
#set_property PACKAGE_PIN P23 [ get_ports "m3_ddr4_dq[29]" ] # Dimm 4 Data Pin 29
#set_property PACKAGE_PIN N23 [ get_ports "m3_ddr4_dq[28]" ] # Dimm 4 Data Pin 28
#set_property PACKAGE_PIN P24 [ get_ports "m3_ddr4_dqs_t[6]" ] # Dimm 4 Data Strobe 6
#set_property PACKAGE_PIN N24 [ get_ports "m3_ddr4_dqs_c[6]" ] # Dimm 4 Data Strobe 6
#set_property PACKAGE_PIN M25 [ get_ports "m3_ddr4_dq[27]" ] # Dimm 4 Data Pin 27
#set_property PACKAGE_PIN M24 [ get_ports "m3_ddr4_dq[26]" ] # Dimm 4 Data Pin 26
#set_property PACKAGE_PIN R25 [ get_ports "m3_ddr4_dq[25]" ] # Dimm 4 Data Pin 25
#set_property PACKAGE_PIN P25 [ get_ports "m3_ddr4_dq[24]" ] # Dimm 4 Data Pin 24
#set_property PACKAGE_PIN L25 [ get_ports "m3_ddr4_dqs_t[5]" ] # Dimm 4 Data Strobe 6
#set_property PACKAGE_PIN L24 [ get_ports "m3_ddr4_dqs_c[5]" ] # Dimm 4 Data Strobe 6
#set_property PACKAGE_PIN L22 [ get_ports "m3_ddr4_dq[23]" ] # Dimm 4 Data Pin 23
#set_property PACKAGE_PIN K22 [ get_ports "m3_ddr4_dq[22]" ] # Dimm 4 Data Pin 22
#set_property PACKAGE_PIN L23 [ get_ports "m3_ddr4_dq[21]" ] # Dimm 4 Data Pin 21
#set_property PACKAGE_PIN K23 [ get_ports "m3_ddr4_dq[20]" ] # Dimm 4 Data Pin 20
#set_property PACKAGE_PIN K25 [ get_ports "m3_ddr4_dqs_t[4]" ] # Dimm 4 Data Strobe 4
#set_property PACKAGE_PIN J25 [ get_ports "m3_ddr4_dqs_c[4]" ] # Dimm 4 Data Strobe 4
#set_property PACKAGE_PIN J23 [ get_ports "m3_ddr4_dq[19]" ] # Dimm 4 Data Pin 19
#set_property PACKAGE_PIN H23 [ get_ports "m3_ddr4_dq[18]" ] # Dimm 4 Data Pin 18
#set_property PACKAGE_PIN J24 [ get_ports "m3_ddr4_dq[17]" ] # Dimm 4 Data Pin 17
#set_property PACKAGE_PIN H24 [ get_ports "m3_ddr4_dq[16]" ] # Dimm 4 Data Pin 16
#set_property PACKAGE_PIN G25 [ get_ports "m3_ddr4_dqs_t[3]" ] # Dimm 4 Data Strobe 3
#set_property PACKAGE_PIN G24 [ get_ports "m3_ddr4_dqs_c[3]" ] # Dimm 4 Data Strobe 3
#set_property PACKAGE_PIN F24 [ get_ports "m3_ddr4_dq[15]" ] # Dimm 4 Data Pin 15
#set_property PACKAGE_PIN F23 [ get_ports "m3_ddr4_dq[14]" ] # Dimm 4 Data Pin 14
#set_property PACKAGE_PIN G22 [ get_ports "m3_ddr4_dq[13]" ] # Dimm 4 Data Pin 13
#set_property PACKAGE_PIN F22 [ get_ports "m3_ddr4_dq[12]" ] # Dimm 4 Data Pin 12
#set_property PACKAGE_PIN E23 [ get_ports "m3_ddr4_dqs_t[2]" ] # Dimm 4 Data Strobe 2
#set_property PACKAGE_PIN E22 [ get_ports "m3_ddr4_dqs_c[2]" ] # Dimm 4 Data Strobe 2
#set_property PACKAGE_PIN D24 [ get_ports "m3_ddr4_dq[11]" ] # Dimm 4 Data Pin 11
#set_property PACKAGE_PIN D23 [ get_ports "m3_ddr4_dq[10]" ] # Dimm 4 Data Pin 10
#set_property PACKAGE_PIN E25 [ get_ports "m3_ddr4_dq[9]" ] # Dimm 4 Data Pin 9
#set_property PACKAGE_PIN D25 [ get_ports "m3_ddr4_dq[8]" ] # Dimm 4 Data Pin 8
#set_property PACKAGE_PIN C22 [ get_ports "m3_ddr4_dqs_t[1]" ] # Dimm 4 Data Strobe 1
#set_property PACKAGE_PIN B22 [ get_ports "m3_ddr4_dqs_c[1]" ] # Dimm 4 Data Strobe 1
#set_property PACKAGE_PIN C24 [ get_ports "m3_ddr4_dq[7]" ] # Dimm 4 Data Pin 7
#set_property PACKAGE_PIN C23 [ get_ports "m3_ddr4_dq[6]" ] # Dimm 4 Data Pin 6
#set_property PACKAGE_PIN C26 [ get_ports "m3_ddr4_dq[5]" ] # Dimm 4 Data Pin 5
#set_property PACKAGE_PIN B26 [ get_ports "m3_ddr4_dq[4]" ] # Dimm 4 Data Pin 4
#set_property PACKAGE_PIN A23 [ get_ports "m3_ddr4_dqs_t[0]" ] # Dimm 4 Data Strobe 0
#set_property PACKAGE_PIN A22 [ get_ports "m3_ddr4_dqs_c[0]" ] # Dimm 4 Data Strobe 0
#set_property PACKAGE_PIN B24 [ get_ports "m3_ddr4_dq[3]" ] # Dimm 4 Data Pin 3
#set_property PACKAGE_PIN A24 [ get_ports "m3_ddr4_dq[2]" ] # Dimm 4 Data Pin 2
#set_property PACKAGE_PIN B25 [ get_ports "m3_ddr4_dq[1]" ] # Dimm 4 Data Pin 1
#set_property PACKAGE_PIN A25 [ get_ports "m3_ddr4_dq[0]" ] # Dimm 4 Data Pin 0
#set_property PACKAGE_PIN L17 [ get_ports "m3_ddr4_reset_n" ] # Dimm 4 Active Low Reset
#set_property PACKAGE_PIN K17 [ get_ports "m3_ddr4_c[0]" ] # Dimm 4 Active Low Chip Select 2
#set_property PACKAGE_PIN L19 [ get_ports "m3_ddr4_c[1]" ] # Dimm 4 Active Low Chip Select 3
#set_property PACKAGE_PIN C18 [ get_ports "m3_ddr4_c[2]" ] # Dimm 4 Die Select
#set_property PACKAGE_PIN F25 [ get_ports "m3_ddr4_c[3]" ] # Dimm 4 RFU
#set_property PACKAGE_PIN D14 [ get_ports "m3_ddr4_c[4]" ] # Dimm 4 RFU
#set_property PACKAGE_PIN L18 [ get_ports "m3_ddr4_cs_n[0]" ] # Dimm 4 Active Low Chip Select 0
#set_property PACKAGE_PIN L20 [ get_ports "m3_ddr4_cs_n[1]" ] # Dimm 4 Active Low Chip Select 1
#set_property PACKAGE_PIN K20 [ get_ports "m3_ddr4_cke[0]" ] # Dimm 4 Clock Enable 0
#set_property PACKAGE_PIN J21 [ get_ports "m3_ddr4_cke[1]" ] # Dimm 4 Clock Enable 1
#set_property PACKAGE_PIN H21 [ get_ports "m3_ddr4_odt[0]" ] # Dimm 4 On Die Termination 0
#set_property PACKAGE_PIN J20 [ get_ports "m3_ddr4_odt[1]" ] # Dimm 4 On Die Termination 1
#set_property PACKAGE_PIN J19 [ get_ports "m3_ddr4_parity" ] # Dimm 4 Parity
#set_property PACKAGE_PIN K21 [ get_ports "m3_ddr4_act_n" ] # Dimm 4 Activation Command Low
#set_property PACKAGE_PIN H19 [ get_ports "m3_ddr4_ba[0]" ] # Dimm 4 Bank Address 0
#set_property PACKAGE_PIN H18 [ get_ports "m3_ddr4_ba[1]" ] # Dimm 4 Bank Address 1
#set_property PACKAGE_PIN G20 [ get_ports "m3_ddr4_bg[0]" ] # Dimm 4 Bank Group 0
#set_property PACKAGE_PIN G19 [ get_ports "m3_ddr4_bg[1]" ] # Dimm 4 Bank Group 1
#set_property PACKAGE_PIN E18 [ get_ports "m3_ddr4_ck_t" ] # Dimm 4 Clock
#set_property PACKAGE_PIN E17 [ get_ports "m3_ddr4_ck_c" ] # Dimm 4 Clock
#set_property PACKAGE_PIN F20 [ get_ports "m3_ddr4_adr[0]" ] # Dimm 4 Address 0
#set_property PACKAGE_PIN F19 [ get_ports "m3_ddr4_adr[1]" ] # Dimm 4 Address 1
#set_property PACKAGE_PIN E21 [ get_ports "m3_ddr4_adr[2]" ] # Dimm 4 Address 2
#set_property PACKAGE_PIN E20 [ get_ports "m3_ddr4_adr[3]" ] # Dimm 4 Address 3
#set_property PACKAGE_PIN F18 [ get_ports "m3_ddr4_adr[4]" ] # Dimm 4 Address 4
#set_property PACKAGE_PIN F17 [ get_ports "m3_ddr4_adr[5]" ] # Dimm 4 Address 5
#set_property PACKAGE_PIN G21 [ get_ports "m3_ddr4_adr[6]" ] # Dimm 4 Address 6
#set_property PACKAGE_PIN D19 [ get_ports "m3_ddr4_adr[7]" ] # Dimm 4 Address 7
#set_property PACKAGE_PIN C19 [ get_ports "m3_ddr4_adr[8]" ] # Dimm 4 Address 8
#set_property PACKAGE_PIN D21 [ get_ports "m3_ddr4_adr[9]" ] # Dimm 4 Address 9
#set_property PACKAGE_PIN D20 [ get_ports "m3_ddr4_adr[10]" ] # Dimm 4 Address 10
#set_property PACKAGE_PIN C21 [ get_ports "m3_ddr4_adr[11]" ] # Dimm 4 Address 11
#set_property PACKAGE_PIN B21 [ get_ports "m3_ddr4_adr[12]" ] # Dimm 4 Address 12
#set_property PACKAGE_PIN B19 [ get_ports "m3_ddr4_adr[13]" ] # Dimm 4 Address 13
#set_property PACKAGE_PIN A19 [ get_ports "m3_ddr4_adr[14]" ] # Dimm 4 Address 14
#set_property PACKAGE_PIN B20 [ get_ports "m3_ddr4_adr[15]" ] # Dimm 4 Address 15
#set_property PACKAGE_PIN A20 [ get_ports "m3_ddr4_adr[16]" ] # Dimm 4 Address 16
#set_property PACKAGE_PIN A18 [ get_ports "m3_ddr4_adr[17]" ] # Dimm 4 Address 17

###############################################
########### GTH/SEP Reference Clocks ##########
###############################################
#set_property PACKAGE_PIN AM11 [get_ports sep_gty_refclk0p_i[0]] # GTH Bank 226 Refclk 0 / Prog Clk B1 1
#set_property PACKAGE_PIN AM10 [get_ports sep_gty_refclk0n_i[0]]
#create_clock -name gtrefclk0_17 -period 3.1 [get_ports sep_gty_refclk0p_i[0]]

##set_property PACKAGE_PIN AK11 [get_ports sep_gty_refclk1p_i[0]] # GTH Bank 226 Refclk 1 Unconnected
##set_property PACKAGE_PIN AK10 [get_ports sep_gty_refclk1n_i[0]]
##create_clock -name gtrefclk1_17 -period 3.1 [get_ports sep_gty_refclk1p_i[0]]

#set_property PACKAGE_PIN AD11 [get_ports sep_gty_refclk0p_i[5]] # GTH Bank 228 Refclk 0
#set_property PACKAGE_PIN AD10 [get_ports sep_gty_refclk0n_i[5]]
#create_clock -name gtrefclk0_17 -period 3.1 [get_ports sep_gty_refclk0p_i[5]]

##set_property PACKAGE_PIN AB11 [get_ports sep_gty_refclk1p_i[5]] # GTH Bank 228 Refclk 1 Unconnected
##set_property PACKAGE_PIN AB10 [get_ports sep_gty_refclk1n_i[5]]
##create_clock -name gtrefclk1_17 -period 3.1 [get_ports sep_gty_refclk1p_i[5]]

#set_property PACKAGE_PIN Y11 [get_ports sep_gty_refclk0p_i[1]] # GTH Bank 229 Refclk 0
#set_property PACKAGE_PIN Y10 [get_ports sep_gty_refclk0n_i[1]]
#create_clock -name gtrefclk0_20 -period 3.1 [get_ports sep_gty_refclk0p_i[1]]

# GTH Bank 229 Refclk 1/PCIE RefClk 2
set_property PACKAGE_PIN V11 [get_ports sys_clk_p[1]] 
set_property PACKAGE_PIN V10 [get_ports sys_clk_n[1]]
#create_clock -name gtrefclk1_20 -period 3.1 [get_ports sep_gty_refclk1p_i[1]]

#set_property PACKAGE_PIN T11 [get_ports sep_gty_refclk0p_i[2]] # GTH Bank 230 Refclk 0
#set_property PACKAGE_PIN T10 [get_ports sep_gty_refclk0n_i[2]]
#create_clock -name gtrefclk0_21 -period 3.1 [get_ports sep_gty_refclk0p_i[2]]

#set_property PACKAGE_PIN P11 [get_ports sep_gty_refclk1p_i[2]] # GTH Bank 230 Refclk 1 / Prog Clk B2 1
#set_property PACKAGE_PIN P10 [get_ports sep_gty_refclk1n_i[2]]
#create_clock -name gtrefclk1_21 -period 3.1 [get_ports sep_gty_refclk1p_i[2]]

#set_property PACKAGE_PIN M11 [get_ports sep_gty_refclk0p_i[3]] # GTH Bank 231 Refclk 0
#set_property PACKAGE_PIN M10 [get_ports sep_gty_refclk0n_i[3]]
#create_clock -name gtrefclk0_22 -period 3.1 [get_ports sep_gty_refclk0p_i[3]]

# GTH Bank 231 Refclk 1/PCIe RefClk 3
#set_property PACKAGE_PIN K11 [get_ports sys_clk_p[1]] 
#set_property PACKAGE_PIN K10 [get_ports sys_clk_n[1]]
#create_clock -name gtrefclk1_22 -period 3.1 [get_ports sep_gty_refclk1p_i[3]]

#set_property PACKAGE_PIN H11 [get_ports sep_gty_refclk0p_i[4]] # GTH Bank 232 Refclk 0
#set_property PACKAGE_PIN H10 [get_ports sep_gty_refclk0n_i[4]]
#create_clock -name gtrefclk0_23 -period 3.1 [get_ports sep_gty_refclk0p_i[4]]

##set_property PACKAGE_PIN F11 [get_ports sep_gty_refclk1p_i[4]] # GTH Bank 232 Refclk 1 Unconnected
##set_property PACKAGE_PIN F10 [get_ports sep_gty_refclk1n_i[4]]
##create_clock -name gtrefclk1_23 -period 3.1 [get_ports sep_gty_refclk1p_i[4]]

###############################################
########### GTY/SEP Connector Pins   ##########
###############################################
## NOTE: All GTY pins are automatically assigned by Vivado. Shown here for reference only.

##GTH BANK 228 SEP 3:0
#set_property PACKAGE_PIN AE4  [get_ports pcie_rxp[16]] 
#set_property PACKAGE_PIN AE3  [get_ports pcie_rxn[16]] 
#set_property PACKAGE_PIN AD2  [get_ports pcie_rxp[17]] 
#set_property PACKAGE_PIN AD1  [get_ports pcie_rxn[17]] 
#set_property PACKAGE_PIN AC4  [get_ports pcie_rxp[18]] 
#set_property PACKAGE_PIN AC3  [get_ports pcie_rxn[18]] 
#set_property PACKAGE_PIN AB2  [get_ports pcie_rxp[19]] 
#set_property PACKAGE_PIN AB1  [get_ports pcie_rxn[19]] 
#set_property PACKAGE_PIN AE9  [get_ports pcie_txp[16]] 
#set_property PACKAGE_PIN AE8  [get_ports pcie_txn[16]] 
#set_property PACKAGE_PIN AD7  [get_ports pcie_txp[17]] 
#set_property PACKAGE_PIN AD6  [get_ports pcie_txn[17]] 
#set_property PACKAGE_PIN AC7  [get_ports pcie_txp[18]] 
#set_property PACKAGE_PIN AC8  [get_ports pcie_txn[18]] 
#set_property PACKAGE_PIN AB7  [get_ports pcie_txp[19]] 
#set_property PACKAGE_PIN AB6  [get_ports pcie_txn[19]] 

##GTH BANK 229 SEP 7:4
set_property PACKAGE_PIN AA4  [get_ports pcie_rxp[16]]
set_property PACKAGE_PIN AA3  [get_ports pcie_rxn[16]]
set_property PACKAGE_PIN Y2   [get_ports pcie_rxp[17]]
set_property PACKAGE_PIN Y1   [get_ports pcie_rxn[17]]
set_property PACKAGE_PIN W4   [get_ports pcie_rxp[18]]
set_property PACKAGE_PIN W3   [get_ports pcie_rxn[18]]
set_property PACKAGE_PIN V2   [get_ports pcie_rxp[19]]
set_property PACKAGE_PIN V1   [get_ports pcie_rxn[19]]
set_property PACKAGE_PIN AA9  [get_ports pcie_txp[16]]
set_property PACKAGE_PIN AA8  [get_ports pcie_txn[16]]
set_property PACKAGE_PIN Y7   [get_ports pcie_txp[17]]
set_property PACKAGE_PIN Y6   [get_ports pcie_txn[17]]
set_property PACKAGE_PIN W9   [get_ports pcie_txp[18]]
set_property PACKAGE_PIN W8   [get_ports pcie_txn[18]]
set_property PACKAGE_PIN V7   [get_ports pcie_txp[19]]
set_property PACKAGE_PIN V6   [get_ports pcie_txn[19]]

##GTH BANK 230 SEP 11:8
set_property PACKAGE_PIN U4   [get_ports pcie_rxp[20]]  
set_property PACKAGE_PIN U3   [get_ports pcie_rxn[20]]  
set_property PACKAGE_PIN T2   [get_ports pcie_rxp[21]]  
set_property PACKAGE_PIN T1   [get_ports pcie_rxn[21]]  
set_property PACKAGE_PIN R4   [get_ports pcie_rxp[22]] 
set_property PACKAGE_PIN R3   [get_ports pcie_rxn[22]] 
set_property PACKAGE_PIN P2   [get_ports pcie_rxp[23]] 
set_property PACKAGE_PIN P1   [get_ports pcie_rxn[23]] 
set_property PACKAGE_PIN U9   [get_ports pcie_txp[20]]  
set_property PACKAGE_PIN U8   [get_ports pcie_txn[20]]  
set_property PACKAGE_PIN T7   [get_ports pcie_txp[21]]  
set_property PACKAGE_PIN T6   [get_ports pcie_txn[21]]  
set_property PACKAGE_PIN R9   [get_ports pcie_txp[22]] 
set_property PACKAGE_PIN R8   [get_ports pcie_txn[22]] 
set_property PACKAGE_PIN P7   [get_ports pcie_txp[23]] 
set_property PACKAGE_PIN P6   [get_ports pcie_txn[23]] 

##GTH BANK 231 SEP 15:12
set_property PACKAGE_PIN N4   [get_ports pcie_rxp[24]] 
set_property PACKAGE_PIN N3   [get_ports pcie_rxn[24]] 
set_property PACKAGE_PIN M2   [get_ports pcie_rxp[25]] 
set_property PACKAGE_PIN M1   [get_ports pcie_rxn[25]] 
set_property PACKAGE_PIN L4   [get_ports pcie_rxp[26]] 
set_property PACKAGE_PIN L3   [get_ports pcie_rxn[26]] 
set_property PACKAGE_PIN K2   [get_ports pcie_rxp[27]] 
set_property PACKAGE_PIN K1   [get_ports pcie_rxn[27]] 
set_property PACKAGE_PIN N9   [get_ports pcie_txp[24]] 
set_property PACKAGE_PIN N8   [get_ports pcie_txn[24]] 
set_property PACKAGE_PIN M7   [get_ports pcie_txp[25]] 
set_property PACKAGE_PIN M6   [get_ports pcie_txn[25]] 
set_property PACKAGE_PIN L9   [get_ports pcie_txp[26]] 
set_property PACKAGE_PIN L8   [get_ports pcie_txn[26]] 
set_property PACKAGE_PIN K7   [get_ports pcie_txp[27]] 
set_property PACKAGE_PIN K6   [get_ports pcie_txn[27]] 

##GTH BANK 232 SEP 19:16
set_property PACKAGE_PIN J4   [get_ports pcie_rxp[28]]
set_property PACKAGE_PIN J3   [get_ports pcie_rxn[28]]
set_property PACKAGE_PIN H2   [get_ports pcie_rxp[29]]
set_property PACKAGE_PIN H1   [get_ports pcie_rxn[29]]
set_property PACKAGE_PIN G4   [get_ports pcie_rxp[30]]
set_property PACKAGE_PIN G3   [get_ports pcie_rxn[30]]
set_property PACKAGE_PIN F2   [get_ports pcie_rxp[31]]
set_property PACKAGE_PIN F1   [get_ports pcie_rxn[31]]
set_property PACKAGE_PIN J9   [get_ports pcie_txp[28]]
set_property PACKAGE_PIN J8   [get_ports pcie_txn[28]]
set_property PACKAGE_PIN H7   [get_ports pcie_txp[29]]
set_property PACKAGE_PIN H6   [get_ports pcie_txn[29]]
set_property PACKAGE_PIN G9   [get_ports pcie_txp[30]]
set_property PACKAGE_PIN G8   [get_ports pcie_txn[30]]
set_property PACKAGE_PIN F7   [get_ports pcie_txp[31]]
set_property PACKAGE_PIN F6   [get_ports pcie_txn[31]]

###############################################
########### GTY 25G Reference Clocks ##########
###############################################
## NOTE: Clock periods below assume a 322.265625 MHz clock, please adjust as necessary based on your application

#set_property PACKAGE_PIN BA40 [get_ports gty_refclk0p_i[0]] # GTY Bank 120 OSC 0
#set_property PACKAGE_PIN BA41 [get_ports gty_refclk0n_i[0]]
#create_clock -name gtrefclk0_1 -period 3.104 [get_ports gty_refclk0p_i[0]]
#create_clock -name gtrefclk1_1 -period 3.104 [get_ports gty_refclk1p_i[0]]

#set_property PACKAGE_PIN AY38 [get_ports gty_refclk1p_i[0]] # GTY Bank 120 Prog Clk B1 3
#set_property PACKAGE_PIN AY39 [get_ports gty_refclk1n_i[0]]

#set_property PACKAGE_PIN AR36 [get_ports gty_refclk0p_i[1]] # GTY Bank 122 OSC 1
#set_property PACKAGE_PIN AR37 [get_ports gty_refclk0n_i[1]]
#create_clock -name gtrefclk0_3 -period 3.104 [get_ports gty_refclk0p_i[1]]
#create_clock -name gtrefclk1_3 -period 3.104 [get_ports gty_refclk1p_i[1]]

#set_property PACKAGE_PIN AN36 [get_ports gty_refclk1p_i[1]] # GTY Bank 122 Prog Clk B1 0
#set_property PACKAGE_PIN AN37 [get_ports gty_refclk1n_i[1]]

#set_property PACKAGE_PIN AC36 [get_ports gty_refclk0p_i[2]] # GTY Bank 125 OSC 2
#set_property PACKAGE_PIN AC37 [get_ports gty_refclk0n_i[2]]
#create_clock -name gtrefclk0_6 -period 3.104 [get_ports gty_refclk0p_i[2]]
#create_clock -name gtrefclk1_6 -period 3.104 [get_ports gty_refclk1p_i[2]]

#set_property PACKAGE_PIN AA36 [get_ports gty_refclk1p_i[2]] # GTY Bank 125 Prog Clk B2 0
#set_property PACKAGE_PIN AA37 [get_ports gty_refclk1n_i[2]]

#set_property PACKAGE_PIN R36 [get_ports gty_refclk0p_i[3]] # GTY Bank 127 OSC 3
#set_property PACKAGE_PIN R37 [get_ports gty_refclk0n_i[3]]
#create_clock -name gtrefclk0_8 -period 3.104 [get_ports gty_refclk0p_i[3]]
#create_clock -name gtrefclk1_8 -period 3.104 [get_ports gty_refclk1p_i[3]]

#set_property PACKAGE_PIN N36 [get_ports gty_refclk1p_i[3]] # GTY Bank 127 Prog Clk B3
#set_property PACKAGE_PIN N37 [get_ports gty_refclk1n_i[3]]

###############################################
########### GTY 25G QSFP Pins        ##########
###############################################
## NOTE: All GTY pins are automatically assigned by Vivado. Shown here for reference only.

##GTY BANK 120 QSFP Port 0
##set_property PACKAGE_PIN BC45 [get_ports gty_rxp_i[0]] # QSFP1_RX_P_1
##set_property PACKAGE_PIN BC46 [get_ports gty_rxn_i[0]] # QSFP1_RX_N_1
##set_property PACKAGE_PIN BA45 [get_ports gty_rxp_i[1]] # QSFP1_RX_P_2
##set_property PACKAGE_PIN BA46 [get_ports gty_rxn_i[1]] # QSFP1_RX_N_2
##set_property PACKAGE_PIN AW45 [get_ports gty_rxp_i[2]] # QSFP1_RX_P_3
##set_property PACKAGE_PIN AW46 [get_ports gty_rxn_i[2]] # QSFP1_RX_N_3
##set_property PACKAGE_PIN AV43 [get_ports gty_rxp_i[3]] # QSFP1_RX_P_4
##set_property PACKAGE_PIN AV44 [get_ports gty_rxn_i[3]] # QSFP1_RX_P_4
##set_property PACKAGE_PIN BF42 [get_ports gty_txp_o[0]] # QSFP1_TX_P_1
##set_property PACKAGE_PIN BF43 [get_ports gty_txn_o[0]] # QSFP1_TX_N_1
##set_property PACKAGE_PIN BD42 [get_ports gty_txp_o[1]] # QSFP1_TX_P_2
##set_property PACKAGE_PIN BD43 [get_ports gty_txn_o[1]] # QSFP1_TX_N_2
##set_property PACKAGE_PIN BB42 [get_ports gty_txp_o[2]] # QSFP1_TX_P_3
##set_property PACKAGE_PIN BB43 [get_ports gty_txn_o[2]] # QSFP1_TX_N_2
##set_property PACKAGE_PIN AW40 [get_ports gty_txp_o[3]] # QSFP1_TX_P_3
##set_property PACKAGE_PIN AW41 [get_ports gty_txn_o[3]] # QSFP1_TX_N_3

##GTY BANK 122 QSFP Port 1
##set_property PACKAGE_PIN AN45 [get_ports gty_rxp_i[4]] # QSFP2_RX_P_1
##set_property PACKAGE_PIN AN46 [get_ports gty_rxn_i[4]] # QSFP2_RX_N_1
##set_property PACKAGE_PIN AM43 [get_ports gty_rxp_i[5]] # QSFP2_RX_P_2
##set_property PACKAGE_PIN AM44 [get_ports gty_rxn_i[5]] # QSFP2_RX_N_2
##set_property PACKAGE_PIN AL45 [get_ports gty_rxp_i[6]] # QSFP2_RX_P_3
##set_property PACKAGE_PIN AL46 [get_ports gty_rxn_i[6]] # QSFP2_RX_N_3
##set_property PACKAGE_PIN AK43 [get_ports gty_rxp_i[7]] # QSFP2_RX_P_4
##set_property PACKAGE_PIN AK44 [get_ports gty_rxn_i[7]] # QSFP2_RX_N_4
##set_property PACKAGE_PIN AN40 [get_ports gty_txp_o[4]] # QSFP2_TX_P_1
##set_property PACKAGE_PIN AN41 [get_ports gty_txn_o[4]] # QSFP2_TX_N_1
##set_property PACKAGE_PIN AM38 [get_ports gty_txp_o[5]] # QSFP2_TX_P_2
##set_property PACKAGE_PIN AM39 [get_ports gty_txn_o[5]] # QSFP2_TX_N_2
##set_property PACKAGE_PIN AL40 [get_ports gty_txp_o[6]] # QSFP2_TX_P_3
##set_property PACKAGE_PIN AL41 [get_ports gty_txn_o[6]] # QSFP2_TX_N_3
##set_property PACKAGE_PIN AK38 [get_ports gty_txp_o[7]] # QSFP2_TX_P_4
##set_property PACKAGE_PIN AK39 [get_ports gty_txn_o[7]] # QSFP2_TX_N_4

##GTY BANK 125 QSFP Port 2
##set_property PACKAGE_PIN AA45 [get_ports gty_rxp_i[8]]  # QSFP3_RX_P_1
##set_property PACKAGE_PIN AA46 [get_ports gty_rxn_i[8]]  # QSFP3_RX_N_1
##set_property PACKAGE_PIN Y43  [get_ports gty_rxp_i[9]]  # QSFP3_RX_P_2
##set_property PACKAGE_PIN Y44  [get_ports gty_rxn_i[9]]  # QSFP3_RX_N_2
##set_property PACKAGE_PIN W45  [get_ports gty_rxp_i[10]] # QSFP3_RX_P_3
##set_property PACKAGE_PIN W46  [get_ports gty_rxn_i[10]] # QSFP3_RX_N_3
##set_property PACKAGE_PIN V43  [get_ports gty_rxp_i[11]] # QSFP3_RX_P_4
##set_property PACKAGE_PIN V44  [get_ports gty_rxn_i[11]] # QSFP3_RX_N_4
##set_property PACKAGE_PIN AA40 [get_ports gty_txp_o[8]]  # QSFP3_TX_P_1
##set_property PACKAGE_PIN AA41 [get_ports gty_txn_o[8]]  # QSFP3_TX_N_1
##set_property PACKAGE_PIN Y38  [get_ports gty_txp_o[9]]  # QSFP3_TX_P_2
##set_property PACKAGE_PIN Y39  [get_ports gty_txn_o[9]]  # QSFP3_TX_N_2
##set_property PACKAGE_PIN W40  [get_ports gty_txp_o[10]] # QSFP3_TX_P_3
##set_property PACKAGE_PIN W41  [get_ports gty_txn_o[10]] # QSFP3_TX_N_3
##set_property PACKAGE_PIN V38  [get_ports gty_txp_o[11]] # QSFP3_TX_P_4
##set_property PACKAGE_PIN V38  [get_ports gty_txn_o[11]] # QSFP3_TX_N_4

##GTY BANK 127 QSFP Port 3
##set_property PACKAGE_PIN N45  [get_ports gty_rxp_i[12]] # QSFP4_RX_P_1
##set_property PACKAGE_PIN N46  [get_ports gty_rxn_i[12]] # QSFP4_RX_N_1
##set_property PACKAGE_PIN M43  [get_ports gty_rxp_i[13]] # QSFP4_RX_P_2
##set_property PACKAGE_PIN M44  [get_ports gty_rxn_i[13]] # QSFP4_RX_N_2
##set_property PACKAGE_PIN L45  [get_ports gty_rxp_i[14]] # QSFP4_RX_P_3
##set_property PACKAGE_PIN L46  [get_ports gty_rxn_i[14]] # QSFP4_RX_N_3
##set_property PACKAGE_PIN K43  [get_ports gty_rxp_i[15]] # QSFP4_RX_P_4
##set_property PACKAGE_PIN K44  [get_ports gty_rxn_i[15]] # QSFP4_RX_N_4
##set_property PACKAGE_PIN N40  [get_ports gty_txp_o[12]] # QSFP4_TX_P_1
##set_property PACKAGE_PIN N41  [get_ports gty_txn_o[12]] # QSFP4_TX_N_1
##set_property PACKAGE_PIN M38  [get_ports gty_txp_o[13]] # QSFP4_TX_P_2
##set_property PACKAGE_PIN M39  [get_ports gty_txn_o[13]] # QSFP4_TX_N_2
##set_property PACKAGE_PIN L40  [get_ports gty_txp_o[14]] # QSFP4_TX_P_3
##set_property PACKAGE_PIN L41  [get_ports gty_txn_o[14]] # QSFP4_TX_N_3
##set_property PACKAGE_PIN J40  [get_ports gty_txp_o[15]] # QSFP4_TX_P_4
##set_property PACKAGE_PIN J41  [get_ports gty_txn_o[15]] # QSFP4_TX_N_4

################################################
########### GTY SATA Reference Clocks ##########
################################################

#set_property PACKAGE_PIN AV38 [get_ports gty_sata_refclk0p_i[0]] # GTY Bank 121 Clk 0
#set_property PACKAGE_PIN AV39 [get_ports gty_sata_refclk0n_i[0]]
#create_clock -name gtrefclk0_2 -period 3.104 [get_ports gty_sata_refclk0p_i[0]]
#create_clock -name gtrefclk1_2 -period 3.104 [get_ports gty_sata_refclk1p_i[0]]

#set_property PACKAGE_PIN AU36 [get_ports gty_sata_refclk1p_i[0]] # GTY Bank 121 Clk 1
#set_property PACKAGE_PIN AU37 [get_ports gty_sata_refclk1n_i[0]]

###############################################
###########       GTY SATA Pins      ##########
###############################################
## NOTE: All GTY pins are automatically assigned by Vivado. Shown here for reference only.

##GTY BANK 121 SATA
##set_property PACKAGE_PIN AU45 [get_ports gty_rxp_i[0]] # SATA_RX_P_1
##set_property PACKAGE_PIN AU46 [get_ports gty_rxn_i[0]] # SATA_RX_N_1
##set_property PACKAGE_PIN AU40 [get_ports gty_rxp_i[1]] # SATA_TX_P_1
##set_property PACKAGE_PIN AU41 [get_ports gty_rxn_i[1]] # SATA_TX_N_1

