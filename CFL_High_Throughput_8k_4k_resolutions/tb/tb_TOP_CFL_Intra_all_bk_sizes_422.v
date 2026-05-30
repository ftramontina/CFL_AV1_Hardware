`timescale 1ns / 1ps
module tb_CFL_Intra_top_all_block_comb_sizes_422;

	parameter width_p 	 			= 10; 		
	parameter samples_n_p			= 16;
	parameter luma_mem_columns_p	= 64; 
	parameter luma_mem_rows_p		= 64;
	parameter sub_mem_columns_p		= 32; 
	parameter sub_mem_rows_p		= 64;	

	reg clk 					= 0;
	reg rst 					= 0;
	reg chr_data_in_valid_left	= 0;
	reg chr_data_in_valid_top	= 0;
	reg luma_data_in_valid		= 0;
	reg subsampling_x     		= 0;
	reg subsampling_y     		= 0;

	reg [6:0] columns_num 		= 0;
	reg [6:0] rows_num  		= 0;
	
	reg [width_p-1:0] chr_sample_left_0 = 0;
	reg [width_p-1:0] chr_sample_left_1 = 0;	
	reg [width_p-1:0] chr_sample_left_2 = 0;	
	reg [width_p-1:0] chr_sample_left_3 = 0;	

	reg [width_p-1:0] chr_sample_top_0 = 0;
	reg [width_p-1:0] chr_sample_top_1 = 0;	
	reg [width_p-1:0] chr_sample_top_2 = 0;	
	reg [width_p-1:0] chr_sample_top_3 = 0;
	
	reg [width_p-1:0] luma_sample_0_i = 0;
	reg [width_p-1:0] luma_sample_1_i = 0;
	reg [width_p-1:0] luma_sample_2_i = 0;
	reg [width_p-1:0] luma_sample_3_i = 0;
	reg [width_p-1:0] luma_sample_4_i = 0;
	reg [width_p-1:0] luma_sample_5_i = 0;
	reg [width_p-1:0] luma_sample_6_i = 0;
	reg [width_p-1:0] luma_sample_7_i = 0;
	reg [width_p-1:0] luma_sample_8_i = 0;
	reg [width_p-1:0] luma_sample_9_i = 0;
	reg [width_p-1:0] luma_sample_10_i = 0;
	reg [width_p-1:0] luma_sample_11_i = 0;
	reg [width_p-1:0] luma_sample_12_i = 0;
	reg [width_p-1:0] luma_sample_13_i = 0;
	reg [width_p-1:0] luma_sample_14_i = 0;
	reg [width_p-1:0] luma_sample_15_i = 0;

	reg [4:0] alpha_index = 0;
	reg alpha_sign		  = 0;
	
	reg chr_above  = 0;
	reg chr_left   = 0;
	
	reg start = 1;
	
	wire chr_ready_to_load_left;
	wire chr_ready_to_load_top;
	wire luma_ready_to_load;
	
	wire [6:0] address_i_final;
	wire [6:0] address_j_final;
	
	wire [width_p+1:0] CFL_final_0_o;
	wire [width_p+1:0] CFL_final_1_o;
	wire [width_p+1:0] CFL_final_2_o;
	wire [width_p+1:0] CFL_final_3_o;
	wire [width_p+1:0] CFL_final_4_o;
	wire [width_p+1:0] CFL_final_5_o;
	wire [width_p+1:0] CFL_final_6_o;
	wire [width_p+1:0] CFL_final_7_o;
	wire [width_p+1:0] CFL_final_8_o;
	wire [width_p+1:0] CFL_final_9_o;
	wire [width_p+1:0] CFL_final_10_o;
	wire [width_p+1:0] CFL_final_11_o;
	wire [width_p+1:0] CFL_final_12_o;
	wire [width_p+1:0] CFL_final_13_o;
	wire [width_p+1:0] CFL_final_14_o;
	wire [width_p+1:0] CFL_final_15_o;
	wire CFL_final_ready;
	
	integer j_0, j_1, j_2, j_3, j_4, j_5, j_6, j_7;
	
	reg test = 0;
	
	CFL_Intraprediction_Top #(
	
		.width_p(width_p),
		.luma_mem_columns(luma_mem_columns_p),
		.luma_mem_rows(luma_mem_rows_p),
		.sub_mem_columns(sub_mem_columns_p),
		.sub_mem_rows(sub_mem_rows_p),
		.samples_n_p(samples_n_p)	
		
	) CFL_Intraprediction_Top_Inst 
	(
		.clk_i(clk),
		.rst_i(rst),

		.chr_data_in_valid_left_i(chr_data_in_valid_left), 
		.chr_data_in_valid_top_i(chr_data_in_valid_top), 
		.luma_data_in_valid_i(luma_data_in_valid), 

		.subsampling_x_i(subsampling_x),
		.subsampling_y_i(subsampling_y),

		.block_height_i(rows_num), 
		.block_width_i(columns_num), 

		.chr_sample_left_0_i(chr_sample_left_0),
		.chr_sample_left_1_i(chr_sample_left_1),
		.chr_sample_left_2_i(chr_sample_left_2),
		.chr_sample_left_3_i(chr_sample_left_3),

		.chr_sample_top_0_i(chr_sample_top_0),
		.chr_sample_top_1_i(chr_sample_top_1),
		.chr_sample_top_2_i(chr_sample_top_2),
		.chr_sample_top_3_i(chr_sample_top_3),	

		.luma_sample_0_i(luma_sample_0_i),
		.luma_sample_1_i(luma_sample_1_i),
		.luma_sample_2_i(luma_sample_2_i),
		.luma_sample_3_i(luma_sample_3_i),
		.luma_sample_4_i(luma_sample_4_i),
		.luma_sample_5_i(luma_sample_5_i),
		.luma_sample_6_i(luma_sample_6_i),
		.luma_sample_7_i(luma_sample_7_i),
		.luma_sample_8_i(luma_sample_8_i),
		.luma_sample_9_i(luma_sample_9_i),
		.luma_sample_10_i(luma_sample_10_i),
		.luma_sample_11_i(luma_sample_11_i),
		.luma_sample_12_i(luma_sample_12_i),
		.luma_sample_13_i(luma_sample_13_i),
		.luma_sample_14_i(luma_sample_14_i),
		.luma_sample_15_i(luma_sample_15_i),		
		
		.alpha_sign_i(alpha_sign), 
		.alpha_index_i(alpha_index),

		.chr_above_i(chr_above),
		.chr_left_i(chr_left),

		.chr_ready_to_load_left_o(chr_ready_to_load_left),	
		.chr_ready_to_load_top_o(chr_ready_to_load_top),
		.luma_ready_to_load_o(luma_ready_to_load),

		.address_i_final_o(address_i_final),
		.address_j_final_o(address_j_final),
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
		.CFL_final_ready_o(CFL_final_ready)
		
	);
	

	task load_sample_left(input [width_p-1:0] sample_val_0, input [width_p-1:0] sample_val_1, input [width_p-1:0] sample_val_2, input [width_p-1:0] sample_val_3);
		begin
			chr_sample_left_0 = sample_val_0;
			chr_sample_left_1 = sample_val_1;
			chr_sample_left_2 = sample_val_2;
			chr_sample_left_3 = sample_val_3;
			
			chr_data_in_valid_left = 1;
			@(posedge clk);
			chr_data_in_valid_left = 0;
		end
	endtask

	task load_sample_top(input [width_p-1:0] sample_val_0, input [width_p-1:0] sample_val_1, input [width_p-1:0] sample_val_2, input [width_p-1:0] sample_val_3);
		begin
			chr_sample_top_0 = sample_val_0;
			chr_sample_top_1 = sample_val_1;
			chr_sample_top_2 = sample_val_2;
			chr_sample_top_3 = sample_val_3;
			
			chr_data_in_valid_top = 1;
			@(posedge clk);
			chr_data_in_valid_top = 0;
		end
	endtask

	task load_sample_left_top
	(	
		input [width_p-1:0] sample_val_left_0,
		input [width_p-1:0] sample_val_left_1,
		input [width_p-1:0] sample_val_left_2,
		input [width_p-1:0] sample_val_left_3,
		input [width_p-1:0] sample_val_top_0, 
		input [width_p-1:0] sample_val_top_1,
	    input [width_p-1:0] sample_val_top_2,
	    input [width_p-1:0] sample_val_top_3
	);
		begin
			chr_sample_left_0 = sample_val_left_0;
			chr_sample_left_1 = sample_val_left_1;
			chr_sample_left_2 = sample_val_left_2;
			chr_sample_left_3 = sample_val_left_3;
			
			chr_sample_top_0  = sample_val_top_0;
			chr_sample_top_1  = sample_val_top_1;
			chr_sample_top_2  = sample_val_top_2;
			chr_sample_top_3  = sample_val_top_3;

			chr_data_in_valid_top  = 1;
			chr_data_in_valid_left = 1;			
			@(posedge clk);
			chr_data_in_valid_top  = 0;
			chr_data_in_valid_left = 0;	
		end
	endtask
	
	task automatic load_luma_4x4_block
	(	
		input [width_p-1:0] luma_sample_0_in, 
		input [width_p-1:0] luma_sample_1_in,
		input [width_p-1:0] luma_sample_2_in,									   
		input [width_p-1:0] luma_sample_3_in,									   
		input [width_p-1:0] luma_sample_4_in,									   
		input [width_p-1:0] luma_sample_5_in,	
		input [width_p-1:0] luma_sample_6_in,
		input [width_p-1:0] luma_sample_7_in,									   
		input [width_p-1:0] luma_sample_8_in,									   
		input [width_p-1:0] luma_sample_9_in,									   
		input [width_p-1:0] luma_sample_10_in,	
		input [width_p-1:0] luma_sample_11_in,
		input [width_p-1:0] luma_sample_12_in,									   
		input [width_p-1:0] luma_sample_13_in,									   
		input [width_p-1:0] luma_sample_14_in,									   
		input [width_p-1:0] luma_sample_15_in									   
	);
		begin 
			luma_sample_0_i 	=	luma_sample_0_in;
			luma_sample_1_i 	=   luma_sample_1_in;
			luma_sample_2_i 	=   luma_sample_2_in;
			luma_sample_3_i 	=   luma_sample_3_in;
			luma_sample_4_i 	=   luma_sample_4_in;
			luma_sample_5_i 	=   luma_sample_5_in;
			luma_sample_6_i 	=   luma_sample_6_in;
			luma_sample_7_i 	=   luma_sample_7_in;
			luma_sample_8_i 	=   luma_sample_8_in;
			luma_sample_9_i 	=   luma_sample_9_in;
			luma_sample_10_i 	=   luma_sample_10_in;
			luma_sample_11_i	=   luma_sample_11_in;
			luma_sample_12_i 	=   luma_sample_12_in;
			luma_sample_13_i	=   luma_sample_13_in;
			luma_sample_14_i 	=   luma_sample_14_in;
			luma_sample_15_i	=   luma_sample_15_in;
			
			luma_data_in_valid 	= 1;
			@(posedge clk);
			luma_data_in_valid 	= 0;
		end
	endtask

	task automatic load_luma_incremental_4x4(input integer block_size);
		integer base_row, base_col;
		integer r, c;
		
		reg [9:0] block [0:15];

		begin
			for (base_row = 0; base_row < block_size; base_row = base_row + 4) begin
				for (base_col = 0; base_col < block_size; base_col = base_col + 4) begin
					
					// block 4x4 
					for (r = 0; r < 4; r = r + 1) begin
						for (c = 0; c < 4; c = c + 1) begin
							block[r*4 + c] = (base_row + r)*block_size + (base_col + c);
						end
					end

					// Send block 4x4 
					load_luma_4x4_block(
						block[0],  block[1],  block[2],  block[3],
						block[4],  block[5],  block[6],  block[7],
						block[8],  block[9],  block[10], block[11],
						block[12], block[13], block[14], block[15]
					);

				end
			end
		end
	endtask

	task automatic load_luma_incremental_4x4_rect(input integer block_height, input integer block_width);
		
		integer base_row, base_col;
		integer r, c;
		
		reg [9:0] block [0:15];

		begin
			for (base_row = 0; base_row < block_height; base_row = base_row + 4) begin
				for (base_col = 0; base_col < block_width; base_col = base_col + 4) begin
					
					// Monta bloco 4x4
					for (r = 0; r < 4; r = r + 1) begin
						for (c = 0; c < 4; c = c + 1) begin
							block[r*4 + c] = (base_row + r)*block_width + (base_col + c);
						end
					end

					// Envia bloco
					load_luma_4x4_block(
						block[0],  block[1],  block[2],  block[3],
						block[4],  block[5],  block[6],  block[7],
						block[8],  block[9],  block[10], block[11],
						block[12], block[13], block[14], block[15]
					);

				end
			end
		end
	endtask

    // Clock: 10ns período
    always #5 clk = ~clk;

    // fazer dois initial, um para o DC Chroma e outro para o Luma 
	// assim podemos entender a questão de amostragem do Luma block height e width
	// talvez o reset da luma memory tenha que ser no final com o CFL_READY
	
// -------------- 4 samples sum --------------	
	/*		 255  255  255  255
		255	  1    2  	3    4 
		255	  5    6  	7    8
		255	  9    10 	11   12
		255	  13   14 	15   16
	*/	

	
	// test: 
	// 		- Chroma DC Block 4x4 		=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  	 		=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2 
	//  Result 
/* 	240 242 244 246
	248 250 252 254
	256 258 260 262
	264 266 268 270
 */	
	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 8x8 		=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2
	//  Result

/* 	192 194 196 198 200 202 204 206
	208 210 212 214 216 218 220 222
	224 226 228 230 232 234 236 238
	240 242 244 246 248 250 252 254
	256 258 260 262 264 266 268 270
	272 274 276 278 280 282 284 286
	288 290 292 294 296 298 300 302
	304 306 308 310 312 314 316 318
 */
	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 16x16 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...; 
	//		- alpha = +1
	//		- 4:2:2 
	//		Result
 
/* 	0   2   4   6  ...  30
	32 34  36  38 ...  62
	...
	...
	480 482 484 ... 508
	510
 */ 
 	// ------------------------------------------------ // 
 
	// test: 
	// 		- Chroma DC Block 32x32 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all 32x32 luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2 



	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 4x8	[8 rows x 4 columns] 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 						=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2

	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 8x4 [4 rows x 8 columns] 	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 						=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2

	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 8x16	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2 

	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 16x8	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2 

	// ------------------------------------------------ // 

	// test: 
	// 		- Chroma DC Block 4x16	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2

	// ------------------------------------------------ // 

	// test: 
	// 		- Chroma DC Block 16x4	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2
	
	// ------------------------------------------------ // 
	
	// test: 
	// 		- Chroma DC Block 16x32	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2

	// ------------------------------------------------ // 

	// test: 
	// 		- Chroma DC Block 16x32	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2

	// ------------------------------------------------ // 

	// test: 
	// 		- Chroma DC Block 8x32	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  		 	=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2

	// ------------------------------------------------ // 

	// test: 
	// 		- Chroma DC Block 32x8	 	=> all neighboring left and top samples are 0xFF;
	//		- CFL block 	  	 		=> all luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:2		

	
initial begin
        $display("DC Chroma Prediction loading start");
		
        rst <= 0;
		repeat (1) @(posedge clk); 
		rst <= 1;
        repeat (1) @(posedge clk); 
        rst <= 0;
        repeat (1) @(posedge clk);
		
		// --------------------------------------- //

		rows_num    	<= 7'h04;
		columns_num   	<= 7'h04;		
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;

		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);

		wait (CFL_final_ready);
		wait (!CFL_final_ready);
		repeat (4) @(posedge clk);

 		// --------------------------------------- //
		
		rows_num    	<= 7'h08;
		columns_num   	<= 7'h08;		
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;

		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);		

		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		

		// --------------------------------------- //

		rows_num    	<= 7'h10;
		columns_num   	<= 7'h10;		
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;

		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);			

		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		

		// --------------------------------------- //
		
		rows_num    	<= 7'h20;
		columns_num   	<= 7'h20;		
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;

		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		repeat (1) @(posedge clk);	
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);		
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		

 		// --------------------------------------- //
		
		// 4x8 samples 
		// 8 rows 4 columns 
		
		rows_num    	<= 7'h8;		  	
		columns_num   	<= 7'h4;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);	
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //

		// 8x4 samples 
		// 4 rows 8 columns 
		
		rows_num    	<= 7'h4;		  	
		columns_num   	<= 7'h8;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);	
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //

		// 8x16 samples 
		// 16 rows 8 columns 
		
		rows_num    	<= 7'h10;		  	
		columns_num   	<= 7'h08;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //

		// 16x8 samples 
		// 8 rows 16 columns 
		
		rows_num    	<= 7'h08;		  	
		columns_num   	<= 7'h10;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //

		// 4x16 samples 
		// 16 rows 4 columns 
		
		rows_num    	<= 7'h10;		  	
		columns_num   	<= 7'h04;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //

		// 16x4 samples 
		// 4 rows 16 columns 
		
		rows_num    	<= 7'h04;		  	
		columns_num   	<= 7'h10;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //
		
		// 16x32 samples 
		// 32 rows 16 columns 
		
		rows_num    	<= 7'h20;		  	
		columns_num   	<= 7'h10;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		repeat (1) @(posedge clk);	
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 
		
		// --------------------------------------- //

		// 32x16 samples 
		// 16 rows 32 columns 
		
		rows_num    	<= 7'h10;		  	
		columns_num   	<= 7'h20;		  
		chr_above 	   	<= 1;
		chr_left  	  	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		repeat (1) @(posedge clk);	
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk); 

		// --------------------------------------- //

		// 8x32 samples 
		// 32 rows 8 columns 
		
		rows_num    	<= 7'h20;		  	
		columns_num   	<= 7'h08;		  
		chr_above 	   	<= 1;
		chr_left  	   	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		repeat (1) @(posedge clk);	
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);
		
		// --------------------------------------- //

		// 32x8 samples 
		// 8 rows 32 columns 
		
		rows_num    	<= 7'h08;		  	
		columns_num   	<= 7'h20;		  
		chr_above 	   	<= 1;
		chr_left  	  	<= 1;
		
        @(posedge clk);
		
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		repeat (1) @(posedge clk);	
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		load_sample_top(10'hFF,10'hFF,10'hFF,10'hFF);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);

	end

	initial begin
        $display("Luma loading start");
		
        rst <= 0;
		repeat (1) @(posedge clk); 
		rst <= 1;
        repeat (1) @(posedge clk); 
        rst <= 0;
        repeat (1) @(posedge clk);

		// --------------------------------------- //

		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4(8); // 8x8 
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");
		
		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 
		
		// Luma samples loading	
		load_luma_incremental_4x4(16); // 8x8 
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the second CFL Prediction");
		
		// --------------------------------------- //

		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 
		
		// Luma samples loading	
		load_luma_incremental_4x4(32);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the third CFL Prediction");
		
		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk);
		
		load_luma_incremental_4x4(64);

		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the fourth CFL Prediction"); 

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(16,8);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(8,16);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(32,16);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(16,32);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(32,8);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");		

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(8,32);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");		

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(64,32);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");		

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(32,64);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");	

		// --------------------------------------- //

 		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(64,16);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");		

		// --------------------------------------- //

		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_incremental_4x4_rect(16,64);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");	
		
	end 

endmodule