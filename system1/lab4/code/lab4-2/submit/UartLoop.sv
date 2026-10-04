`include"uart_struct.vh"
module UartLoop(
    input clk,
    input rstn,
    Decoupled_ift.Slave uart_rdata,
    Decoupled_ift.Master uart_tdata,
    input UartPack::uart_t debug_data,
    input logic debug_send,
    output UartPack::uart_t debug_rdata,
    output UartPack::uart_t debug_tdata
);
    import UartPack::*;

    uart_t rdata;
    logic rdata_valid;

    uart_t tdata;
    logic tdata_valid;

    assign rdata = uart_rdata.data;
    assign rdata_valid = uart_rdata.valid;

    always_comb begin 
        if(debug_send) begin
            tdata = debug_data;
            tdata_valid = 1'b1;
            uart_rdata.ready = 1'b0;
        end else begin
            tdata = rdata;
            tdata_valid = rdata_valid;
            uart_rdata.ready = uart_tdata.ready;
        end
    end
    // fill the code

    assign uart_tdata.data = tdata;
    assign uart_tdata.valid = tdata_valid;

    assign debug_rdata = rdata;
    assign debug_tdata = tdata;

endmodule