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

module pc_reg(
	input wire clk,
	input wire rst,
	output reg[`InstAddrBus] pc,
	output reg ce
);
	always @ (posedge clk) begin
		if (ret == `RstEnable) begin
			ce <= `ChipDisable
		end else begin
			ce <= `ChipEnable
		end
	end

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000
		end else begin
			pc <= pc + 4'h4;
		end
	end
endmodule