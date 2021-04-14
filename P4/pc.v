`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:18:01 11/15/2020 
// Design Name: 
// Module Name:    pc 
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
module pc(
	input Clk,
	input Reset,
	input [31:0] DI,
	output reg [31:0] DO
   );
	
	always @(posedge Clk)
	begin
		if (Reset)
			DO <= 32'h0000_3000;	// ¸´Î»µ½0x0000_3000
		else
			DO <= DI;
	end

endmodule
