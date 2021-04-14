`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:01:14 11/15/2020 
// Design Name: 
// Module Name:    grf 
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

module grf(
    input Clk,
    input Reset,
    input WE,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
	 input [31:0] PC,
    output [31:0] RD1,
    output [31:0] RD2
    );
	 
	 reg [31:0] register [31:1];	// 0号寄存器始终为0
	 integer i;	// 循环变量
	 
	 // 写寄存器
	 always @(posedge Clk)
	 begin
		if (Reset)
		begin
			for (i=1;i<32;i=i+1)
			begin
				register[i] <= 32'h0;
			end
		end
		else
		begin
			if ((WE == 1'b1))	// 为方便对比, 暂时将$0也输出
			begin
				register[A3] <= WD[31:0];
				$display("%d@%h: $%d <= %h", $time, PC, A3, WD);
			end
		end
	 end
	 
	 // 读寄存器
	 assign RD1 = (A1 == 0) ? 32'b0 : register[A1];
	 assign RD2 = (A2 == 0) ? 32'b0 : register[A2];	// 0号寄存器始终输出0


endmodule
