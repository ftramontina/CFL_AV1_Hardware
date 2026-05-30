
// DC intraprediction module 
// The ready_to_load signals are asserted when the sample_number of the block is registered, so the sample number of the block
// are the enable signals of the blocks 

module DC_intraprediction  
  #(
  
	parameter width_p 	    = 10, 			// The samples have 10 bits for High Definition Video
	parameter samples_n_p	= 16			// Number of samples of VRS for 16 block   
   
  )
  (
  
	input wire clk_i,
	input wire rst_i,
	
	input wire data_in_valid_left_i,
	input wire data_in_valid_top_i,
	
	input wire [6:0] sample_number_left_i, 
	input wire [6:0] sample_number_top_i,
	
	input wire [width_p-1:0] sample_left_0_i,
	input wire [width_p-1:0] sample_left_1_i,	
	input wire [width_p-1:0] sample_left_2_i,	
	input wire [width_p-1:0] sample_left_3_i,

	input wire [width_p-1:0] sample_top_0_i,
	input wire [width_p-1:0] sample_top_1_i,
	input wire [width_p-1:0] sample_top_2_i,
	input wire [width_p-1:0] sample_top_3_i,	
	
	input wire above,
	input wire left,
	
	output wire ready_to_load_left_o,	
	output wire ready_to_load_top_o,

	output wire ready_o,
	
	output wire signed [width_p+1:0] intrapred_data_out_o 
	  
   );
   
	wire data_available_left;
	wire data_available_top;
	
	reg ready_reg_left;
	reg ready_reg_top;
	reg ready_reg_left_top;
	
	reg rst_DC_sum_left; 
	reg rst_DC_sum_top;
	
	wire [19:0] DC_sum_left;
	wire [19:0] DC_sum_top; 
	
	reg signed [width_p+1:0] reg_DC_left; 
	reg signed [width_p+1:0] reg_DC_top; 
	reg signed [width_p+1:0] reg_DC_top_left; 
	
	reg [19:0] sum_left; 	
	reg [19:0] sum_top; 
	reg [23:0] sum_top_left; 
	
	reg div_en_left 	= 0;
	reg div_en_top  	= 0;
	reg div_en_top_left = 0;	
	
	wire [2:0] H_div; 
	wire [2:0] W_div; 
	wire [2:0] H_W_div_shift;
	wire [6:0] H_W_div;
	wire shift; 
	
	wire [7:0] H_W_sum_div_2; 
	wire [5:0] H_sum_div_2; 
	wire [5:0] W_sum_div_2; 

	reg [6:0] sample_number_left_reg;
	reg [6:0] sample_number_top_reg;
	
	reg [width_p+1:0] DC_1d_left_4_reg; 
	reg [width_p+1:0] DC_1d_left_8_reg;
	reg [width_p+1:0] DC_1d_left_16_reg;
	reg [width_p+1:0] DC_1d_left_32_reg;
	reg [width_p+1:0] DC_1d_left_64_reg;
	reg [width_p+1:0] DC_1d_top_4_reg;
	reg [width_p+1:0] DC_1d_top_8_reg;
	reg [width_p+1:0] DC_1d_top_16_reg;
	reg [width_p+1:0] DC_1d_top_32_reg;
	reg [width_p+1:0] DC_1d_top_64_reg;
	reg [width_p+1:0] DC_left_top_4_4_reg;
	reg [width_p+1:0] DC_left_top_8_8_reg;
	reg [width_p+1:0] DC_left_top_16_16_reg;
	reg [width_p+1:0] DC_left_top_32_32_reg;
	reg [width_p+1:0] DC_left_top_64_64_reg;
	reg [width_p+1:0] DC_left_top_4_8_reg;
	reg [width_p+1:0] DC_left_top_8_4_reg;
	reg [width_p+1:0] DC_left_top_4_16_reg;
	reg [width_p+1:0] DC_left_top_16_4_reg;
	reg [width_p+1:0] DC_left_top_8_16_reg;
	reg [width_p+1:0] DC_left_top_16_8_reg;
	reg [width_p+1:0] DC_left_top_8_32_reg;
	reg [width_p+1:0] DC_left_top_32_8_reg;
	reg [width_p+1:0] DC_left_top_16_32_reg;
	reg [width_p+1:0] DC_left_top_32_16_reg;
	reg [width_p+1:0] DC_left_top_16_64_reg;
	reg [width_p+1:0] DC_left_top_64_16_reg;
	reg [width_p+1:0] DC_left_top_32_64_reg;
	reg [width_p+1:0] DC_left_top_64_32_reg;
	
	reg mux_sel_en = 0; 

	DC_SUM_16 #(
	
		.width_p(width_p),
		.samples_n_p(samples_n_p)
		
	) DC_Sum_Left 
	(
        .clk_i(clk_i),
        .rst_i(rst_DC_sum_left), 
        .data_in_valid_i(data_in_valid_left_i),
		.sample_number_i(sample_number_left_i),
		.sample_0_i(sample_left_0_i),
		.sample_1_i(sample_left_1_i),
		.sample_2_i(sample_left_2_i),
		.sample_3_i(sample_left_3_i),
		.ready_to_load_o(ready_to_load_left_o),
		.data_available_o(data_available_left),
		.DC_Sum_o(DC_sum_left)
		
    );

	DC_SUM_16 #(
	
		.width_p(width_p),
		.samples_n_p(samples_n_p)
		
	) DC_Sum_Top 
	(
        .clk_i(clk_i),
        .rst_i(rst_DC_sum_top), 
        .data_in_valid_i(data_in_valid_top_i),
		.sample_number_i(sample_number_top_i),
		.sample_0_i(sample_top_0_i),
		.sample_1_i(sample_top_1_i),
		.sample_2_i(sample_top_2_i),
		.sample_3_i(sample_top_3_i),
		.ready_to_load_o(ready_to_load_top_o),
		.data_available_o(data_available_top),
		.DC_Sum_o(DC_sum_top)
		
    );
 
	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_left_4;
	wire [19:0] sum_1d_left_4;	
	wire [width_p+1:0] DC_1d_left_4;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_left_4_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_left_4),
	.sum_1d_i(sum_1d_left_4),
	.DC_1d_o(DC_1d_left_4)
		
    );
   
   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_left_8;
	wire [19:0] sum_1d_left_8;	
	wire [width_p+1:0] DC_1d_left_8;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_left_8_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_left_8),
	.sum_1d_i(sum_1d_left_8),
	.DC_1d_o(DC_1d_left_8)
		
    );
    
   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_left_16;
	wire [19:0] sum_1d_left_16;	
	wire [width_p+1:0] DC_1d_left_16;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_left_16_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_left_16),
	.sum_1d_i(sum_1d_left_16),
	.DC_1d_o(DC_1d_left_16)
		
    );

   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_left_32;
	wire [19:0] sum_1d_left_32;	
	wire [width_p+1:0] DC_1d_left_32;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_left_32_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_left_32),
	.sum_1d_i(sum_1d_left_32),
	.DC_1d_o(DC_1d_left_32)
		
    );

   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_left_64;
	wire [19:0] sum_1d_left_64;	
	wire [width_p+1:0] DC_1d_left_64;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_left_64_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_left_64),
	.sum_1d_i(sum_1d_left_64),
	.DC_1d_o(DC_1d_left_64)
		
    );

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------

	wire [6:0]  sample_number_1d_top_4;
	wire [19:0] sum_1d_top_4;	
	wire [width_p+1:0] DC_1d_top_4;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_top_4_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_top_4),
	.sum_1d_i(sum_1d_top_4),
	.DC_1d_o(DC_1d_top_4)
		
    );
   
   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_top_8;
	wire [19:0] sum_1d_top_8;	
	wire [width_p+1:0] DC_1d_top_8;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_top_8_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_top_8),
	.sum_1d_i(sum_1d_top_8),
	.DC_1d_o(DC_1d_top_8)
		
    );
    
   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_top_16;
	wire [19:0] sum_1d_top_16;	
	wire [width_p+1:0] DC_1d_top_16;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_top_16_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_top_16),
	.sum_1d_i(sum_1d_top_16),
	.DC_1d_o(DC_1d_top_16)
		
    );

   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_top_32;
	wire [19:0] sum_1d_top_32;	
	wire [width_p+1:0] DC_1d_top_32;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_top_32_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_top_32),
	.sum_1d_i(sum_1d_top_32),
	.DC_1d_o(DC_1d_top_32)
		
    );

   	// --------------------------------------------
	
	wire [6:0]  sample_number_1d_top_64;
	wire [19:0] sum_1d_top_64;	
	wire [width_p+1:0] DC_1d_top_64;
	
	DC_1d #(
	
		.width_p(width_p)
		
	) DC_1d_top_64_inst 
	(
	
	.sample_number_1d_i(sample_number_1d_top_64),
	.sum_1d_i(sum_1d_top_64),
	.DC_1d_o(DC_1d_top_64)
		
    );
	
   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------

	wire [6:0]  sample_number_left_4;
	wire [6:0]  sample_number_top_4;	
	wire [19:0] sum_left_top_4_4; 
	wire [width_p+1:0] DC_left_top_4_4;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_4_4_inst 
	(
	
	.sample_number_left_i(sample_number_left_4),
	.sample_number_top_i(sample_number_top_4),
	.sum_left_top(sum_left_top_4_4),
	.DC_left_top(DC_left_top_4_4)
		
    );

   	// --------------------------------------------

	wire [6:0]  sample_number_left_8;
	wire [6:0]  sample_number_top_8;	
	wire [19:0] sum_left_top_8_8; 
	wire [width_p+1:0] DC_left_top_8_8;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_8_8_inst 
	(
	
	.sample_number_left_i(sample_number_left_8),
	.sample_number_top_i(sample_number_top_8),
	.sum_left_top(sum_left_top_8_8),
	.DC_left_top(DC_left_top_8_8)
		
    );

   	// --------------------------------------------

	wire [6:0]  sample_number_left_16;
	wire [6:0]  sample_number_top_16;	
	wire [19:0] sum_left_top_16_16; 
	wire [width_p+1:0] DC_left_top_16_16;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_16_16_inst 
	(
	
	.sample_number_left_i(sample_number_left_16),
	.sample_number_top_i(sample_number_top_16),
	.sum_left_top(sum_left_top_16_16),
	.DC_left_top(DC_left_top_16_16)
		
    );

   	// --------------------------------------------

	wire [6:0]  sample_number_left_32;
	wire [6:0]  sample_number_top_32;	
	wire [19:0] sum_left_top_32_32; 
	wire [width_p+1:0] DC_left_top_32_32;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_32_32_inst 
	(
	
	.sample_number_left_i(sample_number_left_32),
	.sample_number_top_i(sample_number_top_32),
	.sum_left_top(sum_left_top_32_32),
	.DC_left_top(DC_left_top_32_32)
		
    );

   	// --------------------------------------------

	wire [6:0]  sample_number_left_64;
	wire [6:0]  sample_number_top_64;	
	wire [19:0] sum_left_top_64_64; 
	wire [width_p+1:0] DC_left_top_64_64;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_64_64_inst 
	(
	
	.sample_number_left_i(sample_number_left_64),
	.sample_number_top_i(sample_number_top_64),
	.sum_left_top(sum_left_top_64_64),
	.DC_left_top(DC_left_top_64_64)
		
    );
	
   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------	

	wire [6:0]  sample_number_left_0_4_w;
	wire [6:0]  sample_number_top_0_8_w;	
	wire [19:0] sum_left_top_4_8_w; 
	wire [width_p+1:0] DC_left_top_4_8_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_4_8_inst 
	(
	
	.sample_number_left_i(sample_number_left_0_4_w),
	.sample_number_top_i(sample_number_top_0_8_w),
	.sum_left_top(sum_left_top_4_8_w),
	.DC_left_top(DC_left_top_4_8_w)
		
    );

	wire [6:0]  sample_number_left_0_8_w;
	wire [6:0]  sample_number_top_0_4_w;	
	wire [19:0] sum_left_top_8_4_w; 
	wire [width_p+1:0] DC_left_top_8_4_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_8_4_inst 
	(
	
	.sample_number_left_i(sample_number_left_0_8_w),
	.sample_number_top_i(sample_number_top_0_4_w),
	.sum_left_top(sum_left_top_8_4_w),
	.DC_left_top(DC_left_top_8_4_w)
		
    );

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------

	wire [6:0]  sample_number_left_1_4_w;
	wire [6:0]  sample_number_top_1_16_w;	
	wire [19:0] sum_left_top_4_16_w;
	wire [width_p+1:0] DC_left_top_4_16_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_4_16_inst 
	(
	
	.sample_number_left_i(sample_number_left_1_4_w),
	.sample_number_top_i(sample_number_top_1_16_w),
	.sum_left_top(sum_left_top_4_16_w),
	.DC_left_top(DC_left_top_4_16_w)
		
    );

	wire [6:0]  sample_number_left_1_16_w;
	wire [6:0]  sample_number_top_1_4_w;	
	wire [19:0] sum_left_top_16_4_w;
	wire [width_p+1:0] DC_left_top_16_4_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_16_4_inst 
	(
	
	.sample_number_left_i(sample_number_left_1_16_w),
	.sample_number_top_i(sample_number_top_1_4_w),
	.sum_left_top(sum_left_top_16_4_w),
	.DC_left_top(DC_left_top_16_4_w)
		
    );

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------

	wire [6:0]  sample_number_left_2_8_w;
	wire [6:0]  sample_number_top_2_16_w;	
	wire [19:0] sum_left_top_8_16_w;
	wire [width_p+1:0] DC_left_top_8_16_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_8_16_inst 
	(
	
	.sample_number_left_i(sample_number_left_2_8_w),
	.sample_number_top_i(sample_number_top_2_16_w),
	.sum_left_top(sum_left_top_8_16_w),
	.DC_left_top(DC_left_top_8_16_w)
		
    );

	wire [6:0]  sample_number_left_2_16_w;
	wire [6:0]  sample_number_top_2_8_w;	
	wire [19:0] sum_left_top_16_8_w;
	wire [width_p+1:0] DC_left_top_16_8_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_16_8_inst 
	(
	
	.sample_number_left_i(sample_number_left_2_16_w),
	.sample_number_top_i(sample_number_top_2_8_w),
	.sum_left_top(sum_left_top_16_8_w),
	.DC_left_top(DC_left_top_16_8_w)
		
    );

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------

	wire [6:0]  sample_number_left_3_8_w;
	wire [6:0]  sample_number_top_3_32_w;	
	wire [19:0] sum_left_top_8_32_w;
	wire [width_p+1:0] DC_left_top_8_32_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_8_32_inst 
	(
	
	.sample_number_left_i(sample_number_left_3_8_w),
	.sample_number_top_i(sample_number_top_3_32_w),
	.sum_left_top(sum_left_top_8_32_w),
	.DC_left_top(DC_left_top_8_32_w)
		
    );

	wire [6:0]  sample_number_left_3_32_w;
	wire [6:0]  sample_number_top_3_8_w;	
	wire [19:0] sum_left_top_32_8_w;
	wire [width_p+1:0] DC_left_top_32_8_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_32_8_inst 
	(
	
	.sample_number_left_i(sample_number_left_3_32_w),
	.sample_number_top_i(sample_number_top_3_8_w),
	.sum_left_top(sum_left_top_32_8_w),
	.DC_left_top(DC_left_top_32_8_w)
		
    );

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------
	
	wire [6:0]  sample_number_left_4_16_w;
	wire [6:0]  sample_number_top_4_32_w;	
	wire [19:0] sum_left_top_16_32_w;
	wire [width_p+1:0] DC_left_top_16_32_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_16_32_inst 
	(
	
	.sample_number_left_i(sample_number_left_4_16_w),
	.sample_number_top_i(sample_number_top_4_32_w),
	.sum_left_top(sum_left_top_16_32_w),
	.DC_left_top(DC_left_top_16_32_w)
		
    );
	
	wire [6:0]  sample_number_left_4_32_w;
	wire [6:0]  sample_number_top_4_16_w;	
	wire [19:0] sum_left_top_32_16_w;
	wire [width_p+1:0] DC_left_top_32_16_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_32_16_inst 
	(
	
	.sample_number_left_i(sample_number_left_4_32_w),
	.sample_number_top_i(sample_number_top_4_16_w),
	.sum_left_top(sum_left_top_32_16_w),
	.DC_left_top(DC_left_top_32_16_w)
		
    );	

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------
	
	wire [6:0]  sample_number_left_5_16_w;
	wire [6:0]  sample_number_top_5_64_w;	
	wire [19:0] sum_left_top_16_64_w;
	wire [width_p+1:0] DC_left_top_16_64_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_16_64_inst 
	(
	
	.sample_number_left_i(sample_number_left_5_16_w),
	.sample_number_top_i(sample_number_top_5_64_w),
	.sum_left_top(sum_left_top_16_64_w),
	.DC_left_top(DC_left_top_16_64_w)
		
    );

	wire [6:0]  sample_number_left_5_64_w;
	wire [6:0]  sample_number_top_5_16_w;	
	wire [19:0] sum_left_top_64_16_w;
	wire [width_p+1:0] DC_left_top_64_16_w;	
	
	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_64_16_inst 
	(
	
	.sample_number_left_i(sample_number_left_5_64_w),
	.sample_number_top_i(sample_number_top_5_16_w),
	.sum_left_top(sum_left_top_64_16_w),
	.DC_left_top(DC_left_top_64_16_w)
		
    );

   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------
	
	wire [6:0]  sample_number_left_6_32_w;
	wire [6:0]  sample_number_top_6_64_w;	
	wire [19:0] sum_left_top_32_64_w;
	wire [width_p+1:0] DC_left_top_32_64_w;	

	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_32_64_inst 
	(
	
	.sample_number_left_i(sample_number_left_6_32_w),
	.sample_number_top_i(sample_number_top_6_64_w),
	.sum_left_top(sum_left_top_32_64_w),
	.DC_left_top(DC_left_top_32_64_w)
		
    );	

	wire [6:0]  sample_number_left_6_64_w;
	wire [6:0]  sample_number_top_6_32_w;	
	wire [19:0] sum_left_top_64_32_w;
	wire [width_p+1:0] DC_left_top_64_32_w;	

	DC_left_top #(
	
		.width_p(width_p)
		
	) DC_left_top_64_32_inst
	(
	
	.sample_number_left_i(sample_number_left_6_64_w),
	.sample_number_top_i(sample_number_top_6_32_w),
	.sum_left_top(sum_left_top_64_32_w),
	.DC_left_top(DC_left_top_64_32_w)
		
    );		
	
   	// -----------------------------------------------------------------------
   	// -----------------------------------------------------------------------	
	// Wires assign - SUM  
	
	assign sum_1d_left_4				= sum_left; 
	assign sum_1d_left_8				= sum_left; 
	assign sum_1d_left_16				= sum_left;  
	assign sum_1d_left_32				= sum_left;  
	assign sum_1d_left_64				= sum_left; 

	assign sum_1d_top_4					= sum_top; 
	assign sum_1d_top_8					= sum_top; 
	assign sum_1d_top_16				= sum_top;  
	assign sum_1d_top_32				= sum_top;  
	assign sum_1d_top_64				= sum_top; 

	assign sum_left_top_4_4				= sum_top_left;
	assign sum_left_top_8_8				= sum_top_left;
	assign sum_left_top_16_16			= sum_top_left;
	assign sum_left_top_32_32			= sum_top_left;
	assign sum_left_top_64_64   		= sum_top_left;
	assign sum_left_top_4_8_w   		= sum_top_left;
	assign sum_left_top_8_4_w			= sum_top_left;
	assign sum_left_top_4_16_w  		= sum_top_left;
	assign sum_left_top_16_4_w  		= sum_top_left;
	assign sum_left_top_8_16_w			= sum_top_left;
	assign sum_left_top_16_8_w  		= sum_top_left;
	assign sum_left_top_8_32_w  		= sum_top_left;
	assign sum_left_top_32_8_w			= sum_top_left;
	assign sum_left_top_16_32_w 		= sum_top_left;
	assign sum_left_top_32_16_w 		= sum_top_left;
	assign sum_left_top_16_64_w			= sum_top_left;
	assign sum_left_top_64_16_w 		= sum_top_left;
	assign sum_left_top_32_64_w 		= sum_top_left;
	assign sum_left_top_64_32_w 		= sum_top_left;
	
	// Wires assign - Sample Number 
 
	assign sample_number_left_4			= 7'd4; 	
	assign sample_number_left_8			= 7'd8;	
	assign sample_number_left_16		= 7'd16;	
	assign sample_number_left_32		= 7'd32;	
	assign sample_number_left_64		= 7'd64;

	assign sample_number_1d_left_4		= 7'd4; 
	assign sample_number_1d_left_8		= 7'd8;	
	assign sample_number_1d_left_16		= 7'd16;
	assign sample_number_1d_left_32		= 7'd32;
	assign sample_number_1d_left_64		= 7'd64;

	assign sample_number_top_4			= 7'd4; 	
	assign sample_number_top_8			= 7'd8;		
	assign sample_number_top_16			= 7'd16;	
	assign sample_number_top_32			= 7'd32;	
	assign sample_number_top_64			= 7'd64;

	assign sample_number_1d_top_4		= 7'd4; 
	assign sample_number_1d_top_8		= 7'd8;	
	assign sample_number_1d_top_16		= 7'd16;
	assign sample_number_1d_top_32		= 7'd32;
	assign sample_number_1d_top_64		= 7'd64;

	assign sample_number_left_0_4_w		= 7'd4;  
	assign sample_number_left_0_8_w		= 7'd8;	
	assign sample_number_left_1_4_w		= 7'd4;
	assign sample_number_left_1_16_w	= 7'd16;
	assign sample_number_left_2_8_w		= 7'd8;
	assign sample_number_left_2_16_w    = 7'd16;
	assign sample_number_left_3_8_w     = 7'd8;
	assign sample_number_left_3_32_w    = 7'd32;
	assign sample_number_left_4_16_w	= 7'd16;
	assign sample_number_left_4_32_w    = 7'd32;
	assign sample_number_left_5_16_w    = 7'd16;
	assign sample_number_left_5_64_w    = 7'd64;
	assign sample_number_left_6_32_w    = 7'd32;
	assign sample_number_left_6_64_w    = 7'd64;

	assign sample_number_top_0_4_w		= 7'd4;  
	assign sample_number_top_0_8_w		= 7'd8;	
	assign sample_number_top_1_4_w		= 7'd4;
	assign sample_number_top_1_16_w		= 7'd16;
	assign sample_number_top_2_8_w		= 7'd8;
	assign sample_number_top_2_16_w    	= 7'd16;
	assign sample_number_top_3_8_w     	= 7'd8;
	assign sample_number_top_3_32_w    	= 7'd32;
	assign sample_number_top_4_16_w		= 7'd16;
	assign sample_number_top_4_32_w    	= 7'd32;
	assign sample_number_top_5_16_w    	= 7'd16;
	assign sample_number_top_5_64_w    	= 7'd64;
	assign sample_number_top_6_32_w    	= 7'd32;
	assign sample_number_top_6_64_w    	= 7'd64;
	
	assign H_sum_div_2   =  sample_number_left_reg >> 1; 
	assign W_sum_div_2   =  sample_number_top_reg  >> 1;
	assign H_W_sum_div_2 = (sample_number_left_reg + sample_number_top_reg) >> 1;  
   
    always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sample_number_left_reg <= 0;
			
		end else if (sample_number_left_i == 4 || sample_number_left_i == 8 || sample_number_left_i == 16 || sample_number_left_i == 32 || sample_number_left_i == 64) begin 
			sample_number_left_reg <= sample_number_left_i;
		
		end else begin 
			sample_number_left_reg <= sample_number_left_reg; 
		end		
	end 

    always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sample_number_top_reg <= 0;
			
		end else if (sample_number_top_i == 4 || sample_number_top_i == 8 || sample_number_top_i == 16 || sample_number_top_i == 32 || sample_number_top_i == 64) begin 
			sample_number_top_reg <= sample_number_top_i;
		
		end else begin 
			sample_number_top_reg <= sample_number_top_reg;
		end 		
	end 
   
   always @(posedge clk_i)
	begin
		if(rst_i) begin 
			sum_left 		<= 0; 
			sum_top			<= 0;
			sum_top_left 	<= 0; 			
			div_en_left 	<= 0; 
			div_en_top  	<= 0;
			div_en_top_left <= 0;
			rst_DC_sum_left	<= 1;
			rst_DC_sum_top  <= 1; 
			
		end else if(left && (!above) && data_available_left) begin 
			sum_left 		<= DC_sum_left + H_sum_div_2;
			div_en_left 	<= 1; 
			rst_DC_sum_left <= 1;
			
		end else if((!left) && above && data_available_top) begin
			sum_top 		<= DC_sum_top + W_sum_div_2;
			div_en_top 		<= 1;
			rst_DC_sum_top 	<= 1;
		
		end else if(left && above && data_available_left && data_available_top) begin
			sum_top_left 	<= DC_sum_top + DC_sum_left + H_W_sum_div_2;
			div_en_top_left <= 1;
			rst_DC_sum_left <= 1;
			rst_DC_sum_top 	<= 1;
			
		end else begin 
			sum_left 		<= 0; 
			sum_top			<= 0;
			sum_top_left 	<= 0; 			
			div_en_left 	<= 0; 
			div_en_top  	<= 0;
			div_en_top_left <= 0;
			rst_DC_sum_left <= 0;
			rst_DC_sum_top 	<= 0;
			
		end 
	end 	

   always @(posedge clk_i)
	begin
		if(rst_i) begin
			DC_1d_left_4_reg 		<= 0; 			
		    DC_1d_left_8_reg		<= 0;
		    DC_1d_left_16_reg		<= 0;
		    DC_1d_left_32_reg		<= 0;
		    DC_1d_left_64_reg       <= 0;
		    DC_1d_top_4_reg         <= 0;
		    DC_1d_top_8_reg			<= 0;
		    DC_1d_top_16_reg        <= 0;
		    DC_1d_top_32_reg        <= 0;
		    DC_1d_top_64_reg		<= 0;
		    DC_left_top_4_4_reg     <= 0;
		    DC_left_top_8_8_reg     <= 0;
		    DC_left_top_16_16_reg	<= 0;
		    DC_left_top_32_32_reg	<= 0;
		    DC_left_top_64_64_reg   <= 0;
		    DC_left_top_4_8_reg     <= 0;
		    DC_left_top_8_4_reg		<= 0; 
		    DC_left_top_4_16_reg	<= 0;
		    DC_left_top_16_4_reg    <= 0;
		    DC_left_top_8_16_reg    <= 0;
		    DC_left_top_16_8_reg	<= 0;
		    DC_left_top_8_32_reg    <= 0;
		    DC_left_top_32_8_reg    <= 0;
		    DC_left_top_16_32_reg	<= 0;
		    DC_left_top_32_16_reg   <= 0;
		    DC_left_top_16_64_reg   <= 0;
		    DC_left_top_64_16_reg	<= 0;
		    DC_left_top_32_64_reg   <= 0;
		    DC_left_top_64_32_reg   <= 0; 
			mux_sel_en				<= 0; 
			
		end else if(div_en_left || div_en_top || div_en_top_left) begin 
			DC_1d_left_4_reg 		<= 	DC_1d_left_4;		
			DC_1d_left_8_reg		<=	DC_1d_left_8;		
			DC_1d_left_16_reg		<=	DC_1d_left_16;	
			DC_1d_left_32_reg		<=	DC_1d_left_32;		
			DC_1d_left_64_reg       <=	DC_1d_left_64;		
			DC_1d_top_4_reg         <=	DC_1d_top_4;		
			DC_1d_top_8_reg			<=	DC_1d_top_8;		
			DC_1d_top_16_reg        <=	DC_1d_top_16;		
			DC_1d_top_32_reg        <=	DC_1d_top_32;		
			DC_1d_top_64_reg		<=	DC_1d_top_64;		
			DC_left_top_4_4_reg     <=	DC_left_top_4_4;	
			DC_left_top_8_8_reg     <=	DC_left_top_8_8;		
			DC_left_top_16_16_reg	<=	DC_left_top_16_16;		
			DC_left_top_32_32_reg	<=	DC_left_top_32_32;		
			DC_left_top_64_64_reg   <=	DC_left_top_64_64;		
			DC_left_top_4_8_reg     <=	DC_left_top_4_8_w;		
			DC_left_top_8_4_reg		<=	DC_left_top_8_4_w;		
			DC_left_top_4_16_reg	<=	DC_left_top_4_16_w;		
			DC_left_top_16_4_reg    <=	DC_left_top_16_4_w;		
			DC_left_top_8_16_reg    <=	DC_left_top_8_16_w;		
			DC_left_top_16_8_reg	<=	DC_left_top_16_8_w;		
			DC_left_top_8_32_reg    <=	DC_left_top_8_32_w;		
			DC_left_top_32_8_reg    <=	DC_left_top_32_8_w;		
			DC_left_top_16_32_reg	<=	DC_left_top_16_32_w;		
			DC_left_top_32_16_reg   <=	DC_left_top_32_16_w;		
			DC_left_top_16_64_reg   <=	DC_left_top_16_64_w;	
			DC_left_top_64_16_reg	<=	DC_left_top_64_16_w;	
			DC_left_top_32_64_reg   <=	DC_left_top_32_64_w;	
			DC_left_top_64_32_reg   <=	DC_left_top_64_32_w;
			mux_sel_en				<=  1; 
			
		end else begin 
			DC_1d_left_4_reg 		<= 0; 			
		    DC_1d_left_8_reg		<= 0;
		    DC_1d_left_16_reg		<= 0;
		    DC_1d_left_32_reg		<= 0;
		    DC_1d_left_64_reg       <= 0;
		    DC_1d_top_4_reg         <= 0;
		    DC_1d_top_8_reg			<= 0;
		    DC_1d_top_16_reg        <= 0;
		    DC_1d_top_32_reg        <= 0;
		    DC_1d_top_64_reg		<= 0;
		    DC_left_top_4_4_reg     <= 0;
		    DC_left_top_8_8_reg     <= 0;
		    DC_left_top_16_16_reg	<= 0;
		    DC_left_top_32_32_reg	<= 0;
		    DC_left_top_64_64_reg   <= 0;
		    DC_left_top_4_8_reg     <= 0;
		    DC_left_top_8_4_reg		<= 0; 
		    DC_left_top_4_16_reg	<= 0;
		    DC_left_top_16_4_reg    <= 0;
		    DC_left_top_8_16_reg    <= 0;
		    DC_left_top_16_8_reg	<= 0;
		    DC_left_top_8_32_reg    <= 0;
		    DC_left_top_32_8_reg    <= 0;
		    DC_left_top_16_32_reg	<= 0;
		    DC_left_top_32_16_reg   <= 0;
		    DC_left_top_16_64_reg   <= 0;
		    DC_left_top_64_16_reg	<= 0;
		    DC_left_top_32_64_reg   <= 0;
		    DC_left_top_64_32_reg   <= 0; 
			mux_sel_en				<= 0; 
		end 
	end

   always @(posedge clk_i)
	begin
		if(rst_i) begin 
			reg_DC_left 		<= 0;
			reg_DC_top  		<= 0;	
			reg_DC_top_left 	<= 0;
			ready_reg_left		<= 0;
			ready_reg_top 		<= 0;
			ready_reg_left_top 	<= 0; 
			
		end else if(left && (!above) && mux_sel_en) begin 
			case(sample_number_left_reg)
				7'd4  :	begin
							reg_DC_left <= $signed(DC_1d_left_4_reg);
							ready_reg_left <= 1;
						end 		

				7'd8  :	begin
							reg_DC_left <= $signed(DC_1d_left_8_reg);
							ready_reg_left <= 1;
						end 	

				7'd16 :	begin
							reg_DC_left <= $signed(DC_1d_left_16_reg); 
							ready_reg_left <= 1;
						end 

				7'd32 :	begin
							reg_DC_left <= $signed(DC_1d_left_32_reg); 
							ready_reg_left <= 1;
						end 

				7'd64 :	begin
							reg_DC_left <= $signed(DC_1d_left_64_reg);
							ready_reg_left <= 1;							
						end

				default: begin reg_DC_left <= 0; ready_reg_left <= 0; end 
			endcase 
			
		end else if((!left) && above && mux_sel_en) begin   
			case(sample_number_top_reg)
				7'd4  :	begin
							reg_DC_top <= $signed(DC_1d_top_4_reg); 
							ready_reg_top <= 1;
						end 		

				7'd8  :	begin
							reg_DC_top <= $signed(DC_1d_top_8_reg);
							ready_reg_top <= 1;
						end 	

				7'd16 :	begin
							reg_DC_top <= $signed(DC_1d_top_16_reg);
							ready_reg_top <= 1;
						end 

				7'd32 :	begin
							reg_DC_top <= $signed(DC_1d_top_32_reg);
							ready_reg_top <= 1;
						end 

				7'd64 :	begin
							reg_DC_top <= $signed(DC_1d_top_64_reg); 
							ready_reg_top <= 1;
						end

				default: begin reg_DC_top <= 0; ready_reg_top <= 0; end 
			endcase 
			
		end else if(left && above && mux_sel_en) begin 	
			case ({sample_number_top_reg, sample_number_left_reg})
				{7'd4, 7'd4} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_4_4_reg);
										ready_reg_left_top <= 1;
									end 			
			
				{7'd8, 7'd8} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_8_8_reg);
										ready_reg_left_top <= 1;
									end 			
			
				{7'd16, 7'd16} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_16_16_reg);
										ready_reg_left_top <= 1;
									end 			

				{7'd32, 7'd32} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_32_32_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd64, 7'd64} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_64_64_reg); 
										ready_reg_left_top <= 1;
									end 

				{7'd4, 7'd8} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_4_8_reg); 
										ready_reg_left_top <= 1;
									end 						   

				{7'd8, 7'd4} 	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_8_4_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd4, 7'd16}  	:	begin
										reg_DC_top_left <= $signed(DC_left_top_4_16_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd16, 7'd4}  	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_16_4_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd8, 7'd16}  	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_8_16_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd16, 7'd8}  	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_16_8_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd8, 7'd32}  	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_8_32_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd32, 7'd8}  	: 	begin
										reg_DC_top_left <= $signed(DC_left_top_32_8_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd16, 7'd32}  : 	begin
										reg_DC_top_left <= $signed(DC_left_top_16_32_reg);
										ready_reg_left_top <= 1;
									end 
									
				{7'd32, 7'd16}  : 	begin
										reg_DC_top_left <= $signed(DC_left_top_32_16_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd16, 7'd64}  : 	begin
										reg_DC_top_left <= $signed(DC_left_top_16_64_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd64, 7'd16}  : 	begin
										reg_DC_top_left <= $signed(DC_left_top_64_16_reg); 
										ready_reg_left_top <= 1;
									end 

				{7'd32, 7'd64}  : 	begin
										reg_DC_top_left <= $signed(DC_left_top_32_64_reg);
										ready_reg_left_top <= 1;
									end 

				{7'd64, 7'd32}  : 	begin
										reg_DC_top_left <= $signed(DC_left_top_64_32_reg);
										ready_reg_left_top <= 1;
									end
									
				default: begin reg_DC_top_left <= 0; ready_reg_left_top <= 0; end				
			endcase 
			
		end else begin 
			reg_DC_left 		<= 0;
			reg_DC_top  		<= 0;	
			reg_DC_top_left 	<= 0;
			ready_reg_left		<= 0;
			ready_reg_top 		<= 0;
			ready_reg_left_top 	<= 0; 
		end
	end	

   assign ready_o = (ready_reg_left || ready_reg_top || ready_reg_left_top) ? 1'b1 : 1'b0; 
   
   assign intrapred_data_out_o = ready_reg_left     ?  reg_DC_left     : 
								 ready_reg_top      ?  reg_DC_top      : 
								 ready_reg_left_top ?  reg_DC_top_left : 
								 0; 

endmodule 