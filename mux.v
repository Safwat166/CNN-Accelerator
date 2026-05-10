module mux (
    input  wire [783:0] pe_out,
    input  wire [783:0] acc_channel,
    input  wire         sel,
    output wire [783:0] mux_out
);

    assign mux_out = (sel == 1'b0) ? acc_channel : pe_out;

endmodule