`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:10:41 12/02/2020 
// Design Name: 
// Module Name:    mips 
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

module mips(
	input clk,
	input reset
    );

	wire en;
	wire stall;
	
	// ��������, СдΪ���, ��дΪ����
	wire [`MAX-1:0] f_msg;	// ��fetch��ʼ��, ������pc, instr��ֵ
	wire [`MAX-1:0] D_MSG;
	wire [`MAX-1:0] d_msg;
	wire [`MAX-1:0] E_MSG;
	wire [`MAX-1:0] e_msg;
	wire [`MAX-1:0] M_MSG;
	wire [`MAX-1:0] m_msg;
	wire [`MAX-1:0] W_MSG;
	wire [`MAX-1:0] w_msg;
	
	// ת������
	wire [`MAX-1:0] ForwardD;
	wire [`MAX-1:0] ForwardE;
	wire [`MAX-1:0] ForwardM;
	
	assign en = 1'b1;
	
	IF my_IF(
				.MSG(d_msg),
				.clk(clk),
				.reset(reset),
				.en(!stall),
				.msg(f_msg)
	);
	
	LevelReg D_reg(
							.clk(clk),
							.reset(reset),
							.en(!stall),
							.MSG(f_msg),
							.msg(D_MSG)
	);
	
	// ע��д���ź�Ҫ����W��, ����ζ��d����������w_msg, ע��hazardģ��
	rf my_rf(
					.clk(clk),
					.reset(reset),
					.DMSG(D_MSG),
					.Wmsg(W_MSG),
					.msg(w_msg)
	);

	// ת�� E����ˮ�Ĵ���ǰ
	ID my_ID(
					.MSG(ForwardD),
					.msg(d_msg)
	);
	
	LevelReg E_reg(
							.clk(clk),
							.reset(reset | stall),
							.en(en),
							.MSG(d_msg),
							.msg(E_MSG)
	);
	
	// ת�� ALUǰ
	EX my_EX(
					.MSG(ForwardE),
					.msg(e_msg)
	);
	
	LevelReg M_reg(
							.clk(clk),
							.reset(reset),
							.en(en),
							.MSG(e_msg),
							.msg(M_MSG)
	);
	
	// ת�� DMǰ
	MEM my_MEM(
					.clk(clk),
					.reset(reset),
					.MSG(ForwardM),
					.msg(m_msg)
	);
	
	LevelReg W_reg(
							.clk(clk),
							.reset(reset),
							.en(en),
							.MSG(m_msg),
							.msg(W_MSG)
	);
	
	hazard HazardCtrl(
							.msgD(d_msg),
							.msgE(e_msg),
							.msgM(m_msg),
							.MSGD(w_msg),
							.MSGE(E_MSG),
							.MSGM(M_MSG),
							.MSGW(W_MSG),
							.stall(stall),
							.ForwardD(ForwardD),
							.ForwardE(ForwardE),
							.ForwardM(ForwardM)
	);
	
	
	DASM2 dis2(.instr(f_msg[`instr]), .reg_name(1'b0));
	/*
	spl sf(f_msg);
	spl sd(D_MSG);
	spl se(E_MSG);
	spl sm(M_MSG);
	spl sw(w_msg);
	
	*/
endmodule
