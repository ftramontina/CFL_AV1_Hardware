
//Luma memory 

module luma_memory  
  #(
  
	parameter width_p 	    = 10, 			
	parameter columns		= 64, 
	parameter rows			= 64
   
  )
  (
    input logic clk_i,
	input logic rst_i,
	input logic luma_memory_rst_i,
	
	input logic data_in_valid_i,
	input logic [7:0] block_width_i, 
	input logic [7:0] block_height_i, 
	
	input logic [width_p-1:0] sample_0_i,
	input logic [width_p-1:0] sample_1_i,
	input logic [width_p-1:0] sample_2_i,
	input logic [width_p-1:0] sample_3_i,
	input logic [width_p-1:0] sample_4_i,
	input logic [width_p-1:0] sample_5_i,
	input logic [width_p-1:0] sample_6_i,
	input logic [width_p-1:0] sample_7_i,
	input logic [width_p-1:0] sample_8_i,
	input logic [width_p-1:0] sample_9_i,
	input logic [width_p-1:0] sample_10_i,
	input logic [width_p-1:0] sample_11_i,
	input logic [width_p-1:0] sample_12_i,
	input logic [width_p-1:0] sample_13_i,
	input logic [width_p-1:0] sample_14_i,
	input logic [width_p-1:0] sample_15_i,
	
	output logic ready_to_load_o,
	output logic seq_mem_ready_o,
	
	input logic subsampling_re_i,
	
	input logic [6:0] row_addr_a_1_i,
	input logic [6:0] column_addr_a_1_i,
	input logic [6:0] row_addr_a_2_i,
	input logic [6:0] column_addr_a_2_i,

	input logic [6:0] row_addr_b_1_i,
	input logic [6:0] column_addr_b_1_i,
	input logic [6:0] row_addr_b_2_i,
	input logic [6:0] column_addr_b_2_i,
 
	output logic [width_p-1:0] sample_out_a_1_o,
	output logic [width_p-1:0] sample_out_a_2_o,
	output logic [width_p-1:0] sample_out_b_1_o,
	output logic [width_p-1:0] sample_out_b_2_o	
	
  );

    // RAM declaration 
    logic [width_p-1:0] mem [0:rows-1][0:columns-1];   // addresses from 0 to rows-1 
	logic [7:0] block_width_reg  = 0;
	logic [7:0] block_height_reg = 0; 	
	
	logic seq_mem_ready_reg = 0;
	logic ready_to_load_reg = 0; 

	logic load_block_size_en = 0; 
	
	int i = 0; 
	int j = 0; 
	int k = 0;
	int l = 0; 
	
	always_ff @(posedge clk_i) begin 
		if(rst_i || luma_memory_rst_i) begin
			seq_mem_ready_reg  <= 0;
			ready_to_load_reg  <= 0; 
			load_block_size_en <= 1;
			block_width_reg    <= 0;
			block_height_reg   <= 0; 			
			j <= 0;
			i <= 0; 
			
			for(int k = 0; k < rows; k++) begin 
				for(int l = 0; l < columns; l++) begin 
					mem[k][l] <= '0;
				end 	
			end
			
		// Load serially the memory  
		end else begin 
			if(load_block_size_en) begin 
				if((block_width_i == 4) || (block_width_i == 8) || (block_width_i == 16) || (block_width_i == 32) || (block_width_i == 64)) begin 
					if((block_height_i == 4) || (block_height_i == 8) || (block_height_i == 16) || (block_height_i == 32) || (block_height_i == 64)) begin 
						block_width_reg    <= block_width_i;
						block_height_reg   <= block_height_i;
						load_block_size_en <= 0;
						ready_to_load_reg  <= 1; 
						
					end else begin 
						block_width_reg   <= block_width_reg; 
						block_height_reg  <= block_height_reg;
						ready_to_load_reg <= 0;
					end
						
				end else begin 
					block_width_reg   <= block_width_reg; 
					block_height_reg  <= block_height_reg;
					ready_to_load_reg <= 0;
					
				end 
			end	
			
			if(data_in_valid_i && ready_to_load_reg) begin 
				mem[i+0][j+0] <= sample_0_i;
				mem[i+0][j+1] <= sample_1_i;
				mem[i+0][j+2] <= sample_2_i;
				mem[i+0][j+3] <= sample_3_i;

				mem[i+1][j+0] <= sample_4_i;
				mem[i+1][j+1] <= sample_5_i;
				mem[i+1][j+2] <= sample_6_i;
				mem[i+1][j+3] <= sample_7_i;

				mem[i+2][j+0] <= sample_8_i;
				mem[i+2][j+1] <= sample_9_i;
				mem[i+2][j+2] <= sample_10_i;
				mem[i+2][j+3] <= sample_11_i;

				mem[i+3][j+0] <= sample_12_i;
				mem[i+3][j+1] <= sample_13_i;
				mem[i+3][j+2] <= sample_14_i;
				mem[i+3][j+3] <= sample_15_i;

				if(j >= block_width_reg - 4) begin 
					j <= 0;

					if(i >= block_height_reg - 4) begin 
						i <= 0;
						seq_mem_ready_reg <= 1;
						ready_to_load_reg <= 0; 
					end else begin 
						i <= i + 4;
					end 

				end else begin 
					j <= j + 4;
				end 	
				
			end else if(subsampling_re_i) begin 
				sample_out_a_1_o <= mem[row_addr_a_1_i][column_addr_a_1_i]; 
				sample_out_a_2_o <= mem[row_addr_a_2_i][column_addr_a_2_i]; 	
				sample_out_b_1_o <= mem[row_addr_b_1_i][column_addr_b_1_i]; 
				sample_out_b_2_o <= mem[row_addr_b_2_i][column_addr_b_2_i]; 
				
			end 
		end	
	end
	
	always_ff @(posedge clk_i) begin
		if(seq_mem_ready_reg) begin 
			seq_mem_ready_reg <= 0; 
		end 
	end 
	
	assign ready_to_load_o = ready_to_load_reg; 
	assign seq_mem_ready_o = seq_mem_ready_reg;
	
endmodule