module Cnt2num #(
    parameter BASE = 24,
    parameter INITIAL = 16
)(
    input en,
    input clk,
    input rstn,
    input high_rst,
    input low_co,
    output co,
    output [7:0] cnt
);

    localparam HIGH_BASE = 10;
    localparam LOW_BASE  = 10;
    localparam HIGH_INIT = INITIAL/10;
    localparam LOW_INIT  = INITIAL%10;
    localparam HIGH_CO   = (BASE-1)/10;
    localparam LOW_CO    = (BASE-1)%10;
    
    wire [3:0] cnt_high,cnt_low;
    wire low_co_to_high;
    wire inner_high_rst;
    assign cnt = {cnt_high, cnt_low};
    assign co = (cnt_high == 4'(HIGH_CO)) && (cnt_low == 4'(LOW_CO)) && en && low_co;
    assign inner_high_rst = high_rst || co;

    Cnt #(
        .BASE(HIGH_BASE),
        .INITIAL(4'(HIGH_INIT))
    ) high_cnt (
        .en(en),
        .clk(clk),
        .rstn(rstn),
        .high_rst(inner_high_rst),
        .low_co(low_co_to_high),
        .co(),
        .cnt(cnt_high)
    );

    Cnt #(
        .BASE(LOW_BASE),
        .INITIAL(4'(LOW_INIT))
    ) low_cnt (
        .en(en),
        .clk(clk),
        .rstn(rstn),
        .high_rst(inner_high_rst),
        .low_co(low_co),
        .co(low_co_to_high),
        .cnt(cnt_low)
    );

endmodule