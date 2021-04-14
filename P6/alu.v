`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:07:00 12/05/2020 
// Design Name: 
// Module Name:    alu 
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

module alu(
	input [`MAX-1:0] MSG,
	output [31:0] AO
    );

	wire [15:0] imm16;
	wire [31:0] ext32;
	wire [31:0] rs;
	wire [31:0] rt;
	wire [31:0] instr;
	wire [4:0] shamt;	// 指令的shamt位, 移位指令
	wire signed [31:0] sgrs;	// 有符号相关运算
	wire signed [31:0] sgrt;	// 有符号相关运算
	wire signed [31:0] sgext32;	// 有符号32位立即数
	
	// E级生成结果
	reg [31:0] ret; // ALU 计算结果

	
	assign imm16 = MSG[`imm16];	// 16位立即数
	assign ext32 = MSG[`ext32];	// 扩展后的32位立即数
	assign rs = MSG[`RS];	// RS寄存器的值
	assign rt = MSG[`RT];	// RT寄存器的值
	assign instr = MSG[`instr];
	////
	assign shamt = MSG[`shamt];
	assign sgrs = $signed(rs);
	assign sgrt = $signed(rt);
	assign sgext32 = $signed(ext32);
	
	// ALU
	always @(*)
	begin : ALU
		if (`addu) ret = rs + rt;
		else if (`subu) ret = rs - rt;
		else if (`ori) ret = rs | ext32;
		else if (`lui) ret = {imm16, {16'b0}};
		else if (`add) ret = rs + rt;	// 暂时不考虑溢出
		else if (`sub) ret = rs - rt;	// 暂时不考虑溢出
		else if (`sll) ret = rt << shamt;	// 新增截取shamt段
		else if (`srl) ret = rt >> shamt;
		else if (`sra) ret = sgrt >>> shamt;
		else if (`sllv) ret = sgrt << (rs[4:0]);	// 只取低5位, 高位舍去
		else if (`srlv) ret = sgrt >> (rs[4:0]);
		else if (`srav) ret = sgrt >>> (rs[4:0]);
		else if (`AND) ret = rs & rt;
		else if (`OR) ret = rs | rt;
		else if (`XOR) ret = rs ^ rt;
		else if (`NOR) ret = ~ (rs | rt);
		else if (`addi) ret = rs + sgext32;	// 暂时不考虑溢出
		else if (`addiu) ret = rs + sgext32;	// 这里立即数运算为 0 扩展
		else if (`andi) ret = rs & ext32;
		else if (`xori) ret = rs ^ ext32;
		// slt等指令
		else if (`slt)
		begin
			if (sgrs < sgrt)
				ret = 32'h1;
			else
				ret = 32'h0;
		end
		else if (`slti)
		begin
			if (sgrs < sgext32)
				ret = 32'h1;
			else
				ret = 32'h0;
		end
		else if (`sltiu)
		begin
			if (rs < ext32)
				ret = 32'h1;
			else
				ret = 32'h0;
		end
		else if (`sltu)
		begin
			if (rs < rt)
				ret = 32'h1;
			else
				ret = 32'h0;
		end
		
		else ret = rs + ext32;	// store指令 rs + ext32; 符号数 ? 
	end

	assign AO = ret;

endmodule
