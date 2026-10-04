module Testbench;

    reg clk;
    reg rst;
    reg [31:0] multiplicand;
    reg [31:0] multiplier;
    reg start;
    wire [63:0] product;
    wire finish;

    integer i;
    initial begin
        clk=0;
        rst=1;
        #20;
        rst=0;
        #10;

        for(i=0;i<16;i=i+1)begin
            @(posedge clk);
            multiplicand = {$random} % 32'hffff_ffff;
            multiplier = {$random} % 32'hffff_ffff;
            start = 1;
            @(posedge clk);
            start = 0;
            wait(finish == 1);
            @(posedge clk);
        end

        $display("success!!!");
        $finish;
    end

    always begin
        #5;
        clk=~clk;
    end

    Multiplier #(
        .LEN(32)
    ) mul (
        .clk(clk),
        .rst(rst),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .start(start),
        
        .product(product),
        .finish(finish)
    );

    `ifdef VERILATE
		initial begin
			$dumpfile({`TOP_DIR,"/Testbench.vcd"});
			$dumpvars(0,dut);
			$dumpon;
		end

        wire error;
        Judge judge(
            .clk(clk),
            .rstn(~rst),
            .multiplicand(multiplicand),
            .multiplier(multiplier),
            .start(start),
            .product(product),
            .finish(finish),
            .error(error)
        );

        always@(negedge clk)begin
            if(error)begin
                $display("fail!!!");
                $finish;
            end
        end
    `endif
    
endmodule
