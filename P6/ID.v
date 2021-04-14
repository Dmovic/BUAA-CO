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
	
	// b 指令判断, cpu3_4
	wire signed [31:0] sgrs;	// 有符号rs
	
	// D级生成结果
	reg [31:0] D_ext;	// 扩展后32位结果
	reg [31:0] D_npc;	// npc结果
	reg D_branch;	// 当前是否为分支指令
	
//	wire branch;
	reg test;
	
	assign instr = MSG[`instr];
	assign D_pc = MSG[`pc];
	assign D_pc4 = D_pc + 32'h4;
	
	// cpu3_4
	assign sgrs = $signed(MSG[`RS]);

	// EXT
	always @(*)
	begin
		if (`ori | `andi | `xori)
			D_ext = {{16'b0}, instr[`imm16]};
		else
			D_ext = {{16{instr[15]}}, instr[`imm16]};
	end


	// npc
	always @(*)
	begin : branch
		// D_branch
		// 按时间顺序, 共4条j指令
		if (
				 (`beq & (MSG[`RS] == MSG[`RT])) |
				 `j | `jal | `jr | `jalr |
				 (`bne & (MSG[`RS] != MSG[`RT] )) |
				 (`blez & (sgrs <= $signed(32'h0))) |
				 (`bgtz & (sgrs > $signed(32'h0))) |
				 (`bltz & (sgrs < $signed(32'h0))) |
				 (`bgez & (sgrs >= $signed(32'h0))) 
		)
		begin
			D_branch = 1'b1;
			test = 1'b1;
		end
		else
		begin
			D_branch = 1'b0;
			test = 1'b0;
		end
		
//		D_npc = msg[`npc];
//		D_branch = msg[`branch];
	end
	
	// npc
	always @(*)
	begin : npc
		// D_npc
		if (
				(`beq & (MSG[`RS] == MSG[`RT])) |
				(`bne & (MSG[`RS] != MSG[`RT])) |
				(`blez & (sgrs <= $signed(32'h0))) |
				(`bgtz & (sgrs > $signed(32'h0))) |
				(`bltz & (sgrs < $signed(32'h0))) |
				(`bgez & (sgrs >= $signed(32'h0))) 
		)
		begin
			D_npc = {D_ext[29:0], 2'b0} + D_pc4;
		end
		else if (`j | `jal)
		begin
			D_npc = {D_pc[31:28], MSG[`imm26], {2'b0}};
		end
		else if (`jr | `jalr)
		begin
			D_npc = MSG[`RS];
		end
		else
		begin
			D_npc = 32'hffff_eeee;	// 
		end
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
		else if (`jalr)
		begin
			//msg[`tarReg] = MSG[`rd];	// 写rd寄存器
			msg[`WD] = MSG[`pc] + 32'h8;	// 延迟槽
			msg[`grfWE] = 1'b1;	// 写rd
		end
//	end
	
		// rsuse
//	always @(*)
//	begin : rsuse
		// 在D级生成Tuse_Tnew
		if (`beq | `jr | `bne | `blez | `bgtz | `bltz | `bgez | `jalr)
		begin
			msg[`rsuse] = 4'h0;
		end
		else if (
					`addu | `subu | `ori | `add | `sub |
					`sw | `sb | `sh | 
					`lw | `lb | `lbu | `lh | `lhu |
					`sllv | `srlv | `srav |
					`AND | `OR | `XOR | `NOR |
					`addi | `addiu | `andi | `xori |
					`slt | `slti | `sltiu | `sltu |
					`mult | `multu | `div | `divu |
					`mthi | `mtlo |
					`madd | `msub | `maddu | `msubu
		)
		begin
			msg[`rsuse] = 4'h1;
		end
		else
		begin
			msg[`rsuse] = 4'hf;
		end
//	end
	
	// rtuse
//	always @(*)
//	begin : rtuse
		// 生成 rtuse
		if (`beq | `bne)
		begin
			msg[`rtuse] = 4'h0;
		end
		else if (
						  `addu | `subu | `add | `sub | 
						  `sll | `srl | `sra | `sllv | `srlv | `srav |
						  `AND | `OR | `XOR | `NOR |
						  `slt | `sltu |
						  `mult | `multu | `div | `divu |
						  `madd | `msub | `maddu | `msubu
		)
		begin
			msg[`rtuse] = 4'h1;
		end
		else if (`sw | `sb | `sh)
		begin
			msg[`rtuse] = 4'h2;
		end
		else
		begin
			msg[`rtuse] = 4'hf;
		end
//	end
	
	// tarReg
//	always @(*)
//	begin : tarRegister
		// 生成目的寄存器
		if (
				 `addu | `subu | `add | `sub | 
				 `sll | `srl | `sra | `sllv | `srlv | `srav |
				 `AND | `OR | `XOR | `NOR |
				 `slt | `sltu |
				 `jalr |
				 `mfhi | `mflo
		)
		begin
			msg[`tarReg] = msg[`rd];
		end
		else if (
							`ori | `lui |
							`lw | `lb | `lbu | `lh | `lhu |
							`addi | `addiu | `andi | `xori |
							`slti | `sltiu
		)
		begin
			msg[`tarReg] = msg[`rt];
		end
		else if (`jal)
		begin
			msg[`tarReg] = 5'd31;	// 写31号寄存器
		end
		else
		begin
			msg[`tarReg] = 5'd0;
		end
//	end
	
	// tnew
//	always @(*)
//	begin : Tnew
		// 生成tnew信号
		if (
				`lw | `lb | `lbu | `lh | `lhu
		)
		begin
			msg[`tnew] = 4'h3;
		end
		else if (
						 `addu | `subu | `ori | `lui | `add | `sub |
						 `sll | `srl | `sra | `sllv | `srlv | `srav |
						 `AND | `OR | `XOR | `NOR |
						 `addi | `addiu | `andi | `xori |
						 `slt | `slti | `sltiu | `sltu |
						 `mfhi | `mflo
		)
		begin
			msg[`tnew] = 4'h2;
		end
		else if (`jal | `jalr)
		begin
			msg[`tnew] = 4'h1;
		end
		else
		begin
			msg[`tnew] = 4'h0;
		end
//	end
	
	
	// md, 乘除指令暂停
//	always @(*)
//	begin : md
		// 当前是否为乘除指令
		// 生成md信号
		if (
					  `mult | `multu | `div | `divu |
					  `mfhi | `mflo |
					  `mthi | `mtlo |
					  `madd | `msub | `maddu | `msubu
		)
		begin
			msg[`md] = 1'b1;
		end
		else
		begin
			msg[`md] = 1'b0;
		end
		
		// 可变寄存器写入, 用于暂停
		msg[`vary] = 1'b0;
		
	end
	
endmodule
