module PE_Array_Top (
    input  wire         CLK,
    input  wire         rst,
    input  wire        en_pe,
    input  wire        clear,
    input  wire        available_data,
    input  wire [111:0] OUT_A, 
    input  wire [111:0] OUT_B, 
    input  wire [7:0]   filter_in1,
	
    output wire [783:0] pe_out      // 28-bit * 28 PEs = 784 bits
);

    genvar i;
    generate
        for (i = 0; i < 14; i = i + 1) begin 
            PE pe_a (
                .CLK            (CLK), 
                .rst            (rst), 
                .en_pe          (en_pe), 
                .clear          (clear),
                .available_data (available_data),
                .in_element     (OUT_A[i*8 +: 8]),
                .in_filter      (filter_in1),
                .pe_out         (pe_out[i*28 +: 28])
            );
            PE pe_b (
                .CLK            (CLK), 
                .rst            (rst), 
                .en_pe          (en_pe), 
                .clear          (clear),
                .available_data (available_data),
                .in_element     (OUT_B[i*8 +: 8]),
                .in_filter      (filter_in1),
                .pe_out         (pe_out[(i+14)*28 +: 28]) 
            );
        end
    endgenerate

endmodule