`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:08:37 11/28/2020 
// Design Name: 
// Module Name:    rf 
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

module rf(
	input clk,
	input reset,
	input [`MAX-1:0] DMSG,
	input [`MAX-1:0] Wmsg,
	output reg[`MAX-1:0] msg
    );

	// D级临时输出信号
	wire [31:0] D_RD1;
	wire [31:0] D_RD2;
	
	// 写入信号都接入Wmsg
	grf my_grf(
					.Clk(clk),
					.Reset(reset),
					.WE(Wmsg[`grfWE]),
					.A1(DMSG[`rs]),
					.A2(DMSG[`rt]),
					.A3(Wmsg[`tarReg]),
					.WD(Wmsg[`WD]),
					.PC(Wmsg[`pc]),
					.RD1(D_RD1),
					.RD2(D_RD2)
	);
	
	// 更新
	always @(*)
	begin
		msg = DMSG;
		msg[`RS] = D_RD1;
		msg[`RT] = D_RD2;
	end

endmodule
