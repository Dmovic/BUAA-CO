`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:31:53 12/06/2020 
// Design Name: 
// Module Name:    multdiv 
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

module multdiv(
	input clk,
	input reset,
	input [`MAX-1:0] MSG,
	output reg[31:0] HI,
	output reg[31:0] LO,
	output busy
    );

	wire [31:0] instr;
	reg start = 1'b0;	// 是否为乘除指令
	reg [31:0] top = 32'h0;	// 指令执行所需要的周期
	reg [31:0] cycle = 32'h0;	// 记录已经执行的时间
	wire [31:0] rs;	// rs值
	wire [31:0] rt;	// rt 值
	wire signed [31:0] sgrs;	// 有符号数rs
	wire signed [31:0] sgrt;	// 有符号数rt
	
	// 返回
	reg [31:0] high = 32'h0;	// HI 寄存器的值
	reg [31:0] low = 32'h0;	// LO 寄存器的值
	
	assign instr = MSG[`instr];
	assign rs = MSG[`RS];
	assign rt = MSG[`RT];	// 截取rs值
	
	assign sgrs = $signed(rs);	// 有符号数rs
	assign sgrt = $signed(rt);
	
	always @(*)
	begin : mult_div;
		if (`mult)
		begin : mult
			reg signed[63:0] ans;	// 有符号乘
			reg signed[31:0] a;
			reg signed[31:0] b;
			
			a = $signed(rs);
			b = $signed(rt);
			
			start = 1'b1;	// 启动信号
			top = 32'h5;	// 5周期完成
			
			ans = a * b;
			low = ans[31:0];
			high = ans[63:32];
		end
		else if (`multu)
		begin : multu
			reg [63:0] ans;	// 无符号乘
			reg [31:0] a;
			reg [31:0] b;
			
			a = rs;
			b = rt;
			
			start = 1'b1;
			top = 32'h5;
			
			ans = a * b;
			low = ans[31:0];
			high = ans[63:32];
		end
		else if (`div)
		begin : div
			reg signed[31:0] quotient;	// 除数, 商, 有符号除
			reg signed[31:0] remainder;	// 余数
			reg signed[31:0] a;
			reg signed[31:0] b;
			
			a = $signed(rs);
			b = $signed(rt);
			
			start = 1'b1;
			top = 32'd10;	// 10 除法周期
			
			quotient = a / b;
			remainder = a % b;	// 高32位余数
			low = quotient;	// 低除数
			high = remainder;
		end
		else if (`divu)
		begin : divu	// 无符号除
			reg [31:0] quotient;	// 除数, 商
			reg [31:0] remainder;	// 余数
			reg [31:0] a;
			reg [31:0] b;
			
			a = rs;
			b = rt;
			
			start = 1'b1;
			top = 32'd10;
			
			low = a / b;
			high = a % b;
			
		end
		else if (`mthi)
		begin
			start = 1'b0;	// 不启动乘除, 只是将rs移至high
			top = 32'd0;	// 无需乘除运算
			high = rs;
		end
		else if (`mtlo)
		begin
			start = 1'b0;	// 不启动
			top = 32'd0;	// 不乘除
			low = rs;
		end
		else if (`madd)
		begin : madd
			reg signed[63:0] ans;
			reg signed[63:0] sum;
			reg signed[31:0] a;
			reg signed[31:0] b;
			
			a = $signed(rs);
			b = $signed(rt);
			
			ans = a * b;
			sum = $signed({high, low});
			sum = sum + ans;
			
			low = sum[31:0];
			high = sum[63:32];
		end
		else if (`msub)
		begin : msub
			reg signed[63:0] ans;
			reg signed[63:0] sum;
			reg signed[31:0] a;
			reg signed[31:0] b;
			
			a = $signed(rs);
			b = $signed(rt);
			
			ans = a * b;
			sum = $signed({high, low});
			sum = sum - ans;
			
			low = sum[31:0];
			high = sum[63:32];
		end
		else if (`maddu)	// 无符号maddu
		begin : maddu
			reg [63:0] ans;
			reg [63:0] sum;
			reg [31:0] a;
			reg [31:0] b;
			
			a = rs;
			b = rt;
			
			ans = a * b;
			sum = {high, low};
			sum = sum + ans;
			
			low = sum[31:0];
			high = sum[63:32];
		end
		else if (`msubu)
		begin : msubu
			reg [63:0] ans;
			reg [63:0] sum;
			reg [31:0] a;
			reg [31:0] b;
			
			a = rs;
			b = rt;
			
			ans = a * b;
			sum = {high, low};
			sum = sum - ans;
			
			low = sum[31:0];
			high = sum[63:32];
		end
		
		else
		begin
			// 非乘除法指令
			start = 1'b0;	// 启动信号置0
			top = 32'h0;	// 计算周期置0
		end
		
	end
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			// 不能把 high 和 low 清零 ?
			start <= 1'b0;
			cycle <= 32'h0;
			LO <= 32'h0;
			HI <= 32'h0;
		end
		else
		begin
			LO <= low;
			HI <= high;
			if (start)
				cycle <= top;	// 初始化进入
			else if (cycle > 0)
				cycle <= cycle - 32'h1;
		end
	end
	
	assign busy = (cycle != 32'h0) | (start != 1'b0);	// 真实busy应该或上start

endmodule
