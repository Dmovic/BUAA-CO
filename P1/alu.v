`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:24:36 10/24/2020 
// Design Name: 
// Module Name:    alu 
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
`define ADDU 3'b000
`define SUBU 3'b001
`define AND 3'b010
`define OR 3'b011
`define SRL 3'b100
`define SRA 3'b101

module alu(
	input [31:0] A,
	input [31:0] B,
	input [2:0] ALUOp,
	output [31:0] C
    );

	reg [31:0] ret;

	always@(*)
	case (ALUOp)
		`ADDU : ret = A + B;
		`SUBU : ret = A - B;
		`AND : ret = A & B;
		`OR : ret = A | B;
		`SRL : ret = (A >> B);
		`SRA : ret = $signed($signed(A) >>> B);
		default : ret = 0;
	endcase

	assign C[31:0] = ret[31:0];

endmodule
