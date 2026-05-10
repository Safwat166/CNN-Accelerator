module pe_stream_buffer (
    input  wire            clk,
    input  wire            rst,
    input  wire            valid,  // load input 
    input  wire   [783:0]  data_in,
    input  wire            en,  // start streaming 
	
    output reg    [127:0] data_out
);

    reg [783:0] buf_r;
    reg [2:0]   cnt;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            buf_r    <= 784'b0;
            cnt      <= 3'd0;
            data_out <= 128'b0;

        end else begin

            if (valid) begin
                buf_r    <= data_in;
              
            end else if (en) begin
                cnt <= (cnt == 3'd7) ? 3'd0 : cnt + 1'b1;
            end 
        end
    end

    always @ (*) begin
        if(en) begin
            case(cnt)
                3'd0: data_out = buf_r[127:0];
                3'd1: data_out = buf_r[255:128];
                3'd2: data_out = buf_r[383:256];
                3'd3: data_out = {120'b0, buf_r[391:384]};
                3'd4: data_out = buf_r[519:392];
                3'd5: data_out = buf_r[647:520];
                3'd6: data_out = buf_r[775:648];
                3'd7: data_out = {120'b0, buf_r[783:776]};
                default: data_out = 128'b0;
            endcase
        end
        else begin
            data_out = 128'b0;        // en=0: output 0
        end
    end
endmodule
