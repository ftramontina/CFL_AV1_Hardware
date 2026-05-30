
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
	
	wire [width_p-1:0] sample_00;
	wire [width_p-1:0] sample_01;
	wire [width_p-1:0] sample_02;
	wire [width_p-1:0] sample_03;
	wire [width_p-1:0] sample_04;
	wire [width_p-1:0] sample_05;
	wire [width_p-1:0] sample_06;
	wire [width_p-1:0] sample_07;
	wire [width_p-1:0] sample_08;
	wire [width_p-1:0] sample_09;
	wire [width_p-1:0] sample_10;
	wire [width_p-1:0] sample_11;
	wire [width_p-1:0] sample_12;
	wire [width_p-1:0] sample_13;
	wire [width_p-1:0] sample_14;
	wire [width_p-1:0] sample_15;
	wire [width_p-1:0] sample_16;
	wire [width_p-1:0] sample_17;
	wire [width_p-1:0] sample_18;
	wire [width_p-1:0] sample_19;
	wire [width_p-1:0] sample_20;
	wire [width_p-1:0] sample_21;
	wire [width_p-1:0] sample_22;
	wire [width_p-1:0] sample_23;
	wire [width_p-1:0] sample_24;
	wire [width_p-1:0] sample_25;
	wire [width_p-1:0] sample_26;
	wire [width_p-1:0] sample_27;
	wire [width_p-1:0] sample_28;
	wire [width_p-1:0] sample_29;
	wire [width_p-1:0] sample_30;
	wire [width_p-1:0] sample_31;
	wire [width_p-1:0] sample_32;
	wire [width_p-1:0] sample_33;
	wire [width_p-1:0] sample_34;
	wire [width_p-1:0] sample_35;
	wire [width_p-1:0] sample_36;
	wire [width_p-1:0] sample_37;
	wire [width_p-1:0] sample_38;
	wire [width_p-1:0] sample_39;
	wire [width_p-1:0] sample_40;
	wire [width_p-1:0] sample_41;
	wire [width_p-1:0] sample_42;
	wire [width_p-1:0] sample_43;
	wire [width_p-1:0] sample_44;
	wire [width_p-1:0] sample_45;
	wire [width_p-1:0] sample_46;
	wire [width_p-1:0] sample_47;
	wire [width_p-1:0] sample_48;
	wire [width_p-1:0] sample_49;
	wire [width_p-1:0] sample_50;
	wire [width_p-1:0] sample_51;
	wire [width_p-1:0] sample_52;
	wire [width_p-1:0] sample_53;
	wire [width_p-1:0] sample_54;
	wire [width_p-1:0] sample_55;
	wire [width_p-1:0] sample_56;
	wire [width_p-1:0] sample_57;
	wire [width_p-1:0] sample_58;
	wire [width_p-1:0] sample_59;
	wire [width_p-1:0] sample_60;
	wire [width_p-1:0] sample_61;
	wire [width_p-1:0] sample_62;
	wire [width_p-1:0] sample_63;
	
	wire [7:0] block_sub_row;
	wire [7:0] block_sub_column;

	wire [3:0] div_shift;

	wire [width_p-1:0] sample_out_00;
	wire [width_p-1:0] sample_out_01;
	wire [width_p-1:0] sample_out_02;
	wire [width_p-1:0] sample_out_03;
	wire [width_p-1:0] sample_out_04;
	wire [width_p-1:0] sample_out_05;
	wire [width_p-1:0] sample_out_06;
	wire [width_p-1:0] sample_out_07;
	wire [width_p-1:0] sample_out_08;
	wire [width_p-1:0] sample_out_09;
	wire [width_p-1:0] sample_out_10;
	wire [width_p-1:0] sample_out_11;
	wire [width_p-1:0] sample_out_12;
	wire [width_p-1:0] sample_out_13;
	wire [width_p-1:0] sample_out_14;
	wire [width_p-1:0] sample_out_15;
	
	wire [64*7-1:0] row_addr_flat;
	wire [64*7-1:0] column_addr_flat;

	wire [16*7-1:0] row_addr_sub_flat;
	wire [16*7-1:0] column_addr_sub_flat;

	wire [6:0] address_column_out;
	wire [6:0] address_row_out;	
	wire CFL_final_ready; 
	wire luma_memory_rst; 
	
	wire [width_p-1:0] sample_in_00_o;
	wire [width_p-1:0] sample_in_01_o;
	wire [width_p-1:0] sample_in_02_o;
	wire [width_p-1:0] sample_in_03_o;
	wire [width_p-1:0] sample_in_04_o;
	wire [width_p-1:0] sample_in_05_o;
	wire [width_p-1:0] sample_in_06_o;
	wire [width_p-1:0] sample_in_07_o;
	wire [width_p-1:0] sample_in_08_o;
	wire [width_p-1:0] sample_in_09_o;
	wire [width_p-1:0] sample_in_10_o;
	wire [width_p-1:0] sample_in_11_o;
	wire [width_p-1:0] sample_in_12_o;
	wire [width_p-1:0] sample_in_13_o;
	wire [width_p-1:0] sample_in_14_o;
	wire [width_p-1:0] sample_in_15_o;

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
		
		.row_addr_flat_i(row_addr_flat),
		.column_addr_flat_i(column_addr_flat),
		
		.sample_00_o(sample_00),
		.sample_01_o(sample_01),
		.sample_02_o(sample_02),
		.sample_03_o(sample_03),
		.sample_04_o(sample_04),
		.sample_05_o(sample_05),
		.sample_06_o(sample_06),
		.sample_07_o(sample_07),
		.sample_08_o(sample_08),
		.sample_09_o(sample_09),
		.sample_10_o(sample_10),
		.sample_11_o(sample_11),
		.sample_12_o(sample_12),
		.sample_13_o(sample_13),
		.sample_14_o(sample_14),
		.sample_15_o(sample_15),
		.sample_16_o(sample_16),
		.sample_17_o(sample_17),
		.sample_18_o(sample_18),
		.sample_19_o(sample_19),
		.sample_20_o(sample_20),
		.sample_21_o(sample_21),
		.sample_22_o(sample_22),
		.sample_23_o(sample_23),
		.sample_24_o(sample_24),
		.sample_25_o(sample_25),
		.sample_26_o(sample_26),
		.sample_27_o(sample_27),
		.sample_28_o(sample_28),
		.sample_29_o(sample_29),
		.sample_30_o(sample_30),
		.sample_31_o(sample_31),
		.sample_32_o(sample_32),
		.sample_33_o(sample_33),
		.sample_34_o(sample_34),
		.sample_35_o(sample_35),
		.sample_36_o(sample_36),
		.sample_37_o(sample_37),
		.sample_38_o(sample_38),
		.sample_39_o(sample_39),
		.sample_40_o(sample_40),
		.sample_41_o(sample_41),
		.sample_42_o(sample_42),
		.sample_43_o(sample_43),
		.sample_44_o(sample_44),
		.sample_45_o(sample_45),
		.sample_46_o(sample_46),
		.sample_47_o(sample_47),
		.sample_48_o(sample_48),
		.sample_49_o(sample_49),
		.sample_50_o(sample_50),
		.sample_51_o(sample_51),
		.sample_52_o(sample_52),
		.sample_53_o(sample_53),
		.sample_54_o(sample_54),
		.sample_55_o(sample_55),
		.sample_56_o(sample_56),
		.sample_57_o(sample_57),
		.sample_58_o(sample_58),
		.sample_59_o(sample_59),
		.sample_60_o(sample_60),
		.sample_61_o(sample_61),
		.sample_62_o(sample_62),
		.sample_63_o(sample_63)

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
	
		.sample_00_in(sample_00),
		.sample_01_in(sample_01),
		.sample_02_in(sample_02),
		.sample_03_in(sample_03),
		.sample_04_in(sample_04),
		.sample_05_in(sample_05),
		.sample_06_in(sample_06),
		.sample_07_in(sample_07),
		.sample_08_in(sample_08),
		.sample_09_in(sample_09),
		.sample_10_in(sample_10),
		.sample_11_in(sample_11),
		.sample_12_in(sample_12),
		.sample_13_in(sample_13),
		.sample_14_in(sample_14),
		.sample_15_in(sample_15),
		.sample_16_in(sample_16),
		.sample_17_in(sample_17),
		.sample_18_in(sample_18),
		.sample_19_in(sample_19),
		.sample_20_in(sample_20),
		.sample_21_in(sample_21),
		.sample_22_in(sample_22),
		.sample_23_in(sample_23),
		.sample_24_in(sample_24),
		.sample_25_in(sample_25),
		.sample_26_in(sample_26),
		.sample_27_in(sample_27),
		.sample_28_in(sample_28),
		.sample_29_in(sample_29),
		.sample_30_in(sample_30),
		.sample_31_in(sample_31),
		.sample_32_in(sample_32),
		.sample_33_in(sample_33),
		.sample_34_in(sample_34),
		.sample_35_in(sample_35),
		.sample_36_in(sample_36),
		.sample_37_in(sample_37),
		.sample_38_in(sample_38),
		.sample_39_in(sample_39),
		.sample_40_in(sample_40),
		.sample_41_in(sample_41),
		.sample_42_in(sample_42),
		.sample_43_in(sample_43),
		.sample_44_in(sample_44),
		.sample_45_in(sample_45),
		.sample_46_in(sample_46),
		.sample_47_in(sample_47),
		.sample_48_in(sample_48),
		.sample_49_in(sample_49),
		.sample_50_in(sample_50),
		.sample_51_in(sample_51),
		.sample_52_in(sample_52),
		.sample_53_in(sample_53),
		.sample_54_in(sample_54),
		.sample_55_in(sample_55),
		.sample_56_in(sample_56),
		.sample_57_in(sample_57),
		.sample_58_in(sample_58),
		.sample_59_in(sample_59),
		.sample_60_in(sample_60),
		.sample_61_in(sample_61),
		.sample_62_in(sample_62),
		.sample_63_in(sample_63),

		.load_en_i(load_en), 
		.mem_read_en_o(subsampling_re),
		.mem_write_en_o(subsampling_we),
		//.luma_memory_rst_o(luma_memory_rst),
		
		.row_addr_flat_o(row_addr_flat),
		.column_addr_flat_o(column_addr_flat),
		
		.row_addr_sub_flat_o(row_addr_sub_flat),
		.column_addr_sub_flat_o(column_addr_sub_flat),
		
		.sample_out_00_o(sample_out_00),
		.sample_out_01_o(sample_out_01),
		.sample_out_02_o(sample_out_02),
		.sample_out_03_o(sample_out_03),
		.sample_out_04_o(sample_out_04),
		.sample_out_05_o(sample_out_05),
		.sample_out_06_o(sample_out_06),
		.sample_out_07_o(sample_out_07),
		.sample_out_08_o(sample_out_08),
		.sample_out_09_o(sample_out_09),
		.sample_out_10_o(sample_out_10),
		.sample_out_11_o(sample_out_11),
		.sample_out_12_o(sample_out_12),
		.sample_out_13_o(sample_out_13),
		.sample_out_14_o(sample_out_14),
		.sample_out_15_o(sample_out_15),

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

		.block_width_i(block_width), 
		.block_height_i(block_height), 
		
		.sample_in_00_i(sample_out_00),
		.sample_in_01_i(sample_out_01),
		.sample_in_02_i(sample_out_02),
		.sample_in_03_i(sample_out_03),
		.sample_in_04_i(sample_out_04),
		.sample_in_05_i(sample_out_05),
		.sample_in_06_i(sample_out_06),
		.sample_in_07_i(sample_out_07),
		.sample_in_08_i(sample_out_08),
		.sample_in_09_i(sample_out_09),
		.sample_in_10_i(sample_out_10),
		.sample_in_11_i(sample_out_11),
		.sample_in_12_i(sample_out_12),
		.sample_in_13_i(sample_out_13),
		.sample_in_14_i(sample_out_14),
		.sample_in_15_i(sample_out_15),
		
		.block_sub_row_i(block_sub_row),
		.block_sub_column_i(block_sub_column),
		
		.row_addr_sub_flat_i(row_addr_sub_flat),
		.column_addr_sub_flat_i(column_addr_sub_flat),
	
		.div_shift_i(div_shift),
		.samples_loaded_i(samples_loaded),
		
		.sample_out_00_o(sample_in_00_o),
		.sample_out_01_o(sample_in_01_o),
		.sample_out_02_o(sample_in_02_o),
		.sample_out_03_o(sample_in_03_o),
		.sample_out_04_o(sample_in_04_o),
		.sample_out_05_o(sample_in_05_o),
		.sample_out_06_o(sample_in_06_o),
		.sample_out_07_o(sample_in_07_o),
		.sample_out_08_o(sample_in_08_o),
		.sample_out_09_o(sample_in_09_o),
		.sample_out_10_o(sample_in_10_o),
		.sample_out_11_o(sample_in_11_o),
		.sample_out_12_o(sample_in_12_o),
		.sample_out_13_o(sample_in_13_o),
		.sample_out_14_o(sample_in_14_o),
		.sample_out_15_o(sample_in_15_o),
		
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
		
		.block_width_i(block_width), 
		.block_height_i(block_height), 

		.sample_in_00_i(sample_in_00_o),
		.sample_in_01_i(sample_in_01_o),
		.sample_in_02_i(sample_in_02_o),
		.sample_in_03_i(sample_in_03_o),
		.sample_in_04_i(sample_in_04_o),
		.sample_in_05_i(sample_in_05_o),
		.sample_in_06_i(sample_in_06_o),
		.sample_in_07_i(sample_in_07_o),
		.sample_in_08_i(sample_in_08_o),
		.sample_in_09_i(sample_in_09_o),
		.sample_in_10_i(sample_in_10_o),
		.sample_in_11_i(sample_in_11_o),
		.sample_in_12_i(sample_in_12_o),
		.sample_in_13_i(sample_in_13_o),
		.sample_in_14_i(sample_in_14_o),
		.sample_in_15_i(sample_in_15_o),

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
	
	assign mem_ready_to_be_read_o = mem_ready_to_be_read;
	
endmodule 