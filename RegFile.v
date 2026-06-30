module RegFile #(parameter DATA_WIDTH = 64 , Address_Width = 2)
(
    // CPU interface 
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [DATA_WIDTH-1:0]    wdata,
    input   wire    [Address_Width-1:0] Address_in,
    input   wire                        block_enable_r,
    input   wire                        wr_en,
    output  reg     [DATA_WIDTH-1:0]    rdata,

    // Design Interface
    // to indicate last location of Ifmap when it is high and done_slice so we finish Ifmap
    output   reg                        last_location,
    output   reg      [12:0]            reg_ifmap_h,      // Ifmap Height
    output   reg      [12:0]            reg_ifmap_w,      // Ifmap Width
    output   reg      [7:0]             reg_filter_size,  
    output   reg      [7:0]             reg_channel_id,
    output   reg                        load_25_percent_buffers_done,

    input   wire                        valid_out,
    input   wire                        done_slice
);
    /*--------------------------------------------------
    // Memory: 2 locations x 64 bits
    //--------------------------------------------------
    //   control signals at mem[0]:
    //   [7:0]   reg_filter_size              (CPU write)
    //   [15:8]  reg_channel_id               (CPU write)
    //   [28:16] reg_ifmap_h                  (CPU write)
    //   [41:29] reg_ifmap_w                  (CPU write)
    //   [42]    last_location                (CPU write)
    //   [43]    load_25_percent_buffers_done (CPU write)
    
    //   status signals at mem[1]:
    //   [0]    valid_out                    (Design write)
    //   [1]    done_slice                   (Design write)

    // mem[2], mem[3]: reserved

    // note: BRAM Controller is byte addressable
       mem[0] -> has offset address 0x0000_0000 -> index address 0
       mem[1] -> has offset address 0x0000_0008 -> index address 1
       mem[2] -> has offset address 0x0000_0010 -> index address 2
       mem[3] -> has offset address 0x0000_0018 -> index address 3
    --------------------------------------------------*/

    reg [DATA_WIDTH-1:0] mem [3:0];

    //--------------------------------------------------
    // Write Logic
    //--------------------------------------------------
    always @(posedge clk) begin
        // PS Writes
        if (block_enable_r) begin
            if(wr_en) begin
                mem[Address_in] <= wdata;
            end
        end

        // Accelerator writes
        mem[1] <= {62'b0, done_slice ,valid_out};
    end

    /*--------------------------------------------------
    // Read Logic (PS reads)
    ---------------------------------------------------*/
    always @ (posedge clk) begin
        if(!rst_n) begin
            rdata <= 0;
        end
        else if(block_enable_r) begin
            if(!wr_en) begin
                rdata <= mem[Address_in];
            end
        end
    end

    //--------------------------------------------------
    // Read Logic (Accelerator reads)
    //--------------------------------------------------
    always @(*) begin
        reg_filter_size               = mem[0][7:0];
        reg_channel_id                = mem[0][15:8];
        reg_ifmap_h                   = mem[0][28:16];
        reg_ifmap_w                   = mem[0][41:29];
        last_location                 = mem[0][42];
        load_25_percent_buffers_done  = mem[0][43];
    end
endmodule