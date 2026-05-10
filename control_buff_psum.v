module control_buff_psum(
    input   wire            clk,rst_n,
    input   wire            req_psum,

    output  reg             valid_add,
    output  reg     [12:0]  read_address_psum
);

reg     [12:0]          psum_ptr;
reg     [2:0]           counter_psum;
reg                     req_psum_reg;
// Address Generation
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        psum_ptr <= 0;
        read_address_psum <= 0;
        valid_add <= 0;
    end else if (req_psum_reg) begin
        read_address_psum <= psum_ptr;
        psum_ptr <= psum_ptr + 1;
        valid_add <= 1;
    end
end

// register req_psum and count for 6 cycles then make it low
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        req_psum_reg <= 0;
        counter_psum <= 0;
    end else if (req_psum && !req_psum_reg) begin
        req_psum_reg <= req_psum;
        counter_psum <= 0;
    end else if(req_psum_reg) begin
        if(counter_psum == 3'b111) begin
            req_psum_reg <= 0;
            counter_psum <= 0;
        end else begin
            counter_psum <= counter_psum + 1;
        end
    end
end
endmodule