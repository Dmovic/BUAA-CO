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
	 
	wire [3:0] rtuse , rsuse, tnew;
	wire [31:0] instr, pc, RS, RT, npc, ext32, AO, WD;
	wire [4:0] tarReg;
	wire [4:0] A3;
	wire grfWE, branch;
	
	wire md, busy;;;
	
	wire BusyEPC;
	wire [4:0] ExcCode;
	
	wire [31:0] DMRD;
	wire vary;
	
	assign BusyEPC = msg[`BusyEPC];
	assign ExcCode = msg[`ExcCode];
	
	assign md = msg[`md];
	assign busy = msg[`busy];;;
	
	assign instr = msg[`instr];
	assign pc = msg[`pc];
	assign npc = msg[`npc];;
	assign branch = msg[`branch];
	
	assign RS = msg[`RS];
	assign RT = msg[`RT];
	
	assign ext32 = msg[`ext32];
	assign AO = msg[`AO];
	assign WD = msg[`WD];
	
	assign DMRD = msg[`DMRD];
	assign vary = msg[`vary];
	
	assign tarReg = msg[`tarReg];
	assign grfWE = msg[`grfWE];
	
	assign rtuse = msg[`rtuse];
	assign rsuse = msg[`rsuse];
	assign tnew = msg[`tnew];
	
	

endmodule
