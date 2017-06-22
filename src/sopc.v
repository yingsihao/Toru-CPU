`include "../src/defines.v"

module sopc(
	input wire clk,
	input wire rst
);
	wire[`InstAddrBus] inst_addr;
	wire[`InstBus] inst;
	wire rom_ce;
	wire mem_we_i;
  	wire[`RegBus] mem_addr_i;
  	wire[`RegBus] mem_data_i;
  	wire[`RegBus] mem_data_o;
  	wire[3:0] mem_sel_i;  
  	wire mem_ce_i;  

	ToruMIPS ToruMIPS0(
		clk, rst,
		inst,
		inst_addr, rom_ce,
		mem_data_o,
		mem_addr_i,
		mem_data_i,
		mem_we_i,
		mem_sel_i,
		mem_ce_i
	);

	inst_rom inst_rom0(
		rom_ce, inst_addr,
		inst
	);

	data_ram data_ram0(
		clk,
		mem_ce_i,
		mem_we_i,
		mem_addr_i,
		mem_sel_i,
		mem_data_i,
		mem_data_o
	);
endmodule