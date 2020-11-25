`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ruge Xu, Yihua Liu, Yiqi Sun
// 
// Create Date: 2020/11/23 1:27:24
// Design Name:
// Module Name: mem
// Project Name:
// Target Devices: Basys3 xc7a35tcpg236-1
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Memory File Name Changed
// Revision 0.03 - Module Name Changed
// Revision 0.04 - Bug Fixed at Line 48
// Revision 0.05 - Potential Issue Repaired at Line 44
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Memory(read_write, address, writeData, readData);
    input read_write;
	input [9:0] address;
	input [127:0] writeData;
	output [127:0] readData;
	
	reg [31:0] memory [255:0];
	
	integer i;
    initial begin
        for (i=0; i<256; i=i+1)
            memory[i] = 32'b0;
        $readmemb("memory.mem", memory);
    end
    
    assign readData = {memory[{address[9:4],2'b11}], memory[{address[9:4],2'b10}], memory[{address[9:4],2'b01}], memory[{address[9:4],2'b00}]};
    
    always @ (read_write) begin
        if (read_write == 1'b1) begin
            memory[{address[9:4],2'b00}] = writeData[127:96];
            memory[{address[9:4],2'b01}] = writeData[95:64];
            memory[{address[9:4],2'b10}] = writeData[63:32];
            memory[{address[9:4],2'b11}] = writeData[31:0]; 
        end
    end
endmodule
