module adder_array (
    input  wire [783:0] pe_out,       
    input  wire [783:0] psum_ch,  
   
    output wire [783:0] acc_channel       
);

    genvar i;
    generate
        for (i = 0; i < 28; i = i + 1) begin 
            // collect 28 bit from pe_out and psum_ch
            wire [27:0] a = pe_out  [i*28 +: 28];
            wire [27:0] b = psum_ch [i*28 +: 28];

            assign acc_channel[i*28 +: 28] = (a + b) ;
        end
    endgenerate

endmodule
