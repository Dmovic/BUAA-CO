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

/* msg信息流 */
`define MAX 400

/* 指令信息 */
`define instr 31 : 0
`define op 31 : 26
`define rs 25 : 21
`define rt 20 : 16
`define rd 15 : 11
`define shamt 10 : 6
`define func 5 : 0

`define imm16 15 : 0
`define imm26 25 : 0

/* 流水信息 */
`define pc 63 : 32	// pc的值, 32
`define npc 95 : 64	// npc的值, 32
`define branch 96		// 跳转信息是否有效, 1
`define RS 128 : 97	// rs 寄存器的值, 32
`define RT 160 : 129	// rt 寄存器的值, 32
`define AO 192 : 161	// ALU计算结果, 32
`define ext32 224 : 193	// 扩展后的32位立即数, 32
`define grfWE 225	// grf写使能

/* 写相关信号, 与冒险相关 */
`define tarReg 230 : 226	// 目的寄存器
`define WD 262 : 231	// 写入的数据

/* Tnew-Tuse 时间模型, 这里统一取4位 */
`define rsuse 266 : 263
`define rtuse 270 : 267
`define tnew 274 : 271


/* 指令判断相关 */
// 截取指令信息
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

// 判断当前指令
`define addu (instr[`func] == `funcAddu && instr[`op] == `RType)
`define subu (instr[`func] == `funcSubu && instr[`op] == `RType)
`define jr (instr[`func] == `funcJr && instr[`op] == `RType)

//// 以上为R型指令, 取func段
`define ori (instr[`op] == `opOri)
`define lw (instr[`op] == `opLw)
`define sw (instr[`op] == `opSw)
`define beq (instr[`op] == `opBeq)
`define lui (instr[`op] == `opLui)
`define jal (instr[`op] == `opJal)
`define j (instr[`op] == `opJ)