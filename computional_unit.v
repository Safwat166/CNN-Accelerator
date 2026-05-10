module computional_unit(

    // interface reorder module
    input       wire          clk,
    input       wire          rst_n,
    input       wire          valid_input,
    input       wire          en_op,
    input       wire [127:0]  input_activations,
    input       wire [7:0]    filter_size,
    input       wire          initial_window,
    output      wire          load_done,
    output      wire          row_transition,
    output      wire          finished_op,
    output      wire          req_3col,

    // interface weight logic unit
    input       wire [71:0]   filter_in,
    input       wire          valid_weight,
    output      wire          load_done_w,

    // interface pe array
    input       wire          clear_pe,
    output      wire [783:0]  pe_out
);

    /*--------------------------------------------------
    -- internal signals
    --------------------------------------------------*/

    // interface reorder module
    wire          available_data;
    wire [111:0]  out_A;
    wire [111:0]  out_B;

    // interface weight logic unit
    wire [7:0]    filter_out;

    /*--------------------------------------------------
    -- instances
    --------------------------------------------------*/
    reorder_module reorder_module_inst(
        .clk(clk),
        .rst_n(rst_n),
        .valid_data(valid_input),
        .en_op(en_op),
        .input_activations(input_activations),
        .filter_size(filter_size),
        .initial_window(initial_window),
        .load_done(load_done),
        .row_transition(row_transition),
        .available_data(available_data),
        .finished_op(finished_op),
        .request3_col(req_3col),
        .out_A(out_A),
        .out_B(out_B)
    );

    Weight_Logic_Unit weight_logic_unit_inst(
        .clk(clk),
        .rst(rst_n),
        .filter_in(filter_in),
        .Data_valid(valid_weight),
        .shift_en(en_op),
        .filter_out(filter_out),
        .load_done_w(load_done_w)
    );

    PE_Array_Top  pe_array_inst(
        .CLK(clk),
        .rst(rst_n),
        .en_pe(en_op),
        .clear(clear_pe),
        .available_data(available_data),
        .filter_in1(filter_out),
        .OUT_A(out_A),
        .OUT_B(out_B),
        .pe_out(pe_out)
    );

endmodule