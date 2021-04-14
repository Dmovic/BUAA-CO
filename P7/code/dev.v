`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:55:10 12/23/2020 
// Design Name: 
// Module Name:    dev 
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
module dev(
	input clk,
	input reset,
	input [31:0] tc0addr,
	input tc0we,
	input [31:0] tc0write,
	output [31:0] tc0data,
	output tc0intreq,
	// tc1
	input [31:0] tc1addr,
	input tc1we,
	input [31:0] tc1write,
	output [31:0] tc1data,
	output tc1intreq,
	// odm
	input [31:0] odmwrite,
	input [31:0] odmaddr,
	input odmwe,
	output [31:0] odmdata
    );

	reg [31:0] odm [4095:0];
	integer i;
	
	wire [31:2] odmA;
	assign odmA[31:2] = odmaddr[31:2];

	TC my_tc0(
					.clk(clk),
					.reset(reset),
					.Addr(tc0addr[31:2]),
					.WE(tc0we),
					.Din(tc0write),
					.Dout(tc0data),
					.IRQ(tc0intreq)
	);

	TC my_tc1(
					.clk(clk),
					.reset(reset),
					.Addr(tc1addr[31:2]),
					.WE(tc1we),
					.Din(tc1write),
					.Dout(tc1data),
					.IRQ(tc1intreq)
	);
	
	/*
	initial
	begin
		for(i = 0; i < 4096; i = i+1)
		begin
			odm[i] <= 32'h0;
		end
	end
	*/
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			for (i = 0; i < 4096; i = i+1)
			begin
				odm[i] <= 32'h0;
			end
		end
		else if (odmwe)
		begin
			odm[odmA[13:2]] <= odmdata;
		end
	end

endmodule
