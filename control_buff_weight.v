module control_buff_weight(
    input   wire            clk,rst_n,
    input   wire    [1:0]   req_weight,

    input   wire    [7:0]   reg_filter_size,
    // need 12 address line to access 200 locations each one is 9 byte
    output  reg     [11:0]  read_address_weight,
    output  reg             valid_add
);

reg   [11:0]  weight_ptr;

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        weight_ptr <= 0;
        read_address_weight <= 0;
        valid_add <= 0;
    end else begin
        valid_add <= 0;
        if(req_weight == 2'b01) begin // first window
            read_address_weight <= weight_ptr;
            weight_ptr <= weight_ptr + 1 ;
            valid_add <= 1;
        end else if (req_weight == 2'b10) begin // next subfilter
            read_address_weight <= weight_ptr;
            weight_ptr <= weight_ptr + 1;
            valid_add <= 1;
        end else if (req_weight == 2'b11) begin // backward to return to a
            case (reg_filter_size)
                6 : begin
                    weight_ptr <= weight_ptr - 3;
                    read_address_weight <= weight_ptr - 3 - 1;
                    valid_add <= 1;
                end
                9 : begin
                    weight_ptr <= weight_ptr - 8;
                    read_address_weight <= weight_ptr-8 - 1;
                    valid_add <= 1;
                end
                12 : begin
                    weight_ptr <= weight_ptr - 15;
                    read_address_weight <= weight_ptr - 15 - 1;
                    valid_add <= 1;
                end
                15 : begin
                    weight_ptr <= weight_ptr - 19;
                    read_address_weight <= weight_ptr - 19 - 1 ;
                    valid_add <= 1;
                end
                default : begin
                    weight_ptr <= 0;
                    read_address_weight <= 0;
                    valid_add <= 1;
                end
            endcase
        end
    end
end
endmodule