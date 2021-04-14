`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:29:25 10/24/2020 
// Design Name: 
// Module Name:    string 
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
`define s0 4'b0000
`define s1 4'b0010
`define s2 4'b0100
`define s3 4'b1000
// one-hot pratice

module string(
	input clk,
	input clr,
	input [7:0] in,
	output out
   );
	
	reg [3:0] status;
	
	////
	initial
	begin
		status <= `s0;
	end
	////
	
	always @(posedge clk or posedge clr)
	begin
		if (clr)
			status <= `s0;
		else if (clk)
		case (status)
			`s0 : begin
							if ((in >= "0") && (in <= "9"))
								status <= `s1;
							else
								status <= `s3;
					end
					
			`s1 : begin
							if ((in == "+") || (in == "*"))
								status <= `s2;
							else
								status <= `s3;
					end
					
			`s2 : begin
							if ((in >= "0") && (in <= "9"))
								status <= `s1;
							else
								status <= `s3;
					end
					
			`s3 : status <= `s3;
					
			default : status <= `s0;
		endcase
	end
	
	assign out = (status == `s1) ? 1'b1 : 1'b0;


endmodule
