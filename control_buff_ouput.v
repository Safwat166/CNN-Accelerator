module control_buff_output(
    input   wire            clk,rst_n,
    input   wire            req_out,

    output  reg     [12:0]  write_address_output,
    output  reg             valid_add,
    output  reg             valid_in
);

reg     [12:0]          out_ptr;
reg     [2:0]           counter_out;
reg                     req_out_reg;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        out_ptr <= 0;
        valid_in <= 0;
        write_address_output <= 0;
        valid_add <= 0;
    end else if (req_out_reg) begin
        write_address_output <= out_ptr;
        out_ptr <= out_ptr + 1;
        valid_in <= 1;
        valid_add <= 1;
    end else begin
        valid_in <= 0;
        valid_add <= 0;
    end
end

// register req_out and count for 6 cycles then make it low
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        req_out_reg <= 0;
        counter_out <= 0;
    end else if (req_out && !req_out_reg) begin
        req_out_reg <= req_out;
        counter_out <= 0;
    end else if(req_out_reg) begin
        if(counter_out == 3'b111) begin
            req_out_reg <= 0;
            counter_out <= 0;
        end else begin
            counter_out <= counter_out + 1;
        end
    end
end
endmodule