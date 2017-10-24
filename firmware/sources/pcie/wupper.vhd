
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
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! This wrapper would be the unit to instantiate when creating a custom design with
--! this PCIe DMA Core. 
--! It contains the DMA core, the PCI Express hard block and the interrupt controller.
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

entity wupper is
  generic(
    NUMBER_OF_INTERRUPTS  : integer := 8;
    NUMBER_OF_DESCRIPTORS : integer := 8;
    BUILD_DATETIME        : std_logic_vector(39 downto 0) := x"0000FE71CE";
    SVN_VERSION           : integer := 0;
    CARD_TYPE             : integer := 709;
    REG_MAP_VERSION       : std_logic_vector(15 downto 0) := X"0300";
    DEVID                 : std_logic_vector(15 downto 0) := x"7038";
    GIT_HASH              : std_logic_vector(159 downto 0) := x"0000000000000000000000000000000000000000";
    COMMIT_DATETIME       : std_logic_vector(39 downto 0) := x"0000FE71CE";
    GIT_TAG               : std_logic_vector(127 downto 0) := x"00000000000000000000000000000000";
    GIT_COMMIT_NUMBER     : integer := 0);
  port (
    appreg_clk                          : out    std_logic;
    flush_fifo                          : out    std_logic;
    fromHostFifo_din                    : out    std_logic_vector(255 downto 0);
    fromHostFifo_pfull_threshold_assert : out    std_logic_vector(6 downto 0);
    fromHostFifo_pfull_threshold_negate : out    std_logic_vector(6 downto 0);
    fromHostFifo_prog_full              : in     std_logic;
    fromHostFifo_we                     : out    std_logic;
    fromHostFifo_wr_clk                 : out    std_logic;
    interrupt_call                      : in     std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
    lnk_up                              : out    std_logic;
    pcie_rxn                            : in     std_logic_vector(7 downto 0);
    pcie_rxp                            : in     std_logic_vector(7 downto 0);
    pcie_txn                            : out    std_logic_vector(7 downto 0);
    pcie_txp                            : out    std_logic_vector(7 downto 0);
    pll_locked                          : out    std_logic;
    register_map_control                : out    register_map_control_type;
    register_map_monitor                : in     register_map_monitor_type;
    reset_hard                          : out    std_logic;
    reset_soft                          : out    std_logic;
    sys_clk_n                           : in     std_logic;
    sys_clk_p                           : in     std_logic;
    sys_reset_n                         : in     std_logic;
    toHostFifo_dout                     : in     std_logic_vector(255 downto 0);
    toHostFifo_empty_thresh             : out    std_logic_vector(11 downto 0);
    toHostFifo_pfull_threshold_assert   : out    std_logic_vector(11 downto 0);
    toHostFifo_pfull_threshold_negate   : out    std_logic_vector(11 downto 0);
    toHostFifo_prog_empty               : in     std_logic;
    toHostFifo_rd_clk                   : out    std_logic;
    toHostFifo_re                       : out    std_logic);
end entity wupper;


architecture structure of wupper is

  signal m_axis_r_MM2S              : axis_r_type;
  signal s_axis_r_S2MM              : axis_r_type;
  signal m_axis_r_CNTRL             : axis_r_type;
  signal s_axis_r_STS               : axis_r_type;
  signal cfg_interrupt_msix_sent    : std_logic;
  signal cfg_interrupt_msix_fail    : std_logic;
  signal cfg_interrupt_msix_int     : std_logic;
  signal cfg_interrupt_msix_address : std_logic_vector(63 downto 0);
  signal cfg_interrupt_msix_data    : std_logic_vector(31 downto 0);
  signal cfg_interrupt_msix_enable  : std_logic_vector(3 downto 0);
  signal interrupt_vector           : interrupt_vectors_type(0 to (NUMBER_OF_INTERRUPTS-1));
  signal reset                      : std_logic;
  signal clk                        : std_logic;
  signal bar0                       : std_logic_vector(31 downto 0);
  signal bar1                       : std_logic_vector(31 downto 0);
  signal bar2                       : std_logic_vector(31 downto 0);
  signal cfg_mgmt_addr              : std_logic_vector(18 downto 0);
  signal cfg_mgmt_write_data        : std_logic_vector(31 downto 0);
  signal cfg_mgmt_byte_enable       : std_logic_vector(3 downto 0);
  signal cfg_mgmt_write             : std_logic;
  signal cfg_mgmt_read              : std_logic;
  signal cfg_mgmt_read_write_done   : std_logic;
  signal cfg_mgmt_read_data         : std_logic_vector(31 downto 0);
  signal interrupt_table_en         : std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 0);
  signal clkDiv6                    : std_logic;
  signal dma_interrupt_call         : std_logic_vector(3 downto 0);
  signal m_axis_cq                  : axis_type;
  signal m_axis_cc                  : axis_type;
  signal m_axis_rc                  : axis_type;
  signal m_axis_rq                  : axis_type;
  signal cfg_fc_ph                  : std_logic_vector(7 downto 0);
  signal cfg_fc_pd                  : std_logic_vector(11 downto 0);
  signal cfg_fc_nph                 : std_logic_vector(7 downto 0);
  signal cfg_fc_npd                 : std_logic_vector(11 downto 0);
  signal cfg_fc_cplh                : std_logic_vector(7 downto 0);
  signal cfg_fc_cpld                : std_logic_vector(11 downto 0);
  signal cfg_fc_sel                 : std_logic_vector(2 downto 0);
  signal sys_rst_n                  : std_logic;
  signal lnk_up_net                 : std_logic;

  component pcie_ep_wrap
    generic(
      CARD_TYPE : integer := 709;
      DEVID     : std_logic_vector(15 downto 0) := x"7038");
    port (
      cfg_fc_cpld                : out    std_logic_vector(11 downto 0);
      cfg_fc_cplh                : out    std_logic_vector(7 downto 0);
      cfg_fc_npd                 : out    std_logic_vector(11 downto 0);
      cfg_fc_nph                 : out    std_logic_vector(7 downto 0);
      cfg_fc_pd                  : out    std_logic_vector(11 downto 0);
      cfg_fc_ph                  : out    std_logic_vector(7 downto 0);
      cfg_fc_sel                 : in     std_logic_vector(2 downto 0);
      cfg_interrupt_msix_address : in     std_logic_vector(63 downto 0);
      cfg_interrupt_msix_data    : in     std_logic_vector(31 downto 0);
      cfg_interrupt_msix_enable  : out    std_logic_vector(3 downto 0);
      cfg_interrupt_msix_fail    : out    std_logic;
      cfg_interrupt_msix_int     : in     std_logic;
      cfg_interrupt_msix_sent    : out    std_logic;
      cfg_mgmt_addr              : in     std_logic_vector(18 downto 0);
      cfg_mgmt_byte_enable       : in     std_logic_vector(3 downto 0);
      cfg_mgmt_read              : in     std_logic;
      cfg_mgmt_read_data         : out    std_logic_vector(31 downto 0);
      cfg_mgmt_read_write_done   : out    std_logic;
      cfg_mgmt_write             : in     std_logic;
      cfg_mgmt_write_data        : in     std_logic_vector(31 downto 0);
      clk                        : out    std_logic;
      m_axis_cq                  : out    axis_type;
      m_axis_r_cq                : in     axis_r_type;
      m_axis_r_rc                : in     axis_r_type;
      m_axis_rc                  : out    axis_type;
      pci_exp_rxn                : in     std_logic_vector(7 downto 0);
      pci_exp_rxp                : in     std_logic_vector(7 downto 0);
      pci_exp_txn                : out    std_logic_vector(7 downto 0);
      pci_exp_txp                : out    std_logic_vector(7 downto 0);
      reset                      : out    std_logic;
      s_axis_cc                  : in     axis_type;
      s_axis_r_cc                : out    axis_r_type;
      s_axis_r_rq                : out    axis_r_type;
      s_axis_rq                  : in     axis_type;
      sys_clk_n                  : in     std_logic;
      sys_clk_p                  : in     std_logic;
      sys_rst_n                  : in     std_logic;
      user_lnk_up                : out    std_logic);
  end component pcie_ep_wrap;

  component wupper_core
    generic(
      NUMBER_OF_DESCRIPTORS : integer := 8;
      NUMBER_OF_INTERRUPTS  : integer := 8;
      SVN_VERSION           : integer := 0;
      BUILD_DATETIME        : std_logic_vector(39 downto 0) := x"0000FE71CE";
      CARD_TYPE             : integer := 709;
      REG_MAP_VERSION       : std_logic_vector(15 downto 0) := X"0300";
      GIT_HASH              : std_logic_vector(159 downto 0) := x"0000000000000000000000000000000000000000";
      COMMIT_DATETIME       : std_logic_vector(39 downto 0) := x"0000FE71CE";
      GIT_TAG               : std_logic_vector(127 downto 0) := x"00000000000000000000000000000000";
      GIT_COMMIT_NUMBER     : integer := 0);
    port (
      bar0                            : in     std_logic_vector(31 downto 0);
      bar1                            : in     std_logic_vector(31 downto 0);
      bar2                            : in     std_logic_vector(31 downto 0);
      clk                             : in     std_logic;
      clkDiv6                         : in     std_logic;
      dma_interrupt_call              : out    std_logic_vector(3 downto 0);
      flush_fifo                      : out    std_logic;
      fromHostFifo_din                : out    std_logic_vector(255 downto 0);
      fromHostFifo_prog_full          : in     std_logic;
      fromHostFifo_we                 : out    std_logic;
      fromhost_pfull_threshold_assert : out    std_logic_vector(6 downto 0);
      fromhost_pfull_threshold_negate : out    std_logic_vector(6 downto 0);
      interrupt_table_en              : out    std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 0);
      interrupt_vector                : out    interrupt_vectors_type(0 to (NUMBER_OF_INTERRUPTS-1));
      m_axis_cc                       : out    axis_type;
      m_axis_r_cc                     : in     axis_r_type;
      m_axis_r_rq                     : in     axis_r_type;
      m_axis_rq                       : out    axis_type;
      register_map_control            : out    register_map_control_type;
      register_map_monitor            : in     register_map_monitor_type;
      reset                           : in     std_logic;
      reset_global_soft               : out    std_logic;
      s_axis_cq                       : in     axis_type;
      s_axis_r_cq                     : out    axis_r_type;
      s_axis_r_rc                     : out    axis_r_type;
      s_axis_rc                       : in     axis_type;
      toHostFifo_dout                 : in     std_logic_vector(255 downto 0);
      toHostFifo_empty_thresh         : out    std_logic_vector(11 downto 0);
      toHostFifo_prog_empty           : in     std_logic;
      toHostFifo_re                   : out    std_logic;
      tohost_pfull_threshold_assert   : out    std_logic_vector(11 downto 0);
      tohost_pfull_threshold_negate   : out    std_logic_vector(11 downto 0);
      user_lnk_up                     : in     std_logic);
  end component wupper_core;

  component intr_ctrl
    generic(
      NUMBER_OF_INTERRUPTS : integer := 8);
    port (
      cfg_interrupt_msix_address : out    std_logic_vector(63 downto 0);
      cfg_interrupt_msix_data    : out    std_logic_vector(31 downto 0);
      cfg_interrupt_msix_enable  : in     std_logic_vector(3 downto 0);
      cfg_interrupt_msix_fail    : in     std_logic;
      cfg_interrupt_msix_int     : out    std_logic;
      cfg_interrupt_msix_sent    : in     std_logic;
      clk                        : in     std_logic;
      clkDiv6                    : in     std_logic;
      dma_interrupt_call         : in     std_logic_vector(3 downto 0);
      interrupt_call             : in     std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 4);
      interrupt_table_en         : in     std_logic_vector(NUMBER_OF_INTERRUPTS-1 downto 0);
      interrupt_vector           : in     interrupt_vectors_type(0 to (NUMBER_OF_INTERRUPTS-1));
      reset                      : in     std_logic;
      s_axis_cc                  : in     axis_type;
      s_axis_cq                  : in     axis_type;
      s_axis_rc                  : in     axis_type;
      s_axis_rq                  : in     axis_type);
  end component intr_ctrl;

  component pcie_init
    port (
      bar0                     : out    std_logic_vector(31 downto 0);
      bar1                     : out    std_logic_vector(31 downto 0);
      bar2                     : out    std_logic_vector(31 downto 0);
      cfg_fc_cpld              : in     std_logic_vector(11 downto 0);
      cfg_fc_cplh              : in     std_logic_vector(7 downto 0);
      cfg_fc_npd               : in     std_logic_vector(11 downto 0);
      cfg_fc_nph               : in     std_logic_vector(7 downto 0);
      cfg_fc_pd                : in     std_logic_vector(11 downto 0);
      cfg_fc_ph                : in     std_logic_vector(7 downto 0);
      cfg_fc_sel               : out    std_logic_vector(2 downto 0);
      cfg_mgmt_addr            : out    std_logic_vector(18 downto 0);
      cfg_mgmt_byte_enable     : out    std_logic_vector(3 downto 0);
      cfg_mgmt_read            : out    std_logic;
      cfg_mgmt_read_data       : in     std_logic_vector(31 downto 0);
      cfg_mgmt_read_write_done : in     std_logic;
      cfg_mgmt_write           : out    std_logic;
      cfg_mgmt_write_data      : out    std_logic_vector(31 downto 0);
      clk                      : in     std_logic;
      reset                    : in     std_logic);
  end component pcie_init;

  component pcie_slow_clock
    port (
      clk        : in     std_logic;
      clkDiv6    : out    std_logic;
      pll_locked : out    std_logic;
      reset_n    : in     std_logic;
      reset_out  : out    std_logic);
  end component pcie_slow_clock;

begin
  toHostFifo_rd_clk <= clk;
  fromHostFifo_wr_clk <= clk;
  appreg_clk <= clkDiv6;
  sys_rst_n <= sys_reset_n;
  lnk_up <= lnk_up_net;

  u1: pcie_ep_wrap
    generic map(
      CARD_TYPE => CARD_TYPE,
      DEVID     => DEVID)
    port map(
      cfg_fc_cpld                => cfg_fc_cpld,
      cfg_fc_cplh                => cfg_fc_cplh,
      cfg_fc_npd                 => cfg_fc_npd,
      cfg_fc_nph                 => cfg_fc_nph,
      cfg_fc_pd                  => cfg_fc_pd,
      cfg_fc_ph                  => cfg_fc_ph,
      cfg_fc_sel                 => cfg_fc_sel,
      cfg_interrupt_msix_address => cfg_interrupt_msix_address,
      cfg_interrupt_msix_data    => cfg_interrupt_msix_data,
      cfg_interrupt_msix_enable  => cfg_interrupt_msix_enable,
      cfg_interrupt_msix_fail    => cfg_interrupt_msix_fail,
      cfg_interrupt_msix_int     => cfg_interrupt_msix_int,
      cfg_interrupt_msix_sent    => cfg_interrupt_msix_sent,
      cfg_mgmt_addr              => cfg_mgmt_addr,
      cfg_mgmt_byte_enable       => cfg_mgmt_byte_enable,
      cfg_mgmt_read              => cfg_mgmt_read,
      cfg_mgmt_read_data         => cfg_mgmt_read_data,
      cfg_mgmt_read_write_done   => cfg_mgmt_read_write_done,
      cfg_mgmt_write             => cfg_mgmt_write,
      cfg_mgmt_write_data        => cfg_mgmt_write_data,
      clk                        => clk,
      m_axis_cq                  => m_axis_cq,
      m_axis_r_cq                => s_axis_r_STS,
      m_axis_r_rc                => s_axis_r_S2MM,
      m_axis_rc                  => m_axis_rc,
      pci_exp_rxn                => pcie_rxn,
      pci_exp_rxp                => pcie_rxp,
      pci_exp_txn                => pcie_txn,
      pci_exp_txp                => pcie_txp,
      reset                      => reset,
      s_axis_cc                  => m_axis_cc,
      s_axis_r_cc                => m_axis_r_CNTRL,
      s_axis_r_rq                => m_axis_r_MM2S,
      s_axis_rq                  => m_axis_rq,
      sys_clk_n                  => sys_clk_n,
      sys_clk_p                  => sys_clk_p,
      sys_rst_n                  => sys_rst_n,
      user_lnk_up                => lnk_up_net);

  dma0: wupper_core
    generic map(
      NUMBER_OF_DESCRIPTORS => NUMBER_OF_DESCRIPTORS,
      NUMBER_OF_INTERRUPTS  => NUMBER_OF_INTERRUPTS,
      SVN_VERSION           => SVN_VERSION,
      BUILD_DATETIME        => BUILD_DATETIME,
      CARD_TYPE             => CARD_TYPE,
      REG_MAP_VERSION       => REG_MAP_VERSION,
      GIT_HASH              => GIT_HASH,
      COMMIT_DATETIME       => COMMIT_DATETIME,
      GIT_TAG               => GIT_TAG,
      GIT_COMMIT_NUMBER     => GIT_COMMIT_NUMBER)
    port map(
      bar0                            => bar0,
      bar1                            => bar1,
      bar2                            => bar2,
      clk                             => clk,
      clkDiv6                         => clkDiv6,
      dma_interrupt_call              => dma_interrupt_call,
      flush_fifo                      => flush_fifo,
      fromHostFifo_din                => fromHostFifo_din,
      fromHostFifo_prog_full          => fromHostFifo_prog_full,
      fromHostFifo_we                 => fromHostFifo_we,
      fromhost_pfull_threshold_assert => fromHostFifo_pfull_threshold_assert,
      fromhost_pfull_threshold_negate => fromHostFifo_pfull_threshold_negate,
      interrupt_table_en              => interrupt_table_en,
      interrupt_vector                => interrupt_vector,
      m_axis_cc                       => m_axis_cc,
      m_axis_r_cc                     => m_axis_r_CNTRL,
      m_axis_r_rq                     => m_axis_r_MM2S,
      m_axis_rq                       => m_axis_rq,
      register_map_control            => register_map_control,
      register_map_monitor            => register_map_monitor,
      reset                           => reset,
      reset_global_soft               => reset_soft,
      s_axis_cq                       => m_axis_cq,
      s_axis_r_cq                     => s_axis_r_STS,
      s_axis_r_rc                     => s_axis_r_S2MM,
      s_axis_rc                       => m_axis_rc,
      toHostFifo_dout                 => toHostFifo_dout,
      toHostFifo_empty_thresh         => toHostFifo_empty_thresh,
      toHostFifo_prog_empty           => toHostFifo_prog_empty,
      toHostFifo_re                   => toHostFifo_re,
      tohost_pfull_threshold_assert   => toHostFifo_pfull_threshold_assert,
      tohost_pfull_threshold_negate   => toHostFifo_pfull_threshold_negate,
      user_lnk_up                     => lnk_up_net);

  u2: intr_ctrl
    generic map(
      NUMBER_OF_INTERRUPTS => NUMBER_OF_INTERRUPTS)
    port map(
      cfg_interrupt_msix_address => cfg_interrupt_msix_address,
      cfg_interrupt_msix_data    => cfg_interrupt_msix_data,
      cfg_interrupt_msix_enable  => cfg_interrupt_msix_enable,
      cfg_interrupt_msix_fail    => cfg_interrupt_msix_fail,
      cfg_interrupt_msix_int     => cfg_interrupt_msix_int,
      cfg_interrupt_msix_sent    => cfg_interrupt_msix_sent,
      clk                        => clk,
      clkDiv6                    => clkDiv6,
      dma_interrupt_call         => dma_interrupt_call,
      interrupt_call             => interrupt_call,
      interrupt_table_en         => interrupt_table_en,
      interrupt_vector           => interrupt_vector,
      reset                      => reset,
      s_axis_cc                  => m_axis_cc,
      s_axis_cq                  => m_axis_cq,
      s_axis_rc                  => m_axis_rc,
      s_axis_rq                  => m_axis_rq);

  u0: pcie_init
    port map(
      bar0                     => bar0,
      bar1                     => bar1,
      bar2                     => bar2,
      cfg_fc_cpld              => cfg_fc_cpld,
      cfg_fc_cplh              => cfg_fc_cplh,
      cfg_fc_npd               => cfg_fc_npd,
      cfg_fc_nph               => cfg_fc_nph,
      cfg_fc_pd                => cfg_fc_pd,
      cfg_fc_ph                => cfg_fc_ph,
      cfg_fc_sel               => cfg_fc_sel,
      cfg_mgmt_addr            => cfg_mgmt_addr,
      cfg_mgmt_byte_enable     => cfg_mgmt_byte_enable,
      cfg_mgmt_read            => cfg_mgmt_read,
      cfg_mgmt_read_data       => cfg_mgmt_read_data,
      cfg_mgmt_read_write_done => cfg_mgmt_read_write_done,
      cfg_mgmt_write           => cfg_mgmt_write,
      cfg_mgmt_write_data      => cfg_mgmt_write_data,
      clk                      => clk,
      reset                    => reset);

  u3: pcie_slow_clock
    port map(
      clk        => clk,
      clkDiv6    => clkDiv6,
      pll_locked => pll_locked,
      reset_n    => sys_rst_n,
      reset_out  => reset_hard);
end architecture structure ; -- of wupper

