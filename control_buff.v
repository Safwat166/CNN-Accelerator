module control_buff_top(
    input   wire            clk,rst_n,
    // ----------- Input Buffer  ----------------
    input   wire    [1:0]  req_input,
    input   wire    [12:0] reg_ifmap_h,      // Ifmap Height
    input   wire    [12:0] reg_ifmap_w,      // Ifmap Width
    input   wire    [7:0]  reg_filter_size,  // ex: 3 for 3x3, 4 for 4x4
    input   wire    [7:0]  reg_channel_id,   // Current Channel being processed
    input   wire           row_transition,
    input   wire           req_3_col,          
    output  wire     [12:0] read_address_input,
    output  wire            initial_window,
    output  wire            valid_add_input,
    // ----------- Weight Buffer  ----------------
    input   wire    [1:0]   req_weight,
    //input   wire    [7:0]   reg_filter_size,
    output  wire     [11:0]  read_address_weight,
    output  wire             valid_add_weight,
    // ----------- Output Buffer  ----------------
    input   wire             req_out,
    output  wire     [12:0]  write_address_output,
    output  wire             valid_in,
    output  wire             valid_add_out,
    // ----------- Psum Buffer  ------------------
    input   wire             req_psum,
    output  wire             valid_add_psum,
    output  wire     [12:0]  read_address_psum
);

// input buffer
control_buff_input instance_input(
    .clk(clk),
    .rst_n(rst_n),
    .request(req_input),
    .reg_ifmap_h(reg_ifmap_h),
    .reg_ifmap_w(reg_ifmap_w),      
    .reg_filter_size(reg_filter_size),
    .reg_channel_id(reg_channel_id),
    .row_transition(row_transition),
    .req_3_col(req_3_col),          
    .read_address_input(read_address_input),
    .valid_add(valid_add_input),
    .initial_window(initial_window)
);

// weight Buffer
control_buff_weight instance_weight(
    .clk(clk),
    .rst_n(rst_n),
    .req_weight(req_weight),
    .reg_filter_size(reg_filter_size),
    .read_address_weight(read_address_weight),
    .valid_add(valid_add_weight)
);

// output Buffer
control_buff_output instance_output(
    .clk(clk),
    .rst_n(rst_n),
    .req_out(req_out),
    .write_address_output(write_address_output),
    .valid_in(valid_in),
    .valid_add(valid_add_out)
);

// Psum Buffer
control_buff_psum instance_psum(
    .clk(clk),
    .rst_n(rst_n),
    .req_psum(req_psum),
    .read_address_psum(read_address_psum),
    .valid_add(valid_add_psum)
);
endmodule