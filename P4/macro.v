`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:08:36 11/18/2020 
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
`define order 2'b00
`define NPCBEQ 2'b01
`define NPCJAL 2'b10
`define NPCJR 2'b11

// alu
`define AND 3'b000
`define OR 3'b001
`define ADD 3'b010
`define LUI_SHIFT 3'b011
`define SUB 3'b110

// ext
`define ZEXT 1'b0
`define SEXT 1'b1

//ctrl
`define ADDU 6'b10_0001
`define SUBU 6'b10_0011
`define JR 6'b00_1000
// 以上为R型指令, 取func段
`define ORI 6'b00_1101
`define LW 6'b10_0011
`define SW 6'b10_1011
`define BEQ 6'b00_0100
`define LUI 6'b00_1111
`define JAL 6'b00_0011

// mux
`define Ra 5'h1f

`define A3SelRd 2'b00
`define A3SelRt 2'b01
`define A3SelRa 2'b10

`define WDSelALU 2'b00
`define WDSelDM 2'b01
`define WDSelNPC 2'b10

`define BSelGRF 1'b0
`define BSelEXT 1'b1