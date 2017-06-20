`include "defines.v"

module id(
	input wire rst,
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	input wire ex_wreg_i,
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,

	input wire mem_wreg_i,
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,

	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,

	input wire is_in_delayslot_i,

	output reg reg1_read_o,
	output reg reg2_read_o,
	output reg[`RegAddrBus] reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,

	output reg[`AluOpBus] aluOp_o,
	output reg[`AluSelBus] aluSel_o,
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,

	output reg next_inst_in_delayslot_o,
	output reg branch_flag_o,
	output reg[`RegBus] branch_target_address_o,
	output reg[`RegBus] link_addr_o,
	output reg is_in_delayslot_o
);

	wire[5:0] op = inst_i[31:26];
	wire[4:0] op2 = inst_i[10:6];
	wire[5:0] op3 = inst_i[5:0];
	wire[4:0] op4 = inst_i[20:16];

	reg[`RegBus] imm;
	reg instValid;

	wire[`RegBus] pc_plus_4;
	wire[`RegBus] imm_sll2_signedExt;

	assign pc_plus_4 = pc_i + 4;
	assign imm_sll2_signedExt = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

	always @ (*) begin
		if (rst == `RstEnable) begin
			aluOp_o <= `EXE_NOP_OP;
			aluSel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instValid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;
		end else begin
			aluOp_o <= `EXE_NOP_OP;
			aluSel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			instValid <= `InstInvalid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;

			case (op)
				`EXE_SPECIAL_INST : begin
					case (op2)
						5'b00000 : begin
							case (op3)
								`EXE_OR : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_OR_OP;
									aluSel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_AND : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_AND_OP;
									aluSel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_XOR : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_XOR_OP;
									aluSel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_NOR : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_NOR_OP;
									aluSel_o <= `EXE_RES_LOGIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_SLLV : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_SLL_OP;
									aluSel_o <= `EXE_RES_SHIFT;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_SRLV : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_SRL_OP;
									aluSel_o <= `EXE_RES_SHIFT;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_SRAV : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_SRA_OP;
									aluSel_o <= `EXE_RES_SHIFT;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_SYNC : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_NOP_OP;
									aluSel_o <= `EXE_RES_NOP;
									reg1_read_o <= 1'b0;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_SLT : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_SLT_OP;
									aluSel_o <= `EXE_RES_ARITHMETIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_ADD : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_ADD_OP;
									aluSel_o <= `EXE_RES_ARITHMETIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_SUB : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_SUB_OP;
									aluSel_o <= `EXE_RES_ARITHMETIC;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b1;
									instValid <= `InstValid;
								end
								`EXE_JR : begin
									wreg_o <= `WriteEnable;
									aluOp_o <= `EXE_JR_OP;
									aluSel_o <= `EXE_RES_JUMP_BRANCH;
									reg1_read_o <= 1'b1;
									reg2_read_o <= 1'b0;
									link_addr_o <= `ZeroWord;
									branch_target_address_o <= reg1_o;
									branch_flag_o <= `Branch;
									next_inst_in_delayslot_o <= `InDelaySlot;
									instValid <= `InstValid;
								end
								default : begin
								end
							endcase
						end
						default : begin
						end
					endcase
				end

				`EXE_ORI : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_OR_OP;
					aluSel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {16'h0, inst_i[15:0]};
					wd_o <= inst_i[20:16];
					instValid <= `InstValid;
				end

				`EXE_ANDI : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_AND_OP;
					aluSel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {16'h0, inst_i[15:0]};
					wd_o <= inst_i[20:16];
					instValid <= `InstValid;
				end

				`EXE_XORI : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_XOR_OP;
					aluSel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {16'h0, inst_i[15:0]};
					wd_o <= inst_i[20:16];
					instValid <= `InstValid;
				end

				`EXE_LUI : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_OR_OP;
					aluSel_o <= `EXE_RES_LOGIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {16'h0, inst_i[15:0]};
					wd_o <= inst_i[20:16];
					instValid <= `InstValid;
				end

				`EXE_PREF : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_NOP_OP;
					aluSel_o <= `EXE_RES_NOP;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					instValid <= `InstValid;
				end

				`EXE_SLTI : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_SLT_OP;
					aluSel_o <=  `EXE_RES_ARITHMETIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
					wd_o <= inst_i[20:16];
					instValid <= `InstValid;
				end

				`EXE_ADDI : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_ADDI_OP;
					aluSel_o <=  `EXE_RES_ARITHMETIC;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b0;
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};
					wd_o <= inst_i[20:16];
					instValid <= `InstValid;
				end

				`EXE_J : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_J_OP;
					aluSel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b0;
					link_addr_o <= `ZeroWord;
					branch_flag_o <= `Branch;
					next_inst_in_delayslot_o <= `InDelaySlot;
					instValid <= `InstValid;
					branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
				end

				`EXE_BEQ : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_BEQ_OP;
					aluSel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					instValid <= `InstValid;
					if (reg1_o == reg2_o) begin
						branch_target_address_o <= pc_plus_4 + imm_sll2_signedExt;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end

				`EXE_BNE : begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_BNE_OP;
					aluSel_o <= `EXE_RES_JUMP_BRANCH;
					reg1_read_o <= 1'b1;
					reg2_read_o <= 1'b1;
					instValid <= `InstValid;
					if (reg1_o != reg2_o) begin
						branch_target_address_o <= pc_plus_4 + imm_sll2_signedExt;
						branch_flag_o <= `Branch;
						next_inst_in_delayslot_o <= `InDelaySlot;
					end
				end

				default : begin
				end
			endcase

			if (inst_i[31:21] == 11'b00000000000) begin
				if (op3 == `EXE_SLL) begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_SLL_OP;
					aluSel_o <= `EXE_RES_SHIFT;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b1;
					imm[4:0] <= inst_i[10:6];
					wd_o <= inst_i[15:11];
					instValid <= `InstValid;
				end else if (op3 == `EXE_SRL) begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_SRL_OP;
					aluSel_o <= `EXE_RES_SHIFT;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b1;
					imm[4:0] <= inst_i[10:6];
					wd_o <= inst_i[15:11];
					instValid <= `InstValid;
				end else if (op3 == `EXE_SRA) begin
					wreg_o <= `WriteEnable;
					aluOp_o <= `EXE_SRA_OP;
					aluSel_o <= `EXE_RES_SHIFT;
					reg1_read_o <= 1'b0;
					reg2_read_o <= 1'b1;
					imm[4:0] <= inst_i[10:6];
					wd_o <= inst_i[15:11];
					instValid <= `InstValid;
				end
			end
		end
	end

	always @ (*) begin
		if (rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
		end else if (reg1_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg1_addr_o) begin
			reg1_o <= ex_wdata_i;
		end else if (reg1_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg1_addr_o) begin
			reg1_o <= mem_wdata_i;
		end else if (reg1_read_o == 1'b1) begin
			reg1_o <= reg1_data_i;
		end else if (reg1_read_o == 1'b0) begin
			reg1_o <= imm;
		end else begin
			reg1_o <= `ZeroWord;
		end
	end

	always @ (*) begin
		if (rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if (reg2_read_o == 1'b1 && ex_wreg_i == 1'b1 && ex_wd_i == reg2_addr_o) begin
			reg2_o <= ex_wdata_i;
		end else if (reg2_read_o == 1'b1 && mem_wreg_i == 1'b1 && mem_wd_i == reg2_addr_o) begin
			reg2_o <= mem_wdata_i;
		end else if (reg2_read_o == 1'b1) begin
			reg2_o <= reg2_data_i;
		end else if (reg2_read_o == 1'b0) begin
			reg2_o <= imm;
		end else begin
			reg2_o <= `ZeroWord;
		end
	end

	always @ (*) begin
		if (rst == `RstEnable) begin
			is_in_delayslot_o <= `NotInDelaySlot;
		end else begin
			is_in_delayslot_o <= is_in_delayslot_i;
		end
	end

endmodule