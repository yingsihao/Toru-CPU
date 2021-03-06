`include "../src/defines.v"
`timescale 1ns/1ps

module sopc_tb();
	reg CLOCK_50;
	reg rst;

	initial begin
		CLOCK_50 = 1'b0;
		forever #10 CLOCK_50 = ~CLOCK_50;
	end

	initial begin
		rst = `RstEnable;
		#195 rst = `RstDisable;
		#1000 $stop;
	end

	sopc sopc0(
		CLOCK_50,
		rst
	);

endmodule
