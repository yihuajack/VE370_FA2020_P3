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
// Revision 0.03 - Bug Fixed at Line 72 (write_data_mem Issue)
// Revision 0.04 - Code Style Standardized at Line 86-87
// Revision 0.05 - Logic Optimized at Line at Line 76-79
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Cache(read_write, address, writeData, readData, hit); 

    //10 bit address: tag*4bit + index*2bit + word*2bit + byte*2bit

    input read_write; 
    input [9:0] address; 
    input [31:0] writeData; 
    output [31:0] readData; 
    output hit; 

    reg hit; 
    reg [31:0] readData; 

    reg [31:0] cache [3:0][3:0]; //4*4 block of bytes
    reg valid [3:0]; 
    reg [3:0] tag [3:0]; 
    reg [1:0] index; 

    reg read_write_mem; 
    //reg read_write_flag; 
    //wire [9:0] address_to_mem; 
    reg [127:0] write_data_mem; 
    wire [127:0] read_data_mem; 

    integer i, j; 

    initial begin //initialize to all zeros
        valid[0] = 1'b0; 
        valid[1] = 1'b0; 
        valid[2] = 1'b0; 
        valid[3] = 1'b0; 
        tag[0] = 4'b0; 
        tag[1] = 4'b0; 
        tag[2] = 4'b0; 
        tag[3] = 4'b0; 
        hit = 1'b0; 
        readData = 32'b0; 

        for(i=0; i<4; i = i+1) begin
            for(j=0; j<4; j = j+1) begin
                cache[i][j] = 32'b0; 
            end
        end
    end

    Memory mem(.read_write(read_write_mem), .address(address), .writeData(write_data_mem), .readData(read_data_mem)); //to be decided

    always @(read_write or address or writeData) begin
        index = address[5:4]; 
        /* if ((valid[index] == 1'b1) & (tag[index] == address[9:6])) begin
            assign hit = 1'b1;
        end */
        assign hit = (valid[index] == 1'b1) && (tag[index] == address[9:6]);
        if (hit == 1'b1) begin //hit
            if (read_write == 1'b0) begin //read from mem
                assign readData = cache[index][address[3:2]]; 
            end
            else begin //write, change the data, write through
                cache[index][address[3:2]] = writeData; 
                assign read_write_mem = 1'b1; 
            end
        end
        else begin //miss,read mem first
            valid[index] = 1'b1; 
            tag[index] = address[9:6]; 
        end
        #1 if (hit ==1'b0) begin
            read_write_mem = 1'b0; 
            cache[index][0] = read_data_mem[31:0]; 
            cache[index][1] = read_data_mem[63:32]; 
            cache[index][2] = read_data_mem[95:64]; 
            cache[index][3] = read_data_mem[127:96]; 
        end

        #1 if (read_write == 1'b0) begin //read 
                assign read_write_mem = 1'b0; 
                readData = cache[index][address[3:2]]; 
            end
            else begin //write
                assign read_write_mem = 1'b1; 
                if(hit == 1'b1) begin
                     write_data_mem = {cache[index][0],cache[index][1],cache[index][2],cache[index][3]};
                end
                else begin
                    cache[index][address[3:2]] = writeData; 
                    write_data_mem = {cache[index][0],cache[index][1],cache[index][2],cache[index][3]};
            end
        end
    end
endmodule
