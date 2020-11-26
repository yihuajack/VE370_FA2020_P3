`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ruge Xu, Yihua Liu, Yiqi Sun
// 
// Create Date: 2020/11/21 20:10:23
// Design Name: 1_a
// Module Name: cache1a
// Project Name: 1_a
// Target Devices: Basys3 xc7a35tcpg236-1
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Memory Module Name Changed
// Revision 0.03 - Bug Fixed at Line 79 (write_data_mem Issue)
// Revision 0.04 - Code Style Standardized at Line 94-95
// Revision 0.05 - Logic Optimized at Line
// Revision 0.06 - Error Assignment Fixed at Line 85
// Revision 0.07 - Variables index & hit Changed
// Revision 0.08 - Error Assignment Fixed at Line 88, 94, 110, and 114
// Revision 0.09 - Error Fixed at Line 94
// Revision 0.10 - Module Name Changed
// Revision 0.11 - More Detailed Comments Added
// Revision 0.12 - Bug Fixes (hit Issue)
// Revision 0.13 - Error Fixed at Line 93 and 119 (Cache Read from writeData Issue)
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cache1a(read_write, address, writeData, readData, hit);  // Direct mapped write through

    //10 bit address: tag*4bit + index*2bit + word*2bit + byte*2bit

    input read_write;  // from CPU to cache
    input [9:0] address;  // remain the same from CPU to cache to main memory
    input [31:0] writeData;  // from CPU to cache
    output [31:0] readData;  // from cache to CPU
    output hit;  // hit or miss

    reg hit;  // must be reg or assignment will be repeatedly executed
    reg [31:0] readData; 

    reg [31:0] cache [3:0][3:0]; //4*4 block of bytes
    reg valid [3:0]; 
    reg [3:0] tag [3:0]; 
    wire [1:0] index;  // block index

    reg read_write_mem;  // from cache to main memory
    //reg read_write_flag; 
    reg [127:0] write_data_mem;  // from cache to main memory
    wire [127:0] read_data_mem;  // from main memory to cache

    integer i, j; 

    initial begin  //initialize to all zeros
        valid[0] = 1'b0; 
        valid[1] = 1'b0; 
        valid[2] = 1'b0; 
        valid[3] = 1'b0; 
        tag[0] = 4'b0; 
        tag[1] = 4'b0; 
        tag[2] = 4'b0; 
        tag[3] = 4'b0; 
        hit = 1'b0;  // reserved
        readData = 32'b0; 

        for(i=0; i<4; i = i+1) begin
            for(j=0; j<4; j = j+1) begin
                cache[i][j] = 32'b0; 
            end
        end
    end

    Memory mem(.read_write(read_write_mem), .address(address), .writeData(write_data_mem), .readData(read_data_mem));  //to be decided

    assign index = address[5:4];  // determine the block index
    
    always @(read_write or address or writeData) begin
        /* if ((valid[index] == 1'b1) & (tag[index] == address[9:6])) begin
            assign hit = 1'b1;
        end */
        hit = (valid[index] == 1'b1) && (tag[index] == address[9:6]);  // determine whether there is a hit or a miss
        if (hit == 1'b1) begin //hit
            if (read_write == 1'b0) begin //read from mem
                readData = cache[index][address[3:2]]; 
            end
            else begin //write, change the data, write through
                cache[index][address[3:2]][7:0] = writeData[7:0]; 
                // read_write_mem = 1'b1;  duplicating, would not update write_data_mem if added
            end
        end
        else begin //miss, read mem first
            valid[index] = 1'b1; 
            tag[index] = address[9:6]; 
        end
        #1 if (hit == 1'b0) begin  // miss
            read_write_mem = 1'b0; 
            cache[index][0] = read_data_mem[31:0]; 
            cache[index][1] = read_data_mem[63:32]; 
            cache[index][2] = read_data_mem[95:64]; 
            cache[index][3] = read_data_mem[127:96]; 
        end

        #1 if (read_write == 1'b0) begin //read 
                read_write_mem = 1'b0; 
                readData = cache[index][address[3:2]]; 
            end
            else begin //write
                read_write_mem = 1'b1; 
                if(hit == 1'b1) begin  // hit
                     write_data_mem = {cache[index][0],cache[index][1],cache[index][2],cache[index][3]};
                end
                else begin  // miss
                    cache[index][address[3:2]][7:0] = writeData[7:0]; 
                    write_data_mem = {cache[index][0],cache[index][1],cache[index][2],cache[index][3]};
            end
        end
    end
endmodule
