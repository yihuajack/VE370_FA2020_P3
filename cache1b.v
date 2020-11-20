module Cache(read_write, address, writeData, readData,hit); 
//2-way associative tag*5bits+index*1bit+word*2bits+byte*2bits

	input read_write; 
	input [9:0] address; 
	input [31:0] writeData; 
	output [31:0] readData; 
	output hit; 

	reg [31:0] readData;
	reg	hit;


	reg latest	[1:0];
	reg [31:0] cache [3:0][3:0];
	reg	valid [3:0];
	reg	[4:0] tag [3:0];
	reg index;

	reg read_write_mem;
	reg	[127:0] write_data_mem;
	wire [127:0]read_data_mem;
    
    integer	i,j;

	initial begin //initialize to all zeros
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

	Memory1 mem(.read_write(read_write_mem),.address(address),.readData(read_data_mem),.writeData(write_data_mem));
    
	always @(read_write or address or writeData) begin

        index = address[4];
        
        if(valid[{index, 1'b0}] == 1'b1 & tag[{index,1'b0}] == address[9:5]) begin //the first block
            hit = 1'b1; 
        end
        if (valid[{index,1'b1}] == 1'b1 & tag[{index,1'b1}] == address[9:5]) begin //the second block
            hit = 1'b1; 
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
					cache[{index,1'b0}][address[3:2]]=writeData;
				end
				else begin	
					latest[index]=1'b1;
					cache[{index,1'b1}][address[3:2]]=writeData;
				end
			end
		end
		else begin //miss
            if(valid[{index,1'b0}]==1'b0) begin //the first in block not valid
                latest[index] = 1'b0; 
            end
            else begin
                if(valid[{index,1'b1}]==1'b0) begin //the second in block not valid
                    latest[index]=1'b1;
			    end
            end
			valid[{index,latest[index]}]=1'b1;
			tag[{index,latest[index]}]=address[9:5];
		end


		#1;
        if(hit == 1'b0) begin //miss, read in the memory first
				read_write_mem=1'b0;
				cache[{index,latest[index]}][3]=read_data_mem[127:96];
				cache[{index,latest[index]}][2]=read_data_mem[95:64];
				cache[{index,latest[index]}][1]=read_data_mem[63:32];
				cache[{index,latest[index]}][0]=read_data_mem[31:0];
			end
		#1; 
        if (read_write == 1'b0) begin //read
            assign read_write_mem = 1'b0; 
            readData = cache[{index,latest[index]}][address[3:2]]; 
        end
        else begin //write
        	assign read_write_mem=1'b1;
			if(hit == 1'b1) begin //hit
				write_data_mem={cache[{index,latest[index]}][0],cache[{index,latest[index]}][1],cache[{index,latest[index]}][2],cache[{index,latest[index]}][3]};
			end
			else begin //no hit, write through
				cache[{index,latest[index]}][address[3:2]]=writeData;
				write_data_mem={cache[{index,latest[index]}][0],cache[{index,latest[index]}][1],cache[{index,latest[index]}][2],cache[{index,latest[index]}][3]};
			end
		end

	end
endmodule
