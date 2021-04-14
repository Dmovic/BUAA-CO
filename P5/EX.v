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
	input [`MAX-1:0] MSG,
	output reg[`MAX-1:0] msg
    );

	wire [15:0] imm16;
	wire [31:0] ext32;
	wire [31:0] rs;
	wire [31:0] rt;
	wire [31:0] instr;
	
	// E�����ɽ��
	reg [31:0] ret; // ALU ������

	
	assign imm16 = MSG[`imm16];	// 16λ������
	assign ext32 = MSG[`ext32];	// ��չ���32λ������
	assign rs = MSG[`RS];	// RS�Ĵ�����ֵ
	assign rt = MSG[`RT];	// RT�Ĵ�����ֵ
	assign instr = MSG[`instr];
	
	// ALU
	always @(*)
	begin : ALU
		if (`addu) ret = rs + rt;
		else if (`subu) ret = rs - rt;
		else if (`ori) ret = rs | ext32;
		else if (`lui) ret = {imm16, {16'b0}};
		else ret = rs + ext32;	// storeָ�� rs + ext32;
	end
	
	// ����
	always @(*)
	begin : ectrl
		// �ü��²����Ľ��
		msg = MSG;
		msg[`AO] = ret;
		
		// д�Ĵ����ź�
		if (`addu | `subu)
		begin
			msg[`tarReg] = MSG[`rd];
			msg[`WD] = ret;
			msg[`grfWE] = 1'b1;
		end
		else if (`ori | `lui)
		begin
			msg[`tarReg] = MSG[`rt];
			msg[`WD] = ret;
			msg[`grfWE] = 1'b1;
		end
		
		// tnew
		msg[`tnew] = (msg[`tnew] == 4'h0) ? 4'h0 : (msg[`tnew] - 4'h1);
		
	end

endmodule