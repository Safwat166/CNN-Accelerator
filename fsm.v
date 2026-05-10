module fsm #(
    parameter input_code_request_width = 2,
    parameter weight_code_request_width = 2,
    parameter output_code_request_width = 1,
    parameter psums_code_request_width = 1,
    counter_width = 8,
    request_input_counter_width = 3
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
    input first_window,
    input [request_input_counter_width - 1 : 0] request_input_counter,
    input [counter_width - 1 : 0] counter,
    output reg enable_modules,
    output reg output_selection,
    output reg [input_code_request_width - 1 : 0] request_input,
    output reg [weight_code_request_width - 1 : 0] request_weight,
    output reg [output_code_request_width - 1 : 0] request_output,
    output reg [psums_code_request_width - 1 : 0] request_psums,
    output reg first_window_enable,
    output reg clear_modules,
    output reg counter_up_valid,
    output reg en_pe_reg,
    output reg request_input_counter_en,
    output reg request_input_counter_clear
);

  reg [4:0] subs;



  wire special_load_start;

  reg row_transition_reg;




  always @(*) begin
    subs = (filter_size / 3) * (filter_size / 3);
  end



  // define the states
  // typedef enum bit [2:0] {
  //   idle_state = 3'b000,
  //   start_up_state = 3'b001,  // read the configurations from configuration buffer
  //   operation_state = 3'b010,
  //   special_load_state = 3'b011,  // enable the modules to be loaded
  //   output_state = 3'b100  // enable modules to make its operations
  // } states;

  localparam idle_state = 3'b000,
             start_up_state = 3'b001,  // read the configurations from configuration buffer
  operation_state = 3'b010, special_load_state = 3'b011,  // enable the modules to be loaded
  output_state = 3'b100;  // enable modules to make its operations

  reg [2:0] current_state, next_state, prev_state;

  // current state update
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      current_state <= idle_state;
    end else begin
      current_state <= next_state;
    end
  end

  // next state logic
  always @(*) begin
    next_state = idle_state;
    case (current_state)
      idle_state: begin
        next_state = load_buffers_done == 1 ? start_up_state : idle_state;
      end
      start_up_state: begin
        if (clear == 1) next_state = idle_state;
        else if (load_done_reorder == 1) next_state = operation_state;
        else next_state = start_up_state;
      end
      operation_state: begin
        if (clear == 1) next_state = idle_state;
        else if (((finished_op == 1) && (filter_size == 3)) || ((finished_op == 1) && (filter_size != 3) && (counter == subs - 1))) begin
          next_state = output_state;
        end else if ((finished_op == 1) && (filter_size != 3) && (counter != subs - 1)) begin
          next_state = special_load_state;
        end else next_state = operation_state;
      end
      special_load_state: begin
        // check on the row transition if it is 1 then register it if 0 then leave it's register at 0 and at operation state make it = 0
        if(((row_transition_reg == 1) && (load_done_reorder == 1)) || ((row_transition_reg == 0) && (load_done_weight == 1)))
          next_state = operation_state;
        else next_state = special_load_state;
      end
      output_state: begin
        next_state = clear == 1 ? idle_state : start_up_state;
      end
      default: next_state = idle_state;
    endcase
  end


  // enable_modules logic
  always @(*) begin
    if (current_state == operation_state) enable_modules = 1;
    else enable_modules = 0;
  end


  // logic for first window enable
  always @(*) begin
    if (current_state == operation_state) first_window_enable = first_window == 0;
    else first_window_enable = 0;
  end

  // logic for request_input_counter enable and clear
  always @(*) begin
    if (current_state == start_up_state) begin
      request_input_counter_en = 1;
      request_input_counter_clear = 0;
    end else begin
      request_input_counter_en = 0;
      request_input_counter_clear = 1;
    end
  end

  // logic for request_input and first window enable
  always @(*) begin
    if (current_state == start_up_state) begin
      if (request_input_counter <= 3) begin
        if (first_window == 0) begin
          request_input = 'b01;
        end else if (filter_size == 3) begin
          request_input = 'b10;
        end else if (filter_size != 3) begin
          request_input = 'b11;
        end else request_input = 'b00;
      end else begin
        request_input = 'b00;
      end
    end else begin
      request_input = 'b00;
    end
  end

  // logic for weight request
  always @(*) begin
    if ((current_state == start_up_state) && (prev_state != start_up_state)) begin
      if (first_window == 0) begin
        request_weight = 'b01;
      end else if (filter_size == 3) begin
        request_weight = 'b00;
      end else if (filter_size != 3) begin
        request_weight = 'b11;
      end else request_weight = 'b00;
    end else if ((current_state == special_load_state) && (prev_state != special_load_state)) begin
      request_weight = 'b10;
    end else begin
      request_weight = 'b00;
    end
  end




  // logic for clear signal
  always @(*) begin
    if ((current_state == idle_state) || (current_state == start_up_state) || (clear == 1)) begin
      clear_modules = 1;
    end else begin
      clear_modules = 0;
    end
  end


  // logic for request_output (output_data_valid)
  always @(*) begin
    if (current_state == output_state) begin
      request_output = 'b1;
    end else begin
      request_output = 'b0;
    end
  end

  // logic for psums request
  always @(*) begin
    if ((current_state == start_up_state) && (prev_state != start_up_state)) begin
      request_psums = ch_id == 1 ? 'b0 : 'b1;
    end else begin
      request_psums = 'b0;
    end
  end


  // up_count logic
  always @(*) begin
    if (current_state == special_load_state) counter_up_valid = next_state == operation_state;
    else counter_up_valid = 0;
  end

  // logic for output selection
  always @(*) begin
    if (current_state == output_state) output_selection = ch_id == 1;
    else output_selection = 0;
  end

  // row_transition logic
  always @(posedge clk or negedge rst) begin
    if (!rst) prev_state <= idle_state;
    else prev_state <= current_state;
  end

  assign special_load_start = (current_state == special_load_state) && (prev_state   != special_load_state);

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      row_transition_reg <= 0;
    end else if (current_state == operation_state) begin
      row_transition_reg <= 0;
    end else if (special_load_start) begin
      row_transition_reg <= row_transition;
    end
  end


  // enable pe_reg logic
  always @(*) begin
    if (current_state == output_state) en_pe_reg = 1;
    else en_pe_reg = 0;
  end

endmodule
