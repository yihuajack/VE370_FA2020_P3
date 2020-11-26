`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ruge Xu, Yihua Liu, Yiqi Sun
// 
// Create Date: 2020/11/21 20:10:23
// Design Name: 2_b
// Module Name: cache2b
// Project Name: 2_b
// Target Devices: Basys3 xc7a35tcpg236-1
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Memory Module Name Changed
// Revision 0.03 - Logic Optimized (index)
// Revision 0.04 - Error Fixed at Line 100, 105 and 137 (Cache Read from writeData Issue)
// Revision 0.05 - More Detailed Comments Added
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// 2-way associative write back cache
module Cache2b(read_write, address, writeData, readData, hit);  // 2-way associative write back

    input read_write;  // from CPU to cache
    input [9:0] address;  // from CPU to cache
    input [31:0] writeData;  // from CPU to cache
    output reg [31:0] readData;  // from cache to CPU
    output reg hit;  // hit or miss

    reg latest [1:0];
    reg [31:0] cache [3:0][3:0];
    reg valid [3:0];
    reg [4:0] tag [3:0];
    wire index;  // block index
    reg [3:0] dirty;

    reg read_write_mem;  // from cache to main memory
    reg [9:0] address_mem;  // from cache to main memory
    reg [127:0] write_data_mem;  // from cache to main memory
    wire [127:0] read_data_mem;  // from main memory to cache

    integer i, j;

    initial begin  //initialize to all zeros
        for(i=0; i<4; i=i+1) begin
			valid[i] = 1'b0;
		end
		for(i=0; i<2; i=i+1) begin
			latest[i] = 1'b0;
		end
		for(i=0; i<4; i=i+1) begin
			for(j=0; j<4;j=j +1) begin
				cache[i][j] = 32'b0;
			end
		end
		for(i=0 ;i<4; i=i+1) begin
			tag[i] = 5'b0;
		end
        for (i=0; i<4; i=i+1) begin
            dirty[i] = 1'b0;
        end
    end

    Memory mem(.read_write(read_write_mem), .address(address_mem), .writeData(write_data_mem), .readData(read_data_mem));  //to be decided

    assign index = address[4];

    always @(read_write or address or writeData) begin
        address_mem = address;
        if (valid[{index,1'b0}]==1'b1 && tag[{index,1'b0}] == address[9:5]) begin  // determine whether there is a hit or a miss
            hit = 1'b1; 
        end
        else if (valid[{index,1'b1}]==1'b1 && tag[{index,1'b1}] == address[9:5]) begin
            hit = 1'b1; 
        end
        else begin
            hit = 1'b0; 
        end

        if (hit == 1'b1) begin  // hit
            if (read_write == 1'b0) begin
                if (tag[{index, 1'b0}] == address[9:5]) begin
                    latest[index] = 1'b0;
                    readData = cache[{index,1'b0}][address[3:2]];
                end
                else begin
                    latest[index] = 1'b1;
                    readData = cache[{index,1'b1}][address[3:2]];
                end
            end
            else begin
                if (tag[{index, 1'b0}] == address[9:5]) begin
                    latest[index] = 1'b0;
                    cache[{index, 1'b0}][address[3:2]][7:0] = writeData[7:0];
                    dirty[{index, 1'b0}] = 1'b1;
                end
                else begin
                    latest[index] = 1'b1;
                    cache[{index, 1'b1}][address[3:2]][7:0] = writeData[7:0];
                    dirty[{index, 1'b1}] = 1'b1;
                end
            end
        end
        else begin  // miss
            if (valid[{index, 1'b0}] == 1'b0) begin
                latest[index] = 1'b1;
            end
            else if (valid[{index, 1'b1}] == 1'b0) begin
                latest[index] = 1'b0;
            end
            latest[index] = !latest[index];
            if (dirty[{index,latest[index]}] == 1'b1) begin  // dirty
                read_write_mem = 1'b1;
                address_mem = {tag[{index, latest[index]}], index, address[3:0]};
                write_data_mem = {cache[{index,latest[index]}][0],cache[{index,latest[index]}][1],cache[{index,latest[index]}][2],cache[{index,latest[index]}][3]};
				dirty[{index, latest[index]}] = 1'b0;
            end
            valid[{index, latest[index]}] = 1'b1;
            tag[{index, latest[index]}] = address[9:5];
            #1
            read_write_mem = 1'b0;
            cache[{index,latest[index]}][0] = read_data_mem[31:0];
            cache[{index,latest[index]}][1] = read_data_mem[63:32];
            cache[{index,latest[index]}][2] = read_data_mem[95:64];
            cache[{index,latest[index]}][3] = read_data_mem[127:96];
            #1
            if (read_write == 1'b0) begin  // read
                readData = cache[{index, latest[index]}][address[3:2]]; 
            end
            else begin  // write
                cache[{index, latest[index]}][address[3:2]][7:0] = writeData[7:0]; 
                if (valid[{index, latest[index]}] == 1'b1) begin
			        dirty[{index, latest[index]}] = 1'b1; 
                end
            end        
        end
    end        
endmodule
