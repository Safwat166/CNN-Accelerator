`timescale 1ns/1ps
module cnn_accelerator_tb ();

    /*--------------------------------------------------
    -- internal signals
    --------------------------------------------------*/
    bit                clk;
    bit                rst_n;
    bit  [127:0]       data_bus;
    bit  [127:0]       data_bus_o;
    bit  [31:0]        address;
    bit                rd_en_i;
    bit                wr_en_i;
    bit                rd_en_w;
    bit                wr_en_w;
    bit                rd_en_o;
    bit                wr_en_o;
    bit                rd_en_p;
    bit                wr_en_p;
    bit                block_enable_i;
    bit                block_enable_w;
    bit                block_enable_ps;
    bit                block_enable_o;
    bit                block_enable_r;

    integer mem_out;
    integer pe_out;
    integer window;
    int num_sub;

    cnn_accelerator DUT (
        .clk(clk),
        .rst_n(rst_n),
        .data_bus(data_bus),
        .data_bus_o(data_bus_o),
        .address(address),
        .rd_en_i(rd_en_i),
        .wr_en_i(wr_en_i),
        .rd_en_w(rd_en_w),
        .wr_en_w(wr_en_w),
        .rd_en_o(rd_en_o),
        .wr_en_o(wr_en_o),
        .rd_en_p(rd_en_p),
        .wr_en_p(wr_en_p),
        .block_enable_i(block_enable_i),
        .block_enable_w(block_enable_w),
        .block_enable_ps(block_enable_ps),
        .block_enable_o(block_enable_o),
        .block_enable_r(block_enable_r)
    );
    parameter CLK = 10;
    always #(CLK/2) clk = ~clk;

    initial begin
        mem_out = $fopen("golden_model/output_memory.dat", "w");
        pe_out = $fopen("golden_model/pe_out.dat", "w");
        window = $fopen("golden_model/windows.dat", "w");

        // reset phase
        clk = 0;
        rst_n = 0;
        #(CLK);
        rst_n = 1;

        // load buffer + regfile
        block_enable_i = 1;
        block_enable_w = 1;
        block_enable_ps = 1;
        block_enable_o = 1;
        block_enable_r = 1;
        $readmemh("golden_model/memory_in.dat", DUT.input_buff_inst.mem);
        $readmemh("golden_model/filter_in.dat", DUT.weight_buff_inst.mem);
        DUT.filter_size = 8'd12;
        DUT.load_buffers_done = 1;
        DUT.ch_id = 1;
        DUT.clear = 0;
        DUT.ifmap_h = 256;
        DUT.ifmap_w = 256;
        @(negedge clk);
        block_enable_r = 0;

        while(DUT.request_input == 0) begin
            @(negedge clk);
        end
        rd_en_i = 1;
        wr_en_i = 0;
        rd_en_w = 1;
        wr_en_w = 0;
        rd_en_p = 1;
        wr_en_p = 0;
        rd_en_o = 0;
        wr_en_o = 1;

        if (DUT.filter_size == 3) num_sub = 1;
        else if (DUT.filter_size == 6) num_sub = 4;
        else if (DUT.filter_size == 9) num_sub = 9;
        else if (DUT.filter_size == 12) num_sub = 16;
        else if (DUT.filter_size == 15) num_sub = 25;
        else num_sub = 1;

        fork
            // Capture windows on every available_data
            begin
                repeat(200 * num_sub) begin
                    @(posedge DUT.comp_inst.available_data);
                    @(negedge clk);
                    $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_A);
                    $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_B);
                    $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_C);
                    $fdisplay(window, "%h", DUT.comp_inst.reorder_module_inst.wire_D);
                end
            end
            
            // Capture pe_out once every 'num_sub' finished_op
            begin
                repeat(200) begin
                    if(DUT.filter_size == 3) begin
                        @(negedge DUT.finished_op);
                        @(negedge clk);
                        $fdisplay(pe_out, "%h", DUT.pe_out);
                    end
                    else if(DUT.filter_size == 6) begin
                        repeat(4) begin
                            @(negedge DUT.finished_op);
                            @(negedge clk);
                        end
                        $fdisplay(pe_out, "%h", DUT.pe_out);
                    end
                    else if(DUT.filter_size == 9) begin
                        repeat(9) begin
                            @(negedge DUT.finished_op);
                            @(negedge clk);
                        end
                        $fdisplay(pe_out, "%h", DUT.pe_out);
                    end
                    else if(DUT.filter_size == 12) begin
                        repeat(16) begin
                            @(negedge DUT.finished_op);
                            @(negedge clk);
                        end
                        $fdisplay(pe_out, "%h", DUT.pe_out);
                    end
                    else if(DUT.filter_size == 15) begin
                        repeat(25) begin
                            @(negedge DUT.finished_op);
                            @(negedge clk);
                        end
                        $fdisplay(pe_out, "%h", DUT.pe_out);
                    end
                end
            end
        join
        // Wait for the last stream buffer write to complete
        #(CLK * 10);
        for (int i = 0; i < DUT.control_buff_inst.instance_output.out_ptr; i++) begin
            $fdisplay(mem_out, "%032h", DUT.output_buff_inst.mem[i]);
        end
        $fclose(window);
        $fclose(mem_out);
        $fclose(pe_out);
        $stop;
    end
endmodule