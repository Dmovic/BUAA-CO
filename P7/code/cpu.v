`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:31:51 12/23/2020 
// Design Name: 
// Module Name:    cpu 
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

module cpu(
	input clk,
	input reset,
	input [5:0] HWInt,
	input [31:0] BgData,
	output [31:0] DMAddr,
	output [31:0] PC,
	output [31:0] DMData,
	output [31:0] MacroPC,
	output DMWE
    );
	
	wire en;
	wire stall;
	wire [31:0] e_instr;
	wire [31:0] W_instr;
	
	wire [31:0] cpu_pc;
	wire [31:0] cpu_epc;
	wire cpu_Exc;
	
	// 各级接线, 小写为输出, 大写为输入
	wire [`MAX-1:0] f_msg;	// 在fetch初始化, 并加入pc, instr等值
	wire [`MAX-1:0] D_MSG;
	wire [`MAX-1:0] d_msg;
	wire [`MAX-1:0] E_MSG;
	wire [`MAX-1:0] e_msg;
	wire [`MAX-1:0] M_MSG;
	wire [`MAX-1:0] m_msg;
	wire [`MAX-1:0] W_MSG;
	wire [`MAX-1:0] w_msg;
	
	wire [`MAX-1:0] D_MSG_NEW;
	
	// 转发数据
	wire [`MAX-1:0] ForwardD;
	wire [`MAX-1:0] ForwardE;
	wire [`MAX-1:0] ForwardM;
	
	assign en = 1'b1;
	
	wire FlushD;
	wire cpu_IntReq;
	wire [31:0] CP0_datain;
	wire [31:0] CP0_dataout;
	wire [4:0] CP0_addrin;	// 接入CP0 A
	wire CP0_enin;
	
	wire [31:0] CP0Data;
	wire [31:0] CP0Write;
	wire [4:0] CP0Addr;	// 接入CP0 A
	
	IF my_IF(
				.MSG(d_msg),
				.clk(clk),
				.reset(reset),
				.en(!stall),
				.except(cpu_Exc),
				.msg(f_msg),
				.PC(PC)
	);
	
	LevelReg D_reg(
							.clk(clk),
							.reset(reset | cpu_Exc),
							.en(!stall),
							.MSG(f_msg),
							.msg(D_MSG)
	);
	
	// 注意写入信号要来自W级, 且意味这d级输入来自w_msg, 注意hazard模块
	rf my_rf(
					.clk(clk),
					.reset(reset),
					.DMSG(D_MSG),
					.Wmsg(W_MSG),
					.msg(w_msg)
	);
	
	// 转发 E级流水寄存器前
	assign D_MSG_NEW = (FlushD) ? `MAX'b0 :
							 ForwardD;
	ID my_ID(
					.MSG(D_MSG_NEW),
					.EPC(cpu_epc),
					.msg(d_msg)
	);
	
	Reg_IDEX my_Reg_IDEX(
									.clk(clk),
									.reset(reset | cpu_Exc),
									.ResetPC(stall | FlushD),
									.DPC(d_msg[`pc]),
									.en(en),
									.MSG(d_msg),
									.msg(E_MSG)
									
	);
	
	EX my_EX(
					.clk(clk),
					.reset(reset),
					.MSG(ForwardE),
					.inter(cpu_Exc),
					.msg(e_msg)
	);
	
	LevelReg M_reg(
							.clk(clk),
							.reset(reset | cpu_Exc),
							.en(en),
							.MSG(e_msg),
							.msg(M_MSG)
	);
	
	MEM my_MEM(
					.clk(clk),
					.reset(reset),
					.MSG(ForwardM),
					.BgData(BgData),
					.CP0Data(CP0Data),
					.except(cpu_Exc),
					.msg(m_msg),
					//.BgWrite(BgWrite),
					//.BgAddr(BgAddr),
					//.BgWrite(BgData),
					.BgWrite(DMData),
					.BgAddr(DMAddr),
					.BgWE(BgWE),
					.CP0Write(CP0Write),
					.CP0Addr(CP0Addr),
					.CP0WE(CP0WE)
	);
	
	LevelReg W_reg(
							.clk(clk),
							.reset(reset | cpu_Exc),
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
	
	wire [24*8-1:0] asm;
	
	spl sf_out(f_msg);
	spl sd_out(D_MSG);
	spl se_out(E_MSG);
	spl sm_out(M_MSG);
	spl sw_out(w_msg);
	
	CP0 my_CP0(
					.clk(clk),
					.reset(reset),
					.HWInt(HWInt),
					.DIn(CP0Write),
					.A(CP0Addr),
					.We(CP0WE),
					.IntReq(cpu_IntReq),
					.MSGF(d_msg),
					.MSGD(w_msg),
					.MSGE(E_MSG),
					.MSGM(M_MSG),
					.MSGW(W_MSG),
					.DOut(CP0Data),
					.EPC(cpu_epc),
					.MacroPC(MacroPC),
					.EXLSet(cpu_Exc)
	);
	
	assign e_instr = e_msg[`instr];
	assign FlushD = (e_instr == `eret_code) ? 1'b1 :
						 1'b0;
						 
	assign W_instr = W_MSG[`instr];
	assign cpu_IntReq = (W_instr == `eret_code) ? 1'b1 :
							  1'b0;
	

endmodule
