`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:23 10/24/2020 
// Design Name: 
// Module Name:    ext 
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
`define sign_extend 2'b00
`define unsign_extend 2'b01
`define load_high 2'b10
`define ext_sll 2'b11

module ext(
	input [15:0] imm,
	input [1:0] EOp,
	output [31:0] ext
    );
	 
	 reg [31:0] ext_data;
	 
	 always @(*)
	 case (EOp)
	 `sign_extend : ext_data = {{16{imm[15]}}, imm};
	 `unsign_extend : ext_data = {{16{1'b0}}, imm};
	 `load_high : ext_data = {imm, {16{1'b0}}};
	 `ext_sll : ext_data = ({{16{imm[15]}}, imm} >> 2);
	 default : ext_data = 0;
	 endcase
	 
	 assign ext = ext_data;

endmodule
