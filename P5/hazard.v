`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:47:07 11/29/2020 
// Design Name: 
// Module Name:    hazard 
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

module hazard(
	input [`MAX-1:0] msgD,
	input [`MAX-1:0] msgE,
	input [`MAX-1:0] msgM,
	
	input [`MAX-1:0] MSGD,
	input [`MAX-1:0] MSGE,
	input [`MAX-1:0] MSGM,
	input [`MAX-1:0] MSGW,
	
	output stall,
	output reg[`MAX-1:0] ForwardD,
	output reg[`MAX-1:0] ForwardE,
	output reg[`MAX-1:0] ForwardM
    );

	wire stall_rs;
	wire stall_rt;
	wire stall_rs_E;
	wire stall_rs_M;
	wire stall_rt_E;
	wire stall_rt_M;
	
	// 暂停
	assign stall_rs_E = (msgD[`rs] != 5'd0) &
							  (msgD[`rs] == msgE[`tarReg]) &
							  (msgD[`rsuse] < msgE[`tnew]);
							  
	assign stall_rs_M = (msgD[`rs] != 5'd0) &
							  (msgD[`rs] == msgM[`tarReg]) &
							  (msgD[`rsuse] < msgM[`tnew]);
	
	assign stall_rt_E = (msgD[`rt] != 5'd0) &
							  (msgD[`rt] == msgE[`tarReg]) &
							  (msgD[`rtuse] < msgE[`tnew]);
							  
	assign stall_rt_M = (msgD[`rt] != 5'd0) &
							  (msgD[`rt] == msgM[`tarReg]) &
							  (msgD[`rtuse] < msgM[`tnew]);
							  
	assign stall_rs = stall_rs_E | stall_rs_M;
	assign stall_rt = stall_rt_E | stall_rt_M;
	
	assign stall = stall_rs | stall_rt;
	
	// 转发
	always @(*)
	begin : Forward
		ForwardD = MSGD;
		ForwardE = MSGE;
		ForwardM = MSGM;
		
		// 优先级高的在最上面
		// rs
		ForwardD[`RS] = ((MSGE[`tarReg] == MSGD[`rs]) & (MSGD[`rs] != 5'd0)) ? MSGE[`WD] :
							 ((MSGM[`tarReg] == MSGD[`rs]) & (MSGD[`rs] != 5'd0)) ? MSGM[`WD] :
							 ((MSGW[`tarReg] == MSGD[`rs]) & (MSGD[`rs] != 5'd0)) ? MSGW[`WD] :
							 MSGD[`RS];
		
		ForwardE[`RS] = ((MSGM[`tarReg] == MSGE[`rs]) & (MSGE[`rs] != 5'd0)) ? MSGM[`WD] :
							 ((MSGW[`tarReg] == MSGE[`rs]) & (MSGE[`rs] != 5'd0)) ? MSGW[`WD] :
							 MSGE[`RS];
							 
		ForwardM[`RS] = ((MSGW[`tarReg] == MSGM[`rs]) & (MSGM[`rs] != 5'd0)) ? MSGW[`WD] :
							 MSGM[`RS];
		
		// rt
		ForwardD[`RT] = ((MSGE[`tarReg] == MSGD[`rt]) & (MSGD[`rt] != 5'd0)) ? MSGE[`WD] :
							 ((MSGM[`tarReg] == MSGD[`rt]) & (MSGD[`rt] != 5'd0)) ? MSGM[`WD] :
							 ((MSGW[`tarReg] == MSGD[`rt]) & (MSGD[`rt] != 5'd0)) ? MSGW[`WD] :
							 MSGD[`RT];
		
		ForwardE[`RT] = ((MSGM[`tarReg] == MSGE[`rt]) & (MSGE[`rt] != 5'd0)) ? MSGM[`WD] :
							 ((MSGW[`tarReg] == MSGE[`rt]) & (MSGE[`rt] != 5'd0)) ? MSGW[`WD] :
							 MSGE[`RT];
							 
		ForwardM[`RT] = ((MSGW[`tarReg] == MSGM[`rt]) & (MSGM[`rt] != 5'd0)) ? MSGW[`WD] :
							 MSGM[`RT];
	
	end
	
endmodule
