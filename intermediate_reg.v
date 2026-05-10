module intermediate_reg (
    input  wire           clk,                      // clock
    input  wire           rst_n,                    // negative edge reset
    input  wire           valid_data,               // data is valid from input buffer
    input  wire           en_op,                    // operation state from control unit
    input  wire           available_data,           // high with every new values
    input  wire           row_transition,           // Indicate that i'm going to make row transition in case of filter > 3x3
    input  wire           finished_op,              // Indicate that the whole operation is finished to start the next one
    input  wire   [127:0] input_activations,        // feature map
    input  wire   [7:0]   subfilter_hor,            // number of subfilters in horizontal direction
    output reg            load_done,                // RegA, RegB, RegC, RegD are loaded
    output reg    [127:0] reg_A,                    // intermediate register to RegA
    output reg    [127:0] reg_B,                    // intermediate register to RegB
    output reg    [127:0] reg_C,                    // intermediate register to RegC
    output reg    [127:0] reg_D,                    // intermediate register to RegD
    output reg    [127:0] reuse_A,                  // intermediate register to take 3 columns from reuse window
    output reg    [127:0] reuse_B,                  // intermediate register to take 3 columns from reuse window
    output reg    [127:0] reuse_C,                  // intermediate register to take 3 columns from reuse window
    output reg    [127:0] reuse_D                   // intermediate register to take 3 columns from reuse window
);

    /*--------------------------------------------------------------
    -- internal signals
    --------------------------------------------------------------*/
    reg [1:0] counter;
    reg       row_transition_reg;

    /*--------------------------------------------------------------
    -- register row transition
    --------------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            row_transition_reg <= 0;
        end
        else begin
            if(row_transition) begin
                row_transition_reg <= 1;
            end
            else if (finished_op) begin
                row_transition_reg <= 0;
            end
        end
    end

    /*--------------------------------------------------------------
    -- loading operation
    --------------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_A <= 128'b0;
            reg_B <= 128'b0;
            reg_C <= 128'b0;
            reg_D <= 128'b0;
            reuse_A <= 128'b0;
            reuse_B <= 128'b0;
            reuse_C <= 128'b0;
            reuse_D <= 128'b0;
            counter <= 0;
            load_done <= 0;
        end
        else begin

            // load input activations of subfilter a or if filter size == 3x3
            if(valid_data && !available_data) begin
                case(counter)
                    0: begin
                        reg_A <= input_activations;
                        counter <= counter + 1;
                        // when transit in vertical direction i store 4th row of previous window
                        if(row_transition_reg) begin
                            reg_A <= reg_D;
                            reg_B <= input_activations;
                        end
                    end

                    1: begin
                        reg_B <= input_activations;
                        counter <= counter + 1;
                        if(row_transition_reg) begin
                            reg_B <= reg_B;
                            reg_C <= input_activations;
                        end
                    end
                    
                    2:  begin
                        reg_C <= input_activations;
                        counter <= counter + 1;
                        if(row_transition_reg) begin
                            reg_C <= reg_C;
                            reg_D <= input_activations;
                        end
                    end
                    
                    3: begin
                        reg_D <= input_activations;
                        counter <= 0;
                        load_done<=1;
                        if(row_transition_reg) begin
                            reg_D <= reg_D;
                        end
                    end
                    default: begin
                        counter <= 0;
                    end
                endcase
            end

            // load input activations of the remaining subfilters by requesting new 3 coloumns
            else if (valid_data && available_data) begin
                if(subfilter_hor == 0) begin
                    case(counter)
                        0: begin
                            reuse_A <= input_activations;
                            counter <= counter + 1;
                            // when transit in vertical direction i store 4th row of previous window
                            if(row_transition_reg) begin
                                reuse_A <= reuse_D;
                                reuse_B <= input_activations;
                            end
                        end
                        1: begin
                            reuse_B <= input_activations;
                            counter <= counter + 1;
                            if(row_transition_reg) begin
                                reuse_B <= reuse_B;
                                reuse_C <= input_activations;
                            end
                        end
                        2: begin
                            reuse_C <= input_activations;
                            counter <= counter + 1;
                            if(row_transition_reg) begin
                                reuse_C <= reuse_C;
                                reuse_D <= input_activations;
                            end
                        end
                        3: begin
                            reuse_D <= input_activations;
                            counter <= 0 ;
                            if(row_transition_reg) begin
                                reuse_D <= reuse_D;
                            end
                        end
                    endcase
                end
            end
            
            // low the load_done
            else if(en_op)
                load_done <= 0;
        end
    end
endmodule