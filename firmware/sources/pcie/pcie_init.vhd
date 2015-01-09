--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_init
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
--! Contains a process to initialize some registers in the PCI express Gen3 core.
--! Additionally it reads the BAR0..2 registers and outputs their values to be 
--! used by dma_control. 
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

--! @brief ieee

library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity pcie_init is
  port (
    bar0                     : out    std_logic_vector(31 downto 0);
    bar1                     : out    std_logic_vector(31 downto 0);
    bar2                     : out    std_logic_vector(31 downto 0);
    cfg_mgmt_addr            : out    std_logic_vector(18 downto 0);
    cfg_mgmt_byte_enable     : out    std_logic_vector(3 downto 0);
    cfg_mgmt_read            : out    std_logic;
    cfg_mgmt_read_data       : in     std_logic_vector(31 downto 0);
    cfg_mgmt_read_write_done : in     std_logic;
    cfg_mgmt_write           : out    std_logic;
    cfg_mgmt_write_data      : out    std_logic_vector(31 downto 0);
    clk                      : in     std_logic;
    reset                    : in     std_logic);
end entity pcie_init;

architecture rtl of pcie_init is


    signal bar0_s: std_logic_vector(31 downto 0);
    signal bar1_s: std_logic_vector(31 downto 0);
    signal bar2_s: std_logic_vector(31 downto 0);
    signal write_cfg_done_1: std_logic;
    signal bar_index : std_logic_vector(1 downto 0);
    
begin

    cfg_write_skp_nolfsr : process(clk)
    begin
      if(rising_edge(clk)) then
        bar0 <= bar0_s;
        bar1 <= bar1_s;
        bar2 <= bar2_s;
        bar0_s <= bar0_s;
        bar1_s <= bar1_s;
        bar2_s <= bar2_s;
        
        
        if (reset = '1') then
          cfg_mgmt_addr        <= "000"&x"0000";
          cfg_mgmt_write_data  <= x"00000000";
          cfg_mgmt_byte_enable <= x"0";
          cfg_mgmt_write       <= '0';
          cfg_mgmt_read        <= '0';
          write_cfg_done_1     <= '0';
          bar_index            <= "00"; 
        elsif(write_cfg_done_1 = '1') then
          case(bar_index) is
            when "00" =>
              cfg_mgmt_addr <= "000"&x"0004"; --read BAR0
              if(cfg_mgmt_read_write_done = '1') then
                bar0_s <= cfg_mgmt_read_data;
                bar_index <= "01";
              end if;
            when "01" =>
              cfg_mgmt_addr <= "000"&x"0005"; --read BAR1
              if(cfg_mgmt_read_write_done = '1') then
                bar1_s <= cfg_mgmt_read_data;
                bar_index <= "10";
              end if;
            when "10" =>
              cfg_mgmt_addr <= "000"&x"0006"; --read BAR2
              if(cfg_mgmt_read_write_done = '1') then
                bar2_s <= cfg_mgmt_read_data;
                bar_index <= "00";
              end if;
            when others =>
              bar_index <= "00";
          end case;
          cfg_mgmt_write_data  <= (others => '0');
          cfg_mgmt_byte_enable <= x"F";
          cfg_mgmt_write       <= '0';
          cfg_mgmt_read        <= '1'; 
        elsif((cfg_mgmt_read_write_done = '1') and (write_cfg_done_1 = '0')) then
          cfg_mgmt_addr        <= "100"&x"0082";
          cfg_mgmt_write_data(31 downto 28) <= cfg_mgmt_read_data(31 downto 28);
          cfg_mgmt_write_data(27)    <= '1'; 
          cfg_mgmt_write_data(26 downto 0)  <= cfg_mgmt_read_data(26 downto 0);
          cfg_mgmt_byte_enable <= x"F";
          cfg_mgmt_write       <= '1';
          cfg_mgmt_read        <= '0';
          write_cfg_done_1     <= '1';
        elsif (write_cfg_done_1 = '0') then
          cfg_mgmt_addr        <= "100"&x"0082";
          cfg_mgmt_write_data  <= (others => '0');
          cfg_mgmt_byte_enable <= x"F";
          cfg_mgmt_write       <= '0';
          cfg_mgmt_read        <= '1';  
        end if;
      end if;
    end process;

end architecture rtl ; -- of pcie_init

