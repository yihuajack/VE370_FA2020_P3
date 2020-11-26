`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ruge Xu, Yihua Liu, Yiqi Sun
// 
// Create Date: 2020/11/21 ‚Äè‚??17:16:42
// Design Name: 1_b
// Module Name: Cache1b
// Project Name: 1_b
// Target Devices: Basys3 xc7a35tcpg236-1
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Module Name & File Name Changed
// Revision 0.03 - Output Format Adjusted
// Revision 0.04 - Module Name Changed
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim1b;
	reg read_write;  // read_write: 0 for read, 1 for write
	reg	[9:0] address;  // Address: 10 bits byte address
	reg	[31:0] write_data;  // write_data: 32 bits value (8 bits are enough for this project demo)
	wire hit;
	wire [31:0] readData;
	Cache1b cache1b(read_write, address, write_data, readData, hit);
    // keep track of the output of your (cache+memory) block, which are read_data and hit_miss
    // also please find a way to show the content of the main memory 
	initial begin
		#0 read_write = 0; address = 10'b0000000000; //should miss
        #10 read_write = 1; address = 10'b0000000000; write_data = 8'b11111111; //should hit
        #10 read_write = 0; address = 10'b0000000000; //should hit and read out 0xff

		//here check main memory content, 
        //the first byte should remain 0x00 if it is write-back, 
        //should change to 0xff if it is write-through.
		#10 $display("==============================================================================================");
		$display("memory[0] = 0x%h, memory[1] = 0x%h, memory[2] = 0x%h, memory[3] = 0x%h", cache1b.mem.memory[0], cache1b.mem.memory[1], cache1b.mem.memory[2], cache1b.mem.memory[3]);
		$display("----------------------------------------------------------------------------------------------");

		#10 read_write = 0; address = 10'b1000000000; //should miss
        #10 read_write = 0; address = 10'b0000000000; //should hit for 2-way associative, should miss for directly mapped
        
        #10 read_write = 0; address = 10'b1100000000; //should miss
        #10 read_write = 0; address = 10'b1000000000; //should miss both for directly mapped and for 2-way associative (Least-Recently-Used policy)
	
        //here check main memory content, 
        //the first byte should be 0xff
		#10 $display("memory[0] = 0x%h, memory[1] = 0x%h, memory[2] = 0x%h, memory[3] = 0x%h", cache1b.mem.memory[0], cache1b.mem.memory[1], cache1b.mem.memory[2], cache1b.mem.memory[3]);
		$display("==============================================================================================");

		#10 $stop;
	end
endmodule