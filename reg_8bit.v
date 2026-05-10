module reg_8bit (
    input  wire        clk,     // clock
    input  wire        rst_n,   // negative edge reset
    input  wire        en,      // enable opearation state from controller
    input  wire [7:0]  d,       // FF inputs
    output reg  [7:0]  q        // FF outputs
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 8'b0;
        else if(en) begin
            q <= d;
        end
    end
endmodule