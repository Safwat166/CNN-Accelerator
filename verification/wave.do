onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cnn_accelerator_tb/DUT/clk
add wave -noupdate /cnn_accelerator_tb/DUT/rst_n
add wave -noupdate /cnn_accelerator_tb/DUT/input_activations
add wave -noupdate /cnn_accelerator_tb/DUT/valid_input
add wave -noupdate /cnn_accelerator_tb/DUT/filter_in
add wave -noupdate /cnn_accelerator_tb/DUT/comp_inst/valid_weight
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/data_bus_i
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/data_bus_w
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/data_bus_ps
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/data_bus_o
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/data_bus_r_rd
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/data_bus_r_wr
add wave -noupdate -group AXI -radix unsigned /cnn_accelerator_tb/DUT/address_i
add wave -noupdate -group AXI -radix unsigned /cnn_accelerator_tb/DUT/address_w
add wave -noupdate -group AXI -radix unsigned /cnn_accelerator_tb/DUT/address_ps
add wave -noupdate -group AXI -radix unsigned /cnn_accelerator_tb/DUT/address_o
add wave -noupdate -group AXI -radix unsigned /cnn_accelerator_tb/DUT/address_r
add wave -noupdate -group AXI -color {Orange Red} -radix unsigned /cnn_accelerator_tb/DUT/index_address_i
add wave -noupdate -group AXI -color {Orange Red} -radix unsigned /cnn_accelerator_tb/DUT/index_address_w
add wave -noupdate -group AXI -color {Orange Red} -radix unsigned /cnn_accelerator_tb/DUT/index_address_o
add wave -noupdate -group AXI -color {Orange Red} -radix unsigned /cnn_accelerator_tb/DUT/index_address_ps
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/wr_en_i
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/wr_en_w
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/rd_en_o
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/wr_en_ps
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/wr_en_r
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/block_enable_i
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/block_enable_w
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/block_enable_ps
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/block_enable_o
add wave -noupdate -group AXI /cnn_accelerator_tb/DUT/block_enable_r
add wave -noupdate -group {status signals} /cnn_accelerator_tb/DUT/done_slice
add wave -noupdate -group {status signals} -radix unsigned /cnn_accelerator_tb/DUT/ifmap_h
add wave -noupdate -group {status signals} -radix unsigned /cnn_accelerator_tb/DUT/ifmap_w
add wave -noupdate -group {status signals} /cnn_accelerator_tb/DUT/valid_out
add wave -noupdate -group {status signals} /cnn_accelerator_tb/DUT/done_slice
add wave -noupdate -group {status signals} /cnn_accelerator_tb/DUT/load_buffers_done
add wave -noupdate -group {system states and data requests} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/fsm_U/current_state
add wave -noupdate -group {system states and data requests} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/fsm_U/next_state
add wave -noupdate -group {system states and data requests} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_input
add wave -noupdate -group {system states and data requests} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_weight
add wave -noupdate -group {system states and data requests} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_output
add wave -noupdate -group {generated addresses} -color Cyan -radix unsigned /cnn_accelerator_tb/DUT/control_buff_inst/read_address_input
add wave -noupdate -group {generated addresses} -color Cyan -radix unsigned /cnn_accelerator_tb/DUT/control_buff_inst/read_address_weight
add wave -noupdate -group {generated addresses} -color Cyan -radix unsigned /cnn_accelerator_tb/DUT/control_buff_inst/write_address_output
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/en_op
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/comp_inst/clear_pe
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/load_done
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/load_done_w
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/finished_op
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/req_3col
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/comp_inst/available_data
add wave -noupdate -group {operational signals} -color Thistle /cnn_accelerator_tb/DUT/row_transition
add wave -noupdate -group outputs -color Cyan /cnn_accelerator_tb/DUT/stream_out
add wave -noupdate -group outputs -color Cyan /cnn_accelerator_tb/DUT/pe_out
add wave -noupdate -group outputs -color Cyan /cnn_accelerator_tb/DUT/pe_stream_buffer_inst/en
add wave -noupdate -group outputs -color Cyan /cnn_accelerator_tb/DUT/en_pe_reg
add wave -noupdate -expand -group {vertical slice pointer} -color Yellow -radix unsigned /cnn_accelerator_tb/DUT/control_buff_inst/instance_input/coulmn_ptr_ifmap_h
add wave -noupdate -expand -group {vertical slice pointer} -radix unsigned /cnn_accelerator_tb/DUT/control_buff_inst/instance_input/total_16_coulmn_window
add wave -noupdate -group {input buffer} /cnn_accelerator_tb/DUT/input_buff_inst/mem
add wave -noupdate -group {input buffer} /cnn_accelerator_tb/DUT/input_buff_inst/block_enable
add wave -noupdate -group {input buffer} /cnn_accelerator_tb/DUT/control_buff_inst/instance_input/rden
add wave -noupdate -group {weight buffer} /cnn_accelerator_tb/DUT/weight_buff_inst/mem
add wave -noupdate -group {weight buffer} /cnn_accelerator_tb/DUT/weight_buff_inst/block_enable
add wave -noupdate -group {weight buffer} /cnn_accelerator_tb/DUT/control_buff_inst/instance_weight/rden_w
add wave -noupdate -group {output buffer} /cnn_accelerator_tb/DUT/output_buff_inst/mem
add wave -noupdate -group {output buffer} /cnn_accelerator_tb/DUT/output_buff_inst/block_enable
add wave -noupdate -group {output buffer} /cnn_accelerator_tb/DUT/control_buff_inst/instance_output/wren
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21185000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 112
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
WaveRestoreZoom {0 ps} {1521969750 ps}
