`timescale 1ns/1ps
// note: tested parameters are
// 1) ROWS = 258, COLOUMNS = 268, 3 <= FILTER_SIZE <= 12
// 1) ROWS = 512, COLOUMNS = 520, 3 <= FILTER_SIZE <= 12
module cnn_accelerator_tb #(parameter ROWS = 512, COLOUMNS = 520, FILTER_SIZE = 12, NUM_LOCATION = 8192) ();

/*--------------------------------------------------
-- internal signals
--------------------------------------------------*/

    // global signals
    bit          clk;
    bit          rst_n;

    // data bus
    bit [127:0]  data_bus_i;
    bit [127:0]  data_bus_w;
    bit [127:0]  data_bus_ps;
    bit [127:0]  data_bus_o;
    bit [63:0]   data_bus_r_rd;
    bit [63:0]   data_bus_r_wr;

    // addresses
    bit [31:0]   address_i;
    bit [31:0]   address_w;
    bit [31:0]   address_ps;
    bit [31:0]   address_o;
    bit [31:0]   address_r;

    // write enable signals
    bit [15:0]   wr_en_i;
    bit [15:0]   wr_en_w;
    bit [15:0]   rd_en_o;  // wr_en but inverted
    bit [15:0]   wr_en_ps;
    bit [7:0]    wr_en_r;

    // block enable signals
    bit          block_enable_i;
    bit          block_enable_w;
    bit          block_enable_ps;
    bit          block_enable_o;
    bit          block_enable_r;

    // files variables
    integer mem_out;
    integer pe_out;
    integer window;
    integer read_addr_file;

    // calculation parameters
    int vertical_slice;
    int num_window_per_vs;
    int total_num_window;
    int capture_count;

    int max_vertical_slice;
    int col;
    int reg_col;
    int remaining_vertical_slices;

    // arrays
    bit [127:0] input_array  [8191:0];
    bit [71:0] weight_array  [4095:0];
    bit [127:0] output_array [8191:0];
    bit [127:0] psum_array   [8191:0];

/*---------------------------------------------------------------------------
-- Design Instantiate
---------------------------------------------------------------------------*/
    cnn_accelerator DUT (
        .clk(clk),
        .rst_n(rst_n),
        .data_bus_i(data_bus_i),
        .data_bus_w(data_bus_w),
        .data_bus_ps(data_bus_ps),
        .data_bus_o(data_bus_o),
        .data_bus_r_rd(data_bus_r_rd),
        .data_bus_r_wr(data_bus_r_wr),
        .address_i(address_i),
        .address_w(address_w),
        .address_ps(address_ps),
        .address_o(address_o),
        .address_r(address_r),
        .wr_en_i(wr_en_i),
        .wr_en_w(wr_en_w),
        .rd_en_o(rd_en_o),
        .wr_en_ps(wr_en_ps),
        .wr_en_r(wr_en_r),
        .block_enable_i(block_enable_i),
        .block_enable_w(block_enable_w),
        .block_enable_ps(block_enable_ps),
        .block_enable_o(block_enable_o),
        .block_enable_r(block_enable_r)
    );

/*---------------------------------------------------------------------------
-- clock generation
---------------------------------------------------------------------------*/
    parameter CLK = 10;
    always #(CLK/2) clk = ~clk;

/*---------------------------------------------------------------------------
-- generate block to select between different driving modes
---------------------------------------------------------------------------*/

generate
if ((ROWS == 512) && (FILTER_SIZE >= 6)) begin

    initial begin        
        $readmemh("golden_model/memory_in_first_16vs.dat", input_array);
        $readmemh("golden_model/filter_in.dat", weight_array);

        // reset phase
        clk = 0;
        rst_n = 0;
        data_bus_i = 0;
        data_bus_w = 0;
        data_bus_ps = 0;
        data_bus_r_wr = 0;
        address_i = 0;
        address_w = 0;
        address_ps = 0;
        address_o = 0;
        address_r = 0;
        wr_en_i = 0;
        wr_en_w = 0;
        rd_en_o = 0;
        wr_en_ps = 0;
        wr_en_r = 0;
        block_enable_i = 0;
        block_enable_w = 0;
        block_enable_ps = 0;
        block_enable_o = 0;
        block_enable_r = 0;
        #(CLK);
        rst_n = 1;

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};
        

        // loading weight buffers
        block_enable_w = 1;
        wr_en_w = {16{1'b1}};
        if(FILTER_SIZE == 3) begin
            for (int i = 0; i<16*1; i= i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 6) begin
            for (int i = 0; i < 16*4 ; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 9) begin
            for (int i = 0; i<16*9; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 12) begin
            for (int i = 0; i<16*16; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end
        block_enable_w = 0;
        wr_en_w = {16{1'b0}};

        // loading input buffers
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0; i<0.25*8192*16; i = i + 16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};

        // configuration
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        // start operation
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0.25*8192*16; i<8192*16; i = i + 16) begin
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};
        @(posedge DUT.done_slice);

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};
        
        $readmemh("golden_model/memory_in_second_16vs.dat", input_array);
        // loading input buffers
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0; i<0.25*8192*16; i = i + 16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};

        // configuration
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        // start operation
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0.25*8192*16; i<8192*16; i = i + 16) begin
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};
        @(posedge DUT.done_slice);

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 100;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        $readmemh("golden_model/memory_in_remaining_5vs.dat", input_array);
        // loading input buffers
        wr_en_i = {16{1'b1}};
        block_enable_i = 1;
        for (int i = 0; i<0.25*8192*16; i = i + 16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = 0;

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 100;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        // start operation
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0.25*8192*16; i<3584*16; i = i + 16) begin
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        wr_en_i = {16{1'b0}};
        block_enable_i = 0;
        @(posedge DUT.done_slice);
    end
end

if((ROWS == 512) && (FILTER_SIZE == 3)) begin

    initial begin        
        $readmemh("golden_model/memory_in_first_16vs_3.dat", input_array);
        $readmemh("golden_model/filter_in.dat", weight_array);

        // reset phase
        clk = 0;
        rst_n = 0;
        data_bus_i = 0;
        data_bus_w = 0;
        data_bus_ps = 0;
        data_bus_r_wr = 0;
        address_i = 0;
        address_w = 0;
        address_ps = 0;
        address_o = 0;
        address_r = 0;
        wr_en_i = 0;
        wr_en_w = 0;
        rd_en_o = 0;
        wr_en_ps = 0;
        wr_en_r = 0;
        block_enable_i = 0;
        block_enable_w = 0;
        block_enable_ps = 0;
        block_enable_o = 0;
        block_enable_r = 0;
        #(CLK);
        rst_n = 1;

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};
        

        // loading weight buffers
        block_enable_w = 1;
        wr_en_w = {16{1'b1}};
        if(FILTER_SIZE == 3) begin
            for (int i = 0; i<16*1; i= i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 6) begin
            for (int i = 0; i < 16*4 ; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 9) begin
            for (int i = 0; i<16*9; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 12) begin
            for (int i = 0; i<16*16; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end
        block_enable_w = 0;
        wr_en_w = {16{1'b0}};

        // loading input buffers
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0; i<0.25*8192*16; i = i + 16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};

        // configuration
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        // start operation
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0.25*8192*16; i<8192*16; i = i + 16) begin
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};
        @(posedge DUT.done_slice);

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};
        
        $readmemh("golden_model/memory_in_second_16vs_3.dat", input_array);
        // loading input buffers
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0; i<0.25*8192*16; i = i + 16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};

        // configuration
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 226;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        // start operation
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0.25*8192*16; i<8192*16; i = i + 16) begin
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = {16{1'b0}};
        @(posedge DUT.done_slice);

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 72;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        $readmemh("golden_model/memory_in_remaining_6vs_3.dat", input_array);
        // loading input buffers
        wr_en_i = {16{1'b1}};
        block_enable_i = 1;
        for (int i = 0; i<0.25*8192*16; i = i + 16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        block_enable_i = 0;
        wr_en_i = 0;

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = 72;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};

        // start operation
        block_enable_i = 1;
        wr_en_i = {16{1'b1}};
        for (int i = 0.25*8192*16; i<3584*16; i = i + 16) begin
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        wr_en_i = {16{1'b0}};
        block_enable_i = 0;
        @(posedge DUT.done_slice);
    end
end

if(ROWS == 258) begin

    initial begin        
        $readmemh("golden_model/memory_in.dat", input_array);
        $readmemh("golden_model/filter_in.dat", weight_array);

        // reset phase
        clk = 0;
        rst_n = 0;
        data_bus_i = 0;
        data_bus_w = 0;
        data_bus_ps = 0;
        data_bus_r_wr = 0;
        address_i = 0;
        address_w = 0;
        address_ps = 0;
        address_o = 0;
        address_r = 0;
        wr_en_i = 0;
        wr_en_w = 0;
        rd_en_o = 0;
        wr_en_ps = 0;
        wr_en_r = 0;
        block_enable_i = 0;
        block_enable_w = 0;
        block_enable_ps = 0;
        block_enable_o = 0;
        block_enable_r = 0;
        #(CLK);
        rst_n = 1;

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = COLOUMNS;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 0;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};
        

        // loading weight buffers
        block_enable_w = 1;
        wr_en_w = {16{1'b1}};
        if(FILTER_SIZE == 3) begin
            for (int i = 0; i<16*1; i= i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 6) begin
            for (int i = 0; i < 16*4 ; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 9) begin
            for (int i = 0; i<16*9; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end

        else if(FILTER_SIZE == 12) begin
            for (int i = 0; i<16*16; i = i + 16) begin
                address_w = i;
                data_bus_w = weight_array[address_w / 16];
                @(posedge clk);
            end
        end
        block_enable_w = 0;
        wr_en_w = {16{1'b0}};

        // loading input buffers
        wr_en_i = {16{1'b1}};
        block_enable_i = 1;
        for (int i = 0; i<0.25*8192*16; i = i+16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        wr_en_i = {16{1'b0}};
        block_enable_i = 0;

        // configurations
        block_enable_r = 1;
        wr_en_r = {8{1'b1}};
        address_r = 0;
        data_bus_r_wr[7:0] = FILTER_SIZE;
        data_bus_r_wr[15:8] = 1;
        data_bus_r_wr[28:16] = COLOUMNS;
        data_bus_r_wr[41:29] = ROWS;
        data_bus_r_wr[42] = 0;
        data_bus_r_wr[43] = 1;
        @(posedge clk);
        block_enable_r = 0;
        wr_en_r = {8{1'b0}};
        
        // start operation
        wr_en_i = {16{1'b1}};
        block_enable_i = 1;
        for (int i = 0.25*8192*16; i<4902*16; i = i+16) begin  // loading 25% of input buffer
            address_i = i;
            data_bus_i = input_array[address_i / 16];
            @(posedge clk);
        end
        wr_en_i = {16{1'b1}};
        block_enable_i = 0;
        @(posedge DUT.done_slice);
    end

end

endgenerate

    initial begin
        // open files that will include output values (output buffer values, pe_out, window, addresses)
        mem_out = $fopen("golden_model/output_memory.dat", "w");
        read_addr_file = $fopen("golden_model/read_address_input.dat", "w");
        pe_out = $fopen("golden_model/pe_out.dat", "w");
        window = $fopen("golden_model/windows.dat", "w");

        //calculating number of windows to calculate complete pe_out
        vertical_slice = ((COLOUMNS - 16)/14) + 1; //37
        max_vertical_slice = (NUM_LOCATION/ROWS); // maximum vertical slices input buffer can carry  //16
        
        if (FILTER_SIZE == 3) begin
            num_window_per_vs = ((ROWS - 4)/2) + 1;
            total_num_window = (vertical_slice) * (num_window_per_vs);
        end
        else if (FILTER_SIZE == 6) begin
            num_window_per_vs = ((ROWS - 8)/2) + 1;
            total_num_window = (vertical_slice-1) * (num_window_per_vs);
        end
        else if (FILTER_SIZE == 9) begin
            num_window_per_vs = ((ROWS - 12)/2) + 1;
            total_num_window = (vertical_slice-1) * (num_window_per_vs);
        end
        else if (FILTER_SIZE == 12) begin
            num_window_per_vs = ((ROWS - 16)/2) + 1;
            total_num_window = (vertical_slice-1) * (num_window_per_vs);
        end

        // calculating number of captured sub windows
        if (FILTER_SIZE == 3) capture_count = total_num_window;
        else if (FILTER_SIZE == 6) capture_count = total_num_window * 4;
        else if (FILTER_SIZE == 9) capture_count = total_num_window * 9;
        else if (FILTER_SIZE == 12) capture_count = total_num_window * 16;
        else capture_count = total_num_window;
        fork
        begin
            repeat(capture_count) begin //36432
                @(posedge DUT.comp_inst.available_data);
                @(negedge clk);
                $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_A);
                $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_B);
                $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_C);
                $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_D);
            end
        end
        begin
        // Capture pe_out once every 'num_sub' finished_op
            repeat(total_num_window) begin
                if(FILTER_SIZE == 3) begin
                    @(posedge DUT.finished_op);
                    @(negedge DUT.finished_op);
                    $fdisplay(pe_out, "%h", DUT.pe_out);
                end
                else if(FILTER_SIZE == 6) begin
                    repeat(4) begin
                        @(posedge DUT.finished_op);
                    end
                    @(negedge DUT.finished_op);
                    $fdisplay(pe_out, "%h", DUT.pe_out);
                end
                else if(FILTER_SIZE == 9) begin
                    repeat(9) begin
                        @(posedge DUT.finished_op);
                    end
                    @(negedge DUT.finished_op);
                    $fdisplay(pe_out, "%h", DUT.pe_out);
                end
                else if(FILTER_SIZE == 12) begin
                    repeat(16) begin
                        @(posedge DUT.finished_op);
                    end
                    @(negedge DUT.finished_op);
                    $fdisplay(pe_out, "%h", DUT.pe_out);
                end
            end
        end
        join

        // end simulation
        @(negedge DUT.valid_out);
        @(posedge clk);
        $fclose(mem_out);
        $fclose(read_addr_file);
        $fclose(window);
        $fclose(pe_out);
        $stop;
    end

    always @(DUT.control_buff_inst.read_address_input) begin
        if (read_addr_file) begin
            $fdisplay(read_addr_file, "%0d", DUT.control_buff_inst.read_address_input);
        end
    end

    int output_address_cnt = 0;
    always @(posedge DUT.valid_out) begin
        @(posedge clk);
        #1step;
        for(int i = 0; i<8; i = i+1) begin
            $fdisplay(mem_out, "%h", DUT.output_buff_inst.mem[output_address_cnt]);
            output_address_cnt = output_address_cnt + 1;
        end
        if(output_address_cnt == 8192) begin
            output_address_cnt = 0;
        end
    end

endmodule