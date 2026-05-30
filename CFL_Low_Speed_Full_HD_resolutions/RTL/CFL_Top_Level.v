
// CFL Top Level 

module CFL_Top 
  #(
  
	parameter width_p 	    		= 10, 			
	parameter luma_mem_columns		= 64, 
	parameter luma_mem_rows			= 64,
	parameter sub_mem_columns		= 32, 
	parameter sub_mem_rows			= 64	
   
  )
  (

    input wire clk_i,
	input wire rst_i,

	input wire [6:0] block_width_i, 
	input wire [6:0] block_height_i,
	
	input wire data_in_valid_i,
	input wire load_en,
	input wire read_en_mem_sub_i,
	
	input wire subsampling_x_i,
	input wire subsampling_y_i,

	// alpha signals
	input wire alpha_sign_i, 
	input wire [4:0] alpha_index_i,

	input wire [width_p-1:0] sample_0_i,
	input wire [width_p-1:0] sample_1_i,
	input wire [width_p-1:0] sample_2_i,
	input wire [width_p-1:0] sample_3_i,
	input wire [width_p-1:0] sample_4_i,
	input wire [width_p-1:0] sample_5_i,
	input wire [width_p-1:0] sample_6_i,
	input wire [width_p-1:0] sample_7_i,
	input wire [width_p-1:0] sample_8_i,
	input wire [width_p-1:0] sample_9_i,
	input wire [width_p-1:0] sample_10_i,
	input wire [width_p-1:0] sample_11_i,
	input wire [width_p-1:0] sample_12_i,
	input wire [width_p-1:0] sample_13_i,
	input wire [width_p-1:0] sample_14_i,
	input wire [width_p-1:0] sample_15_i,
	
	input wire DC_Chr_ready_i, 
	input wire signed [width_p+1:0] DC_Intra_Chr_i,

	output wire ready_to_load_o,
	output wire seq_mem_ready_o,

	output wire mem_read_finish_o, 
	output wire mem_ready_to_be_read_o,

	output wire [6:0] address_row_final_o,
	output wire [6:0] address_column_final_o,
	
	output wire [width_p+1:0] CFL_final_o,
	output wire CFL_final_ready_o

   );
   
	wire clk;
	wire rst;
	wire subsampling_re; 
	wire subsampling_we; 
	wire samples_loaded; 
	wire mem_ready_to_be_read;
	wire pipe_en; 
	wire mem_read_finish; 

	wire [7:0] block_width;
	wire [7:0] block_height;
	wire [9:0] avg;
	
	wire [6:0] row_addr_a_1;	
	wire [6:0] row_addr_a_2;		
	wire [6:0] column_addr_a_1;  
	wire [6:0] column_addr_a_2;
	
	wire [6:0] row_addr_b_1;	
	wire [6:0] row_addr_b_2;		
	wire [6:0] column_addr_b_1;  
	wire [6:0] column_addr_b_2; 
	
	wire [6:0] row_addr_c_1;	
	wire [6:0] row_addr_c_2;		
	wire [6:0] column_addr_c_1;  
	wire [6:0] column_addr_c_2; 

	wire [7:0] block_sub_row;
	wire [7:0] block_sub_column;

	wire [3:0] div_shift;

	wire [width_p-1:0] sample_in_a_1;
	wire [width_p-1:0] sample_in_a_2;
	wire [width_p-1:0] sample_in_b_1;
	wire [width_p-1:0] sample_in_b_2;

	wire [width_p-1:0] sample_out_a;
	wire [width_p-1:0] sample_out_b;	
	wire [width_p-1:0] sample_out_o; 	

	wire [6:0] address_column_out;
	wire [6:0] address_row_out;	
	wire CFL_final_ready; 
	wire luma_memory_rst; 
	
	assign clk = clk_i; 
	assign rst = rst_i; 
	
	assign block_width    = (subsampling_x_i && subsampling_y_i)    ? block_width_i  << 1 : 	
						    (subsampling_x_i && (!subsampling_y_i)) ? block_width_i  << 1 : 
						    block_width_i;
						  
						  
	assign block_height   = (subsampling_x_i && subsampling_y_i) 	? block_height_i << 1 : 	 
						    (subsampling_x_i && (!subsampling_y_i)) ? block_height_i      :
						    block_height_i;

	luma_memory #(
	
		.width_p(width_p),
		.columns(luma_mem_columns),
		.rows(luma_mem_rows)
		
	) luma_mem_inst
	(
		.clk_i(clk),
		.rst_i(rst),
		.luma_memory_rst_i(luma_memory_rst),
		
		.data_in_valid_i(data_in_valid_i),
		.block_width_i(block_width), 
		.block_height_i(block_height), 
		
		.sample_0_i(sample_0_i),
		.sample_1_i(sample_1_i),
		.sample_2_i(sample_2_i),
		.sample_3_i(sample_3_i),
		.sample_4_i(sample_4_i),
		.sample_5_i(sample_5_i),
		.sample_6_i(sample_6_i),
		.sample_7_i(sample_7_i),
		.sample_8_i(sample_8_i),
		.sample_9_i(sample_9_i),
		.sample_10_i(sample_10_i),
		.sample_11_i(sample_11_i),
		.sample_12_i(sample_12_i),
		.sample_13_i(sample_13_i),
		.sample_14_i(sample_14_i),
		.sample_15_i(sample_15_i),

		.ready_to_load_o(ready_to_load_o),
		.seq_mem_ready_o(seq_mem_ready_o),
		
		.subsampling_re_i(subsampling_re),
		
		.row_addr_a_1_i(row_addr_a_1), 
		.column_addr_a_1_i(column_addr_a_1), 
		.row_addr_a_2_i(row_addr_a_2), 
		.column_addr_a_2_i(column_addr_a_2), 
		
		.row_addr_b_1_i(row_addr_b_1), 
		.column_addr_b_1_i(column_addr_b_1), 
		.row_addr_b_2_i(row_addr_b_2),
		.column_addr_b_2_i(column_addr_b_2),
		
		.sample_out_a_1_o(sample_in_a_1),
		.sample_out_a_2_o(sample_in_a_2),
		.sample_out_b_1_o(sample_in_b_1),
		.sample_out_b_2_o(sample_in_b_2)

    );

    subsampling_machine #(
	
		.width_p(width_p)
		
	) sub_sampling_machine_inst
	(
		.clk_i(clk),
		.rst_i(rst),
	
		.subsampling_x_i(subsampling_x_i),
		.subsampling_y_i(subsampling_y_i),
	
		.block_width_i(block_width), 
		.block_height_i(block_height), 
	
		.sample_in_a_1_i(sample_in_a_1),
		.sample_in_a_2_i(sample_in_a_2),
	
		.sample_in_b_1_i(sample_in_b_1),
		.sample_in_b_2_i(sample_in_b_2),
	
		.load_en_i(load_en), 
		.mem_read_en_o(subsampling_re),
		.mem_write_en_o(subsampling_we),
		//.luma_memory_rst_o(luma_memory_rst),
		
		.row_addr_a_1_o(row_addr_a_1),
		.column_addr_a_1_o(column_addr_a_1),	
		.row_addr_a_2_o(row_addr_a_2),
		.column_addr_a_2_o(column_addr_a_2),
	
		.row_addr_b_1_o(row_addr_b_1),
		.column_addr_b_1_o(column_addr_b_1),
		.row_addr_b_2_o(row_addr_b_2),
		.column_addr_b_2_o(column_addr_b_2),

		.row_addr_c_1_o(row_addr_c_1),
		.column_addr_c_1_o(column_addr_c_1),
		.row_addr_c_2_o(row_addr_c_2),
		.column_addr_c_2_o(column_addr_c_2),

		.sample_out_a_o(sample_out_a), 
		.sample_out_b_o(sample_out_b),
		
		.div_shift_o(div_shift),

		.samples_loaded_o(samples_loaded),
		.block_sub_row_o(block_sub_row),
		.block_sub_column_o(block_sub_column)
		
    );
	
    subsampling_memory #(
	
		.width_p(width_p),
		.columns(sub_mem_columns),
		.rows(sub_mem_rows)
		
	) sub_memory_inst
	(	

		.clk_i(clk),
		.rst_i(rst),
		
		.mem_write_en_i(subsampling_we),
		.mem_read_en_i(read_en_mem_sub_i),
		
		.sample_in_a_i(sample_out_a),
		.sample_in_b_i(sample_out_b),
	
		.block_sub_row_i(block_sub_row),
		.block_sub_column_i(block_sub_column),
		
		.row_addr_c_1_i(row_addr_c_1),
		.column_addr_c_1_i(column_addr_c_1),
		.row_addr_c_2_i(row_addr_c_2),
		.column_addr_c_2_i(column_addr_c_2),
	
		.div_shift_i(div_shift),
		.samples_loaded_i(samples_loaded),
		
		.sample_out_o(sample_out_o),
		.mem_ready_to_be_read_o(mem_ready_to_be_read),
		
		.address_row_o(address_row_out),
		.address_column_o(address_column_out),
		.avg_o(avg),
		
		.pipe_en_o(pipe_en),
		.CFL_final_ready_o(CFL_final_ready),
		
		.mem_read_finish_o(mem_read_finish_o)
	
	);

    output_pipeline #(
	
		.width_p(width_p)
		
	) output_pipeline_inst
	(		
		.clk_i(clk),
	    .rst_i(rst),
		.sample_i(sample_out_o),
		.address_row_i(address_row_out),
	    .address_column_i(address_column_out),
		
		.DC_Chr_ready_i(DC_Chr_ready_i),
		.DC_Intra_Chr_i(DC_Intra_Chr_i),
		
		.avg_en_i(mem_ready_to_be_read),
		.avg_i(avg),
		
		.alpha_sign_i(alpha_sign_i),
		.alpha_index_i(alpha_index_i),
		
		.pipe_en_i(pipe_en),
		.mem_read_finish_i(mem_read_finish_o),
		.CFL_final_ready_i(CFL_final_ready),
		
		.address_row_o(address_row_final_o),
		.address_column_o(address_column_final_o),
		.luma_memory_rst_o(luma_memory_rst),
		.CFL_final_ready_o(CFL_final_ready_o), 
		.CFL_final_o(CFL_final_o)
		
	);
	
	assign mem_ready_to_be_read_o = mem_ready_to_be_read;
	
endmodule 