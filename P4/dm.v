`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:01:29 11/15/2020 
// Design Name: 
// Module Name:    dm 
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
module dm(
    input Clk,
    input Reset,
    input WE,
    input RE,
    input [31:0] Addr,
    input [31:0] WD,
	 input [31:0] PC,
    output [31:0] RD
    );
	
	reg [31:0] data_mem [1023:0];
	integer i;
	
	always @(posedge Clk)
	begin
		if (Reset)
		begin
			for(i=0;i<1024;i=i+1)
			begin
				data_mem[i] <= 32'h0;	// 初始化复位至0
			end
		end
		else
		begin
			if (WE)
			begin
				data_mem[Addr[11:2]] <= WD[31:0];	// 地址取 [11:2]
				$display("@%h: *%h <= %h", PC, Addr, WD);
			end
		end
	end
	
	assign RD = (RE == 1'b1) ? data_mem[Addr[11:2]] : 32'h0;	// RE 有效时读数, 否则为0

endmodule
