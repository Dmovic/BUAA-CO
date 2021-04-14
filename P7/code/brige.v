`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:24:04 12/22/2020 
// Design Name: 
// Module Name:    brige 
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
module brige(
	input [31:0] PC,
	// instodo
	input [31:0] DMAddr,
	input [31:0] DMWrite,
	input DMWE,
	output [31:0] DMData,
	// tc0
	output [31:0] TC0Data,
	output [31:0] TC0Addr,
	output TC0WE,
	input [31:0] TC0Write,
	// tc1
	output [31:0] TC1Data, 
	output [31:0] TC1Addr,
	output TC1WE,
	input [31:0] TC1Write,
	// odm
	output [31:0] odmData,
	output [31:0] odmAddr,
	output odmWE,
	input [31:0] odmWrite
    );
	
	// 地址直通
	assign TC0Addr = DMAddr;
	assign TC1Addr = DMAddr;
	assign odmAddr = DMAddr;
	
	// 选择读设备
	assign DMData = (DMAddr >= 32'h0 && DMAddr <= 32'h2ffff) ? odmWrite :
						  (DMAddr >= 32'h7f00 && DMAddr <= 32'h7f0b) ? TC0Write :
						  (DMAddr >= 32'h7f10 && DMAddr <= 32'h7f1b) ? TC1Write :
						  32'h12345678;
	
	// 根据地址确定写使能
	assign odmWE = (DMAddr >= 32'h0 && DMAddr <= 32'h2ffff) ? 1'b1 :
						1'b0;
						
	assign TC0WE = (DMAddr >= 32'h7f00 && DMAddr <= 32'h7f0b) ? 1'b1 :
						1'b0;
						
	assign TC1WE = (DMAddr >= 32'h7f10 && DMAddr <= 32'h7f1b) ? 1'b1 :
						1'b0;
	
	// 数据直通
	/*
	assign TC0Data = DMData;
	assign TC1Data = DMData;
	assign odmData = DMData;
	*/
	
	/*
	assign TC0Data = odmWrite;
	assign TC1Data = odmWrite;
	assign odmData = odmWrite;
	*/
	
	assign TC0Write = DMWrite;
	assign TC1Write = DMWrite;
	assign odmWrite = DMWrite;

endmodule
