
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class wb_syscon
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
--! Systemcontroller for the Wishbone bus. 
--!     
--!    
--!     
--!                      
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

library ieee;
use ieee.std_logic_1164.all;


----------------------------------------------------------------------
-- Entity declaration.
----------------------------------------------------------------------

entity wb_syscon is
    port(
            -- WISHBONE Interface

            CLK_O:  out std_logic;
            RST_O:  out std_logic;


            -- NON-WISHBONE Signals

            EXTCLK: in  std_logic;   
            EXTRST: in  std_logic
         );

end wb_syscon;


----------------------------------------------------------------------
-- Architecture definition.
----------------------------------------------------------------------

architecture wb_syscon of wb_syscon IS

    
begin

  CLK_O <= EXTCLK;
  RST_O <= EXTRST;


end architecture wb_syscon;