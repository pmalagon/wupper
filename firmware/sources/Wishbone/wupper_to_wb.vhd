
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class wuppper_to_wb
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
--! Makes the Wupper output data Wishbone compatible. 
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
use work.pcie_package.all;
library xpm;
use xpm.vcomponents.all;

entity wupper_to_wb is
port(
    master_i            :   in  t_wishbone_master_in;
    master_o            :   out t_wishbone_master_out;
    control_in          :   in  register_map_control_type;
    monitor_out         :   out wishbone_monitor_type;     
    wishbone_clk_i      :   in  std_logic;
    wupper_clk_i        :   in  std_logic;
    rst_i               :   in  std_logic
    );
end wupper_to_wb;

architecture Behavioral of wupper_to_wb is

COMPONENT wupper_to_wishbone_fifo
  PORT (
    rst     : IN STD_LOGIC;
    wr_clk  : IN STD_LOGIC;
    rd_clk  : IN STD_LOGIC;
    din     : IN STD_LOGIC_VECTOR(64 DOWNTO 0);
    wr_en   : IN STD_LOGIC;
    rd_en   : IN STD_LOGIC;
    dout    : OUT STD_LOGIC_VECTOR(64 DOWNTO 0);
    full    : OUT STD_LOGIC;
    empty   : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT wishbone_to_wupper_fifo
  PORT (
    rst     : IN STD_LOGIC;
    wr_clk  : IN STD_LOGIC;
    rd_clk  : IN STD_LOGIC;
    din     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en   : IN STD_LOGIC;
    rd_en   : IN STD_LOGIC;
    dout    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full    : OUT STD_LOGIC;
    empty   : OUT STD_LOGIC
  );
END COMPONENT;

    type state_type is (wb_idle, wb_start);
    signal prs, nxt :       state_type;
    signal wupper2wb_fifo_out   :   std_logic_vector(64 downto 0);    
    signal wupper2wb_empty      :   std_logic;
    signal wupper2wb_rd_en      :   std_logic;
    signal wb2wupper_wr_en      :   std_logic;
    signal wb2wupper_full       :   std_logic;
    signal wupper2wb_wr_en      :   std_logic;  
    signal wupper2wb_wr_en1     :   std_logic;
    signal wb2wupper_rd_en      :   std_logic;
    signal wb2wupper_rd_en1     :   std_logic;  
    signal wupper2wb_data_in    :   std_logic_vector (64 downto 0);
    signal master_i_s           :   t_wishbone_master_in;     
                
begin

    wupper2wb_data_in(64 downto 64) <= control_in.wishbone_control.write_not_read;
    wupper2wb_data_in(63 downto 32) <= control_in.wishbone_control.address;
    wupper2wb_data_in(31 downto 0)  <= control_in.wishbone_write.data;
  
  wupper_to_wb_fifo0 : xpm_fifo_async
   generic map (
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 32,   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 5,    -- DECIMAL
      PROG_FULL_THRESH => 25,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => 1,   -- DECIMAL
      READ_DATA_WIDTH => 65,      -- DECIMAL
      READ_MODE => "std",         -- String
      --SIM_ASSERT_CHK => 0,        -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_ADV_FEATURES => "0000", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => 65,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => 1    -- DECIMAL
   )
   port map (
      almost_empty => open,
      almost_full => open,
      data_valid => open,
      dbiterr => open,
      rd_clk => wishbone_clk_i,
      dout => wupper2wb_fifo_out,
      empty => wupper2wb_empty,
      full => monitor_out.wishbone_write.full(32),
      overflow => open,
      prog_empty => open,
      prog_full => open,
      rd_data_count => open,
      rd_rst_busy => open,
      sbiterr => open,
      underflow => open,
      wr_ack => open,
      wr_data_count => open,
      wr_rst_busy => open,
      din => wupper2wb_data_in,
      injectdbiterr => '0',
      injectsbiterr => '0',
      wr_clk => wupper_clk_i,
      rd_en => wupper2wb_rd_en,
      rst => RST_I,
      sleep => '0',
      wr_en => wupper2wb_wr_en
   );
    
 wb_to_wupper_fifo0 : xpm_fifo_async
   generic map (
      DOUT_RESET_VALUE => "0",    -- String
      ECC_MODE => "no_ecc",       -- String
      FIFO_MEMORY_TYPE => "auto", -- String
      FIFO_READ_LATENCY => 1,     -- DECIMAL
      FIFO_WRITE_DEPTH => 32,   -- DECIMAL
      FULL_RESET_VALUE => 0,      -- DECIMAL
      PROG_EMPTY_THRESH => 5,    -- DECIMAL
      PROG_FULL_THRESH => 25,     -- DECIMAL
      RD_DATA_COUNT_WIDTH => 1,   -- DECIMAL
      READ_DATA_WIDTH => 32,      -- DECIMAL
      READ_MODE => "std",         -- String
      --SIM_ASSERT_CHK => 0,        -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_ADV_FEATURES => "0000", -- String
      WAKEUP_TIME => 0,           -- DECIMAL
      WRITE_DATA_WIDTH => 32,     -- DECIMAL
      WR_DATA_COUNT_WIDTH => 1    -- DECIMAL
   )
   port map (
      almost_empty => open,
      almost_full => open,
      data_valid => open,
      dbiterr => open,
      rd_clk => wupper_clk_i,
      dout => monitor_out.wishbone_read.data,
      empty => monitor_out.wishbone_read.empty(32),
      full => wb2wupper_full,
      overflow => open,
      prog_empty => open,
      prog_full => open,
      rd_data_count => open,
      rd_rst_busy => open,
      sbiterr => open,
      underflow => open,
      wr_ack => open,
      wr_data_count => open,
      wr_rst_busy => open,
      din => master_i.dat,
      injectdbiterr => '0',
      injectsbiterr => '0',
      wr_clk => wishbone_clk_i,
      rd_en => wb2wupper_rd_en,
      rst => RST_I,
      sleep => '0',
      wr_en => wb2wupper_wr_en
   );
    
    
monitor_proc: process(wupper_clk_i)
begin
    if rising_edge(wupper_clk_i) then
        master_i_s <= master_i;
        if master_i_s.err = '1' then
            monitor_out.WISHBONE_STATUS.ERROR <= "1";
        elsif wupper2wb_empty = '0' then
            monitor_out.WISHBONE_STATUS.ERROR <= "0";
        end if;
        
        if master_i_s.ack = '1' then
            monitor_out.WISHBONE_STATUS.ACKNOWLEDGE <= "1";
        elsif wupper2wb_empty = '0' then
            monitor_out.WISHBONE_STATUS.ACKNOWLEDGE <= "0";
        end if;
              
        monitor_out.WISHBONE_STATUS.STALL(2) <= master_i_s.stall;
        monitor_out.WISHBONE_STATUS.RETRY(3) <= master_i_s.rty;
        monitor_out.WISHBONE_STATUS.INT(4) <= master_i_s.int;
        
    end if;
end process;
    
    rd_wr_delay: process (wishbone_clk_i, control_in.wishbone_write, control_in.wishbone_read) is
    begin
        if rising_edge(wishbone_clk_i) then
            wupper2wb_wr_en1   <=  to_sl(control_in.wishbone_write.write_enable);       
            wb2wupper_rd_en1   <=  to_sl(control_in.wishbone_read.read_enable);        
        end if;       
        
    end process rd_wr_delay;
    
    wupper2wb_wr_en <=  to_sl(control_in.wishbone_write.write_enable) and not wupper2wb_wr_en1;
    wb2wupper_rd_en <=  to_sl(control_in.wishbone_read.read_enable)  and not wb2wupper_rd_en1; 
                
    state_register: process (wishbone_clk_i, RST_I) is
    begin
        if RST_I = '1' then
            prs <= wb_idle;
        elsif rising_edge(wishbone_clk_i) then
            prs <= nxt;
        end if;
    end process state_register;   
    
    next_state_decoder: process (prs, wupper2wb_empty, master_i, wupper2wb_fifo_out)
    begin
        wb2wupper_wr_en <= '0';
        case prs is
        when wb_idle =>         -- wb_idle
            if wupper2wb_empty = '0' then
                nxt <= wb_start;
            else 
                nxt <= wb_idle;                
            end if;            
        when wb_start =>        -- wb_start
            if master_i.ack = '1' then
                if  wupper2wb_fifo_out(64) = '0' then
                    wb2wupper_wr_en <= not wb2wupper_full;
                end if;
                nxt <= wb_idle;
            elsif master_i.err = '1' then
                nxt <= wb_idle;
            else
                nxt <= wb_start;
            end if;                                                                                                                                                                                                      
        end case;
    end process next_state_decoder;
    
    output_decoder: process(prs, wupper2wb_empty) is
    begin
        wupper2wb_rd_en <= '0';
        master_o.cyc <= '0';
        master_o.stb <= '0';
        master_o.we  <= '0'; 
        master_o.adr <= wupper2wb_fifo_out(63 downto 32);
        master_o.dat <= wupper2wb_fifo_out(31 downto 0);                                    
        
        case prs is
        when wb_idle =>
            wupper2wb_rd_en <= not wupper2wb_empty;
        when wb_start =>
            master_o.we  <= wupper2wb_fifo_out(64);
            master_o.cyc <= '1';
            master_o.stb <= '1';     
        end case;
    end process output_decoder;                                                                                                                                                                                                                                                                                 
end Behavioral;