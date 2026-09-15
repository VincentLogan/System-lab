`include"conv_struct.vh"
module ConvUnit (
    input clk,
    input rst,
    input Conv::data_t in_data,
    input Conv::data_vector kernel,
    input in_valid,
    output in_ready,

    output Conv::result_t result,
    output out_valid,
    input out_ready
);

    // fill the code
    Conv::data_vector data_cache;
    logic in_ready_cache;
    logic out_valid_cache;
    
    Shift shift (
        .clk(clk),
        .rst(rst),
        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),

        .out_ready(in_ready_cache),
        .out_valid(out_valid_cache),
        .data(data_cache)
    );
    

    ConvOperator convOperator(
        .clk(clk),
        .rst(rst),
        .kernel(kernel),
        .data(data_cache),
        .in_valid(out_valid_cache),
        .in_ready(in_ready_cache),

        .result(result),
        .out_ready(out_ready),
        .out_valid(out_valid)
    );
    
endmodule