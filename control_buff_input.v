module control_buff_input (
    input wire        clk,rst_n,
    input wire [1:0]  request,

    //Interface to Register File (Configuration)
    input wire [12:0] reg_ifmap_h,      // Ifmap Height
    input wire [12:0] reg_ifmap_w,      // Ifmap Width
    input wire [7:0]  reg_filter_size,  // ex: 3 for 3x3, 4 for 4x4
    input wire [7:0]  reg_channel_id,   // Current Channel being processed
    // Reorder Module Control Signals
    input wire        row_transition,
    input wire        req_3_col,          

    output reg [12:0] read_address_input,
    output reg        valid_add,
    output reg        initial_window
);

reg     [1:0]   counter;
reg     [12:0]  row_ptr_ifmap_w;
reg     [12:0]  coulmn_ptr_ifmap_h;
reg     [12:0]  normal_ptr , reuse_base;

// Calculate Number of 16 coulmns needed to finish Ifmap -- divide by 16 ex (64 / 16 = 4)
// so need 4 window of 16 coulmns to finish IFmap height
wire    [15:0]  total_16_coulmn_window;
assign total_16_coulmn_window = (reg_ifmap_h >> 4); 

// read address generation for input
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_address_input <= 13'b0;
        counter <= 0;
        row_ptr_ifmap_w <= 0;
        coulmn_ptr_ifmap_h <= 0;
        normal_ptr <= 0;
        reuse_base <=0;
        valid_add <= 0;
    end else begin
        valid_add <= 0;
        if (request == 2'b01) begin // first window
            case (counter)
                0 : begin
                    normal_ptr <= normal_ptr + 1; // make sure from this
                    reuse_base <= reg_ifmap_w;
                    row_ptr_ifmap_w <= 0;
                    coulmn_ptr_ifmap_h <= 0;
                    read_address_input <= normal_ptr;
                    counter <= counter + 1;
                    valid_add <= 1;
                end
                1 : begin
                    read_address_input <= normal_ptr;
                    normal_ptr <= normal_ptr + 1;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    counter <= counter + 1;
                    valid_add <= 1;
                end
                2 : begin
                    read_address_input <= normal_ptr;
                    normal_ptr <= normal_ptr + 1;
                    counter <= counter + 1;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    valid_add <= 1;
                end
                3 : begin
                    read_address_input <= normal_ptr;
                    normal_ptr <= normal_ptr + 1;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    counter <= 0;
                    valid_add <= 1;
                end
            endcase
        end else if (request == 2'b10) begin // filter is 3*3 and request new window "first was 0 - 3" second -- (2 -- 5)
            case (counter)
                0 : begin
                    normal_ptr <= normal_ptr - 1;
                    reuse_base <= ( normal_ptr + 1 ) + reg_ifmap_w;
                    read_address_input <= normal_ptr - 1 - 1;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    counter <= counter + 1;
                    valid_add <= 1;
                    if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                        row_ptr_ifmap_w <= 0;
                        coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                        normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                        reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    end
                end
                1 : begin
                    read_address_input <= normal_ptr;
                    normal_ptr <= normal_ptr + 1;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    counter <= counter + 1;
                    valid_add <= 1;
                    if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                        row_ptr_ifmap_w <= 0;
                        coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                        normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                        reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    end
                end
                2 : begin
                    normal_ptr <= normal_ptr + 1;
                    read_address_input <= normal_ptr;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    counter <= counter + 1;
                    valid_add <= 1;
                    if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                        row_ptr_ifmap_w <= 0;
                        coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                        normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                        reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    end
                end
                3 : begin
                    normal_ptr <= normal_ptr + 1;
                    read_address_input <= normal_ptr;
                    row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                    counter <= 0;
                    valid_add <= 1;
                    if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                        row_ptr_ifmap_w <= 0;
                        coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                        normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                        reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    end
                end
            endcase
        end else if (request == 2'b11) begin // filter greater than 3*3 and need 4 rows
            case (reg_filter_size)
                6 : begin // filter 6*6
                    case (counter)
                        0 : begin
                            normal_ptr <= normal_ptr - 5; // Pointer initial points at 7 so address 2 will be out
                            reuse_base <= (normal_ptr - 5 - 1) + reg_ifmap_w;
                            read_address_input <= normal_ptr-5-1;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w - 5;
                            valid_add <= 1;
                        end
                        1 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        2 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        3 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= 0;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                    endcase
                end
                9 : begin // filter 9 * 9
                    case (counter)
                        0 : begin
                            normal_ptr <= normal_ptr - 9; // Pointer initial points at 11 so address 2 will be out
                            reuse_base <= (normal_ptr - 9 -1  ) + reg_ifmap_w;
                            read_address_input <= normal_ptr -9 -1; 
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w - 9;
                            valid_add <= 1;
                        end
                        1 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr ;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        2 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        3 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= 0;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                    endcase
                end
                12 : begin // filter 12*12
                    case (counter)
                        0 : begin
                            normal_ptr <= normal_ptr - 13; // Pointer initial points at 15 so address 2 will be out
                            reuse_base <= (normal_ptr - 13 -1  ) + reg_ifmap_w;
                            read_address_input <= normal_ptr -13 -1;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w - 13;
                            valid_add <= 1;
                        end
                        1 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        2 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        3 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= 0;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                    endcase
                end
                15 : begin
                    case (counter)
                        0 : begin
                            normal_ptr <= normal_ptr - 17; // Pointer initial points at 19 so address 2 will be out
                            reuse_base <= (normal_ptr - 17 -1 ) + reg_ifmap_w;
                            read_address_input <= normal_ptr-17-1;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w - 17;
                            valid_add <= 1;
                        end
                        1 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        2 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            counter <= counter + 1;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                        3 : begin
                            normal_ptr <= normal_ptr + 1;
                            read_address_input <= normal_ptr;
                            row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                            counter <= 0;
                            valid_add <= 1;
                            if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                                row_ptr_ifmap_w <= 0;
                                coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                                normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                                reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                            end
                        end
                    endcase
                end
                default : begin
                    read_address_input <= 0;
                    counter <= 0;
                    valid_add <= 1;
                end
            endcase
        end else if (req_3_col) begin // need 3 col for reuse
        case (counter)
            0 : begin
                reuse_base <= reuse_base + 1;
                read_address_input <= reuse_base;
                counter <= counter + 1;
                valid_add <= 1;
            end
            1 : begin
                reuse_base <= reuse_base + 1;
                read_address_input <= reuse_base;
                counter <= counter + 1;
                valid_add <= 1;
            end
            2 : begin
                reuse_base <= reuse_base + 1;
                read_address_input <= reuse_base;
                counter <= counter + 1;
                valid_add <= 1;
            end
            3 : begin
                reuse_base <= reuse_base + 1;
                read_address_input <= reuse_base;
                counter <= 0;
                valid_add <= 1;
            end
        endcase
        end else if (row_transition) begin
            case (counter)
            0 : begin
                normal_ptr <= normal_ptr + 1;
                //reuse_base <= reuse_base + 1; // as req 3 col was send before so reuse was at 3 from index 0
                read_address_input <= normal_ptr;
                counter <= counter + 1;
                row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                valid_add <= 1;
                if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                    row_ptr_ifmap_w <= 0;
                    coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                    normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                end
            end
            1 : begin
                normal_ptr <= normal_ptr + 1;
                read_address_input <= normal_ptr;
                counter <= counter + 1;
                row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                valid_add <= 1;
                if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                    row_ptr_ifmap_w <= 0;
                    coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                    normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                end
            end
            2 : begin
                normal_ptr <= normal_ptr + 1;
                read_address_input <= normal_ptr;
                counter <= counter + 1;
                row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                valid_add <= 1;
                if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                    row_ptr_ifmap_w <= 0;
                    coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                    normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                end
            end
            3 : begin
                normal_ptr <= normal_ptr + 1;
                read_address_input <= normal_ptr;
                counter <= 0;
                row_ptr_ifmap_w <= row_ptr_ifmap_w + 1;
                valid_add <= 1;
                if(row_ptr_ifmap_w >= (reg_ifmap_w - 1)) begin // jump to next  verticalslice
                    row_ptr_ifmap_w <= 0;
                    coulmn_ptr_ifmap_h <= coulmn_ptr_ifmap_h + 1;
                    normal_ptr <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                    reuse_base <= (coulmn_ptr_ifmap_h +1 ) * reg_ifmap_w;
                end 
            end
            endcase
        end
    end
end

// initial window is high at beginning of every vertical slice in case of filter 3*3
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        initial_window <= 0;
    end
    if(reg_filter_size == 3) begin
            if(row_ptr_ifmap_w == 13'd0 && rst_n) begin
                initial_window <= 1;
            end
            else begin
                initial_window <= 0;
            end
    end else begin
        initial_window <= 0;
    end
    end
endmodule