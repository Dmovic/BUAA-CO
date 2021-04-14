`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:08:16 12/02/2020 
// Design Name: 
// Module Name:    IF 
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

module IF(
	input [`MAX-1:0] MSG,
	input clk,
	input reset,
	input en,
	output reg[`MAX-1:0] msg
    );
	
	wire [31:0] pc;
	
	// F级部件生成结果
	wire [31:0] F_pc;
	wire [31:0] F_instr;
	
	pc fpc(
					.MSG(MSG),
					.clk(clk),
					.reset(reset),
					.en(en),
					.pc(F_pc)
	);
	
	im fim(
					.pc(F_pc),
					.instr(F_instr)
	);
	
	// 更新
	always @(*)
	begin : fctrl
		// 该级新产生的结果
		msg = `MAX'b0;	// 从该级产生初始的msg信号
		msg[`pc] = F_pc;
		msg[`instr] = F_instr;
	end

endmodule
