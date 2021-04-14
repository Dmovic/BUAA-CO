`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:14:47 11/17/2020 
// Design Name: 
// Module Name:    ctrl 
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
`define ADDU 6'b10_0001
`define SUBU 6'b10_0011
`define JR 6'b00_1000
// 以上为R型指令, 取func段
`define ORI 6'b00_1101
`define LW 6'b10_0011
`define SW 6'b10_1011
`define BEQ 6'b00_0100
`define LUI 6'b00_1111
`define JAL 6'b00_0011

module ctrl(
    input [5:0] op,
	 input [5:0] func,
	 output [1:0] NPCOp,
	 output [2:0] ALUCtrl,
	 output EXTOp,
	 output RegWrite,
	 output MemRead,
	 output MemWrite,
	 output [1:0] MGRFA3,
	 output [1:0] MGRFWD,
	 output MALUB
	 );
	 
	wire RType;	// 是否为R型指令
	wire addu;
	wire subu;
	wire jr;
	// 以上为R型指令
	wire ori;
	wire lw;
	wire sw;
	wire beq;
	wire lui;
	wire jal;
	
	// AND门阵列
	assign RType = (op == 6'b00_0000);
	
	assign addu = RType && (func == `ADDU);
	assign subu = RType && (func == `SUBU);
	assign jr = RType && (func == `JR);
	
	assign ori = (op == `ORI);
	assign lw = (op == `LW);
	assign sw = (op == `SW);
	assign beq = (op == `BEQ);
	assign lui = (op == `LUI);
	assign jal = (op == `JAL);
	
	// OR门阵列
	assign NPCOp[1] = jr +
							jal;
	
	assign NPCOp[0] = jr +
							beq;
							
	assign ALUCtrl[2] = subu +
							  beq;
							
	assign ALUCtrl[1] = addu +
							  subu +
							  lw +
							  sw +
							  beq +
							  lui;
	
	assign ALUCtrl[0] = ori +
							  lui;
	
	assign EXTOp = lw + 
						sw;
						
	assign RegWrite = addu +
							subu +
							ori +
							lw +
							lui +
							jal;
							
	assign MemRead = lw;
	
	assign MemWrite = sw;
	
	assign MGRFA3[1] = jal;
	
	assign MGRFA3[0] = ori +
							 lw +
							 lui;
							 
	assign MGRFWD[1] = jal;
	
	assign MGRFWD[0] = lw;
	
	assign MALUB = ori +
						lw +
						sw +
						lui;

endmodule
