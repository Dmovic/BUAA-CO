`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:49:50 12/23/2020 
// Design Name: 
// Module Name:    CP0 
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

module CP0(
	input clk,
	input reset,
	input [5:0] HWInt,
	input [31:0] DIn,
	input [4:0] A,
	input We,
	input IntReq,
	input [`MAX-1:0] MSGF,
	input [`MAX-1:0] MSGD,
	input [`MAX-1:0] MSGE,
	input [`MAX-1:0] MSGM,
	input [`MAX-1:0] MSGW,
	output [31:0] DOut,
	output [31:0] EPC,
	output [31:0] MacroPC,
	output EXLSet
    );
	
	`define PrID 32'h1234_5678
	
	reg [31:0] CAUSE = 32'h0;
	reg [31:0] _EPC = 32'h0;
	reg [31:0] SR = 32'h0;
	reg [31:0] PrID = `PrID;
	reg [31:0] BrPC;
	wire BrDelay;
	wire branch;
	
	wire [31:0] instr;
	
	// 异常中断相关
	wire _IntReq;
	wire _EXLSet;
	
	assign instr = MSGM[`instr];	// 截取当前M流水级指令

	assign _IntReq = (|(HWInt[5:0] & SR[`IM]) & SR[`IE] & ~SR[`EXL]);
	assign _EXLSet = (|MSGM[`ExcCode]) & ~SR[`EXL];
	assign EXLSet = _IntReq | _EXLSet;
	
	assign DOut = (A == `regSR) ? SR :
					  (A == `regCAUSE) ? CAUSE :
					  (A == `regEPC) ? EPC :
					  (A == `regPrID) ? PrID :
					  32'b0;
					  
	assign EPC = _EPC;
	
	assign MacroPC = (MSGM[`pc] != 32'b0) ? MSGM[`pc] :
						  (MSGE[`pc] != 32'b0) ? MSGE[`pc] :
						  (MSGD[`pc] != 32'b0) ? MSGD[`pc] :
						  (MSGF[`pc] != 32'b0) ? MSGF[`pc] :
						  32'h0000_3000;
						  
	assign branch = (`beq | `bne | `blez | `bgtz | `bltz | `bgez |
						  `jr | `jalr | `j | `jal | `eret) ? 1'b1 :
						  1'b0;
						  
	// CP0
	always @(posedge clk)
	begin
		// 检测延迟槽
		if (branch)
			BrPC <= MSGM[`pc];
		else
			BrPC <= BrPC;
			
		if (reset)
		begin
			_EPC <= 32'h0;
			CAUSE <= 32'h0;
			SR <= 32'h0;
			PrID <= `PrID;
		end
		else
		begin
			CAUSE[`IP] <= HWInt[5:0];
			if (We & ~_IntReq & ~_EXLSet)
			begin
				if (A == `regSR)
				begin
					{SR[15:10], SR[1], SR[0]} <= {DIn[15:10], DIn[1], DIn[0]};
				end
				else if (A == `regEPC)
					_EPC <= DIn;
			end
			else if (_IntReq)
			begin
				SR[`EXL] <= 1'b1;
				CAUSE[`Exc] <= 5'b0;
				CAUSE[`BD] <= BrDelay;
				if (BrDelay)
					_EPC <= BrPC;
				else if (MSGM[`pc] != 32'h0)
					_EPC <= MSGM[`pc];
				else if (MSGE[`pc] != 32'h0)
					_EPC <= MSGE[`pc];
				else if (MSGD[`pc] != 32'h0)
					_EPC <= MSGD[`pc];
				else if (MSGF[`pc] != 32'h0)
					_EPC <= MSGF[`pc];
				else
					_EPC <= `PrID;
			end
			else if (_EXLSet)
			begin
				SR[`EXL] <= 1'b1;
				CAUSE[`Exc] <= MSGM[`ExcCode];
				CAUSE[`BD] <= BrDelay;
				if (BrDelay)
					_EPC <= BrPC;
				else if (MSGM[`pc] != 32'h0)
					_EPC <= MSGM[`pc];
				else if (MSGE[`pc] != 32'h0)
					_EPC <= MSGE[`pc];
				else if (MSGD[`pc] != 32'h0)
					_EPC <= MSGD[`pc];
				else if (MSGF[`pc] != 32'h0)
					_EPC <= MSGF[`pc];
				else
					_EPC <= `PrID;
			end
			else if (IntReq)
				SR[`EXL] <= 1'b0;
			
		end
	end
	
	assign BrDelay = (MSGM[`pc] == (BrPC+32'h4)) ? 1'b1 :
							1'b0;
	
endmodule
