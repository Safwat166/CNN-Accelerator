module reorder_module(
    input  wire          clk,                       // System Clock
    input  wire          rst_n,                     // System negative Reset
    input  wire          valid_data,                // Indicate that data from memory is ready
    input  wire          en_op,                     // Enable Signal from control unit to start operation
    input  wire [127:0]  input_activations,         // Input Data from memory
    input  wire [7:0]    filter_size,               // to indicate filter size to control the reuse logic
    input  wire          initial_window,            // to indicate that i'm in the initial window to reuse 2 rows in case filter = 3x3
    output wire          load_done,                 // Indicate that data is stored successfully
    output wire          row_transition,            // Indicate that i'm going to make row transition in case of filter > 3x3
    output wire          available_data,            // Indicate that data is available for the PE array to start processing
    output wire          finished_op,               // Indicate that the whole operation is finished to start the next one
    output wire          request3_col,              // request new 3 columns from the control buffer
    output wire [111:0]  out_A,                     // Output Wire for RegA
    output wire [111:0]  out_B                      // Output Wire for RegB
);

    /*----------------------------------------------------
    -- internal signals
    ----------------------------------------------------*/
    wire [127:0] reg_A;                 // Input Activations for RegA
    wire [127:0] reg_B;                 // Input Activations for RegB
    wire [127:0] reg_C;                 // Input Activations for RegC
    wire [127:0] reg_D;                 // Input Activations for RegD
    wire [127:0] reuse_window_A;        // To store the new three columns that will be used in next subfilter
    wire [127:0] reuse_window_B;        // To store the new three columns that will be used in next subfilter
    wire [127:0] reuse_window_C;        // To store the new three columns that will be used in next subfilter
    wire [127:0] reuse_window_D;        // To store the new three columns that will be used in next subfilter
    wire         valid_left_A;          // Register A Shifts left
    wire         valid_left_B;          // Register B Shifts left
    wire         valid_up_A;            // Register A Shifts up
    wire         valid_up_B;            // Register B Shifts up
    wire         valid_reuse;           // To reuse data from Reg A, B to C, D
    reg          sel_C;                 // Selection for RegC 0-Loading   1-Reuse_Data from Reg A, B
    reg          sel_D;                 // Selection for RegD 0-Loading   1-Reuse_Data from Reg A, B
    wire [127:0] wire_A;                // Wire for Register A output
    wire [127:0] wire_B;                // Wire for Register B output
    wire [127:0] wire_C;                // Wire for Register C output
    wire [127:0] wire_D;                // Wire for Register D output
    reg  [127:0] reuse_A;               // Intermediate wires to swap Reg A, B to Reg C, D
    reg  [127:0] reuse_B;               // Intermediate wires to swap Reg A, B to Reg C, D
    wire [111:0] shift_up_A;            // input to RegA from RegE 
    wire [127:0] shift_up_B;            // input to RegE from RegB
    wire         sel_C_D;               // Select RegB loading mode (0-Load From RegC    1-Load From RegD)
    wire [3:0]   cnt;                   // to control the flow
    reg  [7:0]   filter_siz_reg;        // internal register to store filter size
    wire [7:0]   subfilter_ver;         // to track number of subfilters in horizontal direction
    wire [7:0]   subfilter_hor;         // number of subfilters in horizontal direction
    wire [7:0]   num_subfilter;         // number of subfilters in horizontal and vertical direction
    reg          initial_window_reg;    // intermediate register for initial window
    
    /*----------------------------------------------------
    -- intermediate register instantiation
    ----------------------------------------------------*/
    intermediate_reg intermediate_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid_data(valid_data),
        .en_op(en_op),
        .available_data(available_data),
        .row_transition(row_transition),
        .finished_op(finished_op),
        .input_activations(input_activations),
        .load_done(load_done),
        .reg_A(reg_A),
        .reg_B(reg_B),
        .reg_C(reg_C),
        .reg_D(reg_D),
        .reuse_A(reuse_window_A),
        .reuse_B(reuse_window_B),
        .reuse_C(reuse_window_C),
        .reuse_D(reuse_window_D),
        .subfilter_hor(subfilter_hor)
    );

    /*----------------------------------------------------
    -- 
    ----------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            initial_window_reg <= 0;
        end
        else begin
            if(initial_window) begin
                initial_window_reg <= 1;
            end
            else if (finished_op) begin
                initial_window_reg <= 0;
            end
        end
    end


    /*----------------------------------------------------
    -- register A
    ----------------------------------------------------*/
    registerA registerA_inst (
        .clk(clk),
        .rst_n(rst_n),
        .load_data(reg_A),
        .shift_up(shift_up_A),
        .reuse_data(wire_C),
        .en(en_op),
        .load_done(load_done),
        .valid_left(valid_left_A),
        .valid_up(valid_up_A),
        .valid_reuse(valid_reuse),
        .wire_out(wire_A)
    );

    assign out_A = wire_A[127:16];

    /*----------------------------------------------------
    -- register B
    ----------------------------------------------------*/
    registerB registerB_inst (
        .clk(clk),
        .rst_n(rst_n),
        .load_data(reg_B),
        .shift_up(shift_up_B),
        .reuse_data(wire_D),
        .en(en_op),
        .load_done(load_done),
        .valid_left(valid_left_B),
        .valid_up(valid_up_B),
        .valid_reuse(valid_reuse),
        .wire_out(wire_B)
    );

    assign out_B = wire_B[127:16];
    assign shift_up_B = (sel_C_D == 1'b0) ? wire_C : wire_D;

    /*----------------------------------------------------
    -- static register C
    ----------------------------------------------------*/
    static_register static_registerC_inst (
        .clk(clk),
        .rst_n(rst_n),
        .load_data(reg_C),
        .reuse_data(reuse_A),
        .sel(sel_C),
        .en(en_op),
        .wire_out(wire_C)
    );


    /*----------------------------------------------------
    -- static register D
    ----------------------------------------------------*/
    static_register static_registerD_inst (
        .clk(clk),
        .rst_n(rst_n),
        .load_data(reg_D),
        .reuse_data(reuse_B),
        .sel(sel_D),
        .en(en_op),
        .wire_out(wire_D)
    );

    /*----------------------------------------------------
    -- register E
    ----------------------------------------------------*/
    registerE registerE_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(en_op),
        .reg_in(out_B),
        .out_to_A(shift_up_A)
    );

    /*----------------------------------------------------
    -- valid logic
    ----------------------------------------------------*/
    valid_logic valid_logic_inst(
        .clk(clk),
        .rst_n(rst_n),
        .filter_size(filter_size),
        .en_op(en_op),
        .valid_data(valid_data),
        .valid_left_A(valid_left_A),
        .valid_left_B(valid_left_B),
        .valid_up_A(valid_up_A),
        .valid_up_B(valid_up_B),
        .valid_reuse(valid_reuse),
        .finished_op(finished_op),
        .sel_C_D(sel_C_D),
        .available_data(available_data),
        .row_transition(row_transition),
        .request3_col(request3_col),
        .cnt(cnt),
        .num_subfilter(num_subfilter),
        .subfilter_hor(subfilter_hor),
        .subfilter_ver(subfilter_ver)
    );

    /*----------------------------------------------------
    -- reuse (RegC <- RegA, RegD <- RegA)
    -- then finally swap (RegA <- RegC, RegC <- RegA,
    -- RegB <- RegD, RegD <- RegB)
    ----------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            filter_siz_reg <= 0;
        end
        else begin
            if(valid_data && !available_data) begin
                filter_siz_reg <= filter_size;
            end
        end
    end

    // Just Reording Wires to swap
    always @(*) begin
        if(filter_siz_reg != 3) begin
            reuse_A=wire_C[127:0];
            reuse_B=wire_D[127:0];
            case(subfilter_hor)
                0: begin
                    case(cnt)
                        3: reuse_A[127:24]= out_A[103:0];
                        4: reuse_A[23:0]= reuse_window_A[111:88];
                        6: reuse_B[127:24]=out_A[103:0];
                        7: reuse_B[23:0]= reuse_window_B[111:88];
                        9: begin
                            reuse_A = {out_A[103:0], reuse_window_C[111:88]};
                            reuse_B = {out_B[103:0], reuse_window_D[111:88]};
                        end
                        default: begin
                            reuse_A=wire_C[127:0];
                            reuse_B=wire_D[127:0];
                        end
                    endcase
                end
                1: begin
                    case(cnt)
                        3: reuse_A[127:24]= out_A[103:0];
                        4: reuse_A[23:0]= reuse_window_A[87:64];
                        6: reuse_B[127:24]=out_A[103:0];
                        7: reuse_B[23:0]= reuse_window_B[87:64];
                        9: begin
                            reuse_A = {out_A[103:0], reuse_window_C[87:64]};
                            reuse_B = {out_B[103:0], reuse_window_D[87:64]};
                        end
                        default: begin
                            reuse_A=wire_C[127:0];
                            reuse_B=wire_D[127:0];
                        end
                    endcase
                end
                2: begin
                    case(cnt)
                        3: reuse_A[127:24]= out_A[103:0];
                        4: reuse_A[23:0]= reuse_window_A[63:40];
                        6: reuse_B[127:24]=out_A[103:0];
                        7: reuse_B[23:0]= reuse_window_B[63:40];
                        9: begin
                            reuse_A = {out_A[103:0], reuse_window_C[63:40]};
                            reuse_B = {out_B[103:0], reuse_window_D[63:40]};
                        end
                        default: begin
                            reuse_A=wire_C[127:0];
                            reuse_B=wire_D[127:0];
                        end
                    endcase
                end
                3: begin
                    case(cnt)
                        3: reuse_A[127:24]= out_A[103:0];
                        4: reuse_A[23:0]= reuse_window_A[39:16];
                        6: reuse_B[127:24]=out_A[103:0];
                        7: reuse_B[23:0]= reuse_window_B[39:16];
                        9: begin
                            reuse_A = {out_A[103:0], reuse_window_C[39:16]};
                            reuse_B = {out_B[103:0], reuse_window_D[39:16]};
                        end
                        default: begin
                            reuse_A=wire_C[127:0];
                            reuse_B=wire_D[127:0];
                        end
                    endcase
                end
                default: begin
                    reuse_A=wire_C[127:0];
                    reuse_B=wire_D[127:0];
                end
            endcase
        end
        else begin
            reuse_A=wire_C[127:0];
            reuse_B=wire_D[127:0];
        end
    end

    // Choose RegC, RegD mode (0-loading operation  1-swaping operation)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_C <= 1'b0;
            sel_D <= 1'b0;
        end
        else begin
            if(filter_siz_reg != 3) begin
                case(cnt)
                    2: sel_C <= 1'b1;
                    5: sel_D <= 1'b1;
                    default: begin
                        // condition to reset row transition for each row transition and after processing final subfilter
                        if(row_transition || ((num_subfilter == subfilter_hor) && (num_subfilter == subfilter_ver) && finished_op)) begin
                            sel_C <= 1'b0;
                            sel_D <= 1'b0;
                        end
                    end
                endcase
            end
            else if (filter_siz_reg == 3) begin
                sel_C <= 1'b0;
                sel_D <= 1'b0;
            end
        end
    end
endmodule