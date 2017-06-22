`include "defines.v"

module ex(
	input wire rst,

	input wire[`AluOpBus] aluOp_i,
	input wire[`AluSelBus] aluSel_i,
	input wire[`RegBus] reg1_i,
	input wire[`RegBus] reg2_i,
	input wire[`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire[`RegBus] inst_i,

	input wire[`RegBus] link_address_i,
	input wire is_in_delayslot,

	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg[`RegBus] wdata_o,

	output wire[`AluOpBus] aluOp_o,
	output wire[`RegBus] mem_addr_o,
	output wire[`RegBus] reg2_o,

	reg stallReq
);
	reg[`RegBus] logicOut;
	reg[`RegBus] shiftRes;
	reg[`RegBus] arithmeticRes;

	wire ov_sum;
	wire reg1_eq_reg2;
	wire reg1_lt_reg2;
	wire[`RegBus] reg2_i_mux;
	wire[`RegBus] reg1_i_not;
	wire[`RegBus] result_sum;

	assign aluOp_o = aluOp_i;
	assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
	assign reg2_o = reg2_i;

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

	assign reg2_i_mux = (aluOp_i == `EXE_SUB_OP || aluOp_i == `EXE_SLT_OP) ? (~reg2_i) + 1 : reg2_i;
	assign result_sum = reg1_i + reg2_i_mux;
	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
	assign reg1_lt_reg2 = ((aluOp_i == `EXE_SLT_OP)) ?
												((reg1_i[31] && !reg2_i[31]) || 
												(!reg1_i[31] && !reg2_i[31] && result_sum[31]) ||
			                   					(reg1_i[31] && reg2_i[31] && result_sum[31]))
			                   				:	(reg1_i < reg2_i);
  	assign reg1_i_not = ~reg1_i;

  	always @ (*) begin
  		stallReq = `NoStop;
  	end

  	always @ (*) begin
  		if (rst == `RstEnable) begin
  			arithmeticRes <= `ZeroWord;
  		end else begin
  			case (aluOp_i)
  				`EXE_SLT_OP : begin
  					arithmeticRes <= reg1_lt_reg2;
  				end
  				`EXE_ADD_OP, `EXE_ADDI_OP, `EXE_SUB_OP : begin
  					arithmeticRes <= result_sum;
  				end
  			endcase
  		end
  	end

	always @ (*) begin
		wd_o <= wd_i;
		if (((aluOp_i == `EXE_ADD_OP) || (aluOp_i == `EXE_ADDI_OP) || (aluOp_i == `EXE_SUB_OP)) && ov_sum == 1'b1) begin
			wreg_o <= `WriteDisable;
		end else begin
			wreg_o <= wreg_i;
		end
		case(aluSel_i)
			`EXE_RES_LOGIC : begin
				wdata_o <= logicOut;
			end
			`EXE_RES_SHIFT : begin
				wdata_o <= shiftRes;
			end
			`EXE_RES_ARITHMETIC : begin
				wdata_o <= arithmeticRes;
			end
			`EXE_RES_JUMP_BRANCH : begin
				wdata_o <= link_address_i;
			end
			default : begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end

endmodule
