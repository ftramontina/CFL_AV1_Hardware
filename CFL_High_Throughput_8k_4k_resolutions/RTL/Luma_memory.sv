
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
	
	input logic [64*7-1:0] row_addr_flat_i,
	input logic [64*7-1:0] column_addr_flat_i,	
 
	output logic [width_p-1:0] sample_00_o,
	output logic [width_p-1:0] sample_01_o,
	output logic [width_p-1:0] sample_02_o,
	output logic [width_p-1:0] sample_03_o,
	output logic [width_p-1:0] sample_04_o,
	output logic [width_p-1:0] sample_05_o,
	output logic [width_p-1:0] sample_06_o,
	output logic [width_p-1:0] sample_07_o,
	output logic [width_p-1:0] sample_08_o,
	output logic [width_p-1:0] sample_09_o,
	output logic [width_p-1:0] sample_10_o,
	output logic [width_p-1:0] sample_11_o,
	output logic [width_p-1:0] sample_12_o,
	output logic [width_p-1:0] sample_13_o,
	output logic [width_p-1:0] sample_14_o,
	output logic [width_p-1:0] sample_15_o,
	output logic [width_p-1:0] sample_16_o,
	output logic [width_p-1:0] sample_17_o,
	output logic [width_p-1:0] sample_18_o,
	output logic [width_p-1:0] sample_19_o,
	output logic [width_p-1:0] sample_20_o,
	output logic [width_p-1:0] sample_21_o,
	output logic [width_p-1:0] sample_22_o,
	output logic [width_p-1:0] sample_23_o,
	output logic [width_p-1:0] sample_24_o,
	output logic [width_p-1:0] sample_25_o,
	output logic [width_p-1:0] sample_26_o,
	output logic [width_p-1:0] sample_27_o,
	output logic [width_p-1:0] sample_28_o,
	output logic [width_p-1:0] sample_29_o,
	output logic [width_p-1:0] sample_30_o,
	output logic [width_p-1:0] sample_31_o,
	output logic [width_p-1:0] sample_32_o,
	output logic [width_p-1:0] sample_33_o,
	output logic [width_p-1:0] sample_34_o,
	output logic [width_p-1:0] sample_35_o,
	output logic [width_p-1:0] sample_36_o,
	output logic [width_p-1:0] sample_37_o,
	output logic [width_p-1:0] sample_38_o,
	output logic [width_p-1:0] sample_39_o,
	output logic [width_p-1:0] sample_40_o,
	output logic [width_p-1:0] sample_41_o,
	output logic [width_p-1:0] sample_42_o,
	output logic [width_p-1:0] sample_43_o,
	output logic [width_p-1:0] sample_44_o,
	output logic [width_p-1:0] sample_45_o,
	output logic [width_p-1:0] sample_46_o,
	output logic [width_p-1:0] sample_47_o,
	output logic [width_p-1:0] sample_48_o,
	output logic [width_p-1:0] sample_49_o,
	output logic [width_p-1:0] sample_50_o,
	output logic [width_p-1:0] sample_51_o,
	output logic [width_p-1:0] sample_52_o,
	output logic [width_p-1:0] sample_53_o,
	output logic [width_p-1:0] sample_54_o,
	output logic [width_p-1:0] sample_55_o,
	output logic [width_p-1:0] sample_56_o,
	output logic [width_p-1:0] sample_57_o,
	output logic [width_p-1:0] sample_58_o,
	output logic [width_p-1:0] sample_59_o,
	output logic [width_p-1:0] sample_60_o,
	output logic [width_p-1:0] sample_61_o,
	output logic [width_p-1:0] sample_62_o,
	output logic [width_p-1:0] sample_63_o
	
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

	logic [6:0] row_addr_wire    [0:63];
	logic [6:0] column_addr_wire [0:63];
		
	genvar m, n;
	
	generate
		for (m = 0; m < 64; m = m + 1) begin : UNFLATTEN_ROW
			assign row_addr_wire[m] = row_addr_flat_i[m*7 +: 7];
		end
	endgenerate

	generate
		for (n = 0; n < 64; n = n + 1) begin : UNFLATTEN_COLUMN
			assign column_addr_wire[n] = column_addr_flat_i[n*7 +: 7];
		end
	endgenerate
	
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
				sample_00_o	<= mem[row_addr_wire[0]][column_addr_wire[0]];
				sample_01_o	<= mem[row_addr_wire[1]][column_addr_wire[1]];
				sample_02_o	<= mem[row_addr_wire[2]][column_addr_wire[2]];
				sample_03_o	<= mem[row_addr_wire[3]][column_addr_wire[3]];
				sample_04_o	<= mem[row_addr_wire[4]][column_addr_wire[4]];
				sample_05_o	<= mem[row_addr_wire[5]][column_addr_wire[5]];
				sample_06_o	<= mem[row_addr_wire[6]][column_addr_wire[6]];
				sample_07_o	<= mem[row_addr_wire[7]][column_addr_wire[7]];

				sample_08_o	<= mem[row_addr_wire[8]][column_addr_wire[8]];
				sample_09_o	<= mem[row_addr_wire[9]][column_addr_wire[9]];
				sample_10_o	<= mem[row_addr_wire[10]][column_addr_wire[10]];
				sample_11_o	<= mem[row_addr_wire[11]][column_addr_wire[11]];
				sample_12_o	<= mem[row_addr_wire[12]][column_addr_wire[12]];
				sample_13_o	<= mem[row_addr_wire[13]][column_addr_wire[13]];
				sample_14_o	<= mem[row_addr_wire[14]][column_addr_wire[14]];
				sample_15_o	<= mem[row_addr_wire[15]][column_addr_wire[15]];	

				sample_16_o	<= mem[row_addr_wire[16]][column_addr_wire[16]];
				sample_17_o	<= mem[row_addr_wire[17]][column_addr_wire[17]];
				sample_18_o	<= mem[row_addr_wire[18]][column_addr_wire[18]];
				sample_19_o	<= mem[row_addr_wire[19]][column_addr_wire[19]];
				sample_20_o	<= mem[row_addr_wire[20]][column_addr_wire[20]];
				sample_21_o	<= mem[row_addr_wire[21]][column_addr_wire[21]];
				sample_22_o	<= mem[row_addr_wire[22]][column_addr_wire[22]];
				sample_23_o	<= mem[row_addr_wire[23]][column_addr_wire[23]];	

				sample_24_o	<= mem[row_addr_wire[24]][column_addr_wire[24]];
				sample_25_o	<= mem[row_addr_wire[25]][column_addr_wire[25]];
				sample_26_o	<= mem[row_addr_wire[26]][column_addr_wire[26]];
				sample_27_o	<= mem[row_addr_wire[27]][column_addr_wire[27]];
				sample_28_o	<= mem[row_addr_wire[28]][column_addr_wire[28]];
				sample_29_o	<= mem[row_addr_wire[29]][column_addr_wire[29]];
				sample_30_o	<= mem[row_addr_wire[30]][column_addr_wire[30]];
				sample_31_o	<= mem[row_addr_wire[31]][column_addr_wire[31]];	

				sample_32_o	<= mem[row_addr_wire[32]][column_addr_wire[32]];
				sample_33_o	<= mem[row_addr_wire[33]][column_addr_wire[33]];
				sample_34_o	<= mem[row_addr_wire[34]][column_addr_wire[34]];
				sample_35_o	<= mem[row_addr_wire[35]][column_addr_wire[35]];
				sample_36_o	<= mem[row_addr_wire[36]][column_addr_wire[36]];
				sample_37_o	<= mem[row_addr_wire[37]][column_addr_wire[37]];
				sample_38_o	<= mem[row_addr_wire[38]][column_addr_wire[38]];
				sample_39_o	<= mem[row_addr_wire[39]][column_addr_wire[39]];

				sample_40_o	<= mem[row_addr_wire[40]][column_addr_wire[40]];
				sample_41_o	<= mem[row_addr_wire[41]][column_addr_wire[41]];
				sample_42_o	<= mem[row_addr_wire[42]][column_addr_wire[42]];
				sample_43_o	<= mem[row_addr_wire[43]][column_addr_wire[43]];
				sample_44_o	<= mem[row_addr_wire[44]][column_addr_wire[44]];
				sample_45_o	<= mem[row_addr_wire[45]][column_addr_wire[45]];
				sample_46_o	<= mem[row_addr_wire[46]][column_addr_wire[46]];
				sample_47_o	<= mem[row_addr_wire[47]][column_addr_wire[47]];

				sample_48_o	<= mem[row_addr_wire[48]][column_addr_wire[48]];
				sample_49_o	<= mem[row_addr_wire[49]][column_addr_wire[49]];
				sample_50_o	<= mem[row_addr_wire[50]][column_addr_wire[50]];
				sample_51_o	<= mem[row_addr_wire[51]][column_addr_wire[51]];
				sample_52_o	<= mem[row_addr_wire[52]][column_addr_wire[52]];
				sample_53_o	<= mem[row_addr_wire[53]][column_addr_wire[53]];
				sample_54_o	<= mem[row_addr_wire[54]][column_addr_wire[54]];
				sample_55_o	<= mem[row_addr_wire[55]][column_addr_wire[55]];

				sample_56_o	<= mem[row_addr_wire[56]][column_addr_wire[56]];
				sample_57_o	<= mem[row_addr_wire[57]][column_addr_wire[57]];
				sample_58_o	<= mem[row_addr_wire[58]][column_addr_wire[58]];
				sample_59_o	<= mem[row_addr_wire[59]][column_addr_wire[59]];
				sample_60_o	<= mem[row_addr_wire[60]][column_addr_wire[60]];
				sample_61_o	<= mem[row_addr_wire[61]][column_addr_wire[61]];
				sample_62_o	<= mem[row_addr_wire[62]][column_addr_wire[62]];
				sample_63_o	<= mem[row_addr_wire[63]][column_addr_wire[63]];
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