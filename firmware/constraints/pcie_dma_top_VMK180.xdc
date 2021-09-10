#103     GTY_REFCLKN0_103
set_property  PACKAGE_PIN W40      [get_ports  {sys_clk_n[0]}]
set_property  PACKAGE_PIN W39      [get_ports  {sys_clk_p[0]}]
create_clock -name sys_clk0 -period 10.000 [get_ports {sys_clk_p[0]}]
 
#Bank 103 / 104
set_property  PACKAGE_PIN AB47     [get_ports  {pcie_rxn[0]}]    
set_property  PACKAGE_PIN AA45     [get_ports  {pcie_rxn[1]}]    
set_property  PACKAGE_PIN Y47      [get_ports  {pcie_rxn[2]}]    
set_property  PACKAGE_PIN W45      [get_ports  {pcie_rxn[3]}]    
set_property  PACKAGE_PIN V47      [get_ports  {pcie_rxn[4]}]    
set_property  PACKAGE_PIN T47      [get_ports  {pcie_rxn[5]}]    
set_property  PACKAGE_PIN P47      [get_ports  {pcie_rxn[6]}]    
set_property  PACKAGE_PIN N45      [get_ports  {pcie_rxn[7]}]    
set_property  PACKAGE_PIN AB46     [get_ports  {pcie_rxp[0]}]    
set_property  PACKAGE_PIN AA44     [get_ports  {pcie_rxp[1]}]    
set_property  PACKAGE_PIN Y46      [get_ports  {pcie_rxp[2]}]    
set_property  PACKAGE_PIN W44      [get_ports  {pcie_rxp[3]}]    
set_property  PACKAGE_PIN V46      [get_ports  {pcie_rxp[4]}]    
set_property  PACKAGE_PIN T46      [get_ports  {pcie_rxp[5]}]    
set_property  PACKAGE_PIN P46      [get_ports  {pcie_rxp[6]}]    
set_property  PACKAGE_PIN N44      [get_ports  {pcie_rxp[7]}]    
#
set_property  PACKAGE_PIN AB42     [get_ports  {pcie_txn[0]}]   
set_property  PACKAGE_PIN Y42      [get_ports  {pcie_txn[1]}]   
set_property  PACKAGE_PIN V42      [get_ports  {pcie_txn[2]}]   
set_property  PACKAGE_PIN U44      [get_ports  {pcie_txn[3]}]   
set_property  PACKAGE_PIN T42      [get_ports  {pcie_txn[4]}]   
set_property  PACKAGE_PIN R44      [get_ports  {pcie_txn[5]}]   
set_property  PACKAGE_PIN P42      [get_ports  {pcie_txn[6]}]   
set_property  PACKAGE_PIN M42      [get_ports  {pcie_txn[7]}]   
set_property  PACKAGE_PIN AB41     [get_ports  {pcie_txp[0]}]   
set_property  PACKAGE_PIN Y41      [get_ports  {pcie_txp[1]}]   
set_property  PACKAGE_PIN V41      [get_ports  {pcie_txp[2]}]   
set_property  PACKAGE_PIN U43      [get_ports  {pcie_txp[3]}]   
set_property  PACKAGE_PIN T41      [get_ports  {pcie_txp[4]}]   
set_property  PACKAGE_PIN R43      [get_ports  {pcie_txp[5]}]   
set_property  PACKAGE_PIN P41      [get_ports  {pcie_txp[6]}]   
set_property  PACKAGE_PIN M41      [get_ports  {pcie_txp[7]}]

#PCIE_PERST_B                            501     PMC_MIO38_501   
#set_property PACKAGE_PIN D19       [get_ports sys_reset_n]

# Bank 306  VCC1V8       IO_L6P_HDGC_306       
set_property    PACKAGE_PIN L35         [get_ports {leds[0]}] 
set_property    IOSTANDARD LVCMOS18     [get_ports {leds[0]}]
# Bank 306  VCC1V8       IO_L6N_306
set_property    PACKAGE_PIN K36         [get_ports {leds[1]}]      
set_property    IOSTANDARD LVCMOS18     [get_ports {leds[1]}]
# Bank 306  VCC1V8       IO_L7P_306
set_property    PACKAGE_PIN J33         [get_ports {leds[2]}]      
set_property    IOSTANDARD LVCMOS18     [get_ports {leds[2]}]
# Bank 306  VCC1V8       IO_L7N_306
set_property    PACKAGE_PIN H34         [get_ports {leds[3]}]      
set_property    IOSTANDARD LVCMOS18     [get_ports {leds[3]}]

set_property    PACKAGE_PIN AF43        [get_ports DDR4_DIMM1_CLK_N]
set_property    PACKAGE_PIN AE42        [get_ports DDR4_DIMM1_CLK_P]
set_property    IOSTANDARD DIFF_SSTL12  [get_ports DDR4_DIMM1_CLK_P] 
set_property    IOSTANDARD DIFF_SSTL12  [get_ports DDR4_DIMM1_CLK_N] 

create_clock -name DDR4_DIMM1_CLK -period 5.000 [get_ports DDR4_DIMM1_CLK_P]

create_generated_clock -name clk_out25_clk_wiz_regmap0 [get_pins -hierarchical -filter {NAME =~ "g_endpoints[0].pcie0/clk0/clk0/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0"}]
create_generated_clock -name pcie_userclk0 [get_pins -hierarchical -filter {NAME =~ "g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/DPLL_PCIE0_inst/CLKOUT0"}]

set_false_path -from [get_clocks DDR4_DIMM1_CLK_P] -to [get_clocks pcie_userclk0]


#Some timing constraints, can later move to separate timing constraints file
set_max_delay -datapath_only -from [get_clocks clk_out25*] -to [get_clocks *] 40.000
set_max_delay -datapath_only -from [get_clocks *] -to [get_clocks clk_out25*] 40.000

#

# These constraints are currently missing in the IP and should be integrated into the IP. 
# These are needed for write_device_image to work properly.
#set_property HD.TANDEM 1 [get_cells design_1_i/versal_cips_0/inst/IBUFDS_GTE5_inst]
set_property -quiet HD.TANDEM 1 [get_cells -hierarchical -filter {PRIMITIVE_TYPE == I/O.INPUT_BUFFER.IBUFDS_GTE5}]

# Enable the Deskew logic in the DPLL so that designs with PCIE-A-to-PL connection can meet timing better
#set_property CLKOUT0_PHASE_CTRL 2'b01 [get_cells design_1_wrapper_i/design_1_i/versal_cips_0/inst/DPLL_PCIE0_inst]
#set_property CLKOUT0_PHASE_CTRL 2'b01 [get_cells get_cells */*/*/DPLL_PCIE*inst]

# Add hold time margin as recommended
#set_clock_uncertainty -hold 0.200 [get_clocks pluserclk0_bufg_in]

# Set clock root contraint
#set_property USER_CLOCK_ROOT X0Y2 [get_nets -of [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/bufg_pcie_0/O]]

# set clock uncertainty for PL paths
set_clock_uncertainty -hold 0.050 -from [get_clocks -of_objects [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/DPLL_PCIE0_inst/CLKOUT0]] \
                                     -to [get_clocks -of_objects [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/DPLL_PCIE0_inst/CLKOUT0]]

# Additional Skew delay and LOC constraint
#set_property DESKEW_DELAY_EN TRUE [get_cells g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/DPLL_PCIE0_inst]
#set_property DESKEW_DELAY_PATH TRUE [get_cells g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/DPLL_PCIE0_inst]
#set_property DESKEW_DELAY 4 [get_cells g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/DPLL_PCIE0_inst]
#set_property LOC DPLL_X1Y4 [get_cells g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/inst/DPLL_PCIE0_inst]

#create_clock -name AXISCLK0_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/AXISCLK_M]
#create_clock -name AXISCLK1_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/AXISCLK_M]
#create_clock -name CH0_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH0_DMONITORCLK_M]
#create_clock -name CH1_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH1_DMONITORCLK_M]
#create_clock -name CH2_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH2_DMONITORCLK_M]
#create_clock -name CH3_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH3_DMONITORCLK_M]
#create_clock -name CH4_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH0_DMONITORCLK_M]
#create_clock -name CH5_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH1_DMONITORCLK_M]
#create_clock -name CH6_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH2_DMONITORCLK_M]
#create_clock -name CH7_DMONITORCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH3_DMONITORCLK_M]
#create_clock -name DEBUGTRACECLK0_M -period 10.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/DEBUGTRACECLK_M]
#create_clock -name DEBUGTRACECLK1_M -period 10.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/DEBUGTRACECLK_M]
#create_clock -name CH0_RXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH0_RXUSRCLK_M]
#create_clock -name CH1_RXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH1_RXUSRCLK_M]
#create_clock -name CH2_RXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH2_RXUSRCLK_M]
#create_clock -name CH3_RXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH3_RXUSRCLK_M]
#create_clock -name CH0_TXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH0_TXUSRCLK_M]
#create_clock -name CH1_TXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH1_TXUSRCLK_M]
#create_clock -name CH2_TXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH2_TXUSRCLK_M]
#create_clock -name CH3_TXUSRCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH3_TXUSRCLK_M]
#create_clock -name RXMARGINCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/RXMARGINCLK_M]
#create_clock -name IFCPMEXTCLKRSTPCIE1USERCLK -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/CPM_INST/CPM_MAIN_INST/IFCPMEXTCLKRSTPCIE1USERCLK]
#create_clock -name IFCPMXPIPEHSDPLINKXPIPEGTRXUSRCLK -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/CPM_INST/CPM_MAIN_INST/IFCPMXPIPEHSDPLINKXPIPEGTRXUSRCLK]
#create_clock -name CH0_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH0_RXLATCLK_M]
#create_clock -name CH1_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH1_RXLATCLK_M]
#create_clock -name CH2_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH2_RXLATCLK_M]
#create_clock -name CH3_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH3_RXLATCLK_M]
#create_clock -name CH0_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH0_TXLATCLK_M]
#create_clock -name CH1_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH1_TXLATCLK_M]
#create_clock -name CH2_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH2_TXLATCLK_M]
#create_clock -name CH3_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD0_inst/CH3_TXLATCLK_M]

#create_clock -name CH4_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH0_RXLATCLK_M]
#create_clock -name CH5_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH1_RXLATCLK_M]
#create_clock -name CH6_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH2_RXLATCLK_M]
#create_clock -name CH7_RXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH3_RXLATCLK_M]
#create_clock -name CH4_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH0_TXLATCLK_M]
#create_clock -name CH5_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH1_TXLATCLK_M]
#create_clock -name CH6_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH2_TXLATCLK_M]
#create_clock -name CH7_TXLATCLK_M -period 4.000 [get_pins g_endpoints[0].pcie0/ep0/g_NoSim.g_versal.pcie_ep_versal0/versal_cips_block_i/versal_cips_0/U0/XPIPE_QUAD1_inst/CH3_TXLATCLK_M]

#set_max_delay -datapath_only -from [get_clocks CH*_RXUSRCLK_M] -to [get_clocks GT_REFCLK0] 10.0
#set_max_delay -datapath_only -from [get_clocks IFCPMXPIPEHSDPLINKXPIPEGTRXUSRCLK] -to [get_clocks GT_REFCLK0] 10.0

