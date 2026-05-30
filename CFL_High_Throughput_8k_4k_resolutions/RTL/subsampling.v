
// Subsampling Machine
// Reads the samples from the memory (register file) using 4x channels
// Performs the subsampling operation for 4:2:0 and 4:2:2 for all block sizes 
// Writes in the output memory (register file) 


module subsampling_machine  
  #(
  
	parameter width_p = 10
   
  )
  (
    input wire clk_i,
	input wire rst_i,
	
	input wire subsampling_x_i,
	input wire subsampling_y_i,
	
	input wire [7:0] block_width_i, 
	input wire [7:0] block_height_i, 
	
	input wire [width_p-1:0] sample_00_in,
	input wire [width_p-1:0] sample_01_in,
	input wire [width_p-1:0] sample_02_in,
	input wire [width_p-1:0] sample_03_in,
	input wire [width_p-1:0] sample_04_in,
	input wire [width_p-1:0] sample_05_in,
	input wire [width_p-1:0] sample_06_in,
	input wire [width_p-1:0] sample_07_in,
	input wire [width_p-1:0] sample_08_in,
	input wire [width_p-1:0] sample_09_in,
	input wire [width_p-1:0] sample_10_in,
	input wire [width_p-1:0] sample_11_in,
	input wire [width_p-1:0] sample_12_in,
	input wire [width_p-1:0] sample_13_in,
	input wire [width_p-1:0] sample_14_in,
	input wire [width_p-1:0] sample_15_in,
	input wire [width_p-1:0] sample_16_in,
	input wire [width_p-1:0] sample_17_in,
	input wire [width_p-1:0] sample_18_in,
	input wire [width_p-1:0] sample_19_in,
	input wire [width_p-1:0] sample_20_in,
	input wire [width_p-1:0] sample_21_in,
	input wire [width_p-1:0] sample_22_in,
	input wire [width_p-1:0] sample_23_in,
	input wire [width_p-1:0] sample_24_in,
	input wire [width_p-1:0] sample_25_in,
	input wire [width_p-1:0] sample_26_in,
	input wire [width_p-1:0] sample_27_in,
	input wire [width_p-1:0] sample_28_in,
	input wire [width_p-1:0] sample_29_in,
	input wire [width_p-1:0] sample_30_in,
	input wire [width_p-1:0] sample_31_in,
	input wire [width_p-1:0] sample_32_in,
	input wire [width_p-1:0] sample_33_in,
	input wire [width_p-1:0] sample_34_in,
	input wire [width_p-1:0] sample_35_in,
	input wire [width_p-1:0] sample_36_in,
	input wire [width_p-1:0] sample_37_in,
	input wire [width_p-1:0] sample_38_in,
	input wire [width_p-1:0] sample_39_in,
	input wire [width_p-1:0] sample_40_in,
	input wire [width_p-1:0] sample_41_in,
	input wire [width_p-1:0] sample_42_in,
	input wire [width_p-1:0] sample_43_in,
	input wire [width_p-1:0] sample_44_in,
	input wire [width_p-1:0] sample_45_in,
	input wire [width_p-1:0] sample_46_in,
	input wire [width_p-1:0] sample_47_in,
	input wire [width_p-1:0] sample_48_in,
	input wire [width_p-1:0] sample_49_in,
	input wire [width_p-1:0] sample_50_in,
	input wire [width_p-1:0] sample_51_in,
	input wire [width_p-1:0] sample_52_in,
	input wire [width_p-1:0] sample_53_in,
	input wire [width_p-1:0] sample_54_in,
	input wire [width_p-1:0] sample_55_in,
	input wire [width_p-1:0] sample_56_in,
	input wire [width_p-1:0] sample_57_in,
	input wire [width_p-1:0] sample_58_in,
	input wire [width_p-1:0] sample_59_in,
	input wire [width_p-1:0] sample_60_in,
	input wire [width_p-1:0] sample_61_in,
	input wire [width_p-1:0] sample_62_in,
	input wire [width_p-1:0] sample_63_in,	

	input wire load_en_i,
	
	output wire mem_read_en_o, 
	output wire mem_write_en_o, 
	
	output wire [64*7-1:0] row_addr_flat_o,
	output wire [64*7-1:0] column_addr_flat_o,

	output wire [16*7-1:0] row_addr_sub_flat_o,
	output wire [16*7-1:0] column_addr_sub_flat_o,	
	
	output wire [3:0] div_shift_o,
	output wire samples_loaded_o,
	
	output wire [7:0] block_sub_row_o,
	output wire [7:0] block_sub_column_o,

	output wire [width_p-1:0] sample_out_00_o,
    output wire [width_p-1:0] sample_out_01_o,
    output wire [width_p-1:0] sample_out_02_o,
    output wire [width_p-1:0] sample_out_03_o,
    output wire [width_p-1:0] sample_out_04_o,
    output wire [width_p-1:0] sample_out_05_o,
    output wire [width_p-1:0] sample_out_06_o,
    output wire [width_p-1:0] sample_out_07_o,
    output wire [width_p-1:0] sample_out_08_o,
    output wire [width_p-1:0] sample_out_09_o,
    output wire [width_p-1:0] sample_out_10_o,
    output wire [width_p-1:0] sample_out_11_o,
    output wire [width_p-1:0] sample_out_12_o,
    output wire [width_p-1:0] sample_out_13_o,
    output wire [width_p-1:0] sample_out_14_o,
	output wire [width_p-1:0] sample_out_15_o
	
  );

	// State definitions for 420 Subsampling Machine
	parameter S420_IDLE 	= 3'b000;
	parameter S420_LOAD_1	= 3'b001;
	parameter S420_LOAD_2 	= 3'b100;
	parameter S420_STOP_1	= 3'b010;
	parameter S420_WRITE    = 3'b011;

 	// State definitions for 422 Subsampling Machine
	parameter S422_IDLE 	= 3'b000;
	parameter S422_LOAD_1	= 3'b001;
	parameter S422_LOAD_2 	= 3'b100;
	parameter S422_STOP_1	= 3'b010;
	parameter S422_WRITE    = 3'b011;
	
	reg sub_4_2_0_en; 
	reg sub_4_2_2_en; 
	reg start_reg_4_2_0;
	
	reg sample_load_finished_8x8;
	
	reg [2:0] state; 
	reg [2:0] fsm; 
	
	reg mem_read_en_reg    = 0;
	reg mem_write_en_reg   = 0; 
	reg samples_loaded_reg = 0;  

	reg mem_read_en_reg_422    = 0;
	reg mem_write_en_reg_422   = 0; 
	reg samples_loaded_reg_422 = 0;  
	
	reg [3:0] counter_1; 
	reg [3:0] counter_2; 
	
	reg [7:0] block_width_reg;
	reg [7:0] block_height_reg;
	
	reg [3:0] div_shift_reg = 0; 
	
	reg [7:0] block_sub_row_reg    = 0;
	reg [7:0] block_sub_column_reg = 0;
	
	reg [width_p-1:0] sample_out_00_reg;
	reg [width_p-1:0] sample_out_01_reg;
	reg [width_p-1:0] sample_out_02_reg;
	reg [width_p-1:0] sample_out_03_reg;
	reg [width_p-1:0] sample_out_04_reg;
	reg [width_p-1:0] sample_out_05_reg;
	reg [width_p-1:0] sample_out_06_reg;
	reg [width_p-1:0] sample_out_07_reg;
	reg [width_p-1:0] sample_out_08_reg;
	reg [width_p-1:0] sample_out_09_reg;
	reg [width_p-1:0] sample_out_10_reg;
	reg [width_p-1:0] sample_out_11_reg;
	reg [width_p-1:0] sample_out_12_reg;
	reg [width_p-1:0] sample_out_13_reg;
	reg [width_p-1:0] sample_out_14_reg;
	reg [width_p-1:0] sample_out_15_reg;
	
	reg [6:0] row_addr_reg [0:63];
	reg [6:0] column_addr_reg [0:63];

	reg [6:0] row_addr_reg_422 [0:31];
	reg [6:0] column_addr_reg_422 [0:31];
	
	reg [6:0] row_addr_sub_reg [0:15];
	reg [6:0] column_addr_sub_reg [0:15];
	
	reg sample_load_finished; 
	
	integer i, j, i0, j0, i1, j1, i2, j2, i3, j3, i4, j4, i5, j5, i7, j7, i8, j8, i9, j9;  
	integer i10, i11, j10, j11, i12, j12, i13, j13, i14, j14, i15, j15, i16, j16, i17, j17; 
	integer i18, i19, j18, j19, i20, j20, i21, j21, i22, j22, i23, j23, i24, j24, i25, j25; 
	integer i26, i27, j26, j27, i28, j28, i29, j29, i30, j30, i31, j31, i32, j32; 
	integer i33, j33, i34, j34, i35, j35, i36, j36, i37, j37, i38, j38, i39, j39, i40, j40; 
	integer i41, j41, i42, j42, i43, j43, i44, j44, i45, j45, i46, j46, i47, j47, i48, j48;
	integer i49, j49, i50, j50, i51, j51, i52, j52, i53, j53, i54, j54, i55, j55, i56, j56;
	integer i57, j57, i58, j58, i59, j59, i60, j60, i61, j61, i62, j62, i63, j63, i64, j64;
	integer i65, j65, i66, j66, i67, j67, i68, j68, i69, j69, i70, j70, i71, j71, i72, j72;
	integer i73, j73, i74, j74, i75, j75, i76, j76, i77, j77, i78, j78, i79, j79, i80, j80;
	integer i81, j81, i82, j82, i83, j83, i84, j84, i85, j85, i86, j86, i87, j87, i88, j88;	
	
	reg [width_p+3:0] mem_4x4   [0:3][0:3];
	reg [width_p+3:0] mem_4x4_a [0:3][0:3];
	
	reg [2:0] repeat_ctn_0;
	reg [2:0] repeat_ctn_1;	
	reg [2:0] repeat_ctn_2;	
	reg [3:0] repeat_ctn_3;
	reg [6:0] repeat_ctn_4;
	reg [2:0] repeat_ctn_5;
	reg [6:0] repeat_ctn_6;
	reg [6:0] repeat_ctn_7;
	reg [6:0] repeat_ctn_8;
	reg [6:0] repeat_ctn_9;
	reg [6:0] repeat_ctn_10;
	reg [6:0] repeat_ctn_11;
	reg [6:0] repeat_ctn_12;
	reg [6:0] repeat_ctn_13;
	reg [6:0] repeat_ctn_14;
	reg [6:0] repeat_ctn_15;
	reg [6:0] repeat_ctn_16;
	reg [6:0] repeat_ctn_17;
	reg [6:0] repeat_ctn_18;
	reg [6:0] repeat_ctn_19;
	reg [6:0] repeat_ctn_20;
	reg [6:0] repeat_ctn_21;
	reg [6:0] repeat_ctn_22;
	reg [6:0] repeat_ctn_23;
	reg [6:0] repeat_ctn_24;
	reg [6:0] repeat_ctn_25;	
	reg [6:0] repeat_ctn_26;	
	
	reg [2:0] repeat_ctn_w_0;		
	reg [2:0] repeat_ctn_w_1; 	
	reg [3:0] repeat_ctn_w_2;
	reg [3:0] repeat_ctn_w_3;
	reg [6:0] repeat_ctn_w_4; 
	reg [2:0] repeat_ctn_w_5; 
	reg [6:0] repeat_ctn_w_6; 
	reg [6:0] repeat_ctn_w_7; 
	reg [6:0] repeat_ctn_w_8;
	reg [6:0] repeat_ctn_w_9;
	reg [6:0] repeat_ctn_w_10;
	reg [6:0] repeat_ctn_w_11;
	reg [6:0] repeat_ctn_w_12;
	reg [6:0] repeat_ctn_w_13;
	reg [6:0] repeat_ctn_w_14;	
	reg [6:0] repeat_ctn_w_15;
	reg [6:0] repeat_ctn_w_16;
	reg [6:0] repeat_ctn_w_17;
	reg [6:0] repeat_ctn_w_18;
	reg [6:0] repeat_ctn_w_19;
	reg [6:0] repeat_ctn_w_20;
	reg [6:0] repeat_ctn_w_21;
	reg [6:0] repeat_ctn_w_22;
	reg [6:0] repeat_ctn_w_23;
	reg [6:0] repeat_ctn_w_24;
	reg [6:0] repeat_ctn_w_25;
	reg [6:0] repeat_ctn_w_26;
	
	genvar k;
	genvar z; 
	genvar x;
	genvar y;

// ATRIBUIÇÃO INICIAL DO SINAL NÃO SINTETIZA

/* 	column_addr_reg[0]  → bits [width_p-1 : 0]
	column_addr_reg[1]  → bits [2*width_p-1 : width_p]
	column_addr_reg[2]  → ...
	...
	column_addr_reg[63] → last piece	 */

	generate
		for (k = 0; k < 64; k = k + 1) begin : FLATTEN_ROW_ADDR
			assign row_addr_flat_o[k*7 +: 7] = row_addr_reg[k];
		end
	endgenerate

	generate
		for (z = 0; z < 64; z = z + 1) begin : FLATTEN_COLUMN_ADDR
			assign column_addr_flat_o[z*7 +: 7] = column_addr_reg[z];
		end
	endgenerate

	generate
		for (x = 0; x < 16; x = x + 1) begin : FLATTEN_SUB_ROW_ADDR
			assign row_addr_sub_flat_o[x*7 +: 7] = row_addr_sub_reg[x];
		end
	endgenerate

	generate
		for (y = 0; y < 16; y = y + 1) begin : FLATTEN_SUB_COLUMN_ADDR
			assign column_addr_sub_flat_o[y*7 +: 7] = column_addr_sub_reg[y];
		end
	endgenerate

	always @(posedge clk_i) begin
		if (rst_i) begin
			sub_4_2_0_en <= 0;
			sub_4_2_2_en <= 0;
			
		end else begin
			if(load_en_i) begin 
				if(subsampling_x_i && subsampling_y_i) begin 
					sub_4_2_0_en <= 1; 
					sub_4_2_2_en <= 0; 
					
				end else if(subsampling_x_i && (!subsampling_y_i)) begin 
					sub_4_2_0_en <= 0; 
					sub_4_2_2_en <= 1;
					
				end else begin 
					sub_4_2_0_en <= 0; 
					sub_4_2_2_en <= 0;
				end
			end 
		end
	end 
	
	// FSM for 4:2:0 subsampling process 
	
	always @(posedge clk_i) begin
		if (rst_i) begin
			state <= S420_IDLE;
			mem_read_en_reg  	 <= 0; 
			div_shift_reg    	 <= 0; 
			counter_1 			 <= 0;
			samples_loaded_reg   <= 0; 
			repeat_ctn_0 	  	 <= 0;
			repeat_ctn_w_0		 <= 0;
			repeat_ctn_1 	  	 <= 0;
			repeat_ctn_w_1		 <= 0;
			repeat_ctn_2 	  	 <= 0;
			repeat_ctn_3		 <= 0; 
			repeat_ctn_4		 <= 0;
			repeat_ctn_w_2		 <= 0;	
			repeat_ctn_w_3		 <= 0;
			repeat_ctn_w_4		 <= 0; 
			repeat_ctn_5		 <= 0;
			repeat_ctn_w_5		 <= 0;
			repeat_ctn_6		 <= 0;
			repeat_ctn_w_6		 <= 0;
			repeat_ctn_w_7		 <= 0;
			repeat_ctn_7		 <= 0;
			repeat_ctn_w_8		 <= 0;
			repeat_ctn_8		 <= 0;
			repeat_ctn_w_9		 <= 0;
			repeat_ctn_9		 <= 0;
			repeat_ctn_w_10		 <= 0;
			repeat_ctn_10		 <= 0;
			repeat_ctn_w_11		 <= 0;
			repeat_ctn_11		 <= 0;
			repeat_ctn_12		 <= 0;
			repeat_ctn_w_12 	 <= 0;
			repeat_ctn_13		 <= 0;
			repeat_ctn_w_13 	 <= 0;
			sample_out_00_reg 	 <= 0;
			sample_out_01_reg 	 <= 0;	
			sample_out_02_reg 	 <= 0;	
			sample_out_03_reg 	 <= 0;	
			sample_out_04_reg 	 <= 0;	
			sample_out_05_reg 	 <= 0;	
			sample_out_06_reg 	 <= 0;	
			sample_out_07_reg 	 <= 0;	
			sample_out_08_reg 	 <= 0;	
			sample_out_09_reg 	 <= 0;	
			sample_out_10_reg 	 <= 0;	
			sample_out_11_reg 	 <= 0;	
			sample_out_12_reg 	 <= 0;	
			sample_out_13_reg 	 <= 0;	
			sample_out_14_reg 	 <= 0;	
			sample_out_15_reg 	 <= 0;	
			
			for (i5 = 0; i5 < 8; i5 = i5 + 1) begin
				for (j5 = 0; j5 < 8; j5 = j5 + 1) begin
					row_addr_reg[i5*8 + j5]    <= 0;
					column_addr_reg[i5*8 + j5] <= 0;
				end
			end

			for (i7 = 0; i7 < 4; i7 = i7 + 1) begin
				for (j7 = 0; j7 < 4; j7 = j7 + 1) begin
					mem_4x4[i7][j7] <= 0;
				end
			end				
			
		end else begin		
			case(state)				
			
				S420_IDLE: begin
					block_width_reg  <= block_width_i;
					block_height_reg <= block_height_i;
					samples_loaded_reg     <= 0;
					mem_read_en_reg <= 0; 
					
					if((sub_4_2_0_en) && (!samples_loaded_reg)) begin
						state <= S420_LOAD_1;
					end else begin 
						state <= S420_IDLE;
					end 
				end
				
				S420_LOAD_1: begin 
				
					// first address generation 00, 01, 02 ... 77 [row, column] 
					if(sub_4_2_0_en) begin 
						for (i = 0; i < 8; i = i + 1) begin
							for (j = 0; j < 8; j = j + 1) begin
								row_addr_reg[i*8 + j]    <= i;
								column_addr_reg[i*8 + j] <= j;
							end
						end
						
						state <= S420_STOP_1; 
						mem_read_en_reg <= 1;
					end 
				end
				
				S420_STOP_1: begin 
					mem_read_en_reg <= 0; 
					
					if(counter_1 < 1) begin 
						counter_1 <= counter_1 + 1; 
						state   <= S420_STOP_1;
						
					end else begin 
						if(sub_4_2_0_en) begin  
							mem_4x4[0][0] <= ((sample_00_in + sample_01_in) + (sample_08_in + sample_09_in)) >> 2;						
							mem_4x4[0][1] <= ((sample_02_in + sample_03_in) + (sample_10_in + sample_11_in)) >> 2;
							mem_4x4[0][2] <= ((sample_04_in + sample_05_in) + (sample_12_in + sample_13_in)) >> 2;
							mem_4x4[0][3] <= ((sample_06_in + sample_07_in) + (sample_14_in + sample_15_in)) >> 2;
							
							mem_4x4[1][0] <= ((sample_16_in + sample_17_in) + (sample_24_in + sample_25_in)) >> 2;
							mem_4x4[1][1] <= ((sample_18_in + sample_19_in) + (sample_26_in + sample_27_in)) >> 2;
							mem_4x4[1][2] <= ((sample_20_in + sample_21_in) + (sample_28_in + sample_29_in)) >> 2;
							mem_4x4[1][3] <= ((sample_22_in + sample_23_in) + (sample_30_in + sample_31_in)) >> 2;

							mem_4x4[2][0] <= ((sample_32_in + sample_33_in) + (sample_40_in + sample_41_in)) >> 2;
							mem_4x4[2][1] <= ((sample_34_in + sample_35_in) + (sample_42_in + sample_43_in)) >> 2;
							mem_4x4[2][2] <= ((sample_36_in + sample_37_in) + (sample_44_in + sample_45_in)) >> 2;
							mem_4x4[2][3] <= ((sample_38_in + sample_39_in) + (sample_46_in + sample_47_in)) >> 2;
							
							mem_4x4[3][0] <= ((sample_48_in + sample_49_in) + (sample_56_in + sample_57_in)) >> 2;
							mem_4x4[3][1] <= ((sample_50_in + sample_51_in) + (sample_58_in + sample_59_in)) >> 2;
							mem_4x4[3][2] <= ((sample_52_in + sample_53_in) + (sample_60_in + sample_61_in)) >> 2;
							mem_4x4[3][3] <= ((sample_54_in + sample_55_in) + (sample_62_in + sample_63_in)) >> 2;
							
							// Output block 4x4 address
							if((block_width_reg == 8) && (block_height_reg == 8)) begin 	
								for (i8 = 0; i8 < 4; i8 = i8 + 1) begin
									for (j8 = 0; j8 < 4; j8 = j8 + 1) begin
										row_addr_sub_reg[i8*4 + j8]    <= i8;
										column_addr_sub_reg[i8*4 + j8] <= j8;
									end
								end
							
							// Output block 8x8 address
							end else if((block_width_reg == 16) && (block_height_reg == 16)) begin
								case(repeat_ctn_w_0)
									3'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_0 <= repeat_ctn_w_0 + 1;
									end
									
									3'd1 : begin 
										for (i13 = 0; i13 < 4; i13 = i13 + 1) begin
											for (j13 = 0; j13 < 4; j13 = j13 + 1) begin
												row_addr_sub_reg[i13*4 + j13]    <= i13;
												column_addr_sub_reg[i13*4 + j13] <= j13 + 4;
											end
										end									
										repeat_ctn_w_0 <= repeat_ctn_w_0 + 1;
									end 
									
									3'd2 : begin 
										for (i14 = 0; i14 < 4; i14 = i14 + 1) begin
											for (j14 = 0; j14 < 4; j14 = j14 + 1) begin
												row_addr_sub_reg[i14*4 + j14]    <= i14 + 4;
												column_addr_sub_reg[i14*4 + j14] <= j14;
											end
										end										
										repeat_ctn_w_0 <= repeat_ctn_w_0 + 1;
									end 
									
									3'd3 : begin 								
										for (i15 = 0; i15 < 4; i15 = i15 + 1) begin
											for (j15 = 0; j15 < 4; j15 = j15 + 1) begin
												row_addr_sub_reg[i15*4 + j15]    <= i15 + 4;
												column_addr_sub_reg[i15*4 + j15] <= j15 + 4;
											end
										end										
										repeat_ctn_w_0 <= 0;
									end 
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_0 <= 0;
									end 
								endcase
							
							// Output Block 16x16
							end else if((block_width_reg == 32) && (block_height_reg == 32)) begin							
								case(repeat_ctn_w_2)							
									4'd0 : begin 							
										for (i37 = 0; i37 < 4; i37 = i37 + 1) begin
											for (j37 = 0; j37 < 4; j37 = j37 + 1) begin
												row_addr_sub_reg[i37*4 + j37]    <= i37;
												column_addr_sub_reg[i37*4 + j37] <= j37;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end							

									4'd1 : begin 							
										for (i38 = 0; i38 < 4; i38 = i38 + 1) begin
											for (j38 = 0; j38 < 4; j38 = j38 + 1) begin
												row_addr_sub_reg[i38*4 + j38]    <= i38;
												column_addr_sub_reg[i38*4 + j38] <= j38 + 4;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end

									4'd2 : begin 							
										for (i39 = 0; i39 < 4; i39 = i39 + 1) begin
											for (j39 = 0; j39 < 4; j39 = j39 + 1) begin
												row_addr_sub_reg[i39*4 + j39]    <= i39;
												column_addr_sub_reg[i39*4 + j39] <= j39 + 8;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd3 : begin 							
										for (i40 = 0; i40 < 4; i40 = i40 + 1) begin
											for (j40 = 0; j40 < 4; j40 = j40 + 1) begin
												row_addr_sub_reg[i40*4 + j40]    <= i40;
												column_addr_sub_reg[i40*4 + j40] <= j40 + 12;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end

									4'd4 : begin 							
										for (i41 = 0; i41 < 4; i41 = i41 + 1) begin
											for (j41 = 0; j41 < 4; j41 = j41 + 1) begin
												row_addr_sub_reg[i41*4 + j41]    <= i41 + 4;
												column_addr_sub_reg[i41*4 + j41] <= j41;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end		

									4'd5 : begin 							
										for (i42 = 0; i42 < 4; i42 = i42 + 1) begin
											for (j42 = 0; j42 < 4; j42 = j42 + 1) begin
												row_addr_sub_reg[i42*4 + j42]    <= i42 + 4;
												column_addr_sub_reg[i42*4 + j42] <= j42 + 4;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end			

									4'd6 : begin 							
										for (i43 = 0; i43 < 4; i43 = i43 + 1) begin
											for (j43 = 0; j43 < 4; j43 = j43 + 1) begin
												row_addr_sub_reg[i43*4 + j43]    <= i43 + 4;
												column_addr_sub_reg[i43*4 + j43] <= j43 + 8;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd7 : begin 							
										for (i44 = 0; i44 < 4; i44 = i44 + 1) begin
											for (j44 = 0; j44 < 4; j44 = j44 + 1) begin
												row_addr_sub_reg[i44*4 + j44]    <= i44 + 4;
												column_addr_sub_reg[i44*4 + j44] <= j44 + 12;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end		

									4'd8 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 8;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd9 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 8;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd10 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 8;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd11 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 8;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd12 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 12;
												column_addr_sub_reg[i49*4 + j49] <= j49;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end

									4'd13 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 12;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 4;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end

									4'd14 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 12;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 8;
											end
										end
										repeat_ctn_w_2 <= repeat_ctn_w_2 + 1;
									end	

									4'd15 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 12;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 12;
											end
										end
										repeat_ctn_w_2 <= 0;
									end
									
									default: begin 									
										for (i53 = 0; i53 < 4; i53 = i53 + 1) begin
											for (j53 = 0; j53 < 4; j53 = j53 + 1) begin
												row_addr_sub_reg[i53*4 + j53]    <= 0;
												column_addr_sub_reg[i53*4 + j53] <= 0;
											end
										end										
										repeat_ctn_w_2 <= 0;
									end 
								endcase

							// Output Block 32x32
							end else if((block_width_reg == 64) && (block_height_reg == 64)) begin							
								case(repeat_ctn_w_4)							
									7'd0 : begin 							
										for (i37 = 0; i37 < 4; i37 = i37 + 1) begin
											for (j37 = 0; j37 < 4; j37 = j37 + 1) begin
												row_addr_sub_reg[i37*4 + j37]    <= i37;
												column_addr_sub_reg[i37*4 + j37] <= j37;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end							

									7'd1 : begin 							
										for (i38 = 0; i38 < 4; i38 = i38 + 1) begin
											for (j38 = 0; j38 < 4; j38 = j38 + 1) begin
												row_addr_sub_reg[i38*4 + j38]    <= i38;
												column_addr_sub_reg[i38*4 + j38] <= j38 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd2 : begin 							
										for (i39 = 0; i39 < 4; i39 = i39 + 1) begin
											for (j39 = 0; j39 < 4; j39 = j39 + 1) begin
												row_addr_sub_reg[i39*4 + j39]    <= i39;
												column_addr_sub_reg[i39*4 + j39] <= j39 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd3 : begin 							
										for (i40 = 0; i40 < 4; i40 = i40 + 1) begin
											for (j40 = 0; j40 < 4; j40 = j40 + 1) begin
												row_addr_sub_reg[i40*4 + j40]    <= i40;
												column_addr_sub_reg[i40*4 + j40] <= j40 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd4 : begin 							
										for (i41 = 0; i41 < 4; i41 = i41 + 1) begin
											for (j41 = 0; j41 < 4; j41 = j41 + 1) begin
												row_addr_sub_reg[i41*4 + j41]    <= i41;
												column_addr_sub_reg[i41*4 + j41] <= j41 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end		

									7'd5 : begin 							
										for (i42 = 0; i42 < 4; i42 = i42 + 1) begin
											for (j42 = 0; j42 < 4; j42 = j42 + 1) begin
												row_addr_sub_reg[i42*4 + j42]    <= i42;
												column_addr_sub_reg[i42*4 + j42] <= j42 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end			

									7'd6 : begin 							
										for (i43 = 0; i43 < 4; i43 = i43 + 1) begin
											for (j43 = 0; j43 < 4; j43 = j43 + 1) begin
												row_addr_sub_reg[i43*4 + j43]    <= i43;
												column_addr_sub_reg[i43*4 + j43] <= j43 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd7 : begin 							
										for (i44 = 0; i44 < 4; i44 = i44 + 1) begin
											for (j44 = 0; j44 < 4; j44 = j44 + 1) begin
												row_addr_sub_reg[i44*4 + j44]    <= i44;
												column_addr_sub_reg[i44*4 + j44] <= j44 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end		

									7'd8 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 4;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd9 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 4;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd10 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 4;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd11 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 4;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd12 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 4;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd13 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 4;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd14 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 4;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd15 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 4;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd16 : begin 							
										for (i37 = 0; i37 < 4; i37 = i37 + 1) begin
											for (j37 = 0; j37 < 4; j37 = j37 + 1) begin
												row_addr_sub_reg[i37*4 + j37]    <= i37 + 8;
												column_addr_sub_reg[i37*4 + j37] <= j37;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end							

									7'd17 : begin 							
										for (i38 = 0; i38 < 4; i38 = i38 + 1) begin
											for (j38 = 0; j38 < 4; j38 = j38 + 1) begin
												row_addr_sub_reg[i38*4 + j38]    <= i38 + 8; 
												column_addr_sub_reg[i38*4 + j38] <= j38 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd18 : begin 							
										for (i39 = 0; i39 < 4; i39 = i39 + 1) begin
											for (j39 = 0; j39 < 4; j39 = j39 + 1) begin
												row_addr_sub_reg[i39*4 + j39]    <= i39 + 8;
												column_addr_sub_reg[i39*4 + j39] <= j39 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd19 : begin 							
										for (i40 = 0; i40 < 4; i40 = i40 + 1) begin
											for (j40 = 0; j40 < 4; j40 = j40 + 1) begin
												row_addr_sub_reg[i40*4 + j40]    <= i40 + 8;
												column_addr_sub_reg[i40*4 + j40] <= j40 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd20 : begin 							
										for (i41 = 0; i41 < 4; i41 = i41 + 1) begin
											for (j41 = 0; j41 < 4; j41 = j41 + 1) begin
												row_addr_sub_reg[i41*4 + j41]    <= i41 + 8;
												column_addr_sub_reg[i41*4 + j41] <= j41 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end		

									7'd21 : begin 							
										for (i42 = 0; i42 < 4; i42 = i42 + 1) begin
											for (j42 = 0; j42 < 4; j42 = j42 + 1) begin
												row_addr_sub_reg[i42*4 + j42]    <= i42 + 8;
												column_addr_sub_reg[i42*4 + j42] <= j42 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end			

									7'd22 : begin 							
										for (i43 = 0; i43 < 4; i43 = i43 + 1) begin
											for (j43 = 0; j43 < 4; j43 = j43 + 1) begin
												row_addr_sub_reg[i43*4 + j43]    <= i43 + 8;
												column_addr_sub_reg[i43*4 + j43] <= j43 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd23 : begin 							
										for (i44 = 0; i44 < 4; i44 = i44 + 1) begin
											for (j44 = 0; j44 < 4; j44 = j44 + 1) begin
												row_addr_sub_reg[i44*4 + j44]    <= i44 + 8;
												column_addr_sub_reg[i44*4 + j44] <= j44 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end		

									7'd24 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 12;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd25 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 12;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd26 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 12;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd27 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 12;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd28 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 12;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd29 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 12;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd30 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 12;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd31 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 12;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd32 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 16;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd33 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 16;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd34 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 16;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd35 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 16;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd36 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 16;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd37 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 16;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd38 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 16;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd39 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 16;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd40 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 20;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd41 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 20;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd42 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 20;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd43 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 20;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd44 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 20;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd45 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 20;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd46 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 20;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd47 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 20;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd48 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 24;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd49 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 24;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd50 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 24;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd51 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 24;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd52 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 24;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd53 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 24;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd54 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 24;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd55 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 24;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd56 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 28;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd57 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 28;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd58 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 28;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd59 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 28;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd60 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 28;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd61 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 28;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end

									7'd62 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 28;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_4 <= repeat_ctn_w_4 + 1;
									end	

									7'd63 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 28;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_4 <= 0;
									end

									default: begin 									
										for (i53 = 0; i53 < 4; i53 = i53 + 1) begin
											for (j53 = 0; j53 < 4; j53 = j53 + 1) begin
												row_addr_sub_reg[i53*4 + j53]    <= 0;
												column_addr_sub_reg[i53*4 + j53] <= 0;
											end
										end										
										repeat_ctn_w_4 <= 0;
									end 
								endcase
							
							// Output block 4x8 address 
							end else if((block_width_reg == 8) && (block_height_reg == 16)) begin
								case(repeat_ctn_w_1)
									3'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_1 <= repeat_ctn_w_1 + 1;
									end

									3'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_1 <= 0;
									end
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_1 <= 0;
									end									
								endcase
							
							// Output block 8x4
							end else if((block_width_reg == 16) && (block_height_reg == 8)) begin
								case(repeat_ctn_w_5)
									3'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_5 <= repeat_ctn_w_5 + 1;
									end

									3'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_5 <= 0;
									end
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_5 <= 0;
									end
								endcase

							// Output block 8x16 
							end else if((block_width_reg == 16) && (block_height_reg == 32)) begin  
								case(repeat_ctn_w_6)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end									

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_6 <= repeat_ctn_w_6 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_6 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_6 <= 0;
									end
								endcase

							// Output block 16x8
							end else if((block_width_reg == 32) && (block_height_reg == 16)) begin  
								case(repeat_ctn_w_7)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end
								
									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end		

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end	

									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end										

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_7 <= repeat_ctn_w_7 + 1;
									end									

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_7 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_7 <= 0;
									end
								endcase

							// Output block 4x16
							end else if((block_width_reg == 8) && (block_height_reg == 32)) begin  
								case(repeat_ctn_w_8)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_8 <= repeat_ctn_w_8 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_8 <= repeat_ctn_w_8 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_8 <= repeat_ctn_w_8 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_8 <= 0;
									end
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_8 <= 0;
									end									
								endcase

							end else if((block_width_reg == 32) && (block_height_reg == 8)) begin  
								case(repeat_ctn_w_9)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_9 <= repeat_ctn_w_9 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_9 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_9 <= 0;
									end									
								endcase

							// 16x32
							end else if((block_width_reg == 32) && (block_height_reg == 64)) begin  
								case(repeat_ctn_w_10)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd16 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd17 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd18 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd19 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd20 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd21 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd22 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd23 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd24 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd25 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd26 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd27 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end
									
									7'd28 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd29 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end

									7'd30 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_10 <= repeat_ctn_w_10 + 1;
									end				

									7'd31 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_10 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_10 <= 0;
									end	
								endcase	
							
							// 32x16
							end else if((block_width_reg == 64) && (block_height_reg == 32)) begin 
								case(repeat_ctn_w_11)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end								

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end								

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end								

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd16 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd17 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd18 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd19 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd20 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end								

									7'd21 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd22 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd23 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd24 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end									

									7'd25 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd26 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd27 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd28 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end								

									7'd29 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_11 <= repeat_ctn_w_11 + 1;
									end

									7'd30 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_11 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_11 <= 0;
									end									
								endcase

							// 8x32
							end else if((block_width_reg == 16) && (block_height_reg == 64)) begin 
								case(repeat_ctn_w_12)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end
	
									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end
	
									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end
	
									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_12 <= repeat_ctn_w_12 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_12 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_12 <= 0;
									end										
								endcase

							// 32x8
							end else if((block_width_reg == 64) && (block_height_reg == 16)) begin 
								case(repeat_ctn_w_13)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end
	
									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end
	
									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end
	
									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end
	
									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_13 <= repeat_ctn_w_13 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_13 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_13 <= 0;
									end
								endcase
							end 
							state <= S420_WRITE;
							counter_1 <= 0; 
							mem_write_en_reg <= 0;
						end 
					end
				end 
				
				S420_LOAD_2: begin 
				
					mem_write_en_reg <= 0; 					
					if(sub_4_2_0_en) begin
						
						// 8x8 blocks 
						if((block_width_reg == 8) && (block_height_reg == 8)) begin 
							state <= S420_IDLE;
							samples_loaded_reg <= 1;
							sub_4_2_0_en <= 0; 
							
							for (i0 = 0; i0 < 8; i0 = i0 + 1) begin
								for (j0 = 0; j0 < 8; j0 = j0 + 1) begin
									row_addr_reg[i0*8 + j0]    <= 0;
									column_addr_reg[i0*8 + j0] <= 0;
								end
							end

						// 16x16 blocks
						end else if((block_width_reg == 16) && (block_height_reg == 16)) begin
							case(repeat_ctn_2)
								3'd0 : begin 					
									for (i17 = 0; i17 < 8; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_2 <= repeat_ctn_2 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								3'd1 : begin 
									for (i18 = 0; i18 < 8; i18 = i18 + 1) begin
										for (j18 = 0; j18 < 8; j18 = j18 + 1) begin
											row_addr_reg[i18*8 + j18]    <= i18 + 8;
											column_addr_reg[i18*8 + j18] <= j18;
										end
									end									
									repeat_ctn_2 <= repeat_ctn_2 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								3'd2 : begin 
									for (i19 = 0; i19 < 8; i19 = i19 + 1) begin
										for (j19 = 0; j19 < 8; j19 = j19 + 1) begin
											row_addr_reg[i19*8 + j19]    <= i19 + 8;
											column_addr_reg[i19*8 + j19] <= j19 + 8;
										end
									end										
									repeat_ctn_2 <= repeat_ctn_2 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_2 <= 0;
									state <= S420_IDLE;							
								end
							endcase

						// 32x32 blocks
						end else if((block_width_reg == 32) && (block_height_reg == 32)) begin
							case(repeat_ctn_3)
								4'd0 : begin								
									for (i21 = 0; i21 < 8; i21 = i21 + 1) begin
										for (j21 = 0; j21 < 8; j21 = j21 + 1) begin
											row_addr_reg[i21*8 + j21]    <= i21;
											column_addr_reg[i21*8 + j21] <= j21 + 8;
										end
									end
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								4'd1 : begin
									for (i22 = 0; i22 < 8; i22 = i22 + 1) begin
										for (j22 = 0; j22 < 8; j22 = j22 + 1) begin
											row_addr_reg[i22*8 + j22]    <= i22;
											column_addr_reg[i22*8 + j22] <= j22 + 16;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd2 : begin
									for (i23 = 0; i23 < 8; i23 = i23 + 1) begin
										for (j23 = 0; j23 < 8; j23 = j23 + 1) begin
											row_addr_reg[i23*8 + j23]    <= i23;
											column_addr_reg[i23*8 + j23] <= j23 + 24;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd3 : begin
									for (i24 = 0; i24 < 8; i24 = i24 + 1) begin
										for (j24 = 0; j24 < 8; j24 = j24 + 1) begin
											row_addr_reg[i24*8 + j24]    <= i24 + 8;
											column_addr_reg[i24*8 + j24] <= j24;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								4'd4 : begin
									for (i25 = 0; i25 < 8; i25 = i25 + 1) begin
										for (j25 = 0; j25 < 8; j25 = j25 + 1) begin
											row_addr_reg[i25*8 + j25]    <= i25 + 8;
											column_addr_reg[i25*8 + j25] <= j25 + 8;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd5 : begin
									for (i26 = 0; i26 < 8; i26 = i26 + 1) begin
										for (j26 = 0; j26 < 8; j26 = j26 + 1) begin
											row_addr_reg[i26*8 + j26]    <= i26 + 8;
											column_addr_reg[i26*8 + j26] <= j26 + 16;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd6 : begin
									for (i27 = 0; i27 < 8; i27 = i27 + 1) begin
										for (j27 = 0; j27 < 8; j27 = j27 + 1) begin
											row_addr_reg[i27*8 + j27]    <= i27 + 8;
											column_addr_reg[i27*8 + j27] <= j27 + 24;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd7 : begin
									for (i28 = 0; i28 < 8; i28 = i28 + 1) begin
										for (j28 = 0; j28 < 8; j28 = j28 + 1) begin
											row_addr_reg[i28*8 + j28]    <= i28 + 16;
											column_addr_reg[i28*8 + j28] <= j28;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd8 : begin
									for (i29 = 0; i29 < 8; i29 = i29 + 1) begin
										for (j29 = 0; j29 < 8; j29 = j29 + 1) begin
											row_addr_reg[i29*8 + j29]    <= i29 + 16;
											column_addr_reg[i29*8 + j29] <= j29 + 8;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;	
								end

								4'd9 : begin
									for (i30 = 0; i30 < 8; i30 = i30 + 1) begin
										for (j30 = 0; j30 < 8; j30 = j30 + 1) begin
											row_addr_reg[i30*8 + j30]    <= i30 + 16;
											column_addr_reg[i30*8 + j30] <= j30 + 16;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								4'd10 : begin
									for (i31 = 0; i31 < 8; i31 = i31 + 1) begin
										for (j31 = 0; j31 < 8; j31 = j31 + 1) begin
											row_addr_reg[i31*8 + j31]    <= i31 + 16;
											column_addr_reg[i31*8 + j31] <= j31 + 24;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								4'd11 : begin
									for (i32 = 0; i32 < 8; i32 = i32 + 1) begin
										for (j32 = 0; j32 < 8; j32 = j32 + 1) begin
											row_addr_reg[i32*8 + j32]    <= i32 + 24;
											column_addr_reg[i32*8 + j32] <= j32;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								4'd12 : begin
									for (i33 = 0; i33 < 8; i33 = i33 + 1) begin
										for (j33 = 0; j33 < 8; j33 = j33 + 1) begin
											row_addr_reg[i33*8 + j33]    <= i33 + 24;
											column_addr_reg[i33*8 + j33] <= j33 + 8;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd13 : begin
									for (i34 = 0; i34 < 8; i34 = i34 + 1) begin
										for (j34 = 0; j34 < 8; j34 = j34 + 1) begin
											row_addr_reg[i34*8 + j34]    <= i34 + 24;
											column_addr_reg[i34*8 + j34] <= j34 + 16;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								4'd14 : begin
									for (i35 = 0; i35 < 8; i35 = i35 + 1) begin
										for (j35 = 0; j35 < 8; j35 = j35 + 1) begin
											row_addr_reg[i35*8 + j35]    <= i35 + 24;
											column_addr_reg[i35*8 + j35] <= j35 + 24;
										end
									end									
									repeat_ctn_3 <= repeat_ctn_3 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_3 <= 0;
									state <= S420_IDLE;							
								end
							endcase

						// 64x64 blocks 
						end else if((block_width_reg == 64) && (block_height_reg == 64)) begin
							case(repeat_ctn_4)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd1 : begin
									for (i55 = 0; i55 < 8; i55 = i55 + 1) begin
										for (j55 = 0; j55 < 8; j55 = j55 + 1) begin
											row_addr_reg[i55*8 + j55]    <= i55;
											column_addr_reg[i55*8 + j55] <= j55 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd2 : begin
									for (i56 = 0; i56 < 8; i56 = i56 + 1) begin
										for (j56 = 0; j56 < 8; j56 = j56 + 1) begin
											row_addr_reg[i56*8 + j56]    <= i56;
											column_addr_reg[i56*8 + j56] <= j56 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd3 : begin
									for (i57 = 0; i57 < 8; i57 = i57 + 1) begin
										for (j57 = 0; j57 < 8; j57 = j57 + 1) begin
											row_addr_reg[i57*8 + j57]    <= i57;
											column_addr_reg[i57*8 + j57] <= j57 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd4 : begin
									for (i58 = 0; i58 < 8; i58 = i58 + 1) begin
										for (j58 = 0; j58 < 8; j58 = j58 + 1) begin
											row_addr_reg[i58*8 + j58]    <= i58;
											column_addr_reg[i58*8 + j58] <= j58 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd5 : begin
									for (i59 = 0; i59 < 8; i59 = i59 + 1) begin
										for (j59 = 0; j59 < 8; j59 = j59 + 1) begin
											row_addr_reg[i59*8 + j59]    <= i59;
											column_addr_reg[i59*8 + j59] <= j59 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd6 : begin
									for (i60 = 0; i60 < 8; i60 = i60 + 1) begin
										for (j60 = 0; j60 < 8; j60 = j60 + 1) begin
											row_addr_reg[i60*8 + j60]    <= i60;
											column_addr_reg[i60*8 + j60] <= j60 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd7 : begin
									for (i61 = 0; i61 < 8; i61 = i61 + 1) begin
										for (j61 = 0; j61 < 8; j61 = j61 + 1) begin
											row_addr_reg[i61*8 + j61]    <= i61 + 8;
											column_addr_reg[i61*8 + j61] <= j61;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd8 : begin
									for (i62 = 0; i62 < 8; i62 = i62 + 1) begin
										for (j62 = 0; j62 < 8; j62 = j62 + 1) begin
											row_addr_reg[i62*8 + j62]    <= i62 + 8;
											column_addr_reg[i62*8 + j62] <= j62 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd9 : begin
									for (i63 = 0; i63 < 8; i63 = i63 + 1) begin
										for (j63 = 0; j63 < 8; j63 = j63 + 1) begin
											row_addr_reg[i63*8 + j63]    <= i63 + 8;
											column_addr_reg[i63*8 + j63] <= j63 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd10 : begin
									for (i64 = 0; i64 < 8; i64 = i64 + 1) begin
										for (j64 = 0; j64 < 8; j64 = j64 + 1) begin
											row_addr_reg[i64*8 + j64]    <= i64 + 8;
											column_addr_reg[i64*8 + j64] <= j64 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd11 : begin
									for (i65 = 0; i65 < 8; i65 = i65 + 1) begin
										for (j65 = 0; j65 < 8; j65 = j65 + 1) begin
											row_addr_reg[i65*8 + j65]    <= i65 + 8;
											column_addr_reg[i65*8 + j65] <= j65 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd12 : begin
									for (i66 = 0; i66 < 8; i66 = i66 + 1) begin
										for (j66 = 0; j66 < 8; j66 = j66 + 1) begin
											row_addr_reg[i66*8 + j66]    <= i66 + 8;
											column_addr_reg[i66*8 + j66] <= j66 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd13 : begin
									for (i67 = 0; i67 < 8; i67 = i67 + 1) begin
										for (j67 = 0; j67 < 8; j67 = j67 + 1) begin
											row_addr_reg[i67*8 + j67]    <= i67 + 8;
											column_addr_reg[i67*8 + j67] <= j67 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd14 : begin
									for (i68 = 0; i68 < 8; i68 = i68 + 1) begin
										for (j68 = 0; j68 < 8; j68 = j68 + 1) begin
											row_addr_reg[i68*8 + j68]    <= i68 + 8;
											column_addr_reg[i68*8 + j68] <= j68 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd15 : begin
									for (i69 = 0; i69 < 8; i69 = i69 + 1) begin
										for (j69 = 0; j69 < 8; j69 = j69 + 1) begin
											row_addr_reg[i69*8 + j69]    <= i69 + 16;
											column_addr_reg[i69*8 + j69] <= j69;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd16 : begin
									for (i70 = 0; i70 < 8; i70 = i70 + 1) begin
										for (j70 = 0; j70 < 8; j70 = j70 + 1) begin
											row_addr_reg[i70*8 + j70]    <= i70 + 16;
											column_addr_reg[i70*8 + j70] <= j70 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd17 : begin
									for (i71 = 0; i71 < 8; i71 = i71 + 1) begin
										for (j71 = 0; j71 < 8; j71 = j71 + 1) begin
											row_addr_reg[i71*8 + j71]    <= i71 + 16;
											column_addr_reg[i71*8 + j71] <= j71 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd18 : begin
									for (i72 = 0; i72 < 8; i72 = i72 + 1) begin
										for (j72 = 0; j72 < 8; j72 = j72 + 1) begin
											row_addr_reg[i72*8 + j72]    <= i72 + 16;
											column_addr_reg[i72*8 + j72] <= j72 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd19 : begin
									for (i73 = 0; i73 < 8; i73 = i73 + 1) begin
										for (j73 = 0; j73 < 8; j73 = j73 + 1) begin
											row_addr_reg[i73*8 + j73]    <= i73 + 16;
											column_addr_reg[i73*8 + j73] <= j73 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd20 : begin
									for (i74 = 0; i74 < 8; i74 = i74 + 1) begin
										for (j74 = 0; j74 < 8; j74 = j74 + 1) begin
											row_addr_reg[i74*8 + j74]    <= i74 + 16;
											column_addr_reg[i74*8 + j74] <= j74 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd21 : begin
									for (i75 = 0; i75 < 8; i75 = i75 + 1) begin
										for (j75 = 0; j75 < 8; j75 = j75 + 1) begin
											row_addr_reg[i75*8 + j75]    <= i75 + 16;
											column_addr_reg[i75*8 + j75] <= j75 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd22 : begin
									for (i76 = 0; i76 < 8; i76 = i76 + 1) begin
										for (j76 = 0; j76 < 8; j76 = j76 + 1) begin
											row_addr_reg[i76*8 + j76]    <= i76 + 16;
											column_addr_reg[i76*8 + j76] <= j76 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd23 : begin
									for (i69 = 0; i69 < 8; i69 = i69 + 1) begin
										for (j69 = 0; j69 < 8; j69 = j69 + 1) begin
											row_addr_reg[i69*8 + j69]    <= i69 + 24;
											column_addr_reg[i69*8 + j69] <= j69;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd24 : begin
									for (i70 = 0; i70 < 8; i70 = i70 + 1) begin
										for (j70 = 0; j70 < 8; j70 = j70 + 1) begin
											row_addr_reg[i70*8 + j70]    <= i70 + 24;
											column_addr_reg[i70*8 + j70] <= j70 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd25 : begin
									for (i71 = 0; i71 < 8; i71 = i71 + 1) begin
										for (j71 = 0; j71 < 8; j71 = j71 + 1) begin
											row_addr_reg[i71*8 + j71]    <= i71 + 24;
											column_addr_reg[i71*8 + j71] <= j71 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd26 : begin
									for (i72 = 0; i72 < 8; i72 = i72 + 1) begin
										for (j72 = 0; j72 < 8; j72 = j72 + 1) begin
											row_addr_reg[i72*8 + j72]    <= i72 + 24;
											column_addr_reg[i72*8 + j72] <= j72 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd27 : begin
									for (i73 = 0; i73 < 8; i73 = i73 + 1) begin
										for (j73 = 0; j73 < 8; j73 = j73 + 1) begin
											row_addr_reg[i73*8 + j73]    <= i73 + 24;
											column_addr_reg[i73*8 + j73] <= j73 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd28 : begin
									for (i74 = 0; i74 < 8; i74 = i74 + 1) begin
										for (j74 = 0; j74 < 8; j74 = j74 + 1) begin
											row_addr_reg[i74*8 + j74]    <= i74 + 24;
											column_addr_reg[i74*8 + j74] <= j74 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd29 : begin
									for (i75 = 0; i75 < 8; i75 = i75 + 1) begin
										for (j75 = 0; j75 < 8; j75 = j75 + 1) begin
											row_addr_reg[i75*8 + j75]    <= i75 + 24;
											column_addr_reg[i75*8 + j75] <= j75 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd30 : begin
									for (i76 = 0; i76 < 8; i76 = i76 + 1) begin
										for (j76 = 0; j76 < 8; j76 = j76 + 1) begin
											row_addr_reg[i76*8 + j76]    <= i76 + 24;
											column_addr_reg[i76*8 + j76] <= j76 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd31 : begin
									for (i69 = 0; i69 < 8; i69 = i69 + 1) begin
										for (j69 = 0; j69 < 8; j69 = j69 + 1) begin
											row_addr_reg[i69*8 + j69]    <= i69 + 32;
											column_addr_reg[i69*8 + j69] <= j69;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd32 : begin
									for (i70 = 0; i70 < 8; i70 = i70 + 1) begin
										for (j70 = 0; j70 < 8; j70 = j70 + 1) begin
											row_addr_reg[i70*8 + j70]    <= i70 + 32;
											column_addr_reg[i70*8 + j70] <= j70 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd33 : begin
									for (i71 = 0; i71 < 8; i71 = i71 + 1) begin
										for (j71 = 0; j71 < 8; j71 = j71 + 1) begin
											row_addr_reg[i71*8 + j71]    <= i71 + 32;
											column_addr_reg[i71*8 + j71] <= j71 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd34 : begin
									for (i72 = 0; i72 < 8; i72 = i72 + 1) begin
										for (j72 = 0; j72 < 8; j72 = j72 + 1) begin
											row_addr_reg[i72*8 + j72]    <= i72 + 32;
											column_addr_reg[i72*8 + j72] <= j72 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd35 : begin
									for (i73 = 0; i73 < 8; i73 = i73 + 1) begin
										for (j73 = 0; j73 < 8; j73 = j73 + 1) begin
											row_addr_reg[i73*8 + j73]    <= i73 + 32;
											column_addr_reg[i73*8 + j73] <= j73 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd36 : begin
									for (i74 = 0; i74 < 8; i74 = i74 + 1) begin
										for (j74 = 0; j74 < 8; j74 = j74 + 1) begin
											row_addr_reg[i74*8 + j74]    <= i74 + 32;
											column_addr_reg[i74*8 + j74] <= j74 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd37 : begin
									for (i75 = 0; i75 < 8; i75 = i75 + 1) begin
										for (j75 = 0; j75 < 8; j75 = j75 + 1) begin
											row_addr_reg[i75*8 + j75]    <= i75 + 32;
											column_addr_reg[i75*8 + j75] <= j75 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd38 : begin
									for (i76 = 0; i76 < 8; i76 = i76 + 1) begin
										for (j76 = 0; j76 < 8; j76 = j76 + 1) begin
											row_addr_reg[i76*8 + j76]    <= i76 + 32;
											column_addr_reg[i76*8 + j76] <= j76 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd39 : begin
									for (i69 = 0; i69 < 8; i69 = i69 + 1) begin
										for (j69 = 0; j69 < 8; j69 = j69 + 1) begin
											row_addr_reg[i69*8 + j69]    <= i69 + 40;
											column_addr_reg[i69*8 + j69] <= j69;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd40 : begin
									for (i70 = 0; i70 < 8; i70 = i70 + 1) begin
										for (j70 = 0; j70 < 8; j70 = j70 + 1) begin
											row_addr_reg[i70*8 + j70]    <= i70 + 40;
											column_addr_reg[i70*8 + j70] <= j70 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd41 : begin
									for (i71 = 0; i71 < 8; i71 = i71 + 1) begin
										for (j71 = 0; j71 < 8; j71 = j71 + 1) begin
											row_addr_reg[i71*8 + j71]    <= i71 + 40;
											column_addr_reg[i71*8 + j71] <= j71 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd42 : begin
									for (i72 = 0; i72 < 8; i72 = i72 + 1) begin
										for (j72 = 0; j72 < 8; j72 = j72 + 1) begin
											row_addr_reg[i72*8 + j72]    <= i72 + 40;
											column_addr_reg[i72*8 + j72] <= j72 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd43 : begin
									for (i73 = 0; i73 < 8; i73 = i73 + 1) begin
										for (j73 = 0; j73 < 8; j73 = j73 + 1) begin
											row_addr_reg[i73*8 + j73]    <= i73 + 40;
											column_addr_reg[i73*8 + j73] <= j73 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd44 : begin
									for (i74 = 0; i74 < 8; i74 = i74 + 1) begin
										for (j74 = 0; j74 < 8; j74 = j74 + 1) begin
											row_addr_reg[i74*8 + j74]    <= i74 + 40;
											column_addr_reg[i74*8 + j74] <= j74 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd45 : begin
									for (i75 = 0; i75 < 8; i75 = i75 + 1) begin
										for (j75 = 0; j75 < 8; j75 = j75 + 1) begin
											row_addr_reg[i75*8 + j75]    <= i75 + 40;
											column_addr_reg[i75*8 + j75] <= j75 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd46 : begin
									for (i76 = 0; i76 < 8; i76 = i76 + 1) begin
										for (j76 = 0; j76 < 8; j76 = j76 + 1) begin
											row_addr_reg[i76*8 + j76]    <= i76 + 40;
											column_addr_reg[i76*8 + j76] <= j76 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd47 : begin
									for (i69 = 0; i69 < 8; i69 = i69 + 1) begin
										for (j69 = 0; j69 < 8; j69 = j69 + 1) begin
											row_addr_reg[i69*8 + j69]    <= i69 + 48;
											column_addr_reg[i69*8 + j69] <= j69;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd48 : begin
									for (i70 = 0; i70 < 8; i70 = i70 + 1) begin
										for (j70 = 0; j70 < 8; j70 = j70 + 1) begin
											row_addr_reg[i70*8 + j70]    <= i70 + 48;
											column_addr_reg[i70*8 + j70] <= j70 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd49 : begin
									for (i71 = 0; i71 < 8; i71 = i71 + 1) begin
										for (j71 = 0; j71 < 8; j71 = j71 + 1) begin
											row_addr_reg[i71*8 + j71]    <= i71 + 48;
											column_addr_reg[i71*8 + j71] <= j71 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd50 : begin
									for (i72 = 0; i72 < 8; i72 = i72 + 1) begin
										for (j72 = 0; j72 < 8; j72 = j72 + 1) begin
											row_addr_reg[i72*8 + j72]    <= i72 + 48;
											column_addr_reg[i72*8 + j72] <= j72 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd51 : begin
									for (i73 = 0; i73 < 8; i73 = i73 + 1) begin
										for (j73 = 0; j73 < 8; j73 = j73 + 1) begin
											row_addr_reg[i73*8 + j73]    <= i73 + 48;
											column_addr_reg[i73*8 + j73] <= j73 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd52 : begin
									for (i74 = 0; i74 < 8; i74 = i74 + 1) begin
										for (j74 = 0; j74 < 8; j74 = j74 + 1) begin
											row_addr_reg[i74*8 + j74]    <= i74 + 48;
											column_addr_reg[i74*8 + j74] <= j74 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd53 : begin
									for (i75 = 0; i75 < 8; i75 = i75 + 1) begin
										for (j75 = 0; j75 < 8; j75 = j75 + 1) begin
											row_addr_reg[i75*8 + j75]    <= i75 + 48;
											column_addr_reg[i75*8 + j75] <= j75 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd54 : begin
									for (i76 = 0; i76 < 8; i76 = i76 + 1) begin
										for (j76 = 0; j76 < 8; j76 = j76 + 1) begin
											row_addr_reg[i76*8 + j76]    <= i76 + 48;
											column_addr_reg[i76*8 + j76] <= j76 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd55 : begin
									for (i69 = 0; i69 < 8; i69 = i69 + 1) begin
										for (j69 = 0; j69 < 8; j69 = j69 + 1) begin
											row_addr_reg[i69*8 + j69]    <= i69 + 56;
											column_addr_reg[i69*8 + j69] <= j69;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								7'd56 : begin
									for (i70 = 0; i70 < 8; i70 = i70 + 1) begin
										for (j70 = 0; j70 < 8; j70 = j70 + 1) begin
											row_addr_reg[i70*8 + j70]    <= i70 + 56;
											column_addr_reg[i70*8 + j70] <= j70 + 8;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd57 : begin
									for (i71 = 0; i71 < 8; i71 = i71 + 1) begin
										for (j71 = 0; j71 < 8; j71 = j71 + 1) begin
											row_addr_reg[i71*8 + j71]    <= i71 + 56;
											column_addr_reg[i71*8 + j71] <= j71 + 16;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd58 : begin
									for (i72 = 0; i72 < 8; i72 = i72 + 1) begin
										for (j72 = 0; j72 < 8; j72 = j72 + 1) begin
											row_addr_reg[i72*8 + j72]    <= i72 + 56;
											column_addr_reg[i72*8 + j72] <= j72 + 24;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd59 : begin
									for (i73 = 0; i73 < 8; i73 = i73 + 1) begin
										for (j73 = 0; j73 < 8; j73 = j73 + 1) begin
											row_addr_reg[i73*8 + j73]    <= i73 + 56;
											column_addr_reg[i73*8 + j73] <= j73 + 32;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd60 : begin
									for (i74 = 0; i74 < 8; i74 = i74 + 1) begin
										for (j74 = 0; j74 < 8; j74 = j74 + 1) begin
											row_addr_reg[i74*8 + j74]    <= i74 + 56;
											column_addr_reg[i74*8 + j74] <= j74 + 40;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 

								7'd61 : begin
									for (i75 = 0; i75 < 8; i75 = i75 + 1) begin
										for (j75 = 0; j75 < 8; j75 = j75 + 1) begin
											row_addr_reg[i75*8 + j75]    <= i75 + 56;
											column_addr_reg[i75*8 + j75] <= j75 + 48;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd62 : begin
									for (i76 = 0; i76 < 8; i76 = i76 + 1) begin
										for (j76 = 0; j76 < 8; j76 = j76 + 1) begin
											row_addr_reg[i76*8 + j76]    <= i76 + 56;
											column_addr_reg[i76*8 + j76] <= j76 + 56;
										end
									end									
									repeat_ctn_4 <= repeat_ctn_4 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_4 <= 0;
									state <= S420_IDLE;							
								end
							endcase

						// 8x16 blocks
						end else if((block_width_reg == 8) && (block_height_reg == 16)) begin
							case(repeat_ctn_0)
								4'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_0 <= repeat_ctn_0 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_0 <= 0;
									state <= S420_IDLE;							
								end
							endcase

						// 16x8 blocks
						end else if((block_width_reg == 16) && (block_height_reg == 8)) begin
							case(repeat_ctn_5)
								4'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_5 <= repeat_ctn_5 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end 
								
								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_5 <= 0;
									state <= S420_IDLE;							
								end
							endcase
							
						// 16x32 blocks
						end else if((block_width_reg == 16) && (block_height_reg == 32)) begin
							case(repeat_ctn_6)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end
								
								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_6 <= repeat_ctn_6 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_6 <= 0;
									state <= S420_IDLE;							
								end
							endcase
							
						end else if((block_width_reg == 32) && (block_height_reg == 16)) begin
							case(repeat_ctn_7)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end							

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end								
							
								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end				

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_7 <= repeat_ctn_7 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_7 <= 0;
									state <= S420_IDLE;							
								end
							endcase

						// 4x16
						end else if((block_width_reg == 8) && (block_height_reg == 32)) begin
							case(repeat_ctn_8)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_8 <= repeat_ctn_8 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_8 <= repeat_ctn_8 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_8 <= repeat_ctn_8 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_8 <= 0;
									state <= S420_IDLE;							
								end								
							endcase

						end else if((block_width_reg == 32) && (block_height_reg == 8)) begin
							case(repeat_ctn_9)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end						

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end									

/* 								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_9 <= repeat_ctn_9 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end */
								
								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_9 <= 0;
									state <= S420_IDLE;							
								end								
							endcase
						
						end else if((block_width_reg == 32) && (block_height_reg == 64)) begin
							case(repeat_ctn_10)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd7 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd8 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd9 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd10 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd11 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd12 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd13 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd14 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd15 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 32;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd16 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 32;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd17 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 32;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd18 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 32;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd19 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 40;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd20 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 40;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd21 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 40;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd22 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 40;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd23 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 48;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd24 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 48;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd25 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 48;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd26 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 48;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd27 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd28 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd29 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd30 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_10 <= repeat_ctn_10 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end
								
								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_10 <= 0;
									state <= S420_IDLE;							
								end								
							endcase
						
						end else if((block_width_reg == 64) && (block_height_reg == 32)) begin
							case(repeat_ctn_11)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end							

								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 32;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 40;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 48;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 56;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd7 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd8 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd9 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end							

								7'd10 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd11 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 32;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd12 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 40;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd13 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 48;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end		

								7'd14 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 56;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end			
								
								7'd15 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd16 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd17 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end							

								7'd18 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd19 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 32;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd20 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 40;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd21 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 48;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end		

								7'd22 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 56;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd23 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd24 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd25 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end							

								7'd26 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd27 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 32;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd28 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 40;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end	

								7'd29 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 48;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end		

								7'd30 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 56;
										end
									end
									repeat_ctn_11 <= repeat_ctn_11 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								default: begin
									for (i36 = 0; i36 < 8; i36 = i36 + 1) begin
										for (j36 = 0; j36 < 8; j36 = j36 + 1) begin
											row_addr_reg[i36*8 + j36]    <= 0;
											column_addr_reg[i36*8 + j36] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_11 <= 0;
									state <= S420_IDLE;							
								end	
							endcase
						
						end else if((block_width_reg == 16) && (block_height_reg == 64)) begin
							case(repeat_ctn_12)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 16;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 24;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd7 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 32;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd8 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 32;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd9 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 40;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd10 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 40;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd11 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 48;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd12 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 48;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd13 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd14 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

/* 								7'd15 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd16 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 56;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_12 <= repeat_ctn_12 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end */

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_12 <= 0;
									state <= S420_IDLE;							
								end
							endcase
						
						end else if((block_width_reg == 64) && (block_height_reg == 16)) begin
							case(repeat_ctn_13)
								7'd0 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd1 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd2 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd3 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 32;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd4 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 40;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd5 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 48;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd6 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54;
											column_addr_reg[i54*8 + j54] <= j54 + 56;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd7 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd8 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 8;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd9 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 16;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd10 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 24;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd11 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 32;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd12 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 40;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd13 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 48;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end

								7'd14 : begin								
									for (i54 = 0; i54 < 8; i54 = i54 + 1) begin
										for (j54 = 0; j54 < 8; j54 = j54 + 1) begin
											row_addr_reg[i54*8 + j54]    <= i54 + 8;
											column_addr_reg[i54*8 + j54] <= j54 + 56;
										end
									end
									repeat_ctn_13 <= repeat_ctn_13 + 1;
									state <= S420_STOP_1;
									mem_read_en_reg <= 1;
								end
								
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg <= 1;
									sub_4_2_0_en <= 0;								
									repeat_ctn_13 <= 0;
									state <= S420_IDLE;							
								end							
							endcase
						end
					end	
				end 

				S420_WRITE: begin 
					
					if(sub_4_2_0_en) begin 

						sample_out_00_reg <= mem_4x4[0][0];
						sample_out_01_reg <= mem_4x4[0][1];					
						sample_out_02_reg <= mem_4x4[0][2];
						sample_out_03_reg <= mem_4x4[0][3];
						sample_out_04_reg <= mem_4x4[1][0];
						sample_out_05_reg <= mem_4x4[1][1];
						sample_out_06_reg <= mem_4x4[1][2];
						sample_out_07_reg <= mem_4x4[1][3];
						sample_out_08_reg <= mem_4x4[2][0];
						sample_out_09_reg <= mem_4x4[2][1];
						sample_out_10_reg <= mem_4x4[2][2];
						sample_out_11_reg <= mem_4x4[2][3];
						sample_out_12_reg <= mem_4x4[3][0];
						sample_out_13_reg <= mem_4x4[3][1];
						sample_out_14_reg <= mem_4x4[3][2];
						sample_out_15_reg <= mem_4x4[3][3];		

						for (i4 = 0; i4 < 4; i4 = i4 + 1) begin
							for (j4 = 0; j4 < 4; j4 = j4 + 1) begin
								mem_4x4[i4][j4] <= 0;
							end
						end	
						mem_write_en_reg <= 1;
						state <= S420_LOAD_2;
					end
				end 

				default: begin
					state <= S420_IDLE; 
				end 
			endcase 		
		end
	end

	// FSM for 4:2:2 subsampling process
	
	always @(posedge clk_i) begin
		if (rst_i) begin
			fsm <= S422_IDLE;
			repeat_ctn_14		 <= 0;
			counter_2 			 <= 0;
			repeat_ctn_w_14 	 <= 0;
			repeat_ctn_15		 <= 0;
			repeat_ctn_w_15 	 <= 0;
			repeat_ctn_16		 <= 0;
			repeat_ctn_w_16 	 <= 0;
			repeat_ctn_17		 <= 0;
			repeat_ctn_w_17 	 <= 0;
			repeat_ctn_18		 <= 0;
			repeat_ctn_w_18 	 <= 0;
			repeat_ctn_19		 <= 0;
			repeat_ctn_w_19 	 <= 0;
			repeat_ctn_20		 <= 0;
			repeat_ctn_w_20 	 <= 0;
			repeat_ctn_21		 <= 0;
			repeat_ctn_w_21 	 <= 0;
			repeat_ctn_22		 <= 0;
			repeat_ctn_w_22 	 <= 0;
			repeat_ctn_23		 <= 0;
			repeat_ctn_w_23 	 <= 0;
			repeat_ctn_24		 <= 0;
			repeat_ctn_w_24 	 <= 0;
			repeat_ctn_25		 <= 0;
			repeat_ctn_w_25 	 <= 0;
			repeat_ctn_26		 <= 0;
			repeat_ctn_w_26 	 <= 0;			
			

			for (i7 = 0; i7 < 4; i7 = i7 + 1) begin
				for (j7 = 0; j7 < 4; j7 = j7 + 1) begin
					mem_4x4_a[i7][j7] <= 0;
				end
			end		

		end else begin		
			case(fsm)
				
				S422_IDLE: begin
					samples_loaded_reg_422    <= 0;
					mem_read_en_reg_422	 	  <= 0; 
					
					if((sub_4_2_2_en) && (!samples_loaded_reg_422)) begin
						fsm <= S422_LOAD_1;
					end else begin 
						fsm <= S422_IDLE;
					end 
				end

				S422_LOAD_1: begin 
				
					// first address generation 00, 01, 02 ... 77 [row, column] 
					if(sub_4_2_2_en) begin 
						for (i = 0; i < 4; i = i + 1) begin
							for (j = 0; j < 8; j = j + 1) begin
								row_addr_reg[i*8 + j]    <= i;
								column_addr_reg[i*8 + j] <= j;
							end
						end
						
						fsm <= S422_STOP_1; 
						mem_read_en_reg_422 <= 1;
					end 
				end

				S422_STOP_1: begin 
					mem_read_en_reg_422 <= 0; 
					
					if(counter_2 < 1) begin 
						counter_2 <= counter_2 + 1; 
						fsm   <= S422_STOP_1;
						
					end else begin 
						if(sub_4_2_2_en) begin  
							mem_4x4_a[0][0] <= (sample_00_in + sample_01_in) >> 1;						
							mem_4x4_a[0][1] <= (sample_02_in + sample_03_in) >> 1;
							mem_4x4_a[0][2] <= (sample_04_in + sample_05_in) >> 1;
							mem_4x4_a[0][3] <= (sample_06_in + sample_07_in) >> 1;
							
							mem_4x4_a[1][0] <= (sample_08_in + sample_09_in) >> 1;
							mem_4x4_a[1][1] <= (sample_10_in + sample_11_in) >> 1;
							mem_4x4_a[1][2] <= (sample_12_in + sample_13_in) >> 1;
							mem_4x4_a[1][3] <= (sample_14_in + sample_15_in) >> 1;

							mem_4x4_a[2][0] <= (sample_16_in + sample_17_in) >> 1;
							mem_4x4_a[2][1] <= (sample_18_in + sample_19_in) >> 1;
							mem_4x4_a[2][2] <= (sample_20_in + sample_21_in) >> 1;
							mem_4x4_a[2][3] <= (sample_22_in + sample_23_in) >> 1;
							
							mem_4x4_a[3][0] <= (sample_24_in + sample_25_in) >> 1;
							mem_4x4_a[3][1] <= (sample_26_in + sample_27_in) >> 1;
							mem_4x4_a[3][2] <= (sample_28_in + sample_29_in) >> 1;
							mem_4x4_a[3][3] <= (sample_30_in + sample_31_in) >> 1;
							
							// Output block 4x4 address
							if((block_width_reg == 8) && (block_height_reg == 4)) begin 	
								for (i8 = 0; i8 < 4; i8 = i8 + 1) begin
									for (j8 = 0; j8 < 4; j8 = j8 + 1) begin
										row_addr_sub_reg[i8*4 + j8]    <= i8;
										column_addr_sub_reg[i8*4 + j8] <= j8;
									end
								end
								
							// Output block 8x8 address 
							end else if((block_width_reg == 16) && (block_height_reg == 8)) begin
								case(repeat_ctn_w_14)
									3'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_14 <= repeat_ctn_w_14 + 1;
									end
									
									3'd1 : begin 
										for (i13 = 0; i13 < 4; i13 = i13 + 1) begin
											for (j13 = 0; j13 < 4; j13 = j13 + 1) begin
												row_addr_sub_reg[i13*4 + j13]    <= i13;
												column_addr_sub_reg[i13*4 + j13] <= j13 + 4;
											end
										end									
										repeat_ctn_w_14 <= repeat_ctn_w_14 + 1;
									end 
									
									3'd2 : begin 
										for (i14 = 0; i14 < 4; i14 = i14 + 1) begin
											for (j14 = 0; j14 < 4; j14 = j14 + 1) begin
												row_addr_sub_reg[i14*4 + j14]    <= i14 + 4;
												column_addr_sub_reg[i14*4 + j14] <= j14;
											end
										end										
										repeat_ctn_w_14 <= repeat_ctn_w_14 + 1;
									end 
									
									3'd3 : begin 								
										for (i15 = 0; i15 < 4; i15 = i15 + 1) begin
											for (j15 = 0; j15 < 4; j15 = j15 + 1) begin
												row_addr_sub_reg[i15*4 + j15]    <= i15 + 4;
												column_addr_sub_reg[i15*4 + j15] <= j15 + 4;
											end
										end										
										repeat_ctn_w_14 <= 0;
									end 
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_14 <= 0;
									end 
								endcase

							end else if((block_width_reg == 32) && (block_height_reg == 16)) begin							
								case(repeat_ctn_w_15)							
									4'd0 : begin 							
										for (i37 = 0; i37 < 4; i37 = i37 + 1) begin
											for (j37 = 0; j37 < 4; j37 = j37 + 1) begin
												row_addr_sub_reg[i37*4 + j37]    <= i37;
												column_addr_sub_reg[i37*4 + j37] <= j37;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end							

									4'd1 : begin 							
										for (i38 = 0; i38 < 4; i38 = i38 + 1) begin
											for (j38 = 0; j38 < 4; j38 = j38 + 1) begin
												row_addr_sub_reg[i38*4 + j38]    <= i38;
												column_addr_sub_reg[i38*4 + j38] <= j38 + 4;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end

									4'd2 : begin 							
										for (i39 = 0; i39 < 4; i39 = i39 + 1) begin
											for (j39 = 0; j39 < 4; j39 = j39 + 1) begin
												row_addr_sub_reg[i39*4 + j39]    <= i39;
												column_addr_sub_reg[i39*4 + j39] <= j39 + 8;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd3 : begin 							
										for (i40 = 0; i40 < 4; i40 = i40 + 1) begin
											for (j40 = 0; j40 < 4; j40 = j40 + 1) begin
												row_addr_sub_reg[i40*4 + j40]    <= i40;
												column_addr_sub_reg[i40*4 + j40] <= j40 + 12;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end

									4'd4 : begin 							
										for (i41 = 0; i41 < 4; i41 = i41 + 1) begin
											for (j41 = 0; j41 < 4; j41 = j41 + 1) begin
												row_addr_sub_reg[i41*4 + j41]    <= i41 + 4;
												column_addr_sub_reg[i41*4 + j41] <= j41;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end		

									4'd5 : begin 							
										for (i42 = 0; i42 < 4; i42 = i42 + 1) begin
											for (j42 = 0; j42 < 4; j42 = j42 + 1) begin
												row_addr_sub_reg[i42*4 + j42]    <= i42 + 4;
												column_addr_sub_reg[i42*4 + j42] <= j42 + 4;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end			

									4'd6 : begin 							
										for (i43 = 0; i43 < 4; i43 = i43 + 1) begin
											for (j43 = 0; j43 < 4; j43 = j43 + 1) begin
												row_addr_sub_reg[i43*4 + j43]    <= i43 + 4;
												column_addr_sub_reg[i43*4 + j43] <= j43 + 8;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd7 : begin 							
										for (i44 = 0; i44 < 4; i44 = i44 + 1) begin
											for (j44 = 0; j44 < 4; j44 = j44 + 1) begin
												row_addr_sub_reg[i44*4 + j44]    <= i44 + 4;
												column_addr_sub_reg[i44*4 + j44] <= j44 + 12;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end		

									4'd8 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 8;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd9 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 8;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd10 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 8;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd11 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 8;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd12 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 12;
												column_addr_sub_reg[i49*4 + j49] <= j49;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end

									4'd13 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 12;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 4;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end

									4'd14 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 12;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 8;
											end
										end
										repeat_ctn_w_15 <= repeat_ctn_w_15 + 1;
									end	

									4'd15 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 12;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 12;
											end
										end
										repeat_ctn_w_15 <= 0;
									end
									
									default: begin 									
										for (i53 = 0; i53 < 4; i53 = i53 + 1) begin
											for (j53 = 0; j53 < 4; j53 = j53 + 1) begin
												row_addr_sub_reg[i53*4 + j53]    <= 0;
												column_addr_sub_reg[i53*4 + j53] <= 0;
											end
										end										
										repeat_ctn_w_15 <= 0;
									end 
								endcase

							end else if((block_width_reg == 64) && (block_height_reg == 32)) begin							
								case(repeat_ctn_w_16)							
									7'd0 : begin 							
										for (i37 = 0; i37 < 4; i37 = i37 + 1) begin
											for (j37 = 0; j37 < 4; j37 = j37 + 1) begin
												row_addr_sub_reg[i37*4 + j37]    <= i37;
												column_addr_sub_reg[i37*4 + j37] <= j37;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end							

									7'd1 : begin 							
										for (i38 = 0; i38 < 4; i38 = i38 + 1) begin
											for (j38 = 0; j38 < 4; j38 = j38 + 1) begin
												row_addr_sub_reg[i38*4 + j38]    <= i38;
												column_addr_sub_reg[i38*4 + j38] <= j38 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd2 : begin 							
										for (i39 = 0; i39 < 4; i39 = i39 + 1) begin
											for (j39 = 0; j39 < 4; j39 = j39 + 1) begin
												row_addr_sub_reg[i39*4 + j39]    <= i39;
												column_addr_sub_reg[i39*4 + j39] <= j39 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd3 : begin 							
										for (i40 = 0; i40 < 4; i40 = i40 + 1) begin
											for (j40 = 0; j40 < 4; j40 = j40 + 1) begin
												row_addr_sub_reg[i40*4 + j40]    <= i40;
												column_addr_sub_reg[i40*4 + j40] <= j40 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd4 : begin 							
										for (i41 = 0; i41 < 4; i41 = i41 + 1) begin
											for (j41 = 0; j41 < 4; j41 = j41 + 1) begin
												row_addr_sub_reg[i41*4 + j41]    <= i41;
												column_addr_sub_reg[i41*4 + j41] <= j41 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end		

									7'd5 : begin 							
										for (i42 = 0; i42 < 4; i42 = i42 + 1) begin
											for (j42 = 0; j42 < 4; j42 = j42 + 1) begin
												row_addr_sub_reg[i42*4 + j42]    <= i42;
												column_addr_sub_reg[i42*4 + j42] <= j42 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end			

									7'd6 : begin 							
										for (i43 = 0; i43 < 4; i43 = i43 + 1) begin
											for (j43 = 0; j43 < 4; j43 = j43 + 1) begin
												row_addr_sub_reg[i43*4 + j43]    <= i43;
												column_addr_sub_reg[i43*4 + j43] <= j43 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd7 : begin 							
										for (i44 = 0; i44 < 4; i44 = i44 + 1) begin
											for (j44 = 0; j44 < 4; j44 = j44 + 1) begin
												row_addr_sub_reg[i44*4 + j44]    <= i44;
												column_addr_sub_reg[i44*4 + j44] <= j44 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end		

									7'd8 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 4;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd9 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 4;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd10 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 4;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd11 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 4;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd12 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 4;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd13 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 4;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd14 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 4;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd15 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 4;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd16 : begin 							
										for (i37 = 0; i37 < 4; i37 = i37 + 1) begin
											for (j37 = 0; j37 < 4; j37 = j37 + 1) begin
												row_addr_sub_reg[i37*4 + j37]    <= i37 + 8;
												column_addr_sub_reg[i37*4 + j37] <= j37;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end							

									7'd17 : begin 							
										for (i38 = 0; i38 < 4; i38 = i38 + 1) begin
											for (j38 = 0; j38 < 4; j38 = j38 + 1) begin
												row_addr_sub_reg[i38*4 + j38]    <= i38 + 8; 
												column_addr_sub_reg[i38*4 + j38] <= j38 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd18 : begin 							
										for (i39 = 0; i39 < 4; i39 = i39 + 1) begin
											for (j39 = 0; j39 < 4; j39 = j39 + 1) begin
												row_addr_sub_reg[i39*4 + j39]    <= i39 + 8;
												column_addr_sub_reg[i39*4 + j39] <= j39 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd19 : begin 							
										for (i40 = 0; i40 < 4; i40 = i40 + 1) begin
											for (j40 = 0; j40 < 4; j40 = j40 + 1) begin
												row_addr_sub_reg[i40*4 + j40]    <= i40 + 8;
												column_addr_sub_reg[i40*4 + j40] <= j40 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd20 : begin 							
										for (i41 = 0; i41 < 4; i41 = i41 + 1) begin
											for (j41 = 0; j41 < 4; j41 = j41 + 1) begin
												row_addr_sub_reg[i41*4 + j41]    <= i41 + 8;
												column_addr_sub_reg[i41*4 + j41] <= j41 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end		

									7'd21 : begin 							
										for (i42 = 0; i42 < 4; i42 = i42 + 1) begin
											for (j42 = 0; j42 < 4; j42 = j42 + 1) begin
												row_addr_sub_reg[i42*4 + j42]    <= i42 + 8;
												column_addr_sub_reg[i42*4 + j42] <= j42 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end			

									7'd22 : begin 							
										for (i43 = 0; i43 < 4; i43 = i43 + 1) begin
											for (j43 = 0; j43 < 4; j43 = j43 + 1) begin
												row_addr_sub_reg[i43*4 + j43]    <= i43 + 8;
												column_addr_sub_reg[i43*4 + j43] <= j43 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd23 : begin 							
										for (i44 = 0; i44 < 4; i44 = i44 + 1) begin
											for (j44 = 0; j44 < 4; j44 = j44 + 1) begin
												row_addr_sub_reg[i44*4 + j44]    <= i44 + 8;
												column_addr_sub_reg[i44*4 + j44] <= j44 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end		

									7'd24 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 12;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd25 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 12;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd26 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 12;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd27 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 12;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd28 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 12;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd29 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 12;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd30 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 12;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd31 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 12;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd32 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 16;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd33 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 16;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd34 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 16;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd35 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 16;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd36 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 16;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd37 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 16;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd38 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 16;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd39 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 16;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd40 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 20;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd41 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 20;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd42 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 20;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd43 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 20;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd44 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 20;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd45 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 20;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd46 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 20;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd47 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 20;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd48 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 24;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd49 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 24;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd50 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 24;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd51 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 24;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd52 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 24;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd53 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 24;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd54 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 24;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd55 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 24;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd56 : begin 							
										for (i45 = 0; i45 < 4; i45 = i45 + 1) begin
											for (j45 = 0; j45 < 4; j45 = j45 + 1) begin
												row_addr_sub_reg[i45*4 + j45]    <= i45 + 28;
												column_addr_sub_reg[i45*4 + j45] <= j45;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd57 : begin 							
										for (i46 = 0; i46 < 4; i46 = i46 + 1) begin
											for (j46 = 0; j46 < 4; j46 = j46 + 1) begin
												row_addr_sub_reg[i46*4 + j46]    <= i46 + 28;
												column_addr_sub_reg[i46*4 + j46] <= j46 + 4;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd58 : begin 							
										for (i47 = 0; i47 < 4; i47 = i47 + 1) begin
											for (j47 = 0; j47 < 4; j47 = j47 + 1) begin
												row_addr_sub_reg[i47*4 + j47]    <= i47 + 28;
												column_addr_sub_reg[i47*4 + j47] <= j47 + 8;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd59 : begin 							
										for (i48 = 0; i48 < 4; i48 = i48 + 1) begin
											for (j48 = 0; j48 < 4; j48 = j48 + 1) begin
												row_addr_sub_reg[i48*4 + j48]    <= i48 + 28;
												column_addr_sub_reg[i48*4 + j48] <= j48 + 12;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd60 : begin 							
										for (i49 = 0; i49 < 4; i49 = i49 + 1) begin
											for (j49 = 0; j49 < 4; j49 = j49 + 1) begin
												row_addr_sub_reg[i49*4 + j49]    <= i49 + 28;
												column_addr_sub_reg[i49*4 + j49] <= j49 + 16;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd61 : begin 							
										for (i50 = 0; i50 < 4; i50 = i50 + 1) begin
											for (j50 = 0; j50 < 4; j50 = j50 + 1) begin
												row_addr_sub_reg[i50*4 + j50]    <= i50 + 28;
												column_addr_sub_reg[i50*4 + j50] <= j50 + 20;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end

									7'd62 : begin 							
										for (i51 = 0; i51 < 4; i51 = i51 + 1) begin
											for (j51 = 0; j51 < 4; j51 = j51 + 1) begin
												row_addr_sub_reg[i51*4 + j51]    <= i51 + 28;
												column_addr_sub_reg[i51*4 + j51] <= j51 + 24;
											end
										end
										repeat_ctn_w_16 <= repeat_ctn_w_16 + 1;
									end	

									7'd63 : begin 							
										for (i52 = 0; i52 < 4; i52 = i52 + 1) begin
											for (j52 = 0; j52 < 4; j52 = j52 + 1) begin
												row_addr_sub_reg[i52*4 + j52]    <= i52 + 28;
												column_addr_sub_reg[i52*4 + j52] <= j52 + 28;
											end
										end
										repeat_ctn_w_16 <= 0;
									end

									default: begin 									
										for (i53 = 0; i53 < 4; i53 = i53 + 1) begin
											for (j53 = 0; j53 < 4; j53 = j53 + 1) begin
												row_addr_sub_reg[i53*4 + j53]    <= 0;
												column_addr_sub_reg[i53*4 + j53] <= 0;
											end
										end										
										repeat_ctn_w_16 <= 0;
									end 
								endcase							

							end else if((block_width_reg == 8) && (block_height_reg == 8)) begin							
								case(repeat_ctn_w_17)
									3'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_17 <= repeat_ctn_w_17 + 1;
									end

									3'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_17 <= 0;
									end
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_17 <= 0;
									end									
								endcase

							// Output block 8x4
							end else if((block_width_reg == 16) && (block_height_reg == 4)) begin
								case(repeat_ctn_w_18)
									3'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_18 <= repeat_ctn_w_18 + 1;
									end

									3'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_18 <= 0;
									end
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_18 <= 0;
									end
								endcase 

							end else if((block_width_reg == 16) && (block_height_reg == 16)) begin  
								case(repeat_ctn_w_19)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end									

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_19 <= repeat_ctn_w_19 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_19 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_19 <= 0;
									end
								endcase

							end else if((block_width_reg == 32) && (block_height_reg == 8)) begin  
								case(repeat_ctn_w_20)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end
								
									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end		

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end	

									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end										

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_20 <= repeat_ctn_w_20 + 1;
									end									

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_20 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_20 <= 0;
									end
								endcase

							end else if((block_width_reg == 8) && (block_height_reg == 16)) begin  
								case(repeat_ctn_w_21)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_21 <= repeat_ctn_w_21 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_21 <= repeat_ctn_w_21 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_21 <= repeat_ctn_w_21 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_21 <= 0;
									end
									
									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_21 <= 0;
									end									
								endcase

							end else if((block_width_reg == 32) && (block_height_reg == 4)) begin  
								case(repeat_ctn_w_22)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_22 <= repeat_ctn_w_22 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_22 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_22 <= 0;
									end									
								endcase

							end else if((block_width_reg == 32) && (block_height_reg == 32)) begin  
								case(repeat_ctn_w_23)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd16 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd17 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd18 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd19 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_10 + 1;
									end

									7'd20 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd21 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd22 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd23 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd24 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd25 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd26 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd27 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end
									
									7'd28 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd29 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end

									7'd30 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_23 <= repeat_ctn_w_23 + 1;
									end				

									7'd31 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_23 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_23 <= 0;
									end	
								endcase

							end else if((block_width_reg == 64) && (block_height_reg == 16)) begin 
								case(repeat_ctn_w_24)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end								

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end								

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end								

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd16 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd17 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd18 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd19 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd20 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end								

									7'd21 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd22 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd23 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd24 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end									

									7'd25 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd26 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd27 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd28 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end								

									7'd29 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_24 <= repeat_ctn_w_24 + 1;
									end

									7'd30 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_24 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_24 <= 0;
									end									
								endcase

							end else if((block_width_reg == 16) && (block_height_reg == 32)) begin 
								case(repeat_ctn_w_25)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end
	
									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 8;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end
	
									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 16;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 20;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end
	
									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 24;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_25 <= repeat_ctn_w_25 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 28;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_25 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_25 <= 0;
									end										
								endcase

							end else if((block_width_reg == 64) && (block_height_reg == 8)) begin 
								case(repeat_ctn_w_26)
									7'd0 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end
	
									7'd1 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd2 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd3 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd4 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end
	
									7'd5 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd6 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd7 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end
	
									7'd8 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end
	
									7'd9 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 4;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd10 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 8;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd11 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 12;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd12 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 16;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end
	
									7'd13 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 20;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd14 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 24;
											end
										end
										repeat_ctn_w_26 <= repeat_ctn_w_26 + 1;
									end

									7'd15 : begin 							
										for (i12 = 0; i12 < 4; i12 = i12 + 1) begin
											for (j12 = 0; j12 < 4; j12 = j12 + 1) begin
												row_addr_sub_reg[i12*4 + j12]    <= i12 + 4;
												column_addr_sub_reg[i12*4 + j12] <= j12 + 28;
											end
										end
										repeat_ctn_w_26 <= 0;
									end

									default: begin 									
										for (i16 = 0; i16 < 4; i16 = i16 + 1) begin
											for (j16 = 0; j16 < 4; j16 = j16 + 1) begin
												row_addr_sub_reg[i16*4 + j16]    <= 0;
												column_addr_sub_reg[i16*4 + j16] <= 0;
											end
										end										
										repeat_ctn_w_26 <= 0;
									end
								endcase							
							end
							fsm <= S422_WRITE;
							counter_2 <= 0; 
							mem_write_en_reg_422 <= 0;
						end
					end
				end

				S422_LOAD_2: begin 
				
					mem_write_en_reg_422 <= 0; 					
					if(sub_4_2_2_en) begin
						
						// 8x4 blocks 
						if((block_width_reg == 8) && (block_height_reg == 4)) begin 
							fsm <= S422_IDLE;
							samples_loaded_reg_422 <= 1;
							sub_4_2_2_en <= 0; 
							
							for (i0 = 0; i0 < 8; i0 = i0 + 1) begin
								for (j0 = 0; j0 < 8; j0 = j0 + 1) begin
									row_addr_reg[i0*8 + j0]    <= 0;
									column_addr_reg[i0*8 + j0] <= 0;
								end
							end							

						end else if((block_width_reg == 16) && (block_height_reg == 8)) begin
							case(repeat_ctn_14)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_14 <= repeat_ctn_14 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_14 <= repeat_ctn_14 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_14 <= repeat_ctn_14 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end
								
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_14 <= 0;
									fsm <= S422_IDLE;							
								end
								
							endcase
						
						end else if((block_width_reg == 32) && (block_height_reg == 16)) begin
							case(repeat_ctn_15)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd7 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd8 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd9 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd10 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd11 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd12 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd13 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd14 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_15 <= repeat_ctn_15 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end
								
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_15 <= 0;
									fsm <= S422_IDLE;							
								end
							endcase
						
						end else if((block_width_reg == 64) && (block_height_reg == 32)) begin
							case(repeat_ctn_16)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd7 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd8 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd9 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd10 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd11 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd12 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd13 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd14 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd15 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd16 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd17 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd18 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd19 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd20 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd21 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd22 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end	

								7'd23 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd24 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd25 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd26 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd27 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd28 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd29 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd30 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd31 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;								
								end

								7'd32 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd33 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd34 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd35 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd36 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd37 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd38 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd39 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd40 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd41 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd42 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd43 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd44 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd45 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd46 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd47 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd48 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd49 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd50 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd51 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd52 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd53 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd54 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd55 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd56 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd57 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd58 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd59 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd60 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd61 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end	

								7'd62 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_16 <= repeat_ctn_16 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_16 <= 0;
									fsm <= S422_IDLE;							
								end
							endcase

						end else if((block_width_reg == 8) && (block_height_reg == 8)) begin
							case(repeat_ctn_17)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_17 <= repeat_ctn_17 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end
							
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_17 <= 0;
									fsm <= S422_IDLE;							
								end							
							endcase

						end else if((block_width_reg == 16) && (block_height_reg == 4)) begin
							case(repeat_ctn_18)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_18 <= repeat_ctn_18 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_18 <= 0;
									fsm <= S422_IDLE;							
								end							
							endcase

						end else if((block_width_reg == 16) && (block_height_reg == 16)) begin
							case(repeat_ctn_19)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_19 <= repeat_ctn_19 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_19 <= 0;
									fsm <= S422_IDLE;							
								end	
							endcase	

						end else if((block_width_reg == 32) && (block_height_reg == 8)) begin
							case(repeat_ctn_20)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_20 <= repeat_ctn_20 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_20 <= 0;
									fsm <= S422_IDLE;							
								end
							endcase

						end else if((block_width_reg == 8) && (block_height_reg == 16)) begin
							case(repeat_ctn_21)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_21 <= repeat_ctn_21 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17; 
										end
									end
									repeat_ctn_21 <= repeat_ctn_21 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_21 <= repeat_ctn_21 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end
								
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_21 <= 0;
									fsm <= S422_IDLE;							
								end
							endcase

						end else if((block_width_reg == 32) && (block_height_reg == 4)) begin
							case(repeat_ctn_22)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_22 <= repeat_ctn_22 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_22 <= repeat_ctn_22 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_22 <= repeat_ctn_22 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_22 <= 0;
									fsm <= S422_IDLE;							
								end
							endcase
						
						end else if((block_width_reg == 32) && (block_height_reg == 32)) begin
							case(repeat_ctn_23)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 24; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd7 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd8 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd9 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd10 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd11 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd12 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd13 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd14 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd15 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd16 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd17 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd18 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd19 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd20 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd21 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd22 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd23 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd24 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd25 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd26 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd27 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd28 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd29 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd30 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_23 <= repeat_ctn_23 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end
								
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_23 <= 0;
									fsm <= S422_IDLE;							
								end							
							endcase

						end else if((block_width_reg == 64) && (block_height_reg == 16)) begin
							case(repeat_ctn_24)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 40; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd7 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd8 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd9 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd10 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd11 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 32; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd12 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd13 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd14 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd15 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd16 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd17 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd18 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 24; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd19 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd20 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd21 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd22 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 56; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd23 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd24 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd25 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd26 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd27 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd28 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd29 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd30 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 56;
										end
									end
									repeat_ctn_24 <= repeat_ctn_24 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_24 <= 0;
									fsm <= S422_IDLE;							
								end	
							endcase

						end else if((block_width_reg == 16) && (block_height_reg == 32)) begin
							case(repeat_ctn_25)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17; 
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 8;
											column_addr_reg[i17*8 + j17] <= j17 + 8; 
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 12;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd7 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17; 
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd8 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 16;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end								

								7'd9 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd10 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 20;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd11 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17; 
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd12 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 24;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end	

								7'd13 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17; 
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd14 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 28;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_25 <= repeat_ctn_25 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end
							
								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_25 <= 0;
									fsm <= S422_IDLE;							
								end							
							endcase

						end else if((block_width_reg == 64) && (block_height_reg == 8)) begin
							case(repeat_ctn_26)
								7'd0 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 8;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd1 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 16; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd2 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd3 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 32;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd4 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 40; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd5 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 48;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd6 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17;
											column_addr_reg[i17*8 + j17] <= j17 + 56; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd7 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd8 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 8; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd9 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 16;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd10 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 24;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd11 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 32; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd12 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 40;
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd13 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 48; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								7'd14 : begin 					
									for (i17 = 0; i17 < 4; i17 = i17 + 1) begin
										for (j17 = 0; j17 < 8; j17 = j17 + 1) begin
											row_addr_reg[i17*8 + j17]    <= i17 + 4;
											column_addr_reg[i17*8 + j17] <= j17 + 56; 
										end
									end
									repeat_ctn_26 <= repeat_ctn_26 + 1;
									fsm <= S422_STOP_1;
									mem_read_en_reg_422 <= 1;
								end

								default: begin 
									for (i20 = 0; i20 < 8; i20 = i20 + 1) begin
										for (j20 = 0; j20 < 8; j20 = j20 + 1) begin
											row_addr_reg[i20*8 + j20]    <= 0;
											column_addr_reg[i20*8 + j20] <= 0;
										end
									end		
									samples_loaded_reg_422 <= 1;
									sub_4_2_2_en  <= 0;								
									repeat_ctn_26 <= 0;
									fsm <= S422_IDLE;							
								end							
							endcase
						end
					end 
				end

				S422_WRITE: begin 
					
					if(sub_4_2_2_en) begin 
						sample_out_00_reg <= mem_4x4_a[0][0];
						sample_out_01_reg <= mem_4x4_a[0][1];					
						sample_out_02_reg <= mem_4x4_a[0][2];
						sample_out_03_reg <= mem_4x4_a[0][3];
						sample_out_04_reg <= mem_4x4_a[1][0];
						sample_out_05_reg <= mem_4x4_a[1][1];
						sample_out_06_reg <= mem_4x4_a[1][2];
						sample_out_07_reg <= mem_4x4_a[1][3];
						sample_out_08_reg <= mem_4x4_a[2][0];
						sample_out_09_reg <= mem_4x4_a[2][1];
						sample_out_10_reg <= mem_4x4_a[2][2];
						sample_out_11_reg <= mem_4x4_a[2][3];
						sample_out_12_reg <= mem_4x4_a[3][0];
						sample_out_13_reg <= mem_4x4_a[3][1];
						sample_out_14_reg <= mem_4x4_a[3][2];
						sample_out_15_reg <= mem_4x4_a[3][3];		

						for (i4 = 0; i4 < 4; i4 = i4 + 1) begin
							for (j4 = 0; j4 < 4; j4 = j4 + 1) begin
								mem_4x4_a[i4][j4] <= 0;
							end
						end	
						mem_write_en_reg_422 <= 1;
						fsm <= S422_LOAD_2;
					end
				end				
				
				default: begin
					fsm <= S422_IDLE; 
				end 
				
			endcase 
		end
	end 
	
	always @(posedge clk_i) begin
		div_shift_reg <= 0; 
		
		if(block_height_reg == block_width_reg) begin 
			if(sub_4_2_0_en) begin 
				
				if(block_height_reg == 64) begin 
					div_shift_reg 		 <= 10;
					block_sub_row_reg 	 <= 32;
					block_sub_column_reg <= 32;	
					
				end else if(block_height_reg == 32) begin 
					div_shift_reg 		 <= 8;
					block_sub_row_reg 	 <= 16;
					block_sub_column_reg <= 16;	
					
				end else if(block_height_reg == 16) begin 
					div_shift_reg 		 <= 6;				
					block_sub_row_reg 	 <= 8;
					block_sub_column_reg <= 8;	
					
				end else if(block_height_reg == 8) begin
					div_shift_reg 		 <= 4;								
					block_sub_row_reg 	 <= 4;
					block_sub_column_reg <= 4;	
					
				end else if(block_height_reg == 4) begin
					div_shift_reg 		 <= 2;
					block_sub_row_reg 	 <= 2;
					block_sub_column_reg <= 2;
				end
				
			end else if(sub_4_2_2_en) begin

				if(block_height_reg == 64) begin 
					div_shift_reg 		 <= 11;
					block_sub_row_reg 	 <= 64;
					block_sub_column_reg <= 32;
					
				end else if(block_height_reg == 32) begin 
					div_shift_reg 		 <= 9;
					block_sub_row_reg 	 <= 32;
					block_sub_column_reg <= 16;
					
				end else if(block_height_reg == 16) begin 
					div_shift_reg 		 <= 7;				
					block_sub_row_reg 	 <= 16;
					block_sub_column_reg <= 8;
					
				end else if(block_height_reg == 8) begin
					div_shift_reg 		 <= 5;								
					block_sub_row_reg 	 <= 8;
					block_sub_column_reg <= 4;

				end else if(block_height_reg == 4) begin
					div_shift_reg 		 <= 3;
					block_sub_row_reg 	 <= 4;
					block_sub_column_reg <= 2;
					
				end
			end
			
		end else if((block_width_reg == 4 && block_height_reg == 8) || (block_width_reg == 8 && block_height_reg == 4)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 3; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 4;
			end 
			
		end else if((block_width_reg == 4 && block_height_reg == 16) || (block_width_reg == 16 && block_height_reg == 4)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 4; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 5;
			end		

		end else if((block_width_reg == 8 && block_height_reg == 16) || (block_width_reg == 16 && block_height_reg == 8)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 5; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 6;
			end	
			
		end else if((block_width_reg == 8 && block_height_reg == 32) || (block_width_reg == 32 && block_height_reg == 8)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 6; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 7;
			end		

		end else if((block_width_reg == 16 && block_height_reg == 32) || (block_width_reg == 32 && block_height_reg == 16)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 7; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 8;
			end	

		end else if((block_width_reg == 16 && block_height_reg == 64) || (block_width_reg == 64 && block_height_reg == 16)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 8; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 9;
			end	

		end else if((block_width_reg == 32 && block_height_reg == 64) || (block_width_reg == 64 && block_height_reg == 32)) begin 
			if(sub_4_2_0_en) begin 
				div_shift_reg <= 9; 
				
			end else if(sub_4_2_2_en) begin
				div_shift_reg <= 10;
			end
		end 
	end
	
	always @(posedge clk_i) begin
		if(sub_4_2_0_en) begin 
			block_sub_row_reg 	 <= block_height_reg >> 1; 
			block_sub_column_reg <= block_width_reg  >> 1; 
			
		end else if(sub_4_2_2_en) begin 
			block_sub_row_reg 	 <= block_height_reg;
			block_sub_column_reg <= block_width_reg >> 1; 
		end
	end 

	assign mem_read_en_o       =  mem_read_en_reg     ||  mem_read_en_reg_422; 
	assign mem_write_en_o      =  mem_write_en_reg    ||  mem_write_en_reg_422; 
	assign samples_loaded_o    =  samples_loaded_reg  ||  samples_loaded_reg_422;
	
	assign div_shift_o		   =  div_shift_reg;
	assign block_sub_row_o	   =  block_sub_row_reg;
	assign block_sub_column_o  =  block_sub_column_reg;
	
	assign sample_out_00_o	   = sample_out_00_reg;
	assign sample_out_01_o	   = sample_out_01_reg;
	assign sample_out_02_o	   = sample_out_02_reg;
	assign sample_out_03_o	   = sample_out_03_reg;
	assign sample_out_04_o	   = sample_out_04_reg;
	assign sample_out_05_o	   = sample_out_05_reg;
	assign sample_out_06_o	   = sample_out_06_reg;
	assign sample_out_07_o	   = sample_out_07_reg;
	assign sample_out_08_o	   = sample_out_08_reg;
	assign sample_out_09_o	   = sample_out_09_reg;
	assign sample_out_10_o	   = sample_out_10_reg;
	assign sample_out_11_o	   = sample_out_11_reg;
	assign sample_out_12_o	   = sample_out_12_reg;
	assign sample_out_13_o	   = sample_out_13_reg;
	assign sample_out_14_o	   = sample_out_14_reg;
	assign sample_out_15_o	   = sample_out_15_reg;

endmodule

