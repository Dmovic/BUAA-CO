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
	wire [31:0] M_RD;	// dm�ж�������, ��δ������չ	
	integer i;
	reg [3:0] BE;	// �ֽ�ʹ��
	wire [3:0] be;	// һ��Ҫ����?
	wire [1:0] pst;	// �洢λ��, �ֽ�ƫ��
	
	// M�����ɽ��
	wire [31:0] M_extRD;	// ������չ���
	
	assign M_addr = MSG[`AO];	// AO���ԼĴ�����else����
	assign instr = MSG[`instr];
	assign pst = M_addr[1:0];	// �洢�ľ���λ��
	
	// dm��ؿ����ź�
	always @(*)
	begin : dmctrl
		M_WD = MSG[`RT];	// д�����ݳ�ʼ״̬
		M_WE = `sw | `sb | `sh;	// дʹ���ź�, ����ָ���� | ����
		
		if (`sw)
		begin
			M_WD = MSG[`RT];
			BE = 4'b1111;	// д��������
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
		// ����sb�ȿ��Գ��ԣ���MSG����dm, ��dm������case(addr[1:0])
	
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
	
	// ����
	always @(*)
	begin : mctrl
		// �ü������½��
		msg = MSG;
		msg[`DMRD] = M_extRD;
		
		// д�Ĵ����ź�
		if (`lw | `lb | `lbu | `lh | `lhu)
		begin
			msg[`tarReg] = MSG[`rt];
			msg[`WD] = M_extRD;	// ���ڴ��ж�ȡ����
			msg[`grfWE] = 1'b1;
		end
		
		// Tnew
		msg[`tnew] = (MSG[`tnew] == 4'h0) ? 4'h0 : (MSG[`tnew] - 4'h1);
		
	end
	
endmodule
