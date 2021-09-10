
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class felix_top
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! Top level for the FELIX project, containing GBT, CentralRouter and PCIe DMA core
--! 
--! 
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
use ieee.numeric_std_unsigned.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;
library uvvm_util;
context uvvm_util.uvvm_util_context;

entity wupper_tb is
  
end entity wupper_tb;

architecture structure of wupper_tb is

  

  constant NUMBER_OF_INTERRUPTS: integer := 8;
  constant NUMBER_OF_DESCRIPTORS: integer := 5;
  constant DATA_WIDTH: integer := 256;
  
  constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;
  
  
  signal pcie_rxn: std_logic_vector(7 downto 0);
  signal pcie_rxp: std_logic_vector(7 downto 0);
  signal pcie_txn: std_logic_vector(7 downto 0);
  signal pcie_txp: std_logic_vector(7 downto 0);
  
  signal sys_reset_n: std_logic;
  
  
  signal clk240: std_logic;
  constant clk240_period: time := 4.17 ns;
  
  signal clk40: std_logic;
  constant clk40_period: time := 25 ns;
  
  --signal clk250: std_logic;
  
  signal reset_hard: std_logic;
  signal toHostFifo_rst: std_logic;
  signal fromHostFifo_rst: std_logic;
  
  signal toHostFifo_din       : slv_array(0 to NUMBER_OF_DESCRIPTORS -2);
  signal toHostFifo_wr_en     : std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
  signal toHostFifo_prog_full : std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);

  signal fromHostFifo_rd_en   : std_logic;
  signal fromHostFifo_dout    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal fromHostFifo_empty   : std_logic;
  
  signal flush_fifo : std_logic;
  
  signal reset_hw_in : std_logic;
  signal master_busy_in : std_logic;
  signal reset_hard_p2, reset_hard_p1 : std_logic;
  signal fromHostFifo_rd_en_p1 : std_logic;
  
begin
  pcie_rxn <= pcie_txn;
  pcie_rxp <= pcie_txp;
  master_busy_in <= '0';
  
  process
  begin
    sys_reset_n <= '0';
    wait for 100 ns;
    sys_reset_n <= '1';
    wait;
  end process;

  reset_hw_in <= not sys_reset_n;
  
  toHostFifo_rst <= reset_hard or flush_fifo;
  fromHostFifo_rst <= reset_hard or flush_fifo;
  
  process
  begin
    clk240 <= '1';
    wait for clk240_period/2;
    clk240 <= '0';
    wait for clk240_period/2;
  end process;

  process
  begin
    clk40 <= '1';
    wait for clk40_period/2;
    clk40 <= '0';
    wait for clk40_period/2;
  end process;

  pcie0: entity work.wupper
    generic map(
      NUMBER_OF_INTERRUPTS => NUMBER_OF_INTERRUPTS,
      NUMBER_OF_DESCRIPTORS => NUMBER_OF_DESCRIPTORS,
      BUILD_DATETIME => (others => '0'),
      CARD_TYPE => 128,
      GIT_HASH => (others => '0'),
      COMMIT_DATETIME => (others => '0'),
      GIT_TAG => (others => '0'),
      GIT_COMMIT_NUMBER => 42,
      PCIE_ENDPOINT => 0,
      PCIE_LANES => 8,
      DATA_WIDTH => DATA_WIDTH,
      SIMULATION => true,
      BLOCKSIZE => 1024)
    port map(
      appreg_clk => open,
      sync_clk => clk40,
      flush_fifo => flush_fifo,
      interrupt_call => (others => '0'),
      lnk_up => open,
      pcie_rxn => pcie_rxn,
      pcie_rxp => pcie_rxp,
      pcie_txn => pcie_txn,
      pcie_txp => pcie_txp,
      pll_locked => open,
      register_map_control_sync => open,
      register_map_control_appreg_clk => open,
      register_map_gen_board_info => register_map_gen_board_info_c,
      register_map_hk_monitor => register_map_hk_monitor_c,
      wishbone_monitor => wishbone_monitor_c,
      reset_hard => reset_hard,
      reset_soft => open,
      reset_soft_appreg_clk => open,
      reset_hw_in => reset_hw_in,
      sys_clk_n => '0', -- not used, 250 MHz clock generated internally
      sys_clk_p => '0', -- not used, 250 MHz clock generated internally
      sys_reset_n => sys_reset_n,
      tohost_busy_out => open,
      fromHostFifo_dout => fromHostFifo_dout,
      fromHostFifo_empty => fromHostFifo_empty,
      fromHostFifo_rd_clk => clk240,
      fromHostFifo_rd_en => fromHostFifo_rd_en,
      fromHostFifo_rst => fromHostFifo_rst,
      toHostFifo_din => toHostFifo_din,
      toHostFifo_prog_full => toHostFifo_prog_full,
      toHostFifo_rst => toHostFifo_rst,
      toHostFifo_wr_clk => clk240,
      wr_data_count => open,
      toHostFifo_wr_en => toHostFifo_wr_en,
      clk250_out => open,
      master_busy_in => master_busy_in);


process(clk240)
begin
    if rising_edge(clk240) then
        reset_hard_p1 <= reset_hard;
        reset_hard_p2 <= reset_hard_p1;
    end if;
end process;


g_fifoWrite: for i in 0 to NUMBER_OF_DESCRIPTORS-2 generate
    signal do_write: std_logic;
    signal cnt: std_logic_vector(31 downto 0);
begin

    process(clk240, reset_hard_p2)
    begin
        if reset_hard_p2 = '1' then
            cnt <= (others => '0');
        elsif rising_edge(clk240) then
            if toHostFifo_prog_full(i) = '0' and do_write = '1' then
                cnt <= cnt + 1;
                toHostFifo_din(i) <=
                    std_logic_vector(to_unsigned(i,8))&
                    x"dd_dddd"&cnt&
                    x"cccc_cccc"&cnt&
                    x"bbbb_bbbb"&cnt&
                    x"aaaa_aaaa"&cnt;
                toHostFifo_wr_en(i) <= '1';
            else
                toHostFifo_wr_en(i) <= '0';
            end if;
        end if;
    end process;
    
    do_write_proc: process(clk240)
    variable rnd: std_logic_vector(9 downto 0);
    begin
        if rising_edge(clk240) then
            rnd := random(10);
            if rnd < 100 then
                do_write <= '1';
            else
                do_write <= '0';
            end if;
        end if;
        
    end process;
        
    
    
end generate;

fromHostCheck_proc: process(clk240, reset_hard_p2) 
    variable cnt : std_logic_vector(31 downto 0);
    variable wrapCnt: std_logic_vector(7 downto 0);
    variable CheckVal: std_logic_vector(255 downto 0);
begin
    if reset_hard_p2 = '1' then
        cnt := (others => '0');
        wrapCnt := x"01";
        fromHostFifo_rd_en_p1 <= '0';
    elsif rising_edge(clk240) then
        fromHostFifo_rd_en_p1 <= fromHostFifo_rd_en;
        if fromHostFifo_rd_en_p1 = '1' then
            CheckVal := cnt&x"AAAAAA"&wrapCnt&
                        cnt&x"BBBBBB"&wrapCnt&
                        cnt&x"CCCCCC"&wrapCnt&
                        cnt&x"DDDDDD"&wrapCnt;
            
            check_value(fromHostFifo_dout, CheckVal, ERROR, "Check counter value in FromHost memory", C_SCOPE);
            
            if cnt < 127 then
                cnt := cnt + 1;
            else
                cnt := (others => '0');
                wrapCnt := wrapCnt + 1;
            end if;
            
            
        end if;
    end if;
end process;

empty_timeout_proc: process
begin
    await_value(fromHostFifo_empty, '0', 0 ns, 40 us, TB_ERROR, "Waiting for FromHost data to arrive", C_SCOPE);
    wait;
end process;

fromHostFifo_rd_en <= not fromHostFifo_empty;

end architecture structure ; -- of felix_top

