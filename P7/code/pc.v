`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:48:20 11/28/2020 
// Design Name: 
// Module Name:    pc 
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

module pc(
	input [`MAX-1:0] MSG,
	input clk,
	input reset,
	input en,
	input except,
	output reg [31:0] pc
    );
	
	always @(posedge clk)
	begin
		if (reset)
			pc <= 32'h0000_3000;	// 初始化为0x0000_3000
		else if (except)
			pc <= 32'h0000_4180;	// 异常处理入口
		else if (en)
			pc <= (MSG[`branch] == 1'b1) ? MSG[`npc] :
					(pc + 32'h4);	// 这里修改npc只是跳转
		else
			pc <= pc;
	end
	
endmodule
