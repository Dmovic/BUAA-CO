`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:06:47 12/23/2020 
// Design Name: 
// Module Name:    mips 
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
module mips(
	input clk,
	input reset,
	// 
	input interrupt,
	output [31:0] addr
    );

	wire tc0intreq;
	wire tc1intreq;
	wire tc0we;
	wire tc1we;
	wire odmwe;
	wire [5:0]HWInt;
	wire [31:0] tc0data, tc0write, tc0addr;
	wire [31:0] tc1data, tc1write, tc1addr;
	wire [31:0] odmdata, odmwrite, odmaddr;
	wire [31:0] cpu_pc;
	wire [31:0] BgData, BgWrite, BgAddr;
	wire BgWE;
	
	assign HWInt[0] = tc0intreq;
	assign HWInt[1] = tc1intreq;
	assign HWInt[2] = interrupt;
	assign HWInt[5:3] = 3'b000;
	
	cpu my_cpu(
					.clk(clk),
					.reset(reset),
					.HWInt(HWInt),
					.BgData(BgData),
					.DMAddr(BgAddr),
					.PC(cpu_pc),
					.DMData(BgWrite),
					.MacroPC(addr),
					.DMWE(BgWE)
	);
	
	brige my_bridge(
							.PC(cpu_pc),
							.DMAddr(BgAddr),
							.DMWrite(BgWrite),
							.DMWE(BgWE),
							.DMData(BgData),
							
							.TC0Data(tc0data),
							.TC0Addr(tc0addr),
							.TC0WE(tc0we),
							.TC0Write(tc0write),
							
							.TC1Data(tc1data),
							.TC1Addr(tc1addr),
							.TC1WE(tc1we),
							.TC1Write(tc1write),
							
							.odmData(odmdata),
							.odmAddr(odmaddr),
							.odmWE(odmwe),
							.odmWrite(odmwrite)
		
	);
	
	dev my_dev(
						.clk(clk),
						.reset(reset),
						
						.tc0addr(tc0addr),
						.tc0we(tc0we),
						.tc0write(tc0write),
						.tc0data(tc0data),
						.tc0intreq(tc0intreq),
						
						.tc1addr(tc1addr),
						.tc1we(tc1we),
						.tc1write(tc1write),
						.tc1data(tc1data),
						.tc1intreq(tc1intreq),
						
						.odmwrite(odmwrite),
						.odmaddr(odmaddr),
						.odmwe(odmwe),
						.odmdata(odmdata)
	);

endmodule
