`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:55:52 11/15/2020 
// Design Name: 
// Module Name:    im 
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

module im(
    input [31:0] pc,
	 output [31:0] instr
	 );
	 
	 reg [31:0] instr_mem [1023:0];
	 
	 initial
	 begin
		$readmemh("code.txt", instr_mem);
	 end
	 
	 assign instr = instr_mem[pc[11:2]];	// 地址为4的倍数, 暂不考虑错误

endmodule
