`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:07:12 12/21/2020 
// Design Name: 
// Module Name:    Reg_IDEX 
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

module Reg_IDEX(
	input clk,
	input reset,
	input ResetPC,
	input [31:0] DPC,
	input en,
	input [`MAX-1:0] MSG,
	output reg [`MAX-1:0] msg
    );
	 
	 always @(posedge clk)
	 begin
		if (reset)
			msg <= `MAX'b0;
		else if (ResetPC)
		begin
			msg <= `MAX'b0;	// 将其他信息清空, 放入pc
			msg[`pc] <= DPC;
		end
		else if (en)
			msg <= MSG;
		else
			msg <= msg;
	 end


endmodule
