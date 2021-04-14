`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:19:45 12/06/2020 
// Design Name: 
// Module Name:    dmext 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "macro.v"

module dmext(
	input [1:0] A,
	input [31:0] Din,
	input [`MAX-1:0] MSG,
	output [31:0] Dout
    );

	wire [31:0] instr;
	
	reg [31:0] mext;	// dm 读出的数据, 进行扩展
	
	assign instr = MSG[`instr];
	always @(*)
	begin : dm_data_ext
		if (`lw)
			mext = Din;
		else if (`lb)
		begin
			case (A)
				2'b00 : mext = {{24{Din[7]}}, Din[7:0]};	// 符号扩展
				2'b01 : mext = {{24{Din[15]}}, Din[15:8]};
				2'b10 : mext = {{24{Din[23]}}, Din[23:16]};
				2'b11 : mext = {{24{Din[31]}}, Din[31:24]};
			endcase
		end
		else if (`lbu)
		begin
			case (A)
				2'b00 : mext = {{24{1'b0}}, Din[7:0]};	// 0扩展
				2'b01 : mext = {{24{1'b0}}, Din[15:8]};
				2'b10 : mext = {{24{1'b0}}, Din[23:16]};
				2'b11 : mext = {{24{1'b0}}, Din[31:24]};
			endcase
		end
		else if (`lh)
		begin
			if (A[1] == 1'b0)
				mext = {{16{Din[15]}}, Din[15:0]};	// 符号扩展
			else
				mext = {{16{Din[31]}}, Din[31:16]};
		end
		else if (`lhu)
		begin
			if (A[1] == 1'b0)
				mext = {{16{1'b0}}, Din[15:0]};	// 0 扩展
			else
				mext = {{16{1'b0}}, Din[31:16]};
		end
		
		else
			mext = 32'h0;	// 不是读取指令
	end
	
	assign Dout = mext;
	
endmodule
