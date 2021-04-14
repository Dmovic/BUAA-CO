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
	wire [31:0] instr;	// Ҫ�ж�ָ��
	reg M_WE;
	reg [31:0] M_WD;	// д�������
	integer i;
	
	// M�����ɽ��
	wire [31:0] M_RD;
	
	assign M_addr = MSG[`AO];	// AO���ԼĴ�����else����
	assign instr = MSG[`instr];
	
	// dm��ؿ����ź�
	always @(*)
	begin : dmctrl
		M_WE = `sw;	// дʹ���ź�, ����ָ���� | ����
		
		if (`sw)
		begin
			M_WD = MSG[`RT];
		end
		
		// ����sb�ȿ��Գ��ԣ���MSG����dm, ��dm������case(addr[1:0])
	
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
	
	// ����
	always @(*)
	begin : mctrl
		// �ü������½��
		msg = MSG;
		
		// д�Ĵ����ź�
		if (`lw)
		begin
			msg[`tarReg] = MSG[`rt];
			msg[`WD] = M_RD;	// ���ڴ��ж�ȡ����
			msg[`grfWE] = 1'b1;
		end
		
		// Tnew
		msg[`tnew] = (MSG[`tnew] == 4'h0) ? 4'h0 : (MSG[`tnew] - 4'h1);
		
	end
	
endmodule
