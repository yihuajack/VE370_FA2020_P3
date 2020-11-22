`timescale 1ns / 1ps

// 2-way associative write back cache
module Cache(read_write, address, writeData, readData, hit);

    input read_write;
    input [9:0] address;
    input [31:0] writeData;
    output reg [31:0] readData;
    output reg hit;

    reg latest [1:0];
    reg [31:0] cache [3:0][3:0];
    reg valid [3:0];
    reg [4:0] tag [3:0];
    reg index;
    reg [3:0] dirty;

    reg read_write_mem;
    reg [9:0] address_mem;
    reg [127:0] write_data_mem;
    wire [127:0] read_data_mem;

    integer i, j;

    initial begin
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

    Memory1 mem(.read_write(read_write_mem), .address(address_mem), .writeData(write_data_mem), .readData(read_data_mem));

    always @(read_write or address or writeData) begin
        index = address[4]; 
        address_mem = address;
        if (valid[{index,1'b0}]==1'b1 && tag[{index,1'b0}] == address[9:5]) begin
            hit = 1'b1; 
        end
        else if (valid[{index,1'b1}]==1'b1 && tag[{index,1'b1}] == address[9:5]) begin
                hit = 1'b1; 
        end
        else begin
                hit = 1'b0; 
        end

        if (hit == 1'b1) begin // hit
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
                    cache[{index, 1'b0}][address[3:2]] = writeData;
                    dirty[{index, 1'b0}] = 1'b1;
                end
                else begin
                    latest[index] = 1'b1;
                    cache[{index, 1'b1}][address[3:2]] = writeData;
                    dirty[{index, 1'b1}] = 1'b1;
                end
            end
        end
        else begin // miss
            if (valid[{index, 1'b0}] == 1'b0) begin
                latest[index] = 1'b1;
            end
            else if (valid[{index, 1'b1}] == 1'b0) begin
                latest[index] = 1'b0;
            end
            latest[index] = !latest[index];
            if (dirty[{index,latest[index]}] == 1'b1) begin
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
            if (read_write == 1'b0) begin
                readData = cache[{index, latest[index]}][address[3:2]]; 
            end
            else begin
                cache[{index, latest[index]}][address[3:2]] = writeData; 
                if (valid[{index, latest[index]}] == 1'b1) begin
			dirty[{index, latest[index]}] = 1'b1; 
                end
            end        
        end
    end        
endmodule
