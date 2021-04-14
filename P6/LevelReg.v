`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:20:47 12/02/2020 
// Design Name: 
// Module Name:    LevelReg 
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

module LevelReg(
	input clk,
	input reset,
	input en,
	input [`MAX-1:0] MSG,
	output reg[`MAX-1:0] msg
    );

	always @(posedge clk)
	begin
		if (reset)
			msg <= `MAX'b0;	// ��ʼ��Ϊȫ0
		else if (en)
			msg <= MSG;	// ����
		else
			msg <= msg;	// ���� stall
	end
	

endmodule
