`include "defines.v"

module ex(
	input wire rst,

	input wire[`AluOpBus] aluOp_i,
	input wire[`AluSelBus] aluSel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,

	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o
);
	reg[`RegBus] logicOut;
	reg[`RegBus] shiftRes;

	always @ (*) begin
		if (rst == `RstEnable) begin
			logicOut <= `ZeroWord;
		end else begin
			case (aluOp_i)
				`EXE_OR_OP : begin
					logicOut <= reg1_i | reg2_i;
				end
				`EXE_AND_OP : begin
					logicOut <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP : begin
					logicOut <= ~(reg1_i | reg2_i);
				end
				`EXE_XOR_OP : begin
					logicOut <= reg1_i ^ reg2_i;
				end
				default : begin
					logicOut <= `ZeroWord;
				end
			endcase
		end
	end

	always @ (*) begin
		if (rst == `RstEnable) begin
			shiftRes <= `ZeroWord;
		end else begin
			case (aluOp_i) 
				`EXE_SLL_OP : begin
					shiftRes <= reg2_i << reg1_i[4:0];
				end
				`EXE_SRL_OP : begin
					shiftRes <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP : begin
					shiftRes <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
				end
				default : begin
					shiftRes <= `ZeroWord;
				end
			endcase
		end
	end

	always @ (*) begin
		wd_o <= wd_i;
		wreg_o <= wreg_i;
		case(aluSel_i)
			`EXE_RES_LOGIC : begin
				wdata_o <= logicOut;
			end
			`EXE_RES_SHIFT : begin
				wdata_o <= shiftRes;
			end
			default : begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end

endmodule
