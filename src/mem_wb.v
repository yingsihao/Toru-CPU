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

module mem_wb(
	input wire clk,
	input wire rst,

	input wire[`RegAddrBus] mem_wd,
	input wire mem_wreg,
	input wire[`RegBus] mem_wdata,

	output reg[`RegAddrBus] wb_wd,
	output reg wb_wreg,
	output reg[`RegBus] wb_wdata
);
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			wb_ed <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
			wb_wdata <= `ZeroWord;
		end else begin
			wb_ed <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end
	end
endmodule
