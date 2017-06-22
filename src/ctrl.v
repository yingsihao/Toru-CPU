`include "defines.v"

module ctrl(
	input wire rst,
	input wire stallReq_from_id,
	input wire stallReq_from_ex,
	output reg[5:0] stall
);

	always @ (*) begin
		if (rst == `RstEnable) begin
			stall <= 6'b000000;
		end else if (stallReq_from_ex == `Stop) begin
			stall <= 6'b001111;
		end else if (stallReq_from_id == `Stop) begin
			stall <= 6'b000111;
		end else begin
			stall <= 6'b000000;
		end
	end

endmodule
