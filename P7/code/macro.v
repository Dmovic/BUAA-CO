`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:56:00 12/02/2020 
// Design Name: 
// Module Name:    macro 
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

/* msg��Ϣ�� */
`define MAX 400

/* ָ����Ϣ */
`define instr 31 : 0
`define op 31 : 26
`define rs 25 : 21
`define rt 20 : 16
`define rd 15 : 11
`define shamt 10 : 6
`define func 5 : 0

`define imm16 15 : 0
`define imm26 25 : 0

/* ��ˮ��Ϣ */
`define pc 63 : 32	// pc��ֵ, 32
`define npc 95 : 64	// npc��ֵ, 32
`define branch 96		// ��ת��Ϣ�Ƿ���Ч, 1
`define RS 128 : 97	// rs �Ĵ�����ֵ, 32
`define RT 160 : 129	// rt �Ĵ�����ֵ, 32
`define AO 192 : 161	// ALU������, 32
`define ext32 224 : 193	// ��չ���32λ������, 32
`define grfWE 225	// grfдʹ��

/* д����ź�, ��ð����� */
`define tarReg 230 : 226	// Ŀ�ļĴ���
`define WD 262 : 231	// д�������

/* Tnew-Tuse ʱ��ģ��, ����ͳһȡ4λ */
`define rsuse 266 : 263
`define rtuse 270 : 267
`define tnew 274 : 271

// �˳����
`define busy 300	// �˳������Ƿ����ڽ���
`define md 301	// �Ƿ�Ϊ�˳�ָ��

// ����д
`define vary 302

`define DMRD 334 : 303

/* �쳣�ж� */
`define ExcCode 354 : 350
`define BusyEPC 355

// �쳣���Ƿ� 
`define Int 5'd0
`define AdEL 5'd4
`define AdES 5'd5
`define RI 5'd10
`define Ov 5'd12

/* ָ���ж���� */
// ��ȡָ����Ϣ
`define funcAddu 6'b10_0001
`define funcSubu 6'b10_0011
`define funcJr 6'b00_1000
`define funcAdd 6'b10_0000
`define funcSub 6'b10_0010

`define funcMult 6'b01_1000
`define funcMultu 6'b01_1001
`define funcDiv 6'b01_1010
`define funcDivu 6'b01_1011
// �汾3
`define funcSll 6'b00_0000
`define funcSrl 6'b00_0010
`define funcSra 6'b00_0011
`define funcSllv 6'b00_0100
`define funcSrlv 6'b00_0110
`define funcSrav 6'b00_0111
// �汾3_1
`define funcAnd 6'b10_0100
`define funcOr 6'b10_0101
`define funcXor 6'b10_0110
`define funcNor 6'b10_0111
// �汾3_3 slt��ָ��
`define funcSlt 6'b10_1010
`define funcSltu 6'b10_1011
// �汾3_5, ����jalr
`define funcJalr 6'b00_1001

// �汾3_6, mfhi��ָ��
`define funcMfhi 6'b01_0000
`define funcMflo 6'b01_0010
`define funcMthi 6'b01_0001
`define funcMtlo 6'b01_0011

// ����ΪR��ָ��func��Ϣ
`define RType 6'b00_0000
`define opOri 6'b00_1101
`define opLw 6'b10_0011
`define opSw 6'b10_1011
`define opBeq 6'b00_0100
`define opLui 6'b00_1111
`define opJal 6'b00_0011
`define opJ 6'b00_0010

`define opLb 6'b10_0000
`define opLbu 6'b10_0100
`define opLh 6'b10_0001
`define opLhu 6'b10_0101
`define opSh 6'b10_1001
`define opSb 6'b10_1000
// �汾3_2
`define opAddi 6'b00_1000
`define opAddiu 6'b00_1001
`define opAndi 6'b00_1100
`define opXori 6'b00_1110
// �汾3_3
`define opSlti 6'b00_1010
`define opSltiu 6'b00_1011
// �汾3_4
`define opBne 6'b00_0101
`define opBlez 6'b00_0110
`define opBgtz 6'b00_0111

//// ע������op��ͬ, ��rt��ͬ
`define opBltz 6'b00_0001
`define opBgez 6'b00_0001
//// 

// �жϵ�ǰָ��
`define addu (instr[`func] == `funcAddu && instr[`op] == `RType)
`define subu (instr[`func] == `funcSubu && instr[`op] == `RType)
`define jr (instr[`func] == `funcJr && instr[`op] == `RType)
`define add (instr[`func] == `funcAdd && instr[`op] == `RType)
`define sub (instr[`func] == `funcSub && instr[`op] == `RType)

`define mult (instr[`func] == `funcMult && instr[`op] == `RType)
`define multu (instr[`func] == `funcMultu && instr[`op] == `RType)
`define div (instr[`func] == `funcDiv && instr[`op] == `RType)
`define divu (instr[`func] == `funcDivu && instr[`op] == `RType)
// �汾3
`define sll (instr[`func] == `funcSll && instr[`op] == `RType)
`define srl (instr[`func] == `funcSrl && instr[`op] == `RType)
`define sra (instr[`func] == `funcSra && instr[`op] == `RType)
`define sllv (instr[`func] == `funcSllv && instr[`op] == `RType)
`define srlv (instr[`func] == `funcSrlv && instr[`op] == `RType)
`define srav (instr[`func] == `funcSrav && instr[`op] == `RType)
// �汾3_1
`define AND (instr[`func] == `funcAnd && instr[`op] == `RType)
`define OR (instr[`func] == `funcOr && instr[`op] == `RType)
`define XOR (instr[`func] == `funcXor && instr[`op] == `RType)
`define NOR (instr[`func] == `funcNor && instr[`op] == `RType)
// �汾3_3, slt��
`define slt (instr[`func] == `funcSlt && instr[`op] == `RType)
`define sltu (instr[`func] == `funcSltu && instr[`op] == `RType)
// �汾3_5, jalr
`define jalr (instr[`func] == `funcJalr && instr[`op] == `RType)

// �汾3_6, mfhi��
`define mfhi (instr[`func] == `funcMfhi && instr[`op] == `RType)
`define mflo (instr[`func] == `funcMflo && instr[`op] == `RType)
`define mthi (instr[`func] == `funcMthi && instr[`op] == `RType)
`define mtlo (instr[`func] == `funcMtlo && instr[`op] == `RType)

//// ����ΪR��ָ��, ȡfunc��
`define ori (instr[`op] == `opOri)
`define lw (instr[`op] == `opLw)
`define sw (instr[`op] == `opSw)
`define beq (instr[`op] == `opBeq)
`define lui (instr[`op] == `opLui)
`define jal (instr[`op] == `opJal)
`define j (instr[`op] == `opJ)

`define lb (instr[`op] == `opLb)
`define lbu (instr[`op] == `opLbu)
`define lh (instr[`op] == `opLh)
`define lhu (instr[`op] == `opLhu)
`define sh (instr[`op] == `opSh)
`define sb (instr[`op] == `opSb)
// �汾3_2
`define addi (instr[`op] == `opAddi)
`define addiu (instr[`op] == `opAddiu)
`define andi (instr[`op] == `opAndi)
`define xori (instr[`op] == `opXori)
// �汾3_3
`define slti (instr[`op] == `opSlti)
`define sltiu (instr[`op] == `opSltiu)

// �汾3_4
`define bne (instr[`op] == `opBne)
`define blez (instr[`op] == `opBlez)
`define bgtz (instr[`op] == `opBgtz)

//// ע��rt��ͬ
`define bltz (instr[`op] == `opBltz && instr[`rt] == 6'h0)
`define bgez (instr[`op] == `opBgez && instr[`rt] == 6'h1)
////

`define opMadd 6'b01_1100
`define madd (instr[`op] == `opMadd && instr[`func] == 6'h0)
`define opMsub 6'b01_1100
`define msub (instr[`op] == `opMsub && instr[`func] == 6'b00_0100)

`define eret (instr == 32'b010000_1_000_0000_0000_0000_011000)
`define eret_code (32'b010000_1_000_0000_0000_0000_011000)
// ��Щ��11'b0
`define mtc0 (instr[31:21] == 11'b010000_00100 && instr[10:3] == 8'b0000_0000)
`define mfc0 (instr[31:21] == 11'b010000_00000 && instr[10:3] == 8'b0000_0000)
`define nop (instr == 32'b0)

/* CP0�Ĵ��� */
// cause �Ĵ���
`define IP 15 : 10
`define Exc 6 : 2
`define BD 31

`define regSR 5'd12
`define regCAUSE 5'd13
`define regEPC 5'd14
`define regPrID 5'd15

// SR �Ĵ���
`define IM 15 : 10
`define EXL 1
`define IE 0

