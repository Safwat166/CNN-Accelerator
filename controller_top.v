module controller_top #(
    parameter input_code_request_width = 2,
    weight_code_request_width = 2,
    output_code_request_width = 1,
    psums_code_request_width = 1,
    counter_width = 8
) (

    input clk,
    input rst,
    input clear,
    input [7:0] ch_id,
    input [7:0] filter_size,
    input finished_op,
    input load_done_reorder,
    input load_done_weight,
    input row_transition,
    input load_buffers_done,
    output enable_modules,
    output output_selection,
    output [input_code_request_width - 1 : 0] request_input,
    output [weight_code_request_width - 1 : 0] request_weight,
    output [output_code_request_width - 1 : 0] request_output,
    output [psums_code_request_width - 1 : 0] request_psums,
    output clear_modules,
    output en_pe_reg
);

  // ----------------- define internal nets --------------- 
  wire first_window_wire;
  wire first_window_enable_wire;
  wire [counter_width - 1 : 0] counter_wire;
  wire counter_up_valid_wire;
  wire request_input_counter_en_wire;
  wire request_input_counter_clear_wire;
  wire [2 : 0] request_input_counter_wire;
  //   wire [weight_code_request_width - 1 : 0] request_weight;

  // -------------------- instantiate FSM ----------------------------
  fsm #(
      .input_code_request_width(input_code_request_width),
      .weight_code_request_width(weight_code_request_width),
      .output_code_request_width(output_code_request_width),
      .psums_code_request_width(psums_code_request_width),
      .counter_width(counter_width)
  ) fsm_U (
      .clk                        (clk),
      .rst                        (rst),
      .clear                      (clear),
      .ch_id                      (ch_id),
      .filter_size                (filter_size),
      .finished_op                (finished_op),
      .load_done_reorder          (load_done_reorder),
      .load_done_weight           (load_done_weight),
      .row_transition             (row_transition),
      .load_buffers_done          (load_buffers_done),
      .first_window               (first_window_wire),
      .counter                    (counter_wire),
      .enable_modules             (enable_modules),
      .output_selection           (output_selection),
      .request_input              (request_input),
      .request_weight             (request_weight),
      .request_output             (request_output),
      .request_psums              (request_psums),
      .first_window_enable        (first_window_enable_wire),
      .clear_modules              (clear_modules),
      .counter_up_valid           (counter_up_valid_wire),
      .en_pe_reg                  (en_pe_reg),
      .request_input_counter_en   (request_input_counter_en_wire),
      .request_input_counter_clear(request_input_counter_clear_wire),
      .request_input_counter      (request_input_counter_wire)
  );



  // -------------------- instantiate counter ----------------------------
  counter #(
      .counter_width(counter_width)
  ) counter_u (
      .clk(clk),
      .rst(rst),
      .en(counter_up_valid_wire),
      .clear(clear_modules),
      .count(counter_wire)
  );


  // -------------------- instantiate first window reg ----------------------------
  first_window_reg first_window_U (
      .clk(clk),
      .rst(rst),
      .en(first_window_enable_wire),
      .first_window(first_window_wire)
  );

  // -------------------- instantiate request input counter ----------------------------
  request_input_counter #(
      .counter_width(3)
  ) request_input_counter_U (
      .clk(clk),
      .rst(rst),
      .en(request_input_counter_en_wire),
      .clear(request_input_counter_clear_wire),
      .count(request_input_counter_wire)
  );

  // top module instantiation 
  //   controller_top #(
  //     // between bracket is the value should be assigned
  //       .input_code_request_width(2),
  //       .weight_code_request_width(2),
  //       .output_code_request_width(1),
  //       .psums_code_request_width(1),
  //       .counter_width(8)
  //   ) instance_name_ya_3ars (
  //       .clk              (),
  //       .rst              (),
  //       .clear            (),
  //       .ch_id            (),
  //       .filter_size      (),
  //       .finished_op      (),
  //       .load_done_reorder(),
  //       .load_done_weight (),
  //       .row_transition   (),
  //       .load_buffers_done(),
  //       .enable_modules   (),
  //       .output_selection (),
  //       .request_input    (),
  //       .request_weight   (),
  //       .request_output   (),
  //       .request_psums    (),
  //       .clear_modules    (),
  //       .en_pe_reg        ()
  //   );




endmodule
