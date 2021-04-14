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
	 output reg [31:0] instr,
	 output reg [4:0] ImExc
	 );
	 
	 integer i;
	 reg [31:0] instr_mem [4095:0];
	 
	 //// pc 值需要减去 0x3000
	 reg [31:0] newpc;
	 
	 initial
	 begin
		for (i=0;i<4096;i=i+1)
			instr_mem[i] = 32'h0;
		$readmemh("code.txt", instr_mem);
		$readmemh("code_handler.txt", instr_mem, 1120, 2047);
	 end
	 
	 // 计算新的pc, 用于读取指令
	 always @(*)
	 begin
		newpc = pc -32'h3000;
		
		if (!(((pc >= 32'h0000_3000) && (pc <= 32'h0000_4ffff)) &&
				pc[1:0] == 2'b00))
		begin
			// 产生异常
			instr = 32'b0;	// 视为nop
			ImExc = `AdEL;
		end
		else
		begin
			instr = instr_mem[newpc[13:2]];
			ImExc = 5'd0;
		end
	 end
	 
endmodule
