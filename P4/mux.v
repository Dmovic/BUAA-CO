`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:29:29 11/17/2020 
// Design Name: 
// Module Name:    mux 
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
`define Ra 5'h1f

`define A3SelRd 2'b00
`define A3SelRt 2'b01
`define A3SelRa 2'b10

`define WDSelALU 2'b00
`define WDSelDM 2'b01
`define WDSelNPC 2'b10

`define BSelGRF 1'b0
`define BSelEXT 1'b1

module mux(
    input [4:0] rd,
	 input [4:0] rt,
	 input [31:0] Result,
	 input [31:0] RD,
	 input [31:0] PC4,
	 input [31:0] RD2,
	 input [31:0] Ext32,
	 
	 input [1:0] MGRFA3,
	 input [1:0] MGRFWD,
	 input MALUB,
	 output reg [4:0] GRFA3,
	 output reg [31:0] GRFWD,
	 output reg [31:0] ALUB
	 );
	 
	
	always @(*)
	begin
		case (MGRFA3)
			`A3SelRd : GRFA3 = rd;
			`A3SelRt : GRFA3 = rt;
			`A3SelRa : GRFA3 = `Ra;
		endcase
		
		case (MGRFWD)
			`WDSelALU : GRFWD = Result;
			`WDSelDM : GRFWD = RD;
			`WDSelNPC : GRFWD = PC4;
		endcase
		
		case (MALUB)
			`BSelGRF : ALUB = RD2;
			`BSelEXT : ALUB = Ext32;
		endcase
	end


endmodule
