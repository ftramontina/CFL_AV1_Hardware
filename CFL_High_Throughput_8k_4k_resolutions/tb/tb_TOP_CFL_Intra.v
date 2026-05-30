
`timescale 1ns / 1ps
module tb_CFL_Intra_top_Integration;

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

	reg [6:0] block_height 		= 0;
	reg [6:0] block_width  		= 0;
	
	reg [width_p-1:0] chr_sample_left = 0;
	reg [width_p-1:0] chr_sample_top  = 0;
	reg [width_p-1:0] luma_sample	  = 0; 

	reg [4:0] alpha_index = 0;
	reg alpha_sign		  = 0;
	
	reg chr_above  = 0;
	reg chr_left   = 0;
	
	reg start = 1;
	
	wire chr_ready_to_load_left;
	wire chr_ready_to_load_top;
	wire luma_ready_to_load;
	
	wire [6:0] address_row_final;
	wire [6:0] address_column_final;
	
	wire signed [width_p+1:0] CFL_final;
	wire CFL_final_ready;
	
	integer j;
	
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

		.block_height_i(block_height), 
		.block_width_i(block_width),

		.chr_sample_left_i(chr_sample_left),
		.chr_sample_top_i(chr_sample_top),	
		.luma_sample_i(luma_sample),

		.alpha_sign_i(alpha_sign), 
		.alpha_index_i(alpha_index),

		.chr_above_i(chr_above),
		.chr_left_i(chr_left),

		.chr_ready_to_load_left_o(chr_ready_to_load_left),	
		.chr_ready_to_load_top_o(chr_ready_to_load_top),
		.luma_ready_to_load_o(luma_ready_to_load),

		.address_row_final_o(address_row_final),
		.address_column_final_o(address_column_final),
		.CFL_final_o(CFL_final),
		.CFL_final_ready_o(CFL_final_ready)
		
	);
	

	task load_sample_left(input [width_p-1:0] sample_val);
		begin
			chr_sample_left = sample_val;
			chr_data_in_valid_left = 1;
			@(posedge clk);
			chr_data_in_valid_left = 0;
		end
	endtask

	task load_sample_top(input [width_p-1:0] sample_val);
		begin
			chr_sample_top = sample_val;
			chr_data_in_valid_top = 1;
			@(posedge clk);
			chr_data_in_valid_top = 0;
		end
	endtask

	task load_sample_left_top(input [width_p-1:0] sample_val_left, input [width_p-1:0] sample_val_top);
		begin
			chr_sample_top  = sample_val_top;
			chr_sample_left = sample_val_left;
			chr_data_in_valid_top  = 1;
			chr_data_in_valid_left = 1;			
			@(posedge clk);
			chr_data_in_valid_top  = 0;
			chr_data_in_valid_left = 0;	
		end
	endtask
	
	task automatic load_luma_sample(input [width_p-1:0] luma_sample_in);
		begin 
			luma_sample = luma_sample_in;
			luma_data_in_valid = 1;
			@(posedge clk);
			luma_data_in_valid = 0;
		end
	endtask 
	
	task automatic load_luma_1_to_64;		// 8x8 1,2,3...
		integer i;
		begin
			for (i = 0; i < 64; i = i + 1) begin
				load_luma_sample(i+1);
			end
		end
	endtask

	task automatic load_luma_1_to_64_all_same(input [width_p-1:0] luma_sample_in);		// 64x64 all same 
		integer k;
		begin
			luma_sample = luma_sample_in;
			for (k = 0; k < 4096; k = k + 1) begin
				luma_data_in_valid = 1;
				@(posedge clk);
				luma_data_in_valid = 0;
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

	
	// First test: 
	// 		- Chroma DC Block 4x4 => all neighboring left and top samples are 0xFF;
	//		- CFL block 	  8x8 => all 64 luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:0 

	// Second test: 
	// 		- Chroma DC Block 4x4 => all neighboring left and top samples are 0xFF;
	//		- CFL block 	  8x8 => all 64 luma samples are incremented from 1 to 64, L(0,0) = 1, L(0,1) = 2 ...;
	//		- alpha = -0.750
	//		- 4:2:2 
	
	// Third test: 
	// 		- Chroma DC Block 32x32 => all neighboring left samples are 0xDC, all top samples are 0x7B;
	//		- CFL block 	  64x64 => all 64x64 luma samples are 0x2, L(0,0) = 2, L(0,1) = 2 ...;
	//		- alpha = +1
	//		- 4:2:0 
	
	
	// DC Chroma Intra Prediction 
	initial begin
        $display("DC Chroma Prediction loading start");
		
        rst <= 0;
		repeat (1) @(posedge clk); 
		rst <= 1;
        repeat (1) @(posedge clk); 
        rst <= 0;
        repeat (1) @(posedge clk);
		
		// --------------------------------------- //

		block_width    <= 7'h04;
		block_height   <= 7'h04;		
		chr_above 	   <= 1;
		chr_left  	   <= 1;

		// Chroma samples loading 
		load_sample_left_top(10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF);		
		load_sample_left_top(10'hFF,10'hFF);		

		wait (CFL_final_ready);
		wait (!CFL_final_ready);
		repeat (4) @(posedge clk);

		// --------------------------------------- //
		
		block_width    <= 7'h04;
		block_height   <= 7'h04;		
		chr_above 	   <= 1;
		chr_left  	   <= 1;

		// Chroma samples loading 
		load_sample_left_top(10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF);
		load_sample_left_top(10'hFF,10'hFF);		
		load_sample_left_top(10'hFF,10'hFF);	

		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
        //repeat (100) @(posedge clk);		

		// --------------------------------------- //
		
		block_width    <= 7'h20;
		block_height   <= 7'h20;		
		chr_above 	   <= 1;
		chr_left  	   <= 1;
		
		test <= 1;

		repeat (1) @(posedge clk);

		// Chroma samples loading 
		for (j = 0; j < 32; j = j + 1) begin
			if(j == 15 || j == 31) begin 
				load_sample_left_top(10'hDC,10'h7B);
				@(posedge clk);
			end else begin 
				load_sample_left_top(10'hDC,10'h7B);
			end 	
		end	

		wait (CFL_final_ready);
		wait (!CFL_final_ready);
		repeat (500) @(posedge clk);
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
		subsampling_y  <= 1; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_1_to_64();
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready); 
		repeat (4) @(posedge clk);		
		$display("End of the first CFL Prediction");
		
		// --------------------------------------- //

		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		alpha_index	   <= 6;
		alpha_sign	   <= 1;
		
		repeat (1) @(posedge clk); 

		// Luma samples loading 
		load_luma_1_to_64();
		
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
		load_luma_1_to_64_all_same(10'h02);
		
		wait (CFL_final_ready);
		wait (!CFL_final_ready);
		repeat (500) @(posedge clk);		
		$display("End of the third CFL Prediction"); 
		
	end 

endmodule