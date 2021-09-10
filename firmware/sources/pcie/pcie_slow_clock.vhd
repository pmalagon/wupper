
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_dma_wrap
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        26/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! Creates a slow clock of ~40 MHz (41.667) by dividing the 250MHz clock by 6.
--!
--! @detail
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



library ieee, UNISIM;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;-- @suppress "Deprecated package"
use ieee.std_logic_1164.all;

entity pcie_slow_clock is
  port (
    clk        : in     std_logic;
    regmap_clk : out    std_logic;
    pll_locked : out    std_logic;
    reset_n    : in     std_logic;
    reset_out  : out    std_logic);
end entity pcie_slow_clock;



architecture rtl of pcie_slow_clock is
component clk_wiz_regmap
    port(
        clk_out25 : out STD_LOGIC;
        reset     : in  STD_LOGIC;
        locked    : out STD_LOGIC;
        clk_in1   : in  STD_LOGIC
    );
end component clk_wiz_regmap;



   signal regmap_clk_s: std_logic;
   signal reset_s: std_logic;
   signal locked_s: std_logic;
   

begin

reset_out <= not locked_s;
reset_s <= not reset_n;
pll_locked <= locked_s;
regmap_clk <= regmap_clk_s;

clk0 : clk_wiz_regmap
    port map ( 
    clk_out25 => regmap_clk_s,
    reset => reset_s,
    locked => locked_s,
    clk_in1 => clk            
  );

 
end architecture rtl ; -- of pcie_slow_clock

