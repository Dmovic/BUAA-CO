`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:20 10/24/2020 
// Design Name: 
// Module Name:    splitter 
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
module splitter(
	input [31:0] A,
	output [7:0] O1,
	output [7:0] O2,
	output [7:0] O3,
	output [7:0] O4
    );

assign O1[7:0] = A[31:24];
assign O2[7:0] = A[23:16];
assign O3[7:0] = A[15: 8];
assign O4[7:0] = A[ 7: 0];

endmodule
