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
	input [31:0] EPC,
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
	begin
		D_branch = (`beq & (MSG[`RS] == MSG[`RT])) | 
							`j |
							`jal |
							`jr |
							(`bne & (MSG[`RS] != MSG[`RT])) |
							(`blez & (sgrs <= $signed(32'h0))) |
							(`bgtz & (sgrs > $signed(32'h0))) | 
							(`bltz & (sgrs < $signed(32'h0))) |
							(`bgez & (sgrs >= $signed(32'h0))) |
							`jalr;	// 按时间顺序, 共4条j指令
		
		D_npc = (`beq & (MSG[`RS] == MSG[`RT])) |
				  (`bne & (MSG[`RS] != MSG[`RT])) |
				  (`blez & (sgrs <= $signed(32'h0))) |
				  (`bgtz & (sgrs > $signed(32'h0))) |
				  (`bltz & (sgrs < $signed(32'h0))) |
				  (`bgez & (sgrs >= $signed(32'h0)))
				  ? ({D_ext[29:0], {2'b0}} + D_pc4) :
				  
						(`j | `jal) ? ({D_pc[31:28], MSG[`imm26], {2'b0}}) :
						
						(`jr | `jalr) ? MSG[`RS] :
						
						(`eret) ? EPC :
						
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
		else if (`jalr)
		begin
			msg[`tarReg] = MSG[`rd];	// 写rd寄存器
			msg[`WD] = MSG[`pc] + 32'h8;	// 延迟槽
			msg[`grfWE] = 1'b1;	// 写rd
		end
		
		// 在D级生成Tuse_Tnew
		msg[`rsuse] = (`beq | `jr |
							`bne | `blez | `bgtz | `bltz | `bgez |
							`jalr) ? 4'h0 :
		
						  (`addu | `subu | `ori | `add | `sub | 
						  `sw | `sb | `sh | 
						  `lw | `lb | `lbu | `lh | `lhu |
						  `sllv | `srlv | `srav |
						  `AND | `OR | `XOR | `NOR |
						  `addi | `addiu | `andi | `xori |
						  `slt | `slti | `sltiu | `sltu |
						  `mult | `multu | `div | `divu |
						  `mthi | `mtlo |
						  `madd | `msub) ? 4'h1 :
						  
						  4'hf;
						  
		msg[`rtuse] = (`beq | `bne) ? 4'h0 :
		
						  (`addu | `subu | `add | `sub | 
						  `sll | `srl | `sra | `sllv | `srlv | `srav |
						  `AND | `OR | `XOR | `NOR |
						  `slt | `sltu |
						  `mult | `multu | `div | `divu |
						  `madd | `msub) ? 4'h1 :
						  
						  (`sw | `sb | `sh) ? 4'h2 :
						  4'hf;
						  
		msg[`tarReg] = (`addu | `subu | `add | `sub | 
							 `sll | `srl | `sra | `sllv | `srlv | `srav |
							 `AND | `OR | `XOR | `NOR |
							 `slt | `sltu |
							 `jalr |
							 `mfhi | `mflo) ? msg[`rd] :
							 
							(`ori | `lui |
							`lw | `lb | `lbu | `lh | `lhu |
							`addi | `addiu | `andi | `xori |
							`slti | `sltiu) ? msg[`rt] :
							
							(`jal) ? 5'd31 :
							
							5'd0;
							
		msg[`tnew] = (`lw | `lb | `lbu | `lh | `lhu) ? 4'h3 :
		
						 (`addu | `subu | `ori | `lui | `add | `sub |
						 `sll | `srl | `sra | `sllv | `srlv | `srav |
						 `AND | `OR | `XOR | `NOR |
						 `addi | `addiu | `andi | `xori |
						 `slt | `slti | `sltiu | `sltu |
						 `mfhi | `mflo) ? 4'h2 :
						 
						 (`jal | `jalr) ? 4'h1 :
						 
						 4'h0;
		
		// 当前是否为乘除指令
		msg[`md] = `mult | `multu | `div | `divu |
					  `mfhi | `mflo |
					  `mthi | `mtlo |
					  `madd | `msub;
		
		// 可变寄存器写入, 用于暂停
		msg[`vary] = 1'b0;
		
		// 当前是写EPC指令, BusyEPC
		msg[`BusyEPC] = `mtc0;
		
		if (!(`beq | `bne | `blez | `bgtz | `bltz | `bgez |
				`jr | `jalr | `j | `jal |
				`mthi | `mtlo | `mfhi | `mflo |
				`mult | `multu | `div | `divu |
				`AND | `OR | `XOR | `NOR |
				`sra | `sll | `srl | `sllv | `srlv | `srav |
				`slt | `sltu |
				`add | `sub | `addu | `subu |
				`addi | `addiu | `andi | `xori | `ori |
				`slti | `sltiu |
				`lui |
				`mfc0 | `mtc0 | `eret |
				`nop |
				`sw | `sh | `sb |
				`lb | `lbu | `lh | `lhu | `lw))
		begin
			msg[`ExcCode] = `RI;
			msg[`instr] = 32'b0;
		end
		
	end
	
endmodule
