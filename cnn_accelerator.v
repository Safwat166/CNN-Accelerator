module cnn_accelerator #(
    parameter input_code_request_width = 2,
    weight_code_request_width = 2,
    output_code_request_width = 1,
    psums_code_request_width = 1,
    counter_width = 8
) (
    // BRAM Controller interface

    // global signals
    input       wire          clk,
    input       wire          rst_n,

    // data bus
    input       wire [127:0]  data_bus_i,
    input       wire [127:0]  data_bus_w,
    input       wire [127:0]  data_bus_ps,
    output      wire [127:0]  data_bus_o,
    output      wire [63:0]   data_bus_r_rd,
    input       wire [63:0]   data_bus_r_wr,

    // addresses
    input       wire [31:0]   address_i,
    input       wire [31:0]   address_w,
    input       wire [31:0]   address_ps,
    input       wire [31:0]   address_o,
    input       wire [31:0]   address_r,

    // write enable signals
    input       wire [15:0]   wr_en_i,
    input       wire [15:0]   wr_en_w,
    input       wire [15:0]   rd_en_o,  // wr_en but inverted
    input       wire [15:0]   wr_en_ps,
    input       wire [7:0]    wr_en_r,

    // block enable signals
    input       wire          block_enable_i,
    input       wire          block_enable_w,
    input       wire          block_enable_ps,
    input       wire          block_enable_o,
    input       wire          block_enable_r
);
    wire          rd_en_i;
    wire          rd_en_w;
    wire          wr_en_o;
    wire          rd_en_p;


    /*--------------------------------------------------
    -- internal signals
    --------------------------------------------------*/
    wire          en_op;
    wire          load_done;
    wire          load_done_w;
    wire          clear_pe;
    wire          clear_modules;

    // interface reorder module
    wire  [127:0] input_activations;
    wire          valid_input;
    wire          initial_window;
    wire          row_transition;
    wire          req_3col;
    wire          finished_op;

    // interface weight logic unit
    wire [71:0]   filter_in;
    wire          valid_weight;

    // interface pe array
    wire [783:0]  pe_out;

    // controller interface
    wire          so;
    wire          en_pe_reg;
    wire [input_code_request_width - 1 : 0]  request_input;
    wire [weight_code_request_width - 1 : 0] request_weight;
    wire                                     request_output;
    wire                                     request_psums;

    // interface control buffer
    wire [12:0]  read_address_input;
    wire [11:0]  read_address_weight;
    wire [12:0]  write_address_output;
    wire [12:0]  read_address_psum;
    wire         valid_in;
    wire         valid_add_in;
    wire         valid_add_w;
    wire         valid_add_o;
    wire         valid_add_p;


    // interface of Regfile
    wire [7:0]    filter_size;
    wire          load_buffers_done;
    wire [7:0]    ch_id;
    wire [12:0]   ifmap_h;
    wire [12:0]   ifmap_w;
    wire          valid_out;
    wire          last_location;
    wire          done_slice;

    // interface of output logic
    wire [127:0]  psum_ch;
    wire          psum_valid;
    wire [783:0]  out_adder;
    wire [783:0]  out_mux;
    wire [783:0]  acc_ch;
    wire [783:0]  final_out;
    wire [127:0]  stream_out;
    wire [783:0]  stream_psum;
    wire          valid_out_1;

    /*--------------------------------------------------
    -- computational unit
    --------------------------------------------------*/
    computional_unit comp_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid_input(valid_input),
        .en_op(en_op),
        .input_activations(input_activations),
        .filter_size(filter_size),
        .initial_window(initial_window),
        .load_done(load_done),
        .row_transition(row_transition),
        .finished_op(finished_op),
        .req_3col(req_3col),
        .filter_in(filter_in),
        .valid_weight(valid_weight),
        .load_done_w(load_done_w),
        .clear_pe(clear_pe),
        .pe_out(pe_out)
    );

    /*--------------------------------------------------
    -- controller
    --------------------------------------------------*/
    controller_top #(
        .input_code_request_width(input_code_request_width),
        .weight_code_request_width(weight_code_request_width),
        .output_code_request_width(output_code_request_width),
        .psums_code_request_width(psums_code_request_width),
        .counter_width(counter_width)
    ) controller_top_inst (
        .clk(clk),
        .rst(rst_n),
        .clear(clear),
        .ch_id(ch_id),
        .filter_size(filter_size),
        .finished_op(finished_op),
        .load_done_reorder(load_done),
        .load_done_weight(load_done_w),
        .row_transition(row_transition),
        .load_buffers_done(load_buffers_done),
        .enable_modules(en_op),
        .output_selection(so),
        .request_input(request_input),
        .request_weight(request_weight),
        .request_output(request_output),
        .request_psums(request_psums),
        .clear_modules(clear_pe),
        .en_pe_reg(en_pe_reg)
    );

    /*--------------------------------------------------
    -- control Buffer
    --------------------------------------------------*/
    control_buff_top control_buff_inst (
        .clk(clk),
        .rst_n(rst_n),
        .req_input(request_input),
        .reg_ifmap_h(ifmap_h),
        .reg_ifmap_w(ifmap_w),
        .reg_filter_size(filter_size),
        .reg_channel_id(ch_id),
        .row_transition(row_transition),
        .req_3_col(req_3col),
        .read_address_input(read_address_input),
        .req_weight(request_weight),
        .read_address_weight(read_address_weight),
        .req_out(request_output),
        .write_address_output(write_address_output),
        .valid_in(valid_in),
        .req_psum(request_psums),
        .read_address_psum(read_address_psum),
        .valid_add_input(valid_add_in),
        .valid_add_weight(valid_add_w),
        .valid_add_out(valid_add_o),
        .valid_add_psum(valid_add_p),
        .done_slice(done_slice),
        .rden_input(rd_en_i),
        .rden_weight(rd_en_w),
        .rden_ps(rd_en_p),
        .wren_out(wr_en_o)
    );

    /*--------------------------------------------------
    -- Buffers
    --------------------------------------------------*/
    wire [12:0] index_address_i;
    assign index_address_i = address_i >> 4;
    wire wr_en_i_1bit;
    assign wr_en_i_1bit = |wr_en_i;
    input_buff input_buff_inst (
        .clk(clk),
        .rst_n(rst_n),
        .WrEn(wr_en_i_1bit),
        .RdEn(rd_en_i),
        .write_address(index_address_i),
        .read_address(read_address_input),
        .block_enable(block_enable_i),
        .data_in(data_bus_i),
        .data_out(input_activations),
        .data_valid(valid_input),
        .valid_add(valid_add_in)
    );

    wire [11:0] index_address_w;
    assign index_address_w = address_w >> 4;
    wire wr_en_w_1bit;
    assign wr_en_w_1bit = |wr_en_w;
    weight_buff weight_buff_inst(
        .clk(clk),
        .rst_n(rst_n),
        .WrEn(wr_en_w_1bit),
        .RdEn(rd_en_w),
        .write_address(index_address_w),
        .read_address(read_address_weight),
        .block_enable(block_enable_w),
        .data_in(data_bus_w[71:0]),
        .data_out(filter_in),
        .data_valid(valid_weight),
        .valid_add(valid_add_w)
    );

    wire [12:0] index_address_o;
    assign index_address_o = address_o >> 4;
    wire rd_en_o_1bit;
    assign rd_en_o_1bit = !(|rd_en_o);
    output_buff output_buff_inst(
        .clk(clk),
        .rst_n(rst_n),
        .WrEn(wr_en_o),
        .RdEn(rd_en_o_1bit),
        .write_address(write_address_output),
        .read_address(index_address_o),
        .block_enable(block_enable_o),
        .data_in(stream_out),
        .data_out(data_bus_o),
        .data_valid(valid_out_1),
        .valid_add(valid_add_o)
    );


    wire [12:0] index_address_ps;
    assign index_address_ps = address_ps >> 4;
    wire wr_en_ps_1bit;
    assign wr_en_ps_1bit = |wr_en_ps;
    psum_buff psum_buff_inst(
        .clk(clk),
        .rst_n(rst_n),
        .WrEn(wr_en_ps_1bit),
        .RdEn(rd_en_p),
        .write_address(index_address_ps),
        .read_address(read_address_psum),
        .block_enable(block_enable_ps),
        .data_in(data_bus_ps),
        .data_out(psum_ch),
        .data_valid(psum_valid),
        .valid_add(valid_add_p)
    );

    /*--------------------------------------------------
    -- register file
    --------------------------------------------------*/
    wire wr_en_r_1bit;
    assign wr_en_r_1bit = |wr_en_r;
    RegFile RegFile_inst(
        .clk(clk),
        .rst_n(rst_n),
        .wdata(data_bus_r_wr),
        .Address_in(address_r[4:3]),
        .wr_en(wr_en_r_1bit),
        .block_enable_r(block_enable_r),
        .rdata(data_bus_r_rd),
        .last_location(last_location),
        .reg_ifmap_h(ifmap_h),
        .reg_ifmap_w(ifmap_w),
        .reg_filter_size(filter_size),
        .reg_channel_id(ch_id),
        .load_25_percent_buffers_done(load_buffers_done),
        .valid_out(valid_out),
        .done_slice(done_slice)
    );

    /*--------------------------------------------------
    -- output logic
    --------------------------------------------------*/
    demux demux_inst (
        .pe_out(pe_out),
        .sel(so),
        .out_adder(out_adder),
        .out_mux(out_mux)
    );

    mux mux_inst(
        .pe_out(out_mux),
        .acc_channel(acc_ch),
        .sel(so),
        .mux_out(final_out)
    );

    pe_stream_buffer pe_stream_buffer_inst(
        .clk(clk),
        .rst(rst_n),
        .valid(en_pe_reg),
        .data_in(final_out),
        .en(valid_in),
        .data_out(stream_out),
        .valid_out(valid_out)
    );

    adder_array adder_array_inst(
        .pe_out(out_adder),
        .psum_ch(stream_psum),
        .acc_channel(acc_ch)
    );

    Stream_Psum Stream_Psum_inst(
        .clk(clk),
        .rst(rst_n),
        .data_in(psum_ch),
        .en(psum_valid),
        .data_out(stream_psum)
    );
endmodule