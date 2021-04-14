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
	
	// b ָ���ж�, cpu3_4
	wire signed [31:0] sgrs;	// �з���rs
	
	// D�����ɽ��
	reg [31:0] D_ext;	// ��չ��32λ���
	reg [31:0] D_npc;	// npc���
	reg D_branch;	// ��ǰ�Ƿ�Ϊ��ָ֧��
	
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
		// ��ʱ��˳��, ��4��jָ��
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
		else if (`jalr)
		begin
			//msg[`tarReg] = MSG[`rd];	// дrd�Ĵ���
			msg[`WD] = MSG[`pc] + 32'h8;	// �ӳٲ�
			msg[`grfWE] = 1'b1;	// дrd
		end
//	end
	
		// rsuse
//	always @(*)
//	begin : rsuse
		// ��D������Tuse_Tnew
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
		// ���� rtuse
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
		// ����Ŀ�ļĴ���
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
			msg[`tarReg] = 5'd31;	// д31�żĴ���
		end
		else
		begin
			msg[`tarReg] = 5'd0;
		end
//	end
	
	// tnew
//	always @(*)
//	begin : Tnew
		// ����tnew�ź�
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
	
	
	// md, �˳�ָ����ͣ
//	always @(*)
//	begin : md
		// ��ǰ�Ƿ�Ϊ�˳�ָ��
		// ����md�ź�
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
		
		// �ɱ�Ĵ���д��, ������ͣ
		msg[`vary] = 1'b0;
		
	end
	
endmodule
