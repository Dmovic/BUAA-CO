`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:04 11/15/2020 
// Design Name: 
// Module Name:    npc 
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
`define order 2'b00
`define NPCBEQ 2'b01
`define NPCJAL 2'b10
`define NPCJR 2'b11

module npc(
	input Zero,
	input [1:0] NPCOp,
	input [31:0] PC,
	input [25:0] Imm,
	input [31:0] RA,
	output reg [31:0] NPC,
	output reg [31:0] PC4
   );
	
	always @(*)
	begin
		PC4 = PC + 32'h4;

		case (NPCOp)
			`order : NPC = PC + 32'h4;	// À≥–Ú÷¥–– PC + 4
			
			`NPCBEQ : 
						if (Zero == 1'b1)
							NPC = PC + 32'h4 + {{14{Imm[15]}}, Imm[15:0], {2{1'b0}}};	// sign_extend(Imm[15:0] || 00)
						else
							NPC = PC + 32'h4;
			
			`NPCJAL : NPC = {PC[31:28], Imm[25:0], {2{1'b0}}};	// PC_31..28 || instr_index || 00\
			
			`NPCJR : NPC = RA[31:0];	// npc <- grf[rs]
		endcase
	end


endmodule
