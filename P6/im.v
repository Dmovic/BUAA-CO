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
	 
	 integer i;
	 reg [31:0] instr_mem [4095:0];
	 
	 //// pc ֵ��Ҫ��ȥ 0x3000
	 reg [31:0] newpc;
	 
	 initial
	 begin
		for (i=0;i<4096;i=i+1)
			instr_mem[i] = 32'h0;
		$readmemh("code.txt", instr_mem, 0, 4095);
	 end
	 
	 // �����µ�pc, ���ڶ�ȡָ��
	 always @(*)
	 begin
		newpc = pc -32'h3000;
	 end
	 
	 assign instr = instr_mem[newpc[13:2]];	// ��ַΪ4�ı���, �ݲ����Ǵ���

endmodule
