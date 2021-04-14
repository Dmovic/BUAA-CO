`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:09:06 12/02/2020 
// Design Name: 
// Module Name:    ID 
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

module ID(
	input [`MAX-1:0] MSG,
	output reg[`MAX-1:0] msg
    );
	
	wire [31:0] instr;
	wire [31:0] D_pc;
	wire [31:0] D_pc4;	// pc + 4
	
	// D�����ɽ��
	reg [31:0] D_ext;	// ��չ��32λ���
	reg [31:0] D_npc;	// npc���
	reg D_branch;	// ��ǰ�Ƿ�Ϊ��ָ֧��
	
	assign instr = MSG[`instr];
	assign D_pc = MSG[`pc];
	assign D_pc4 = D_pc + 32'h4;

	// EXT
	always @(*)
	begin : ext
		if (`ori)
			D_ext = {{16'b0}, instr[`imm16]};
		else
			D_ext = {{16{instr[15]}}, instr[`imm16]};
	end

	// npc
	always @(*)
	begin : npc
		D_branch = (`beq & (MSG[`RS] == MSG[`RT])) | 
							`j |
							`jal |
							`jr;
		
		D_npc = (`beq & (MSG[`RS] == MSG[`RT])) ? ({D_ext[29:0], {2'b0}} + D_pc4) :
						(`j | `jal) ? ({D_pc[31:28], MSG[`imm26], {2'b0}}) :
						(`jr) ? MSG[`RS] :
						32'b0;
	end
	
	// Tuse_Tnew �Լ������ź�
	always @(*)
	begin : dctrl
		// �ü��²����Ľ��
		msg = MSG;
		msg[`ext32] = D_ext;
		msg[`branch] = D_branch;
		msg[`npc] = D_npc;
		
		// д�Ĵ����ź�
		if (`jal)
		begin
			msg[`tarReg] = 5'd31;	// $31�Ĵ���
			msg[`WD] = MSG[`pc] + 32'h8;	// �ӳٲ�
			msg[`grfWE] = 1'b1;	// д$31
		end
		
		// ��D������Tuse_Tnew
		msg[`rsuse] = (`beq | `jr) ? 4'h0 :
						  (`addu | `subu | `ori | `lw | `sw) ? 4'h1 :
						  4'hf;
						  
		msg[`rtuse] = (`beq) ? 4'h0 :
						  (`addu | `subu) ? 4'h1 :
						  (`sw) ? 4'h2 :
						  4'hf;
						  
		msg[`tarReg] = (`addu | `subu) ? msg[`rd] :
							(`ori | `lui | `lw) ? msg[`rt] :
							`jal ? 5'd31 :
							5'd0;
							
		msg[`tnew] = (`lw) ? 4'h3 :
						 (`addu | `subu | `ori | `lui) ? 4'h2 :
						 (`jal) ? 4'h1 :
						 4'h0;
	end
	
endmodule
