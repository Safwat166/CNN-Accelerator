onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cnn_accelerator_tb/DUT/clk
add wave -noupdate /cnn_accelerator_tb/DUT/rst_n
add wave -noupdate /cnn_accelerator_tb/DUT/input_activations
add wave -noupdate /cnn_accelerator_tb/DUT/valid_input
add wave -noupdate /cnn_accelerator_tb/DUT/filter_in
add wave -noupdate /cnn_accelerator_tb/DUT/comp_inst/valid_weight
add wave -noupdate -expand -group {system states} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/fsm_U/current_state
add wave -noupdate -expand -group {system states} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/fsm_U/next_state
add wave -noupdate -expand -group {system states} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_input
add wave -noupdate -expand -group {system states} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_weight
add wave -noupdate -expand -group {system states} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_output
add wave -noupdate -expand -group {system states} -color Orange /cnn_accelerator_tb/DUT/controller_top_inst/request_psums
add wave -noupdate -expand -group address -color Cyan /cnn_accelerator_tb/DUT/control_buff_inst/read_address_input
add wave -noupdate -expand -group address -color Cyan /cnn_accelerator_tb/DUT/control_buff_inst/read_address_weight
add wave -noupdate -expand -group address -color Cyan /cnn_accelerator_tb/DUT/control_buff_inst/write_address_output
add wave -noupdate -expand -group address -color Cyan /cnn_accelerator_tb/DUT/control_buff_inst/read_address_psum
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/initial_window
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/comp_inst/clear_pe
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/load_done
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/load_done_w
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/finished_op
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/req_3col
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/comp_inst/available_data
add wave -noupdate -expand -group {status signals} -color Thistle /cnn_accelerator_tb/DUT/row_transition
add wave -noupdate -expand -group {reorder window} -color Gold /cnn_accelerator_tb/DUT/comp_inst/reorder_module_inst/wire_A
add wave -noupdate -expand -group {reorder window} -color Gold /cnn_accelerator_tb/DUT/comp_inst/reorder_module_inst/wire_B
add wave -noupdate -expand -group {reorder window} -color Gold /cnn_accelerator_tb/DUT/comp_inst/reorder_module_inst/wire_C
add wave -noupdate -expand -group {reorder window} -color Gold /cnn_accelerator_tb/DUT/comp_inst/reorder_module_inst/wire_D
add wave -noupdate -expand -group {pe array output} -color Cyan /cnn_accelerator_tb/DUT/pe_out
add wave -noupdate /cnn_accelerator_tb/DUT/stream_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5163406 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 294
configure wave -valuecolwidth 163
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
WaveRestoreZoom {3371120 ps} {10134013 ps}
