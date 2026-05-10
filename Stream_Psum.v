module Stream_Psum (
    input              clk,
    input              rst,
    input  [127:0]     data_in,
    input              en, // data_valid from psum buffer 

    output reg [783:0] data_out
);

    reg [783:0] buf_r;
    reg [2:0]   cnt;
    reg         load_done;    // finish load 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            buf_r     <= 784'b0;
            cnt       <= 3'd0;
            data_out  <= 784'b0;
            load_done <= 1'b0;

        end else begin

            if (load_done) begin
                data_out  <= buf_r;
                load_done <= 1'b0;

            end else if (en) begin
                case (cnt)
                    3'd0: buf_r[127:0]   <= data_in;
                    3'd1: buf_r[255:128] <= data_in;
                    3'd2: buf_r[383:256] <= data_in;
                    3'd3: buf_r[391:384] <= data_in[7:0];     // ignore top 120 zeros
                    3'd4: buf_r[519:392] <= data_in;
                    3'd5: buf_r[647:520] <= data_in;
                    3'd6: buf_r[775:648] <= data_in;
                    3'd7: begin
                        buf_r[783:776] <= data_in[7:0];       // ignore top 120 zeros
                        load_done      <= 1'b1;
                    end
                endcase

                cnt <= (cnt == 3'd7) ? 3'd0 : cnt + 1'b1;

            end else begin
                cnt       <= 3'd0;
            end

        end
    end

endmodule
