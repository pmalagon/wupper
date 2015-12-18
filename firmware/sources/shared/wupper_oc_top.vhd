
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class virtex7_dma_top
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.1
--!
--! @brief 
--! Top level design containing a simple application and the PCIe DMA 
--! core
--!
--!
--! 11/19/2015 B. Kuschak <brian@skybox.com> 
--!          Modifications for KCU105.
--! 
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

entity wupper_oc_top is
  generic(
    NUMBER_OF_INTERRUPTS  : integer := 8;
    NUMBER_OF_DESCRIPTORS : integer := 8;
    CARD_TYPE             : integer := 709;
    SVN_VERSION           : integer := 0;
    BUILD_DATETIME        : std_logic_vector(39 downto 0) := x"0000FE71CE");
  port (
    emcclk      : in     std_logic; --! emcclk is part of the JTAG high speed programming.
    emcclk_out  : out    std_logic; --! use emcclk_out in order to not optimize emcclk away
    leds        : out    std_logic_vector(7 downto 0); --! 8 status leds
    pcie_rxn    : in     std_logic_vector(7 downto 0);
    pcie_rxp    : in     std_logic_vector(7 downto 0);
    pcie_txn    : out    std_logic_vector(7 downto 0);
    pcie_txp    : out    std_logic_vector(7 downto 0); --! PCIe link lanes
    sys_clk_n   : in     std_logic;
    sys_clk_p   : in     std_logic; --! 100MHz PCIe reference clock
    sys_reset_n : in     std_logic); --! Active-low system reset from PCIe interface
end entity wupper_oc_top;


architecture structure of wupper_oc_top is

  signal register_map_monitor  : register_map_monitor_type; --! this signal contains all status (read only) signals from the application. The record members are described in pcie_package.vhd
  signal register_map_control  : register_map_control_type; --! contains all read/write registers that control the application. The record members are described in pcie_package.vhd
  signal upfifo_din            : std_logic_vector(255 downto 0);
  signal upfifo_we             : std_logic;
  signal upfifo_prog_full      : std_logic;
  signal fifo_wr_clk           : std_logic; --! High speed DMA fifo for the PC => PCIe transfers
  signal downfifo_dout         : std_logic_vector(255 downto 0);
  signal downfifo_re           : std_logic;
  signal downfifo_prog_empty   : std_logic;
  signal fifo_rd_clk           : std_logic; --! High speed DMA fifo for the PCIe => PC transfers
  signal flush_fifo            : std_logic; --! Reset signal for the FIFOs
  signal interrupt_call        : std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
  signal appreg_clk            : std_logic;
  signal u1_pll_locked         : std_logic;
  signal reset_soft            : std_logic;
  signal reset_hard            : std_logic;
  signal downfifo_empty_thresh : STD_LOGIC_VECTOR(7 downto 0);
  signal sys_reset_n_c        : std_logic;

  component wupper
    generic(
      NUMBER_OF_INTERRUPTS  : integer := 8;
      NUMBER_OF_DESCRIPTORS : integer := 8;
      CARD_TYPE             : integer := 709;
      BUILD_DATETIME        : std_logic_vector(39 downto 0) := x"0000FE71CE";
      SVN_VERSION           : integer := 0);
    port (
      appreg_clk            : out    std_logic;
      downfifo_dout         : in     std_logic_vector(255 downto 0);
      downfifo_empty_thresh : out    STD_LOGIC_VECTOR(7 downto 0);
      downfifo_prog_empty   : in     std_logic;
      downfifo_re           : out    std_logic;
      fifo_rd_clk           : out    std_logic;
      fifo_wr_clk           : out    std_logic;
      flush_fifo            : out    std_logic;
      interrupt_call        : in     std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
      pcie_rxn              : in     std_logic_vector(7 downto 0);
      pcie_rxp              : in     std_logic_vector(7 downto 0);
      pcie_txn              : out    std_logic_vector(7 downto 0);
      pcie_txp              : out    std_logic_vector(7 downto 0);
      pll_locked            : out    std_logic;
      register_map_control  : out    register_map_control_type;
      register_map_monitor  : in     register_map_monitor_type;
      reset_hard            : out    std_logic;
      reset_soft            : out    std_logic;
      sys_clk_n             : in     std_logic;
      sys_clk_p             : in     std_logic;
      sys_reset_n           : in     std_logic;
      upfifo_din            : out    std_logic_vector(255 downto 0);
      upfifo_prog_full      : in     std_logic;
      upfifo_we             : out    std_logic);
  end component wupper;

  component application
    generic(
      NUMBER_OF_INTERRUPTS : integer := 8);
    port (
      appreg_clk            : in     std_logic;
      downfifo_dout         : out    std_logic_vector(255 downto 0);
      downfifo_empty_thresh : in     STD_LOGIC_VECTOR(7 downto 0);
      downfifo_prog_empty   : out    std_logic;
      downfifo_re           : in     std_logic;
      fifo_rd_clk           : in     std_logic;
      fifo_wr_clk           : in     std_logic;
      flush_fifo            : in     std_logic;
      interrupt_call        : out    std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
      leds                  : out    std_logic_vector(7 downto 0);
      pll_locked            : in     std_logic;
      register_map_control  : in     register_map_control_type; --! contains all read/write registers that control the application. The record members are described in pcie_package.vhd
      register_map_monitor  : out    register_map_monitor_type; --! contains all status (read only) signals from the application. The record members are described in pcie_package.vhd
      reset_hard            : in     std_logic;
      reset_soft            : in     std_logic;
      upfifo_din            : in     std_logic_vector(255 downto 0);
      upfifo_prog_full      : out    std_logic;
      upfifo_we             : in     std_logic);
  end component application;

begin
  emcclk_out <= emcclk;
  
  
  -- This seems to be needed for ultrascale
  ib1: IBUF 
    port map (
        I => sys_reset_n,
        O => sys_reset_n_c);



  --! Instantiation of the actual PCI express core. Please note the 40MHz
  --! clock required by the core, the 250MHz clock (fifo_rd_clk and fifo_wr_clk) 
  --! are generated from sys_clk_p and _n
  u1: wupper
    generic map(
      NUMBER_OF_INTERRUPTS  => NUMBER_OF_INTERRUPTS,
      NUMBER_OF_DESCRIPTORS => NUMBER_OF_DESCRIPTORS,
      CARD_TYPE             => CARD_TYPE,
      BUILD_DATETIME        => BUILD_DATETIME,
      SVN_VERSION           => SVN_VERSION)
    port map(
      appreg_clk            => appreg_clk,
      downfifo_dout         => downfifo_dout,
      downfifo_empty_thresh => downfifo_empty_thresh,
      downfifo_prog_empty   => downfifo_prog_empty,
      downfifo_re           => downfifo_re,
      fifo_rd_clk           => fifo_rd_clk,
      fifo_wr_clk           => fifo_wr_clk,
      flush_fifo            => flush_fifo,
      interrupt_call        => interrupt_call,
      pcie_rxn              => pcie_rxn,
      pcie_rxp              => pcie_rxp,
      pcie_txn              => pcie_txn,
      pcie_txp              => pcie_txp,
      pll_locked            => u1_pll_locked,
      register_map_control  => register_map_control,
      register_map_monitor  => register_map_monitor,
      reset_hard            => reset_hard,
      reset_soft            => reset_soft,
      sys_clk_n             => sys_clk_n,
      sys_clk_p             => sys_clk_p,
      sys_reset_n           => sys_reset_n_c,
      upfifo_din            => upfifo_din,
      upfifo_prog_full      => upfifo_prog_full,
      upfifo_we             => upfifo_we);


  --! The example application only instantiates one fifo (PC=>PCIe). 
  --! it fills it with some constants and a counter value.
  u0: application
    generic map(
      NUMBER_OF_INTERRUPTS => NUMBER_OF_INTERRUPTS)
    port map(
      appreg_clk            => appreg_clk,
      downfifo_dout         => downfifo_dout,
      downfifo_empty_thresh => downfifo_empty_thresh,
      downfifo_prog_empty   => downfifo_prog_empty,
      downfifo_re           => downfifo_re,
      fifo_rd_clk           => fifo_rd_clk,
      fifo_wr_clk           => fifo_wr_clk,
      flush_fifo            => flush_fifo,
      interrupt_call        => interrupt_call,
      leds                  => leds,
      pll_locked            => u1_pll_locked,
      register_map_control  => register_map_control,
      register_map_monitor  => register_map_monitor,
      reset_hard            => reset_hard,
      reset_soft            => reset_soft,
      upfifo_din            => upfifo_din,
      upfifo_prog_full      => upfifo_prog_full,
      upfifo_we             => upfifo_we);
end architecture structure ; -- of wupper_oc_top

