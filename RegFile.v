module RegFile #(parameter DATA_WIDTH = 128 , Address_Width = 2)
(
    // CPU interface 
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [DATA_WIDTH-1:0]    wdata,
    input   wire    [Address_Width-1:0] Address_in,
    input   wire                        block_enable_r,
    output  wire    [DATA_WIDTH-1:0]    rdata,

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
    // Memory: 2 locations x 128 bits
    //--------------------------------------------------
    //   [7:0]   reg_filter_size              (CPU write)
    //   [15:8]   reg_channel_id              (CPU write)
    //   [28:16]  reg_ifmap_h                 (CPU write)
    //   [41:29] reg_ifmap_w                  (CPU write)
    //   [42]    last_location                (CPU write)
    //   [43]    load_25_percent_buffers_done (CPU write)
    //   [44]    valid_out                    (Design write)
    //   [45]    done_slice                   (Design write)

    ---- mem[1] : reserved for future use
    --------------------------------------------------*/

    reg [DATA_WIDTH-1:0] mem [0:1];

    //--------------------------------------------------
    // Write Logic
    //--------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            mem[0] <= {DATA_WIDTH{1'b0}};
            mem[1] <= {DATA_WIDTH{1'b0}};
        end
        else begin
            // CPU write
            if (block_enable_r) begin
                mem[Address_in] <= wdata;
            end
            mem[0][44] <= valid_out;
            mem[0][45] <= done_slice;
        end
    end

    /*--------------------------------------------------
    // Read Logic
    ---------------------------------------------------*/
    assign rdata = mem[Address_in];

    //--------------------------------------------------
    // Design  outputs
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