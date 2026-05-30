
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

	input logic [7:0] block_width_i, 
	input logic [7:0] block_height_i,
	
	input logic [width_p-1:0] sample_in_00_i,
	input logic [width_p-1:0] sample_in_01_i, 
    input logic [width_p-1:0] sample_in_02_i,
    input logic [width_p-1:0] sample_in_03_i,
    input logic [width_p-1:0] sample_in_04_i,
    input logic [width_p-1:0] sample_in_05_i,
    input logic [width_p-1:0] sample_in_06_i,
    input logic [width_p-1:0] sample_in_07_i,
    input logic [width_p-1:0] sample_in_08_i,
    input logic [width_p-1:0] sample_in_09_i,
    input logic [width_p-1:0] sample_in_10_i,
    input logic [width_p-1:0] sample_in_11_i,
    input logic [width_p-1:0] sample_in_12_i,
    input logic [width_p-1:0] sample_in_13_i,
    input logic [width_p-1:0] sample_in_14_i,
    input logic [width_p-1:0] sample_in_15_i,

	input logic [16*7-1:0] row_addr_sub_flat_i,
	input logic [16*7-1:0] column_addr_sub_flat_i,		
	
	input logic [3:0] div_shift_i,
	
	input logic samples_loaded_i, 
	
	output logic [width_p-1:0] sample_out_00_o,
	output logic [width_p-1:0] sample_out_01_o,
    output logic [width_p-1:0] sample_out_02_o,
    output logic [width_p-1:0] sample_out_03_o,
    output logic [width_p-1:0] sample_out_04_o,
    output logic [width_p-1:0] sample_out_05_o,
    output logic [width_p-1:0] sample_out_06_o,
    output logic [width_p-1:0] sample_out_07_o,
    output logic [width_p-1:0] sample_out_08_o,
    output logic [width_p-1:0] sample_out_09_o,
    output logic [width_p-1:0] sample_out_10_o,
    output logic [width_p-1:0] sample_out_11_o,
    output logic [width_p-1:0] sample_out_12_o,
    output logic [width_p-1:0] sample_out_13_o,
    output logic [width_p-1:0] sample_out_14_o,
    output logic [width_p-1:0] sample_out_15_o,

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
	logic mem_read_finish_reg_dly = 0; 	
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
	
	logic samples_loaded_dly_dly;
	logic [3:0] div_shift_dly_dly;
	
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

	logic [6:0] row_addr_wire    [0:15];
	logic [6:0] column_addr_wire [0:15];
	
	logic [width_p:0] sum_0;
	logic [width_p:0] sum_1;	
	logic [width_p:0] sum_2;
	logic [width_p:0] sum_3;
	logic [width_p:0] sum_4;	
	logic [width_p:0] sum_5;
	logic [width_p:0] sum_6;	
	logic [width_p:0] sum_7;

	logic [width_p+1:0] sum_a;	
	logic [width_p+1:0] sum_b;
	logic [width_p+1:0] sum_c;	
	logic [width_p+1:0] sum_d;

	logic [width_p+2:0] sum_ab;	
	logic [width_p+2:0] sum_cd;

	logic [width_p+3:0] sum_abcd;
	
	logic adjust;
	
	genvar m, n;
	
	generate
		for (m = 0; m < 16; m = m + 1) begin : UNFLATTEN_ROW_ADDR
			assign row_addr_wire[m] = row_addr_sub_flat_i[m*7 +: 7];
		end
	endgenerate

	generate
		for (n = 0; n < 16; n = n + 1) begin : UNFLATTEN_COLUMN_ADDR
			assign column_addr_wire[n] = column_addr_sub_flat_i[n*7 +: 7];
		end
	endgenerate
	
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

	// Combinational sum using individual signals and register at one clock to avoid big critical path - 4 adders critical path; 
	
	assign sum_0 = sample_in_00_i + sample_in_01_i;
	assign sum_1 = sample_in_02_i + sample_in_03_i;
	assign sum_2 = sample_in_04_i + sample_in_05_i; 
	assign sum_3 = sample_in_06_i + sample_in_07_i; 			
	assign sum_4 = sample_in_08_i + sample_in_09_i;
	assign sum_5 = sample_in_10_i + sample_in_11_i;
	assign sum_6 = sample_in_12_i + sample_in_13_i;
	assign sum_7 = sample_in_14_i + sample_in_15_i;
	
	assign sum_a = sum_0 + sum_1; 
	assign sum_b = sum_2 + sum_3; 
	assign sum_c = sum_4 + sum_5; 
	assign sum_d = sum_6 + sum_7;
	
	assign sum_ab = sum_a + sum_b; 
	assign sum_cd = sum_c + sum_d; 

	assign sum_abcd = sum_ab + sum_cd; 
	
	always_ff @(posedge clk_i) begin 
		if(rst_i) begin
			mem_ready_to_be_read_reg <= 0; 
			mem_read_finish_reg <= 0; 
			acc_reg <= 0;
			avg_reg <= 0; 
			block_width_reg  <= 0; 
			block_height_reg <= 0;
			sample_out_00_o  <=0;
            sample_out_01_o  <=0;
            sample_out_02_o  <=0;
            sample_out_03_o  <=0;
            sample_out_04_o  <=0;
            sample_out_05_o  <=0;
            sample_out_06_o  <=0;
            sample_out_07_o  <=0;
            sample_out_08_o  <=0;
            sample_out_09_o  <=0;
            sample_out_10_o  <=0;
            sample_out_11_o  <=0;
            sample_out_12_o  <=0;
            sample_out_13_o  <=0;
            sample_out_14_o  <=0;
            sample_out_15_o  <=0;
			pipe_en_reg <= 0;
			mem_read_finish_reg_dly <= 0;
/* 			sum_0 <= 0;
			sum_1 <= 0;
			sum_2 <= 0;
			sum_3 <= 0; */
			i <= 0; 
			l <= 0; 
			j <= 0;
			k <= 0; 
			
			for(int k = 0; k < rows; k++) begin 
				for(int l = 0; l < columns; l++) begin 
					mem[k][l] <= '0;
				end 	
			end
			
		end	else if(mem_write_en_i) begin 
			mem[row_addr_wire[0]][column_addr_wire[0]] 	 <= sample_in_00_i;
			mem[row_addr_wire[1]][column_addr_wire[1]] 	 <= sample_in_01_i;
			mem[row_addr_wire[2]][column_addr_wire[2]] 	 <= sample_in_02_i;
			mem[row_addr_wire[3]][column_addr_wire[3]] 	 <= sample_in_03_i;
			
			mem[row_addr_wire[4]][column_addr_wire[4]] 	 <= sample_in_04_i;
			mem[row_addr_wire[5]][column_addr_wire[5]] 	 <= sample_in_05_i;
			mem[row_addr_wire[6]][column_addr_wire[6]] 	 <= sample_in_06_i;
			mem[row_addr_wire[7]][column_addr_wire[7]] 	 <= sample_in_07_i;
			
			mem[row_addr_wire[8]][column_addr_wire[8]]   <= sample_in_08_i;
			mem[row_addr_wire[9]][column_addr_wire[9]]   <= sample_in_09_i;
			mem[row_addr_wire[10]][column_addr_wire[10]] <= sample_in_10_i;
			mem[row_addr_wire[11]][column_addr_wire[11]] <= sample_in_11_i;
			
			mem[row_addr_wire[12]][column_addr_wire[12]] <= sample_in_12_i;
			mem[row_addr_wire[13]][column_addr_wire[13]] <= sample_in_13_i;
			mem[row_addr_wire[14]][column_addr_wire[14]] <= sample_in_14_i;
			mem[row_addr_wire[15]][column_addr_wire[15]] <= sample_in_15_i;

			acc_reg <= sum_abcd + acc_reg; 

		end else if(mem_read_en_i && (!mem_read_finish_reg)) begin
			// row 0
			sample_out_00_o  <= mem[i+0][j+0];
			sample_out_01_o  <= mem[i+0][j+1];
			sample_out_02_o  <= mem[i+0][j+2];
			sample_out_03_o  <= mem[i+0][j+3];

			// row 1
			sample_out_04_o  <= mem[i+1][j+0];
			sample_out_05_o  <= mem[i+1][j+1];
			sample_out_06_o  <= mem[i+1][j+2];
			sample_out_07_o  <= mem[i+1][j+3];

			// row 2
			sample_out_08_o  <= mem[i+2][j+0];
			sample_out_09_o  <= mem[i+2][j+1];
			sample_out_10_o  <= mem[i+2][j+2];
			sample_out_11_o  <= mem[i+2][j+3];

			// row 3
			sample_out_12_o  <= mem[i+3][j+0];
			sample_out_13_o  <= mem[i+3][j+1];
			sample_out_14_o  <= mem[i+3][j+2];
			sample_out_15_o  <= mem[i+3][j+3];

			address_row_reg     <= i; 
			address_column_reg  <= j; 
			pipe_en_reg			<= 1;
			CFL_final_ready_reg	<= 1; 
			
			if(j >= block_sub_column_reg-4) begin		
				j <= 0; 
				if(i >= block_sub_row_reg-4) begin 		
					i <= 0; 
					mem_read_finish_reg  <= 1;
					block_sub_row_reg    <= 0; 
					block_sub_column_reg <= 0;
					count_pipe_en_reg    <= 1; 		
				end else begin 
					i <= i + 4; 
				end
			end else begin 
				j <= j + 4;
			end
		end 
	end	
	
 	always_ff @(posedge clk_i) begin
		if(mem_read_finish_reg) begin 
			address_row_reg    <= 0; 
			address_column_reg <= 0;
			sample_out_00_o <= 0;
            sample_out_01_o <= 0;
            sample_out_02_o <= 0;
            sample_out_03_o <= 0;
            sample_out_04_o <= 0;
            sample_out_05_o <= 0;
            sample_out_06_o <= 0;
            sample_out_07_o <= 0;
            sample_out_08_o <= 0;
            sample_out_09_o <= 0;
            sample_out_10_o <= 0;
            sample_out_11_o <= 0;
            sample_out_12_o <= 0;
            sample_out_13_o <= 0;
            sample_out_14_o <= 0;
            sample_out_15_o <= 0;
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
		
/* 		if(block_width_i == 8 && block_height_i == 8) begin 
			mem_read_finish_reg_dly <= mem_read_finish_reg;
		end else begin 
			mem_read_finish_reg_dly <= 0;
		end */
		
		div_shift_dly	       <= div_shift_i;
		samples_loaded_dly 	   <= samples_loaded_i;
	end
	
	assign mem_ready_to_be_read_o = mem_ready_to_be_read_reg;
	assign address_row_o          = address_row_reg; 
	assign address_column_o       = address_column_reg; 
//	assign mem_read_finish_o	  = ((block_sub_column_i == 8) && (block_height_i == 8)) ? mem_read_finish_reg_dly : mem_read_finish_reg; 	 // no controle, qunando mem_read_finish_reg = 1, mem_read_en_i = 0
	assign mem_read_finish_o	  = mem_read_finish_reg; 	 																				// no controle, qunando mem_read_finish_reg = 1, mem_read_en_i = 0
	assign avg_o				  = avg_reg; 
	assign pipe_en_o			  = pipe_en_reg; 
	assign CFL_final_ready_o	  = CFL_final_ready_reg; 
	
endmodule
