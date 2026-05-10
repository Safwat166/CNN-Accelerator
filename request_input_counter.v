module request_input_counter #(
    parameter counter_width = 3
) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire clear,
    output reg [counter_width-1:0] count
);

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      count <= 0;
    end else if (clear) begin
      count <= 0;
    end else if (en) begin
      if (count < 7) count <= count + 1;
      else count <= count;
    end
  end

endmodule
