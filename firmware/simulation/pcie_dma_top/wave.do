onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group app /virtex7_dma_top/u0/clk40
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_din
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_dout
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_empty
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_full
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_rd_clk
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_re
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_we
add wave -noupdate -expand -group app /virtex7_dma_top/u0/fifo_wr_clk
add wave -noupdate -expand -group app /virtex7_dma_top/u0/flush_fifo
add wave -noupdate -expand -group app /virtex7_dma_top/u0/leds
add wave -noupdate -expand -group app /virtex7_dma_top/u0/register_map_control
add wave -noupdate -expand -group app /virtex7_dma_top/u0/register_map_monitor
add wave -noupdate -expand -group app /virtex7_dma_top/u0/reset_hard
add wave -noupdate -expand -group app /virtex7_dma_top/u0/reset_soft
add wave -noupdate -expand -group app /virtex7_dma_top/u0/register_map_monitor_s
add wave -noupdate -expand -group app /virtex7_dma_top/u0/register_map_control_s
add wave -noupdate -expand -group app /virtex7_dma_top/u0/s_fifo_we
add wave -noupdate -expand -group app /virtex7_dma_top/u0/s_fifo_full
add wave -noupdate -expand -group app /virtex7_dma_top/u0/s_fifo_din
add wave -noupdate -expand -group app /virtex7_dma_top/u0/cnt
add wave -noupdate -expand -group app /virtex7_dma_top/u0/reset
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar0
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar1
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar2
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/clk
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/clk40
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_descriptors
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_soft_reset
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_status
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/flush_fifo
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/interrupt_table_en
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/interrupt_vector
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/m_axis_cc
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/m_axis_r_cc
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_map_monitor
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_map_control
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/reset
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/reset_global_soft
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/s_axis_cq
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/s_axis_r_cq
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_interrupt_call
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/completer_state
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/completer_state_slv
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_descriptors_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_descriptors_40_r_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_descriptors_40_w_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_descriptors_w_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_status_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_status_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/int_vector_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/int_vector_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/int_table_en_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_address_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/address_type_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dword_count_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/request_type_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/requester_id_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/tag_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/target_function_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar_id_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar_aperture_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar0_valid
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/transaction_class_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/attributes_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/seen_tlast_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_data_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_data_r
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_map_monitor_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_map_control_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/tlast_timer_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_address_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_address_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_enable_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_enable_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_done_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_done_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_data_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_read_data_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_address_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_address_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_enable_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_enable_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_done_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_done_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_data_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/register_write_data_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar0_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar1_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/bar2_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/flush_fifo_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/dma_soft_reset_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/reset_global_soft_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/write_interrupt_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/read_interrupt_40_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/write_interrupt_250_s
add wave -noupdate -expand -group dma_control /virtex7_dma_top/pcie0/dma0/u1/read_interrupt_250_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1133 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1744 ps}
