`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:11:27 12/02/2020 
// Design Name: 
// Module Name:    MEM 
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

module MEM(
	input clk,
	input reset,
	input [`MAX-1:0] MSG,
	output reg[`MAX-1:0] msg
    );

	wire [31:0] M_addr;
	wire [31:0] instr;	// 要判断指令
	reg M_WE;
	reg [31:0] M_WD;	// 写入的数据
	integer i;
	
	// M级生成结果
	wire [31:0] M_RD;
	
	assign M_addr = MSG[`AO];	// AO来自寄存器的else计算
	assign instr = MSG[`instr];
	
	// dm相关控制信号
	always @(*)
	begin : dmctrl
		M_WE = `sw;	// 写使能信号, 多条指令用 | 连接
		
		if (`sw)
		begin
			M_WD = MSG[`RT];
		end
		
		// 若是sb等可以尝试，将MSG接入dm, 在dm部件中case(addr[1:0])
	
	end
	
	dm mdm(
					.Clk(clk),
					.Reset(reset),
					.WE(M_WE),
					.Addr(MSG[`AO]),
					.WD(M_WD),
					.PC(MSG[`pc]),
					.RD(M_RD)
		);
	
	// 更新
	always @(*)
	begin : mctrl
		// 该级产生新结果
		msg = MSG;
		
		// 写寄存器信号
		if (`lw)
		begin
			msg[`tarReg] = MSG[`rt];
			msg[`WD] = M_RD;	// 从内存中读取数据
			msg[`grfWE] = 1'b1;
		end
		
		// Tnew
		msg[`tnew] = (MSG[`tnew] == 4'h0) ? 4'h0 : (MSG[`tnew] - 4'h1);
		
	end
	
endmodule
