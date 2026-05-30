
// Output pipeline 
// First  Stage: Memory load + Transform to signed fixed point
// Second Stage: Subtraction (AC Value)
// Third  Stage: Multiply by alpha
// Fourth Stage: Sum DC Chroma value
//  

module output_pipeline  
  #(
  
   parameter width_p = 10 			
   
  )
  (
    input wire clk_i,
	input wire rst_i,  

	input wire [width_p-1:0] sample_i,
	
	input wire [6:0] address_row_i,
	input wire [6:0] address_column_i,
	
	input wire DC_Chr_ready_i,
	input wire signed [width_p+1:0] DC_Intra_Chr_i, 		// check data width and add data sign in DC Chroma block 
	
	input wire avg_en_i,									// connected to mem_ready_to_be_read_i; 
	input wire [9:0] avg_i,
	
	// alpha signals
	input wire alpha_sign_i, 
	input wire [4:0] alpha_index_i,
	
	input wire pipe_en_i, 
	input wire mem_read_finish_i, 
	
	input wire CFL_final_ready_i,

	output wire CFL_final_ready_o,
	
	output wire luma_memory_rst_o,
	
	output wire [6:0] address_row_o,
	output wire [6:0] address_column_o,
	
	output wire [width_p+1:0] CFL_final_o 
   
   );
   
	reg [6:0] address_row_first_reg 	= 0;
	reg [6:0] address_column_first_reg 	= 0;
	reg [6:0] address_row_second_reg	= 0; 	
	reg [6:0] address_column_second_reg	= 0;
	reg [6:0] address_row_third_reg		= 0; 	
	reg [6:0] address_column_third_reg	= 0;
	reg [6:0] address_row_fourth_reg	= 0; 	
	reg [6:0] address_column_fourth_reg	= 0;
	
	reg CFL_final_ready_first_reg 	= 0; 
	reg CFL_final_ready_second_reg 	= 0; 	
	reg CFL_final_ready_third_reg	= 0; 
	reg CFL_final_ready_fourth_reg	= 0; 	
	
	reg signed [width_p+2:0] AC_value_reg;	
	reg signed [width_p+2:0] sample_input_reg;
	reg signed [width_p+2:0] scaled_sample; 
	reg signed [width_p+2:0] CFL_final_reg; 	
	
	reg [9:0] avg_reg   = 0;  
	reg [5:0] alpha_index_reg = 0;
	reg alpha_sign_reg  = 0;
	
	reg signed [width_p+1:0] DC_Intra_Chr_reg    = 0; 
	reg signed [width_p+1:0] DC_Intra_Chr_first  = 0; 	
	reg signed [width_p+1:0] DC_Intra_Chr_second = 0; 	
	reg signed [width_p+1:0] DC_Intra_Chr_third  = 0; 
	reg signed [width_p+1:0] DC_Intra_Chr_fourth = 0;
	
	reg [9:0] avg_reg_in = 0; 
	reg [9:0] avg_first	 = 0; 
	
	reg 	 count_en    = 0;
	reg 	 pipe_en_reg = 0;
	reg[2:0] count_pipe  = 0; 
	
	reg signed [width_p+2:0] CFL_0_reg;	  
	reg signed [width_p+2:0] CFL_1_pos_reg;
	reg signed [width_p+2:0] CFL_1_neg_reg; 
	reg signed [width_p+2:0] CFL_2_pos_reg; 
	reg signed [width_p+2:0] CFL_2_neg_reg; 
	reg signed [width_p+2:0] CFL_3_pos_reg; 
	reg signed [width_p+2:0] CFL_3_neg_reg; 
	reg signed [width_p+2:0] CFL_4_pos_reg; 
	reg signed [width_p+2:0] CFL_4_neg_reg; 
	reg signed [width_p+2:0] CFL_5_pos_reg;
	reg signed [width_p+2:0] CFL_5_neg_reg;
	reg signed [width_p+2:0] CFL_6_pos_reg; 
	reg signed [width_p+2:0] CFL_6_neg_reg; 
	reg signed [width_p+2:0] CFL_7_pos_reg; 
	reg signed [width_p+2:0] CFL_7_neg_reg; 
	reg signed [width_p+2:0] CFL_8_pos_reg;
	reg signed [width_p+2:0] CFL_8_neg_reg;
	reg signed [width_p+2:0] CFL_9_pos_reg; 
	reg signed [width_p+2:0] CFL_9_neg_reg; 
	reg signed [width_p+2:0] CFL_10_pos_reg;
	reg signed [width_p+2:0] CFL_10_neg_reg;
	reg signed [width_p+2:0] CFL_11_pos_reg;
	reg signed [width_p+2:0] CFL_11_neg_reg;
	reg signed [width_p+2:0] CFL_12_pos_reg;
	reg signed [width_p+2:0] CFL_12_neg_reg;
	reg signed [width_p+2:0] CFL_13_pos_reg;
	reg signed [width_p+2:0] CFL_13_neg_reg;
	reg signed [width_p+2:0] CFL_14_pos_reg;
	reg signed [width_p+2:0] CFL_14_neg_reg;
	reg signed [width_p+2:0] CFL_15_pos_reg;
	reg signed [width_p+2:0] CFL_15_neg_reg;
	reg signed [width_p+2:0] CFL_16_pos_reg;
	reg signed [width_p+2:0] CFL_16_neg_reg;
	

	// --------- wires of alpha processing ---------- //
	
	// index = 0 	
	wire alpha_sign_0 = 0;
	wire [4:0] alpha_index_0 = 0; 
	wire signed [width_p+2:0] AC_value_wire;	
	wire signed [width_p+2:0] CFL_0;	
	wire pipe_en; 

	assign alpha_sign_0  = 0;
	assign alpha_index_0 = 0; 
	
	reg luma_memory_rst = 0; 
	reg ready_sync_1 = 0;
	reg ready_sync_2 = 0;
	reg ready_sync_d = 0;
	
	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_0
	(
		.alpha_sign(alpha_sign_0),
		.alpha_index(alpha_index_0),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_0)
    );	

	// --------------- index = 1 --------------- //
	
	wire [4:0] alpha_index_1 = 1; 
	wire alpha_sign_1_pos  = 0;
	wire alpha_sign_1_neg  = 1;

	assign alpha_index_1 = 1; 
	assign alpha_sign_1_pos  = 0;
	assign alpha_sign_1_neg  = 1;
	
	wire signed [width_p+2:0] CFL_1_pos;
	wire signed [width_p+2:0] CFL_1_neg;

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_1_pos 
	(
		.alpha_sign(alpha_sign_1_pos),
		.alpha_index(alpha_index_1),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_1_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_1_neg 
	(
		.alpha_sign(alpha_sign_1_neg),
		.alpha_index(alpha_index_1),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_1_neg)
    );	
	
	// --------------- index = 2 --------------- //	

	wire [4:0] alpha_index_2 = 2; 
	wire alpha_sign_2_pos  = 0;
	wire alpha_sign_2_neg  = 1;

	assign alpha_index_2 = 2; 
	assign alpha_sign_2_pos  = 0;
	assign alpha_sign_2_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_2_pos;
	wire signed [width_p+2:0] CFL_2_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_2_pos 
	(
		.alpha_sign(alpha_sign_2_pos),
		.alpha_index(alpha_index_2),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_2_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_2_neg 
	(
		.alpha_sign(alpha_sign_2_neg),
		.alpha_index(alpha_index_2),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_2_neg)
    );		
	
	// --------------- index = 3 --------------- //	

	wire [4:0] alpha_index_3 = 3; 
	wire alpha_sign_3_pos  = 0;
	wire alpha_sign_3_neg  = 1;

	assign alpha_index_3 = 3; 
	assign alpha_sign_3_pos  = 0;
	assign alpha_sign_3_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_3_pos;
	wire signed [width_p+2:0] CFL_3_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_3_pos 
	(
		.alpha_sign(alpha_sign_3_pos),
		.alpha_index(alpha_index_3),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_3_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_3_neg 
	(
		.alpha_sign(alpha_sign_3_neg),
		.alpha_index(alpha_index_3),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_3_neg)
    );			

	// --------------- index = 4 --------------- //	

	wire [4:0] alpha_index_4 = 4; 
	wire alpha_sign_4_pos  = 0;
	wire alpha_sign_4_neg  = 1;

	assign alpha_index_4 = 4; 
	assign alpha_sign_4_pos  = 0;
	assign alpha_sign_4_neg  = 1;

	wire signed [width_p+2:0] CFL_4_pos;
	wire signed [width_p+2:0] CFL_4_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_4_pos 
	(
		.alpha_sign(alpha_sign_4_pos),
		.alpha_index(alpha_index_4),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_4_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_4_neg 
	(
		.alpha_sign(alpha_sign_4_neg),
		.alpha_index(alpha_index_4),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_4_neg)
    );		

	// --------------- index = 5 --------------- //	

	wire [4:0] alpha_index_5 = 5; 
	wire alpha_sign_5_pos  = 0;
	wire alpha_sign_5_neg  = 1;
	
	assign alpha_index_5 = 5; 
	assign alpha_sign_5_pos  = 0;
	assign alpha_sign_5_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_5_pos;
	wire signed [width_p+2:0] CFL_5_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_5_pos 
	(
		.alpha_sign(alpha_sign_5_pos),
		.alpha_index(alpha_index_5),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_5_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_5_neg 
	(
		.alpha_sign(alpha_sign_5_neg),
		.alpha_index(alpha_index_5),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_5_neg)
    );	

	// --------------- index = 6 --------------- //	

	wire [4:0] alpha_index_6 = 6; 
	wire alpha_sign_6_pos  = 0;
	wire alpha_sign_6_neg  = 1;
	
	assign alpha_index_6 = 6; 
	assign alpha_sign_6_pos  = 0;
	assign alpha_sign_6_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_6_pos;
	wire signed [width_p+2:0] CFL_6_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_6_pos 
	(
		.alpha_sign(alpha_sign_6_pos),
		.alpha_index(alpha_index_6),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_6_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_6_neg 
	(
		.alpha_sign(alpha_sign_6_neg),
		.alpha_index(alpha_index_6),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_6_neg)
    );	

	// --------------- index = 7 --------------- //	

	wire [4:0] alpha_index_7 = 7; 
	wire alpha_sign_7_pos  = 0;
	wire alpha_sign_7_neg  = 1;
	
	assign alpha_index_7 = 7; 
	assign alpha_sign_7_pos  = 0;
	assign alpha_sign_7_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_7_pos;
	wire signed [width_p+2:0] CFL_7_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_7_pos 
	(
		.alpha_sign(alpha_sign_7_pos),
		.alpha_index(alpha_index_7),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_7_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_7_neg 
	(
		.alpha_sign(alpha_sign_7_neg),
		.alpha_index(alpha_index_7),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_7_neg)
    );	

	// --------------- index = 8 --------------- //	

	wire [4:0] alpha_index_8 = 8; 
	wire alpha_sign_8_pos  = 0;
	wire alpha_sign_8_neg  = 1;

	assign alpha_index_8 = 8; 
	assign alpha_sign_8_pos  = 0;
	assign alpha_sign_8_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_8_pos;
	wire signed [width_p+2:0] CFL_8_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_8_pos 
	(
		.alpha_sign(alpha_sign_8_pos),
		.alpha_index(alpha_index_8),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_8_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_8_neg 
	(
		.alpha_sign(alpha_sign_8_neg),
		.alpha_index(alpha_index_8),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_8_neg)
    );	

	// --------------- index = 9 --------------- //	

	wire [4:0] alpha_index_9 = 9; 
	wire alpha_sign_9_pos  = 0;
	wire alpha_sign_9_neg  = 1;

	assign alpha_index_9 = 9; 
	assign alpha_sign_9_pos  = 0;
	assign alpha_sign_9_neg  = 1;

	wire signed [width_p+2:0] CFL_9_pos;
	wire signed [width_p+2:0] CFL_9_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_9_pos 
	(
		.alpha_sign(alpha_sign_9_pos),
		.alpha_index(alpha_index_9),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_9_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_9_neg 
	(
		.alpha_sign(alpha_sign_9_neg),
		.alpha_index(alpha_index_9),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_9_neg)
    );

	// --------------- index = 10 --------------- //	

	wire [4:0] alpha_index_10 = 10; 
	wire alpha_sign_10_pos  = 0;
	wire alpha_sign_10_neg  = 1;

	assign alpha_index_10 = 10; 
	assign alpha_sign_10_pos  = 0;
	assign alpha_sign_10_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_10_pos;
	wire signed [width_p+2:0] CFL_10_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_10_pos 
	(
		.alpha_sign(alpha_sign_10_pos),
		.alpha_index(alpha_index_10),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_10_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_10_neg 
	(
		.alpha_sign(alpha_sign_10_neg),
		.alpha_index(alpha_index_10),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_10_neg)
    );

	// --------------- index = 11 --------------- //	

	wire [4:0] alpha_index_11 = 11; 
	wire alpha_sign_11_pos  = 0;
	wire alpha_sign_11_neg  = 1;

	assign alpha_index_11 	  = 11; 
	assign alpha_sign_11_pos  = 0;
	assign alpha_sign_11_neg  = 1;

	wire signed [width_p+2:0] CFL_11_pos;
	wire signed [width_p+2:0] CFL_11_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_11_pos 
	(
		.alpha_sign(alpha_sign_11_pos),
		.alpha_index(alpha_index_11),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_11_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_11_neg 
	(
		.alpha_sign(alpha_sign_11_neg),
		.alpha_index(alpha_index_11),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_11_neg)
    );

	// --------------- index = 12 --------------- //	

	wire [4:0] alpha_index_12 = 12; 
	wire alpha_sign_12_pos  = 0;
	wire alpha_sign_12_neg  = 1;
	
	assign alpha_index_12 	  = 12; 
	assign alpha_sign_12_pos  = 0;
	assign alpha_sign_12_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_12_pos;
	wire signed [width_p+2:0] CFL_12_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_12_pos 
	(
		.alpha_sign(alpha_sign_12_pos),
		.alpha_index(alpha_index_12),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_12_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_12_neg 
	(
		.alpha_sign(alpha_sign_12_neg),
		.alpha_index(alpha_index_12),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_12_neg)
    );

	// --------------- index = 13 --------------- //	

	wire [4:0] alpha_index_13 = 13; 
	wire alpha_sign_13_pos  = 0;
	wire alpha_sign_13_neg  = 1;

	assign alpha_index_13 = 13; 
	assign alpha_sign_13_pos  = 0;
	assign alpha_sign_13_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_13_pos;
	wire signed [width_p+2:0] CFL_13_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_13_pos 
	(
		.alpha_sign(alpha_sign_13_pos),
		.alpha_index(alpha_index_13),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_13_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_13_neg 
	(
		.alpha_sign(alpha_sign_13_neg),
		.alpha_index(alpha_index_13),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_13_neg)
    );

	// --------------- index = 14 --------------- //	

	wire [4:0] alpha_index_14 = 14; 
	wire alpha_sign_14_pos  = 0;
	wire alpha_sign_14_neg  = 1;

	assign alpha_index_14     = 14; 
	assign alpha_sign_14_pos  = 0;
	assign alpha_sign_14_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_14_pos;
	wire signed [width_p+2:0] CFL_14_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_14_pos 
	(
		.alpha_sign(alpha_sign_14_pos),
		.alpha_index(alpha_index_14),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_14_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_14_neg 
	(
		.alpha_sign(alpha_sign_14_neg),
		.alpha_index(alpha_index_14),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_14_neg)
    );

	// --------------- index = 15 --------------- //	

	wire [4:0] alpha_index_15 = 15; 
	wire alpha_sign_15_pos  = 0;
	wire alpha_sign_15_neg  = 1;

	assign alpha_index_15     = 15; 
	assign alpha_sign_15_pos  = 0;
	assign alpha_sign_15_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_15_pos;
	wire signed [width_p+2:0] CFL_15_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_15_pos 
	(
		.alpha_sign(alpha_sign_15_pos),
		.alpha_index(alpha_index_15),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_15_neg 
	(
		.alpha_sign(alpha_sign_15_neg),
		.alpha_index(alpha_index_15),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_15_neg)
    );

	// --------------- index = 16 --------------- //	

	wire [4:0] alpha_index_16 = 16; 
	wire alpha_sign_16_pos  = 0;
	wire alpha_sign_16_neg  = 1;
	
	assign alpha_index_16 = 16;
	assign alpha_sign_16_pos = 0;
	assign alpha_sign_16_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_16_pos;
	wire signed [width_p+2:0] CFL_16_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_16_pos 
	(
		.alpha_sign(alpha_sign_16_pos),
		.alpha_index(alpha_index_16),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_16_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_16_neg 
	(
		.alpha_sign(alpha_sign_16_neg),
		.alpha_index(alpha_index_16),
		.AC_value(AC_value_wire),
		.CFL_o(CFL_16_neg)
    );

 	always @(posedge clk_i) begin
		if(avg_en_i) begin 
			avg_reg_in <= avg_i;  
		end 
	end

 	always @(posedge clk_i) begin
		if(DC_Chr_ready_i && (!mem_read_finish_i)) begin 
			DC_Intra_Chr_reg <= DC_Intra_Chr_i;  
		end else begin 
			DC_Intra_Chr_reg <= 0; 
		end 
	end
	
   // Pipeline First Stage - Memory load + Transform to signed
   // Evaluate if we can remove the first stage of the pipeline 
	always @(posedge clk_i) begin
		if(rst_i) begin 
			address_row_first_reg    	<= 0; 
			address_column_first_reg 	<= 0; 
			sample_input_reg 		 	<= 0; 
			AC_value_reg			 	<= 0; 
			CFL_final_reg			 	<= 0; 
			count_en				 	<= 0;
			CFL_final_ready_first_reg 	<= 0;
			
		end else if(pipe_en_i) begin 						
			address_row_first_reg 	 	<= address_row_i;
			address_column_first_reg 	<= address_column_i;
			sample_input_reg 		 	<= sample_i; 
			DC_Intra_Chr_first		 	<= DC_Intra_Chr_reg;
			CFL_final_ready_first_reg 	<= CFL_final_ready_i;
			
			if(mem_read_finish_i) begin 
				count_en   <= 1; 
			end else begin 
				avg_first  <= avg_reg_in; 
			end
		end	
	end
	
	always @(posedge clk_i) begin
		if(count_en) begin 
			count_en  <= 0;
			avg_first <= 0;
		end 
	end 
 
	// Pipeline Second Stage - Subtraction (AC Value)
	always @(posedge clk_i) begin	
		AC_value_reg 				<= $signed(sample_input_reg) - $signed(avg_first);
		address_row_second_reg    	<= address_row_first_reg;
		address_column_second_reg 	<= address_column_first_reg;
		DC_Intra_Chr_second		  	<= DC_Intra_Chr_first;
		CFL_final_ready_second_reg	<= CFL_final_ready_first_reg; 
	end 
	
	assign AC_value_wire = AC_value_reg; 

 	// Pipeline Third Stage - Alpha Multipl	
	always @(posedge clk_i) begin
		address_row_third_reg	 	<= address_row_second_reg;
		address_column_third_reg 	<= address_column_second_reg;
		DC_Intra_Chr_third		 	<= DC_Intra_Chr_second; 
		CFL_final_ready_third_reg	<= CFL_final_ready_second_reg; 
		
		CFL_0_reg	   <= CFL_0;
		CFL_1_pos_reg  <= CFL_1_pos;
		CFL_1_neg_reg  <= CFL_1_neg;
		CFL_2_pos_reg  <= CFL_2_pos;
		CFL_2_neg_reg  <= CFL_2_neg;
		CFL_3_pos_reg  <= CFL_3_pos;
		CFL_3_neg_reg  <= CFL_3_neg;
		CFL_4_pos_reg  <= CFL_4_pos;
		CFL_4_neg_reg  <= CFL_4_neg;
		CFL_5_pos_reg  <= CFL_5_pos;
		CFL_5_neg_reg  <= CFL_5_neg;
		CFL_6_pos_reg  <= CFL_6_pos;
		CFL_6_neg_reg  <= CFL_6_neg;
		CFL_7_pos_reg  <= CFL_7_pos;
		CFL_7_neg_reg  <= CFL_7_neg;
		CFL_8_pos_reg  <= CFL_8_pos;
		CFL_8_neg_reg  <= CFL_8_neg;		
		CFL_9_pos_reg  <= CFL_9_pos;
		CFL_9_neg_reg  <= CFL_9_neg;			
		CFL_10_pos_reg <= CFL_10_pos;
		CFL_10_neg_reg <= CFL_10_neg;			
		CFL_11_pos_reg <= CFL_11_pos;
		CFL_11_neg_reg <= CFL_11_neg;
		CFL_12_pos_reg <= CFL_12_pos;
		CFL_12_neg_reg <= CFL_12_neg;
		CFL_13_pos_reg <= CFL_13_pos;
		CFL_13_neg_reg <= CFL_13_neg;
		CFL_14_pos_reg <= CFL_14_pos;
		CFL_14_neg_reg <= CFL_14_neg;
		CFL_15_pos_reg <= CFL_15_pos;
		CFL_15_neg_reg <= CFL_15_neg;
		CFL_16_pos_reg <= CFL_16_pos;
		CFL_16_neg_reg <= CFL_16_neg;
	end  

 	// Pipeline Fourth Stage - CFL_Final = CFL + DC_Chroma	
	always @(posedge clk_i) begin
		
		address_row_fourth_reg	  	<= address_row_third_reg;
		address_column_fourth_reg 	<= address_column_third_reg;
		CFL_final_ready_fourth_reg	<= CFL_final_ready_third_reg; 
		
			case (alpha_index_i)
			
				5'd0  : begin CFL_final_reg <= CFL_0 + DC_Intra_Chr_third; 
						end 
				
				5'd1  : begin 			
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_1_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_1_neg_reg + DC_Intra_Chr_third;
							end
						end 
					
				5'd2  :	begin 
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_2_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_2_neg_reg + DC_Intra_Chr_third;
							end 				
						end 
					
				5'd3  :	begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_3_pos_reg + DC_Intra_Chr_third; 
							end else begin
								CFL_final_reg <= CFL_3_neg_reg + DC_Intra_Chr_third;
							end 
						end
						
				5'd4  : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_4_pos_reg + DC_Intra_Chr_third; 
							end else begin
								CFL_final_reg <= CFL_4_neg_reg + DC_Intra_Chr_third;
							end
						end
					
				5'd5  : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_5_pos_reg + DC_Intra_Chr_third; 
							end else begin
								CFL_final_reg <= CFL_5_neg_reg + DC_Intra_Chr_third;
							end 
						end

				5'd6  : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_6_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_6_neg_reg + DC_Intra_Chr_third;
							end 
						end

				5'd7  : begin 
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_7_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_7_neg_reg + DC_Intra_Chr_third;
							end
						end 
						
				5'd8  : begin 
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_8_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_8_neg_reg + DC_Intra_Chr_third;
							end 	
						end 

				5'd9  :	begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_9_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_9_neg_reg + DC_Intra_Chr_third;
							end 
						end 
				
				5'd10 : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_10_pos_reg + DC_Intra_Chr_third; 
							end else begin
								CFL_final_reg <= CFL_10_neg_reg + DC_Intra_Chr_third;
							end 	
						end 

				5'd11 : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_11_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_11_neg_reg + DC_Intra_Chr_third;
							end 
						end
	
				5'd12 : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_12_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_12_neg_reg + DC_Intra_Chr_third;
							end 		
						end 
				
				5'd13 : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_13_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_13_neg_reg + DC_Intra_Chr_third;
							end
						end
				
				5'd14 : begin 
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_14_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_14_neg_reg + DC_Intra_Chr_third;
							end
						end 
				
				5'd15 : begin 
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_15_pos_reg + DC_Intra_Chr_third; 
							end else begin 
								CFL_final_reg <= CFL_15_neg_reg + DC_Intra_Chr_third;
							end
						end
						
				5'd16 : begin
							if(!alpha_sign_i) begin 
								CFL_final_reg <= CFL_16_pos_reg + DC_Intra_Chr_third; 
							end else begin
								CFL_final_reg <= CFL_16_neg_reg + DC_Intra_Chr_third;
							end
						end
						
				default: begin CFL_final_reg <= 0; end 

			endcase
	end 
	
	always @(posedge clk_i) begin
		ready_sync_1 <= CFL_final_ready_fourth_reg;
		ready_sync_2 <= ready_sync_1;
		ready_sync_d <= ready_sync_2;

		// Luma mem reset pulse gen
		if (ready_sync_d & ~ready_sync_2) begin 
			luma_memory_rst <= 1'b1;
		end else begin
			luma_memory_rst <= 1'b0;		
		end 
		
	end

	assign luma_memory_rst_o = luma_memory_rst;
	
	assign CFL_final_o 		 = (CFL_final_reg < 0)    ? 0    :
							   (CFL_final_reg > 1023) ? 1023 : 
							   CFL_final_reg;

	assign address_row_o     = address_row_fourth_reg;
	assign address_column_o  = address_column_fourth_reg;
	assign CFL_final_ready_o = CFL_final_ready_fourth_reg;

endmodule 