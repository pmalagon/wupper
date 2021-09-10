
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class wb_intercon
--! 
--!
--! @author      Roel Blankers  (broel@nikhef.nl)
--!
--!
--! @date        31/10/2017    created
--!
--! @version     1.0
--!
--! @brief 
--! Top level design containing four entities for wupper to Wishbone.
--!     - Systemcontroller
--!     - Block memory
--!     - Crossbar
--!     - Wupper to Wishbone                  
--!          
--! 
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Wupper: PCIe Gen3 and Gen4 DMA Core for Xilinx FPGAs
--! 
--! Copyright (C) 2021 Nikhef, Amsterdam (f.schreuder@nikhef.nl)
--! 
--! Licensed under the Apache License, Version 2.0 (the "License");
--! you may not use this file except in compliance with the License.
--! You may obtain a copy of the License at
--! 
--!         http://www.apache.org/licenses/LICENSE-2.0
--! 
--! Unless required by applicable law or agreed to in writing, software
--! distributed under the License is distributed on an "AS IS" BASIS,
--! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--! See the License for the specific language governing permissions and
--! limitations under the License.
-- 
--! @brief ieee

library ieee, work;
use ieee.std_logic_1164.all;
use work.wishbone_pkg.all;
use work.pcie_package.all;

entity wb_intercon is
    port (
            control_in      :   in  register_map_control_type;
            monitor_out     :   out wishbone_monitor_type;     
            wupper_clk_i    :   in  std_logic;
            rst_soft_i      :   in  std_logic;
            rst_hard_i      :   in  std_logic
        );

end entity wb_intercon;

----------------------------------------------------------------------
-- Architecture definition.
----------------------------------------------------------------------

architecture wb_intercon of wb_intercon is

    constant g_num_masters : integer := 1;
    constant g_num_slaves  : integer := 1;
    
    ------------------------------------------------------------------
    -- Define internal signals.
    ------------------------------------------------------------------
    signal  CLK:            std_logic;
    signal  RST, EXTRST:    std_logic; 
    signal  read_en:        std_logic;
    signal  write_en:       std_logic;
    signal  full_signal:    std_logic;  
    signal  empty_signal:   std_logic; 
    signal  register_map_monitor:   register_map_monitor_type;
    signal  register_map_control:   register_map_control_type;          
    signal  Slave_o:    t_wishbone_slave_out_array(g_num_masters-1 downto 0);
    signal  Slave_i:    t_wishbone_slave_in_array(g_num_masters-1 downto 0);
    signal  Master_o:   t_wishbone_master_out_array(g_num_slaves-1 downto 0);
    signal  Master_i:   t_wishbone_master_in_array(g_num_slaves-1 downto 0);    
      
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of Master_o : signal is "TRUE";
    attribute DONT_TOUCH of Master_i : signal is "TRUE";
    attribute DONT_TOUCH of Slave_o : signal is "TRUE";
    attribute DONT_TOUCH of Slave_i : signal is "TRUE";       
                
begin

    EXTRST <= rst_hard_i or rst_soft_i;
    ------------------------------------------------------------------
    -- Connect up the signals on the individual components.
    ------------------------------------------------------------------
    -- NOTE: THE 'EXTTST' BIT IS NOT NEEDED, AND HAS BEEN TIED LOW.
    ------------------------------------------------------------------

    U00: entity work.wb_syscon
    port map(
        CLK_O   =>  CLK,
        RST_O   =>  RST,
        EXTCLK  =>  wupper_clk_i,
        EXTRST  =>  EXTRST
         );
                                                                                   
    U01: entity work.wb_memory
    port map(
        slave_i =>  Slave_i(0),  
        slave_o =>  Slave_o(0),  
        CLK_I   =>  CLK,
        RST_I   =>  RST
         );
        
    U02: entity work.xwb_crossbar
    generic map(
      g_num_masters => g_num_masters,
      g_num_slaves  => g_num_slaves,
      g_registered  => false,
      -- Address of the slaves connected
      g_address     => ( 0 => X"80000000" ),
      g_mask        => ( 0 => X"FFFF0000" )
      )
    port map(
        clk_sys_i =>  CLK,
        rst_n_i =>  RST, 
        slave_i =>  Master_o,       
        slave_o =>   Master_i,      
        master_i =>  Slave_o, 
        master_o =>  Slave_i                
    );             

   U03: entity work.wupper_to_wb
   port map(
       control_in           =>  control_in,
       monitor_out          =>  monitor_out,        
       wishbone_clk_i       =>  wupper_clk_i,
       wupper_clk_i         =>  wupper_clk_i,
       RST_I                =>  RST,     
       master_o             =>  Master_o(0), 
       master_i             =>  Master_i(0)                 
    );               
end architecture wb_intercon;
