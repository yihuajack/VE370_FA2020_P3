`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ruge Xu, Yihua Liu, Yiqi Sun
// 
// Create Date: 2020/11/21 20:10:23
// Design Name: 1_b
// Module Name: cache1b
// Project Name: 1_b
// Target Devices: Basys3 xc7a35tcpg236-1
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Memory Module Name Changed
// Revision 0.03 - Error Fixed at Line 67 (Parameters Order Issue)
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cache1b(read_write, address, writeData, readData, hit);  // 2-way associative write through
//2-way associative tag*5bits+index*1bit+word*2bits+byte*2bits

	input read_write;  // from CPU to cache
	input [9:0] address;  // remain the same from CPU to cache to main memory
	input [31:0] writeData;  // from CPU to cache
	output [31:0] readData;  // from cache to CPU
	output hit;  // hit or miss

	reg [31:0] readData;
	reg	hit;

	reg latest	[1:0];
	reg [31:0] cache [3:0][3:0];
	reg	valid [3:0];
	reg	[4:0] tag [3:0];
	wire index;  // block index

	reg read_write_mem;  // from cache to main memory
	reg	[127:0] write_data_mem;  // from cache to main memory
	wire [127:0] read_data_mem;  // from main memory to cache
    
    integer	i,j;

	initial begin  //initialize to all zeros
		for(i=0; i<4; i=i+1) begin
			valid[i]=1'b0;
		end
		for(i=0; i<2; i=i+1) begin
			latest[i]=1'b0;
		end
		for(i=0; i<4; i=i+1) begin
			for(j=0; j<4;j=j +1) begin
				cache[i][j]=32'b0;
			end
		end
		for(i=0 ;i<4; i=i+1) begin
			tag[i]=5'b0;
		end
	end

	Memory mem(.read_write(read_write_mem),.address(address),.writeData(write_data_mem),.readData(read_data_mem));  //to be decided
    
	assign index = address[4];

	always @(read_write or address or writeData) begin
        // hit = (valid[{index, 1'b0}] == 1'b1 && tag[{index, 1'b0}] == address[9:5]) || (valid[{index, 1'b1}] == 1'b1 && tag[{index, 1'b1}] == address[9:5]);  // determine whether there is a hit or a miss
		// hit = valid[{index, 1'b0}] == 1'b1 & tag[{index, 1'b0}] == address[9:5];  //the first block
		// hit = valid[{index, 1'b1}] == 1'b1 & tag[{index, 1'b1}] == address[9:5];  //the second block
		
        if (valid[{index, 1'b0}] == 1'b1 && tag[{index,1'b0}] == address[9:5]) begin //the first block
            hit = 1'b1; 
        end
        else if (valid[{index,1'b1}] == 1'b1 && tag[{index,1'b1}] == address[9:5]) begin //the second block
            hit = 1'b1; 
        end  // (Accepted) Initially hit = X, these if conditions can only let hit = 1 but not 0, at very first hit will be X when it should be 0,
		// so it will miss hit == 0 conditions, which will cause memory[1], [2], and [3] to be 0
		else begin
			hit = 1'b0;  // (Alternative, works fine step by step but fail by simulation, may related to timing issue) Complete logic
        end
                 
        //renew the cache when hit and latest
		if(hit == 1'b1) begin //hit
			if(read_write == 1'b0) begin //read
				if(tag[{index,1'b0}] == address[9:5]) begin //the first block
					latest[index]=1'b0;
					readData=cache[{index,1'b0}][address[3:2]];
				end
				else begin //the second block
					latest[index]=1'b1;
					readData=cache[{index,1'b1}][address[3:2]];
				end
			end
			else begin //write
				if(tag[{index,1'b0}] == address[9:5]) begin
					latest[index]=1'b0;
					cache[{index,1'b0}][address[3:2]][7:0]=writeData[7:0];
				end
				else begin	
					latest[index]=1'b1;
					cache[{index,1'b1}][address[3:2]][7:0]=writeData[7:0];
				end
				read_write_mem = 1'b1;
                write_data_mem={cache[{index,latest[index]}][0],cache[{index,latest[index]}][1],cache[{index,latest[index]}][2],cache[{index,latest[index]}][3]};
			end
		end
		else begin //miss
            if(valid[{index,1'b0}]==1'b0) begin //the first in block not valid
                latest[index] = 1'b1; 
            end
            else if(valid[{index,1'b1}]==1'b0) begin //the second in block not valid
                latest[index]=1'b0;
            end
            latest[index] = !latest[index];
			valid[{index,latest[index]}]=1'b1;
			tag[{index,latest[index]}]=address[9:5];
			#1
			read_write_mem=1'b0;
            cache[{index,latest[index]}][3]=read_data_mem[127:96];
            cache[{index,latest[index]}][2]=read_data_mem[95:64];
            cache[{index,latest[index]}][1]=read_data_mem[63:32];
            cache[{index,latest[index]}][0]=read_data_mem[31:0];
            #1
            if (read_write == 1'b0) begin //read
                read_write_mem = 1'b0;
                readData = cache[{index,latest[index]}][address[3:2]]; 
            end
            else begin
                read_write_mem = 1'b1;
                cache[{index,latest[index]}][address[3:2]][7:0]=writeData[7:0];
                write_data_mem={cache[{index,latest[index]}][0],cache[{index,latest[index]}][1],cache[{index,latest[index]}][2],cache[{index,latest[index]}][3]};
            end
		end
	end
endmodule