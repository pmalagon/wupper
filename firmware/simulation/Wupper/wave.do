onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group application -expand -group mul1 /wupper_oc_top/u0/mul1/CLK
add wave -noupdate -expand -group application -expand -group mul1 /wupper_oc_top/u0/mul1/A
add wave -noupdate -expand -group application -expand -group mul1 /wupper_oc_top/u0/mul1/B
add wave -noupdate -expand -group application -expand -group mul1 /wupper_oc_top/u0/mul1/P
add wave -noupdate -expand -group application -expand -group mul1 /wupper_oc_top/u0/mul1/NLW_U0_PCASC_UNCONNECTED
add wave -noupdate -expand -group application -expand -group mul1 /wupper_oc_top/u0/mul1/NLW_U0_ZERO_DETECT_UNCONNECTED
add wave -noupdate -expand -group application -expand -group mul0 /wupper_oc_top/u0/mul0/CLK
add wave -noupdate -expand -group application -expand -group mul0 /wupper_oc_top/u0/mul0/A
add wave -noupdate -expand -group application -expand -group mul0 /wupper_oc_top/u0/mul0/B
add wave -noupdate -expand -group application -expand -group mul0 /wupper_oc_top/u0/mul0/P
add wave -noupdate -expand -group application -expand -group mul0 /wupper_oc_top/u0/mul0/NLW_U0_PCASC_UNCONNECTED
add wave -noupdate -expand -group application -expand -group mul0 /wupper_oc_top/u0/mul0/NLW_U0_ZERO_DETECT_UNCONNECTED
add wave -noupdate -expand -group application /wupper_oc_top/u0/appreg_clk
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_din
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_dout
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_empty
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_full
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_rd_clk
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_re
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_we
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_wr_clk
add wave -noupdate -expand -group application /wupper_oc_top/u0/flush_fifo
add wave -noupdate -expand -group application /wupper_oc_top/u0/interrupt_call
add wave -noupdate -expand -group application /wupper_oc_top/u0/leds
add wave -noupdate -expand -group application /wupper_oc_top/u0/pll_locked
add wave -noupdate -expand -group application -expand /wupper_oc_top/u0/register_map_control
add wave -noupdate -expand -group application /wupper_oc_top/u0/register_map_monitor
add wave -noupdate -expand -group application /wupper_oc_top/u0/reset_hard
add wave -noupdate -expand -group application /wupper_oc_top/u0/reset_soft
add wave -noupdate -expand -group application /wupper_oc_top/u0/register_map_monitor_s
add wave -noupdate -expand -group application /wupper_oc_top/u0/register_map_control_s
add wave -noupdate -expand -group application /wupper_oc_top/u0/reset
add wave -noupdate -expand -group application /wupper_oc_top/u0/appreg_clk
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_din
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_we
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_dout
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_empty
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_full
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_rd_clk
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_re
add wave -noupdate -expand -group application /wupper_oc_top/u0/fifo_wr_clk
add wave -noupdate -expand -group application /wupper_oc_top/u0/flush_fifo
add wave -noupdate -expand -group application /wupper_oc_top/u0/interrupt_call
add wave -noupdate -expand -group application /wupper_oc_top/u0/leds
add wave -noupdate -expand -group application /wupper_oc_top/u0/pll_locked
add wave -noupdate -expand -group application /wupper_oc_top/u0/register_map_control
add wave -noupdate -expand -group application /wupper_oc_top/u0/register_map_monitor
add wave -noupdate -expand -group application /wupper_oc_top/u0/reset_hard
add wave -noupdate -expand -group application /wupper_oc_top/u0/reset_soft
add wave -noupdate -expand -group application /wupper_oc_top/u0/register_map_monitor_s
add wave -noupdate -expand -group application -expand -subitemconfig {/wupper_oc_top/u0/register_map_control_s.APP_MUX -expand} /wupper_oc_top/u0/register_map_control_s
add wave -noupdate -expand -group application /wupper_oc_top/u0/reset
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/rst
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/din
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/wr_en
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/rd_en
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/dout
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/full
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/empty
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_almost_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_almost_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_prog_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_prog_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_prog_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_prog_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_prog_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_prog_empty_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_dbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arvalid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awvalid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_bready_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_rready_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_wlast_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_wvalid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tlast_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tvalid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_overflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_prog_full_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_rd_rst_busy_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_arready_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_awready_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_bvalid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_rlast_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_rvalid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_wready_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axis_tready_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_sbiterr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_underflow_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_valid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_wr_ack_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_wr_rst_busy_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_ar_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_aw_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_b_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_r_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axi_w_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_axis_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_araddr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arburst_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arcache_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arlen_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arlock_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arprot_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arqos_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arregion_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_arsize_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_aruser_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awaddr_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awburst_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awcache_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awlen_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awlock_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awprot_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awqos_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awregion_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awsize_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_awuser_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_wdata_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_wid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_wstrb_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axi_wuser_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tdata_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tdest_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tkeep_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tstrb_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_m_axis_tuser_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_rd_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_bid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_bresp_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_buser_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_rdata_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_rid_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_rresp_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_s_axi_ruser_UNCONNECTED
add wave -noupdate -expand -group application -expand -group upfifo /wupper_oc_top/u0/upfifo/NLW_U0_wr_data_count_UNCONNECTED
add wave -noupdate -expand -group application -expand -group LFSR /wupper_oc_top/u0/LFSR1/clk
add wave -noupdate -expand -group application -expand -group LFSR /wupper_oc_top/u0/LFSR1/load_seed
add wave -noupdate -expand -group application -expand -group LFSR /wupper_oc_top/u0/LFSR1/enable
add wave -noupdate -expand -group application -expand -group LFSR /wupper_oc_top/u0/LFSR1/rndmdata
add wave -noupdate -expand -group application -expand -group LFSR /wupper_oc_top/u0/LFSR1/seed
add wave -noupdate -expand -group application -expand -group LFSR /wupper_oc_top/u0/LFSR1/vector
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_downfifo_we
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_downfifo_full
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_downfifo_din
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_upfifo_re
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_upfifo_empty
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_upfifo_dout
add wave -noupdate -expand -group application /wupper_oc_top/u0/s_flush_fifo
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/clk
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/pll_locked
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_n
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_out
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_s
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/locked_s
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_cnt
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/clk
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/pll_locked
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_n
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_out
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_s
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/locked_s
add wave -noupdate -expand -group slowclock /wupper_oc_top/u1/u3/reset_cnt
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_in250
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_out40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/reset
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/locked
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_in250_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_out40_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clkfbout_buf_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clkfbout_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKFBOUTB_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKFBSTOPPED_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKINSTOPPED_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT0B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT1_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT1B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT2_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT2B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT3_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT3B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT4_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT5_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT6_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_DRDY_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_PSDONE_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_DO_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_in250
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_out40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/reset
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/locked
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_in250_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clk_out40_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clkfbout_buf_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/clkfbout_clk_wiz_40
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKFBOUTB_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKFBSTOPPED_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKINSTOPPED_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT0B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT1_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT1B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT2_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT2B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT3_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT3B_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT4_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT5_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_CLKOUT6_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_DRDY_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_PSDONE_UNCONNECTED
add wave -noupdate -group clk_wiz /wupper_oc_top/u1/u3/clk0/U0/NLW_mmcm_adv_inst_DO_UNCONNECTED
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar0
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar1
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar2
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/clk
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/clkDiv6
add wave -noupdate -group dma_control -expand -subitemconfig {/wupper_oc_top/u1/dma0/u1/dma_descriptors(0) -expand} /wupper_oc_top/u1/dma0/u1/dma_descriptors
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_soft_reset
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_status
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/flush_fifo
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/interrupt_table_en
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/interrupt_vector
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/m_axis_cc
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/m_axis_r_cc
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_map_monitor
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_map_control
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/reset
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/reset_global_soft
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/s_axis_cq
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/s_axis_r_cq
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/fifo_full
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/fifo_empty
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_interrupt_call
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/completer_state
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/completer_state_slv
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_descriptors_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_descriptors_40_r_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_descriptors_40_w_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_descriptors_w_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_status_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_status_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/int_vector_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/int_vector_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/int_table_en_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_address_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/address_type_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dword_count_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/request_type_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/requester_id_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/tag_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/target_function_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar_id_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar_aperture_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar0_valid
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/transaction_class_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/attributes_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_data_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_data_r
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_map_monitor_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_map_control_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/tlast_timer_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_address_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_address_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_enable_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_enable1_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_enable_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_done_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_done_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_data_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_read_data_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_address_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_address_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_enable_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_enable1_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_enable_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_done_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_done_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_data_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/register_write_data_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar0_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar1_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/bar2_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/fifo_full_interrupt_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/data_available_interrupt_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/flush_fifo_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_soft_reset_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/reset_global_soft_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/write_interrupt_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/read_interrupt_40_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/write_interrupt_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/read_interrupt_250_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/next_current_address_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/last_current_address_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/last_pc_pointer_s
add wave -noupdate -group dma_control /wupper_oc_top/u1/dma0/u1/dma_wait
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/clk
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/dma_descriptors
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/dma_soft_reset
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/dma_status
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_din
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_dout
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_empty
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_full
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_re
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_we
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/m_axis_r_rq
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/m_axis_rq
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/reset
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/s_axis_r_rc
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/s_axis_rc
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/rw_state
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/rw_state_slv
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/strip_state
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/strip_state_slv
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/current_descriptor
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_dout_pipe
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_din_pipe
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/req_tag
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/descriptor_done_s
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/s_axis_rc_tlast_pipe
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/s_axis_rc_tvalid_pipe
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/fifo_full_pipe
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/receive_word_count
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/active_descriptor_s
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/receive_tags_s
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/receive_tag_status_s
add wave -noupdate -group dma_read_write /wupper_oc_top/u1/dma0/u0/current_receive_tag_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2638518 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 269
configure wave -valuecolwidth 449
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {2599784 ps} {2862745 ps}
