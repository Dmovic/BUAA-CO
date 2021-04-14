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
	output [31:0] AO,
	output reg [4:0] ExcCode
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
		// else if (`add) ret = rs + rt;	// 暂时不考虑溢出
		else if (`add)
		begin : add
			reg [32:0] rs33;
			reg [32:0] rt33;
			reg [32:0] add33;
			
			rs33 = {rs[31], rs};
			rt33 = {rt[31], rt};
			add33 = rs33 + rt33;
			
			// 溢出
			if (add33[32] != add33[31])
			begin
				ExcCode = `Ov;
				ret = 32'h12345678;
			end
			else
			begin
				ExcCode = 5'b0;
				ret = add33[31:0];
			end
		end
		// else if (`sub) ret = rs - rt;	// 暂时不考虑溢出
		else if (`sub)
		begin : sub
			reg [32:0] rs33;
			reg [32:0] rt33;
			reg [32:0] sub33;
			
			rs33 = {rs[31], rs};
			rt33 = {rt[31], rt};
			sub33 = rs33 - rt33;
			
			// 溢出
			if (sub33[32] != sub33[31])
			begin
				ExcCode = `Ov;
				ret = 32'h12345678;	// debug
			end
			else
			begin
				ExcCode = 5'b0;
				ret = sub33[31:0];
			end
		end
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
		// else if (`addi) ret = rs + sgext32;	// 暂时不考虑溢出
		else if (`addi)
		begin : addi
			reg [32:0] rs33;
			reg [32:0] rt33;
			reg [32:0] addi33;
			
			rs33 = {rs[31], rs};
			rt33 = {rt[31], rt};
			addi33 = rs33 + rt33;
			
			if (addi33[32] != addi33[31])
			begin
				ExcCode = `Ov;
				ret = 32'h12345678;
			end
			else
			begin
				ExcCode = 5'b0;
				ret = addi33[31:0];
			end
		end
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
		else if (`sw | `sh | `sb)
		begin : store
			reg [32:0] rs33;
			reg [32:0] ext33;
			reg [32:0] store33;
			reg st_dm;
			reg st_time1;
			reg st_time2;
			
			
			rs33 = {rs[31], rs};
			//rs33 = rs;
			ext33 = {ext32[31], ext32};
			store33 = rs33 + ext33;
			
			st_dm = (store33[31:0] >= 32'h0 && store33[31:0] <= 32'h2ffff);
			st_time1 = (store33[31:0] >= 32'h7f00 && store33[31:0] <= 32'h7f07);
			st_time2 = (store33[31:0] >= 32'h7f10 && store33[31:0] <= 32'h7f17);
			
			if (store33[32] != store33[31])
			begin
				ExcCode = `AdES;
				ret = 32'h12345678;
			end
			else if (!(st_dm | st_time1 | st_time2))
			begin
				ExcCode = `AdES;
				ret = 32'h12345678;
			end
			else if ((`sh | `sb) && (st_time1 | st_time2))
			begin
				ExcCode = `AdES;
			end
			else if (`sh && store33[0] != 1'b0)
				ExcCode = `AdES;
			else if (`sw && store33[1:0] != 2'b0)
				ExcCode = `AdES;
			else
			begin
				ExcCode = 5'b0;
				ret = store33[31:0];
			end
		end
		else if (`lb | `lbu | `lh | `lhu | `lw)
		begin : load
			reg [32:0] rs33;
			reg [32:0] ext33;
			reg [32:0] load33;
			reg ld_dm;
			reg ld_time1;
			reg ld_time2;
			
			rs33 = {rs[31] ,rs};
			ext33 = {ext32[31], ext32};
			load33 = rs33 + ext33;
			
			ld_dm = (load33[31:0] >= 32'h0 && load33[31:0] <= 32'h2ffff);
			ld_time1 = (load33[31:0] >= 32'h7f00 && load33[31:0] <= 32'h7f07);
			ld_time2 = (load33[31:0] >= 32'h7f10 && load33[31:0] <= 32'h7f17);
			
			if (load33[32] != load33[31])
			begin
				ExcCode = `AdEL;
				ret = 32'h12345678;
			end
			else if (!(ld_dm | ld_time1 | ld_time2))
			begin
				ExcCode = `AdEL;
				ret = 32'h12345678;
			end
			else if (`lw && load33[1:0] != 2'b0)
			begin
				ExcCode = `AdEL;
				ret = 32'h12345678;
			end
			else if (`lh | `lhu && load33[0] != 1'b0)
			begin
				ExcCode = `AdEL;
				ret = 32'h12345678;
			end
			else
			begin
				ExcCode = 5'b0;
				ret = load33[31:0];
			end
		end
		
		else ret = rs + ext32;	//
	end

	assign AO = ret;

endmodule
