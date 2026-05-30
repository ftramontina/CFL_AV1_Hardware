
// Subsampling memory 


module subsampling_memory  
  #(
  
	parameter width_p 	    = 10, 			
	parameter columns		= 32, 
	parameter rows			= 64
   
  )
  (
    input logic clk_i,
	input logic rst_i,
	
	input logic mem_write_en_i,
	input logic mem_read_en_i,			// it must be asserted after Chroma DC intra is finished 
	
	input logic [7:0] block_sub_row_i,
	input logic [7:0] block_sub_column_i,
	
	input logic [width_p-1:0] sample_in_a_i,
	input logic [width_p-1:0] sample_in_b_i, 	
	
	input logic [6:0] row_addr_c_1_i,
	input logic [6:0] column_addr_c_1_i,
	input logic [6:0] row_addr_c_2_i,
	input logic [6:0] column_addr_c_2_i,
	
	input logic [3:0] div_shift_i,
	
	input logic samples_loaded_i, 
	
	output logic [width_p-1:0] sample_out_o,
	output logic mem_ready_to_be_read_o,
	
	output logic [6:0] address_row_o,
	output logic [6:0] address_column_o,
	output logic [9:0] avg_o, 
	output logic mem_read_finish_o,
	output logic CFL_final_ready_o,
	
	output logic pipe_en_o
	
  );

    // RAM declaration 
    logic [width_p-1:0] mem [0:rows-1][0:columns-1];  
	logic mem_ready_to_be_read_reg; 
	logic mem_read_finish_reg = 0; 
	logic [20:0] acc_reg = 0;
	
	logic [7:0] block_width_reg  = 0; 
	logic [7:0] block_height_reg = 0;

	logic [9:0] avg_reg; 
	logic [6:0] address_row_reg = 0;
	logic [6:0] address_column_reg = 0; 

	logic [7:0] block_sub_column_reg = 0; 
	logic [7:0] block_sub_row_reg = 0;
	
	logic pipe_en_reg = 0; 
	logic [2:0] count_pipe  = 0; 
	logic count_pipe_en_reg = 0; 
	
	logic CFL_final_ready_reg = 0;
	logic samples_loaded_dly;
	logic [3:0] div_shift_dly; 
	
	int k = 0;
	int l = 0; 
	int i = 0; 
	int j = 0; 
	
	logic [9:0] avg_2;
	logic [9:0] avg_3;	
	logic [9:0] avg_4;
	logic [9:0] avg_5;
	logic [9:0] avg_6;	
	logic [9:0] avg_7;	
	logic [9:0] avg_8;
	logic [9:0] avg_9;
	logic [9:0] avg_10;
	logic [9:0] avg_11;
	
	logic [9:0] avg_2_reg;
	logic [9:0] avg_3_reg;	
	logic [9:0] avg_4_reg;
	logic [9:0] avg_5_reg;
	logic [9:0] avg_6_reg;	
	logic [9:0] avg_7_reg;	
	logic [9:0] avg_8_reg;
	logic [9:0] avg_9_reg;
	logic [9:0] avg_10_reg;
	logic [9:0] avg_11_reg;
	
	logic [3:0] div_shift_2;
	logic [3:0] div_shift_3;
	logic [3:0] div_shift_4;
	logic [3:0] div_shift_5;
	logic [3:0] div_shift_6;
	logic [3:0] div_shift_7;
	logic [3:0] div_shift_8;
	logic [3:0] div_shift_9;
	logic [3:0] div_shift_10;
	logic [3:0] div_shift_11;
	
	assign div_shift_2 	 = 2;
	assign div_shift_3 	 = 3; 
	assign div_shift_4 	 = 4; 
	assign div_shift_5 	 = 5;  
	assign div_shift_6 	 = 6; 
	assign div_shift_7 	 = 7; 
	assign div_shift_8   = 8;
	assign div_shift_9 	 = 9; 
	assign div_shift_10  = 10;
	assign div_shift_11  = 11; 
	
	// -------------------------------------------------------- // 
	
	Luma_Avg_Processing Luma_Avg_Processing_2 
	(
		.div_shift_i(div_shift_2),
		.acc_i(acc_reg),
		.avg_o(avg_2)
	);
	
	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_3 
	(
		.div_shift_i(div_shift_3),
		.acc_i(acc_reg),
		.avg_o(avg_3)
	);
	
	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_4 
	(
		.div_shift_i(div_shift_4),
		.acc_i(acc_reg),
		.avg_o(avg_4)
	);
	
	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_5 
	(
		.div_shift_i(div_shift_5),
		.acc_i(acc_reg),
		.avg_o(avg_5)
	);	
	
	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_6 
	(
		.div_shift_i(div_shift_6),
		.acc_i(acc_reg),
		.avg_o(avg_6)
	);	

	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_7 
	(
		.div_shift_i(div_shift_7),
		.acc_i(acc_reg),
		.avg_o(avg_7)
	);	
	
	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_8 
	(
		.div_shift_i(div_shift_8),
		.acc_i(acc_reg),
		.avg_o(avg_8)
	);	

	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_9 
	(
		.div_shift_i(div_shift_9),
		.acc_i(acc_reg),
		.avg_o(avg_9)
	);			
	
	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_10 
	(
		.div_shift_i(div_shift_10),
		.acc_i(acc_reg),
		.avg_o(avg_10)
	);			

	// -------------------------------------------------------- // 
	
		Luma_Avg_Processing Luma_Avg_Processing_11 
	(
		.div_shift_i(div_shift_11),
		.acc_i(acc_reg),
		.avg_o(avg_11)
	);		

	// -------------------------------------------------------- // 

	always_ff @(posedge clk_i) begin 
		if(rst_i) begin
			mem_ready_to_be_read_reg <= 0; 
			mem_read_finish_reg <= 0; 
			acc_reg <= 0;
			avg_reg <= 0; 
			block_width_reg  <= 0; 
			block_height_reg <= 0;
			sample_out_o <=0;
			pipe_en_reg <= 0; 
			i <= 0; 
			l <= 0; 
			j <= 0;
			k <= 0 ; 
			
			for(int k = 0; k < rows; k++) begin 
				for(int l = 0; l < columns; l++) begin 
					mem[k][l] <= '0;
				end 	
			end
			
		end	else if(mem_write_en_i) begin 
			mem[row_addr_c_1_i][column_addr_c_1_i] <= sample_in_a_i; 
			mem[row_addr_c_2_i][column_addr_c_2_i] <= sample_in_b_i;
			
			acc_reg <= sample_in_a_i + sample_in_b_i + acc_reg;  
			
		end else if(mem_read_en_i && (!mem_read_finish_reg)) begin 
			sample_out_o        <= mem[i][j]; 
			address_row_reg     <= i; 
			address_column_reg  <= j; 
			pipe_en_reg			<= 1;
			CFL_final_ready_reg	<= 1; 
			
			if(j == block_sub_column_reg-1) begin		
				j <= 0; 
				if(i == block_sub_row_reg-1) begin 		
					j <= 0; 
					i <= 0; 
					mem_read_finish_reg  <= 1;
					block_sub_row_reg    <= 0; 
					block_sub_column_reg <= 0;
					count_pipe_en_reg    <= 1; 		
				end else begin 
					i <= i + 1; 
				end
			end else begin 
				j <= j + 1;
			end
		end 
	end	
	
 	always_ff @(posedge clk_i) begin
		if(mem_read_finish_reg) begin 
			address_row_reg    <= 0; 
			address_column_reg <= 0;
			sample_out_o <= 0; 
			CFL_final_ready_reg <= 0; 
		end 
		
		if(count_pipe_en_reg) begin 
			if(count_pipe < 1) begin 
				count_pipe  <= count_pipe + 1; 
				pipe_en_reg <= 1; 
			end else begin 
				count_pipe  <= 0;
				pipe_en_reg <= 0;
				count_pipe_en_reg <= 0; 
				
				for(int k = 0; k < rows; k++) begin 
					for(int l = 0; l < columns; l++) begin 
						mem[k][l] <= '0;
					end 	
				end
				
			end
		end 
	end  
	
	always_ff @(posedge clk_i) begin
		avg_2_reg	<= avg_2;
		avg_3_reg	<= avg_3;
		avg_4_reg	<= avg_4;
	    avg_5_reg	<= avg_5;
	    avg_6_reg	<= avg_6;
	    avg_7_reg	<= avg_7;
	    avg_8_reg	<= avg_8;
	    avg_9_reg	<= avg_9;
	    avg_10_reg	<= avg_10;
		avg_11_reg	<= avg_11;
	end	
	
	always_ff @(posedge clk_i) begin
		if(samples_loaded_dly) begin 
			case (div_shift_dly)  
				4'd2  : avg_reg <= avg_2_reg; 
				4'd3  : avg_reg <= avg_3_reg;	 				
				4'd4  : avg_reg <= avg_4_reg;	 			
				4'd5  : avg_reg <= avg_5_reg;	 	
				4'd6  : avg_reg <= avg_6_reg;	 	
				4'd7  : avg_reg <= avg_7_reg;	 	
				4'd8  : avg_reg <= avg_8_reg;	 
				4'd9  : avg_reg <= avg_9_reg;	 
				4'd10 : avg_reg <= avg_10_reg;
				4'd11 : avg_reg <= avg_11_reg;		
			endcase 
			acc_reg <= 0;
			mem_ready_to_be_read_reg <= 1;
			block_sub_column_reg <= block_sub_column_i; 
			block_sub_row_reg    <= block_sub_row_i; 
		end else begin 
			avg_reg <= 0; 
			mem_ready_to_be_read_reg <= 0; 
		end 
	end 
	
	always_ff @(posedge clk_i) begin	
		if(!mem_read_en_i) begin 
			mem_read_finish_reg <= 0;
		end
		div_shift_dly	   <= div_shift_i;
		samples_loaded_dly <= samples_loaded_i;
	end	
	
	assign mem_ready_to_be_read_o = mem_ready_to_be_read_reg;
	assign address_row_o          = address_row_reg; 
	assign address_column_o       = address_column_reg; 
	assign mem_read_finish_o	  = mem_read_finish_reg; // no controle, qunando mem_read_finish_reg = 1, mem_read_en_i = 0
	assign avg_o				  = avg_reg; 
	assign pipe_en_o			  = pipe_en_reg; 
	assign CFL_final_ready_o	  = CFL_final_ready_reg; 
	
endmodule
