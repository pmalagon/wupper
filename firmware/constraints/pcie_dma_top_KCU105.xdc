###############################################################################
# User Configuration
# Link Width   - x8
# Link Speed   - gen3
# Family       - kintex ultrascale
# Part         - xcku040-ffva1156-2-e
# Package      - ffva1156
# Speed grade  - -2
# PCIe Block   - X0Y1
###############################################################################
#
#########################################################################################################################
# User Constraints
#########################################################################################################################
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################

#! file TEST.XDC
#! net constraints for TEST design


set_property IOSTANDARD LVCMOS18 [get_ports emcclk]
#set_property IOSTANDARD LVCMOS18 [get_ports emcclk_out]


set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

#System Reset, User Reset, User Link Up, User Clk Heartbeat
# Changed for KCU105 board
set_property PACKAGE_PIN AP8 [get_ports {leds[0]}]
set_property PACKAGE_PIN H23 [get_ports {leds[1]}]
set_property PACKAGE_PIN P20 [get_ports {leds[2]}]
set_property PACKAGE_PIN P21 [get_ports {leds[3]}]
set_property PACKAGE_PIN N22 [get_ports {leds[4]}]
set_property PACKAGE_PIN M22 [get_ports {leds[5]}]
set_property PACKAGE_PIN R23 [get_ports {leds[6]}]
set_property PACKAGE_PIN P23 [get_ports {leds[7]}]
set_property PACKAGE_PIN K20 [get_ports emcclk]
# R25 not connected on KCU105.
#set_property PACKAGE_PIN R25 [get_ports emcclk_out]
set_property PACKAGE_PIN AB5 [get_ports sys_clk_n]
set_property PACKAGE_PIN AB6 [get_ports sys_clk_p]


set_property PACKAGE_PIN AC4 [get_ports {pcie_txp[0]}]
set_property PACKAGE_PIN AB2 [get_ports {pcie_rxp[0]}]
set_property PACKAGE_PIN AB1 [get_ports {pcie_rxn[0]}]
set_property PACKAGE_PIN AC3 [get_ports {pcie_txn[0]}]
set_property PACKAGE_PIN AE4 [get_ports {pcie_txp[1]}]
set_property PACKAGE_PIN AD2 [get_ports {pcie_rxp[1]}]
set_property PACKAGE_PIN AD1 [get_ports {pcie_rxn[1]}]
set_property PACKAGE_PIN AE3 [get_ports {pcie_txn[1]}]
set_property PACKAGE_PIN AG4 [get_ports {pcie_txp[2]}]
set_property PACKAGE_PIN AF2 [get_ports {pcie_rxp[2]}]
set_property PACKAGE_PIN AF1 [get_ports {pcie_rxn[2]}]
set_property PACKAGE_PIN AG3 [get_ports {pcie_txn[2]}]
set_property PACKAGE_PIN AH6 [get_ports {pcie_txp[3]}]
set_property PACKAGE_PIN AH2 [get_ports {pcie_rxp[3]}]
set_property PACKAGE_PIN AH1 [get_ports {pcie_rxn[3]}]
set_property PACKAGE_PIN AH5 [get_ports {pcie_txn[3]}]
set_property PACKAGE_PIN AK6 [get_ports {pcie_txp[4]}]
set_property PACKAGE_PIN AJ4 [get_ports {pcie_rxp[4]}]
set_property PACKAGE_PIN AJ3 [get_ports {pcie_rxn[4]}]
set_property PACKAGE_PIN AK5 [get_ports {pcie_txn[4]}]
set_property PACKAGE_PIN AL4 [get_ports {pcie_txp[5]}]
set_property PACKAGE_PIN AK2 [get_ports {pcie_rxp[5]}]
set_property PACKAGE_PIN AK1 [get_ports {pcie_rxn[5]}]
set_property PACKAGE_PIN AL3 [get_ports {pcie_txn[5]}]
set_property PACKAGE_PIN AM6 [get_ports {pcie_txp[6]}]
set_property PACKAGE_PIN AM2 [get_ports {pcie_rxp[6]}]
set_property PACKAGE_PIN AM1 [get_ports {pcie_rxn[6]}]
set_property PACKAGE_PIN AM5 [get_ports {pcie_txn[6]}]
set_property PACKAGE_PIN AN4 [get_ports {pcie_txp[7]}]
set_property PACKAGE_PIN AP2 [get_ports {pcie_rxp[7]}]
set_property PACKAGE_PIN AP1 [get_ports {pcie_rxn[7]}]
set_property PACKAGE_PIN AN3 [get_ports {pcie_txn[7]}]

#
set_property IOSTANDARD LVCMOS18 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[7]}]

#IIC
set_property PACKAGE_PIN J24 [get_ports "SCL"]
set_property IOSTANDARD LVCMOS18 [get_ports "SCL"]
set_property PACKAGE_PIN J25 [get_ports "SDA"]
set_property IOSTANDARD LVCMOS18 [get_ports "SDA"]
set_property PACKAGE_PIN AP10 [get_ports "i2cmux_rst"]
set_property IOSTANDARD LVCMOS18 [get_ports "i2cmux_rst"]

#########################################################################################################################
# End User Constraints
#########################################################################################################################
#
#
#
#########################################################################################################################
# PCIE Core Constraints
#########################################################################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#
# Changed for KCU105
# ultrascale has dedicated PCIE reset pin
set_property PACKAGE_PIN K22 [get_ports sys_reset_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_reset_n]
set_property PULLUP true [get_ports sys_reset_n]

#
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#
create_clock -period 10.000 -name sys_clk_p -waveform {0.000 5.000} [get_ports sys_clk_p]

###############################################################################
# Physical Constraints
###############################################################################

set_false_path -from [get_ports sys_reset_n]
###############################################################################
# End
###############################################################################











