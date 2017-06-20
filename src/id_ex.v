`include "defines.v"

module id_ex(
	input wire clk,
	input wire rst,

	input wire[`AluOpBus] id_aluOp,
	input wire[`AluSelBus] id_aluSel,
	input wire[`RegBus] id_reg1,
	input wire[`RegBus] id_reg2,
	input wire[`RegAddrBus] id_wd,
	input wire id_wreg,
	input wire[`RegBus] id_link_address,
	input wire id_is_in_delayslot,
	input wire next_inst_in_delayslot_i,

	output reg[`AluOpBus] ex_aluOp,
	output reg[`AluSelBus] ex_aluSel,
	output reg[`RegBus] ex_reg1,
	output reg[`RegBus] ex_reg2,
	output reg[`RegAddrBus] ex_wd,
	output reg ex_wreg
	output reg[`RegBus] ex_link_address,
	output reg ex_is_in_delayslot,
	output reg is_in_delayslot_o
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluOp <= `EXE_NOP_OP;
			ex_aluSel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
			is_in_delayslot_o <= `NotInDelaySlot;
		end else begin
			ex_aluOp <= id_aluOp;
			ex_aluSel <= id_aluSel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
	    	is_in_delayslot_o <= next_inst_in_delayslot_i;
		end
	end

endmodule