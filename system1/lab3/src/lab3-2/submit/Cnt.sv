module Cnt #(
    parameter BASE = 10,
    parameter INITIAL = 0
) (
    input en,
    input clk,
    input rstn,
    input low_co,
    input high_rst,
    output co,
    output reg [3:0] cnt
);
    assign co = (cnt == BASE - 1) && en && low_co;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt <= INITIAL;
        end else if(en && high_rst) begin
            cnt <= 0;
        end else if(en && low_co) begin
            if(cnt == BASE - 1) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 4'b1;
            end
        end
    end

endmodule