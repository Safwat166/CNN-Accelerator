module input_buff(
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

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        data_out <= 128'b0;
        data_valid <= 1'b0;
    end else if (block_enable) begin
        case({WrEn,RdEn})
        2'b01 :  begin // read from Memory
        data_valid <= 0;
            if(valid_add) begin
                data_out <= mem[read_address];
                data_valid <= 1'b1;
            end
        end
        2'b10 : begin // write in memory
            mem[write_address] <= data_in;
            data_valid <= 1'b0;
        end
        2'b11 : begin // read and write from memory
            mem[write_address] <= data_in;
            data_valid <= 0;
            if(valid_add) begin
                data_out <= mem[read_address];
                data_valid <= 1'b1;
            end
        end
        default : data_valid <= 1'b0; 
        endcase
    end
end
endmodule