module FSM(
    input rstn,
    input clk,
    input a,
    input b,
    output [1:0] state
);
    typedef enum logic [1:0] {S0, S1, S2, S3} fsm_state;
    fsm_state state_reg;
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            state_reg <= S0;
        end
        else begin
            case(state_reg) 
                S0: if(a == 0 && b == 1) state_reg <= S0;
                    else if(a == 1) state_reg <= S1;
                    else state_reg <= S0;

                S1: if(a == 0 && b == 1) state_reg <= S0;
                    else if(a == 1) state_reg <= S2;
                    else state_reg <= S1;

                S2: if(a == 0 && b == 1) state_reg <= S0;
                    else if(a == 1) state_reg <= S3;
                    else state_reg <= S2;

                S3: state_reg <= S3;

            endcase
        end
    end

    assign state = state_reg;
endmodule