module first_window_reg (
    input clk,
    input rst,
    input en,
    output reg first_window
);

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      first_window <= 0;
    end else begin
      if (en) first_window <= 1;
    end
  end


endmodule
