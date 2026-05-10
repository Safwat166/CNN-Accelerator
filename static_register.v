module static_register (
    input   wire         clk,
    input   wire         rst_n,
    input   wire [127:0] load_data,
    input   wire [127:0] reuse_data,
    input   wire         sel,
    input   wire         en,
    output  wire [127:0] wire_out
);

    /*---------------------------------------------------
    -- internal signals
    ---------------------------------------------------*/
    reg  [127:0] reg_in;

    /*---------------------------------------------------
    -- MUX to select between loading data or reuse data
    ---------------------------------------------------*/
    always @(*) begin
        case(sel)
            0: reg_in = load_data;
            1: reg_in = reuse_data; // reuse data from register A or B and skip 3 columns from it and load the new 3 columns from memory
            default: reg_in = wire_out;
        endcase
    end


    /*---------------------------------------------------
    -- instantiate 8-bit ffs
    ---------------------------------------------------*/
    reg_8bit reg_1(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[7:0]),
        .en(en),
        .q(wire_out[7:0])
    );
    reg_8bit reg_2(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[15:8]),
        .en(en),
        .q(wire_out[15:8])
    );
    reg_8bit reg_3(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[23:16]),
        .en(en),
        .q(wire_out[23:16])
    );
    reg_8bit reg_4(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[31:24]),
        .en(en),
        .q(wire_out[31:24])
    );
    reg_8bit reg_5(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[39:32]),
        .en(en),
        .q(wire_out[39:32])
    );
    reg_8bit reg_6(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[47:40]),
        .en(en),
        .q(wire_out[47:40])
    );

    reg_8bit reg_7(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[55:48]),
        .en(en),
        .q(wire_out[55:48])
    );

    reg_8bit reg_8(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[63:56]),
        .en(en),
        .q(wire_out[63:56])
    );

    reg_8bit reg_9(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[71:64]),
        .en(en),
        .q(wire_out[71:64])
    );

    reg_8bit reg_10(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[79:72]),
        .en(en),
        .q(wire_out[79:72])
    );

    reg_8bit reg_11(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[87:80]),
        .en(en),
        .q(wire_out[87:80])
    );

    reg_8bit reg_12(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[95:88]),
        .en(en),
        .q(wire_out[95:88])
    );

    reg_8bit reg_13(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[103:96]),
        .en(en),
        .q(wire_out[103:96])
    );

    reg_8bit reg_14(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[111:104]),
        .en(en),
        .q(wire_out[111:104])
    );

    reg_8bit reg_15(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[119:112]),
        .en(en),
        .q(wire_out[119:112])
    );

    reg_8bit reg_16(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[127:120]),
        .en(en),
        .q(wire_out[127:120])
    );
endmodule