`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:15:42 12/21/2020
// Design Name:   Reg_IDEX
// Module Name:   D:/Computer Organization/P7/test1/Reg_tb.v
// Project Name:  test1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Reg_IDEX
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`include "macro.v"
module Reg_tb;

	// Inputs
	reg clk;
	reg reset;
	reg ResetPC;
	reg [31:0] DPC;
	reg en;
	reg [399:0] MSG;

	// Outputs
	wire [399:0] msg;

	// Instantiate the Unit Under Test (UUT)
	Reg_IDEX uut (
		.clk(clk), 
		.reset(reset), 
		.ResetPC(ResetPC), 
		.DPC(DPC), 
		.en(en), 
		.MSG(MSG), 
		.msg(msg)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		ResetPC = 0;
		DPC = 0;
		en = 0;
		MSG = 0;
		
		#5
		en = 1;
		MSG = {{`MAX{1'b1}}};

		// Wait 100 ns for global reset to finish
		#100;
        
		DPC = 32'hfac1_3215;
		#5
		ResetPC = 1;
		// Add stimulus here

	end
      always #5 clk = ~clk;
endmodule

