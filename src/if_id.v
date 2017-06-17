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

module if_id(
	input wire clk,
	input wire rst,

	input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,

	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
	end

endmodule
