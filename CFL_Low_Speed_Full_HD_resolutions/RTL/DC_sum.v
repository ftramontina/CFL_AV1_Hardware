// SUM of all pixels 
// Load one sample per cycle => Total are up to 16 samples of 10 bits each 
// Sum of all them 


module DC_SUM_16  
  #(
  
   parameter width_p 	    = 10, 			// The samples have 10 bits for High Definition Video
   parameter samples_n_p	= 16			// Number of samples of VRS for 16 block   
   
  )
  (
  
   input wire clk_i,
   input wire rst_i, 
   
   input wire data_in_valid_i, 		
   input wire [6:0] sample_number_i, 			// The number of samples, height (left samples) or width (above samples)
   
   input wire [width_p-1:0] sample_0_i,  	
   input wire [width_p-1:0] sample_1_i,  
   input wire [width_p-1:0] sample_2_i,  
   input wire [width_p-1:0] sample_3_i,  
   
   //output wire [samples_n_p*width_p-1:0] data_out_test 
   output wire data_available_o, 
   output wire ready_to_load_o,
   output wire [19:0] DC_Sum_o 

   );
   
   reg [samples_n_p*width_p-1:0] VRS_reg;

   wire VRS_full_w; 										
   reg  [1:0] repeat_load = 0;
   reg  [6:0] block_sample_number_reg;
   reg  [6:0] block_sample_number_2_reg = 0;
   reg	[4:0] write_ptr_reg; 	
   reg 	ready_to_load; 
   
   reg  ready_4_reg 	= 0; 
   reg  ready_8_reg		= 0; 
   reg  ready_16_reg	= 0;  
   reg  ready_32_reg	= 0;  
   reg  ready_64_reg	= 0;

   reg [20:0] Acc_reg 		 = 0;
   reg [5:0]  repeat_1_clk   = 0; 
   reg [5:0]  repeat_2_clk	 = 0;
   reg [5:0]  repeat_counter = 0; 
   
   reg ready_2_Acc_reg = 0; 
   
   integer i;  
  
   wire [width_p-1:0] 	data_in_0_w;
   wire [width_p-1:0] 	data_in_1_w;
   wire [width_p:0]   	sum_0_1_w;
   reg  [width_p:0]   	sum_0_1_reg;
   
   wire [width_p-1:0] 	data_in_2_w;
   wire [width_p-1:0] 	data_in_3_w;
   wire [width_p:0]   	sum_2_3_w;
   reg  [width_p:0]   	sum_2_3_reg;  

   wire [width_p-1:0] 	data_in_4_w;
   wire [width_p-1:0] 	data_in_5_w;
   wire [width_p:0]   	sum_4_5_w;
   reg  [width_p:0]   	sum_4_5_reg;      

   wire [width_p-1:0] 	data_in_6_w;
   wire [width_p-1:0] 	data_in_7_w;
   wire [width_p:0]   	sum_6_7_w;
   reg  [width_p:0]   	sum_6_7_reg;  

   wire [width_p-1:0] 	data_in_8_w;
   wire [width_p-1:0] 	data_in_9_w;
   wire [width_p:0]   	sum_8_9_w;
   reg  [width_p:0]   	sum_8_9_reg; 

   wire [width_p-1:0] 	data_in_10_w;
   wire [width_p-1:0] 	data_in_11_w;
   wire [width_p:0]   	sum_10_11_w;
   reg  [width_p:0]   	sum_10_11_reg; 

   wire [width_p-1:0] 	data_in_12_w;
   wire [width_p-1:0] 	data_in_13_w;
   wire [width_p:0]   	sum_12_13_w;
   reg  [width_p:0]   	sum_12_13_reg; 

   wire [width_p-1:0] 	data_in_14_w;
   wire [width_p-1:0] 	data_in_15_w;
   wire [width_p:0]   	sum_14_15_w;
   reg  [width_p:0]   	sum_14_15_reg; 

   // ------------ second row of adders ------------ 

   wire [width_p:0] 	data_in_S_0_w;
   wire [width_p:0] 	data_in_S_1_w;
   wire [width_p+1:0] 	sum_S_0_1_w;
   reg  [width_p+1:0]   sum_K_0_1_reg;

   wire [width_p:0] 	data_in_S_2_w;
   wire [width_p:0] 	data_in_S_3_w;
   wire [width_p+1:0] 	sum_S_2_3_w;
   reg  [width_p+1:0]   sum_K_2_3_reg;   

   wire [width_p:0] 	data_in_S_4_w;
   wire [width_p:0] 	data_in_S_5_w;
   wire [width_p+1:0] 	sum_S_4_5_w;
   reg  [width_p+1:0]   sum_K_4_5_reg; 

   wire [width_p:0] 	data_in_S_6_w;
   wire [width_p:0] 	data_in_S_7_w;
   wire [width_p+1:0] 	sum_S_6_7_w;
   reg  [width_p+1:0]   sum_K_6_7_reg; 

   // ------------ third row of adders ------------ 

   wire [width_p+1:0] 	data_in_K_0_w; 
   wire [width_p+1:0] 	data_in_K_1_w;
   wire [width_p+2:0] 	sum_K_0_1_w;
   reg  [width_p+2:0]   sum_H_0_1_reg;

   wire [width_p+1:0] 	data_in_K_2_w; 
   wire [width_p+1:0] 	data_in_K_3_w;
   wire [width_p+2:0] 	sum_K_2_3_w;
   reg  [width_p+2:0]   sum_H_2_3_reg;
   
   // ------------ fourth row of adders ------------ 
   
   wire [width_p+2:0] 	data_in_H_0_w; 
   wire [width_p+2:0] 	data_in_H_1_w;
   wire [width_p+3:0] 	sum_H_0_1_w;
   reg  [width_p+3:0]   sum_16_reg;

   // ------------ Inst. of the adders of the first row ------------  
   
   	
	sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_0_1 
	(
        .data_in_A_i(data_in_0_w),
        .data_in_B_i(data_in_1_w),
        .Sum_o(sum_0_1_w)
		
    );
	
    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_2_3 
	(
        .data_in_A_i(data_in_2_w),
        .data_in_B_i(data_in_3_w),
        .Sum_o(sum_2_3_w)
		
    );	
  
    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_4_5 
	(
        .data_in_A_i(data_in_4_w),
        .data_in_B_i(data_in_5_w),
        .Sum_o(sum_4_5_w)
		
    ); 

    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_6_7 
	(
        .data_in_A_i(data_in_6_w),
        .data_in_B_i(data_in_7_w),
        .Sum_o(sum_6_7_w)
		
    );

    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_8_9 
	(
        .data_in_A_i(data_in_8_w),
        .data_in_B_i(data_in_9_w),
        .Sum_o(sum_8_9_w)
		
    );		

    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_10_11 
	(
        .data_in_A_i(data_in_10_w),
        .data_in_B_i(data_in_11_w),
        .Sum_o(sum_10_11_w)
		
    );

    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_12_13 
	(
        .data_in_A_i(data_in_12_w),
        .data_in_B_i(data_in_13_w),
        .Sum_o(sum_12_13_w)
		
    );

    sum_2_samples #(
	
		.width_p(width_p)
		
	) sum_sample_14_15 
	(
        .data_in_A_i(data_in_14_w),
        .data_in_B_i(data_in_15_w),
        .Sum_o(sum_14_15_w)
		
    );			

   // ------- Inst of second adders row ------- //  

    sum_2_samples #(
	
		.width_p(width_p+1)
		
	) sum_sample_S_0_1	
	(
        .data_in_A_i(data_in_S_0_w),
        .data_in_B_i(data_in_S_1_w),
        .Sum_o(sum_S_0_1_w)
		
    );

    sum_2_samples #(
	
		.width_p(width_p+1)
		
	) sum_sample_S_2_3	
	(
        .data_in_A_i(data_in_S_2_w),
        .data_in_B_i(data_in_S_3_w),
        .Sum_o(sum_S_2_3_w)
		
    );

    sum_2_samples #(
	
		.width_p(width_p+1)
		
	) sum_sample_S_4_5	
	(
        .data_in_A_i(data_in_S_4_w),
        .data_in_B_i(data_in_S_5_w),
        .Sum_o(sum_S_4_5_w)
		
    );

    sum_2_samples #(
	
		.width_p(width_p+1)
		
	) sum_sample_S_6_7	
	(
        .data_in_A_i(data_in_S_6_w),
        .data_in_B_i(data_in_S_7_w),
        .Sum_o(sum_S_6_7_w)
		
    );

   // ------- Inst of third adders row ------- //  
   
    sum_2_samples #(
	
		.width_p(width_p+2)
		
	) sum_sample_K_0_1	
	(
        .data_in_A_i(data_in_K_0_w),
        .data_in_B_i(data_in_K_1_w),
        .Sum_o(sum_K_0_1_w)
		
    );   
   
    sum_2_samples #(
	
		.width_p(width_p+2)
		
	) sum_sample_K_2_3	
	(
        .data_in_A_i(data_in_K_2_w),
        .data_in_B_i(data_in_K_3_w),
        .Sum_o(sum_K_2_3_w)
		
    );  

   // ------- Inst of 4th adders row ------- //  

    sum_2_samples #(
	
		.width_p(width_p+3)
		
	) sum_sample_H_0_1	
	(
        .data_in_A_i(data_in_H_0_w),
        .data_in_B_i(data_in_H_1_w),
        .Sum_o(sum_H_0_1_w)
		
    ); 

   // --------------------------- Load Stage --------------------------- //	
   
   assign VRS_full_w = (write_ptr_reg == block_sample_number_reg); 								// when write_ptr = block_sample_number => VRS_full = 1, when not VRS_full = 0 
   assign ready_to_load_o = VRS_full_w ? 1'b0 : ready_to_load; 									
 

   always @(posedge clk_i) 
	begin
		if(rst_i) begin
			block_sample_number_reg   <= 1; 
			block_sample_number_2_reg <= 0; 
			ready_to_load <= 0; 
			
		end else if(sample_number_i == 4 || sample_number_i == 8 || sample_number_i == 16) begin 
			block_sample_number_reg <= sample_number_i;
			ready_to_load <= 1;
				
		end else if(sample_number_i == 32 || sample_number_i == 64) begin 
			block_sample_number_reg   <= 6'h10;
			block_sample_number_2_reg <= sample_number_i; 
			ready_to_load <= 1;
			
		end else begin 
			block_sample_number_reg   <= block_sample_number_reg; 
			block_sample_number_2_reg <= block_sample_number_2_reg; 
			ready_to_load <= 0;
			
		end	
	end 
 
	always @(posedge clk_i) begin
		if(rst_i) begin 
			VRS_reg        <= {(width_p * samples_n_p){1'b0}};
			write_ptr_reg  <= 5'b00000;
			repeat_load    <= 2'b00; 
			
		end else if (data_in_valid_i && !VRS_full_w) begin 
			
			VRS_reg[(write_ptr_reg+0)*width_p +: width_p] <= sample_0_i; // VRS_reg[(write_ptr_reg*10)+9 : (write_ptr_reg*10)]
			VRS_reg[(write_ptr_reg+1)*width_p +: width_p] <= sample_1_i;
			VRS_reg[(write_ptr_reg+2)*width_p +: width_p] <= sample_2_i;
			VRS_reg[(write_ptr_reg+3)*width_p +: width_p] <= sample_3_i;

			write_ptr_reg <= write_ptr_reg + 4;
			
		end else if(block_sample_number_2_reg == 32 && VRS_full_w && !repeat_load) begin  
			write_ptr_reg <= 5'b00000;
			repeat_load   <= 2'b01;     

		end else if(block_sample_number_2_reg == 64 && VRS_full_w && repeat_load < 3) begin  
			write_ptr_reg <= 5'b00000;
			repeat_load   <= repeat_load + 1;          
		end    
	end

   // -------------- Connection to First Row of Adders  -------------- //

	// if VRS_reg is full, it assigns the values for the sum, if not, the wires are kept in 0
	// VRS_full is used as a flag to start the sum

   assign data_in_0_w  = VRS_full_w ? VRS_reg[9:0]     : 10'b0000000000; 
   assign data_in_1_w  = VRS_full_w ? VRS_reg[19:10]   : 10'b0000000000; 
   assign data_in_2_w  = VRS_full_w ? VRS_reg[29:20]   : 10'b0000000000; 
   assign data_in_3_w  = VRS_full_w ? VRS_reg[39:30]   : 10'b0000000000; 
   assign data_in_4_w  = VRS_full_w ? VRS_reg[49:40]   : 10'b0000000000; 
   assign data_in_5_w  = VRS_full_w ? VRS_reg[59:50]   : 10'b0000000000; 
   assign data_in_6_w  = VRS_full_w ? VRS_reg[69:60]   : 10'b0000000000; 
   assign data_in_7_w  = VRS_full_w ? VRS_reg[79:70]   : 10'b0000000000; 
   assign data_in_8_w  = VRS_full_w ? VRS_reg[89:80]   : 10'b0000000000; 
   assign data_in_9_w  = VRS_full_w ? VRS_reg[99:90]   : 10'b0000000000; 
   assign data_in_10_w = VRS_full_w ? VRS_reg[109:100] : 10'b0000000000; 
   assign data_in_11_w = VRS_full_w ? VRS_reg[119:110] : 10'b0000000000; 
   assign data_in_12_w = VRS_full_w ? VRS_reg[129:120] : 10'b0000000000; 
   assign data_in_13_w = VRS_full_w ? VRS_reg[139:130] : 10'b0000000000;   
   assign data_in_14_w = VRS_full_w ? VRS_reg[149:140] : 10'b0000000000;
   assign data_in_15_w = VRS_full_w ? VRS_reg[159:150] : 10'b0000000000;   
   
   // --------------------------- S-Registers Stage --------------------------- //	
   
   always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sum_0_1_reg   <= 0;
			sum_2_3_reg   <= 0;
			sum_4_5_reg   <= 0;
			sum_6_7_reg   <= 0;
			sum_8_9_reg   <= 0; 
			sum_10_11_reg <= 0; 
			sum_12_13_reg <= 0; 
			sum_14_15_reg <= 0; 
			
		end else begin  		
			sum_0_1_reg   <= sum_0_1_w;
			sum_2_3_reg   <= sum_2_3_w;
			sum_4_5_reg   <= sum_4_5_w;
			sum_6_7_reg   <= sum_6_7_w;
			sum_8_9_reg   <= sum_8_9_w; 
			sum_10_11_reg <= sum_10_11_w; 
			sum_12_13_reg <= sum_12_13_w; 
			sum_14_15_reg <= sum_14_15_w;
		end
		
	end 	

   // --------------------------- K-Registers Stage --------------------------- //	

	assign data_in_S_0_w = sum_0_1_reg;
	assign data_in_S_1_w = sum_2_3_reg;	
	assign data_in_S_2_w = sum_4_5_reg;
	assign data_in_S_3_w = sum_6_7_reg;
	assign data_in_S_4_w = sum_8_9_reg;
	assign data_in_S_5_w = sum_10_11_reg;
	assign data_in_S_6_w = sum_12_13_reg;
	assign data_in_S_7_w = sum_14_15_reg;

   always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sum_K_0_1_reg  <= 0;
			sum_K_2_3_reg  <= 0;	
			sum_K_4_5_reg  <= 0;
			sum_K_6_7_reg  <= 0;
			ready_4_reg    <= 0;
			
		end else if(block_sample_number_reg == 4) begin 			
			sum_K_0_1_reg  <= sum_S_0_1_w;
			sum_K_2_3_reg  <= sum_S_2_3_w;	
			sum_K_4_5_reg  <= sum_S_4_5_w;
			sum_K_6_7_reg  <= sum_S_6_7_w;
			if (sum_K_0_1_reg != 0) begin 
				ready_4_reg    <= 1;
				sum_K_0_1_reg  <= sum_K_0_1_reg;
			end 
			
		end else if (block_sample_number_reg == 8 || block_sample_number_reg == 16) begin 			
			sum_K_0_1_reg  <= sum_S_0_1_w;
			sum_K_2_3_reg  <= sum_S_2_3_w;	
			sum_K_4_5_reg  <= sum_S_4_5_w;
			sum_K_6_7_reg  <= sum_S_6_7_w;
			ready_4_reg	   <= 0;
			
		end else begin
			sum_K_0_1_reg  <= 0;
			sum_K_2_3_reg  <= 0;	
			sum_K_4_5_reg  <= 0;
			sum_K_6_7_reg  <= 0;
			ready_4_reg    <= 0;
		end
	end 

   // --------------------------- H-Registers Stage --------------------------- //	

	assign data_in_K_0_w = sum_K_0_1_reg;
	assign data_in_K_1_w = sum_K_2_3_reg;	
	assign data_in_K_2_w = sum_K_4_5_reg;
	assign data_in_K_3_w = sum_K_6_7_reg;

   always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sum_H_0_1_reg <= 0;
			sum_H_2_3_reg <= 0; 
			ready_8_reg   <= 0; 
			
		end else if(block_sample_number_reg == 8) begin 
			sum_H_0_1_reg  <= sum_K_0_1_w;
			sum_H_2_3_reg  <= sum_K_2_3_w;

			if (sum_H_0_1_reg != 0) begin 
				ready_8_reg    <= 1;
				sum_H_0_1_reg  <= sum_H_0_1_reg;
			end
 			
		end else if (block_sample_number_reg == 16) begin 
			sum_H_0_1_reg  <= sum_K_0_1_w;
			sum_H_2_3_reg  <= sum_K_2_3_w;
			ready_8_reg    <= 0;
			
		end else begin
			sum_H_0_1_reg  <= 0;
			sum_H_2_3_reg  <= 0;
			ready_8_reg    <= 0;			
		end	
	end 

   // --------------------------- Sum of 16 Stage and Acc Stage --------------------------- //		

	assign data_in_H_0_w = sum_H_0_1_reg;
	assign data_in_H_1_w = sum_H_2_3_reg;	   

   always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sum_16_reg 	 	<= 0; 
			ready_16_reg 	<= 0;
			ready_32_reg 	<= 0;			
			ready_2_Acc_reg <= 0;
			ready_64_reg 	<= 0;
			repeat_counter 	<= 0; 

		end else if(block_sample_number_reg == 16 && block_sample_number_2_reg != 32 && block_sample_number_2_reg != 64) begin 
			sum_16_reg <= sum_H_0_1_w;
			
			if (sum_16_reg != 0) begin 
				ready_16_reg <= 1;
			end			

		end else if(block_sample_number_reg == 16 && (block_sample_number_2_reg == 32 || block_sample_number_2_reg == 64)) begin 
			sum_16_reg <= sum_H_0_1_w; 
			ready_16_reg <= 0;

			if(sum_16_reg != 0 && (!ready_2_Acc_reg)) begin 
				ready_2_Acc_reg <= 1;
				Acc_reg <= sum_16_reg;
			end	

			if(block_sample_number_2_reg == 32 && ready_2_Acc_reg) begin 
				
				if(repeat_1_clk < 16) begin 
					repeat_1_clk <= repeat_1_clk + 1;
				end else if(repeat_1_clk == 16)begin 
					Acc_reg <= Acc_reg + sum_16_reg;
					ready_32_reg <= 1; 
					repeat_1_clk <= repeat_1_clk + 1;
				end else begin 
					Acc_reg <= Acc_reg;
				end
			end				

			if(block_sample_number_2_reg == 64 && ready_2_Acc_reg) begin 
				if(repeat_counter < 51) begin 
					if(repeat_2_clk < 16) begin 
						repeat_2_clk <= repeat_2_clk + 1;
					end else if(repeat_2_clk == 16)begin 
						Acc_reg <= Acc_reg + sum_16_reg;
						repeat_2_clk <= repeat_2_clk + 1;
					end else begin 
						Acc_reg <= Acc_reg;
						repeat_2_clk <= 1; 
					end
					repeat_counter <= repeat_counter + 1; 
				
				end else begin 
					ready_64_reg <= 1; 
				end
			end		
					
		end else begin 
			sum_16_reg 	 <= 0; 
			ready_16_reg <= 0;
			ready_32_reg <= 0;	
			ready_64_reg <= 0; 	
			
		end 
	end
 
   // --------------------------- Sum of Acc --------------------------- //
 

assign DC_Sum_o = ready_4_reg  ? sum_K_0_1_reg :
                  ready_8_reg  ? sum_H_0_1_reg :
				  ready_16_reg ? sum_16_reg    :
				  ready_32_reg ? Acc_reg	   :
				  ready_64_reg ? Acc_reg	   :
                  20'b00000000000000000000;
				  
assign data_available_o = (ready_4_reg || ready_8_reg || ready_16_reg || ready_32_reg || ready_64_reg) ? 1'b1 : 1'b0;

		
endmodule	

	