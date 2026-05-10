module counter #(
    parameter counter_width = 8
) (
    input                             clk,
    input                             rst,
    input                             en,
    input                             clear,
    output reg [counter_width - 1:0] count
);



  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      count <= 'd0;
    end else begin
      if (clear) count <= 0;
      else if (en) count <= count + 1;
    end
  end


endmodule
