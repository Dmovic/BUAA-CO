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
	
	// D级生成结果
	reg [31:0] D_ext;	// 扩展后32位结果
	reg [31:0] D_npc;	// npc结果
	reg D_branch;	// 当前是否为分支指令
	
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
	
	// Tuse_Tnew 以及控制信号
	always @(*)
	begin : dctrl
		// 该级新产生的结果
		msg = MSG;
		msg[`ext32] = D_ext;
		msg[`branch] = D_branch;
		msg[`npc] = D_npc;
		
		// 写寄存器信号
		if (`jal)
		begin
			msg[`tarReg] = 5'd31;	// $31寄存器
			msg[`WD] = MSG[`pc] + 32'h8;	// 延迟槽
			msg[`grfWE] = 1'b1;	// 写$31
		end
		
		// 在D级生成Tuse_Tnew
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
