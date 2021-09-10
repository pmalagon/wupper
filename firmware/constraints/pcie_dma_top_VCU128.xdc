

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



###############################################
###########           LEDs           ##########
###############################################
# Active Low Led 0
set_property IOSTANDARD LVCMOS18 [get_ports {leds[0]}]
set_property PACKAGE_PIN BH24 [get_ports {leds[0]}]
# Active Low Led 1
set_property IOSTANDARD LVCMOS18 [get_ports {leds[1]}]
set_property PACKAGE_PIN BG24 [get_ports {leds[1]}]
# Active Low Led 2
set_property IOSTANDARD LVCMOS18 [get_ports {leds[2]}]
set_property PACKAGE_PIN BG25 [get_ports {leds[2]}]
# Active Low Led 3
set_property IOSTANDARD LVCMOS18 [get_ports {leds[3]}]
set_property PACKAGE_PIN BF25 [get_ports {leds[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {leds[4]}]
set_property PACKAGE_PIN BF26 [get_ports {leds[4]}]
# Active Low Led 1
set_property IOSTANDARD LVCMOS18 [get_ports {leds[5]}]
set_property PACKAGE_PIN BF27 [get_ports {leds[5]}]
# Active Low Led 2
set_property IOSTANDARD LVCMOS18 [get_ports {leds[6]}]
set_property PACKAGE_PIN BG27 [get_ports {leds[6]}]
# Active Low Led 3
set_property IOSTANDARD LVCMOS18 [get_ports {leds[7]}]
set_property PACKAGE_PIN BG28 [get_ports {leds[7]}]

##############################################
##########           PCIe           ##########
##############################################
#set_property PACKAGE_PIN AY23 [get_ports progclk_b1_p]
#set_property PACKAGE_PIN BA23 [get_ports progclk_b1_n]
#set_property IOSTANDARD DIFF_SSTL18_I [get_ports progclk_b1_p]
# PCIE Active Low Reset

set_property PACKAGE_PIN BF41 [get_ports sys_reset_n]
set_property IOSTANDARD LVCMOS12 [get_ports sys_reset_n]
set_property PULLUP true [get_ports sys_reset_n]
set_false_path -from [get_ports sys_reset_n]
# PCIE Reference Clock 0
 #MGTREFCLK0N_227
set_property PACKAGE_PIN AL14 [get_ports {sys_clk_n[0]}]
set_property PACKAGE_PIN AL15 [get_ports {sys_clk_p[0]}]

set_property PACKAGE_PIN AR14 [get_ports {sys_clk_n[1]}]
set_property PACKAGE_PIN AR15 [get_ports {sys_clk_p[1]}]

create_clock -period 10.000 -name sys_clk0 [get_ports {sys_clk_p[0]}]
create_clock -period 10.000 -name sys_clk1 [get_ports {sys_clk_p[1]}]

set_property PACKAGE_PIN AL11 [get_ports {pcie_txp[0]}]
set_property PACKAGE_PIN AL10 [get_ports {pcie_txn[0]}]
set_property PACKAGE_PIN AL2  [get_ports {pcie_rxp[0]}]
set_property PACKAGE_PIN AL1  [get_ports {pcie_rxn[0]}]

set_property PACKAGE_PIN AM9  [get_ports {pcie_txp[1]}]
set_property PACKAGE_PIN AM8  [get_ports {pcie_txn[1]}]
set_property PACKAGE_PIN AM4  [get_ports {pcie_rxp[1]}]
set_property PACKAGE_PIN AM3  [get_ports {pcie_rxn[1]}]

set_property PACKAGE_PIN AN11 [get_ports {pcie_txp[2]}]
set_property PACKAGE_PIN AN10 [get_ports {pcie_txn[2]}]
set_property PACKAGE_PIN AN6  [get_ports {pcie_rxp[2]}]
set_property PACKAGE_PIN AN5  [get_ports {pcie_rxn[2]}]

set_property PACKAGE_PIN AP9  [get_ports {pcie_txp[3]}]
set_property PACKAGE_PIN AP8  [get_ports {pcie_txn[3]}]
set_property PACKAGE_PIN AN2  [get_ports {pcie_rxp[3]}]
set_property PACKAGE_PIN AN1  [get_ports {pcie_rxn[3]}]

set_property PACKAGE_PIN AR11 [get_ports {pcie_txp[4]}]
set_property PACKAGE_PIN AR10 [get_ports {pcie_txn[4]}]
set_property PACKAGE_PIN AP4  [get_ports {pcie_rxp[4]}]
set_property PACKAGE_PIN AP3  [get_ports {pcie_rxn[4]}]

set_property PACKAGE_PIN AR7  [get_ports {pcie_txp[5]}]
set_property PACKAGE_PIN AR6  [get_ports {pcie_txn[5]}]
set_property PACKAGE_PIN AR2  [get_ports {pcie_rxp[5]}]
set_property PACKAGE_PIN AR1  [get_ports {pcie_rxn[5]}]

set_property PACKAGE_PIN AT9  [get_ports {pcie_txp[6]}]
set_property PACKAGE_PIN AT8  [get_ports {pcie_txn[6]}]
set_property PACKAGE_PIN AT4  [get_ports {pcie_rxp[6]}]
set_property PACKAGE_PIN AT3  [get_ports {pcie_rxn[6]}]

set_property PACKAGE_PIN AU11 [get_ports {pcie_txp[7]}]
set_property PACKAGE_PIN AU10 [get_ports {pcie_txn[7]}]
set_property PACKAGE_PIN AU2  [get_ports {pcie_rxp[7]}]
set_property PACKAGE_PIN AU1  [get_ports {pcie_rxn[7]}]

set_property PACKAGE_PIN AU7  [get_ports {pcie_txp[8]}]
set_property PACKAGE_PIN AU6  [get_ports {pcie_txn[8]}]
set_property PACKAGE_PIN AV4  [get_ports {pcie_rxp[8]}]
set_property PACKAGE_PIN AV3  [get_ports {pcie_rxn[8]}]

set_property PACKAGE_PIN AV9  [get_ports {pcie_txp[9]}]
set_property PACKAGE_PIN AV8  [get_ports {pcie_txn[9]}]
set_property PACKAGE_PIN AW6  [get_ports {pcie_rxp[9]}]
set_property PACKAGE_PIN AW5  [get_ports {pcie_rxn[9]}]

set_property PACKAGE_PIN AW11 [get_ports {pcie_txp[10]}]
set_property PACKAGE_PIN AW10 [get_ports {pcie_txn[10]}]
set_property PACKAGE_PIN AW2  [get_ports {pcie_rxp[10]}]
set_property PACKAGE_PIN AW1  [get_ports {pcie_rxn[10]}]

set_property PACKAGE_PIN AY9  [get_ports {pcie_txp[11]}]
set_property PACKAGE_PIN AY8  [get_ports {pcie_txn[11]}]
set_property PACKAGE_PIN AY4  [get_ports {pcie_rxp[11]}]
set_property PACKAGE_PIN AY3  [get_ports {pcie_rxn[11]}]

set_property PACKAGE_PIN BA11 [get_ports {pcie_txp[12]}]
set_property PACKAGE_PIN BA10 [get_ports {pcie_txn[12]}]
set_property PACKAGE_PIN BA6  [get_ports {pcie_rxp[12]}]
set_property PACKAGE_PIN BA5  [get_ports {pcie_rxn[12]}]

set_property PACKAGE_PIN BB9  [get_ports {pcie_txp[13]}]
set_property PACKAGE_PIN BB8  [get_ports {pcie_txn[13]}]
set_property PACKAGE_PIN BA2  [get_ports {pcie_rxp[13]}]
set_property PACKAGE_PIN BA1  [get_ports {pcie_rxn[13]}]

set_property PACKAGE_PIN BC11 [get_ports {pcie_txp[14]}]
set_property PACKAGE_PIN BC10 [get_ports {pcie_txn[14]}]
set_property PACKAGE_PIN BB4  [get_ports {pcie_rxp[14]}]
set_property PACKAGE_PIN BB3  [get_ports {pcie_rxn[14]}]

set_property PACKAGE_PIN BC7  [get_ports {pcie_txp[15]}]
set_property PACKAGE_PIN BC6  [get_ports {pcie_txn[15]}]
set_property PACKAGE_PIN BC2  [get_ports {pcie_rxp[15]}]
set_property PACKAGE_PIN BC1  [get_ports {pcie_rxn[15]}]


#PL_I2C0_SDA_LS
set_property PACKAGE_PIN BL28 [get_ports SDA]
set_property IOSTANDARD LVCMOS18 [get_ports SDA]
#PL_I2C0_SCL_LS
set_property PACKAGE_PIN BM27 [get_ports SCL]
set_property IOSTANDARD LVCMOS18 [get_ports SCL]

set_property PACKAGE_PIN A26 [get_ports {i2cmux_rst}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2cmux_rst}]


#ENET_CLKOUT
set_property PACKAGE_PIN BJ4 [get_ports emcclk]
set_property IOSTANDARD LVCMOS12 [get_ports emcclk]