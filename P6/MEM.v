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
	wire [31:0] M_RD;	// dm中读出数据, 尚未进行扩展	
	integer i;
	reg [3:0] BE;	// 字节使能
	wire [3:0] be;	// 一定要导线?
	wire [1:0] pst;	// 存储位置, 字节偏移
	
	// M级生成结果
	wire [31:0] M_extRD;	// 最新扩展结果
	
	assign M_addr = MSG[`AO];	// AO来自寄存器的else计算
	assign instr = MSG[`instr];
	assign pst = M_addr[1:0];	// 存储的具体位置
	
	// dm相关控制信号
	always @(*)
	begin : dmctrl
		M_WD = MSG[`RT];	// 写入数据初始状态
		M_WE = `sw | `sb | `sh;	// 写使能信号, 多条指令用 | 连接
		
		if (`sw)
		begin
			M_WD = MSG[`RT];
			BE = 4'b1111;	// 写入整个字
		end
		else if(`sb)
		begin
			M_WD = {{4{M_WD[7:0]}}};
			case (pst)
				2'b00 : BE = 4'b0001;
				2'b01 : BE = 4'b0010;
				2'b10 : BE = 4'b0100;
				2'b11 : BE = 4'b1000;
			endcase
		end
		else if (`sh)
		begin
			M_WD = {{2{M_WD[15:0]}}};
			if (pst[1] == 1'b0)
				BE = 4'b0011;
			else
				BE = 4'b1100;
		end
		else
			BE = 4'b0000;
		// 若是sb等可以尝试，将MSG接入dm, 在dm部件中case(addr[1:0])
	
	end
	
	assign be = BE;
	
	dm mdm(
					.Clk(clk),
					.Reset(reset),
					.WE(M_WE),
					.BE(be),
					.Addr(MSG[`AO]),
					.WD(M_WD),
					.PC(MSG[`pc]),
					.RD(M_RD)
		);
		
	dmext mdmext(
						.A(pst),
						.Din(M_RD),
						.MSG(MSG),
						.Dout(M_extRD)
	);
	
	// 更新
	always @(*)
	begin : mctrl
		// 该级产生新结果
		msg = MSG;
		msg[`DMRD] = M_extRD;
		
		// 写寄存器信号
		if (`lw | `lb | `lbu | `lh | `lhu)
		begin
			msg[`tarReg] = MSG[`rt];
			msg[`WD] = M_extRD;	// 从内存中读取数据
			msg[`grfWE] = 1'b1;
		end
		
		// Tnew
		msg[`tnew] = (MSG[`tnew] == 4'h0) ? 4'h0 : (MSG[`tnew] - 4'h1);
		
	end
	
endmodule
