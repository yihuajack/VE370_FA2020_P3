`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ruge Xu, Yihua Liu, Yiqi Sun
// 
// Create Date: 2020/11/21 20:10:23
// Design Name: 2_a
// Module Name: cache2a
// Project Name: 2_a
// Target Devices: Basys3 xc7a35tcpg236-1
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Memory Module Name Changed
// Revision 0.03 - Bug Fixed at Line 71 (write_data_mem Issue)
// Revision 0.04 - Memory Module Name Changed
// Revision 0.05 - Useless Assignment readData_out Removed
// Revision 0.06 - Logic Optimized (index)
// Revision 0.07 - Error Fixed (hit Issue)
// Revision 0.08 - Error Fixed at Line 94 and 122 (Cache Read from writeData Issue)
// Revision 0.09 - More Detailed Comments Added
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cache2a(read_write, address, writeData, readData, hit);  // Direct mapped write back

    input read_write;  // from CPU to cache
    input [9:0] address;  // from CPU to cache
    input [31:0] writeData;  // from CPU to cache
    output [31:0] readData;  // from cache to CPU
    output hit;  // hit or miss

    reg [31:0] readData; 
    reg hit; 

    reg [31:0] cache[3:0][3:0]; 
    reg valid[3:0]; 
    reg [3:0] tag [3:0]; 
    wire [1:0] index;  // block index
    reg dirty[3:0]; 

    reg read_write_mem;  // from cache to main memory
    reg [127:0] write_data_mem;  // from cache to main memory
    wire [127:0] read_data_mem;  // from main memory to cache

    reg [9:0] address_mem;  // from cache to main memory

    integer i, j; 

    initial begin  //initialize to all zeros
        read_write_mem = 1'b0; 
        for(i=0; i<4; i=i+1) begin
            valid[i] = 1'b0; 
        end
        for(i=0; i<4; i=i+1) begin
            tag[i] = 4'b0000; 
        end
        for(i=0; i<4; i=i+1) begin
            dirty[i] = 4'b0000; 
        end
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                cache[i][j] = 32'b0; 
            end
        end
    end

    Memory mem(.read_write(read_write_mem), .address(address_mem), .writeData(write_data_mem), .readData(read_data_mem));  //to be decided

    assign index = address[5:4]; 

    always @(read_write or address or writeData) begin
        address_mem = address; 
        //whether hit
        //$display ("valid[index]: %B, tag[index]: %B, address[9:6]: %B", valid[index], tag[index], address[9:6]); 
        /* if((valid[index] == 1'b1) & (tag[index] == address[9:6])) begin
            assign hit = 1'b1; 
        end
        else begin
            assign hit = 1'b0; 
        end */
        hit = (valid[index] == 1'b1) & (tag[index] == address[9:6]);  // determine whether there is a hit or a miss
        if (hit == 1'b1) begin //hit
            if (read_write == 1'b0) begin //read from mem
                readData = cache[index][address[3:2]]; 
            end
            else begin //write
                cache[index][address[3:2]][7:0] = writeData[7:0]; 
                dirty[index] = 1'b1; 
            end
        end
        if (hit == 1'b0) begin // miss
            if (dirty[index] == 1'b1) begin //dirty
                //write back
                read_write_mem = 1'b1; 
                address_mem = {tag[index], index, address[3:0]};
                write_data_mem = {cache[index][0], cache[index][1], cache[index][2], cache[index][3]}; 
                dirty[index] = 1'b0; 
                valid[index] = 1'b0; 
            end
            valid[index] = 1'b1; 
            tag[index] = address[9:6]; 
            #1; 
            //read the data from mem first
            read_write_mem = 1'b0; 
            cache[index][0] = read_data_mem[31:0]; 
            cache[index][1] = read_data_mem[63:32]; 
            cache[index][2] = read_data_mem[95:64]; 
            cache[index][3] = read_data_mem[127:96]; 
            valid[index] = 1'b1; 
            #1; 
            if (read_write == 1'b0) begin //read
                readData = cache[index][address[3:2]]; 
            end
            else begin //write
                cache[index][address[3:2]][7:0] = writeData[7:0]; 
                if (valid[index] == 1'b1 && dirty[index] == 1'b0) begin
                    dirty[index] = 1'b1; 
                end
            end
        end
    end
endmodule


