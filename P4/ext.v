`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:17:22 11/15/2020 
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
`define ZEXT 1'b0
`define SEXT 1'b1

module ext(
    input EXTOp,
    input [15:0] Imm,
    output [31:0] Ext32
    );

	assign Ext32 = (EXTOp == `ZEXT) ? {{16{1'b0}}, Imm} : 
												{{16{Imm[15]}}, Imm};	// 判断高位扩展方式 if ZERO_EXT

endmodule
