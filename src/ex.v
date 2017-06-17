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

	always @ (*) begin
		if (rst == `RstEnable) begin
			logicOut <= `ZeroWord;
		end else begin
			case (aluOp_i)
				`EXE_OR_OP : begin
					logicOut <= reg1_i | reg2_i;
				end
				default : begin
					ligicOut <= `ZeroWord;
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
			default : begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end