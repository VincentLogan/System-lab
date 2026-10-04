`include"conv_struct.vh"
module Shift (
    input clk,
    input rst,
    input Conv::data_t in_data,
    input in_valid,
    output reg in_ready,

    output Conv::data_vector data,
    output reg out_valid,
    input out_ready
);

    typedef enum logic {RDATA, TDATA} fsm_state;
    fsm_state state_reg;
    Conv::data_t [Conv::LEN-1:0] data_reg;
    generate
        for(genvar i = 0; i < Conv::LEN; i = i + 1)begin
            assign data.data[i] = data_reg[i];
        end
    endgenerate

    // fill the code

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= RDATA;
            in_ready <= 1'b1;
            out_valid <= 1'b0;
            for(integer i = 0; i < Conv::LEN; i = i + 1) begin
                data_reg[i] <= '0;
            end
        end else begin
            case (state_reg)
                RDATA: begin
                    if (in_valid) begin
                        data_reg[Conv::LEN-1] <= in_data;
                        data_reg[Conv::LEN-2:0] <= data_reg[Conv::LEN-1:1];
                        in_ready <= 1'b0;
                        out_valid <= 1'b1;
                        state_reg <= TDATA;
                    end else begin
                        state_reg <= RDATA;
                    end
                end
                TDATA: begin
                    if(out_ready) begin
                        in_ready <= 1'b1;
                        out_valid <= 1'b0;
                        state_reg <= RDATA;
                    end else begin
                        state_reg <= TDATA;
                    end
                end
            endcase
        end
    end

endmodule