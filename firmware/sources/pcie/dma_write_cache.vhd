
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class dma_write_cache
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
--! This unit records all transmitted DMA TLPs. If back pressure is issued from the
--! pc side, the last TLP may be lost, when the back pressure is released, this
--! unit "replays" the TLP.
--! 
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 
-- 
--! @brief ieee



library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity dma_write_cache is
  generic(
    USE_BACKUP_CACHE : boolean := true);
  port (
    cache_tready   : out    std_logic;
    clk            : in     std_logic;
    dma_soft_reset : in     std_logic;
    m_axis_r_rq    : in     axis_r_type;
    m_axis_rq      : out    axis_type;
    reset          : in     std_logic;
    s_axis_r_rq    : out    axis_r_type;
    s_axis_rq      : in     axis_type);
end entity dma_write_cache;



architecture rtl of dma_write_cache is

COMPONENT cache_fifo
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(265 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(265 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;
ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
ATTRIBUTE SYN_BLACK_BOX OF cache_fifo : COMPONENT IS TRUE;
ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
ATTRIBUTE BLACK_BOX_PAD_PIN OF cache_fifo : COMPONENT IS "clk,srst,din[265:0],wr_en,rd_en,dout[265:0],full,empty";

  
  type cache_state_type is(TRANSFER, START_RESTORE, RESTORE);
  signal cache_state: cache_state_type := TRANSFER;
  signal tready_overrule: std_logic;
  
  signal tready_pipe : std_logic;
  
  signal fifo_srst: std_logic;
  signal fifo_din: std_logic_vector(265 downto 0);
  signal fifo_dout: std_logic_vector(265 downto 0);
  signal fifo_rd_en: std_logic;
  signal fifo_wr_en: std_logic;
  signal fifo_rd_en_s: std_logic;
  signal fifo_wr_en_s: std_logic;
  signal fifo_full: std_logic;
  signal fifo_empty: std_logic;
begin

g0: if(USE_BACKUP_CACHE = true) generate

  s_axis_r_rq <= m_axis_r_rq;
  
  cache_tready <= tready_overrule;
  
  
  
  fifo0 : cache_fifo
  PORT MAP (
    clk => clk,
    srst => fifo_srst,
    din => fifo_din,
    wr_en => fifo_wr_en,
    rd_en => fifo_rd_en,
    dout => fifo_dout,
    full => fifo_full,
    empty => fifo_empty
  );
  
  fifo_rd_en <= fifo_rd_en_s and (not fifo_empty);
  fifo_wr_en <= fifo_wr_en_s and (not fifo_full);

  sync: process(clk, reset)
  begin
    if(reset = '1') then
      cache_state <= TRANSFER;
      fifo_srst <= '1'; 
    elsif (rising_edge(clk)) then
      fifo_din <= s_axis_rq.tdata &
              s_axis_rq.tkeep &
              s_axis_rq.tlast&
              s_axis_rq.tvalid;
      tready_pipe <= m_axis_r_rq.tready;
      tready_overrule <= '1';
      cache_state <= cache_state;
      fifo_wr_en_s <= '0';
      fifo_srst <= '0';
      fifo_rd_en_s <= '0';
      
      case (cache_state) is
        when TRANSFER =>
          --normal operation, just throughput the data
          m_axis_rq <= s_axis_rq;
          
          --additionally write the data in cache, in case we need to restore one TLP
          if(tready_pipe = '1' and s_axis_rq.tvalid='1')then
            fifo_wr_en_s <= '1';
          end if;

          if(m_axis_r_rq.tready = '0' and s_axis_rq.tvalid='1') then
            cache_state <= START_RESTORE;
          elsif(s_axis_rq.tlast = '1') then
            fifo_srst <= '1';          --new tlp, forget current tlp one
          end if;
          
          
          
        when START_RESTORE =>
          --normal operation, just throughput the data
          m_axis_rq <= s_axis_rq;
          
          --additionally write the data in cache, in case we need to restore one TLP
          if(tready_pipe = '1' and s_axis_rq.tvalid='1')then
            fifo_wr_en_s <= '1';
          end if;
          tready_overrule <= '0'; --tell the DMA core to keep quiet as we are restoring
          if(s_axis_rq.tlast = '1') then
            cache_state <= RESTORE;
            fifo_rd_en_s <= '1';
          end if;          
        when RESTORE =>
          tready_overrule <= '0'; --tell the DMA core to keep quiet as we are restoring
          m_axis_rq.tdata <= fifo_dout(265 downto 10);
          m_axis_rq.tkeep <= fifo_dout(9 downto 2);
          m_axis_rq.tlast <= fifo_dout(1);
          m_axis_rq.tvalid <= fifo_dout(0);
          
          if(fifo_dout(1)='1')then
            cache_state <= TRANSFER;
          else
            fifo_rd_en_s <= '1';
          end if;
      end case;
    end if;
  end process;
  
end generate;

g1: if (USE_BACKUP_CACHE = false) generate
  cache_tready <= '1';
  m_axis_rq <= s_axis_rq;
  s_axis_r_rq <= m_axis_r_rq;
end generate;
  
end architecture rtl ; -- of dma_write_cache

