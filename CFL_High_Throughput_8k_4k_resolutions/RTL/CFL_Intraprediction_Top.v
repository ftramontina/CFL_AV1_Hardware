
// CFL Top Level 

module CFL_Intraprediction_Top 
  #(
  
	parameter width_p 	    		= 10, 			
	parameter luma_mem_columns		= 64, 
	parameter luma_mem_rows			= 64,
	parameter sub_mem_columns		= 32, 
	parameter sub_mem_rows			= 64,
	parameter samples_n_p			= 16	
	
  )
  (
	input wire clk_i,
	input wire rst_i,
	
	input wire chr_data_in_valid_left_i, 
	input wire chr_data_in_valid_top_i, 
	input wire luma_data_in_valid_i, 
	
	input wire subsampling_x_i,
	input wire subsampling_y_i,
	
	input wire [6:0] block_height_i, 
    input wire [6:0] block_width_i,
	
	input wire [width_p-1:0] chr_sample_left_0_i,
	input wire [width_p-1:0] chr_sample_left_1_i,	
	input wire [width_p-1:0] chr_sample_left_2_i,	
	input wire [width_p-1:0] chr_sample_left_3_i,	
	
	input wire [width_p-1:0] chr_sample_top_0_i,
	input wire [width_p-1:0] chr_sample_top_1_i,	
	input wire [width_p-1:0] chr_sample_top_2_i,	
	input wire [width_p-1:0] chr_sample_top_3_i,	
	
	input wire [width_p-1:0] luma_sample_0_i,
	input wire [width_p-1:0] luma_sample_1_i,
	input wire [width_p-1:0] luma_sample_2_i,
	input wire [width_p-1:0] luma_sample_3_i,
	input wire [width_p-1:0] luma_sample_4_i,
	input wire [width_p-1:0] luma_sample_5_i,
	input wire [width_p-1:0] luma_sample_6_i,
	input wire [width_p-1:0] luma_sample_7_i,
	input wire [width_p-1:0] luma_sample_8_i,
	input wire [width_p-1:0] luma_sample_9_i,
	input wire [width_p-1:0] luma_sample_10_i,
	input wire [width_p-1:0] luma_sample_11_i,
	input wire [width_p-1:0] luma_sample_12_i,
	input wire [width_p-1:0] luma_sample_13_i,
	input wire [width_p-1:0] luma_sample_14_i,
	input wire [width_p-1:0] luma_sample_15_i,

	input wire alpha_sign_i, 
	input wire [4:0] alpha_index_i,

	input wire chr_above_i,
	input wire chr_left_i,
	
	output wire chr_ready_to_load_left_o,	
	output wire chr_ready_to_load_top_o,
	output wire luma_ready_to_load_o,

	output wire [6:0] address_i_final_o,
	output wire [6:0] address_j_final_o,
	
	output wire [width_p+1:0] CFL_final_0_o,
	output wire [width_p+1:0] CFL_final_1_o,
	output wire [width_p+1:0] CFL_final_2_o,
	output wire [width_p+1:0] CFL_final_3_o,
	output wire [width_p+1:0] CFL_final_4_o,
	output wire [width_p+1:0] CFL_final_5_o,
	output wire [width_p+1:0] CFL_final_6_o,
	output wire [width_p+1:0] CFL_final_7_o,
	output wire [width_p+1:0] CFL_final_8_o,
	output wire [width_p+1:0] CFL_final_9_o,
	output wire [width_p+1:0] CFL_final_10_o,
	output wire [width_p+1:0] CFL_final_11_o,
	output wire [width_p+1:0] CFL_final_12_o,
	output wire [width_p+1:0] CFL_final_13_o,
	output wire [width_p+1:0] CFL_final_14_o,
	output wire [width_p+1:0] CFL_final_15_o,

	output wire CFL_final_ready_o
	
   );

	wire DC_ready;
	wire DC_ready_Chr; 
	wire read_en_mem_sub;
	wire subsampling_load_en; 
	wire mem_ready_to_be_read; 
	wire signed [width_p+1:0] DC_Intra_Chr; 
	wire signed [width_p+1:0] DC_intrapred_data_out; 
	
	DC_intraprediction #(
	
		.width_p(width_p),
		.samples_n_p(samples_n_p)
		
	) DC_intraprediction_inst 
	(
		.clk_i(clk_i),
		.rst_i(rst_i),
		
		.data_in_valid_left_i(chr_data_in_valid_left_i),
		.data_in_valid_top_i(chr_data_in_valid_top_i),
		
		.sample_number_left_i(block_height_i),  // the sample number is also the enable of the block - 
		.sample_number_top_i(block_width_i),	// the sample number is also the enable of the block -
		
		.sample_left_0_i(chr_sample_left_0_i),
		.sample_left_1_i(chr_sample_left_1_i),
		.sample_left_2_i(chr_sample_left_2_i),
		.sample_left_3_i(chr_sample_left_3_i),

		.sample_top_0_i(chr_sample_top_0_i),
		.sample_top_1_i(chr_sample_top_1_i),
		.sample_top_2_i(chr_sample_top_2_i),
		.sample_top_3_i(chr_sample_top_3_i),		
		
		.above(chr_above_i),
		.left(chr_left_i),
	
		.ready_to_load_left_o(chr_ready_to_load_left_o),	
		.ready_to_load_top_o(chr_ready_to_load_top_o),
		.ready_o(DC_ready),	
		.intrapred_data_out_o(DC_intrapred_data_out)

    );
	
    CFL_Top #(
	
		.width_p(width_p),
		.luma_mem_columns(luma_mem_columns),
		.luma_mem_rows(luma_mem_rows),
		.sub_mem_columns(sub_mem_columns),
		.sub_mem_rows(sub_mem_rows)		
		
	) CFL_Top_inst
	(
		.clk_i(clk_i),
		.rst_i(rst_i),

		.block_width_i(block_width_i), 
		.block_height_i(block_height_i),
	
		.data_in_valid_i(luma_data_in_valid_i),
		.load_en(subsampling_load_en), 			//subsampling load enable   [sub mach]   - from control block 
		.read_en_mem_sub_i(read_en_mem_sub), 	//subsampling memory enable [sub mem]    - from control block  
	
		.subsampling_x_i(subsampling_x_i),
		.subsampling_y_i(subsampling_y_i),

		.alpha_sign_i(alpha_sign_i), 
		.alpha_index_i(alpha_index_i),

		.sample_0_i(luma_sample_0_i),
		.sample_1_i(luma_sample_1_i),
		.sample_2_i(luma_sample_2_i),
		.sample_3_i(luma_sample_3_i),
		.sample_4_i(luma_sample_4_i),
		.sample_5_i(luma_sample_5_i),
		.sample_6_i(luma_sample_6_i),
		.sample_7_i(luma_sample_7_i),
		.sample_8_i(luma_sample_8_i),
		.sample_9_i(luma_sample_9_i),
		.sample_10_i(luma_sample_10_i),
		.sample_11_i(luma_sample_11_i),
		.sample_12_i(luma_sample_12_i),
		.sample_13_i(luma_sample_13_i),
		.sample_14_i(luma_sample_14_i),
		.sample_15_i(luma_sample_15_i),
		
		.DC_Chr_ready_i(DC_ready_Chr), 		// block control ? => must be ready when read_en_mem_sub = 1
		.DC_Intra_Chr_i(DC_Intra_Chr),

		.ready_to_load_o(luma_ready_to_load_o),
		.seq_mem_ready_o(seq_mem_ready),		// block control	

		.mem_read_finish_o(mem_read_finish),	// block control
		.mem_ready_to_be_read_o(mem_ready_to_be_read),
		
		.address_row_final_o(address_i_final_o),
		.address_column_final_o(address_j_final_o),
		
		.CFL_final_0_o(CFL_final_0_o),
		.CFL_final_1_o(CFL_final_1_o),
		.CFL_final_2_o(CFL_final_2_o),
		.CFL_final_3_o(CFL_final_3_o),
		.CFL_final_4_o(CFL_final_4_o),
		.CFL_final_5_o(CFL_final_5_o),
		.CFL_final_6_o(CFL_final_6_o),
		.CFL_final_7_o(CFL_final_7_o),
		.CFL_final_8_o(CFL_final_8_o),
		.CFL_final_9_o(CFL_final_9_o),
		.CFL_final_10_o(CFL_final_10_o),
		.CFL_final_11_o(CFL_final_11_o),
		.CFL_final_12_o(CFL_final_12_o),
		.CFL_final_13_o(CFL_final_13_o),
		.CFL_final_14_o(CFL_final_14_o),
		.CFL_final_15_o(CFL_final_15_o),
		
		.CFL_final_ready_o(CFL_final_ready_o)

    );
	
	Control_Unit #(
	
		.width_p(width_p)
		
	) Control_Unit_Inst  
	(
		.clk_i(clk_i),
		.rst_i(rst_i), 
		
		.mem_read_finish_i(mem_read_finish),
		.seq_mem_ready_i(seq_mem_ready), 
		.mem_ready_to_be_read_i(mem_ready_to_be_read),
		
		.DC_intrapred_i(DC_intrapred_data_out),
		.DC_ready_i(DC_ready),
		
		.load_en_o(subsampling_load_en), 
		.read_en_mem_sub_o(read_en_mem_sub),
		
		.DC_intrapred_data_out_o(DC_Intra_Chr),
		.DC_intrapred_data_out_ready_o(DC_ready_Chr)
	);
	
endmodule		
	
	
	

