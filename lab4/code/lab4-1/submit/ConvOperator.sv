`include"conv_struct.vh"
module ConvOperator(
    input clk,
    input rst,
    input Conv::data_vector kernel,
    input Conv::data_vector data,
    input in_valid,
    output reg in_ready,

    output Conv::result_t result,
    output reg out_valid,
    input out_ready
);

    localparam VECTOR_WIDTH = 2*Conv::WIDTH;
    typedef struct {
        Conv::result_t data;
        logic valid;
    } mid_vector;

    mid_vector vector_stage1 [Conv::LEN-1:0];
    mid_vector vector_stage2;

    typedef enum logic [1:0] {RDATA, WORK, TDATA} fsm_state;
    fsm_state state_reg;
    
    Conv::result_t add_tmp[Conv::LEN-1:1]/* verilator split_var */;

    Conv::result_t mul_product [Conv::LEN-1:0];
    logic start;
    logic [Conv::LEN-1:0] finish;
    logic total_finish;
    logic total_valid;
    assign total_finish = &finish;

    assign result = vector_stage2.data;
    // fill the code

    generate
    for(genvar j = 0;j < Conv::LEN; j = j + 1) begin : vector_mul
        Multiplier mul(
            .clk(clk),
            .rst(rst),
            .multiplicand(kernel.data[j]),
            .multiplier(data.data[j]),
            .start(start),
        
            .product(mul_product[j]),
            .finish(finish[j])
        );
    end
    endgenerate


    generate
        for(genvar i = 1;i<Conv::LEN; i = i + 1) begin
            if(i<Conv::LEN/2) begin
                assign add_tmp[i] = add_tmp[i*2] + add_tmp[i*2+1];
            end else begin
                assign add_tmp[i] = mul_product[(i-Conv::LEN/2)*2] + mul_product[(i-Conv::LEN/2)*2+1]; 
            end
        end
    endgenerate


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= RDATA;
            in_ready <= 1'b1;
            out_valid <= 1'b0;
            start <= 1'b0;

            for(integer k = 0; k < Conv::LEN; k = k + 1) begin
                vector_stage1[k].valid <= 1'b0;
            end
            vector_stage2.valid <= 1'b0;
        end else begin

            case (state_reg)

                RDATA: begin
                    if(in_valid) begin
                        start <= 1'b1;
                        in_ready <= 1'b0;
                        for(integer k = 0; k < Conv::LEN; k = k + 1) begin
                            vector_stage1[k].valid <= 1'b0;
                        end
                        vector_stage2.valid <= 1'b0;
                        state_reg <= WORK;
                    end
                end

                WORK: begin
                    start <= 1'b0;
                    if(total_finish) begin
                        for (integer k = 0; k < Conv::LEN; k = k + 1) begin
                            vector_stage1[k].valid <= 1'b1;
                            vector_stage1[k].data <= mul_product[k];
                        end
                        vector_stage2.data <= add_tmp[1];
                        vector_stage2.valid <= 1'b1;
                        out_valid <= 1'b1;
                        state_reg <= TDATA;
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

                default: state_reg <= RDATA;
            endcase
        end

    end

endmodule