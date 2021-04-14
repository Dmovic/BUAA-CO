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
`include "macro.v"

module dm(
    input Clk,
    input Reset,
    input WE,
	 input [3:0] BE,
    input [31:0] Addr,
    input [31:0] WD,
	 input [31:0] PC,
    output [31:0] RD
    );
	
	reg [31:0] data_mem [4095:0];
	integer i;
	
	reg [31:0] write;	// 最终写入的数据, 根据sh\sb等选择
	
	// WD写入位置选择, 根据BE
	always @(*)
	begin : WD_Sel
		write = data_mem[Addr[13:2]];	// 先获取原本数据
		if (BE[0] == 1'b1)
			write[7:0] = WD[7:0];
		if (BE[1] == 1'b1)
			write[15:8] = WD[15:8];
		if (BE[2] == 1'b1)
			write[23:16] = WD[23:16];
		if (BE[3] == 1'b1)
			write[31:24] = WD[31:24];
	end
	
	always @(posedge Clk)
	begin
		if (Reset)
		begin
			for(i=0;i<4096;i=i+1)
			begin
				data_mem[i] <= 32'h0;	// 初始化复位至0
			end
		end
		else
		begin
			if (WE)
			begin
				data_mem[Addr[13:2]] <= write[31:0];	// 地址取 [13:2]更新
				$display("%d@%h: *%h <= %h", $time, PC, {Addr[31:2], 2'b00}, write);
			end
		end
	end
	
	assign RD = data_mem[Addr[13:2]];	// 越界?

endmodule
