`include"conv_struct.vh"
module Multiplier #(
    parameter LEN = 64
) (
    input clk,
    input rst,
    input [LEN-1:0] multiplicand,
    input [LEN-1:0] multiplier,
    input start,
    
    output [LEN*2-1:0] product,
    output finish
);

    //乘机的位宽
    localparam PRODUCT_LEN = LEN*2;

    //被乘数寄存器
    logic [LEN-1:0] multiplicand_reg;

    //乘积寄存器
    logic [PRODUCT_LEN-1:0] product_reg;

    //计数到LEN需要多少个迭代
    localparam CNT_NUM = LEN - 1;

    //有限状态机设计
    typedef enum logic [1:0] {IDLE, WORK, FINAL} fsm_state;
    fsm_state fsm_state_reg;

    //计数到LEN需要多少位二进制计数器
    localparam CNT_LEN = $clog2(LEN);

    // 迭代需要的立即数，控制乘法循环
    logic [CNT_LEN-1:0] work_cnt;

    reg finish_reg;
    assign product = product_reg;
    assign finish = finish_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fsm_state_reg <= IDLE;
        end else begin
            case (fsm_state_reg)
                IDLE: begin
                    finish_reg <= 1'b0;
                    if(start) begin
                        multiplicand_reg <= multiplicand;
                        product_reg[PRODUCT_LEN-1:LEN] <= {LEN{1'b0}};
                        product_reg[LEN-1:0] <= multiplier;
                        work_cnt <= 0;
                        fsm_state_reg <= WORK;
                    end else begin
                        fsm_state_reg <= IDLE;
                    end
                end
                WORK: begin
                    if(product_reg[0] == 1'b1) begin
                       product_reg <= {({1'b0,product_reg[PRODUCT_LEN-1:LEN]} + multiplicand_reg), product_reg[LEN-1:1]};
                    end else begin  
                        product_reg <= {1'b0, product_reg[PRODUCT_LEN-1:1]};
                    end
                    work_cnt <= work_cnt + 1;

                    if(work_cnt == CNT_NUM[CNT_LEN-1:0]) begin
                        fsm_state_reg <= FINAL;
                    end else begin
                        fsm_state_reg <= WORK;
                    end
                end
                FINAL: begin
                    finish_reg <= 1'b1;
                    fsm_state_reg <= IDLE;     
                end
                default : fsm_state_reg <= IDLE;
            endcase
        end
    end
    
 
    // fill the code
    
endmodule