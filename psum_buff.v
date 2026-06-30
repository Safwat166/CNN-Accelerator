module psum_buff(
    input   wire            clk,rst_n,
    input   wire            WrEn,RdEn,
    input   wire    [12:0]  write_address, // From AXI
    input   wire    [12:0]  read_address,
    input   wire            block_enable,
    input   wire    [127:0] data_in,
    input   wire            valid_add,

    output  reg     [127:0] data_out,
    output  reg             data_valid
);

reg [127:0] mem [8191:0]; // 8192 locations and each location is 128 bit
// write
always@(posedge clk) begin
    if(block_enable) begin
        if (WrEn) begin
            mem[write_address] <= data_in;   
        end
    end
end
always @(posedge clk) begin
    if(~rst_n) begin
        data_out <= 128'b0;
        data_valid <= 1'b0;
    end else begin
        if(RdEn && valid_add) begin
                data_out <= mem[read_address];
                data_valid <= 1'b1;
        end
        else begin
            data_valid <= 0;
        end
    end
end
endmodule