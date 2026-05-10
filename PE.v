module PE (
    input  wire        CLK,
    input  wire        rst,
    input  wire        en_pe,
    input  wire        clear,
    input  wire        available_data,
    input  wire [7:0]  in_element,
    input  wire [7:0]  in_filter,
	
    output wire [27:0] pe_out       // 28-bit: [27:24]=4'b00, [23:0]=acc
);

    reg [23:0] acc_reg;             // 24-bit accumulator

    always @(posedge CLK or negedge rst) begin
        if (!rst) begin
            acc_reg <= 24'b0;
        end 
        else begin 
		if (clear) begin
                 acc_reg <= 24'b0;
        end else if (en_pe && available_data) begin
			    acc_reg <= acc_reg + (in_element * in_filter);
		end
		end
		end

    assign pe_out = {4'b0000, acc_reg};   // MSB 4 bits always zero

endmodule