`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:10:44 12/02/2020 
// Design Name: 
// Module Name:    EX 
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

module EX(
	input clk,
	input reset,
	input [`MAX-1:0] MSG,
	output reg[`MAX-1:0] msg
    );

	wire [31:0] instr;
	wire [31:0] ret;	// 常规ALU计算结果
	
	wire [31:0] high;	// 乘除法高32位数值
	wire [31:0] low;	// 乘除法低32位数值
	wire busy;
	
	assign instr = MSG[`instr];
	
	// 常规ALU计算
	alu ealu(
					.MSG(MSG),
					.AO(ret)
	);
	
	multdiv emultdiv(
								.clk(clk),
								.reset(reset),
								.MSG(MSG),
								.HI(high),
								.LO(low),
								.busy(busy)
	);
	
	// 更新
	always @(*)
	begin : ectrl
		// 该级新产生的结果
		msg = MSG;
		msg[`AO] = ret;
		msg[`busy] = busy;
		
		// 写寄存器信号
		if (`addu | `subu | `add | `sub |
			 `sll | `srl | `sra | `sllv | `srlv | `srav |
			 `AND | `OR | `XOR | `NOR |
			 `slt | `sltu)
		begin
			msg[`tarReg] = MSG[`rd];
			msg[`WD] = ret;
			msg[`grfWE] = 1'b1;
		end
		else if (`ori | `lui |
					`addi | `addiu | `andi | `xori |
					`slti | `sltiu)
		begin
			msg[`tarReg] = MSG[`rt];
			msg[`WD] = ret;
			msg[`grfWE] = 1'b1;
		end
		// 乘除指令
		else if (`mfhi)
		begin
			msg[`tarReg] = MSG[`rd];	// 写rd寄存器
			msg[`WD] = high;	// 高32位
			msg[`grfWE] = 1'b1;
		end
		else if (`mflo)
		begin
			msg[`tarReg] = MSG[`rd];	// 写rd
			msg[`WD] = low;	// 低32位
			msg[`grfWE] = 1'b1;
		end
		
		// tnew
		msg[`tnew] = (msg[`tnew] == 4'h0) ? 4'h0 : (msg[`tnew] - 4'h1);
		
	end

endmodule