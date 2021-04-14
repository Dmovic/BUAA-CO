`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:30:14 11/15/2020 
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
`define AND 3'b000
`define OR 3'b001
`define ADD 3'b010
`define LUI_SHIFT 3'b011
`define SUB 3'b110

module alu(
    input [2:0] ALUCtrl,
    input [31:0] A,
    input [31:0] B,
    output Zero,
    output [31:0] Result
    );
	 
	 reg [31:0] ret;	// reg 型建模组合逻辑
	 
	 always @(*)
	 begin
		case (ALUCtrl)
			`AND : ret = A & B;
			`OR : ret = A | B;
			`ADD : ret = A + B;
			`LUI_SHIFT : ret = B << 16;	// 逻辑左移16位
			`SUB : ret = A - B;
		endcase
	 end
	 
	 assign Result[31:0] = ret[31:0];
	 assign Zero = (A == B) ? 1'b1 : 1'b0;	// Zero 判断两个数字是否相等

endmodule
