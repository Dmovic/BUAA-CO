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
	reg start = 1'b0;	// �Ƿ�Ϊ�˳�ָ��
	reg [31:0] top = 32'h0;	// ָ��ִ������Ҫ������
	reg [31:0] cycle = 32'h0;	// ��¼�Ѿ�ִ�е�ʱ��
	wire [31:0] rs;	// rsֵ
	wire [31:0] rt;	// rt ֵ
	wire signed [31:0] sgrs;	// �з�����rs
	wire signed [31:0] sgrt;	// �з�����rt
	
	// ����
	reg [31:0] high = 32'h0;	// HI �Ĵ�����ֵ
	reg [31:0] low = 32'h0;	// LO �Ĵ�����ֵ
	
	assign instr = MSG[`instr];
	assign rs = MSG[`RS];
	assign rt = MSG[`RT];	// ��ȡrsֵ
	
	assign sgrs = $signed(rs);	// �з�����rs
	assign sgrt = $signed(rt);
	
	always @(*)
	begin : mult_div;
		if (`mult)
		begin : mult
			reg signed[63:0] ans;	// �з��ų�
			reg signed[31:0] a;
			reg signed[31:0] b;
			
			a = $signed(rs);
			b = $signed(rt);
			
			start = 1'b1;	// �����ź�
			top = 32'h5;	// 5�������
			
			ans = a * b;
			low = ans[31:0];
			high = ans[63:32];
		end
		else if (`multu)
		begin : multu
			reg [63:0] ans;	// �޷��ų�
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
			reg signed[31:0] quotient;	// ����, ��, �з��ų�
			reg signed[31:0] remainder;	// ����
			reg signed[31:0] a;
			reg signed[31:0] b;
			
			a = $signed(rs);
			b = $signed(rt);
			
			start = 1'b1;
			top = 32'd10;	// 10 ��������
			
			quotient = a / b;
			remainder = a % b;	// ��32λ����
			low = quotient;	// �ͳ���
			high = remainder;
		end
		else if (`divu)
		begin : divu	// �޷��ų�
			reg [31:0] quotient;	// ����, ��
			reg [31:0] remainder;	// ����
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
			start = 1'b0;	// �������˳�, ֻ�ǽ�rs����high
			top = 32'd0;	// ����˳�����
			high = rs;
		end
		else if (`mtlo)
		begin
			start = 1'b0;	// ������
			top = 32'd0;	// ���˳�
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
		else if (`maddu)	// �޷���maddu
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
			// �ǳ˳���ָ��
			start = 1'b0;	// �����ź���0
			top = 32'h0;	// ����������0
		end
		
	end
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			// ���ܰ� high �� low ���� ?
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
				cycle <= top;	// ��ʼ������
			else if (cycle > 0)
				cycle <= cycle - 32'h1;
		end
	end
	
	assign busy = (cycle != 32'h0) | (start != 1'b0);	// ��ʵbusyӦ�û���start

endmodule
