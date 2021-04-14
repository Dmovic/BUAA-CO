`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:48:45 12/01/2020 
// Design Name: 
// Module Name:    spl 
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

module spl(
	input [`MAX-1:0] msg
    );

	wire [31:0] instr,pc,RS,RT,npc,ext32,AO,WD;
	wire [4:0] A3;
	wire [3:0] rtuse,rsuse,tnew;
	wire GRFWE,branch;
	
	assign instr=msg[`instr];
	assign pc=msg[`pc];
	assign RS=msg[`RS];
	assign RT=msg[`RT];
	assign nPC=msg[`npc];
	assign ext32=msg[`ext32];
	assign AO=msg[`AO];
	assign WD=msg[`WD];
	assign A3=msg[`tarReg];
	assign rtuse=msg[`rtuse];
	assign rsuse=msg[`rsuse];
	assign tnew=msg[`tnew];
	assign GRFWE=msg[`grfWE];
	assign branch=msg[`branch];

endmodule
