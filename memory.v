`timescale 1ns / 1ps

module mem(read_write, address, writeData, readData);
    input read_write;
	input [9:0] address;
	input [127:0] writeData;
	output [127:0] readData;
	
	reg [31:0] memory [255:0];
	
	integer i;
    initial begin
        for (i=0; i<256; i=i+1)
            memory[i] = 32'b0;
        $readmemb("memory.txt", memory);
    end
    
    assign readData = {memory[{address[9:4],2'b11}], memory[{address[9:4],2'b10}], memory[{address[9:4],2'b01}], memory[{address[9:4],2'b00}]};
    
    always @ (*) begin
        if (read_write == 1'b1) begin
            memory[{address[9:4],2'b00}] = writeData[127:96];
            memory[{address[9:4],2'b01}] = writeData[95:64];
            memory[{address[9:4],2'b11}] = writeData[63:32];
            memory[{address[9:4],2'b11}] = writeData[31:0]; 
        end
    end
endmodule
