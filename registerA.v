module registerA (
    input   wire         clk,
    input   wire         rst_n,
    input   wire [127:0] load_data,
    input   wire [111:0] shift_up,
    input   wire [127:0] reuse_data,
    input   wire         load_done,
    input   wire         valid_left,
    input   wire         valid_up,
    input   wire         valid_reuse,
    input   wire         en,
    output  wire [127:0] wire_out
);

    /*---------------------------------------------------
    -- internal signals
    ---------------------------------------------------*/
    reg  [127:0] reg_in;

    /*---------------------------------------------------
    -- MUX to select between 
    ---------------------------------------------------*/
    always @(*) begin
        case({load_done,valid_left, valid_up, valid_reuse})
            4'b1000:begin
                reg_in = load_data;
            end
            4'b0100: begin
                reg_in = {wire_out[119:0], 8'b0};
            end
            4'b0010: begin
                reg_in[127:16] = shift_up;
                reg_in[15:0] = 16'b0;
            end
            4'b0001: begin
                reg_in = reuse_data;
            end
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