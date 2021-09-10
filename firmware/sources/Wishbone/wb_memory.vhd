
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class wb_memory
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
--! Example to use as a slave for Wishbone bus
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.wishbone_pkg.all;
library xpm;
use xpm.vcomponents.all;

entity wb_memory is
port(
    -- WISHBONE inteface:
    slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;
    CLK_I   : in  std_logic;
    RST_I   : in  std_logic
     );
end wb_memory;

architecture Behavioral of wb_memory is
COMPONENT wishbone_memory
  PORT (
    clka    : IN STD_LOGIC;
    rsta    : IN STD_LOGIC;
    ena     : IN STD_LOGIC;
    wea     : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

begin
  
  mem0 : xpm_memory_spram
   generic map (
      ADDR_WIDTH_A => 16,
      AUTO_SLEEP_TIME => 0,
      BYTE_WRITE_WIDTH_A => 32,
      --CASCADE_HEIGHT => 0,
      ECC_MODE => "no_ecc",
      MEMORY_INIT_FILE => "none",
      MEMORY_INIT_PARAM => "0",
      MEMORY_OPTIMIZATION => "true",
      MEMORY_PRIMITIVE => "auto",
      MEMORY_SIZE => 65536*32,
      MESSAGE_CONTROL => 0,
      READ_DATA_WIDTH_A => 32,
      READ_LATENCY_A => 1,
      READ_RESET_VALUE_A => "0",
      --RST_MODE_A => "SYNC",
      --SIM_ASSERT_CHK => 0,
      USE_MEM_INIT => 1,
      WAKEUP_TIME => "disable_sleep",
      WRITE_DATA_WIDTH_A => 32,
      WRITE_MODE_A => "read_first"
   )
   port map (
      dbiterra => open,
      douta => slave_o.dat (31 downto 0),
      sbiterra => open,
      addra => slave_i.adr (15 downto 0),
      clka => CLK_I,
      dina => slave_i.dat (31 downto 0),
      ena => slave_i.stb,
      injectdbiterra => '0',
      injectsbiterra => '0',
      regcea => '1',
      rsta => RST_I,
      sleep => '0',
      wea(0) => slave_i.we
   );
  
  process(CLK_I)
  variable stb_p1: std_logic;
  begin
    if rising_edge(CLK_I) then      
        slave_o.ack <=  stb_p1;
        stb_p1 := slave_i.stb;        
    end if;
  end process;
  
  slave_o.err <= '0';
  slave_o.rty <= '0';
  slave_o.stall <= '0';
  slave_o.int <= '0';
    
end Behavioral;