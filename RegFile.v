module RegFile #(parameter DATA_WIDTH = 128 , Address_Width = 2)
(
    // CPU interface 
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire    [DATA_WIDTH-1:0]    wdata,
    input   wire    [Address_Width-1:0] Address_in,
    input   wire                        we,
    output  wire    [DATA_WIDTH-1:0]    rdata,

    // Design Interface
    // to indicate last location of Ifmap when it is high and done_slice so we finish Ifmap
    output   reg                        last_location,
    output   reg      [12:0]            reg_ifmap_h,      // Ifmap Height
    output   reg      [12:0]            reg_ifmap_w,      // Ifmap Width
    output   reg      [3:0]             reg_filter_size,  
    output   reg      [1:0]             reg_channel_id,
    output   reg                        load_20_percent_buffers_done,

    input   wire                        valid_out,
    input   wire                        block_enable_reg_file
);
    /*--------------------------------------------------
    // Memory: 2 locations x 128 bits
    //--------------------------------------------------
    //   [3:0]   reg_filter_size       (CPU write)
    //   [5:4]   reg_channel_id        (CPU write)
    //   [18:6]  reg_ifmap_h           (CPU write)
    //   [31:19] reg_ifmap_w           (CPU write)
    //   [32]    last_location         (CPU write)
    //   [33]    load_20_percent_buffers_done (CPU write)
    //   [34]    valid_out             (Design write)

    ---- mem[1] : reserved for future use
    --------------------------------------------------*/

    reg [DATA_WIDTH-1:0] mem [0:1];

    //--------------------------------------------------
    // Write Logic
    //--------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= {DATA_WIDTH{1'b0}};
            mem[1] <= {DATA_WIDTH{1'b0}};
        end
        else begin
            // CPU write
            if (we) begin
                mem[Address_in] <= wdata;
            end
            mem[0][34] <= valid_out;
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
        reg_filter_size             = mem[0][3:0];
        reg_channel_id              = mem[0][5:4];
        reg_ifmap_h                 = mem[0][18:6];
        reg_ifmap_w                 = mem[0][31:19];
        last_location               = mem[0][32];
        load_20_percent_buffers_done = mem[0][33];
    end
endmodule