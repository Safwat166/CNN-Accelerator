module registerE(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         en,
    input  wire [111:0] reg_in,
    output wire [111:0] out_to_A
);

    /*---------------------------------------------------
    -- internal signals
    ---------------------------------------------------*/
    wire [111:0] wire_out;

    /*---------------------------------------------------
    -- instantiate 8-bit ffs for E0
    ---------------------------------------------------*/
    reg_8bit reg_E0_1(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[7:0]),
        .en(en),
        .q(wire_out[7:0])
    );

    reg_8bit reg_E0_2(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[15:8]),
        .en(en),
        .q(wire_out[15:8])
    );

    reg_8bit reg_E0_3(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[23:16]),
        .en(en),
        .q(wire_out[23:16])
    );

    reg_8bit reg_E0_4(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[31:24]),
        .en(en),
        .q(wire_out[31:24])
    );

    reg_8bit reg_E0_5(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[39:32]),
        .en(en),
        .q(wire_out[39:32])
    );

    reg_8bit reg_E0_6(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[47:40]),
        .en(en),
        .q(wire_out[47:40])
    );

    reg_8bit reg_E0_7(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[55:48]),
        .en(en),
        .q(wire_out[55:48])
    );

    reg_8bit reg_E0_8(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[63:56]),
        .en(en),
        .q(wire_out[63:56])
    );

    reg_8bit reg_E0_9(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[71:64]),
        .en(en),
        .q(wire_out[71:64])
    );

    reg_8bit reg_E0_10(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[79:72]),
        .en(en),
        .q(wire_out[79:72])
    );

    reg_8bit reg_E0_11(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[87:80]),
        .en(en),
        .q(wire_out[87:80])
    );

    reg_8bit reg_E0_12(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[95:88]),
        .en(en),
        .q(wire_out[95:88])
    );

    reg_8bit reg_E0_13(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[103:96]),
        .en(en),
        .q(wire_out[103:96])
    );

    reg_8bit reg_E0_14(
        .clk(clk),
        .rst_n(rst_n),
        .d(reg_in[111:104]),
        .en(en),
        .q(wire_out[111:104])
    );

    /*---------------------------------------------------
    -- instantiate 8-bit ffs for E1
    ---------------------------------------------------*/
    reg_8bit reg_E1_1(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[7:0]),
        .en(en),
        .q(out_to_A[7:0])
    );
    reg_8bit reg_E1_2(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[15:8]),
        .en(en),
        .q(out_to_A[15:8])
    );
    reg_8bit reg_E1_3(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[23:16]),
        .en(en),
        .q(out_to_A[23:16])
    );
    reg_8bit reg_E1_4(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[31:24]),
        .en(en),
        .q(out_to_A[31:24])
    );
    reg_8bit reg_E1_5(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[39:32]),
        .en(en),
        .q(out_to_A[39:32])
    );
    reg_8bit reg_E1_6(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[47:40]),
        .en(en),
        .q(out_to_A[47:40])
    );

    reg_8bit reg_E1_7(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[55:48]),
        .en(en),
        .q(out_to_A[55:48])
    );

    reg_8bit reg_E1_8(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[63:56]),
        .en(en),
        .q(out_to_A[63:56])
    );

    reg_8bit reg_E1_9(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[71:64]),
        .en(en),
        .q(out_to_A[71:64])
    );

    reg_8bit reg_E1_10(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[79:72]),
        .en(en),
        .q(out_to_A[79:72])
    );

    reg_8bit reg_E1_11(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[87:80]),
        .en(en),
        .q(out_to_A[87:80])
    );

    reg_8bit reg_E1_12(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[95:88]),
        .en(en),
        .q(out_to_A[95:88])
    );

    reg_8bit reg_E1_13(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[103:96]),
        .en(en),
        .q(out_to_A[103:96])
    );

    reg_8bit reg_E1_14(
        .clk(clk),
        .rst_n(rst_n),
        .d(wire_out[111:104]),
        .en(en),
        .q(out_to_A[111:104])
    );
endmodule