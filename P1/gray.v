`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:33:23 10/24/2020 
// Design Name: 
// Module Name:    gray 
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
module gray(
	input Clk,
	input Reset,
	input En,
	output [2:0] Output,
	output Overflow
   );
	
	// garyʵ����ģ��
	parameter gray_width = 3;	// λ��
	reg [2:0] gray_value;	//gray��
	reg [2:0] binary_value;	//��������
	reg is_overflow;	// �Ƿ����
	
	////
	initial
	begin
		gray_value = 0;
		binary_value = 1;
		is_overflow = 0;
	end
	////
	
	always @(posedge Clk)
	begin
	if (Reset)
	begin
		binary_value <= {{gray_width{1'b0}}, 1'b1};
		gray_value <= {{gray_width{1'b0}}};
		is_overflow <= 0;
	end
	else if (En)
	begin
		if (gray_value == 4)
		begin
			is_overflow <= 1;
			binary_value <= {{gray_width{1'b0}}, 1'b1};
			gray_value <= {{gray_width{1'b0}}};
		end
		binary_value <= binary_value + 3'b001;
		gray_value <= (binary_value >> 1) ^ binary_value;
	end
	end
	
	assign Output[2:0] = gray_value[2:0];
	assign Overflow = is_overflow;
	
endmodule
