

module tb_CFL_Intra_top_Image;

	parameter width_p 	 	= 10; 		
	parameter columns_p	 	= 64;
	parameter rows_p		= 64;
	parameter samples_n_p	= 16;

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
	
	integer d, e; 
	integer j;
	integer b, k; 
	integer fd;
	
	logic [width_p-1:0] block [0:7][0:7] = '{default: '0};
	
	reg block_read = 0; 
	
	CFL_Intraprediction_Top #(
	
		.width_p(width_p),
		.columns(columns_p),
		.rows(rows_p),
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

    // Clock: 10ns período
    always #5 clk = ~clk;
	
	task read_next_8x8_block(input integer fd, output reg [width_p-1:0] block [0:7][0:7]);
		integer i;
		integer r;
		integer c;
		integer value;
		reg [1023:0] line;
		
		begin
			i = 0;
			// read all the 64 pixels 
			while (i < 64 && !$feof(fd)) begin

				// Read a line
				r = $fgets(line, fd);

				// If it's a comment, it "breaks" the iteration 
				if (line[7:0] == "#") begin
					// do nothing 
				end
				else begin
					// Try to read the value 
					r = $sscanf(line, "%d", value);

					if (r == 1) begin
						block[i/8][i%8] = value[7:0];
						i = i + 1;
					end
				end
			end

			// Check
			if (i != 64) begin
				$display("ERROR: Block incompleted (%0d read pixels)", i);
				$stop;
			end
		end
	endtask
	
	task luma_input_one_block(input reg [width_p-1:0] block [0:7][0:7]);
		integer d;
		integer e; 
		begin
			for (d = 0; d < 8; d = d + 1) begin
				for (e = 0; e < 8; e = e + 1) begin
					luma_sample = block[d][e];
					luma_data_in_valid = 1;
					@(posedge clk);
					luma_data_in_valid = 0;
				end 
			end
		end 
	endtask	

	
	// CFL Prediction 
	initial begin
 		fd = $fopen("Luma_8x8_for_Modelsim.txt", "r");
		if (fd == 0) begin
			$display("ERROR: The file has not been opened");
			$stop;
		end

        rst <= 0;
		repeat (1) @(posedge clk); 
		rst <= 1;
        repeat (1) @(posedge clk); 
        rst <= 0;
        repeat (1) @(posedge clk);

		block_width    <= 7'h08;			// <= tem que ajeitar a questão dos block sizes pro CFL/DC
		block_height   <= 7'h08;			// <= tem que ajeitar a questão dos block sizes pro CFL/DC
		
		repeat (1) @(posedge clk); 	
		
		subsampling_x  <= 1;
		subsampling_y  <= 1; 
		alpha_index	   <= 8;
		alpha_sign	   <= 0;
		block_read 	   <= 0;
		
		// ADICIONAR UM DC CCHROMA PRA VER O COMPORTAMENTO
		// all luma blocks input to CFL block  
		
		wait (chr_ready_to_load_left);
		wait (chr_ready_to_load_top);		
		
		//inicializar o chroma aqui 
		
		wait (luma_ready_to_load);
		
		for (k = 0; k < 32400; k = k + 1) begin // testar com 10 
			if(luma_ready_to_load) begin 
				block_read <= 0;
				read_next_8x8_block(fd, block);
				block_read <= 1; 	
				
				luma_input_one_block(block);
				wait (CFL_final_ready);
				wait (!CFL_final_ready);
			end 
		end 
		
		repeat (50) @(posedge clk);
		
		// Luma samples loading 
		//load_luma_1_to_16();
		
		//wait (CFL_final_ready);
		//wait (!CFL_final_ready); 
		//repeat (4) @(posedge clk);		
		//$display("End of the CFL Prediction Block");		


		$fclose(fd);
		repeat (50) @(posedge clk);
		$finish;
	
	end

endmodule