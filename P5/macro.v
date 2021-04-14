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


/* ָ���ж���� */
// ��ȡָ����Ϣ
`define funcAddu 6'b10_0001
`define funcSubu 6'b10_0011
`define funcJr 6'b00_1000

`define RType 6'b00_0000
`define opOri 6'b00_1101
`define opLw 6'b10_0011
`define opSw 6'b10_1011
`define opBeq 6'b00_0100
`define opLui 6'b00_1111
`define opJal 6'b00_0011
`define opJ 6'b00_0010

// �жϵ�ǰָ��
`define addu (instr[`func] == `funcAddu && instr[`op] == `RType)
`define subu (instr[`func] == `funcSubu && instr[`op] == `RType)
`define jr (instr[`func] == `funcJr && instr[`op] == `RType)

//// ����ΪR��ָ��, ȡfunc��
`define ori (instr[`op] == `opOri)
`define lw (instr[`op] == `opLw)
`define sw (instr[`op] == `opSw)
`define beq (instr[`op] == `opBeq)
`define lui (instr[`op] == `opLui)
`define jal (instr[`op] == `opJal)
`define j (instr[`op] == `opJ)