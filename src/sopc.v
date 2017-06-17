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