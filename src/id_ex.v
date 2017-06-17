module id_ex(
	input wire clk,
	input wire rst,

	input wire[`AluOpBus] id_aluOp;
	input wire[`AluSelBus] id_aluSel;
	input wire[`RegBus] id_reg1,
	input wire[`RegBus] id_reg2,
	input wire[`RegAddrBus] id_wd,
	input wire id_wreg,

	output reg[`AluOpBus] ex_aluOp,
	output reg[`AluSelBus] ex_aluSel,
	output reg[`RegBus] ex_reg1,
	output reg[`RegBus] ex_reg2,
	output reg[`RegAddrBus] ex_wd,
	output reg ex_wreg
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluOp <= `EXE_NOP_OP;
			ex_aluSel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
		end else begin
			ex_aluOp <= id_aluOp;
			ex_aluSel <= id_aluSel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
		end
	end;

endmodule