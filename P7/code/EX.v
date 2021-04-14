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
	input inter,
	output reg[`MAX-1:0] msg
    );

	wire [31:0] instr;
	wire [31:0] ret;	// ����ALU������
	
	wire [31:0] high;	// �˳�����32λ��ֵ
	wire [31:0] low;	// �˳�����32λ��ֵ
	wire busy;
	
	// �쳣�ж�
	wire [4:0] E_ExcCode;
	
	assign instr = MSG[`instr];
	
	// ����ALU����
	alu ealu(
					.MSG(MSG),
					.AO(ret),
					.ExcCode(E_ExcCode)
	);
	
	multdiv emultdiv(
								.clk(clk),
								.reset(reset),
								.MSG(MSG),
								.HI(high),
								.LO(low),
								.busy(busy),
								.inter(inter)
	);
	
	// ����
	always @(*)
	begin : ectrl
		// �ü��²����Ľ��
		msg = MSG;
		msg[`AO] = ret;
		msg[`busy] = busy;
		
		// д�Ĵ����ź�
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
		// �˳�ָ��
		else if (`mfhi)
		begin
			msg[`tarReg] = MSG[`rd];	// дrd�Ĵ���
			msg[`WD] = high;	// ��32λ
			msg[`grfWE] = 1'b1;
		end
		else if (`mflo)
		begin
			msg[`tarReg] = MSG[`rd];	// дrd
			msg[`WD] = low;	// ��32λ
			msg[`grfWE] = 1'b1;
		end
		
		// tnew
		msg[`tnew] = (msg[`tnew] == 4'h0) ? 4'h0 : (msg[`tnew] - 4'h1);
		
		// �쳣�ж�
		if (E_ExcCode != 5'd0)
		begin
			msg[`instr] = 32'b0;
			msg[`grfWE] = 1'b0;
			msg[`ExcCode] = msg[`ExcCode] | E_ExcCode;
		end
	end

endmodule