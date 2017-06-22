`include "defines.v"

module ToruMIPS(
	input wire clk,
	input wire rst,

	input wire[`RegBus] rom_data_i,

	output wire[`RegBus] rom_addr_o,
	output wire rom_ce_o
);

	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;

	wire[`AluOpBus] id_aluOp_o;
	wire[`AluSelBus] id_aluSel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	wire id_is_in_delayslot_o;
	wire[`RegBus] id_link_address_o;

	wire[`AluOpBus] ex_aluOp_i;
	wire[`AluSelBus] ex_aluSel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire ex_is_in_delayslot_i;
	wire[`RegBus] ex_link_address_i;

	wire  ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;

	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;

	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;

	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;

	wire reg1_read;
	wire reg2_read;
	wire[`RegBus] reg1_data;
	wire[`RegBus] reg2_data;
	wire[`RegAddrBus] reg1_addr;
	wire[`RegAddrBus] reg2_addr;

	wire is_in_delayslot_i;
	wire is_in_delayslot_o;
	wire next_inst_in_delay_slot_o;
	wire id_branch_flag_o;
	wire[`RegBus] branch_target_address;

	wire[5:0] stall;
	wire stallReq_from_id;
	wire stallReq_from_ex;

	pc_reg pc_reg0(
		clk, rst,
		stall,
		id_branch_flag_o, branch_target_address,
		pc, rom_ce_o
	);

	assign rom_addr_o = pc;

	if_id if_id0(
		clk, rst, stall, pc, rom_data_i,
		id_pc_i, id_inst_i
	);

	id id0(
		rst, id_pc_i, id_inst_i, ex_wreg_o, ex_wdata_o, ex_wd_o, mem_wreg_o, mem_wdata_o, mem_wd_o, reg1_data, reg2_data,
		is_in_delayslot_i,
		reg1_read, reg2_read, reg1_addr, reg2_addr,
		id_aluOp_o, id_aluSel_o, id_reg1_o, id_reg2_o, id_wd_o, id_wreg_o,
		stallReq_from_id,
		next_inst_in_delayslot_o,
		id_branch_flag_o,
		branch_target_address,
		id_link_address_o,
		id_is_in_delayslot_o
	);

	regfile regfile0(
		clk, rst, wb_wreg_i, wb_wd_i, wb_wdata_i, 
		reg1_read, reg1_addr, reg1_data,
		reg2_read, reg2_addr, reg2_data
	);

	id_ex id_ex0(
		clk, rst,
		stall,
		id_aluOp_o, id_aluSel_o, id_reg1_o, id_reg2_o, id_wd_o, id_wreg_o,
		id_link_address_o, id_is_in_delayslot_o, next_inst_in_delayslot_o,
		ex_aluOp_i, ex_aluSel_i, ex_reg1_i, ex_reg2_i, ex_wd_i, ex_wreg_i,
		ex_link_address_i, ex_is_in_delay_slot_i, is_in_delayslot_i
	);

	ex ex0(
		rst,
		ex_aluOp_i, ex_aluSel_i, ex_reg1_i, ex_reg2_i, ex_wd_i, ex_wreg_i,
		ex_link_address_i, ex_is_in_delayslot_i,
		ex_wd_o, ex_wreg_o, ex_wdata_o,
		stallReq_from_ex
	);

	ex_mem ex_mem0(
		clk, rst,
		stall,
		ex_wd_o, ex_wreg_o, ex_wdata_o,
		mem_wd_i, mem_wreg_i, mem_wdata_i,
	);

	mem mem0(
		rst,
		mem_wd_i, mem_wreg_i, mem_wdata_i,
		mem_wd_o, mem_wreg_o, mem_wdata_o
	);

	mem_wb mem_wb_0(
		clk, rst,
		stall,
		mem_wd_o, mem_wreg_o, mem_wdata_o,
		wb_wd_i, wb_wreg_i, wb_wdata_i
	);

	ctrl ctrl0(
		rst,
		stallReq_from_id, stallReq_from_ex,
		stall
	);

endmodule