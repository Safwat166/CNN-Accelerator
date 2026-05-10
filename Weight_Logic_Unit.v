module Weight_Logic_Unit (
    input wire clk,
    input wire rst,
    input wire [71:0] filter_in,   
    input wire Data_valid,     	  
    input wire shift_en,          	  
	
    output wire [7:0] filter_out,
    output reg load_done_w
); 
    reg [71:0] shift_reg;
    reg [3:0]  cnt; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            shift_reg   <= 72'd0;
            load_done_w <= 0;
            cnt         <= 0;
        end else begin	
            if (Data_valid) begin
                shift_reg   <= filter_in;
                load_done_w <= 1;
                cnt         <= 0;
            end
            else if (load_done_w) begin
                load_done_w <= 0;
            end
            else if (shift_en) begin
                if (cnt == 0) begin
                    cnt <= 1;          // hold first element
                end else begin
                    shift_reg <= {shift_reg[7:0], shift_reg[71:8]};
                    cnt <= (cnt == 9) ? 4'd0 : cnt + 1;
                end
            end
        end
    end
	
    
    assign filter_out = shift_reg[7:0];
    

endmodule