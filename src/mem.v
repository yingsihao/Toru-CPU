`include "defines.v"

module sopc(
	input wire clk,
	input wire rst
);
	wire[`InstAddeBus] inst_addr;
	wire[`InstBus] inst;
	wire rom_ce;

	ToruMIPS ToruMIPS0(
		clk, rst,
		inst,
		inst_addr, rom_ce
	);

	inst_rom inst_rom0(
		rom_ce, inst_addr,
		inst
	);
endmodule

module mem(
	input wire rst,

	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] wdata_i,

	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o
);

	always @ (*) begin
		if (rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			wdata_o <= `ZeroWord;
		end else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
		end
	end

endmodule
