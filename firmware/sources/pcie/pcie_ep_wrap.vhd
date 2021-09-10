--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_ep_wrap
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
--! Wrapper unit for the PCI Express core, and the clock generator 
--!
--! Notes:
--! 05/17/2019 F. Schreuder <f.schreuder@nikhef.nl> 
--!          Updates for Vivado 2018.1
--!
--! 11/19/2015 B. Kuschak <brian@skybox.com> 
--!          Modifications for KCU105.
--!          See Xilinx AR 50579.  Only one bit for tready signsls.
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
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; -- @suppress "Deprecated package"
use work.pcie_package.all;
--library std;
--use std.env.all;
entity pcie_ep_wrap is
    generic(
        CARD_TYPE : integer := 800;
        PCIE_ENDPOINT     : integer := 0; --in dual endpoint mode, there may be a different Devid assigned to the second endpoint
        PCIE_LANES: integer;
        DATA_WIDTH: integer;
        SIMULATION: boolean:=false;
        NUMBER_OF_DESCRIPTORS: integer --For simulation model only
    );
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
        pci_exp_rxn                : in     std_logic_vector(PCIE_LANES-1 downto 0);
        pci_exp_rxp                : in     std_logic_vector(PCIE_LANES-1 downto 0);
        pci_exp_txn                : out    std_logic_vector(PCIE_LANES-1 downto 0);
        pci_exp_txp                : out    std_logic_vector(PCIE_LANES-1 downto 0);
        reset                      : out    std_logic;
        s_axis_cc                  : in     axis_type;
        s_axis_r_cc                : out    axis_r_type;
        s_axis_r_rq                : out    axis_r_type;
        s_axis_rq                  : in     axis_type;
        sys_clk_n                  : in     std_logic;
        sys_clk_p                  : in     std_logic;
        sys_rst_n                  : in     std_logic;
        user_lnk_up                : out    std_logic);
end entity pcie_ep_wrap;



architecture structure of pcie_ep_wrap is

    signal m_axis_cq_s                  :     axis_type;
    signal m_axis_rc_s                  :     axis_type;

    signal s_axis_rq_tready : std_logic_vector(3 downto 0);
    signal s_axis_cc_tready : std_logic_vector(3 downto 0);
    signal s_axis_rq_tuser: std_logic_vector(136 downto 0);
    --signal m_axis_rc_tready : std_logic_vector(21 downto 0);
    --signal m_axis_cq_tready : std_logic_vector(21 downto 0);
  

type devid_array is array(0 to 1) of std_logic_vector(15 downto 0);
    constant DEVICE_ID : devid_array := (x"0427", x"0428");
    signal cfg_err_cor_out       : std_logic_vector(0 downto 0);
    signal cfg_err_nonfatal_out  : std_logic_vector(0 downto 0);
    signal cfg_err_fatal_out     : std_logic_vector(0 downto 0);
    signal cfg_local_error_valid : std_logic_vector(0 downto 0);
    signal cfg_local_error_out   : std_logic_vector(4 downto 0);
    signal cfg_ltssm_state       : std_logic_vector(5 downto 0);
    signal cfg_rx_pm_state       : std_logic_vector(1 downto 0);
    signal cfg_tx_pm_state       : std_logic_vector(1 downto 0);
    signal cfg_rcb_status        : std_logic_vector(3 downto 0);
    signal cfg_obff_enable       : std_logic_vector(1 downto 0);
  

  signal s_cfg_interrupt_msix_sent : std_logic;
    signal s_cfg_interrupt_msix_fail : std_logic;
    signal monitor_cfg_interrupt_msix_sent : std_logic; -- @suppress "signal monitor_cfg_interrupt_msix_sent is never read"
    signal monitor_cfg_interrupt_msix_fail : std_logic; -- @suppress "signal monitor_cfg_interrupt_msix_fail is never read"
    attribute dont_touch : string;
    attribute dont_touch of monitor_cfg_interrupt_msix_sent : signal is "true";
    attribute dont_touch of monitor_cfg_interrupt_msix_fail : signal is "true";
  
  
  component pcie_clocking
      generic(
          PCIE_ASYNC_EN       : string;
          PCIE_CLK_SHARING_EN : string;
          PCIE_LANE           : integer;
          PCIE_LINK_SPEED     : integer;
          PCIE_REFCLK_FREQ    : integer;
          PCIE_USERCLK1_FREQ  : integer;
          PCIE_USERCLK2_FREQ  : integer;
          PCIE_OOBCLK_MODE    : integer;
          PCIE_DEBUG_MODE     : integer
      );
      port(
          CLK_TXOUTCLK       : in  std_logic;
          CLK_RXOUTCLK_IN    : in  std_logic_vector(PCIE_LANE - 1 downto 0);
          CLK_RST_N          : in  std_logic;
          CLK_PCLK_SEL       : in  std_logic_vector(PCIE_LANE - 1 downto 0);
          CLK_PCLK_SEL_SLAVE : in  std_logic_vector(PCIE_LANE - 1 downto 0);
          CLK_PCLK           : out std_logic;
          CLK_PCLK_SLAVE     : out std_logic;
          CLK_RXUSRCLK       : out std_logic;
          CLK_RXOUTCLK_OUT   : out std_logic_vector(PCIE_LANE - 1 downto 0);
          CLK_DCLK           : out std_logic;
          CLK_OOBCLK         : out std_logic;
          CLK_USERCLK1       : out std_logic;
          CLK_USERCLK2       : out std_logic;
          CLK_MMCM_LOCK      : out std_logic
      );
  end component pcie_clocking;

    COMPONENT pcie_x8_gen3_3_0 -- @suppress "Component declaration is not equal to its matching entity"
        PORT (
            pci_exp_txn : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pci_exp_txp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pci_exp_rxn : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            pci_exp_rxp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            pipe_pclk_in : IN STD_LOGIC;
            pipe_rxusrclk_in : IN STD_LOGIC;
            pipe_rxoutclk_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            pipe_dclk_in : IN STD_LOGIC;
            pipe_userclk1_in : IN STD_LOGIC;
            pipe_userclk2_in : IN STD_LOGIC;
            pipe_oobclk_in : IN STD_LOGIC;
            pipe_mmcm_lock_in : IN STD_LOGIC;
            pipe_txoutclk_out : OUT STD_LOGIC;
            pipe_rxoutclk_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pipe_pclk_sel_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pipe_gen3_out : OUT STD_LOGIC;
            pipe_mmcm_rst_n : IN STD_LOGIC;
            mmcm_lock : OUT STD_LOGIC;
            user_clk : OUT STD_LOGIC;
            user_reset : OUT STD_LOGIC;
            user_lnk_up : OUT STD_LOGIC;
            user_app_rdy : OUT STD_LOGIC;
            s_axis_rq_tlast : IN STD_LOGIC;
            s_axis_rq_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
            s_axis_rq_tuser : IN STD_LOGIC_VECTOR(59 DOWNTO 0);
            s_axis_rq_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_rq_tvalid : IN STD_LOGIC;
            m_axis_rc_tdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
            m_axis_rc_tuser : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
            m_axis_rc_tlast : OUT STD_LOGIC;
            m_axis_rc_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            m_axis_rc_tvalid : OUT STD_LOGIC;
            m_axis_rc_tready : IN STD_LOGIC;
            m_axis_cq_tdata : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
            m_axis_cq_tuser : OUT STD_LOGIC_VECTOR(84 DOWNTO 0);
            m_axis_cq_tlast : OUT STD_LOGIC;
            m_axis_cq_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            m_axis_cq_tvalid : OUT STD_LOGIC;
            m_axis_cq_tready : IN STD_LOGIC;
            s_axis_cc_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
            s_axis_cc_tuser : IN STD_LOGIC_VECTOR(32 DOWNTO 0);
            s_axis_cc_tlast : IN STD_LOGIC;
            s_axis_cc_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            s_axis_cc_tvalid : IN STD_LOGIC;
            s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_rq_seq_num : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_rq_seq_num_vld : OUT STD_LOGIC;
            pcie_rq_tag : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            pcie_rq_tag_vld : OUT STD_LOGIC;
            pcie_tfc_nph_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            pcie_tfc_npd_av : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            pcie_cq_np_req : IN STD_LOGIC;
            pcie_cq_np_req_count : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_phy_link_down : OUT STD_LOGIC;
            cfg_phy_link_status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_negotiated_width : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_current_speed : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_max_payload : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_max_read_req : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_function_status : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_function_power_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_vf_status : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_vf_power_state : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
            cfg_link_power_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_mgmt_addr : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
            cfg_mgmt_write : IN STD_LOGIC;
            cfg_mgmt_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_mgmt_byte_enable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_mgmt_read : IN STD_LOGIC;
            cfg_mgmt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_mgmt_read_write_done : OUT STD_LOGIC;
            cfg_mgmt_type1_cfg_reg_access : IN STD_LOGIC;
            cfg_err_cor_out : OUT STD_LOGIC;
            cfg_err_nonfatal_out : OUT STD_LOGIC;
            cfg_err_fatal_out : OUT STD_LOGIC;
            cfg_ltr_enable : OUT STD_LOGIC;
            cfg_ltssm_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_rcb_status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_dpa_substate_change : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_obff_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_pl_status_change : OUT STD_LOGIC;
            cfg_tph_requester_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_tph_st_mode : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_vf_tph_requester_enable : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_vf_tph_st_mode : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
            cfg_msg_received : OUT STD_LOGIC;
            cfg_msg_received_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_msg_received_type : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_msg_transmit : IN STD_LOGIC;
            cfg_msg_transmit_type : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_msg_transmit_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_msg_transmit_done : OUT STD_LOGIC;
            cfg_fc_ph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_pd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_nph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_npd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_per_func_status_control : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_per_func_status_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_per_function_number : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_per_function_output_request : IN STD_LOGIC;
            cfg_per_function_update_done : OUT STD_LOGIC;
            cfg_subsys_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_dsn : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            cfg_power_state_change_ack : IN STD_LOGIC;
            cfg_power_state_change_interrupt : OUT STD_LOGIC;
            cfg_err_cor_in : IN STD_LOGIC;
            cfg_err_uncor_in : IN STD_LOGIC;
            cfg_flr_in_process : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_flr_done : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_vf_flr_in_process : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_vf_flr_done : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_link_training_enable : IN STD_LOGIC;
            cfg_interrupt_int : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_pending : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_interrupt_sent : OUT STD_LOGIC;
            cfg_interrupt_msix_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_interrupt_msix_mask : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_interrupt_msix_vf_enable : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_interrupt_msix_vf_mask : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_interrupt_msix_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_interrupt_msix_address : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            cfg_interrupt_msix_int : IN STD_LOGIC;
            cfg_interrupt_msix_sent : OUT STD_LOGIC;
            cfg_interrupt_msix_fail : OUT STD_LOGIC;
            cfg_interrupt_msi_function_number : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_hot_reset_out : OUT STD_LOGIC;
            cfg_config_space_enable : IN STD_LOGIC;
            cfg_req_pm_transition_l23_ready : IN STD_LOGIC;
            cfg_hot_reset_in : IN STD_LOGIC;
            cfg_ds_port_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_ds_bus_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_ds_device_number : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_ds_function_number : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            sys_clk : IN STD_LOGIC;
            sys_reset : IN STD_LOGIC
        );
    END COMPONENT;


    -- UltraScale Architecture Gen3 Integrated Block for PCI Express v4.1
    COMPONENT pcie3_ultrascale_7038  -- @suppress "Component declaration 'pcie3_ultrascale_7038' has none or multiple matching entity declarations" -- @suppress "Component declaration is not equal to its matching entity"
        PORT (
            pci_exp_txn : OUT std_logic_vector(7 DOWNTO 0);
            pci_exp_txp : OUT std_logic_vector(7 DOWNTO 0);
            pci_exp_rxn : IN std_logic_vector(7 DOWNTO 0);
            pci_exp_rxp : IN std_logic_vector(7 DOWNTO 0);
            user_clk : OUT std_logic;
            user_reset : OUT std_logic;
            user_lnk_up : OUT std_logic;
            s_axis_rq_tdata : IN std_logic_vector(255 DOWNTO 0);
            s_axis_rq_tkeep : IN std_logic_vector(7 DOWNTO 0);
            s_axis_rq_tlast : IN std_logic;
            s_axis_rq_tready : OUT std_logic_vector(3 DOWNTO 0);
            s_axis_rq_tuser : IN std_logic_vector(59 DOWNTO 0);
            s_axis_rq_tvalid : IN std_logic;
            m_axis_rc_tdata : OUT std_logic_vector(255 DOWNTO 0);
            m_axis_rc_tkeep : OUT std_logic_vector(7 DOWNTO 0);
            m_axis_rc_tlast : OUT std_logic;
            m_axis_rc_tready : IN std_logic;
            m_axis_rc_tuser : OUT std_logic_vector(74 DOWNTO 0);
            m_axis_rc_tvalid : OUT std_logic;
            m_axis_cq_tdata : OUT std_logic_vector(255 DOWNTO 0);
            m_axis_cq_tkeep : OUT std_logic_vector(7 DOWNTO 0);
            m_axis_cq_tlast : OUT std_logic;
            m_axis_cq_tready : IN std_logic;
            m_axis_cq_tuser : OUT std_logic_vector(84 DOWNTO 0);
            m_axis_cq_tvalid : OUT std_logic;
            s_axis_cc_tdata : IN std_logic_vector(255 DOWNTO 0);
            s_axis_cc_tkeep : IN std_logic_vector(7 DOWNTO 0);
            s_axis_cc_tlast : IN std_logic;
            s_axis_cc_tready : OUT std_logic_vector(3 DOWNTO 0);
            s_axis_cc_tuser : IN std_logic_vector(32 DOWNTO 0);
            s_axis_cc_tvalid : IN std_logic;
            pcie_rq_seq_num : OUT std_logic_vector(3 DOWNTO 0);
            pcie_rq_seq_num_vld : OUT std_logic;
            pcie_rq_tag : OUT std_logic_vector(5 DOWNTO 0);
            pcie_rq_tag_av : OUT std_logic_vector(1 DOWNTO 0);
            pcie_rq_tag_vld : OUT std_logic;
            pcie_tfc_nph_av : OUT std_logic_vector(1 DOWNTO 0);
            pcie_tfc_npd_av : OUT std_logic_vector(1 DOWNTO 0);
            pcie_cq_np_req : IN std_logic;
            pcie_cq_np_req_count : OUT std_logic_vector(5 DOWNTO 0);
            cfg_phy_link_down : OUT std_logic;
            cfg_phy_link_status : OUT std_logic_vector(1 DOWNTO 0);
            cfg_negotiated_width : OUT std_logic_vector(3 DOWNTO 0);
            cfg_current_speed : OUT std_logic_vector(2 DOWNTO 0);
            cfg_max_payload : OUT std_logic_vector(2 DOWNTO 0);
            cfg_max_read_req : OUT std_logic_vector(2 DOWNTO 0);
            cfg_function_status : OUT std_logic_vector(15 DOWNTO 0);
            cfg_function_power_state : OUT std_logic_vector(11 DOWNTO 0);
            cfg_vf_status : OUT std_logic_vector(15 DOWNTO 0);
            cfg_vf_power_state : OUT std_logic_vector(23 DOWNTO 0);
            cfg_link_power_state : OUT std_logic_vector(1 DOWNTO 0);
            cfg_mgmt_addr : IN std_logic_vector(18 DOWNTO 0);
            cfg_mgmt_write : IN std_logic;
            cfg_mgmt_write_data : IN std_logic_vector(31 DOWNTO 0);
            cfg_mgmt_byte_enable : IN std_logic_vector(3 DOWNTO 0);
            cfg_mgmt_read : IN std_logic;
            cfg_mgmt_read_data : OUT std_logic_vector(31 DOWNTO 0);
            cfg_mgmt_read_write_done : OUT std_logic;
            cfg_mgmt_type1_cfg_reg_access : IN std_logic;
            cfg_err_cor_out : OUT std_logic;
            cfg_err_nonfatal_out : OUT std_logic;
            cfg_err_fatal_out : OUT std_logic;
            cfg_local_error : OUT std_logic;
            cfg_ltr_enable : OUT std_logic;
            cfg_ltssm_state : OUT std_logic_vector(5 DOWNTO 0);
            cfg_rcb_status : OUT std_logic_vector(3 DOWNTO 0);
            cfg_dpa_substate_change : OUT std_logic_vector(3 DOWNTO 0);
            cfg_obff_enable : OUT std_logic_vector(1 DOWNTO 0);
            cfg_pl_status_change : OUT std_logic;
            cfg_tph_requester_enable : OUT std_logic_vector(3 DOWNTO 0);
            cfg_tph_st_mode : OUT std_logic_vector(11 DOWNTO 0);
            cfg_vf_tph_requester_enable : OUT std_logic_vector(7 DOWNTO 0);
            cfg_vf_tph_st_mode : OUT std_logic_vector(23 DOWNTO 0);
            cfg_msg_received : OUT std_logic;
            cfg_msg_received_data : OUT std_logic_vector(7 DOWNTO 0);
            cfg_msg_received_type : OUT std_logic_vector(4 DOWNTO 0);
            cfg_msg_transmit : IN std_logic;
            cfg_msg_transmit_type : IN std_logic_vector(2 DOWNTO 0);
            cfg_msg_transmit_data : IN std_logic_vector(31 DOWNTO 0);
            cfg_msg_transmit_done : OUT std_logic;
            cfg_fc_ph : OUT std_logic_vector(7 DOWNTO 0);
            cfg_fc_pd : OUT std_logic_vector(11 DOWNTO 0);
            cfg_fc_nph : OUT std_logic_vector(7 DOWNTO 0);
            cfg_fc_npd : OUT std_logic_vector(11 DOWNTO 0);
            cfg_fc_cplh : OUT std_logic_vector(7 DOWNTO 0);
            cfg_fc_cpld : OUT std_logic_vector(11 DOWNTO 0);
            cfg_fc_sel : IN std_logic_vector(2 DOWNTO 0);
            cfg_per_func_status_control : IN std_logic_vector(2 DOWNTO 0);
            cfg_per_func_status_data : OUT std_logic_vector(15 DOWNTO 0);
            cfg_per_function_number : IN std_logic_vector(3 DOWNTO 0);
            cfg_per_function_output_request : IN std_logic;
            cfg_per_function_update_done : OUT std_logic;
            cfg_dsn : IN std_logic_vector(63 DOWNTO 0);
            cfg_power_state_change_ack : IN std_logic;
            cfg_power_state_change_interrupt : OUT std_logic;
            cfg_err_cor_in : IN std_logic;
            cfg_err_uncor_in : IN std_logic;
            cfg_flr_in_process : OUT std_logic_vector(3 DOWNTO 0);
            cfg_flr_done : IN std_logic_vector(3 DOWNTO 0);
            cfg_vf_flr_in_process : OUT std_logic_vector(7 DOWNTO 0);
            cfg_vf_flr_done : IN std_logic_vector(7 DOWNTO 0);
            cfg_link_training_enable : IN std_logic;
            --        cfg_ext_read_received : OUT std_logic;
            --        cfg_ext_write_received : OUT std_logic;
            --        cfg_ext_register_number : OUT std_logic_vector(9 DOWNTO 0);
            --        cfg_ext_function_number : OUT std_logic_vector(7 DOWNTO 0);
            --        cfg_ext_write_data : OUT std_logic_vector(31 DOWNTO 0);
            --        cfg_ext_write_byte_enable : OUT std_logic_vector(3 DOWNTO 0);
            --        cfg_ext_read_data : IN std_logic_vector(31 DOWNTO 0);
            --        cfg_ext_read_data_valid : IN std_logic;
            cfg_interrupt_int : IN std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_pending : IN std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_sent : OUT std_logic;
            cfg_interrupt_msi_function_number : IN std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_msix_enable : OUT std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_msix_mask : OUT std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_msix_vf_enable : OUT std_logic_vector(7 DOWNTO 0);
            cfg_interrupt_msix_vf_mask : OUT std_logic_vector(7 DOWNTO 0);
            cfg_interrupt_msix_data : IN std_logic_vector(31 DOWNTO 0);
            cfg_interrupt_msix_address : IN std_logic_vector(63 DOWNTO 0);
            cfg_interrupt_msix_int : IN std_logic;
            cfg_interrupt_msix_sent : OUT std_logic;
            cfg_interrupt_msix_fail : OUT std_logic;
            cfg_hot_reset_out : OUT std_logic;
            cfg_config_space_enable : IN std_logic;
            cfg_req_pm_transition_l23_ready : IN std_logic;
            cfg_hot_reset_in : IN std_logic;
            cfg_ds_port_number : IN std_logic_vector(7 DOWNTO 0);
            cfg_ds_bus_number : IN std_logic_vector(7 DOWNTO 0);
            cfg_ds_device_number : IN std_logic_vector(4 DOWNTO 0);
            cfg_ds_function_number : IN std_logic_vector(2 DOWNTO 0);
            cfg_subsys_vend_id : IN std_logic_vector(15 DOWNTO 0);
            sys_clk : IN std_logic;
            sys_clk_gt : IN std_logic;
            sys_reset : IN std_logic;
            int_qpll1lock_out : OUT std_logic_vector(1 DOWNTO 0);
            int_qpll1outrefclk_out : OUT std_logic_vector(1 DOWNTO 0);
            int_qpll1outclk_out : OUT std_logic_vector(1 DOWNTO 0);
            phy_rdy_out : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT pcie3_ultrascale_7039 -- @suppress "Component declaration 'pcie3_ultrascale_7039' has none or multiple matching entity declarations"
        PORT (
            pci_exp_txn : OUT std_logic_vector(7 DOWNTO 0);
            pci_exp_txp : OUT std_logic_vector(7 DOWNTO 0);
            pci_exp_rxn : IN std_logic_vector(7 DOWNTO 0);
            pci_exp_rxp : IN std_logic_vector(7 DOWNTO 0);
            user_clk : OUT std_logic;
            user_reset : OUT std_logic;
            user_lnk_up : OUT std_logic;
            s_axis_rq_tdata : IN std_logic_vector(255 DOWNTO 0);
            s_axis_rq_tkeep : IN std_logic_vector(7 DOWNTO 0);
            s_axis_rq_tlast : IN std_logic;
            s_axis_rq_tready : OUT std_logic_vector(3 DOWNTO 0);
            s_axis_rq_tuser : IN std_logic_vector(59 DOWNTO 0);
            s_axis_rq_tvalid : IN std_logic;
            m_axis_rc_tdata : OUT std_logic_vector(255 DOWNTO 0);
            m_axis_rc_tkeep : OUT std_logic_vector(7 DOWNTO 0);
            m_axis_rc_tlast : OUT std_logic;
            m_axis_rc_tready : IN std_logic;
            m_axis_rc_tuser : OUT std_logic_vector(74 DOWNTO 0);
            m_axis_rc_tvalid : OUT std_logic;
            m_axis_cq_tdata : OUT std_logic_vector(255 DOWNTO 0);
            m_axis_cq_tkeep : OUT std_logic_vector(7 DOWNTO 0);
            m_axis_cq_tlast : OUT std_logic;
            m_axis_cq_tready : IN std_logic;
            m_axis_cq_tuser : OUT std_logic_vector(84 DOWNTO 0);
            m_axis_cq_tvalid : OUT std_logic;
            s_axis_cc_tdata : IN std_logic_vector(255 DOWNTO 0);
            s_axis_cc_tkeep : IN std_logic_vector(7 DOWNTO 0);
            s_axis_cc_tlast : IN std_logic;
            s_axis_cc_tready : OUT std_logic_vector(3 DOWNTO 0);
            s_axis_cc_tuser : IN std_logic_vector(32 DOWNTO 0);
            s_axis_cc_tvalid : IN std_logic;
            pcie_rq_seq_num : OUT std_logic_vector(3 DOWNTO 0);
            pcie_rq_seq_num_vld : OUT std_logic;
            pcie_rq_tag : OUT std_logic_vector(5 DOWNTO 0);
            pcie_rq_tag_av : OUT std_logic_vector(1 DOWNTO 0);
            pcie_rq_tag_vld : OUT std_logic;
            pcie_tfc_nph_av : OUT std_logic_vector(1 DOWNTO 0);
            pcie_tfc_npd_av : OUT std_logic_vector(1 DOWNTO 0);
            pcie_cq_np_req : IN std_logic;
            pcie_cq_np_req_count : OUT std_logic_vector(5 DOWNTO 0);
            cfg_phy_link_down : OUT std_logic;
            cfg_phy_link_status : OUT std_logic_vector(1 DOWNTO 0);
            cfg_negotiated_width : OUT std_logic_vector(3 DOWNTO 0);
            cfg_current_speed : OUT std_logic_vector(2 DOWNTO 0);
            cfg_max_payload : OUT std_logic_vector(2 DOWNTO 0);
            cfg_max_read_req : OUT std_logic_vector(2 DOWNTO 0);
            cfg_function_status : OUT std_logic_vector(15 DOWNTO 0);
            cfg_function_power_state : OUT std_logic_vector(11 DOWNTO 0);
            cfg_vf_status : OUT std_logic_vector(15 DOWNTO 0);
            cfg_vf_power_state : OUT std_logic_vector(23 DOWNTO 0);
            cfg_link_power_state : OUT std_logic_vector(1 DOWNTO 0);
            cfg_mgmt_addr : IN std_logic_vector(18 DOWNTO 0);
            cfg_mgmt_write : IN std_logic;
            cfg_mgmt_write_data : IN std_logic_vector(31 DOWNTO 0);
            cfg_mgmt_byte_enable : IN std_logic_vector(3 DOWNTO 0);
            cfg_mgmt_read : IN std_logic;
            cfg_mgmt_read_data : OUT std_logic_vector(31 DOWNTO 0);
            cfg_mgmt_read_write_done : OUT std_logic;
            cfg_mgmt_type1_cfg_reg_access : IN std_logic;
            cfg_err_cor_out : OUT std_logic;
            cfg_err_nonfatal_out : OUT std_logic;
            cfg_err_fatal_out : OUT std_logic;
            cfg_local_error : OUT std_logic;
            cfg_ltr_enable : OUT std_logic;
            cfg_ltssm_state : OUT std_logic_vector(5 DOWNTO 0);
            cfg_rcb_status : OUT std_logic_vector(3 DOWNTO 0);
            cfg_dpa_substate_change : OUT std_logic_vector(3 DOWNTO 0);
            cfg_obff_enable : OUT std_logic_vector(1 DOWNTO 0);
            cfg_pl_status_change : OUT std_logic;
            cfg_tph_requester_enable : OUT std_logic_vector(3 DOWNTO 0);
            cfg_tph_st_mode : OUT std_logic_vector(11 DOWNTO 0);
            cfg_vf_tph_requester_enable : OUT std_logic_vector(7 DOWNTO 0);
            cfg_vf_tph_st_mode : OUT std_logic_vector(23 DOWNTO 0);
            cfg_msg_received : OUT std_logic;
            cfg_msg_received_data : OUT std_logic_vector(7 DOWNTO 0);
            cfg_msg_received_type : OUT std_logic_vector(4 DOWNTO 0);
            cfg_msg_transmit : IN std_logic;
            cfg_msg_transmit_type : IN std_logic_vector(2 DOWNTO 0);
            cfg_msg_transmit_data : IN std_logic_vector(31 DOWNTO 0);
            cfg_msg_transmit_done : OUT std_logic;
            cfg_fc_ph : OUT std_logic_vector(7 DOWNTO 0);
            cfg_fc_pd : OUT std_logic_vector(11 DOWNTO 0);
            cfg_fc_nph : OUT std_logic_vector(7 DOWNTO 0);
            cfg_fc_npd : OUT std_logic_vector(11 DOWNTO 0);
            cfg_fc_cplh : OUT std_logic_vector(7 DOWNTO 0);
            cfg_fc_cpld : OUT std_logic_vector(11 DOWNTO 0);
            cfg_fc_sel : IN std_logic_vector(2 DOWNTO 0);
            cfg_per_func_status_control : IN std_logic_vector(2 DOWNTO 0);
            cfg_per_func_status_data : OUT std_logic_vector(15 DOWNTO 0);
            cfg_per_function_number : IN std_logic_vector(3 DOWNTO 0);
            cfg_per_function_output_request : IN std_logic;
            cfg_per_function_update_done : OUT std_logic;
            cfg_dsn : IN std_logic_vector(63 DOWNTO 0);
            cfg_power_state_change_ack : IN std_logic;
            cfg_power_state_change_interrupt : OUT std_logic;
            cfg_err_cor_in : IN std_logic;
            cfg_err_uncor_in : IN std_logic;
            cfg_flr_in_process : OUT std_logic_vector(3 DOWNTO 0);
            cfg_flr_done : IN std_logic_vector(3 DOWNTO 0);
            cfg_vf_flr_in_process : OUT std_logic_vector(7 DOWNTO 0);
            cfg_vf_flr_done : IN std_logic_vector(7 DOWNTO 0);
            cfg_link_training_enable : IN std_logic;
            --        cfg_ext_read_received : OUT std_logic;
            --        cfg_ext_write_received : OUT std_logic;
            --        cfg_ext_register_number : OUT std_logic_vector(9 DOWNTO 0);
            --        cfg_ext_function_number : OUT std_logic_vector(7 DOWNTO 0);
            --        cfg_ext_write_data : OUT std_logic_vector(31 DOWNTO 0);
            --        cfg_ext_write_byte_enable : OUT std_logic_vector(3 DOWNTO 0);
            --        cfg_ext_read_data : IN std_logic_vector(31 DOWNTO 0);
            --        cfg_ext_read_data_valid : IN std_logic;
            cfg_interrupt_int : IN std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_pending : IN std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_sent : OUT std_logic;
            cfg_interrupt_msi_function_number : IN std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_msix_enable : OUT std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_msix_mask : OUT std_logic_vector(3 DOWNTO 0);
            cfg_interrupt_msix_vf_enable : OUT std_logic_vector(7 DOWNTO 0);
            cfg_interrupt_msix_vf_mask : OUT std_logic_vector(7 DOWNTO 0);
            cfg_interrupt_msix_data : IN std_logic_vector(31 DOWNTO 0);
            cfg_interrupt_msix_address : IN std_logic_vector(63 DOWNTO 0);
            cfg_interrupt_msix_int : IN std_logic;
            cfg_interrupt_msix_sent : OUT std_logic;
            cfg_interrupt_msix_fail : OUT std_logic;
            cfg_hot_reset_out : OUT std_logic;
            cfg_config_space_enable : IN std_logic;
            cfg_req_pm_transition_l23_ready : IN std_logic;
            cfg_hot_reset_in : IN std_logic;
            cfg_ds_port_number : IN std_logic_vector(7 DOWNTO 0);
            cfg_ds_bus_number : IN std_logic_vector(7 DOWNTO 0);
            cfg_ds_device_number : IN std_logic_vector(4 DOWNTO 0);
            cfg_ds_function_number : IN std_logic_vector(2 DOWNTO 0);
            cfg_subsys_vend_id : IN std_logic_vector(15 DOWNTO 0);
            sys_clk : IN std_logic;
            sys_clk_gt : IN std_logic;
            sys_reset : IN std_logic;
            int_qpll1lock_out : OUT std_logic_vector(1 DOWNTO 0);
            int_qpll1outrefclk_out : OUT std_logic_vector(1 DOWNTO 0);
            int_qpll1outclk_out : OUT std_logic_vector(1 DOWNTO 0);
            phy_rdy_out : OUT STD_LOGIC
        );
    END COMPONENT;

    --For VU9P and VU37P
    COMPONENT pcie4c_uscale_plus_0 -- @suppress "Component declaration 'pcie4c_uscale_plus_0' has none or multiple matching entity declarations"
        PORT (
            pci_exp_txn : OUT STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            pci_exp_txp : OUT STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            pci_exp_rxn : IN STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            pci_exp_rxp : IN STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            user_clk : OUT STD_LOGIC;
            user_reset : OUT STD_LOGIC;
            user_lnk_up : OUT STD_LOGIC;
            s_axis_rq_tdata : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            s_axis_rq_tkeep : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_rq_tlast : IN STD_LOGIC;
            s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_rq_tuser : IN STD_LOGIC_VECTOR(136 DOWNTO 0);
            s_axis_rq_tvalid : IN STD_LOGIC;
            m_axis_rc_tdata : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            m_axis_rc_tkeep : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_rc_tlast : OUT STD_LOGIC;
            m_axis_rc_tready : IN STD_LOGIC;
            m_axis_rc_tuser : OUT STD_LOGIC_VECTOR(160 DOWNTO 0);
            m_axis_rc_tvalid : OUT STD_LOGIC;
            m_axis_cq_tdata : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            m_axis_cq_tkeep : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_cq_tlast : OUT STD_LOGIC;
            m_axis_cq_tready : IN STD_LOGIC;
            m_axis_cq_tuser : OUT STD_LOGIC_VECTOR(182 DOWNTO 0);
            m_axis_cq_tvalid : OUT STD_LOGIC;
            s_axis_cc_tdata : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            s_axis_cc_tkeep : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_cc_tlast : IN STD_LOGIC;
            s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_cc_tuser : IN STD_LOGIC_VECTOR(80 DOWNTO 0);
            s_axis_cc_tvalid : IN STD_LOGIC;
            pcie_rq_seq_num0 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            pcie_rq_seq_num_vld0 : OUT STD_LOGIC;
            pcie_rq_seq_num1 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            pcie_rq_seq_num_vld1 : OUT STD_LOGIC;
            pcie_rq_tag0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pcie_rq_tag1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pcie_rq_tag_av : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_rq_tag_vld0 : OUT STD_LOGIC;
            pcie_rq_tag_vld1 : OUT STD_LOGIC;
            pcie_tfc_nph_av : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_tfc_npd_av : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_cq_np_req : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pcie_cq_np_req_count : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_phy_link_down : OUT STD_LOGIC;
            cfg_phy_link_status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_negotiated_width : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_current_speed : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_max_payload : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_max_read_req : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_function_status : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_function_power_state : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_vf_status : OUT STD_LOGIC_VECTOR(503 DOWNTO 0);
            cfg_vf_power_state : OUT STD_LOGIC_VECTOR(755 DOWNTO 0);
            cfg_link_power_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_mgmt_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            cfg_mgmt_function_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_mgmt_write : IN STD_LOGIC;
            cfg_mgmt_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_mgmt_byte_enable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_mgmt_read : IN STD_LOGIC;
            cfg_mgmt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_mgmt_read_write_done : OUT STD_LOGIC;
            cfg_mgmt_debug_access : IN STD_LOGIC;
            cfg_err_cor_out : OUT STD_LOGIC;
            cfg_err_nonfatal_out : OUT STD_LOGIC;
            cfg_err_fatal_out : OUT STD_LOGIC;
            cfg_local_error_valid : OUT STD_LOGIC;
            cfg_local_error_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_ltssm_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_rx_pm_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_tx_pm_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_rcb_status : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_obff_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_pl_status_change : OUT STD_LOGIC;
            cfg_tph_requester_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_tph_st_mode : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_vf_tph_requester_enable : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_vf_tph_st_mode : OUT STD_LOGIC_VECTOR(755 DOWNTO 0);
            cfg_msg_received : OUT STD_LOGIC;
            cfg_msg_received_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_msg_received_type : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_msg_transmit : IN STD_LOGIC;
            cfg_msg_transmit_type : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_msg_transmit_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_msg_transmit_done : OUT STD_LOGIC;
            cfg_fc_ph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_pd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_nph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_npd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_dsn : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            cfg_bus_number : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_power_state_change_ack : IN STD_LOGIC;
            cfg_power_state_change_interrupt : OUT STD_LOGIC;
            cfg_err_cor_in : IN STD_LOGIC;
            cfg_err_uncor_in : IN STD_LOGIC;
            cfg_flr_in_process : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_flr_done : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_vf_flr_in_process : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_vf_flr_func_num : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_vf_flr_done : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            cfg_link_training_enable : IN STD_LOGIC;
            cfg_interrupt_int : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_pending : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_sent : OUT STD_LOGIC;
            cfg_interrupt_msi_sent : OUT STD_LOGIC;
            cfg_interrupt_msi_fail : OUT STD_LOGIC;
            cfg_interrupt_msi_function_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_interrupt_msix_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_msix_mask : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_msix_vf_enable : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_interrupt_msix_vf_mask : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_pm_aspm_l1_entry_reject : IN STD_LOGIC;
            cfg_pm_aspm_tx_l0s_entry_disable : IN STD_LOGIC;
            cfg_interrupt_msix_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_interrupt_msix_address : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            cfg_interrupt_msix_int : IN STD_LOGIC;
            cfg_interrupt_msix_vec_pending : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_interrupt_msix_vec_pending_status : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            cfg_hot_reset_out : OUT STD_LOGIC;
            cfg_config_space_enable : IN STD_LOGIC;
            cfg_req_pm_transition_l23_ready : IN STD_LOGIC;
            cfg_hot_reset_in : IN STD_LOGIC;
            cfg_ds_port_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_ds_bus_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_ds_device_number : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_subsys_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_dev_id_pf0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_rev_id_pf0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_subsys_id_pf0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            sys_clk : IN STD_LOGIC;
            sys_clk_gt : IN STD_LOGIC;
            sys_reset : IN STD_LOGIC;
            conf_req_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            conf_req_reg_num : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            conf_req_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            conf_req_valid : IN STD_LOGIC;
            conf_req_ready : OUT STD_LOGIC;
            conf_resp_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            conf_resp_valid : OUT STD_LOGIC;
            cap_req : OUT STD_LOGIC;
            cap_gnt : IN STD_LOGIC;
            cap_rel : IN STD_LOGIC;
            mcap_design_switch : OUT STD_LOGIC;
            phy_rdy_out : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT pcie4c_uscale_plus_1 -- @suppress "Component declaration 'pcie4c_uscale_plus_1' has none or multiple matching entity declarations"
        PORT (
            pci_exp_txn : OUT STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            pci_exp_txp : OUT STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            pci_exp_rxn : IN STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            pci_exp_rxp : IN STD_LOGIC_VECTOR(PCIE_LANES-1 DOWNTO 0);
            user_clk : OUT STD_LOGIC;
            user_reset : OUT STD_LOGIC;
            user_lnk_up : OUT STD_LOGIC;
            s_axis_rq_tdata : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            s_axis_rq_tkeep : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_rq_tlast : IN STD_LOGIC;
            s_axis_rq_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_rq_tuser : IN STD_LOGIC_VECTOR(136 DOWNTO 0);
            s_axis_rq_tvalid : IN STD_LOGIC;
            m_axis_rc_tdata : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            m_axis_rc_tkeep : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_rc_tlast : OUT STD_LOGIC;
            m_axis_rc_tready : IN STD_LOGIC;
            m_axis_rc_tuser : OUT STD_LOGIC_VECTOR(160 DOWNTO 0);
            m_axis_rc_tvalid : OUT STD_LOGIC;
            m_axis_cq_tdata : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            m_axis_cq_tkeep : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_cq_tlast : OUT STD_LOGIC;
            m_axis_cq_tready : IN STD_LOGIC;
            m_axis_cq_tuser : OUT STD_LOGIC_VECTOR(182 DOWNTO 0);
            m_axis_cq_tvalid : OUT STD_LOGIC;
            s_axis_cc_tdata : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
            s_axis_cc_tkeep : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_cc_tlast : IN STD_LOGIC;
            s_axis_cc_tready : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            s_axis_cc_tuser : IN STD_LOGIC_VECTOR(80 DOWNTO 0);
            s_axis_cc_tvalid : IN STD_LOGIC;
            pcie_rq_seq_num0 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            pcie_rq_seq_num_vld0 : OUT STD_LOGIC;
            pcie_rq_seq_num1 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            pcie_rq_seq_num_vld1 : OUT STD_LOGIC;
            pcie_rq_tag0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pcie_rq_tag1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pcie_rq_tag_av : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_rq_tag_vld0 : OUT STD_LOGIC;
            pcie_rq_tag_vld1 : OUT STD_LOGIC;
            pcie_tfc_nph_av : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_tfc_npd_av : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcie_cq_np_req : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pcie_cq_np_req_count : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_phy_link_down : OUT STD_LOGIC;
            cfg_phy_link_status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_negotiated_width : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_current_speed : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_max_payload : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_max_read_req : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_function_status : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_function_power_state : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_vf_status : OUT STD_LOGIC_VECTOR(503 DOWNTO 0);
            cfg_vf_power_state : OUT STD_LOGIC_VECTOR(755 DOWNTO 0);
            cfg_link_power_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_mgmt_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            cfg_mgmt_function_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_mgmt_write : IN STD_LOGIC;
            cfg_mgmt_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_mgmt_byte_enable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_mgmt_read : IN STD_LOGIC;
            cfg_mgmt_read_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_mgmt_read_write_done : OUT STD_LOGIC;
            cfg_mgmt_debug_access : IN STD_LOGIC;
            cfg_err_cor_out : OUT STD_LOGIC;
            cfg_err_nonfatal_out : OUT STD_LOGIC;
            cfg_err_fatal_out : OUT STD_LOGIC;
            cfg_local_error_valid : OUT STD_LOGIC;
            cfg_local_error_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_ltssm_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            cfg_rx_pm_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_tx_pm_state : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_rcb_status : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_obff_enable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_pl_status_change : OUT STD_LOGIC;
            cfg_tph_requester_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_tph_st_mode : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_vf_tph_requester_enable : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_vf_tph_st_mode : OUT STD_LOGIC_VECTOR(755 DOWNTO 0);
            cfg_msg_received : OUT STD_LOGIC;
            cfg_msg_received_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_msg_received_type : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_msg_transmit : IN STD_LOGIC;
            cfg_msg_transmit_type : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_msg_transmit_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_msg_transmit_done : OUT STD_LOGIC;
            cfg_fc_ph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_pd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_nph : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_npd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_cplh : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_fc_cpld : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            cfg_fc_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            cfg_dsn : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            cfg_bus_number : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_power_state_change_ack : IN STD_LOGIC;
            cfg_power_state_change_interrupt : OUT STD_LOGIC;
            cfg_err_cor_in : IN STD_LOGIC;
            cfg_err_uncor_in : IN STD_LOGIC;
            cfg_flr_in_process : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_flr_done : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_vf_flr_in_process : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_vf_flr_func_num : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_vf_flr_done : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            cfg_link_training_enable : IN STD_LOGIC;
            cfg_interrupt_int : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_pending : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_sent : OUT STD_LOGIC;
            cfg_interrupt_msi_sent : OUT STD_LOGIC;
            cfg_interrupt_msi_fail : OUT STD_LOGIC;
            cfg_interrupt_msi_function_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_interrupt_msix_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_msix_mask : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cfg_interrupt_msix_vf_enable : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_interrupt_msix_vf_mask : OUT STD_LOGIC_VECTOR(251 DOWNTO 0);
            cfg_pm_aspm_l1_entry_reject : IN STD_LOGIC;
            cfg_pm_aspm_tx_l0s_entry_disable : IN STD_LOGIC;
            cfg_interrupt_msix_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            cfg_interrupt_msix_address : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            cfg_interrupt_msix_int : IN STD_LOGIC;
            cfg_interrupt_msix_vec_pending : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            cfg_interrupt_msix_vec_pending_status : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            cfg_hot_reset_out : OUT STD_LOGIC;
            cfg_config_space_enable : IN STD_LOGIC;
            cfg_req_pm_transition_l23_ready : IN STD_LOGIC;
            cfg_hot_reset_in : IN STD_LOGIC;
            cfg_ds_port_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_ds_bus_number : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_ds_device_number : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            cfg_subsys_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_dev_id_pf0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_vend_id : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cfg_rev_id_pf0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            cfg_subsys_id_pf0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            sys_clk : IN STD_LOGIC;
            sys_clk_gt : IN STD_LOGIC;
            sys_reset : IN STD_LOGIC;
            conf_req_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            conf_req_reg_num : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            conf_req_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            conf_req_valid : IN STD_LOGIC;
            conf_req_ready : OUT STD_LOGIC;
            conf_resp_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            conf_resp_valid : OUT STD_LOGIC;
            cap_req : OUT STD_LOGIC;
            cap_gnt : IN STD_LOGIC;
            cap_rel : IN STD_LOGIC;
            mcap_design_switch : OUT STD_LOGIC;
            phy_rdy_out : OUT STD_LOGIC
        );
    END COMPONENT;

    --For Versal
    component versal_pcie_block_wrapper -- @suppress "Component declaration 'versal_pcie_block_wrapper' has none or multiple matching entity declarations"
    port (
      cfg_pasid_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      cfg_pasid_exec_permission_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      cfg_pasid_privil_mode_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      m_axis_cq_tdata : out STD_LOGIC_VECTOR ( 511 downto 0 );
      m_axis_cq_tkeep : out STD_LOGIC_VECTOR ( 15 downto 0 );
      m_axis_cq_tlast : out STD_LOGIC;
      m_axis_cq_tready : in STD_LOGIC;
      m_axis_cq_tuser : out STD_LOGIC_VECTOR ( 228 downto 0 );
      m_axis_cq_tvalid : out STD_LOGIC;
      m_axis_rc_tdata : out STD_LOGIC_VECTOR ( 511 downto 0 );
      m_axis_rc_tkeep : out STD_LOGIC_VECTOR ( 15 downto 0 );
      m_axis_rc_tlast : out STD_LOGIC;
      m_axis_rc_tready : in STD_LOGIC;
      m_axis_rc_tuser : out STD_LOGIC_VECTOR ( 160 downto 0 );
      m_axis_rc_tvalid : out STD_LOGIC;
      pcie4_cfg_control_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_control_config_space_enable : in STD_LOGIC;
      pcie4_cfg_control_ds_bus_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_control_ds_device_number : in STD_LOGIC_VECTOR ( 4 downto 0 );
      pcie4_cfg_control_ds_port_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_control_dsn : in STD_LOGIC_VECTOR ( 63 downto 0 );
      pcie4_cfg_control_err_cor_in : in STD_LOGIC;
      pcie4_cfg_control_err_uncor_in : in STD_LOGIC;
      pcie4_cfg_control_flr_done : in STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_control_flr_in_process : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_control_hot_reset_in : in STD_LOGIC;
      pcie4_cfg_control_hot_reset_out : out STD_LOGIC;
      pcie4_cfg_control_link_training_enable : in STD_LOGIC;
      pcie4_cfg_control_pm_aspm_l1entry_reject : in STD_LOGIC;
      pcie4_cfg_control_pm_aspm_tx_l0s_entry_disable : in STD_LOGIC;
      pcie4_cfg_control_power_state_change_ack : in STD_LOGIC;
      pcie4_cfg_control_power_state_change_interrupt : out STD_LOGIC;
      pcie4_cfg_control_req_pm_transition_l23_ready : in STD_LOGIC;
      pcie4_cfg_control_vf_flr_done : in STD_LOGIC_VECTOR ( 0 to 0 );
      pcie4_cfg_control_vf_flr_func_num : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_control_vf_flr_in_process : out STD_LOGIC_VECTOR ( 251 downto 0 );
      pcie4_cfg_external_msix_without_msi_address : in STD_LOGIC_VECTOR ( 63 downto 0 );
      pcie4_cfg_external_msix_without_msi_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
      pcie4_cfg_external_msix_without_msi_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_external_msix_without_msi_fail : out STD_LOGIC;
      pcie4_cfg_external_msix_without_msi_function_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_external_msix_without_msi_int_vector : in STD_LOGIC;
      pcie4_cfg_external_msix_without_msi_mask : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_external_msix_without_msi_sent : out STD_LOGIC;
      pcie4_cfg_external_msix_without_msi_vec_pending : in STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_external_msix_without_msi_vec_pending_status : out STD_LOGIC_VECTOR ( 0 to 0 );
      pcie4_cfg_external_msix_without_msi_vf_enable : out STD_LOGIC_VECTOR ( 251 downto 0 );
      pcie4_cfg_external_msix_without_msi_vf_mask : out STD_LOGIC_VECTOR ( 251 downto 0 );
      pcie4_cfg_fc_cpld : out STD_LOGIC_VECTOR ( 11 downto 0 );
      pcie4_cfg_fc_cpld_scale : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_fc_cplh : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_fc_cplh_scale : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_fc_npd : out STD_LOGIC_VECTOR ( 11 downto 0 );
      pcie4_cfg_fc_npd_scale : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_fc_nph : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_fc_nph_scale : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_fc_pd : out STD_LOGIC_VECTOR ( 11 downto 0 );
      pcie4_cfg_fc_pd_scale : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_fc_ph : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_fc_ph_scale : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_fc_sel : in STD_LOGIC_VECTOR ( 2 downto 0 );
      pcie4_cfg_interrupt_intx_vector : in STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_interrupt_pending : in STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_interrupt_sent : out STD_LOGIC;
      pcie4_cfg_mesg_rcvd_recd : out STD_LOGIC;
      pcie4_cfg_mesg_rcvd_recd_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_mesg_rcvd_recd_type : out STD_LOGIC_VECTOR ( 4 downto 0 );
      pcie4_cfg_mesg_tx_transmit : in STD_LOGIC;
      pcie4_cfg_mesg_tx_transmit_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
      pcie4_cfg_mesg_tx_transmit_done : out STD_LOGIC;
      pcie4_cfg_mesg_tx_transmit_type : in STD_LOGIC_VECTOR ( 2 downto 0 );
      pcie4_cfg_mgmt_addr : in STD_LOGIC_VECTOR ( 9 downto 0 );
      pcie4_cfg_mgmt_byte_en : in STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_mgmt_debug_access : in STD_LOGIC;
      pcie4_cfg_mgmt_function_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_cfg_mgmt_read_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
      pcie4_cfg_mgmt_read_en : in STD_LOGIC;
      pcie4_cfg_mgmt_read_write_done : out STD_LOGIC;
      pcie4_cfg_mgmt_write_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
      pcie4_cfg_mgmt_write_en : in STD_LOGIC;
      pcie4_cfg_status_10b_tag_requester_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_status_atomic_requester_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_status_cq_np_req : in STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_cq_np_req_count : out STD_LOGIC_VECTOR ( 5 downto 0 );
      pcie4_cfg_status_current_speed : out STD_LOGIC_VECTOR ( 2 downto 0 );
      pcie4_cfg_status_err_cor_out : out STD_LOGIC;
      pcie4_cfg_status_err_fatal_out : out STD_LOGIC;
      pcie4_cfg_status_err_nonfatal_out : out STD_LOGIC;
      pcie4_cfg_status_ext_tag_enable : out STD_LOGIC;
      pcie4_cfg_status_function_power_state : out STD_LOGIC_VECTOR ( 11 downto 0 );
      pcie4_cfg_status_function_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
      pcie4_cfg_status_link_power_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_local_error_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
      pcie4_cfg_status_local_error_valid : out STD_LOGIC;
      pcie4_cfg_status_ltssm_state : out STD_LOGIC_VECTOR ( 5 downto 0 );
      pcie4_cfg_status_max_payload : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_max_read_req : out STD_LOGIC_VECTOR ( 2 downto 0 );
      pcie4_cfg_status_negotiated_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
      pcie4_cfg_status_obff_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_phy_link_down : out STD_LOGIC;
      pcie4_cfg_status_phy_link_status : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_pl_status_change : out STD_LOGIC;
      pcie4_cfg_status_rcb_status : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_status_rq_seq_num0 : out STD_LOGIC_VECTOR ( 5 downto 0 );
      pcie4_cfg_status_rq_seq_num1 : out STD_LOGIC_VECTOR ( 5 downto 0 );
      pcie4_cfg_status_rq_seq_num_vld0 : out STD_LOGIC;
      pcie4_cfg_status_rq_seq_num_vld1 : out STD_LOGIC;
      pcie4_cfg_status_rq_tag0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
      pcie4_cfg_status_rq_tag1 : out STD_LOGIC_VECTOR ( 9 downto 0 );
      pcie4_cfg_status_rq_tag_av : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_status_rq_tag_vld0 : out STD_LOGIC;
      pcie4_cfg_status_rq_tag_vld1 : out STD_LOGIC;
      pcie4_cfg_status_rx_pm_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_tph_requester_enable : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_cfg_status_tph_st_mode : out STD_LOGIC_VECTOR ( 11 downto 0 );
      pcie4_cfg_status_tx_pm_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
      pcie4_cfg_status_vc1_enable : out STD_LOGIC;
      pcie4_cfg_status_vc1_negotiation_pending : out STD_LOGIC;
      pcie4_cfg_status_vf_power_state : out STD_LOGIC_VECTOR ( 755 downto 0 );
      pcie4_cfg_status_vf_status : out STD_LOGIC_VECTOR ( 503 downto 0 );
      pcie4_cfg_status_vf_tph_requester_enable : out STD_LOGIC_VECTOR ( 251 downto 0 );
      pcie4_cfg_status_vf_tph_st_mode : out STD_LOGIC_VECTOR ( 755 downto 0 );
      pcie4_pf0_id_dev_id : in STD_LOGIC_VECTOR ( 15 downto 0 );
      pcie4_pf0_id_dev_subsys_id : in STD_LOGIC_VECTOR ( 15 downto 0 );
      pcie4_pf0_id_rev_id : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie4_transmit_fc_npd_av : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_transmit_fc_nph_av : out STD_LOGIC_VECTOR ( 3 downto 0 );
      pcie4_vend_id_subsys_vend_id : in STD_LOGIC_VECTOR ( 15 downto 0 );
      pcie4_vend_id_vend_id : in STD_LOGIC_VECTOR ( 15 downto 0 );
      pcie_ltssm_state : out STD_LOGIC_VECTOR ( 5 downto 0 );
      pcie_mgt_grx_n : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie_mgt_grx_p : in STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie_mgt_gtx_n : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie_mgt_gtx_p : out STD_LOGIC_VECTOR ( 7 downto 0 );
      pcie_refclk_clk_n : in STD_LOGIC_VECTOR ( 0 to 0 );
      pcie_refclk_clk_p : in STD_LOGIC_VECTOR ( 0 to 0 );
      phy_rdy_out : out STD_LOGIC;
      s_axis_cc_tdata : in STD_LOGIC_VECTOR ( 511 downto 0 );
      s_axis_cc_tkeep : in STD_LOGIC_VECTOR ( 15 downto 0 );
      s_axis_cc_tlast : in STD_LOGIC;
      s_axis_cc_tready : out STD_LOGIC_VECTOR ( 3 downto 0 );
      s_axis_cc_tuser : in STD_LOGIC_VECTOR ( 80 downto 0 );
      s_axis_cc_tvalid : in STD_LOGIC;
      s_axis_rq_tdata : in STD_LOGIC_VECTOR ( 511 downto 0 );
      s_axis_rq_tkeep : in STD_LOGIC_VECTOR ( 15 downto 0 );
      s_axis_rq_tlast : in STD_LOGIC;
      s_axis_rq_tready : out STD_LOGIC_VECTOR ( 3 downto 0 );
      s_axis_rq_tuser : in STD_LOGIC_VECTOR ( 182 downto 0 );
      s_axis_rq_tvalid : in STD_LOGIC;
      sys_reset : in STD_LOGIC;
      user_clk : out STD_LOGIC;
      user_lnk_up : out STD_LOGIC;
      user_reset : out STD_LOGIC
    );
    end component versal_pcie_block_wrapper;

    signal sys_clk: std_logic;
    signal sys_reset: std_logic;
    signal sys_clk_gt: std_logic;

    signal user_clk: std_logic;
    signal user_reset: std_logic;

    signal pipe_pclk_in     : std_logic;
    signal pipe_rxusrclk_in : std_logic;
    signal pipe_rxoutclk_in : std_logic_vector(7 downto 0);
    signal pipe_dclk_in     : std_logic;
    signal pipe_userclk1_in : std_logic;
    signal pipe_userclk2_in : std_logic;
    signal pipe_oobclk_in   : std_logic;
    signal pipe_mmcm_lock_in: std_logic;
    signal pipe_txoutclk_out: std_logic;
    signal pipe_rxoutclk_out: std_logic_vector(7 downto 0);
    signal pipe_pclk_sel_out: std_logic_vector(7 downto 0);
    signal pipe_mmcm_rst_n  : std_logic;
    --signal pipe_gen3_out    : std_logic;
      
      
      signal cfg_power_state_change_ack : std_logic;
      
      
      
begin
    g_NoSim: if SIMULATION=false generate
        pipe_mmcm_rst_n <= '1';

        s_axis_r_rq.tready <= s_axis_rq_tready(0);
        s_axis_r_cc.tready <= s_axis_cc_tready(0);
        --m_axis_rc_tready <= (others => m_axis_r_rc.tready);
        --m_axis_cq_tready <= (others => m_axis_r_cq.tready);
        m_axis_rc.tuser <= (others => '0'); --unused.

        cfg_interrupt_msix_fail <= s_cfg_interrupt_msix_fail;
        cfg_interrupt_msix_sent <= s_cfg_interrupt_msix_sent;
        monitor_cfg_interrupt_msix_fail <= s_cfg_interrupt_msix_fail;
        monitor_cfg_interrupt_msix_sent <= s_cfg_interrupt_msix_sent;

        --Virtex7 devices
        g_virtex7: if (CARD_TYPE = 709 or CARD_TYPE = 710) generate
            signal cfg_flr_in_process: std_logic_vector(3 downto 0);
            signal cfg_vf_flr_in_process: std_logic_vector(251 downto 0);
            signal cfg_flr_done, cfg_flr_done_reg0, cfg_flr_done_reg1: std_logic_vector(3 downto 0);
            signal cfg_vf_flr_done, cfg_vf_flr_done_reg0, cfg_vf_flr_done_reg1: std_logic_vector(251 downto 0);
        begin
            refclk_buff: IBUFDS_GTE2 port map( -- @suppress "Generic map uses default values. Missing optional actuals: CLKCM_CFG, CLKRCV_TRST, CLKSWING_CFG"
                    O => sys_clk,
                    ODIV2 => open,
                    CEB => '0',
                    I => sys_clk_p,
                    IB => sys_clk_n
                );

            sys_reset <= not sys_rst_n;

            u1: pcie_x8_gen3_3_0
                PORT MAP (
                    pci_exp_txn => pci_exp_txn(7 downto 0),
                    pci_exp_txp => pci_exp_txp(7 downto 0),
                    pci_exp_rxn => pci_exp_rxn(7 downto 0),
                    pci_exp_rxp => pci_exp_rxp(7 downto 0),
                    pipe_pclk_in => pipe_pclk_in,
                    pipe_rxusrclk_in => pipe_rxusrclk_in,
                    pipe_rxoutclk_in => pipe_rxoutclk_in,
                    pipe_dclk_in => pipe_dclk_in,
                    pipe_userclk1_in => pipe_userclk1_in,
                    pipe_userclk2_in => pipe_userclk2_in,
                    pipe_oobclk_in => pipe_oobclk_in,
                    pipe_mmcm_lock_in => pipe_mmcm_lock_in,
                    pipe_txoutclk_out => pipe_txoutclk_out,
                    pipe_rxoutclk_out => pipe_rxoutclk_out,
                    pipe_pclk_sel_out => pipe_pclk_sel_out,
                    pipe_gen3_out => open, --pipe_gen3_out,
                    pipe_mmcm_rst_n => pipe_mmcm_rst_n,
                    mmcm_lock => open,
                    user_clk => user_clk,
                    user_reset => user_reset,
                    user_lnk_up => user_lnk_up,
                    user_app_rdy => open,
                    s_axis_rq_tlast => s_axis_rq.tlast,
                    s_axis_rq_tdata => s_axis_rq.tdata(255 downto 0),
                    s_axis_rq_tuser => x"0000000000000FF",
                    s_axis_rq_tkeep => s_axis_rq.tkeep(7 downto 0),
                    s_axis_rq_tready => s_axis_rq_tready,
                    s_axis_rq_tvalid => s_axis_rq.tvalid,
                    m_axis_rc_tdata => m_axis_rc.tdata(255 downto 0),
                    m_axis_rc_tuser => open,
                    m_axis_rc_tlast => m_axis_rc.tlast,
                    m_axis_rc_tkeep => m_axis_rc.tkeep(7 downto 0),
                    m_axis_rc_tvalid => m_axis_rc.tvalid,
                    m_axis_rc_tready => m_axis_r_rc.tready,
                    m_axis_cq_tdata => m_axis_cq.tdata(255 downto 0),
                    m_axis_cq_tuser => m_axis_cq.tuser(84 downto 0),
                    m_axis_cq_tlast => m_axis_cq.tlast,
                    m_axis_cq_tkeep => m_axis_cq.tkeep(7 downto 0),
                    m_axis_cq_tvalid => m_axis_cq.tvalid,
                    m_axis_cq_tready => m_axis_r_cq.tready,
                    s_axis_cc_tdata => s_axis_cc.tdata(255 downto 0),
                    s_axis_cc_tuser => (others => '0'),
                    s_axis_cc_tlast => s_axis_cc.tlast,
                    s_axis_cc_tkeep => s_axis_cc.tkeep(7 downto 0),
                    s_axis_cc_tvalid => s_axis_cc.tvalid,
                    s_axis_cc_tready => s_axis_cc_tready,
                    pcie_rq_seq_num => open,
                    pcie_rq_seq_num_vld => open,
                    pcie_rq_tag => open,
                    pcie_rq_tag_vld => open,
                    pcie_tfc_nph_av => open,
                    pcie_tfc_npd_av => open,
                    pcie_cq_np_req => '1',
                    pcie_cq_np_req_count => open,
                    cfg_phy_link_down => open,
                    cfg_phy_link_status => open,
                    cfg_negotiated_width => open,
                    cfg_current_speed => open,
                    cfg_max_payload => open,
                    cfg_max_read_req => open,
                    cfg_function_status => open,
                    cfg_function_power_state => open,
                    cfg_vf_status => open,
                    cfg_vf_power_state => open,
                    cfg_link_power_state => open,
                    cfg_mgmt_addr => cfg_mgmt_addr,
                    cfg_mgmt_write => cfg_mgmt_write,
                    cfg_mgmt_write_data => cfg_mgmt_write_data,
                    cfg_mgmt_byte_enable => cfg_mgmt_byte_enable,
                    cfg_mgmt_read => cfg_mgmt_read,
                    cfg_mgmt_read_data => cfg_mgmt_read_data,
                    cfg_mgmt_read_write_done => cfg_mgmt_read_write_done,
                    cfg_mgmt_type1_cfg_reg_access => '0',
                    cfg_err_cor_out => open,
                    cfg_err_nonfatal_out => open,
                    cfg_err_fatal_out => open,
                    cfg_ltr_enable => open,
                    cfg_ltssm_state => open,
                    cfg_rcb_status => open,
                    cfg_dpa_substate_change => open,
                    cfg_obff_enable => open,
                    cfg_pl_status_change => open,
                    cfg_tph_requester_enable => open,
                    cfg_tph_st_mode => open,
                    cfg_vf_tph_requester_enable => open,
                    cfg_vf_tph_st_mode => open,
                    cfg_msg_received => open,
                    cfg_msg_received_data => open,
                    cfg_msg_received_type => open,
                    cfg_msg_transmit => '0',
                    cfg_msg_transmit_type => "000",
                    cfg_msg_transmit_data => x"00000000",
                    cfg_msg_transmit_done => open,
                    cfg_fc_ph => cfg_fc_ph,
                    cfg_fc_pd => cfg_fc_pd,
                    cfg_fc_nph => cfg_fc_nph,
                    cfg_fc_npd => cfg_fc_npd,
                    cfg_fc_cplh => cfg_fc_cplh,
                    cfg_fc_cpld => cfg_fc_cpld,
                    cfg_fc_sel => cfg_fc_sel,
                    cfg_per_func_status_control => "000",
                    cfg_per_func_status_data => open,
                    cfg_per_function_number => "000",
                    cfg_per_function_output_request => '0',
                    cfg_per_function_update_done => open,
                    cfg_subsys_vend_id => x"10EE",
                    cfg_dsn => x"00000001_01_000A35",
                    cfg_power_state_change_ack => cfg_power_state_change_ack,
                    cfg_power_state_change_interrupt => cfg_power_state_change_ack,
                    cfg_err_cor_in => '0',
                    cfg_err_uncor_in => '0',
                    cfg_flr_in_process => cfg_flr_in_process(1 downto 0),
                    cfg_flr_done => cfg_flr_done(1 downto 0),
                    cfg_vf_flr_in_process => cfg_vf_flr_in_process(5 downto 0),
                    cfg_vf_flr_done => cfg_vf_flr_done(5 downto 0),
                    cfg_link_training_enable => '1',
                    cfg_interrupt_int => "0000",
                    cfg_interrupt_pending => "00",
                    cfg_interrupt_sent => open,
                    cfg_interrupt_msix_enable => cfg_interrupt_msix_enable(1 downto 0),
                    cfg_interrupt_msix_mask => open,
                    cfg_interrupt_msix_vf_enable => open,
                    cfg_interrupt_msix_vf_mask => open,
                    cfg_interrupt_msix_data => cfg_interrupt_msix_data,
                    cfg_interrupt_msix_address => cfg_interrupt_msix_address,
                    cfg_interrupt_msix_int => cfg_interrupt_msix_int,
                    cfg_interrupt_msix_sent => s_cfg_interrupt_msix_sent,
                    cfg_interrupt_msix_fail => s_cfg_interrupt_msix_fail,
                    cfg_interrupt_msi_function_number => "000",
                    cfg_hot_reset_out => open,
                    cfg_config_space_enable => '1',
                    cfg_req_pm_transition_l23_ready => '0',
                    cfg_hot_reset_in => '0',
                    cfg_ds_port_number => x"00",
                    cfg_ds_bus_number => x"00",
                    cfg_ds_device_number => "00000",
                    cfg_ds_function_number => "000",
                    sys_clk => sys_clk,
                    sys_reset => sys_reset
                );

            cfg_interrupt_msix_enable(3 downto 2) <= "00";

            ---------- PIPE Clock Shared Mode ------------------------------//

            pipe_clock0: pcie_clocking generic map(
                    PCIE_ASYNC_EN             =>    "FALSE" ,                     -- PCIe async enable
                    --PCIE_TXBUF_EN             =>    "FALSE" ,                     -- PCIe TX buffer enable for Gen1/Gen2 only
                    PCIE_CLK_SHARING_EN       =>    "FALSE" ,                     -- Enable Clock Sharing
                    PCIE_LANE                 =>    8 ,                           -- PCIe number of lanes
                    PCIE_LINK_SPEED           =>    3 ,                           -- PCIe Maximum Link Speed
                    PCIE_REFCLK_FREQ          =>    0 ,                           -- PCIe Reference Clock Frequency
                    PCIE_USERCLK1_FREQ        =>    5 ,                           -- PCIe Core Clock Frequency - Core Clock Freq
                    PCIE_USERCLK2_FREQ        =>    4 ,                           -- PCIe User Clock Frequency - User Clock Freq
                    PCIE_OOBCLK_MODE          =>    1 ,
                    PCIE_DEBUG_MODE           =>    0                             -- Debug Enable
                )
                port map
                (
                    ---------- Input -------------------------------------
                    --CLK_CLK                   =>    ( sys_clk ),
                    CLK_TXOUTCLK              =>    ( pipe_txoutclk_out ),     -- Reference clock from lane 0
                    CLK_RXOUTCLK_IN           =>    ( pipe_rxoutclk_out ),
                    CLK_RST_N                 =>    ( pipe_mmcm_rst_n ),      -- Allow system reset for error_recovery             
                    CLK_PCLK_SEL              =>    ( pipe_pclk_sel_out ),
                    CLK_PCLK_SEL_SLAVE        =>    ( x"00"),
                    --CLK_GEN3                  =>    ( pipe_gen3_out ),

      ---------- Output ------------------------------------
                    CLK_PCLK                 =>    ( pipe_pclk_in),
                    CLK_PCLK_SLAVE           =>    open,
                    CLK_RXUSRCLK             =>    ( pipe_rxusrclk_in),
                    CLK_RXOUTCLK_OUT         =>    ( pipe_rxoutclk_in),
                    CLK_DCLK                 =>    ( pipe_dclk_in),
                    CLK_OOBCLK               =>    ( pipe_oobclk_in),
                    CLK_USERCLK1             =>    ( pipe_userclk1_in),
                    CLK_USERCLK2             =>    ( pipe_userclk2_in),
                    CLK_MMCM_LOCK            =>    ( pipe_mmcm_lock_in)

  );
            cfg_flr: process(user_clk)
            begin
                if (rising_edge(user_clk)) then
                    if (user_reset = '1') then
                        cfg_flr_done_reg0       <= (others => '0');
                        cfg_vf_flr_done_reg0    <= (others => '0');
                        cfg_flr_done_reg1       <= (others => '0');
                        cfg_vf_flr_done_reg1    <= (others => '0');
                    else
                        cfg_flr_done_reg0       <= cfg_flr_in_process;
                        cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process;
                        cfg_flr_done_reg1       <= cfg_flr_done_reg0;
                        cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;
                    end if;
                end if;
            end process;

            cfg_flr_done(0) <= (not cfg_flr_done_reg1(0)) and cfg_flr_done_reg0(0);
            cfg_flr_done(1) <= (not cfg_flr_done_reg1(1)) and cfg_flr_done_reg0(1);
            cfg_flr_done(2) <= (not cfg_flr_done_reg1(2)) and cfg_flr_done_reg0(2);
            cfg_flr_done(3) <= (not cfg_flr_done_reg1(3)) and cfg_flr_done_reg0(3);
  

            cfg_vf_flr_done(0) <= (not cfg_vf_flr_done_reg1(0)) and cfg_vf_flr_done_reg0(0);
            cfg_vf_flr_done(1) <= (not cfg_vf_flr_done_reg1(1)) and cfg_vf_flr_done_reg0(1);
            cfg_vf_flr_done(2) <= (not cfg_vf_flr_done_reg1(2)) and cfg_vf_flr_done_reg0(2);
            cfg_vf_flr_done(3) <= (not cfg_vf_flr_done_reg1(3)) and cfg_vf_flr_done_reg0(3);
            cfg_vf_flr_done(4) <= (not cfg_vf_flr_done_reg1(4)) and cfg_vf_flr_done_reg0(4);
            cfg_vf_flr_done(5) <= (not cfg_vf_flr_done_reg1(5)) and cfg_vf_flr_done_reg0(5);
            cfg_vf_flr_done(6) <= (not cfg_vf_flr_done_reg1(6)) and cfg_vf_flr_done_reg0(6);
            cfg_vf_flr_done(7) <= (not cfg_vf_flr_done_reg1(7)) and cfg_vf_flr_done_reg0(7);

        end generate;

        --Kintex Ultrascale devices
        g_ultrascale: if (CARD_TYPE = 105 or CARD_TYPE = 711 or CARD_TYPE = 712 or CARD_TYPE = 105) generate
            signal cfg_flr_in_process: std_logic_vector(3 downto 0);
            signal cfg_vf_flr_in_process: std_logic_vector(251 downto 0);
            signal cfg_flr_done, cfg_flr_done_reg0, cfg_flr_done_reg1: std_logic_vector(3 downto 0);
            signal cfg_vf_flr_done, cfg_vf_flr_done_reg0, cfg_vf_flr_done_reg1: std_logic_vector(251 downto 0);
        begin

            refclk_buff: IBUFDS_GTE3 port map( -- @suppress "Generic map uses default values. Missing optional actuals: REFCLK_EN_TX_PATH, REFCLK_HROW_CK_SEL, REFCLK_ICNTL_RX"
                    O => sys_clk_gt,
                    ODIV2 => sys_clk, -- default is no divide
                    CEB => '0',
                    I => sys_clk_p,
                    IB => sys_clk_n                );
            g_endpoint_0: if(PCIE_ENDPOINT=0) generate
                u1 : pcie3_ultrascale_7038
                    PORT MAP (
                        pci_exp_txn => pci_exp_txn(7 downto 0),
                        pci_exp_txp => pci_exp_txp(7 downto 0),
                        pci_exp_rxn => pci_exp_rxn(7 downto 0),
                        pci_exp_rxp => pci_exp_rxp(7 downto 0),
                        user_clk => user_clk,
                        user_reset => user_reset,
                        user_lnk_up => user_lnk_up,
                        s_axis_rq_tdata => s_axis_rq.tdata(255 downto 0),
                        s_axis_rq_tkeep => s_axis_rq.tkeep(7 downto 0),
                        s_axis_rq_tlast => s_axis_rq.tlast,
                        s_axis_rq_tready => s_axis_rq_tready,
                        s_axis_rq_tuser => x"0000000000000FF",
                        s_axis_rq_tvalid => s_axis_rq.tvalid,
                        m_axis_rc_tdata => m_axis_rc.tdata(255 downto 0),
                        m_axis_rc_tkeep => m_axis_rc.tkeep(7 downto 0),
                        m_axis_rc_tlast => m_axis_rc.tlast,
                        m_axis_rc_tready => m_axis_r_rc.tready,
                        m_axis_rc_tuser => open,
                        m_axis_rc_tvalid => m_axis_rc.tvalid,
                        m_axis_cq_tdata => m_axis_cq.tdata(255 downto 0),
                        m_axis_cq_tkeep => m_axis_cq.tkeep(7 downto 0),
                        m_axis_cq_tlast => m_axis_cq.tlast,
                        m_axis_cq_tready => m_axis_r_cq.tready,
                        m_axis_cq_tuser => m_axis_cq.tuser(84 downto 0),
                        m_axis_cq_tvalid => m_axis_cq.tvalid,
                        s_axis_cc_tdata => s_axis_cc.tdata(255 downto 0),
                        s_axis_cc_tkeep => s_axis_cc.tkeep(7 downto 0),
                        s_axis_cc_tlast => s_axis_cc.tlast,
                        s_axis_cc_tready => s_axis_cc_tready,
                        s_axis_cc_tuser => (others => '0'),
                        s_axis_cc_tvalid => s_axis_cc.tvalid,
                        pcie_rq_seq_num => open,
                        pcie_rq_seq_num_vld => open,
                        pcie_rq_tag => open,
                        --pcie_rq_tag_av => pcie_rq_tag_av,     -- bk not present on 7-series core?
                        pcie_rq_tag_av => open, -- bk   FIXME        
                        pcie_rq_tag_vld => open,
                        pcie_tfc_nph_av => open,
                        pcie_tfc_npd_av => open,
                        pcie_cq_np_req => '1',
                        pcie_cq_np_req_count => open,
                        cfg_phy_link_down => open,
                        cfg_phy_link_status => open,
                        cfg_negotiated_width => open,
                        cfg_current_speed => open,
                        cfg_max_payload => open,
                        cfg_max_read_req => open,
                        cfg_function_status => open,
                        cfg_function_power_state => open,
                        cfg_vf_status => open,
                        cfg_vf_power_state => open,
                        cfg_link_power_state => open,
                        cfg_mgmt_addr => cfg_mgmt_addr,
                        cfg_mgmt_write => cfg_mgmt_write,
                        cfg_mgmt_write_data => cfg_mgmt_write_data,
                        cfg_mgmt_byte_enable => cfg_mgmt_byte_enable,
                        cfg_mgmt_read => cfg_mgmt_read,
                        cfg_mgmt_read_data => cfg_mgmt_read_data,
                        cfg_mgmt_read_write_done => cfg_mgmt_read_write_done,
                        cfg_mgmt_type1_cfg_reg_access => '0',
                        cfg_err_cor_out => open,
                        cfg_err_nonfatal_out => open,
                        cfg_err_fatal_out => open,
                        cfg_local_error => open,
                        cfg_ltr_enable => open,
                        cfg_ltssm_state => open,
                        cfg_rcb_status => open,
                        cfg_dpa_substate_change => open,
                        cfg_obff_enable => open,
                        cfg_pl_status_change => open,
                        cfg_tph_requester_enable => open,
                        cfg_tph_st_mode => open,
                        cfg_vf_tph_requester_enable => open,
                        cfg_vf_tph_st_mode => open,
                        cfg_msg_received => open,
                        cfg_msg_received_data => open,
                        cfg_msg_received_type => open,
                        cfg_msg_transmit => '0',
                        cfg_msg_transmit_type => "000",
                        cfg_msg_transmit_data => x"00000000",
                        cfg_msg_transmit_done => open,
                        cfg_fc_ph => cfg_fc_ph,
                        cfg_fc_pd => cfg_fc_pd,
                        cfg_fc_nph => cfg_fc_nph,
                        cfg_fc_npd => cfg_fc_npd,
                        cfg_fc_cplh => cfg_fc_cplh,
                        cfg_fc_cpld => cfg_fc_cpld,
                        cfg_fc_sel => cfg_fc_sel,
                        cfg_per_func_status_control => "000",
                        cfg_per_func_status_data => open,
                        cfg_per_function_number => "0000",
                        cfg_per_function_output_request => '0',
                        cfg_per_function_update_done => open,
                        cfg_dsn => x"00000001_01_000A35",
                        cfg_power_state_change_ack => cfg_power_state_change_ack,
                        cfg_power_state_change_interrupt => cfg_power_state_change_ack,
                        cfg_err_cor_in => '0',
                        cfg_err_uncor_in => '0',
                        cfg_flr_in_process => cfg_flr_in_process,
                        cfg_flr_done => cfg_flr_done,
                        cfg_vf_flr_in_process => cfg_vf_flr_in_process(7 downto 0),
                        cfg_vf_flr_done => cfg_vf_flr_done(7 downto 0),
                        cfg_link_training_enable => '1',
                        cfg_interrupt_int => "0000",
                        cfg_interrupt_pending => "0000",
                        cfg_interrupt_sent => open,
                        cfg_interrupt_msi_function_number => "0000",
                        cfg_interrupt_msix_enable => cfg_interrupt_msix_enable,
                        cfg_interrupt_msix_mask => open,
                        cfg_interrupt_msix_vf_enable => open,
                        cfg_interrupt_msix_vf_mask => open,
                        cfg_interrupt_msix_data => cfg_interrupt_msix_data,
                        cfg_interrupt_msix_address => cfg_interrupt_msix_address,
                        cfg_interrupt_msix_int => cfg_interrupt_msix_int,      
                        cfg_interrupt_msix_sent => s_cfg_interrupt_msix_sent,
                        cfg_interrupt_msix_fail => s_cfg_interrupt_msix_fail,
                        cfg_hot_reset_out => open,
                        cfg_config_space_enable => '1',
                        cfg_req_pm_transition_l23_ready => '0',
                        cfg_hot_reset_in => '0',
                        cfg_ds_port_number => x"00",
                        cfg_ds_bus_number => x"00",
                        cfg_ds_device_number => "00000",
                        cfg_ds_function_number => "000",
                        cfg_subsys_vend_id => x"10EE",
                        sys_clk => sys_clk,
                        sys_clk_gt => sys_clk_gt,
                        sys_reset => sys_rst_n,
                        int_qpll1lock_out => open,
                        int_qpll1outrefclk_out => open,
                        int_qpll1outclk_out => open,
                        phy_rdy_out => open
                    );

            end generate;

            g_endpoint_1: if(PCIE_ENDPOINT=1) generate
                u1 : pcie3_ultrascale_7039
                    PORT MAP (
                        pci_exp_txn => pci_exp_txn(7 downto 0),
                        pci_exp_txp => pci_exp_txp(7 downto 0),
                        pci_exp_rxn => pci_exp_rxn(7 downto 0),
                        pci_exp_rxp => pci_exp_rxp(7 downto 0),
                        user_clk => user_clk,
                        user_reset => user_reset,
                        user_lnk_up => user_lnk_up,
                        s_axis_rq_tdata => s_axis_rq.tdata(255 downto 0),
                        s_axis_rq_tkeep => s_axis_rq.tkeep(7 downto 0),
                        s_axis_rq_tlast => s_axis_rq.tlast,
                        s_axis_rq_tready => s_axis_rq_tready,
                        s_axis_rq_tuser => x"0000000000000FF",
                        s_axis_rq_tvalid => s_axis_rq.tvalid,
                        m_axis_rc_tdata => m_axis_rc.tdata(255 downto 0),
                        m_axis_rc_tkeep => m_axis_rc.tkeep(7 downto 0),
                        m_axis_rc_tlast => m_axis_rc.tlast,
                        m_axis_rc_tready => m_axis_r_rc.tready,
                        m_axis_rc_tuser => open,
                        m_axis_rc_tvalid => m_axis_rc.tvalid,
                        m_axis_cq_tdata => m_axis_cq.tdata(255 downto 0),
                        m_axis_cq_tkeep => m_axis_cq.tkeep(7 downto 0),
                        m_axis_cq_tlast => m_axis_cq.tlast,
                        m_axis_cq_tready => m_axis_r_cq.tready,
                        m_axis_cq_tuser => m_axis_cq.tuser(84 downto 0),
                        m_axis_cq_tvalid => m_axis_cq.tvalid,
                        s_axis_cc_tdata => s_axis_cc.tdata(255 downto 0),
                        s_axis_cc_tkeep => s_axis_cc.tkeep(7 downto 0),
                        s_axis_cc_tlast => s_axis_cc.tlast,
                        s_axis_cc_tready => s_axis_cc_tready,
                        s_axis_cc_tuser => (others => '0'),
                        s_axis_cc_tvalid => s_axis_cc.tvalid,
                        pcie_rq_seq_num => open,
                        pcie_rq_seq_num_vld => open,
                        pcie_rq_tag => open,
                        pcie_rq_tag_av => open, -- bk   FIXME        
                        pcie_rq_tag_vld => open,
                        pcie_tfc_nph_av => open,
                        pcie_tfc_npd_av => open,
                        pcie_cq_np_req => '1',
                        pcie_cq_np_req_count => open,
                        cfg_phy_link_down => open,
                        cfg_phy_link_status => open,
                        cfg_negotiated_width => open,
                        cfg_current_speed => open,
                        cfg_max_payload => open,
                        cfg_max_read_req => open,
                        cfg_function_status => open,
                        cfg_function_power_state => open,
                        cfg_vf_status => open,
                        cfg_vf_power_state => open,
                        cfg_link_power_state => open,
                        cfg_mgmt_addr => cfg_mgmt_addr,
                        cfg_mgmt_write => cfg_mgmt_write,
                        cfg_mgmt_write_data => cfg_mgmt_write_data,
                        cfg_mgmt_byte_enable => cfg_mgmt_byte_enable,
                        cfg_mgmt_read => cfg_mgmt_read,
                        cfg_mgmt_read_data => cfg_mgmt_read_data,
                        cfg_mgmt_read_write_done => cfg_mgmt_read_write_done,
                        cfg_mgmt_type1_cfg_reg_access => '0',
                        cfg_err_cor_out => open,
                        cfg_err_nonfatal_out => open,
                        cfg_err_fatal_out => open,
                        cfg_local_error => open,
                        cfg_ltr_enable => open,
                        cfg_ltssm_state => open,
                        cfg_rcb_status => open,
                        cfg_dpa_substate_change => open,
                        cfg_obff_enable => open,
                        cfg_pl_status_change => open,
                        cfg_tph_requester_enable => open,
                        cfg_tph_st_mode => open,
                        cfg_vf_tph_requester_enable => open,
                        cfg_vf_tph_st_mode => open,
                        cfg_msg_received => open,
                        cfg_msg_received_data => open,
                        cfg_msg_received_type => open,
                        cfg_msg_transmit => '0',
                        cfg_msg_transmit_type => "000",
                        cfg_msg_transmit_data => x"00000000",
                        cfg_msg_transmit_done => open,
                        cfg_fc_ph => cfg_fc_ph,
                        cfg_fc_pd => cfg_fc_pd,
                        cfg_fc_nph => cfg_fc_nph,
                        cfg_fc_npd => cfg_fc_npd,
                        cfg_fc_cplh => cfg_fc_cplh,
                        cfg_fc_cpld => cfg_fc_cpld,
                        cfg_fc_sel => cfg_fc_sel,
                        cfg_per_func_status_control => "000",
                        cfg_per_func_status_data => open,
                        cfg_per_function_number => "0000",
                        cfg_per_function_output_request => '0',
                        cfg_per_function_update_done => open,
                        cfg_dsn => x"00000001_01_000A35",
                        cfg_power_state_change_ack => cfg_power_state_change_ack,
                        cfg_power_state_change_interrupt => cfg_power_state_change_ack,
                        cfg_err_cor_in => '0',
                        cfg_err_uncor_in => '0',
                        cfg_flr_in_process => cfg_flr_in_process,
                        cfg_flr_done => cfg_flr_done,
                        cfg_vf_flr_in_process => cfg_vf_flr_in_process(7 downto 0),
                        cfg_vf_flr_done => cfg_vf_flr_done(7 downto 0),
                        cfg_link_training_enable => '1',
                        cfg_interrupt_int => "0000",
                        cfg_interrupt_pending => "0000",
                        cfg_interrupt_sent => open,
                        cfg_interrupt_msi_function_number => "0000",
                        cfg_interrupt_msix_enable => cfg_interrupt_msix_enable,
                        cfg_interrupt_msix_mask => open,
                        cfg_interrupt_msix_vf_enable => open,
                        cfg_interrupt_msix_vf_mask => open,
                        cfg_interrupt_msix_data => cfg_interrupt_msix_data,
                        cfg_interrupt_msix_address => cfg_interrupt_msix_address,
                        cfg_interrupt_msix_int => cfg_interrupt_msix_int,
                        cfg_interrupt_msix_sent => s_cfg_interrupt_msix_sent,
                        cfg_interrupt_msix_fail => s_cfg_interrupt_msix_fail,
                        cfg_hot_reset_out => open,
                        cfg_config_space_enable => '1',
                        cfg_req_pm_transition_l23_ready => '0',
                        cfg_hot_reset_in => '0',
                        cfg_ds_port_number => x"00",
                        cfg_ds_bus_number => x"00",
                        cfg_ds_device_number => "00000",
                        cfg_ds_function_number => "000",
                        cfg_subsys_vend_id => x"10EE",
                        sys_clk => sys_clk,
                        sys_clk_gt => sys_clk_gt,
                        sys_reset => sys_rst_n,
                        int_qpll1lock_out => open,
                        int_qpll1outrefclk_out => open,
                        int_qpll1outclk_out => open,
                        phy_rdy_out => open
                    );

            end generate;

            cfg_flr: process(user_clk)
            begin
                if (rising_edge(user_clk)) then
                    if (user_reset = '1') then
                        cfg_flr_done_reg0       <= (others => '0');
                        cfg_vf_flr_done_reg0    <= (others => '0');
                        cfg_flr_done_reg1       <= (others => '0');
                        cfg_vf_flr_done_reg1    <= (others => '0');
                    else
                        cfg_flr_done_reg0       <= cfg_flr_in_process;
                        cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process;
                        cfg_flr_done_reg1       <= cfg_flr_done_reg0;
                        cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;
                    end if;
                end if;
            end process;

            cfg_flr_done(0) <= (not cfg_flr_done_reg1(0)) and cfg_flr_done_reg0(0);
            cfg_flr_done(1) <= (not cfg_flr_done_reg1(1)) and cfg_flr_done_reg0(1);
            cfg_flr_done(2) <= (not cfg_flr_done_reg1(2)) and cfg_flr_done_reg0(2);
            cfg_flr_done(3) <= (not cfg_flr_done_reg1(3)) and cfg_flr_done_reg0(3);
    

            cfg_vf_flr_done(0) <= (not cfg_vf_flr_done_reg1(0)) and cfg_vf_flr_done_reg0(0);
            cfg_vf_flr_done(1) <= (not cfg_vf_flr_done_reg1(1)) and cfg_vf_flr_done_reg0(1);
            cfg_vf_flr_done(2) <= (not cfg_vf_flr_done_reg1(2)) and cfg_vf_flr_done_reg0(2);
            cfg_vf_flr_done(3) <= (not cfg_vf_flr_done_reg1(3)) and cfg_vf_flr_done_reg0(3);
            cfg_vf_flr_done(4) <= (not cfg_vf_flr_done_reg1(4)) and cfg_vf_flr_done_reg0(4);
            cfg_vf_flr_done(5) <= (not cfg_vf_flr_done_reg1(5)) and cfg_vf_flr_done_reg0(5);
            cfg_vf_flr_done(6) <= (not cfg_vf_flr_done_reg1(6)) and cfg_vf_flr_done_reg0(6);
            cfg_vf_flr_done(7) <= (not cfg_vf_flr_done_reg1(7)) and cfg_vf_flr_done_reg0(7);

        end generate;
    
    
--Virtex Ultrascale plus x16 devices
        g_ultrascale_plus: if (CARD_TYPE = 128 or CARD_TYPE = 800 or CARD_TYPE = 801) generate
            signal cfg_power_state_change_interrupt: std_logic;

            signal cfg_flr_done_reg0: std_logic_vector(1 downto 0);
            signal cfg_vf_flr_done_reg0: std_logic_vector(5 downto 0);
            signal cfg_flr_done_reg1: std_logic_vector(1 downto 0);
            signal cfg_vf_flr_done_reg1: std_logic_vector(5 downto 0);
            signal cfg_vf_flr_func_num_reg: std_logic_vector(7 downto 0);
            signal cfg_flr_in_process: std_logic_vector(3 downto 0);
            signal cfg_flr_done: std_logic_vector(3 downto 0);

            signal cfg_vf_flr_in_process: std_logic_vector(251 downto 0);
            signal cfg_vf_flr_func_num: std_logic_vector(7 downto 0);
            signal cfg_vf_flr_done: std_logic_vector(0 downto 0);
        
        
    begin

            refclk_buff: IBUFDS_GTE4 port map( -- @suppress "Generic map uses default values. Missing optional actuals: REFCLK_EN_TX_PATH, REFCLK_HROW_CK_SEL, REFCLK_ICNTL_RX"
                    O => sys_clk_gt,
                    ODIV2 => sys_clk, -- default is no divide
                    CEB => '0',
                    I => sys_clk_p,
                    IB => sys_clk_n);

            s_axis_rq_tuser(7 downto 0) <= x"0F";    --first be
            s_axis_rq_tuser(15 downto 8) <= x"0F";   --last be
            s_axis_rq_tuser(19 downto 16) <= x"0";   --addr_offset
            s_axis_rq_tuser(21 downto 20) <= "00";   --is_sop
            s_axis_rq_tuser(23 downto 22) <= "00";   --is_sop0_ptr
            s_axis_rq_tuser(25 downto 24) <= "00";   --is_sop1_ptr
            s_axis_rq_tuser(27 downto 26) <= "00";   --is_eop
            s_axis_rq_tuser(31 downto 28) <= "0000"; --is_eop0_ptr
            s_axis_rq_tuser(35 downto 32) <= "0000"; --is_eop1_ptr
            s_axis_rq_tuser(36) <= '0';              --discontinue
            s_axis_rq_tuser(38 downto 37) <= "00";   --tph_present
            s_axis_rq_tuser(42 downto 39) <= "0000"; --tph_type
            s_axis_rq_tuser(44 downto 43) <= "00";   --tph_indirect_tag_en
            s_axis_rq_tuser(60 downto 45) <= x"0000";--tph_st_tag
            s_axis_rq_tuser(72 downto 61) <= x"000"; --seq_num 0 and 1
            s_axis_rq_tuser(136 downto 73) <= x"0000_0000_0000_0000"; --parity

            g_ep0: if PCIE_ENDPOINT = 0 generate
                u1: pcie4c_uscale_plus_0
                    PORT MAP (
                        pci_exp_txn => pci_exp_txn,
                        pci_exp_txp => pci_exp_txp,
                        pci_exp_rxn => pci_exp_rxn,
                        pci_exp_rxp => pci_exp_rxp,
                        user_clk => user_clk,
                        user_reset => user_reset,
                        user_lnk_up => user_lnk_up,
                        s_axis_rq_tdata => s_axis_rq.tdata(DATA_WIDTH-1 downto 0),
                        s_axis_rq_tkeep => s_axis_rq.tkeep,
                        s_axis_rq_tlast => s_axis_rq.tlast,
                        s_axis_rq_tready => s_axis_rq_tready,
                        --3:0 => "1111" : First BE
                        --11:8 => "1111" : Last BE
                        --21:20 => "01" : is_sop for single TLP
                        --27:26 => "01" : is_eop for single TLP
                        s_axis_rq_tuser => s_axis_rq_tuser,
                        s_axis_rq_tvalid => s_axis_rq.tvalid,
                        m_axis_rc_tdata => m_axis_rc_s.tdata(DATA_WIDTH-1 downto 0),
                        m_axis_rc_tkeep => m_axis_rc_s.tkeep,
                        m_axis_rc_tlast => m_axis_rc_s.tlast,
                        m_axis_rc_tready => m_axis_r_rc.tready,
                        m_axis_rc_tuser => open,
                        m_axis_rc_tvalid => m_axis_rc_s.tvalid,
                        m_axis_cq_tdata => m_axis_cq_s.tdata(DATA_WIDTH-1 downto 0),
                        m_axis_cq_tkeep => m_axis_cq_s.tkeep,
                        m_axis_cq_tlast => m_axis_cq_s.tlast,
                        m_axis_cq_tready => m_axis_r_cq.tready,
                        m_axis_cq_tuser => m_axis_cq_s.tuser,
                        m_axis_cq_tvalid => m_axis_cq_s.tvalid,
                        s_axis_cc_tdata => s_axis_cc.tdata(DATA_WIDTH-1 downto 0),
                        s_axis_cc_tkeep => s_axis_cc.tkeep,
                        s_axis_cc_tlast => s_axis_cc.tlast,
                        s_axis_cc_tready => s_axis_cc_tready,
                        s_axis_cc_tuser => (others => '0'),
                        s_axis_cc_tvalid => s_axis_cc.tvalid,
                        pcie_rq_seq_num0 => open,
                        pcie_rq_seq_num_vld0 => open,
                        pcie_rq_seq_num1 => open,
                        pcie_rq_seq_num_vld1 => open,
                        pcie_rq_tag0 => open,
                        pcie_rq_tag1 => open,
                        pcie_rq_tag_av => open,
                        pcie_rq_tag_vld0 => open,
                        pcie_rq_tag_vld1 => open,
                        pcie_tfc_nph_av => open,
                        pcie_tfc_npd_av => open,
                        pcie_cq_np_req => "11",
                        pcie_cq_np_req_count => open,
                        cfg_phy_link_down => open,
                        cfg_phy_link_status => open,
                        cfg_negotiated_width => open,
                        cfg_current_speed => open,
                        cfg_max_payload => open,
                        cfg_max_read_req => open,
                        cfg_function_status => open,
                        cfg_function_power_state => open,
                        cfg_vf_status => open,
                        cfg_vf_power_state => open,
                        cfg_link_power_state => open,
                        cfg_mgmt_addr => (others => '0'),
                        cfg_mgmt_function_number => x"00",
                        cfg_mgmt_write => '0',
                        cfg_mgmt_write_data => (others => '0'),
                        cfg_mgmt_byte_enable => "0000",
                        cfg_mgmt_read => '0',
                        cfg_mgmt_read_data => open,
                        cfg_mgmt_read_write_done => open,
                        cfg_mgmt_debug_access => '0', --was cfg_mgmt_type1_cfg_reg_access
                        cfg_err_cor_out => cfg_err_cor_out(0),
                        cfg_err_nonfatal_out => cfg_err_nonfatal_out(0),
                        cfg_err_fatal_out => cfg_err_fatal_out(0),
                        cfg_local_error_valid => cfg_local_error_valid(0),
                        cfg_local_error_out => cfg_local_error_out,
                        cfg_ltssm_state => cfg_ltssm_state,
                        cfg_rx_pm_state => cfg_rx_pm_state,
                        cfg_tx_pm_state => cfg_tx_pm_state,
                        cfg_rcb_status => cfg_rcb_status,
                        cfg_obff_enable => cfg_obff_enable,
                        cfg_pl_status_change => open,
                        cfg_tph_requester_enable => open,
                        cfg_tph_st_mode => open,
                        cfg_vf_tph_requester_enable => open,
                        cfg_vf_tph_st_mode => open,
                        cfg_msg_received => open,
                        cfg_msg_received_data => open,
                        cfg_msg_received_type => open,
                        cfg_msg_transmit => '0',
                        cfg_msg_transmit_type => "000",
                        cfg_msg_transmit_data => x"00000000",
                        cfg_msg_transmit_done => open,
                        cfg_fc_ph => open,
                        cfg_fc_pd => open,
                        cfg_fc_nph => open,
                        cfg_fc_npd => open,
                        cfg_fc_cplh => open,
                        cfg_fc_cpld => open,
                        cfg_fc_sel => "000",
                        cfg_dsn => x"00000001_01_000A35",
                        cfg_bus_number => open,
                        cfg_power_state_change_ack => cfg_power_state_change_ack,
                        cfg_power_state_change_interrupt => cfg_power_state_change_interrupt,
                        cfg_err_cor_in => '0',
                        cfg_err_uncor_in => '0',
                        cfg_flr_in_process => cfg_flr_in_process,
                        cfg_flr_done => cfg_flr_done,
                        cfg_vf_flr_in_process => cfg_vf_flr_in_process,
                        cfg_vf_flr_func_num => cfg_vf_flr_func_num,
                        cfg_vf_flr_done => cfg_vf_flr_done,
                        cfg_link_training_enable => '1',
                        cfg_interrupt_int => "0000",
                        cfg_interrupt_pending => "0000",
                        cfg_interrupt_sent => open,
                        cfg_interrupt_msi_sent => cfg_interrupt_msix_sent,
                        cfg_interrupt_msi_fail => cfg_interrupt_msix_fail,
                        cfg_interrupt_msi_function_number => x"00",
                        cfg_interrupt_msix_enable => cfg_interrupt_msix_enable,
                        cfg_interrupt_msix_mask => open,
                        cfg_interrupt_msix_vf_enable => open,
                        cfg_interrupt_msix_vf_mask => open,
                        cfg_pm_aspm_l1_entry_reject => '0',
                        cfg_pm_aspm_tx_l0s_entry_disable => '1',
                        cfg_interrupt_msix_data => cfg_interrupt_msix_data,
                        cfg_interrupt_msix_address => cfg_interrupt_msix_address,
                        cfg_interrupt_msix_int => cfg_interrupt_msix_int,
                        cfg_interrupt_msix_vec_pending => "00",
                        cfg_interrupt_msix_vec_pending_status => open,
                        cfg_hot_reset_out => open,
                        cfg_config_space_enable => '1',
                        cfg_req_pm_transition_l23_ready => '0',
                        cfg_hot_reset_in => '0',
                        cfg_ds_port_number => x"00",
                        cfg_ds_bus_number => x"00",
                        cfg_ds_device_number => "00000",
                        cfg_subsys_vend_id => x"10DC",
                        cfg_dev_id_pf0 => DEVICE_ID(PCIE_ENDPOINT),
                        cfg_vend_id => x"10DC",
                        cfg_rev_id_pf0 => x"00",
                        cfg_subsys_id_pf0 => x"0038",
                        sys_clk => sys_clk,
                        sys_clk_gt => sys_clk_gt,
                        sys_reset => sys_rst_n,
                        conf_req_type => "00",
                        conf_req_reg_num => "0000",
                        conf_req_data => x"0000_0000",
                        conf_req_valid => '0',
                        conf_req_ready => open,
                        conf_resp_rdata => open,
                        conf_resp_valid => open,
                        cap_req => open,
                        cap_gnt => '1',
                        cap_rel => '0',
                        mcap_design_switch => open,
                        phy_rdy_out => open
                    );
            end generate;
            g_ep1: if PCIE_ENDPOINT = 1 generate
                u1: pcie4c_uscale_plus_1
                    PORT MAP (
                        pci_exp_txn => pci_exp_txn,
                        pci_exp_txp => pci_exp_txp,
                        pci_exp_rxn => pci_exp_rxn,
                        pci_exp_rxp => pci_exp_rxp,
                        user_clk => user_clk,
                        user_reset => user_reset,
                        user_lnk_up => user_lnk_up,
                        s_axis_rq_tdata => s_axis_rq.tdata(DATA_WIDTH-1 downto 0),
                        s_axis_rq_tkeep => s_axis_rq.tkeep,
                        s_axis_rq_tlast => s_axis_rq.tlast,
                        s_axis_rq_tready => s_axis_rq_tready,
                        --3:0 => "1111" : First BE
                        --11:8 => "1111" : Last BE
                        --21:20 => "01" : is_sop for single TLP
                        --27:26 => "01" : is_eop for single TLP
                        s_axis_rq_tuser => s_axis_rq_tuser,
                        s_axis_rq_tvalid => s_axis_rq.tvalid,
                        m_axis_rc_tdata => m_axis_rc_s.tdata(DATA_WIDTH-1 downto 0),
                        m_axis_rc_tkeep => m_axis_rc_s.tkeep,
                        m_axis_rc_tlast => m_axis_rc_s.tlast,
                        m_axis_rc_tready => m_axis_r_rc.tready,
                        m_axis_rc_tuser => open,
                        m_axis_rc_tvalid => m_axis_rc_s.tvalid,
                        m_axis_cq_tdata => m_axis_cq_s.tdata(DATA_WIDTH-1 downto 0),
                        m_axis_cq_tkeep => m_axis_cq_s.tkeep,
                        m_axis_cq_tlast => m_axis_cq_s.tlast,
                        m_axis_cq_tready => m_axis_r_cq.tready,
                        m_axis_cq_tuser => m_axis_cq_s.tuser,
                        m_axis_cq_tvalid => m_axis_cq_s.tvalid,
                        s_axis_cc_tdata => s_axis_cc.tdata(DATA_WIDTH-1 downto 0),
                        s_axis_cc_tkeep => s_axis_cc.tkeep,
                        s_axis_cc_tlast => s_axis_cc.tlast,
                        s_axis_cc_tready => s_axis_cc_tready,
                        s_axis_cc_tuser => (others => '0'),
                        s_axis_cc_tvalid => s_axis_cc.tvalid,
                        pcie_rq_seq_num0 => open,
                        pcie_rq_seq_num_vld0 => open,
                        pcie_rq_seq_num1 => open,
                        pcie_rq_seq_num_vld1 => open,
                        pcie_rq_tag0 => open,
                        pcie_rq_tag1 => open,
                        pcie_rq_tag_av => open,
                        pcie_rq_tag_vld0 => open,
                        pcie_rq_tag_vld1 => open,
                        pcie_tfc_nph_av => open,
                        pcie_tfc_npd_av => open,
                        pcie_cq_np_req => "11",
                        pcie_cq_np_req_count => open,
                        cfg_phy_link_down => open,
                        cfg_phy_link_status => open,
                        cfg_negotiated_width => open,
                        cfg_current_speed => open,
                        cfg_max_payload => open,
                        cfg_max_read_req => open,
                        cfg_function_status => open,
                        cfg_function_power_state => open,
                        cfg_vf_status => open,
                        cfg_vf_power_state => open,
                        cfg_link_power_state => open,
                        cfg_mgmt_addr => (others => '0'),
                        cfg_mgmt_function_number => x"00",
                        cfg_mgmt_write => '0',
                        cfg_mgmt_write_data => (others => '0'),
                        cfg_mgmt_byte_enable => "0000",
                        cfg_mgmt_read => '0',
                        cfg_mgmt_read_data => open,
                        cfg_mgmt_read_write_done => open,
                        cfg_mgmt_debug_access => '0', --was cfg_mgmt_type1_cfg_reg_access
                        cfg_err_cor_out => cfg_err_cor_out(0),
                        cfg_err_nonfatal_out => cfg_err_nonfatal_out(0),
                        cfg_err_fatal_out => cfg_err_fatal_out(0),
                        cfg_local_error_valid => cfg_local_error_valid(0),
                        cfg_local_error_out => cfg_local_error_out,
                        cfg_ltssm_state => cfg_ltssm_state,
                        cfg_rx_pm_state => cfg_rx_pm_state,
                        cfg_tx_pm_state => cfg_tx_pm_state,
                        cfg_rcb_status => cfg_rcb_status,
                        cfg_obff_enable => cfg_obff_enable,
                        cfg_pl_status_change => open,
                        cfg_tph_requester_enable => open,
                        cfg_tph_st_mode => open,
                        cfg_vf_tph_requester_enable => open,
                        cfg_vf_tph_st_mode => open,
                        cfg_msg_received => open,
                        cfg_msg_received_data => open,
                        cfg_msg_received_type => open,
                        cfg_msg_transmit => '0',
                        cfg_msg_transmit_type => "000",
                        cfg_msg_transmit_data => x"00000000",
                        cfg_msg_transmit_done => open,
                        cfg_fc_ph => open,
                        cfg_fc_pd => open,
                        cfg_fc_nph => open,
                        cfg_fc_npd => open,
                        cfg_fc_cplh => open,
                        cfg_fc_cpld => open,
                        cfg_fc_sel => "000",
                        cfg_dsn => x"00000001_01_000A35",
                        cfg_bus_number => open,
                        cfg_power_state_change_ack => cfg_power_state_change_ack,
                        cfg_power_state_change_interrupt => cfg_power_state_change_interrupt,
                        cfg_err_cor_in => '0',
                        cfg_err_uncor_in => '0',
                        cfg_flr_in_process => cfg_flr_in_process,
                        cfg_flr_done => cfg_flr_done,
                        cfg_vf_flr_in_process => cfg_vf_flr_in_process,
                        cfg_vf_flr_func_num => cfg_vf_flr_func_num,
                        cfg_vf_flr_done => cfg_vf_flr_done,
                        cfg_link_training_enable => '1',
                        cfg_interrupt_int => "0000",
                        cfg_interrupt_pending => "0000",
                        cfg_interrupt_sent => open,
                        cfg_interrupt_msi_sent => cfg_interrupt_msix_sent,
                        cfg_interrupt_msi_fail => cfg_interrupt_msix_fail,
                        cfg_interrupt_msi_function_number => x"00",
                        cfg_interrupt_msix_enable => cfg_interrupt_msix_enable,
                        cfg_interrupt_msix_mask => open,
                        cfg_interrupt_msix_vf_enable => open,
                        cfg_interrupt_msix_vf_mask => open,
                        cfg_pm_aspm_l1_entry_reject => '0',
                        cfg_pm_aspm_tx_l0s_entry_disable => '1',
                        cfg_interrupt_msix_data => cfg_interrupt_msix_data,
                        cfg_interrupt_msix_address => cfg_interrupt_msix_address,
                        cfg_interrupt_msix_int => cfg_interrupt_msix_int,
                        cfg_interrupt_msix_vec_pending => "00",
                        cfg_interrupt_msix_vec_pending_status => open,
                        cfg_hot_reset_out => open,
                        cfg_config_space_enable => '1',
                        cfg_req_pm_transition_l23_ready => '0',
                        cfg_hot_reset_in => '0',
                        cfg_ds_port_number => x"00",
                        cfg_ds_bus_number => x"00",
                        cfg_ds_device_number => "00000",
                        cfg_subsys_vend_id => x"10DC",
                        cfg_dev_id_pf0 => DEVICE_ID(PCIE_ENDPOINT),
                        cfg_vend_id => x"10DC",
                        cfg_rev_id_pf0 => x"00",
                        cfg_subsys_id_pf0 => x"0038",
                        sys_clk => sys_clk,
                        sys_clk_gt => sys_clk_gt,
                        sys_reset => sys_rst_n,
                        conf_req_type => "00",
                        conf_req_reg_num => "0000",
                        conf_req_data => x"0000_0000",
                        conf_req_valid => '0',
                        conf_req_ready => open,
                        conf_resp_rdata => open,
                        conf_resp_valid => open,
                        cap_req => open,
                        cap_gnt => '1',
                        cap_rel => '0',
                        mcap_design_switch => open,
                        phy_rdy_out => open
                    );
            end generate;

            process(user_clk)
            begin
                if rising_edge(user_clk) then
                    if (user_reset = '1' ) then
                        cfg_power_state_change_ack <= '0';
                    else
                        if ( cfg_power_state_change_interrupt = '1') then
                            cfg_power_state_change_ack <= '1';
                        else
                            cfg_power_state_change_ack <= '0';
                        end if;
                    end if;
                end if;
            end process;
    
        
  flr_proc: process(user_clk)
            begin
                if rising_edge(user_clk) then
                    if (user_reset = '1') then
                        cfg_flr_done_reg0(1 downto 0)       <= "00";
                        cfg_vf_flr_done_reg0                <= "000000";
                        cfg_flr_done_reg1(1 downto 0)       <= "00";
                        cfg_vf_flr_done_reg1                <= "000000";

                    else
                        cfg_flr_done_reg0       <= cfg_flr_in_process(1 downto 0);
                        cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process(5 downto 0);
                        cfg_flr_done_reg1       <= cfg_flr_done_reg0;
                        cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;

                    end if;
                end if;
            end process;

            -- assign function level reset outputs.
            cfg_flr_done(0) <= (not cfg_flr_done_reg1(0)) and cfg_flr_done_reg0(0);
            cfg_flr_done(1) <= (not cfg_flr_done_reg1(1)) and cfg_flr_done_reg0(1);
            cfg_vf_flr_done(0) <= (not cfg_vf_flr_done_reg1(0)) and cfg_vf_flr_done_reg0(0); 
        
        
  
  func_num: process( user_clk)
            begin
                if rising_edge(user_clk) then
                    if (user_reset = '1') then
                        cfg_vf_flr_func_num_reg <= x"00";
                    else
                        cfg_vf_flr_func_num_reg <= cfg_vf_flr_func_num_reg + x"01";
                    end if;
                end if;
            end process;

            cfg_vf_flr_func_num <= cfg_vf_flr_func_num_reg;

            m_axis_cq    <= m_axis_cq_s   ;
            m_axis_rc    <= m_axis_rc_s   ;


        end generate;

        --Versal prime devices (VMK180 board)
        g_versal: if (CARD_TYPE = 180) generate
            signal  cfg_power_state_change_interrupt: std_logic;

            signal  cfg_flr_done_reg0: std_logic_vector(3 downto 0);
            signal  cfg_vf_flr_done_reg0: std_logic_vector(5 downto 0);
            signal  cfg_flr_done_reg1: std_logic_vector(3 downto 0);
            signal  cfg_vf_flr_done_reg1: std_logic_vector(5 downto 0);
            signal  cfg_vf_flr_func_num_reg: std_logic_vector(7 downto 0);
            signal  cfg_flr_in_process: std_logic_vector(3 downto 0);
            signal  cfg_flr_done: std_logic_vector(3 downto 0);

            signal cfg_vf_flr_in_process: std_logic_vector(251 downto 0);
            signal cfg_vf_flr_func_num: std_logic_vector(7 downto 0);
            signal cfg_vf_flr_done: std_logic_vector(0 downto 0);
            
            signal m_axis_cq_tuser_s : std_logic_vector(228 downto 0);

            signal s_axis_rq_0_tuser : std_logic_vector(182 downto 0);
        begin


            s_axis_rq_0_tuser(7 downto 0) <= x"0F";    --first be
            s_axis_rq_0_tuser(15 downto 8) <= x"0F";   --last be
            s_axis_rq_0_tuser(19 downto 16) <= x"0";   --addr_offset
            s_axis_rq_0_tuser(21 downto 20) <= "00";   --is_sop
            s_axis_rq_0_tuser(23 downto 22) <= "00";   --is_sop0_ptr
            s_axis_rq_0_tuser(25 downto 24) <= "00";   --is_sop1_ptr
            s_axis_rq_0_tuser(27 downto 26) <= "00";   --is_eop
            s_axis_rq_0_tuser(31 downto 28) <= "0000"; --is_eop0_ptr
            s_axis_rq_0_tuser(35 downto 32) <= "0000"; --is_eop1_ptr
            s_axis_rq_0_tuser(36) <= '0';              --discontinue
            s_axis_rq_0_tuser(38 downto 37) <= "00";   --tph_present
            s_axis_rq_0_tuser(42 downto 39) <= "0000"; --tph_type
            s_axis_rq_0_tuser(44 downto 43) <= "00";   --tph_indirect_tag_en
            s_axis_rq_0_tuser(60 downto 45) <= x"0000";--tph_st_tag
            s_axis_rq_0_tuser(72 downto 61) <= x"000"; --seq_num 0 and 1
            s_axis_rq_0_tuser(136 downto 73) <= x"0000_0000_0000_0000"; --parity
            s_axis_rq_0_tuser(182 downto 137) <= (others => '0');


            u1: versal_pcie_block_wrapper
                PORT MAP ( -- @suppress "Port map uses default values. Missing optional actuals: cfg_pasid_exec_permission_enable, cfg_pasid_privil_mode_enable, pcie_ltssm_state"
                sys_reset => '1', --sys_reset,
                pcie4_cfg_interrupt_intx_vector => "0000",
                pcie4_cfg_interrupt_pending => "0000",
                pcie4_cfg_mgmt_addr => "0000000000",
                pcie4_cfg_mgmt_byte_en => "0000",
                pcie4_cfg_mgmt_debug_access => '0',
                pcie4_cfg_mgmt_function_number => x"00",
                pcie4_cfg_mgmt_read_en => '0',
                pcie4_cfg_mgmt_write_data => x"00000000",
                pcie4_cfg_mgmt_write_en => '0',
                pcie4_cfg_interrupt_sent => open,
                pcie4_cfg_mgmt_read_data => open,
                pcie4_cfg_mgmt_read_write_done => open,
                m_axis_cq_tdata => m_axis_cq_s.tdata(511 downto 0),
                m_axis_cq_tkeep => m_axis_cq_s.tkeep,
                m_axis_cq_tlast => m_axis_cq_s.tlast,
                m_axis_cq_tready => m_axis_r_cq.tready,
                m_axis_cq_tuser => m_axis_cq_tuser_s,
                m_axis_cq_tvalid => m_axis_cq_s.tvalid,
                m_axis_rc_tdata => m_axis_rc_s.tdata(511 downto 0),
                m_axis_rc_tkeep => m_axis_rc_s.tkeep,
                m_axis_rc_tlast => m_axis_rc_s.tlast,
                m_axis_rc_tready => m_axis_r_rc.tready,
                m_axis_rc_tuser  => open, --m_axis_rc_s.tuser(160 downto 0),
                m_axis_rc_tvalid  => m_axis_rc_s.tvalid,
                pcie4_cfg_external_msix_without_msi_address => cfg_interrupt_msix_address,
                pcie4_cfg_external_msix_without_msi_data    => cfg_interrupt_msix_data,
                pcie4_cfg_external_msix_without_msi_enable  => cfg_interrupt_msix_enable,
                pcie4_cfg_external_msix_without_msi_fail    => cfg_interrupt_msix_fail,
                pcie4_cfg_external_msix_without_msi_function_number => x"00",
                pcie4_cfg_external_msix_without_msi_int_vector => '0',
                pcie4_cfg_external_msix_without_msi_mask => open,
                pcie4_cfg_external_msix_without_msi_sent => cfg_interrupt_msix_sent,
                pcie4_cfg_external_msix_without_msi_vec_pending  => "00",
                pcie4_cfg_external_msix_without_msi_vec_pending_status  => open,
                pcie4_cfg_external_msix_without_msi_vf_enable => open,
                pcie4_cfg_external_msix_without_msi_vf_mask  => open,
                pcie4_pf0_id_dev_id => DEVICE_ID(PCIE_ENDPOINT),
                pcie4_pf0_id_dev_subsys_id => x"0038",
                pcie4_pf0_id_rev_id  => x"00",
                pcie4_vend_id_subsys_vend_id  => x"10DC",
                pcie4_vend_id_vend_id  => x"10DC",
                pcie_mgt_grx_n => pci_exp_rxn(7 downto 0),
                pcie_mgt_grx_p => pci_exp_rxp(7 downto 0),
                pcie_mgt_gtx_n => pci_exp_txn(7 downto 0),
                pcie_mgt_gtx_p => pci_exp_txp(7 downto 0),
                pcie_refclk_clk_n(0) => sys_clk_n,
                pcie_refclk_clk_p(0) => sys_clk_p,
                s_axis_cc_tdata  => s_axis_cc.tdata(511 downto 0),
                s_axis_cc_tkeep  => s_axis_cc.tkeep,
                s_axis_cc_tlast  => s_axis_cc.tlast,
                s_axis_cc_tready  => s_axis_cc_tready, --s_axis_r_cc.tready,
                s_axis_cc_tuser => (others => '0'),
                s_axis_cc_tvalid  => s_axis_cc.tvalid,
                s_axis_rq_tdata => s_axis_rq.tdata(511 downto 0),
                s_axis_rq_tkeep => s_axis_rq.tkeep,
                s_axis_rq_tlast => s_axis_rq.tlast,
                s_axis_rq_tready => s_axis_rq_tready, --s_axis_r_rq.tready,
                s_axis_rq_tuser => s_axis_rq_0_tuser,
                s_axis_rq_tvalid  => s_axis_rq.tvalid,
                user_clk => user_clk,
                user_lnk_up => user_lnk_up,
                user_reset => user_reset,
                cfg_pasid_enable => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_fc_cpld  => open, --: out STD_LOGIC_VECTOR ( 11 downto 0 );
                pcie4_cfg_fc_cpld_scale  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_fc_cplh  => open, --: out STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_fc_cplh_scale  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_fc_npd  => open, --: out STD_LOGIC_VECTOR ( 11 downto 0 );
                pcie4_cfg_fc_npd_scale  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_fc_nph  => open, --: out STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_fc_nph_scale  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_fc_pd  => open, --: out STD_LOGIC_VECTOR ( 11 downto 0 );
                pcie4_cfg_fc_pd_scale  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_fc_ph  => open, --: out STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_fc_ph_scale  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_fc_sel  => "000", --: in STD_LOGIC_VECTOR ( 2 downto 0 );
                pcie4_cfg_mesg_rcvd_recd  => open, --: out STD_LOGIC;
                pcie4_cfg_mesg_rcvd_recd_data  => open, --: out STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_mesg_rcvd_recd_type  => open, --: out STD_LOGIC_VECTOR ( 4 downto 0 );
                pcie4_cfg_mesg_tx_transmit  => '0', --: in STD_LOGIC;
                pcie4_cfg_mesg_tx_transmit_data  => x"0000_0000", --: in STD_LOGIC_VECTOR ( 31 downto 0 );
                pcie4_cfg_mesg_tx_transmit_done  => open, --: out STD_LOGIC;
                pcie4_cfg_mesg_tx_transmit_type  => "000", --: in STD_LOGIC_VECTOR ( 2 downto 0 );
                pcie4_cfg_status_10b_tag_requester_enable  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_status_atomic_requester_enable  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_status_cq_np_req  => "11", --: in STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_cq_np_req_count  => open, --: out STD_LOGIC_VECTOR ( 5 downto 0 );
                pcie4_cfg_status_current_speed  => open, --: out STD_LOGIC_VECTOR ( 2 downto 0 );
                pcie4_cfg_status_err_cor_out  => open, --: out STD_LOGIC;
                pcie4_cfg_status_err_fatal_out  => open, --: out STD_LOGIC;
                pcie4_cfg_status_err_nonfatal_out  => open, --: out STD_LOGIC;
                pcie4_cfg_status_ext_tag_enable  => open, --: out STD_LOGIC;
                pcie4_cfg_status_function_power_state  => open, --: out STD_LOGIC_VECTOR ( 11 downto 0 );
                pcie4_cfg_status_function_status  => open, --: out STD_LOGIC_VECTOR ( 15 downto 0 );
                pcie4_cfg_status_link_power_state  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_local_error_out  => open, --: out STD_LOGIC_VECTOR ( 4 downto 0 );
                pcie4_cfg_status_local_error_valid  => open, --: out STD_LOGIC;
                pcie4_cfg_status_ltssm_state  => cfg_ltssm_state, --: out STD_LOGIC_VECTOR ( 5 downto 0 );
                pcie4_cfg_status_max_payload  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_max_read_req  => open, --: out STD_LOGIC_VECTOR ( 2 downto 0 );
                pcie4_cfg_status_negotiated_width  => open, --: out STD_LOGIC_VECTOR ( 2 downto 0 );
                pcie4_cfg_status_obff_enable  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_phy_link_down  => open, --: out STD_LOGIC;
                pcie4_cfg_status_phy_link_status  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_pl_status_change  => open, --: out STD_LOGIC;
                pcie4_cfg_status_rcb_status  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_status_rq_seq_num0  => open, --: out STD_LOGIC_VECTOR ( 5 downto 0 );
                pcie4_cfg_status_rq_seq_num1  => open, --: out STD_LOGIC_VECTOR ( 5 downto 0 );
                pcie4_cfg_status_rq_seq_num_vld0  => open, --: out STD_LOGIC;
                pcie4_cfg_status_rq_seq_num_vld1  => open, --: out STD_LOGIC;
                pcie4_cfg_status_rq_tag0  => open, --: out STD_LOGIC_VECTOR ( 9 downto 0 );
                pcie4_cfg_status_rq_tag1  => open, --: out STD_LOGIC_VECTOR ( 9 downto 0 );
                pcie4_cfg_status_rq_tag_av  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_status_rq_tag_vld0  => open, --: out STD_LOGIC;
                pcie4_cfg_status_rq_tag_vld1  => open, --: out STD_LOGIC;
                pcie4_cfg_status_rx_pm_state  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_tph_requester_enable  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_status_tph_st_mode  => open, --: out STD_LOGIC_VECTOR ( 11 downto 0 );
                pcie4_cfg_status_tx_pm_state  => open, --: out STD_LOGIC_VECTOR ( 1 downto 0 );
                pcie4_cfg_status_vc1_enable  => open, --: out STD_LOGIC;
                pcie4_cfg_status_vc1_negotiation_pending  => open, --: out STD_LOGIC;
                pcie4_cfg_status_vf_power_state  => open, --: out STD_LOGIC_VECTOR ( 755 downto 0 );
                pcie4_cfg_status_vf_status  => open, --: out STD_LOGIC_VECTOR ( 503 downto 0 );
                pcie4_cfg_status_vf_tph_requester_enable  => open, --: out STD_LOGIC_VECTOR ( 251 downto 0 );
                pcie4_cfg_status_vf_tph_st_mode  => open, --: out STD_LOGIC_VECTOR ( 755 downto 0 );
                pcie4_transmit_fc_npd_av  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_transmit_fc_nph_av  => open, --: out STD_LOGIC_VECTOR ( 3 downto 0 );
                phy_rdy_out  => open,--: out STD_LOGIC;
                pcie4_cfg_control_bus_number => open,--: out STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_control_config_space_enable => '1',--: in STD_LOGIC;
                pcie4_cfg_control_ds_bus_number => x"00",--: in STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_control_ds_device_number => "00000",--: in STD_LOGIC_VECTOR ( 4 downto 0 );
                pcie4_cfg_control_ds_port_number => x"00",--: in STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_control_dsn => x"00000001_01_000A35",--: in STD_LOGIC_VECTOR ( 63 downto 0 );
                pcie4_cfg_control_err_cor_in => '0',--: in STD_LOGIC;
                pcie4_cfg_control_err_uncor_in => '0',--: in STD_LOGIC;
                pcie4_cfg_control_flr_done => cfg_flr_done,--: in STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_control_flr_in_process => cfg_flr_in_process,--: out STD_LOGIC_VECTOR ( 3 downto 0 );
                pcie4_cfg_control_hot_reset_in => '0',--: in STD_LOGIC;
                pcie4_cfg_control_hot_reset_out => open,--: out STD_LOGIC;
                pcie4_cfg_control_link_training_enable => '1',--: in STD_LOGIC;
                pcie4_cfg_control_pm_aspm_l1entry_reject => '0',--: in STD_LOGIC;
                pcie4_cfg_control_pm_aspm_tx_l0s_entry_disable => '1',--: in STD_LOGIC;
                pcie4_cfg_control_power_state_change_ack => cfg_power_state_change_ack,--: in STD_LOGIC;
                pcie4_cfg_control_power_state_change_interrupt => cfg_power_state_change_interrupt ,--: out STD_LOGIC;
                pcie4_cfg_control_req_pm_transition_l23_ready => '0',--: in STD_LOGIC;
                pcie4_cfg_control_vf_flr_done => cfg_vf_flr_done,--: in STD_LOGIC_VECTOR ( 0 to 0 );
                pcie4_cfg_control_vf_flr_func_num => cfg_vf_flr_func_num,--: in STD_LOGIC_VECTOR ( 7 downto 0 );
                pcie4_cfg_control_vf_flr_in_process => cfg_vf_flr_in_process--: out STD_LOGIC_VECTOR ( 251 downto 0 )
    
                );
                
                m_axis_cq_s.tuser <= m_axis_cq_tuser_s(182 downto 0);
                
            process(user_clk)
            begin
                if rising_edge(user_clk) then
                    if (user_reset = '1' ) then
                        cfg_power_state_change_ack <= '0';
                    else
                        if ( cfg_power_state_change_interrupt = '1') then
                            cfg_power_state_change_ack <= '1';
                        else
                            cfg_power_state_change_ack <= '0';
                        end if;
                    end if;
                end if;
            end process;
    
        
  flr_proc: process(user_clk)
            begin
                if rising_edge(user_clk) then
                    if (user_reset = '1') then
                        cfg_flr_done_reg0       <= "0000";
                        cfg_vf_flr_done_reg0    <= "000000";
                        cfg_flr_done_reg1       <= "0000";
                        cfg_vf_flr_done_reg1    <= "000000";

                    else
                        cfg_flr_done_reg0       <= cfg_flr_in_process;
                        cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process(5 downto 0);
                        cfg_flr_done_reg1       <= cfg_flr_done_reg0;
                        cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;

                    end if;
                end if;
            end process;

            -- assign function level reset outputs.
            cfg_flr_done(0) <= (not cfg_flr_done_reg1(0)) and cfg_flr_done_reg0(0);
            cfg_flr_done(1) <= (not cfg_flr_done_reg1(1)) and cfg_flr_done_reg0(1);
            cfg_flr_done(2) <= (not cfg_flr_done_reg1(2)) and cfg_flr_done_reg0(2);
            cfg_flr_done(3) <= (not cfg_flr_done_reg1(3)) and cfg_flr_done_reg0(3);
            cfg_vf_flr_done(0) <= (not cfg_vf_flr_done_reg1(0)) and cfg_vf_flr_done_reg0(0); 
        
        
  
  func_num: process( user_clk)
            begin
                if rising_edge(user_clk) then
                    if (user_reset = '1') then
                        cfg_vf_flr_func_num_reg <= x"00";
                    else
                        cfg_vf_flr_func_num_reg <= cfg_vf_flr_func_num_reg + x"01";
                    end if;
                end if;
            end process;

            cfg_vf_flr_func_num <= cfg_vf_flr_func_num_reg;

            m_axis_cq    <= m_axis_cq_s   ;
            m_axis_rc    <= m_axis_rc_s   ;

        end generate; --CARD_TYPE = 180

        reset <= user_reset;
        clk   <= user_clk;
    end generate; --SIMULATION = false    
    g_simulation: if SIMULATION generate
    component pcie_ep_sim_model
        generic(
            DATA_WIDTH            : integer;
            NUMBER_OF_DESCRIPTORS : integer
        );
        port(
            cfg_fc_cpld               : out std_logic_vector(11 downto 0);
            cfg_fc_cplh               : out std_logic_vector(7 downto 0);
            cfg_fc_npd                : out std_logic_vector(11 downto 0);
            cfg_fc_nph                : out std_logic_vector(7 downto 0);
            cfg_fc_pd                 : out std_logic_vector(11 downto 0);
            cfg_fc_ph                 : out std_logic_vector(7 downto 0);
            cfg_interrupt_msix_enable : out std_logic_vector(3 downto 0);
            cfg_interrupt_msix_fail   : out std_logic;
            cfg_interrupt_msix_int    : in  std_logic;
            cfg_interrupt_msix_sent   : out std_logic;
            cfg_mgmt_addr             : in  std_logic_vector(18 downto 0);
            cfg_mgmt_read             : in  std_logic;
            cfg_mgmt_read_data        : out std_logic_vector(31 downto 0);
            cfg_mgmt_read_write_done  : out std_logic;
            cfg_mgmt_write            : in  std_logic;
            clk                       : out std_logic;
            m_axis_cq                 : out axis_type;
            m_axis_r_cq               : in  axis_r_type;
            m_axis_r_rc               : in  axis_r_type;
            m_axis_rc                 : out axis_type;
            reset                     : out std_logic;
            s_axis_cc                 : in  axis_type;
            s_axis_r_cc               : out axis_r_type;
            s_axis_r_rq               : out axis_r_type;
            s_axis_rq                 : in  axis_type;
            sys_rst_n                 : in  std_logic;
            user_lnk_up               : out std_logic
        );
    end component pcie_ep_sim_model;
    begin
    
      sim_model0: pcie_ep_sim_model
      generic map(
        DATA_WIDTH => DATA_WIDTH,
        NUMBER_OF_DESCRIPTORS => NUMBER_OF_DESCRIPTORS
      )
      port map(
        cfg_fc_cpld                => cfg_fc_cpld               ,
        cfg_fc_cplh                => cfg_fc_cplh               ,
        cfg_fc_npd                 => cfg_fc_npd                ,
        cfg_fc_nph                 => cfg_fc_nph                ,
        cfg_fc_pd                  => cfg_fc_pd                 ,
        cfg_fc_ph                  => cfg_fc_ph                 ,
        cfg_interrupt_msix_enable  => cfg_interrupt_msix_enable ,
        cfg_interrupt_msix_fail    => cfg_interrupt_msix_fail   ,
        cfg_interrupt_msix_int     => cfg_interrupt_msix_int    ,
        cfg_interrupt_msix_sent    => cfg_interrupt_msix_sent   ,
        cfg_mgmt_addr              => cfg_mgmt_addr             ,
        cfg_mgmt_read              => cfg_mgmt_read             ,
        cfg_mgmt_read_data         => cfg_mgmt_read_data        ,
        cfg_mgmt_read_write_done   => cfg_mgmt_read_write_done  ,
        cfg_mgmt_write             => cfg_mgmt_write            ,
        clk                        => clk                       ,
        m_axis_cq                  => m_axis_cq                 ,
        m_axis_r_cq                => m_axis_r_cq               ,
        m_axis_r_rc                => m_axis_r_rc               ,
        m_axis_rc                  => m_axis_rc                 ,
        reset                      => reset                     ,
        s_axis_cc                  => s_axis_cc                 ,
        s_axis_r_cc                => s_axis_r_cc               ,
        s_axis_r_rq                => s_axis_r_rq               ,
        s_axis_rq                  => s_axis_rq                 ,
        sys_rst_n                  => sys_rst_n                 ,
        user_lnk_up                => user_lnk_up               
      );
    
    end generate; --SIMULATION

end architecture structure ; -- of pcie_ep_wrap

