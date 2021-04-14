`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:08:16 12/02/2020 
// Design Name: 
// Module Name:    IF 
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

module IF(
	input [`MAX-1:0] MSG,
	input clk,
	input reset,
	input en,
	input except,
	output reg[`MAX-1:0] msg,
	output [31:0] PC
    );
	
	wire [31:0] pc;
	
	// F���������ɽ��
	wire [31:0] F_pc;
	wire [31:0] F_instr;
	wire [4:0] im_exc;	// ������
	
	pc fpc(
					.MSG(MSG),
					.clk(clk),
					.reset(reset),
					.en(en),
					.except(except),
					.pc(F_pc)
	);
	
	im fim(
					.pc(F_pc),
					.instr(F_instr),
					.ImExc(im_exc)
	);
	
	assign PC = F_pc;
	
	// ����
	always @(*)
	begin : fctrl
		// �ü��²����Ľ��
		msg = `MAX'b0;	// �Ӹü�������ʼ��msg�ź�
		msg[`pc] = F_pc;
		msg[`instr] = F_instr;
		msg[`ExcCode] = im_exc;
	end

endmodule
