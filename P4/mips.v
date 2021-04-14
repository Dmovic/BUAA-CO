`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:06:42 11/17/2020 
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

	// 依次的模块输出端口
	//PC
	wire [31:0] DO;
	
	// NPC
	wire [31:0] NPC;
	wire [31:0] PC4; 
	
	// IM
	wire [31:0] Instr;
	
	// GRF
	wire [31:0] RD1;
	wire [31:0] RD2;
	
	// ALU
	wire Zero;
	wire [31:0] Result;
	
	// DM
	wire [31:0] RD;
	
	// EXT
	wire [31:0] Ext32;
	
	// Ctrl
	wire [1:0] NPCOp;
	wire EXTOp;
	wire RegWrite;
	wire MemWrite;
	wire MemRead;
	wire [2:0] ALUCtrl;
	wire [1:0] MGRFA3;
	wire [1:0] MGRFWD;
	wire MALUB;
	
	//MUX
	wire [4:0] GRFA3;
	wire [31:0] GRFWD;
	wire [31:0] ALUB;
	
	// 解析指令
	wire [5:0] op;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] shamt;
	wire [5:0] func;
	wire [25:0] imm26;
	wire [15:0] imm16;
	
	assign op = Instr[31:26];
	assign rs = Instr[25:21];
	assign rt = Instr[20:16];
	assign rd = Instr[15:11];
	assign shamt = Instr[10:6];
	assign func = Instr[5:0];
	assign imm26 = Instr[25:0];
	assign imm16 = Instr[15:0];
	
	// 模块连接
	
	pc my_pc(.Clk(clk), .Reset(reset), .DI(NPC), .DO(DO));
	npc my_npc(.Zero(Zero), .NPCOp(NPCOp), .PC(DO), .Imm(imm26), .RA(RD1), .NPC(NPC), .PC4(PC4));
	im my_im(.Addr(DO), .Instr(Instr));
	grf my_grf(.Clk(clk), .Reset(reset), .WE(RegWrite), .A1(rs), .A2(rt), .A3(GRFA3), .WD(GRFWD), .PC(DO), .RD1(RD1), .RD2(RD2));
	alu my_alu(.ALUCtrl(ALUCtrl), .A(RD1), .B(ALUB), .Zero(Zero), .Result(Result));
	dm my_dm(.Clk(clk), .Reset(reset), .WE(MemWrite), .RE(MemRead), .Addr(Result), .WD(RD2), .PC(DO), .RD(RD));
	ext my_ext(.EXTOp(EXTOp), .Imm(imm16), .Ext32(Ext32));
	
	ctrl my_ctrl(.op(op), .func(func), .NPCOp(NPCOp), .ALUCtrl(ALUCtrl), .EXTOp(EXTOp), .RegWrite(RegWrite), 
					.MemRead(MemRead), .MemWrite(MemWrite), .MGRFA3(MGRFA3), .MGRFWD(MGRFWD), .MALUB(MALUB));
					
	mux my_mux(.rd(rd), .rt(rt), .Result(Result), .RD(RD), .PC4(PC4), .RD2(RD2), .Ext32(Ext32), 
				.MGRFA3(MGRFA3), .MGRFWD(MGRFWD), .MALUB(MALUB), .GRFA3(GRFA3), .GRFWD(GRFWD), .ALUB(ALUB));
				
	//// test module
	//DASM2 my_DASM2(.instr(Instr), .reg_name(1'b0));
	////
	
endmodule
