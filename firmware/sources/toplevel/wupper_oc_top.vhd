
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



library ieee, UNISIM, xpm;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use xpm.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity wupper_oc_top is
  generic(
    NUMBER_OF_INTERRUPTS  : integer := 8;
    NUMBER_OF_DESCRIPTORS : integer := 2;
    CARD_TYPE             : integer := 709;
    BUILD_DATETIME        : std_logic_vector(39 downto 0) := x"0000FE71CE";
    GIT_HASH              : std_logic_vector(159 downto 0) := x"0000000000000000000000000000000000000000";
    COMMIT_DATETIME       : std_logic_vector(39 downto 0) := x"0000FE71CE";
    GIT_TAG               : std_logic_vector(127 downto 0) := x"00000000000000000000000000000000";
    GIT_COMMIT_NUMBER     : integer := 0;
    PCIE_LANES            : integer := 8;
    DATA_WIDTH            : integer := 512;
    ENDPOINTS             : integer := 1;
    NUM_LEDS              : integer := 8);
  port (
    leds        : out    std_logic_vector(NUM_LEDS-1 downto 0); --! 8 status leds
    pcie_rxn    : in     std_logic_vector((ENDPOINTS*PCIE_LANES)-1 downto 0);
    pcie_rxp    : in     std_logic_vector((ENDPOINTS*PCIE_LANES)-1 downto 0);
    pcie_txn    : out    std_logic_vector((ENDPOINTS*PCIE_LANES)-1 downto 0);
    pcie_txp    : out    std_logic_vector((ENDPOINTS*PCIE_LANES)-1 downto 0); --! PCIe link lanes
    sys_clk_n   : in     std_logic_vector(ENDPOINTS-1 downto 0);
    sys_clk_p   : in     std_logic_vector(ENDPOINTS-1 downto 0);--; --! 100MHz PCIe reference clock
    emcclk      : in     std_logic; --! emcclk is part of the JTAG high speed programming.
    sys_reset_n : in     std_logic; --! Active-low system reset from PCIe interface
    SCL         : inout  std_logic; --! I2C port
    SDA         : inout  std_logic; --! I2C port
    i2cmux_rst  : out    std_logic --! I2C port
  );
end entity wupper_oc_top;


architecture structure of wupper_oc_top is
  signal leds_s                              : std_logic_vector(ENDPOINTS*8-1 downto 0);
  signal pll_locked                          : std_logic; -- @suppress "signal pll_locked is never read"
  signal appreg_clk                          : std_logic; 
  signal register_map_hk_monitor : register_map_hk_monitor_type; -- @suppress "signal register_map_hk_monitor is never written"
  signal register_map_gen_board_info : register_map_gen_board_info_type; -- @suppress "signal register_map_gen_board_info is never written"
  signal register_map_control             : register_map_control_type; --! contains all read/write registers that control the application. The record members are described in pcie_package.vhd -- @suppress "signal register_map_control is never read"
  signal reset_soft : std_logic; -- @suppress "signal reset_soft is never read"
  signal reset_hard : std_logic; 
  signal lnk_up : std_logic_vector(1 downto 0); -- @suppress "signal lnk_up is never read"
  signal RXUSRCLK : std_logic_vector(24*ENDPOINTS-1 downto 0);
  signal versal_sys_reset_n : std_logic;
  signal wupper_sys_reset_n : std_logic;
  signal emcclk_s: std_logic;
  
  attribute DONT_TOUCH: string;
  attribute DONT_TOUCH of emcclk_s: signal is "TRUE";

begin

  hk0: entity work.housekeeping_module
    generic map (
      CARD_TYPE => CARD_TYPE,
      ENDPOINTS => ENDPOINTS
    )
    port map(
      SCL => SCL,
      SDA => SDA,
      appreg_clk => appreg_clk,
      i2cmux_rst => i2cmux_rst,
      register_map_control => register_map_control,
      register_map_gen_board_info => register_map_gen_board_info,
      register_map_hk_monitor => register_map_hk_monitor,
      rst_soft => reset_soft,
      rst_hw => reset_hard,
      versal_sys_reset_n_out => versal_sys_reset_n
    );
g_Versal: if CARD_TYPE = 180 generate
    wupper_sys_reset_n <= '1'; --Reset from versal BD is broken, don't reset. versal_sys_reset_n; --Through MIO pins
end generate;
g_noVersal: if CARD_TYPE /= 180 generate
    wupper_sys_reset_n <= sys_reset_n; --Directly connect to PCIe finger / sys_reset / PERSTn
end generate;
    

g_endpoints: for i in 0 to ENDPOINTS-1 generate
  signal ep_register_map_control             : register_map_control_type; --! contains all read/write registers that control the application. The record members are described in pcie_package.vhd
  signal register_map_control_appreg_clk : register_map_control_type; -- @suppress "signal register_map_control_appreg_clk is never read"
  signal wishbone_monitor : wishbone_monitor_type; -- @suppress "signal wishbone_monitor is never written"
  signal reset_soft_appreg_clk : std_logic; -- @suppress "signal reset_soft_appreg_clk is never read"
  
  signal ep_reset_soft                       : std_logic;
  signal ep_reset_hard                       : std_logic;
  signal fromHostFifo_dout                   : std_logic_vector(DATA_WIDTH-1 downto 0); -- @suppress "signal fromHostFifo_dout is never read"
  signal fromHostFifo_rd_en                  : std_logic;
  signal fromHostFifo_empty                  : std_logic;
  signal fromHostFifo_rd_clk                 : std_logic;
  signal fromHostFifo_rst                    : std_logic;
  signal fromHostFifo_dvalid                 : std_logic;
  signal toHostFifo_wr_clk                   : std_logic;
  signal toHostFifo_rst                      : std_logic;
  
  signal ep_appreg_clk: std_logic;
  signal ep_pll_locked: std_logic; -- @suppress "signal ep_pll_locked is never read"
  
  signal toHostFifo_din : slv_array(0 to NUMBER_OF_DESCRIPTORS-2);
  signal toHostFifo_prog_full : std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
  signal wr_data_count : slv12_array(0 to NUMBER_OF_DESCRIPTORS-2); -- @suppress "signal wr_data_count is never read"
  signal toHostFifo_wr_en : std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
  signal clk250: std_logic;
  signal rst_hw : std_logic;
  signal fromHostFifoDataCount: std_logic_vector(31 downto 0);
  signal LOOPBACK_250: std_logic_vector(NUMBER_OF_DESCRIPTORS-2 downto 0);
  
begin

  g_ep0: if i = 0 generate
    register_map_control <= ep_register_map_control;
    reset_soft <= ep_reset_soft;
    reset_hard <= ep_reset_hard;
    appreg_clk <= ep_appreg_clk;
    pll_locked <= ep_pll_locked;
  end generate;
  
  --! Instantiation of the actual PCI express core. Please note the 40MHz
  --! clock required by the core, the 250MHz clock (fifo_rd_clk and fifo_wr_clk) 
  --! are generated from sys_clk_p and _n
  pcie0: entity work.wupper
    generic map(
      NUMBER_OF_INTERRUPTS => NUMBER_OF_INTERRUPTS,
      NUMBER_OF_DESCRIPTORS => NUMBER_OF_DESCRIPTORS,
      BUILD_DATETIME => BUILD_DATETIME,
      CARD_TYPE => CARD_TYPE,
      GIT_HASH => GIT_HASH,
      COMMIT_DATETIME => COMMIT_DATETIME,
      GIT_TAG => GIT_TAG,
      GIT_COMMIT_NUMBER => GIT_COMMIT_NUMBER,
      PCIE_ENDPOINT => i,
      PCIE_LANES => PCIE_LANES,
      DATA_WIDTH => DATA_WIDTH,
      SIMULATION => false)
    port map(
      appreg_clk => ep_appreg_clk,
      sync_clk => ep_appreg_clk,
      flush_fifo => open,
      interrupt_call => (others => '0'),
      lnk_up => lnk_up(i),
      pcie_rxn => pcie_rxn(PCIE_LANES*i+(PCIE_LANES-1) downto PCIE_LANES*i),
      pcie_rxp => pcie_rxp(PCIE_LANES*i+(PCIE_LANES-1) downto PCIE_LANES*i),
      pcie_txn => pcie_txn(PCIE_LANES*i+(PCIE_LANES-1) downto PCIE_LANES*i),
      pcie_txp => pcie_txp(PCIE_LANES*i+(PCIE_LANES-1) downto PCIE_LANES*i),
      pll_locked => ep_pll_locked,
      register_map_control_sync => ep_register_map_control,
      register_map_control_appreg_clk => register_map_control_appreg_clk,
      register_map_gen_board_info => register_map_gen_board_info,
      register_map_hk_monitor => register_map_hk_monitor,
      wishbone_monitor => wishbone_monitor,
      reset_hard => ep_reset_hard,
      reset_soft => ep_reset_soft,
      reset_soft_appreg_clk => reset_soft_appreg_clk,
      reset_hw_in => rst_hw,
      sys_clk_n => sys_clk_n(i),
      sys_clk_p => sys_clk_p(i),
      sys_reset_n => wupper_sys_reset_n, --versal_sys_reset_n,
      tohost_busy_out => open,
      fromHostFifo_dout => fromHostFifo_dout,
      fromHostFifo_empty => fromHostFifo_empty,
      fromHostFifo_rd_clk => fromHostFifo_rd_clk,
      fromHostFifo_rd_en => fromHostFifo_rd_en,
      fromHostFifo_rst => fromHostFifo_rst,
      toHostFifo_din => toHostFifo_din,
      toHostFifo_prog_full => toHostFifo_prog_full,
      toHostFifo_rst => toHostFifo_rst,
      toHostFifo_wr_clk => toHostFifo_wr_clk,
      wr_data_count => wr_data_count,
      toHostFifo_wr_en => toHostFifo_wr_en,
      clk250_out => clk250,
      master_busy_in => '0');
      
      
      toHostFifo_wr_clk <= clk250;
      fromHostFifo_rd_clk <= clk250;
      toHostFifo_rst <= ep_reset_soft or ep_reset_hard;
      fromHostFifo_rst <= ep_reset_soft or ep_reset_hard;
      
      fromHostFifo_rd_en <= not fromHostFifo_empty;
      
      rst_hw <= ep_reset_hard;
      leds_s(8*i+7 downto 8*i) <= ep_register_map_control.STATUS_LEDS;
      
      fromHostFifo_dvalid_proc: process(clk250)
      begin
        if rising_edge(clk250) then
            if fromHostFifo_rst = '1' then
                fromHostFifo_dvalid <= '0';
                fromHostFifoDataCount <= (others => '0');
            else
                fromHostFifo_dvalid <= fromHostFifo_rd_en;
                if fromHostFifo_rd_en = '1' then
                    fromHostFifoDataCount <= fromHostFifoDataCount + 1;
                end if;
            end if;
        end if;
      end process;
      
      xpm_cdc_array_single_inst : xpm_cdc_array_single
       generic map (
          DEST_SYNC_FF => 2,
          INIT_SYNC_FF => 0,
          SIM_ASSERT_CHK => 0,
          SRC_INPUT_REG => 0,
          WIDTH => NUMBER_OF_DESCRIPTORS-1
       )
       port map (
          dest_out => LOOPBACK_250,
          dest_clk => clk250,
          src_clk => '0',
          src_in => ep_register_map_control.LOOPBACK(NUMBER_OF_DESCRIPTORS-2 downto 0)
       );
    
      
      g_descr: for descr in 0 to NUMBER_OF_DESCRIPTORS-2 generate
      
        signal cnt: std_logic_vector(63 downto 0);
        signal out_data: std_logic_vector(DATA_WIDTH-1 downto 0);
      begin
          
          
          cnt_combine : for i in 0 to (DATA_WIDTH/cnt'length)-1 generate
            out_data((cnt'length*(i+1))-1 downto cnt'length*i) <= cnt;
          end generate;

          cntProc: process(clk250)
          begin
            if rising_edge(clk250) then
                if ep_reset_soft = '1' then
                    cnt <= (others => '0');
                else
                    if toHostFifo_prog_full(descr) = '0' then
                        cnt <= cnt + 1;
                    end if;
                end if;
            end if;
          end process;
          toHostFifo_wr_en(descr) <= (not toHostFifo_prog_full(descr)) when LOOPBACK_250(i) = '0' else fromHostFifo_dvalid;
          toHostFifo_din(descr) <= out_data when LOOPBACK_250(i) = '0' else fromHostFifo_dout;
          
          end generate;
          
          wb0: entity work.wb_intercon
            port map(
              control_in              => ep_register_map_control,
              monitor_out             => wishbone_monitor,     
              wupper_clk_i            => ep_appreg_clk,
              rst_soft_i              => ep_reset_soft,
              rst_hard_i              => ep_reset_hard);  
         
end generate; --g_endpoints

leds <=  leds_s(NUM_LEDS-1 downto 0);

emcclk_ibuf: IBUF port map(I => emcclk, O => emcclk_s);
            
end architecture structure ; -- of wupper_oc_top

