module valid_logic (
    input   wire         clk,               // clock system
    input   wire         rst_n,             // active low reset
    input   wire  [7:0]  filter_size,       // current channel filter size
    input   wire         en_op,             // start operation states
    input   wire         valid_data,        // data is ready from input buffer
    output  reg          valid_left_A,      // shift left operation RegA
    output  reg          valid_left_B,      // shift left operation RegB 
    output  reg          valid_up_A,        // shift up operation RegA 
    output  reg          valid_up_B,        // shift up operation RegB
    output  reg          valid_reuse,       // 3x3 filter- reuse two rows     filter>3x3- reuse the previous window and add new 3 columns
    output  reg          finished_op,       // processed all elements in the window
    output  reg          sel_C_D,           // 0- shift up (RegB <- RegC)   1- shift up (RegB <- RegD)
    output  reg          available_data,    // new input activation
    output  reg          row_transition,    // moving in vertical direction (ex: assume filter 6x6 row transition = 1 when transit from subfilter a -> b)
    output  reg          request3_col,      // requesting reuse window for the next subfilters
    output  reg   [3:0]  cnt,               // counter to control the flow of reorder module
    output  reg   [7:0]  num_subfilter,     // number of subfilters in horizontal and vertical direction
    output  reg   [7:0]  subfilter_hor,     // to track number of subfilters in horizontal direction
    output  reg   [7:0]  subfilter_ver      // to track number of subfilters in vertical direction direction
);

    /*--------------------------------------------------------------
    -- internal signals
    --------------------------------------------------------------*/
    reg  [7:0]   filter_siz_reg;        // internal register to store filter size
    reg  [7:0]   filter_siz_reg1;       // internal register to store filter size
    reg  [2:0]   cnt_row;               // i want row transition to be high for 4 valid data signals

    /*----------------------------------------------------------
    -- valid signal logic to control flow or reorder module
    ----------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_left_A <= 0;
            valid_left_B <= 0;
            valid_up_A <= 0;
            valid_up_B <= 0;
            valid_reuse <= 0;
            sel_C_D <= 1'b0;
            cnt <= 0;
            finished_op <= 0;
            available_data <= 0;
            request3_col <= 0;
        end
        else begin
            valid_left_A <= 0;
            valid_left_B <= 0;
            valid_up_A <= 0;
            valid_up_B <= 0;
            valid_reuse <= 0;
            sel_C_D <= 1'b0;
            cnt <= 0;
            finished_op <= 0;
            available_data <= 0;
            request3_col <= 0;
            if(en_op) begin
                if(filter_siz_reg == 3) begin
                    case(cnt)
                        0: begin
                            cnt <= cnt + 1;
                            valid_left_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        1: begin
                            cnt <= cnt + 1;
                            valid_left_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        2: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_up_B <= 1;
                            available_data <= 1;
                        end
                        3: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        4: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        5: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_up_B <= 1;
                            sel_C_D <= 1'b1;
                            available_data <= 1;
                        end
                        6: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        7: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        8: begin
                            cnt <= cnt + 1;
                            valid_reuse <= 1;
                            finished_op <= 1;
                            available_data <= 1;
                        end

                        default: begin
                            valid_left_A <= 0;
                            valid_left_B <= 0;
                            valid_up_A <= 0;
                            valid_up_B <= 0;
                            valid_reuse <= 0;
                            sel_C_D <= 1'b0;
                            cnt <= 0;
                            finished_op <= 0;
                            available_data <= 0;
                        end
                    endcase
                end
                else if(filter_siz_reg != 3) begin
                    case(cnt)
                        0: begin
                            cnt <= cnt + 1;
                            valid_left_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                            if(subfilter_hor == 0) begin
                                request3_col <= 1;
                            end
                        end
                        1: begin
                            cnt <= cnt + 1;
                            valid_left_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                            if(subfilter_hor == 0) begin
                                request3_col <= 1;
                            end
                        end
                        2: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_up_B <= 1;
                            available_data <= 1;
                            if(subfilter_hor == 0) begin
                                request3_col <= 1;
                            end
                        end
                        3: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                            if(subfilter_hor == 0) begin
                                request3_col <= 1;
                            end
                        end
                        4: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        5: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_up_B <= 1;
                            sel_C_D <= 1'b1;
                            available_data <= 1;
                        end
                        6: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        7: begin
                            cnt <= cnt + 1;
                            valid_up_A <= 1;
                            valid_left_B <= 1;
                            available_data <= 1;
                        end
                        8: begin
                            cnt <= cnt + 1;
                            finished_op <= 1;
                            available_data <= 1;
                            valid_reuse <= 1;
                        end

                        default: begin
                            valid_left_A <= 0;
                            valid_left_B <= 0;
                            valid_up_A <= 0;
                            valid_up_B <= 0;
                            valid_reuse <= 0;
                            sel_C_D <= 1'b0;
                            cnt <= 0;
                            finished_op <= 0;
                            available_data <= 0;
                            request3_col <= 0;
                        end
                    endcase
                end
            end
        end
    end

    /*-----------------------------------------------------------------
    -- register filter size
    -----------------------------------------------------------------*/
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            filter_siz_reg <= 0;
        end
        else begin
            if(valid_data && !available_data) begin
                filter_siz_reg <= filter_size;
            end
        end
    end

    /*-----------------------------------------------------------------
    -- to know how many subfilters with 3*3 so i know
    -- when i'm going to transit to vertical subfilter
    -- example: filter 6*6 (4 3*3 subfilters) (subfilter a, b, c, d)
    -----------------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            filter_siz_reg1 <= 0;
            num_subfilter <= 0;
        end
        else begin
            if(valid_data && !available_data) begin
                filter_siz_reg1 <= filter_size;
                num_subfilter <= 0;
            end
            else if((filter_siz_reg1 != 3) && (filter_siz_reg1 != 0)) begin
                filter_siz_reg1 <= filter_siz_reg1 - 3;
                num_subfilter <= num_subfilter + 1;
            end
            else if((num_subfilter == subfilter_hor) && (num_subfilter == subfilter_ver) && finished_op) begin
                num_subfilter <= 0;
            end
        end
    end


    /*----------------------------------------------------
    -- Count subfilters in horizontal direction
    -- to control when transiting from subfilter
    -- to another (when filter > 3*3)
    ----------------------------------------------------*/
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            subfilter_hor <= 0;
            row_transition <= 0;
            cnt_row <= 0;
        end
        else begin
            if((filter_siz_reg != 3) && (finished_op)) begin
                subfilter_hor <= subfilter_hor + 1;
                if(subfilter_hor == num_subfilter) begin
                    row_transition <= 1;
                    subfilter_hor <= 0;
                    if(subfilter_hor == subfilter_ver) begin
                        row_transition <= 0;
                    end
                end
            end
            else if(row_transition) begin
                cnt_row <= cnt_row + 1;
                if(cnt_row == 3) begin
                    row_transition <= 0;
                    cnt_row <= 0;
                end
            end
        end
    end

    /*----------------------------------------------------
    -- Count subfilters in vertical direction
    ----------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            subfilter_ver <= 0;
        end
        else begin
            if((subfilter_hor == num_subfilter) && finished_op) begin
                subfilter_ver <= subfilter_ver + 1;
                if(subfilter_ver == num_subfilter) begin
                    subfilter_ver <= 0;
                end
            end
        end
    end
    
endmodule