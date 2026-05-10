module demux (
    input  wire [783:0] pe_out,
    input  wire         sel,
    
	output wire [783:0] out_adder,
    output wire [783:0] out_mux
);

    assign out_adder = (sel == 1'b0) ? pe_out : 784'b0;
    assign out_mux   = (sel == 1'b1) ? pe_out : 784'b0;

endmodule
