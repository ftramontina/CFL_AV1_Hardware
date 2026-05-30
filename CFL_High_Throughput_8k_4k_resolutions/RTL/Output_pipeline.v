
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

	input wire [width_p-1:0] sample_in_00_i,
	input wire [width_p-1:0] sample_in_01_i,
    input wire [width_p-1:0] sample_in_02_i,
    input wire [width_p-1:0] sample_in_03_i,
    input wire [width_p-1:0] sample_in_04_i,
    input wire [width_p-1:0] sample_in_05_i,
    input wire [width_p-1:0] sample_in_06_i,
    input wire [width_p-1:0] sample_in_07_i,
    input wire [width_p-1:0] sample_in_08_i,
    input wire [width_p-1:0] sample_in_09_i,
    input wire [width_p-1:0] sample_in_10_i,
    input wire [width_p-1:0] sample_in_11_i,
    input wire [width_p-1:0] sample_in_12_i,
    input wire [width_p-1:0] sample_in_13_i,
    input wire [width_p-1:0] sample_in_14_i,
    input wire [width_p-1:0] sample_in_15_i,

	input wire [7:0] block_width_i, 
	input wire [7:0] block_height_i, 

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
	output wire [width_p+1:0] CFL_final_15_o
   
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
	
	reg signed [width_p+2:0] AC_value_00_reg;
	reg signed [width_p+2:0] AC_value_01_reg;
	reg signed [width_p+2:0] AC_value_02_reg;
	reg signed [width_p+2:0] AC_value_03_reg;
	reg signed [width_p+2:0] AC_value_04_reg;
	reg signed [width_p+2:0] AC_value_05_reg;
	reg signed [width_p+2:0] AC_value_06_reg;
	reg signed [width_p+2:0] AC_value_07_reg;
	reg signed [width_p+2:0] AC_value_08_reg;
	reg signed [width_p+2:0] AC_value_09_reg;
	reg signed [width_p+2:0] AC_value_10_reg;
	reg signed [width_p+2:0] AC_value_11_reg;
	reg signed [width_p+2:0] AC_value_12_reg;
	reg signed [width_p+2:0] AC_value_13_reg;
	reg signed [width_p+2:0] AC_value_14_reg;
	reg signed [width_p+2:0] AC_value_15_reg;
	
	reg signed [width_p+2:0] sample_in_00_reg;
	reg signed [width_p+2:0] sample_in_01_reg;	
	reg signed [width_p+2:0] sample_in_02_reg;
	reg signed [width_p+2:0] sample_in_03_reg;
	reg signed [width_p+2:0] sample_in_04_reg;
	reg signed [width_p+2:0] sample_in_05_reg;
	reg signed [width_p+2:0] sample_in_06_reg;
	reg signed [width_p+2:0] sample_in_07_reg;
    reg signed [width_p+2:0] sample_in_08_reg;
    reg signed [width_p+2:0] sample_in_09_reg;
    reg signed [width_p+2:0] sample_in_10_reg;
    reg signed [width_p+2:0] sample_in_11_reg;
    reg signed [width_p+2:0] sample_in_12_reg;
    reg signed [width_p+2:0] sample_in_13_reg;
    reg signed [width_p+2:0] sample_in_14_reg;
    reg signed [width_p+2:0] sample_in_15_reg;

	reg signed [width_p+2:0] CFL_final_0_reg; 
	reg signed [width_p+2:0] CFL_final_1_reg; 
	reg signed [width_p+2:0] CFL_final_2_reg; 
	reg signed [width_p+2:0] CFL_final_3_reg; 
	reg signed [width_p+2:0] CFL_final_4_reg; 
	reg signed [width_p+2:0] CFL_final_5_reg; 
	reg signed [width_p+2:0] CFL_final_6_reg; 
	reg signed [width_p+2:0] CFL_final_7_reg; 
	reg signed [width_p+2:0] CFL_final_8_reg; 
	reg signed [width_p+2:0] CFL_final_9_reg; 
	reg signed [width_p+2:0] CFL_final_10_reg;
	reg signed [width_p+2:0] CFL_final_11_reg;
	reg signed [width_p+2:0] CFL_final_12_reg;
	reg signed [width_p+2:0] CFL_final_13_reg;
	reg signed [width_p+2:0] CFL_final_14_reg;
	reg signed [width_p+2:0] CFL_final_15_reg;
	
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
	
	reg signed [width_p+2:0] CFL_0_0_reg 	  ;
	reg signed [width_p+2:0] CFL_0_1_reg 	  ;
	reg signed [width_p+2:0] CFL_0_2_reg 	  ;
	reg signed [width_p+2:0] CFL_0_3_reg 	  ;
	reg signed [width_p+2:0] CFL_0_4_reg 	  ;
	reg signed [width_p+2:0] CFL_0_5_reg 	  ;
	reg signed [width_p+2:0] CFL_0_6_reg 	  ;
	reg signed [width_p+2:0] CFL_0_7_reg 	  ;
	reg signed [width_p+2:0] CFL_0_8_reg 	  ;
	reg signed [width_p+2:0] CFL_0_9_reg 	  ;
	reg signed [width_p+2:0] CFL_0_10_reg	  ;
	reg signed [width_p+2:0] CFL_0_11_reg	  ;
	reg signed [width_p+2:0] CFL_0_12_reg	  ;
	reg signed [width_p+2:0] CFL_0_13_reg	  ;
	reg signed [width_p+2:0] CFL_0_14_reg	  ;
	reg signed [width_p+2:0] CFL_0_15_reg	  ;
	reg signed [width_p+2:0] CFL_1_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_1_10_pos_reg ;
	reg signed [width_p+2:0] CFL_1_11_pos_reg ;
	reg signed [width_p+2:0] CFL_1_12_pos_reg ;
	reg signed [width_p+2:0] CFL_1_13_pos_reg ;
	reg signed [width_p+2:0] CFL_1_14_pos_reg ;
	reg signed [width_p+2:0] CFL_1_15_pos_reg ;
	reg signed [width_p+2:0] CFL_1_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_1_10_neg_reg ;
	reg signed [width_p+2:0] CFL_1_11_neg_reg ;
	reg signed [width_p+2:0] CFL_1_12_neg_reg ;
	reg signed [width_p+2:0] CFL_1_13_neg_reg ;
	reg signed [width_p+2:0] CFL_1_14_neg_reg ;
	reg signed [width_p+2:0] CFL_1_15_neg_reg ;
	reg signed [width_p+2:0] CFL_2_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_2_10_pos_reg ;
	reg signed [width_p+2:0] CFL_2_11_pos_reg ;
	reg signed [width_p+2:0] CFL_2_12_pos_reg ;
	reg signed [width_p+2:0] CFL_2_13_pos_reg ;
	reg signed [width_p+2:0] CFL_2_14_pos_reg ;
	reg signed [width_p+2:0] CFL_2_15_pos_reg ;
	reg signed [width_p+2:0] CFL_2_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_2_10_neg_reg ;
	reg signed [width_p+2:0] CFL_2_11_neg_reg ;
	reg signed [width_p+2:0] CFL_2_12_neg_reg ;
	reg signed [width_p+2:0] CFL_2_13_neg_reg ;
	reg signed [width_p+2:0] CFL_2_14_neg_reg ;
	reg signed [width_p+2:0] CFL_2_15_neg_reg ;
	reg signed [width_p+2:0] CFL_3_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_3_10_pos_reg ;
	reg signed [width_p+2:0] CFL_3_11_pos_reg ;
	reg signed [width_p+2:0] CFL_3_12_pos_reg ;
	reg signed [width_p+2:0] CFL_3_13_pos_reg ;
	reg signed [width_p+2:0] CFL_3_14_pos_reg ;
	reg signed [width_p+2:0] CFL_3_15_pos_reg ;
	reg signed [width_p+2:0] CFL_3_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_3_10_neg_reg ;
	reg signed [width_p+2:0] CFL_3_11_neg_reg ;
	reg signed [width_p+2:0] CFL_3_12_neg_reg ;
	reg signed [width_p+2:0] CFL_3_13_neg_reg ;
	reg signed [width_p+2:0] CFL_3_14_neg_reg ;
	reg signed [width_p+2:0] CFL_3_15_neg_reg ;
	reg signed [width_p+2:0] CFL_4_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_4_10_pos_reg ;
	reg signed [width_p+2:0] CFL_4_11_pos_reg ;
	reg signed [width_p+2:0] CFL_4_12_pos_reg ;
	reg signed [width_p+2:0] CFL_4_13_pos_reg ;
	reg signed [width_p+2:0] CFL_4_14_pos_reg ;
	reg signed [width_p+2:0] CFL_4_15_pos_reg ;
	reg signed [width_p+2:0] CFL_4_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_4_10_neg_reg ;
	reg signed [width_p+2:0] CFL_4_11_neg_reg ;
	reg signed [width_p+2:0] CFL_4_12_neg_reg ;
	reg signed [width_p+2:0] CFL_4_13_neg_reg ;
	reg signed [width_p+2:0] CFL_4_14_neg_reg ;
	reg signed [width_p+2:0] CFL_4_15_neg_reg ;
	reg signed [width_p+2:0] CFL_5_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_5_10_pos_reg ;
	reg signed [width_p+2:0] CFL_5_11_pos_reg ;
	reg signed [width_p+2:0] CFL_5_12_pos_reg ;
	reg signed [width_p+2:0] CFL_5_13_pos_reg ;
	reg signed [width_p+2:0] CFL_5_14_pos_reg ;
	reg signed [width_p+2:0] CFL_5_15_pos_reg ;
	reg signed [width_p+2:0] CFL_5_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_5_10_neg_reg ;
	reg signed [width_p+2:0] CFL_5_11_neg_reg ;
	reg signed [width_p+2:0] CFL_5_12_neg_reg ;
	reg signed [width_p+2:0] CFL_5_13_neg_reg ;
	reg signed [width_p+2:0] CFL_5_14_neg_reg ;
	reg signed [width_p+2:0] CFL_5_15_neg_reg ;
	reg signed [width_p+2:0] CFL_6_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_1_pos_reg  ;
    reg signed [width_p+2:0] CFL_6_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_6_10_pos_reg ;
	reg signed [width_p+2:0] CFL_6_11_pos_reg ;
	reg signed [width_p+2:0] CFL_6_12_pos_reg ;
	reg signed [width_p+2:0] CFL_6_13_pos_reg ;
	reg signed [width_p+2:0] CFL_6_14_pos_reg ;
	reg signed [width_p+2:0] CFL_6_15_pos_reg ;
	reg signed [width_p+2:0] CFL_6_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_6_10_neg_reg ;
	reg signed [width_p+2:0] CFL_6_11_neg_reg ;
	reg signed [width_p+2:0] CFL_6_12_neg_reg ;
	reg signed [width_p+2:0] CFL_6_13_neg_reg ;
	reg signed [width_p+2:0] CFL_6_14_neg_reg ;
	reg signed [width_p+2:0] CFL_6_15_neg_reg ;
	reg signed [width_p+2:0] CFL_7_0_pos_reg;
	reg signed [width_p+2:0] CFL_7_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_7_10_pos_reg ;
	reg signed [width_p+2:0] CFL_7_11_pos_reg ;
	reg signed [width_p+2:0] CFL_7_12_pos_reg ;
	reg signed [width_p+2:0] CFL_7_13_pos_reg ;
	reg signed [width_p+2:0] CFL_7_14_pos_reg ;
	reg signed [width_p+2:0] CFL_7_15_pos_reg ;
	reg signed [width_p+2:0] CFL_7_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_7_10_neg_reg ;
	reg signed [width_p+2:0] CFL_7_11_neg_reg ;
	reg signed [width_p+2:0] CFL_7_12_neg_reg ;
	reg signed [width_p+2:0] CFL_7_13_neg_reg ;
	reg signed [width_p+2:0] CFL_7_14_neg_reg ;
	reg signed [width_p+2:0] CFL_7_15_neg_reg ;
	reg signed [width_p+2:0] CFL_8_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_8_10_pos_reg ;
	reg signed [width_p+2:0] CFL_8_11_pos_reg ;
	reg signed [width_p+2:0] CFL_8_12_pos_reg ;
	reg signed [width_p+2:0] CFL_8_13_pos_reg ;
	reg signed [width_p+2:0] CFL_8_14_pos_reg ;
	reg signed [width_p+2:0] CFL_8_15_pos_reg ;
	reg signed [width_p+2:0] CFL_8_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_8_10_neg_reg ;
	reg signed [width_p+2:0] CFL_8_11_neg_reg ;
	reg signed [width_p+2:0] CFL_8_12_neg_reg ;
	reg signed [width_p+2:0] CFL_8_13_neg_reg ;
	reg signed [width_p+2:0] CFL_8_14_neg_reg ;
	reg signed [width_p+2:0] CFL_8_15_neg_reg ;
	reg signed [width_p+2:0] CFL_9_0_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_1_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_2_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_3_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_4_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_5_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_6_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_7_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_8_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_9_pos_reg  ;
	reg signed [width_p+2:0] CFL_9_10_pos_reg ;
	reg signed [width_p+2:0] CFL_9_11_pos_reg ;
	reg signed [width_p+2:0] CFL_9_12_pos_reg ;
	reg signed [width_p+2:0] CFL_9_13_pos_reg ;
	reg signed [width_p+2:0] CFL_9_14_pos_reg ;
	reg signed [width_p+2:0] CFL_9_15_pos_reg ;
	reg signed [width_p+2:0] CFL_9_0_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_1_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_2_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_3_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_4_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_5_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_6_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_7_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_8_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_9_neg_reg  ;
	reg signed [width_p+2:0] CFL_9_10_neg_reg ;
	reg signed [width_p+2:0] CFL_9_11_neg_reg ;
	reg signed [width_p+2:0] CFL_9_12_neg_reg ;
	reg signed [width_p+2:0] CFL_9_13_neg_reg ;
	reg signed [width_p+2:0] CFL_9_14_neg_reg ;
	reg signed [width_p+2:0] CFL_9_15_neg_reg ;
	reg signed [width_p+2:0] CFL_10_0_pos_reg ;
	reg signed [width_p+2:0] CFL_10_1_pos_reg ;
	reg signed [width_p+2:0] CFL_10_2_pos_reg ;
	reg signed [width_p+2:0] CFL_10_3_pos_reg ;
	reg signed [width_p+2:0] CFL_10_4_pos_reg ;
	reg signed [width_p+2:0] CFL_10_5_pos_reg ;
	reg signed [width_p+2:0] CFL_10_6_pos_reg ;
	reg signed [width_p+2:0] CFL_10_7_pos_reg ;
	reg signed [width_p+2:0] CFL_10_8_pos_reg ;
	reg signed [width_p+2:0] CFL_10_9_pos_reg ;
	reg signed [width_p+2:0] CFL_10_10_pos_reg;
	reg signed [width_p+2:0] CFL_10_11_pos_reg;
	reg signed [width_p+2:0] CFL_10_12_pos_reg;
	reg signed [width_p+2:0] CFL_10_13_pos_reg;
	reg signed [width_p+2:0] CFL_10_14_pos_reg;
	reg signed [width_p+2:0] CFL_10_15_pos_reg;
	reg signed [width_p+2:0] CFL_10_0_neg_reg ;
	reg signed [width_p+2:0] CFL_10_1_neg_reg ;
	reg signed [width_p+2:0] CFL_10_2_neg_reg ;
	reg signed [width_p+2:0] CFL_10_3_neg_reg ;
	reg signed [width_p+2:0] CFL_10_4_neg_reg ;
	reg signed [width_p+2:0] CFL_10_5_neg_reg ;
	reg signed [width_p+2:0] CFL_10_6_neg_reg ;
	reg signed [width_p+2:0] CFL_10_7_neg_reg ;
	reg signed [width_p+2:0] CFL_10_8_neg_reg ;
	reg signed [width_p+2:0] CFL_10_9_neg_reg ;
	reg signed [width_p+2:0] CFL_10_10_neg_reg;
	reg signed [width_p+2:0] CFL_10_11_neg_reg;
	reg signed [width_p+2:0] CFL_10_12_neg_reg;
	reg signed [width_p+2:0] CFL_10_13_neg_reg;
	reg signed [width_p+2:0] CFL_10_14_neg_reg;
	reg signed [width_p+2:0] CFL_10_15_neg_reg;
	reg signed [width_p+2:0] CFL_11_0_pos_reg ;
	reg signed [width_p+2:0] CFL_11_1_pos_reg ;
	reg signed [width_p+2:0] CFL_11_2_pos_reg ;
	reg signed [width_p+2:0] CFL_11_3_pos_reg ;
	reg signed [width_p+2:0] CFL_11_4_pos_reg ;
	reg signed [width_p+2:0] CFL_11_5_pos_reg ;
	reg signed [width_p+2:0] CFL_11_6_pos_reg ;
	reg signed [width_p+2:0] CFL_11_7_pos_reg ;
	reg signed [width_p+2:0] CFL_11_8_pos_reg ;
	reg signed [width_p+2:0] CFL_11_9_pos_reg ;
	reg signed [width_p+2:0] CFL_11_10_pos_reg;
	reg signed [width_p+2:0] CFL_11_11_pos_reg;
	reg signed [width_p+2:0] CFL_11_12_pos_reg;
	reg signed [width_p+2:0] CFL_11_13_pos_reg;
	reg signed [width_p+2:0] CFL_11_14_pos_reg;
	reg signed [width_p+2:0] CFL_11_15_pos_reg;
	reg signed [width_p+2:0] CFL_11_0_neg_reg ;
	reg signed [width_p+2:0] CFL_11_1_neg_reg ;
	reg signed [width_p+2:0] CFL_11_2_neg_reg ;
	reg signed [width_p+2:0] CFL_11_3_neg_reg ;
	reg signed [width_p+2:0] CFL_11_4_neg_reg ;
	reg signed [width_p+2:0] CFL_11_5_neg_reg ;
	reg signed [width_p+2:0] CFL_11_6_neg_reg ;
	reg signed [width_p+2:0] CFL_11_7_neg_reg ;
	reg signed [width_p+2:0] CFL_11_8_neg_reg ;
	reg signed [width_p+2:0] CFL_11_9_neg_reg ;
	reg signed [width_p+2:0] CFL_11_10_neg_reg;
	reg signed [width_p+2:0] CFL_11_11_neg_reg;
	reg signed [width_p+2:0] CFL_11_12_neg_reg;
	reg signed [width_p+2:0] CFL_11_13_neg_reg;
	reg signed [width_p+2:0] CFL_11_14_neg_reg;
	reg signed [width_p+2:0] CFL_11_15_neg_reg;
	reg signed [width_p+2:0] CFL_12_0_pos_reg ;
	reg signed [width_p+2:0] CFL_12_1_pos_reg ;
	reg signed [width_p+2:0] CFL_12_2_pos_reg ;
	reg signed [width_p+2:0] CFL_12_3_pos_reg ;
	reg signed [width_p+2:0] CFL_12_4_pos_reg ;
	reg signed [width_p+2:0] CFL_12_5_pos_reg ;
	reg signed [width_p+2:0] CFL_12_6_pos_reg ;
	reg signed [width_p+2:0] CFL_12_7_pos_reg ;
	reg signed [width_p+2:0] CFL_12_8_pos_reg ;
	reg signed [width_p+2:0] CFL_12_9_pos_reg ;
	reg signed [width_p+2:0] CFL_12_10_pos_reg;
	reg signed [width_p+2:0] CFL_12_11_pos_reg;
	reg signed [width_p+2:0] CFL_12_12_pos_reg;
	reg signed [width_p+2:0] CFL_12_13_pos_reg;
	reg signed [width_p+2:0] CFL_12_14_pos_reg;
	reg signed [width_p+2:0] CFL_12_15_pos_reg;
	reg signed [width_p+2:0] CFL_12_0_neg_reg ;
	reg signed [width_p+2:0] CFL_12_1_neg_reg ;
	reg signed [width_p+2:0] CFL_12_2_neg_reg ;
	reg signed [width_p+2:0] CFL_12_3_neg_reg ;
	reg signed [width_p+2:0] CFL_12_4_neg_reg ;
	reg signed [width_p+2:0] CFL_12_5_neg_reg ;
	reg signed [width_p+2:0] CFL_12_6_neg_reg ;
	reg signed [width_p+2:0] CFL_12_7_neg_reg ;
	reg signed [width_p+2:0] CFL_12_8_neg_reg ;
	reg signed [width_p+2:0] CFL_12_9_neg_reg ;
    reg signed [width_p+2:0] CFL_12_10_neg_reg;
    reg signed [width_p+2:0] CFL_12_11_neg_reg;
    reg signed [width_p+2:0] CFL_12_12_neg_reg;
    reg signed [width_p+2:0] CFL_12_13_neg_reg;
    reg signed [width_p+2:0] CFL_12_14_neg_reg;
    reg signed [width_p+2:0] CFL_12_15_neg_reg;
    reg signed [width_p+2:0] CFL_13_0_pos_reg ;
    reg signed [width_p+2:0] CFL_13_1_pos_reg ;
    reg signed [width_p+2:0] CFL_13_2_pos_reg ;
    reg signed [width_p+2:0] CFL_13_3_pos_reg ;
    reg signed [width_p+2:0] CFL_13_4_pos_reg ;
    reg signed [width_p+2:0] CFL_13_5_pos_reg ;
    reg signed [width_p+2:0] CFL_13_6_pos_reg ;
    reg signed [width_p+2:0] CFL_13_7_pos_reg ;
    reg signed [width_p+2:0] CFL_13_8_pos_reg ;
    reg signed [width_p+2:0] CFL_13_9_pos_reg ;
    reg signed [width_p+2:0] CFL_13_10_pos_reg;
    reg signed [width_p+2:0] CFL_13_11_pos_reg;
    reg signed [width_p+2:0] CFL_13_12_pos_reg;
    reg signed [width_p+2:0] CFL_13_13_pos_reg;
    reg signed [width_p+2:0] CFL_13_14_pos_reg;
    reg signed [width_p+2:0] CFL_13_15_pos_reg;
    reg signed [width_p+2:0] CFL_13_0_neg_reg ;
    reg signed [width_p+2:0] CFL_13_1_neg_reg ;
    reg signed [width_p+2:0] CFL_13_2_neg_reg ;
    reg signed [width_p+2:0] CFL_13_3_neg_reg ;
    reg signed [width_p+2:0] CFL_13_4_neg_reg ;
    reg signed [width_p+2:0] CFL_13_5_neg_reg ;
    reg signed [width_p+2:0] CFL_13_6_neg_reg ;
    reg signed [width_p+2:0] CFL_13_7_neg_reg ;
    reg signed [width_p+2:0] CFL_13_8_neg_reg ;
    reg signed [width_p+2:0] CFL_13_9_neg_reg ;
    reg signed [width_p+2:0] CFL_13_10_neg_reg;
    reg signed [width_p+2:0] CFL_13_11_neg_reg;
    reg signed [width_p+2:0] CFL_13_12_neg_reg;
    reg signed [width_p+2:0] CFL_13_13_neg_reg;
    reg signed [width_p+2:0] CFL_13_14_neg_reg;
    reg signed [width_p+2:0] CFL_13_15_neg_reg;
    reg signed [width_p+2:0] CFL_14_0_pos_reg ;
    reg signed [width_p+2:0] CFL_14_1_pos_reg ;
    reg signed [width_p+2:0] CFL_14_2_pos_reg ;
    reg signed [width_p+2:0] CFL_14_3_pos_reg ;
    reg signed [width_p+2:0] CFL_14_4_pos_reg ;
    reg signed [width_p+2:0] CFL_14_5_pos_reg ;
    reg signed [width_p+2:0] CFL_14_6_pos_reg ;
    reg signed [width_p+2:0] CFL_14_7_pos_reg ;
    reg signed [width_p+2:0] CFL_14_8_pos_reg ;
    reg signed [width_p+2:0] CFL_14_9_pos_reg ;
    reg signed [width_p+2:0] CFL_14_10_pos_reg;
    reg signed [width_p+2:0] CFL_14_11_pos_reg;
    reg signed [width_p+2:0] CFL_14_12_pos_reg;
    reg signed [width_p+2:0] CFL_14_13_pos_reg;
    reg signed [width_p+2:0] CFL_14_14_pos_reg;
    reg signed [width_p+2:0] CFL_14_15_pos_reg;
    reg signed [width_p+2:0] CFL_14_0_neg_reg ;
    reg signed [width_p+2:0] CFL_14_1_neg_reg ;
    reg signed [width_p+2:0] CFL_14_2_neg_reg ;
    reg signed [width_p+2:0] CFL_14_3_neg_reg ;
    reg signed [width_p+2:0] CFL_14_4_neg_reg ;
    reg signed [width_p+2:0] CFL_14_5_neg_reg ;
    reg signed [width_p+2:0] CFL_14_6_neg_reg ;
    reg signed [width_p+2:0] CFL_14_7_neg_reg ;
    reg signed [width_p+2:0] CFL_14_8_neg_reg ;
    reg signed [width_p+2:0] CFL_14_9_neg_reg ;
    reg signed [width_p+2:0] CFL_14_10_neg_reg;
    reg signed [width_p+2:0] CFL_14_11_neg_reg;
    reg signed [width_p+2:0] CFL_14_12_neg_reg;
    reg signed [width_p+2:0] CFL_14_13_neg_reg;
    reg signed [width_p+2:0] CFL_14_14_neg_reg;
    reg signed [width_p+2:0] CFL_14_15_neg_reg;
    reg signed [width_p+2:0] CFL_15_0_pos_reg ;
    reg signed [width_p+2:0] CFL_15_1_pos_reg ;
    reg signed [width_p+2:0] CFL_15_2_pos_reg ;
    reg signed [width_p+2:0] CFL_15_3_pos_reg ;
    reg signed [width_p+2:0] CFL_15_4_pos_reg ;
    reg signed [width_p+2:0] CFL_15_5_pos_reg ;
    reg signed [width_p+2:0] CFL_15_6_pos_reg ;
    reg signed [width_p+2:0] CFL_15_7_pos_reg ;
    reg signed [width_p+2:0] CFL_15_8_pos_reg ;
    reg signed [width_p+2:0] CFL_15_9_pos_reg ;
    reg signed [width_p+2:0] CFL_15_10_pos_reg;
    reg signed [width_p+2:0] CFL_15_11_pos_reg;
    reg signed [width_p+2:0] CFL_15_12_pos_reg;
    reg signed [width_p+2:0] CFL_15_13_pos_reg;
    reg signed [width_p+2:0] CFL_15_14_pos_reg;
    reg signed [width_p+2:0] CFL_15_15_pos_reg;
    reg signed [width_p+2:0] CFL_15_0_neg_reg ;
    reg signed [width_p+2:0] CFL_15_1_neg_reg ;
    reg signed [width_p+2:0] CFL_15_2_neg_reg ;
    reg signed [width_p+2:0] CFL_15_3_neg_reg ;
    reg signed [width_p+2:0] CFL_15_4_neg_reg ;
    reg signed [width_p+2:0] CFL_15_5_neg_reg ;
    reg signed [width_p+2:0] CFL_15_6_neg_reg ;
    reg signed [width_p+2:0] CFL_15_7_neg_reg ;
    reg signed [width_p+2:0] CFL_15_8_neg_reg ;
    reg signed [width_p+2:0] CFL_15_9_neg_reg ;
    reg signed [width_p+2:0] CFL_15_10_neg_reg;
    reg signed [width_p+2:0] CFL_15_11_neg_reg;
    reg signed [width_p+2:0] CFL_15_12_neg_reg;
    reg signed [width_p+2:0] CFL_15_13_neg_reg;
    reg signed [width_p+2:0] CFL_15_14_neg_reg;
    reg signed [width_p+2:0] CFL_15_15_neg_reg;
    reg signed [width_p+2:0] CFL_16_0_pos_reg ;
    reg signed [width_p+2:0] CFL_16_1_pos_reg ;
    reg signed [width_p+2:0] CFL_16_2_pos_reg ;
    reg signed [width_p+2:0] CFL_16_3_pos_reg ;
    reg signed [width_p+2:0] CFL_16_4_pos_reg ;
    reg signed [width_p+2:0] CFL_16_5_pos_reg ;
    reg signed [width_p+2:0] CFL_16_6_pos_reg ;
    reg signed [width_p+2:0] CFL_16_7_pos_reg ;
    reg signed [width_p+2:0] CFL_16_8_pos_reg ;
    reg signed [width_p+2:0] CFL_16_9_pos_reg ;
    reg signed [width_p+2:0] CFL_16_10_pos_reg;
    reg signed [width_p+2:0] CFL_16_11_pos_reg;
    reg signed [width_p+2:0] CFL_16_12_pos_reg;
    reg signed [width_p+2:0] CFL_16_13_pos_reg;
    reg signed [width_p+2:0] CFL_16_14_pos_reg;
    reg signed [width_p+2:0] CFL_16_15_pos_reg;
    reg signed [width_p+2:0] CFL_16_0_neg_reg ;
    reg signed [width_p+2:0] CFL_16_1_neg_reg ;
    reg signed [width_p+2:0] CFL_16_2_neg_reg ;
    reg signed [width_p+2:0] CFL_16_3_neg_reg ;
    reg signed [width_p+2:0] CFL_16_4_neg_reg ;
    reg signed [width_p+2:0] CFL_16_5_neg_reg ;
    reg signed [width_p+2:0] CFL_16_6_neg_reg ;
    reg signed [width_p+2:0] CFL_16_7_neg_reg ;
    reg signed [width_p+2:0] CFL_16_8_neg_reg ;
    reg signed [width_p+2:0] CFL_16_9_neg_reg ;
    reg signed [width_p+2:0] CFL_16_10_neg_reg;
    reg signed [width_p+2:0] CFL_16_11_neg_reg;
    reg signed [width_p+2:0] CFL_16_12_neg_reg;
    reg signed [width_p+2:0] CFL_16_13_neg_reg;
    reg signed [width_p+2:0] CFL_16_14_neg_reg;
    reg signed [width_p+2:0] CFL_16_15_neg_reg;

	// --------- wires of alpha processing ---------- //
	
	// index = 0 	
	wire alpha_sign_0 = 0;
	wire [4:0] alpha_index_0 = 0; 
	
	wire signed [width_p+2:0] AC_value_00_wire;
	wire signed [width_p+2:0] AC_value_01_wire;
	wire signed [width_p+2:0] AC_value_02_wire;
	wire signed [width_p+2:0] AC_value_03_wire;
	wire signed [width_p+2:0] AC_value_04_wire;
	wire signed [width_p+2:0] AC_value_05_wire;
	wire signed [width_p+2:0] AC_value_06_wire;
	wire signed [width_p+2:0] AC_value_07_wire;
	wire signed [width_p+2:0] AC_value_08_wire;
	wire signed [width_p+2:0] AC_value_09_wire;
	wire signed [width_p+2:0] AC_value_10_wire;
	wire signed [width_p+2:0] AC_value_11_wire;
	wire signed [width_p+2:0] AC_value_12_wire;
	wire signed [width_p+2:0] AC_value_13_wire;
	wire signed [width_p+2:0] AC_value_14_wire;
	wire signed [width_p+2:0] AC_value_15_wire;

	wire signed [width_p+2:0] CFL_0_0;	
	wire signed [width_p+2:0] CFL_0_1;
	wire signed [width_p+2:0] CFL_0_2;
	wire signed [width_p+2:0] CFL_0_3;
	wire signed [width_p+2:0] CFL_0_4;
	wire signed [width_p+2:0] CFL_0_5;
	wire signed [width_p+2:0] CFL_0_6;
	wire signed [width_p+2:0] CFL_0_7;
	wire signed [width_p+2:0] CFL_0_8;
	wire signed [width_p+2:0] CFL_0_9;
	wire signed [width_p+2:0] CFL_0_10;
	wire signed [width_p+2:0] CFL_0_11;
	wire signed [width_p+2:0] CFL_0_12;
	wire signed [width_p+2:0] CFL_0_13;
	wire signed [width_p+2:0] CFL_0_14;
	wire signed [width_p+2:0] CFL_0_15;
	
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
		
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_0_0),
		.CFL_01_o(CFL_0_1),
		.CFL_02_o(CFL_0_2),
		.CFL_03_o(CFL_0_3),
		.CFL_04_o(CFL_0_4),
		.CFL_05_o(CFL_0_5),
		.CFL_06_o(CFL_0_6),
		.CFL_07_o(CFL_0_7),
		.CFL_08_o(CFL_0_8),
		.CFL_09_o(CFL_0_9),
		.CFL_10_o(CFL_0_10),
		.CFL_11_o(CFL_0_11),
		.CFL_12_o(CFL_0_12),
		.CFL_13_o(CFL_0_13),
		.CFL_14_o(CFL_0_14),
		.CFL_15_o(CFL_0_15)
		
    );

	// --------------- index = 1 --------------- //
	
	wire [4:0] alpha_index_1 = 1; 
	wire alpha_sign_1_pos  = 0;
	wire alpha_sign_1_neg  = 1;

	assign alpha_index_1 = 1; 
	assign alpha_sign_1_pos  = 0;
	assign alpha_sign_1_neg  = 1;

	wire signed [width_p+2:0] CFL_1_0_pos;	
	wire signed [width_p+2:0] CFL_1_1_pos;
	wire signed [width_p+2:0] CFL_1_2_pos;
	wire signed [width_p+2:0] CFL_1_3_pos;
	wire signed [width_p+2:0] CFL_1_4_pos;
	wire signed [width_p+2:0] CFL_1_5_pos;
	wire signed [width_p+2:0] CFL_1_6_pos;
	wire signed [width_p+2:0] CFL_1_7_pos;
	wire signed [width_p+2:0] CFL_1_8_pos;
	wire signed [width_p+2:0] CFL_1_9_pos;
	wire signed [width_p+2:0] CFL_1_10_pos;
	wire signed [width_p+2:0] CFL_1_11_pos;
	wire signed [width_p+2:0] CFL_1_12_pos;
	wire signed [width_p+2:0] CFL_1_13_pos;
	wire signed [width_p+2:0] CFL_1_14_pos;
	wire signed [width_p+2:0] CFL_1_15_pos;

	wire signed [width_p+2:0] CFL_1_0_neg;	
	wire signed [width_p+2:0] CFL_1_1_neg;
	wire signed [width_p+2:0] CFL_1_2_neg;
	wire signed [width_p+2:0] CFL_1_3_neg;
	wire signed [width_p+2:0] CFL_1_4_neg;
	wire signed [width_p+2:0] CFL_1_5_neg;
	wire signed [width_p+2:0] CFL_1_6_neg;
	wire signed [width_p+2:0] CFL_1_7_neg;
	wire signed [width_p+2:0] CFL_1_8_neg;
	wire signed [width_p+2:0] CFL_1_9_neg;
	wire signed [width_p+2:0] CFL_1_10_neg;
	wire signed [width_p+2:0] CFL_1_11_neg;
	wire signed [width_p+2:0] CFL_1_12_neg;
	wire signed [width_p+2:0] CFL_1_13_neg;
	wire signed [width_p+2:0] CFL_1_14_neg;
	wire signed [width_p+2:0] CFL_1_15_neg;

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_1_pos 
	(
		.alpha_sign(alpha_sign_1_pos),
		.alpha_index(alpha_index_1),
		
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_1_0_pos),
		.CFL_01_o(CFL_1_1_pos),
		.CFL_02_o(CFL_1_2_pos),
		.CFL_03_o(CFL_1_3_pos),
		.CFL_04_o(CFL_1_4_pos),
		.CFL_05_o(CFL_1_5_pos),
		.CFL_06_o(CFL_1_6_pos),
		.CFL_07_o(CFL_1_7_pos),
		.CFL_08_o(CFL_1_8_pos),
		.CFL_09_o(CFL_1_9_pos),
		.CFL_10_o(CFL_1_10_pos),
		.CFL_11_o(CFL_1_11_pos),
		.CFL_12_o(CFL_1_12_pos),
		.CFL_13_o(CFL_1_13_pos),
		.CFL_14_o(CFL_1_14_pos),
		.CFL_15_o(CFL_1_15_pos)

    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_1_neg 
	(
		.alpha_sign(alpha_sign_1_neg),
		.alpha_index(alpha_index_1),
		
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),
		
		.CFL_00_o(CFL_1_0_neg),
		.CFL_01_o(CFL_1_1_neg),
		.CFL_02_o(CFL_1_2_neg),
		.CFL_03_o(CFL_1_3_neg),
		.CFL_04_o(CFL_1_4_neg),
		.CFL_05_o(CFL_1_5_neg),
		.CFL_06_o(CFL_1_6_neg),
		.CFL_07_o(CFL_1_7_neg),
		.CFL_08_o(CFL_1_8_neg),
		.CFL_09_o(CFL_1_9_neg),
		.CFL_10_o(CFL_1_10_neg),
		.CFL_11_o(CFL_1_11_neg),
		.CFL_12_o(CFL_1_12_neg),
		.CFL_13_o(CFL_1_13_neg),
		.CFL_14_o(CFL_1_14_neg),
		.CFL_15_o(CFL_1_15_neg)	

    );	
	
	// --------------- index = 2 --------------- //	

	wire [4:0] alpha_index_2 = 2; 
	wire alpha_sign_2_pos  = 0;
	wire alpha_sign_2_neg  = 1;

	assign alpha_index_2 = 2; 
	assign alpha_sign_2_pos  = 0;
	assign alpha_sign_2_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_2_0_pos;	
	wire signed [width_p+2:0] CFL_2_1_pos;
	wire signed [width_p+2:0] CFL_2_2_pos;
	wire signed [width_p+2:0] CFL_2_3_pos;
	wire signed [width_p+2:0] CFL_2_4_pos;
	wire signed [width_p+2:0] CFL_2_5_pos;
	wire signed [width_p+2:0] CFL_2_6_pos;
	wire signed [width_p+2:0] CFL_2_7_pos;
	wire signed [width_p+2:0] CFL_2_8_pos;
	wire signed [width_p+2:0] CFL_2_9_pos;
	wire signed [width_p+2:0] CFL_2_10_pos;
	wire signed [width_p+2:0] CFL_2_11_pos;
	wire signed [width_p+2:0] CFL_2_12_pos;
	wire signed [width_p+2:0] CFL_2_13_pos;
	wire signed [width_p+2:0] CFL_2_14_pos;
	wire signed [width_p+2:0] CFL_2_15_pos;

	wire signed [width_p+2:0] CFL_2_0_neg;	
	wire signed [width_p+2:0] CFL_2_1_neg;
	wire signed [width_p+2:0] CFL_2_2_neg;
	wire signed [width_p+2:0] CFL_2_3_neg;
	wire signed [width_p+2:0] CFL_2_4_neg;
	wire signed [width_p+2:0] CFL_2_5_neg;
	wire signed [width_p+2:0] CFL_2_6_neg;
	wire signed [width_p+2:0] CFL_2_7_neg;
	wire signed [width_p+2:0] CFL_2_8_neg;
	wire signed [width_p+2:0] CFL_2_9_neg;
	wire signed [width_p+2:0] CFL_2_10_neg;
	wire signed [width_p+2:0] CFL_2_11_neg;
	wire signed [width_p+2:0] CFL_2_12_neg;
	wire signed [width_p+2:0] CFL_2_13_neg;
	wire signed [width_p+2:0] CFL_2_14_neg;
	wire signed [width_p+2:0] CFL_2_15_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_2_pos 
	(
		.alpha_sign(alpha_sign_2_pos),
		.alpha_index(alpha_index_2),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_2_0_pos),
		.CFL_01_o(CFL_2_1_pos),
		.CFL_02_o(CFL_2_2_pos),
		.CFL_03_o(CFL_2_3_pos),
		.CFL_04_o(CFL_2_4_pos),
		.CFL_05_o(CFL_2_5_pos),
		.CFL_06_o(CFL_2_6_pos),
		.CFL_07_o(CFL_2_7_pos),
		.CFL_08_o(CFL_2_8_pos),
		.CFL_09_o(CFL_2_9_pos),
		.CFL_10_o(CFL_2_10_pos),
		.CFL_11_o(CFL_2_11_pos),
		.CFL_12_o(CFL_2_12_pos),
		.CFL_13_o(CFL_2_13_pos),
		.CFL_14_o(CFL_2_14_pos),
		.CFL_15_o(CFL_2_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_2_neg 
	(
		.alpha_sign(alpha_sign_2_neg),
		.alpha_index(alpha_index_2),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_2_0_neg),
		.CFL_01_o(CFL_2_1_neg),
		.CFL_02_o(CFL_2_2_neg),
		.CFL_03_o(CFL_2_3_neg),
		.CFL_04_o(CFL_2_4_neg),
		.CFL_05_o(CFL_2_5_neg),
		.CFL_06_o(CFL_2_6_neg),
		.CFL_07_o(CFL_2_7_neg),
		.CFL_08_o(CFL_2_8_neg),
		.CFL_09_o(CFL_2_9_neg),
		.CFL_10_o(CFL_2_10_neg),
		.CFL_11_o(CFL_2_11_neg),
		.CFL_12_o(CFL_2_12_neg),
		.CFL_13_o(CFL_2_13_neg),
		.CFL_14_o(CFL_2_14_neg),
		.CFL_15_o(CFL_2_15_neg)
    );		
	
	// --------------- index = 3 --------------- //	

	wire [4:0] alpha_index_3 = 3; 
	wire alpha_sign_3_pos  = 0;
	wire alpha_sign_3_neg  = 1;

	assign alpha_index_3 = 3; 
	assign alpha_sign_3_pos  = 0;
	assign alpha_sign_3_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_3_0_pos;	
	wire signed [width_p+2:0] CFL_3_1_pos;
	wire signed [width_p+2:0] CFL_3_2_pos;
	wire signed [width_p+2:0] CFL_3_3_pos;
	wire signed [width_p+2:0] CFL_3_4_pos;
	wire signed [width_p+2:0] CFL_3_5_pos;
	wire signed [width_p+2:0] CFL_3_6_pos;
	wire signed [width_p+2:0] CFL_3_7_pos;
	wire signed [width_p+2:0] CFL_3_8_pos;
	wire signed [width_p+2:0] CFL_3_9_pos;
	wire signed [width_p+2:0] CFL_3_10_pos;
	wire signed [width_p+2:0] CFL_3_11_pos;
	wire signed [width_p+2:0] CFL_3_12_pos;
	wire signed [width_p+2:0] CFL_3_13_pos;
	wire signed [width_p+2:0] CFL_3_14_pos;
	wire signed [width_p+2:0] CFL_3_15_pos;

	wire signed [width_p+2:0] CFL_3_0_neg;	
	wire signed [width_p+2:0] CFL_3_1_neg;
	wire signed [width_p+2:0] CFL_3_2_neg;
	wire signed [width_p+2:0] CFL_3_3_neg;
	wire signed [width_p+2:0] CFL_3_4_neg;
	wire signed [width_p+2:0] CFL_3_5_neg;
	wire signed [width_p+2:0] CFL_3_6_neg;
	wire signed [width_p+2:0] CFL_3_7_neg;
	wire signed [width_p+2:0] CFL_3_8_neg;
	wire signed [width_p+2:0] CFL_3_9_neg;
	wire signed [width_p+2:0] CFL_3_10_neg;
	wire signed [width_p+2:0] CFL_3_11_neg;
	wire signed [width_p+2:0] CFL_3_12_neg;
	wire signed [width_p+2:0] CFL_3_13_neg;
	wire signed [width_p+2:0] CFL_3_14_neg;
	wire signed [width_p+2:0] CFL_3_15_neg;		

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_3_pos 
	(
		.alpha_sign(alpha_sign_3_pos),
		.alpha_index(alpha_index_3),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_3_0_pos),
		.CFL_01_o(CFL_3_1_pos),
		.CFL_02_o(CFL_3_2_pos),
		.CFL_03_o(CFL_3_3_pos),
		.CFL_04_o(CFL_3_4_pos),
		.CFL_05_o(CFL_3_5_pos),
		.CFL_06_o(CFL_3_6_pos),
		.CFL_07_o(CFL_3_7_pos),
		.CFL_08_o(CFL_3_8_pos),
		.CFL_09_o(CFL_3_9_pos),
		.CFL_10_o(CFL_3_10_pos),
		.CFL_11_o(CFL_3_11_pos),
		.CFL_12_o(CFL_3_12_pos),
		.CFL_13_o(CFL_3_13_pos),
		.CFL_14_o(CFL_3_14_pos),
		.CFL_15_o(CFL_3_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_3_neg 
	(
		.alpha_sign(alpha_sign_3_neg),
		.alpha_index(alpha_index_3),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_3_0_neg),
		.CFL_01_o(CFL_3_1_neg),
		.CFL_02_o(CFL_3_2_neg),
		.CFL_03_o(CFL_3_3_neg),
		.CFL_04_o(CFL_3_4_neg),
		.CFL_05_o(CFL_3_5_neg),
		.CFL_06_o(CFL_3_6_neg),
		.CFL_07_o(CFL_3_7_neg),
		.CFL_08_o(CFL_3_8_neg),
		.CFL_09_o(CFL_3_9_neg),
		.CFL_10_o(CFL_3_10_neg),
		.CFL_11_o(CFL_3_11_neg),
		.CFL_12_o(CFL_3_12_neg),
		.CFL_13_o(CFL_3_13_neg),
		.CFL_14_o(CFL_3_14_neg),
		.CFL_15_o(CFL_3_15_neg)
    );			

	// --------------- index = 4 --------------- //	

	wire [4:0] alpha_index_4 = 4; 
	wire alpha_sign_4_pos  = 0;
	wire alpha_sign_4_neg  = 1;

	assign alpha_index_4 = 4; 
	assign alpha_sign_4_pos  = 0;
	assign alpha_sign_4_neg  = 1;

	wire signed [width_p+2:0] CFL_4_0_pos;	
	wire signed [width_p+2:0] CFL_4_1_pos;
	wire signed [width_p+2:0] CFL_4_2_pos;
	wire signed [width_p+2:0] CFL_4_3_pos;
	wire signed [width_p+2:0] CFL_4_4_pos;
	wire signed [width_p+2:0] CFL_4_5_pos;
	wire signed [width_p+2:0] CFL_4_6_pos;
	wire signed [width_p+2:0] CFL_4_7_pos;
	wire signed [width_p+2:0] CFL_4_8_pos;
	wire signed [width_p+2:0] CFL_4_9_pos;
	wire signed [width_p+2:0] CFL_4_10_pos;
	wire signed [width_p+2:0] CFL_4_11_pos;
	wire signed [width_p+2:0] CFL_4_12_pos;
	wire signed [width_p+2:0] CFL_4_13_pos;
	wire signed [width_p+2:0] CFL_4_14_pos;
	wire signed [width_p+2:0] CFL_4_15_pos;

	wire signed [width_p+2:0] CFL_4_0_neg;	
	wire signed [width_p+2:0] CFL_4_1_neg;
	wire signed [width_p+2:0] CFL_4_2_neg;
	wire signed [width_p+2:0] CFL_4_3_neg;
	wire signed [width_p+2:0] CFL_4_4_neg;
	wire signed [width_p+2:0] CFL_4_5_neg;
	wire signed [width_p+2:0] CFL_4_6_neg;
	wire signed [width_p+2:0] CFL_4_7_neg;
	wire signed [width_p+2:0] CFL_4_8_neg;
	wire signed [width_p+2:0] CFL_4_9_neg;
	wire signed [width_p+2:0] CFL_4_10_neg;
	wire signed [width_p+2:0] CFL_4_11_neg;
	wire signed [width_p+2:0] CFL_4_12_neg;
	wire signed [width_p+2:0] CFL_4_13_neg;
	wire signed [width_p+2:0] CFL_4_14_neg;
	wire signed [width_p+2:0] CFL_4_15_neg;		

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_4_pos 
	(
		.alpha_sign(alpha_sign_4_pos),
		.alpha_index(alpha_index_4),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_4_0_pos),
		.CFL_01_o(CFL_4_1_pos),
		.CFL_02_o(CFL_4_2_pos),
		.CFL_03_o(CFL_4_3_pos),
		.CFL_04_o(CFL_4_4_pos),
		.CFL_05_o(CFL_4_5_pos),
		.CFL_06_o(CFL_4_6_pos),
		.CFL_07_o(CFL_4_7_pos),
		.CFL_08_o(CFL_4_8_pos),
		.CFL_09_o(CFL_4_9_pos),
		.CFL_10_o(CFL_4_10_pos),
		.CFL_11_o(CFL_4_11_pos),
		.CFL_12_o(CFL_4_12_pos),
		.CFL_13_o(CFL_4_13_pos),
		.CFL_14_o(CFL_4_14_pos),
		.CFL_15_o(CFL_4_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_4_neg 
	(
		.alpha_sign(alpha_sign_4_neg),
		.alpha_index(alpha_index_4),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_4_0_neg),
		.CFL_01_o(CFL_4_1_neg),
		.CFL_02_o(CFL_4_2_neg),
		.CFL_03_o(CFL_4_3_neg),
		.CFL_04_o(CFL_4_4_neg),
		.CFL_05_o(CFL_4_5_neg),
		.CFL_06_o(CFL_4_6_neg),
		.CFL_07_o(CFL_4_7_neg),
		.CFL_08_o(CFL_4_8_neg),
		.CFL_09_o(CFL_4_9_neg),
		.CFL_10_o(CFL_4_10_neg),
		.CFL_11_o(CFL_4_11_neg),
		.CFL_12_o(CFL_4_12_neg),
		.CFL_13_o(CFL_4_13_neg),
		.CFL_14_o(CFL_4_14_neg),
		.CFL_15_o(CFL_4_15_neg)
    );		

	// --------------- index = 5 --------------- //	

	wire [4:0] alpha_index_5 = 5; 
	wire alpha_sign_5_pos  = 0;
	wire alpha_sign_5_neg  = 1;
	
	assign alpha_index_5 = 5; 
	assign alpha_sign_5_pos  = 0;
	assign alpha_sign_5_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_5_0_pos;	
	wire signed [width_p+2:0] CFL_5_1_pos;
	wire signed [width_p+2:0] CFL_5_2_pos;
	wire signed [width_p+2:0] CFL_5_3_pos;
	wire signed [width_p+2:0] CFL_5_4_pos;
	wire signed [width_p+2:0] CFL_5_5_pos;
	wire signed [width_p+2:0] CFL_5_6_pos;
	wire signed [width_p+2:0] CFL_5_7_pos;
	wire signed [width_p+2:0] CFL_5_8_pos;
	wire signed [width_p+2:0] CFL_5_9_pos;
	wire signed [width_p+2:0] CFL_5_10_pos;
	wire signed [width_p+2:0] CFL_5_11_pos;
	wire signed [width_p+2:0] CFL_5_12_pos;
	wire signed [width_p+2:0] CFL_5_13_pos;
	wire signed [width_p+2:0] CFL_5_14_pos;
	wire signed [width_p+2:0] CFL_5_15_pos;

	wire signed [width_p+2:0] CFL_5_0_neg;	
	wire signed [width_p+2:0] CFL_5_1_neg;
	wire signed [width_p+2:0] CFL_5_2_neg;
	wire signed [width_p+2:0] CFL_5_3_neg;
	wire signed [width_p+2:0] CFL_5_4_neg;
	wire signed [width_p+2:0] CFL_5_5_neg;
	wire signed [width_p+2:0] CFL_5_6_neg;
	wire signed [width_p+2:0] CFL_5_7_neg;
	wire signed [width_p+2:0] CFL_5_8_neg;
	wire signed [width_p+2:0] CFL_5_9_neg;
	wire signed [width_p+2:0] CFL_5_10_neg;
	wire signed [width_p+2:0] CFL_5_11_neg;
	wire signed [width_p+2:0] CFL_5_12_neg;
	wire signed [width_p+2:0] CFL_5_13_neg;
	wire signed [width_p+2:0] CFL_5_14_neg;
	wire signed [width_p+2:0] CFL_5_15_neg;			

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_5_pos 
	(
		.alpha_sign(alpha_sign_5_pos),
		.alpha_index(alpha_index_5),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_5_0_pos),
		.CFL_01_o(CFL_5_1_pos),
		.CFL_02_o(CFL_5_2_pos),
		.CFL_03_o(CFL_5_3_pos),
		.CFL_04_o(CFL_5_4_pos),
		.CFL_05_o(CFL_5_5_pos),
		.CFL_06_o(CFL_5_6_pos),
		.CFL_07_o(CFL_5_7_pos),
		.CFL_08_o(CFL_5_8_pos),
		.CFL_09_o(CFL_5_9_pos),
		.CFL_10_o(CFL_5_10_pos),
		.CFL_11_o(CFL_5_11_pos),
		.CFL_12_o(CFL_5_12_pos),
		.CFL_13_o(CFL_5_13_pos),
		.CFL_14_o(CFL_5_14_pos),
		.CFL_15_o(CFL_5_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_5_neg 
	(
		.alpha_sign(alpha_sign_5_neg),
		.alpha_index(alpha_index_5),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_5_0_neg),
		.CFL_01_o(CFL_5_1_neg),
		.CFL_02_o(CFL_5_2_neg),
		.CFL_03_o(CFL_5_3_neg),
		.CFL_04_o(CFL_5_4_neg),
		.CFL_05_o(CFL_5_5_neg),
		.CFL_06_o(CFL_5_6_neg),
		.CFL_07_o(CFL_5_7_neg),
		.CFL_08_o(CFL_5_8_neg),
		.CFL_09_o(CFL_5_9_neg),
		.CFL_10_o(CFL_5_10_neg),
		.CFL_11_o(CFL_5_11_neg),
		.CFL_12_o(CFL_5_12_neg),
		.CFL_13_o(CFL_5_13_neg),
		.CFL_14_o(CFL_5_14_neg),
		.CFL_15_o(CFL_5_15_neg)
    );	

	// --------------- index = 6 --------------- //	

	wire [4:0] alpha_index_6 = 6; 
	wire alpha_sign_6_pos  = 0;
	wire alpha_sign_6_neg  = 1;
	
	assign alpha_index_6 = 6; 
	assign alpha_sign_6_pos  = 0;
	assign alpha_sign_6_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_6_0_pos;	
	wire signed [width_p+2:0] CFL_6_1_pos;
	wire signed [width_p+2:0] CFL_6_2_pos;
	wire signed [width_p+2:0] CFL_6_3_pos;
	wire signed [width_p+2:0] CFL_6_4_pos;
	wire signed [width_p+2:0] CFL_6_5_pos;
	wire signed [width_p+2:0] CFL_6_6_pos;
	wire signed [width_p+2:0] CFL_6_7_pos;
	wire signed [width_p+2:0] CFL_6_8_pos;
	wire signed [width_p+2:0] CFL_6_9_pos;
	wire signed [width_p+2:0] CFL_6_10_pos;
	wire signed [width_p+2:0] CFL_6_11_pos;
	wire signed [width_p+2:0] CFL_6_12_pos;
	wire signed [width_p+2:0] CFL_6_13_pos;
	wire signed [width_p+2:0] CFL_6_14_pos;
	wire signed [width_p+2:0] CFL_6_15_pos;

	wire signed [width_p+2:0] CFL_6_0_neg;	
	wire signed [width_p+2:0] CFL_6_1_neg;
	wire signed [width_p+2:0] CFL_6_2_neg;
	wire signed [width_p+2:0] CFL_6_3_neg;
	wire signed [width_p+2:0] CFL_6_4_neg;
	wire signed [width_p+2:0] CFL_6_5_neg;
	wire signed [width_p+2:0] CFL_6_6_neg;
	wire signed [width_p+2:0] CFL_6_7_neg;
	wire signed [width_p+2:0] CFL_6_8_neg;
	wire signed [width_p+2:0] CFL_6_9_neg;
	wire signed [width_p+2:0] CFL_6_10_neg;
	wire signed [width_p+2:0] CFL_6_11_neg;
	wire signed [width_p+2:0] CFL_6_12_neg;
	wire signed [width_p+2:0] CFL_6_13_neg;
	wire signed [width_p+2:0] CFL_6_14_neg;
	wire signed [width_p+2:0] CFL_6_15_neg;		

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_6_pos 
	(
		.alpha_sign(alpha_sign_6_pos),
		.alpha_index(alpha_index_6),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_6_0_pos),
		.CFL_01_o(CFL_6_1_pos),
		.CFL_02_o(CFL_6_2_pos),
		.CFL_03_o(CFL_6_3_pos),
		.CFL_04_o(CFL_6_4_pos),
		.CFL_05_o(CFL_6_5_pos),
		.CFL_06_o(CFL_6_6_pos),
		.CFL_07_o(CFL_6_7_pos),
		.CFL_08_o(CFL_6_8_pos),
		.CFL_09_o(CFL_6_9_pos),
		.CFL_10_o(CFL_6_10_pos),
		.CFL_11_o(CFL_6_11_pos),
		.CFL_12_o(CFL_6_12_pos),
		.CFL_13_o(CFL_6_13_pos),
		.CFL_14_o(CFL_6_14_pos),
		.CFL_15_o(CFL_6_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_6_neg 
	(
		.alpha_sign(alpha_sign_6_neg),
		.alpha_index(alpha_index_6),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_6_0_neg),
		.CFL_01_o(CFL_6_1_neg),
		.CFL_02_o(CFL_6_2_neg),
		.CFL_03_o(CFL_6_3_neg),
		.CFL_04_o(CFL_6_4_neg),
		.CFL_05_o(CFL_6_5_neg),
		.CFL_06_o(CFL_6_6_neg),
		.CFL_07_o(CFL_6_7_neg),
		.CFL_08_o(CFL_6_8_neg),
		.CFL_09_o(CFL_6_9_neg),
		.CFL_10_o(CFL_6_10_neg),
		.CFL_11_o(CFL_6_11_neg),
		.CFL_12_o(CFL_6_12_neg),
		.CFL_13_o(CFL_6_13_neg),
		.CFL_14_o(CFL_6_14_neg),
		.CFL_15_o(CFL_6_15_neg)
    );	

	// --------------- index = 7 --------------- //	

	wire [4:0] alpha_index_7 = 7; 
	wire alpha_sign_7_pos  = 0;
	wire alpha_sign_7_neg  = 1;
	
	assign alpha_index_7 = 7; 
	assign alpha_sign_7_pos  = 0;
	assign alpha_sign_7_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_7_0_pos;	
	wire signed [width_p+2:0] CFL_7_1_pos;
	wire signed [width_p+2:0] CFL_7_2_pos;
	wire signed [width_p+2:0] CFL_7_3_pos;
	wire signed [width_p+2:0] CFL_7_4_pos;
	wire signed [width_p+2:0] CFL_7_5_pos;
	wire signed [width_p+2:0] CFL_7_6_pos;
	wire signed [width_p+2:0] CFL_7_7_pos;
	wire signed [width_p+2:0] CFL_7_8_pos;
	wire signed [width_p+2:0] CFL_7_9_pos;
	wire signed [width_p+2:0] CFL_7_10_pos;
	wire signed [width_p+2:0] CFL_7_11_pos;
	wire signed [width_p+2:0] CFL_7_12_pos;
	wire signed [width_p+2:0] CFL_7_13_pos;
	wire signed [width_p+2:0] CFL_7_14_pos;
	wire signed [width_p+2:0] CFL_7_15_pos;

	wire signed [width_p+2:0] CFL_7_0_neg;	
	wire signed [width_p+2:0] CFL_7_1_neg;
	wire signed [width_p+2:0] CFL_7_2_neg;
	wire signed [width_p+2:0] CFL_7_3_neg;
	wire signed [width_p+2:0] CFL_7_4_neg;
	wire signed [width_p+2:0] CFL_7_5_neg;
	wire signed [width_p+2:0] CFL_7_6_neg;
	wire signed [width_p+2:0] CFL_7_7_neg;
	wire signed [width_p+2:0] CFL_7_8_neg;
	wire signed [width_p+2:0] CFL_7_9_neg;
	wire signed [width_p+2:0] CFL_7_10_neg;
	wire signed [width_p+2:0] CFL_7_11_neg;
	wire signed [width_p+2:0] CFL_7_12_neg;
	wire signed [width_p+2:0] CFL_7_13_neg;
	wire signed [width_p+2:0] CFL_7_14_neg;
	wire signed [width_p+2:0] CFL_7_15_neg;		

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_7_pos 
	(
		.alpha_sign(alpha_sign_7_pos),
		.alpha_index(alpha_index_7),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_7_0_pos),
		.CFL_01_o(CFL_7_1_pos),
		.CFL_02_o(CFL_7_2_pos),
		.CFL_03_o(CFL_7_3_pos),
		.CFL_04_o(CFL_7_4_pos),
		.CFL_05_o(CFL_7_5_pos),
		.CFL_06_o(CFL_7_6_pos),
		.CFL_07_o(CFL_7_7_pos),
		.CFL_08_o(CFL_7_8_pos),
		.CFL_09_o(CFL_7_9_pos),
		.CFL_10_o(CFL_7_10_pos),
		.CFL_11_o(CFL_7_11_pos),
		.CFL_12_o(CFL_7_12_pos),
		.CFL_13_o(CFL_7_13_pos),
		.CFL_14_o(CFL_7_14_pos),
		.CFL_15_o(CFL_7_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_7_neg 
	(
		.alpha_sign(alpha_sign_7_neg),
		.alpha_index(alpha_index_7),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_7_0_neg),
		.CFL_01_o(CFL_7_1_neg),
		.CFL_02_o(CFL_7_2_neg),
		.CFL_03_o(CFL_7_3_neg),
		.CFL_04_o(CFL_7_4_neg),
		.CFL_05_o(CFL_7_5_neg),
		.CFL_06_o(CFL_7_6_neg),
		.CFL_07_o(CFL_7_7_neg),
		.CFL_08_o(CFL_7_8_neg),
		.CFL_09_o(CFL_7_9_neg),
		.CFL_10_o(CFL_7_10_neg),
		.CFL_11_o(CFL_7_11_neg),
		.CFL_12_o(CFL_7_12_neg),
		.CFL_13_o(CFL_7_13_neg),
		.CFL_14_o(CFL_7_14_neg),
		.CFL_15_o(CFL_7_15_neg)
    );	

	// --------------- index = 8 --------------- //	

	wire [4:0] alpha_index_8 = 8; 
	wire alpha_sign_8_pos  = 0;
	wire alpha_sign_8_neg  = 1;

	assign alpha_index_8 = 8; 
	assign alpha_sign_8_pos  = 0;
	assign alpha_sign_8_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_8_0_pos;	
	wire signed [width_p+2:0] CFL_8_1_pos;
	wire signed [width_p+2:0] CFL_8_2_pos;
	wire signed [width_p+2:0] CFL_8_3_pos;
	wire signed [width_p+2:0] CFL_8_4_pos;
	wire signed [width_p+2:0] CFL_8_5_pos;
	wire signed [width_p+2:0] CFL_8_6_pos;
	wire signed [width_p+2:0] CFL_8_7_pos;
	wire signed [width_p+2:0] CFL_8_8_pos;
	wire signed [width_p+2:0] CFL_8_9_pos;
	wire signed [width_p+2:0] CFL_8_10_pos;
	wire signed [width_p+2:0] CFL_8_11_pos;
	wire signed [width_p+2:0] CFL_8_12_pos;
	wire signed [width_p+2:0] CFL_8_13_pos;
	wire signed [width_p+2:0] CFL_8_14_pos;
	wire signed [width_p+2:0] CFL_8_15_pos;

	wire signed [width_p+2:0] CFL_8_0_neg;	
	wire signed [width_p+2:0] CFL_8_1_neg;
	wire signed [width_p+2:0] CFL_8_2_neg;
	wire signed [width_p+2:0] CFL_8_3_neg;
	wire signed [width_p+2:0] CFL_8_4_neg;
	wire signed [width_p+2:0] CFL_8_5_neg;
	wire signed [width_p+2:0] CFL_8_6_neg;
	wire signed [width_p+2:0] CFL_8_7_neg;
	wire signed [width_p+2:0] CFL_8_8_neg;
	wire signed [width_p+2:0] CFL_8_9_neg;
	wire signed [width_p+2:0] CFL_8_10_neg;
	wire signed [width_p+2:0] CFL_8_11_neg;
	wire signed [width_p+2:0] CFL_8_12_neg;
	wire signed [width_p+2:0] CFL_8_13_neg;
	wire signed [width_p+2:0] CFL_8_14_neg;
	wire signed [width_p+2:0] CFL_8_15_neg;		

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_8_pos 
	(
		.alpha_sign(alpha_sign_8_pos),
		.alpha_index(alpha_index_8),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_8_0_pos),
		.CFL_01_o(CFL_8_1_pos),
		.CFL_02_o(CFL_8_2_pos),
		.CFL_03_o(CFL_8_3_pos),
		.CFL_04_o(CFL_8_4_pos),
		.CFL_05_o(CFL_8_5_pos),
		.CFL_06_o(CFL_8_6_pos),
		.CFL_07_o(CFL_8_7_pos),
		.CFL_08_o(CFL_8_8_pos),
		.CFL_09_o(CFL_8_9_pos),
		.CFL_10_o(CFL_8_10_pos),
		.CFL_11_o(CFL_8_11_pos),
		.CFL_12_o(CFL_8_12_pos),
		.CFL_13_o(CFL_8_13_pos),
		.CFL_14_o(CFL_8_14_pos),
		.CFL_15_o(CFL_8_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_8_neg 
	(
		.alpha_sign(alpha_sign_8_neg),
		.alpha_index(alpha_index_8),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_8_0_neg),
		.CFL_01_o(CFL_8_1_neg),
		.CFL_02_o(CFL_8_2_neg),
		.CFL_03_o(CFL_8_3_neg),
		.CFL_04_o(CFL_8_4_neg),
		.CFL_05_o(CFL_8_5_neg),
		.CFL_06_o(CFL_8_6_neg),
		.CFL_07_o(CFL_8_7_neg),
		.CFL_08_o(CFL_8_8_neg),
		.CFL_09_o(CFL_8_9_neg),
		.CFL_10_o(CFL_8_10_neg),
		.CFL_11_o(CFL_8_11_neg),
		.CFL_12_o(CFL_8_12_neg),
		.CFL_13_o(CFL_8_13_neg),
		.CFL_14_o(CFL_8_14_neg),
		.CFL_15_o(CFL_8_15_neg)
    );	

	// --------------- index = 9 --------------- //	

	wire [4:0] alpha_index_9 = 9; 
	wire alpha_sign_9_pos  = 0;
	wire alpha_sign_9_neg  = 1;

	assign alpha_index_9 = 9; 
	assign alpha_sign_9_pos  = 0;
	assign alpha_sign_9_neg  = 1;

	wire signed [width_p+2:0] CFL_9_0_pos;	
	wire signed [width_p+2:0] CFL_9_1_pos;
	wire signed [width_p+2:0] CFL_9_2_pos;
	wire signed [width_p+2:0] CFL_9_3_pos;
	wire signed [width_p+2:0] CFL_9_4_pos;
	wire signed [width_p+2:0] CFL_9_5_pos;
	wire signed [width_p+2:0] CFL_9_6_pos;
	wire signed [width_p+2:0] CFL_9_7_pos;
	wire signed [width_p+2:0] CFL_9_8_pos;
	wire signed [width_p+2:0] CFL_9_9_pos;
	wire signed [width_p+2:0] CFL_9_10_pos;
	wire signed [width_p+2:0] CFL_9_11_pos;
	wire signed [width_p+2:0] CFL_9_12_pos;
	wire signed [width_p+2:0] CFL_9_13_pos;
	wire signed [width_p+2:0] CFL_9_14_pos;
	wire signed [width_p+2:0] CFL_9_15_pos;

	wire signed [width_p+2:0] CFL_9_0_neg;	
	wire signed [width_p+2:0] CFL_9_1_neg;
	wire signed [width_p+2:0] CFL_9_2_neg;
	wire signed [width_p+2:0] CFL_9_3_neg;
	wire signed [width_p+2:0] CFL_9_4_neg;
	wire signed [width_p+2:0] CFL_9_5_neg;
	wire signed [width_p+2:0] CFL_9_6_neg;
	wire signed [width_p+2:0] CFL_9_7_neg;
	wire signed [width_p+2:0] CFL_9_8_neg;
	wire signed [width_p+2:0] CFL_9_9_neg;
	wire signed [width_p+2:0] CFL_9_10_neg;
	wire signed [width_p+2:0] CFL_9_11_neg;
	wire signed [width_p+2:0] CFL_9_12_neg;
	wire signed [width_p+2:0] CFL_9_13_neg;
	wire signed [width_p+2:0] CFL_9_14_neg;
	wire signed [width_p+2:0] CFL_9_15_neg;		

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_9_pos 
	(
		.alpha_sign(alpha_sign_9_pos),
		.alpha_index(alpha_index_9),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_9_0_pos),
		.CFL_01_o(CFL_9_1_pos),
		.CFL_02_o(CFL_9_2_pos),
		.CFL_03_o(CFL_9_3_pos),
		.CFL_04_o(CFL_9_4_pos),
		.CFL_05_o(CFL_9_5_pos),
		.CFL_06_o(CFL_9_6_pos),
		.CFL_07_o(CFL_9_7_pos),
		.CFL_08_o(CFL_9_8_pos),
		.CFL_09_o(CFL_9_9_pos),
		.CFL_10_o(CFL_9_10_pos),
		.CFL_11_o(CFL_9_11_pos),
		.CFL_12_o(CFL_9_12_pos),
		.CFL_13_o(CFL_9_13_pos),
		.CFL_14_o(CFL_9_14_pos),
		.CFL_15_o(CFL_9_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_9_neg 
	(
		.alpha_sign(alpha_sign_9_neg),
		.alpha_index(alpha_index_9),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_9_0_neg),
		.CFL_01_o(CFL_9_1_neg),
		.CFL_02_o(CFL_9_2_neg),
		.CFL_03_o(CFL_9_3_neg),
		.CFL_04_o(CFL_9_4_neg),
		.CFL_05_o(CFL_9_5_neg),
		.CFL_06_o(CFL_9_6_neg),
		.CFL_07_o(CFL_9_7_neg),
		.CFL_08_o(CFL_9_8_neg),
		.CFL_09_o(CFL_9_9_neg),
		.CFL_10_o(CFL_9_10_neg),
		.CFL_11_o(CFL_9_11_neg),
		.CFL_12_o(CFL_9_12_neg),
		.CFL_13_o(CFL_9_13_neg),
		.CFL_14_o(CFL_9_14_neg),
		.CFL_15_o(CFL_9_15_neg)
    );

	// --------------- index = 10 --------------- //	

	wire [4:0] alpha_index_10 = 10; 
	wire alpha_sign_10_pos  = 0;
	wire alpha_sign_10_neg  = 1;

	assign alpha_index_10 = 10; 
	assign alpha_sign_10_pos  = 0;
	assign alpha_sign_10_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_10_0_pos;	
	wire signed [width_p+2:0] CFL_10_1_pos;
	wire signed [width_p+2:0] CFL_10_2_pos;
	wire signed [width_p+2:0] CFL_10_3_pos;
	wire signed [width_p+2:0] CFL_10_4_pos;
	wire signed [width_p+2:0] CFL_10_5_pos;
	wire signed [width_p+2:0] CFL_10_6_pos;
	wire signed [width_p+2:0] CFL_10_7_pos;
	wire signed [width_p+2:0] CFL_10_8_pos;
	wire signed [width_p+2:0] CFL_10_9_pos;
	wire signed [width_p+2:0] CFL_10_10_pos;
	wire signed [width_p+2:0] CFL_10_11_pos;
	wire signed [width_p+2:0] CFL_10_12_pos;
	wire signed [width_p+2:0] CFL_10_13_pos;
	wire signed [width_p+2:0] CFL_10_14_pos;
	wire signed [width_p+2:0] CFL_10_15_pos;

	wire signed [width_p+2:0] CFL_10_0_neg;	
	wire signed [width_p+2:0] CFL_10_1_neg;
	wire signed [width_p+2:0] CFL_10_2_neg;
	wire signed [width_p+2:0] CFL_10_3_neg;
	wire signed [width_p+2:0] CFL_10_4_neg;
	wire signed [width_p+2:0] CFL_10_5_neg;
	wire signed [width_p+2:0] CFL_10_6_neg;
	wire signed [width_p+2:0] CFL_10_7_neg;
	wire signed [width_p+2:0] CFL_10_8_neg;
	wire signed [width_p+2:0] CFL_10_9_neg;
	wire signed [width_p+2:0] CFL_10_10_neg;
	wire signed [width_p+2:0] CFL_10_11_neg;
	wire signed [width_p+2:0] CFL_10_12_neg;
	wire signed [width_p+2:0] CFL_10_13_neg;
	wire signed [width_p+2:0] CFL_10_14_neg;
	wire signed [width_p+2:0] CFL_10_15_neg;	
	
	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_10_pos 
	(
		.alpha_sign(alpha_sign_10_pos),
		.alpha_index(alpha_index_10),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_10_0_pos),
		.CFL_01_o(CFL_10_1_pos),
		.CFL_02_o(CFL_10_2_pos),
		.CFL_03_o(CFL_10_3_pos),
		.CFL_04_o(CFL_10_4_pos),
		.CFL_05_o(CFL_10_5_pos),
		.CFL_06_o(CFL_10_6_pos),
		.CFL_07_o(CFL_10_7_pos),
		.CFL_08_o(CFL_10_8_pos),
		.CFL_09_o(CFL_10_9_pos),
		.CFL_10_o(CFL_10_10_pos),
		.CFL_11_o(CFL_10_11_pos),
		.CFL_12_o(CFL_10_12_pos),
		.CFL_13_o(CFL_10_13_pos),
		.CFL_14_o(CFL_10_14_pos),
		.CFL_15_o(CFL_10_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_10_neg 
	(
		.alpha_sign(alpha_sign_10_neg),
		.alpha_index(alpha_index_10),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_10_0_neg),
		.CFL_01_o(CFL_10_1_neg),
		.CFL_02_o(CFL_10_2_neg),
		.CFL_03_o(CFL_10_3_neg),
		.CFL_04_o(CFL_10_4_neg),
		.CFL_05_o(CFL_10_5_neg),
		.CFL_06_o(CFL_10_6_neg),
		.CFL_07_o(CFL_10_7_neg),
		.CFL_08_o(CFL_10_8_neg),
		.CFL_09_o(CFL_10_9_neg),
		.CFL_10_o(CFL_10_10_neg),
		.CFL_11_o(CFL_10_11_neg),
		.CFL_12_o(CFL_10_12_neg),
		.CFL_13_o(CFL_10_13_neg),
		.CFL_14_o(CFL_10_14_neg),
		.CFL_15_o(CFL_10_15_neg)
    );

	// --------------- index = 11 --------------- //	

	wire [4:0] alpha_index_11 = 11; 
	wire alpha_sign_11_pos  = 0;
	wire alpha_sign_11_neg  = 1;

	assign alpha_index_11 	  = 11; 
	assign alpha_sign_11_pos  = 0;
	assign alpha_sign_11_neg  = 1;

	wire signed [width_p+2:0] CFL_11_0_pos;	
	wire signed [width_p+2:0] CFL_11_1_pos;
	wire signed [width_p+2:0] CFL_11_2_pos;
	wire signed [width_p+2:0] CFL_11_3_pos;
	wire signed [width_p+2:0] CFL_11_4_pos;
	wire signed [width_p+2:0] CFL_11_5_pos;
	wire signed [width_p+2:0] CFL_11_6_pos;
	wire signed [width_p+2:0] CFL_11_7_pos;
	wire signed [width_p+2:0] CFL_11_8_pos;
	wire signed [width_p+2:0] CFL_11_9_pos;
	wire signed [width_p+2:0] CFL_11_10_pos;
	wire signed [width_p+2:0] CFL_11_11_pos;
	wire signed [width_p+2:0] CFL_11_12_pos;
	wire signed [width_p+2:0] CFL_11_13_pos;
	wire signed [width_p+2:0] CFL_11_14_pos;
	wire signed [width_p+2:0] CFL_11_15_pos;

	wire signed [width_p+2:0] CFL_11_0_neg;	
	wire signed [width_p+2:0] CFL_11_1_neg;
	wire signed [width_p+2:0] CFL_11_2_neg;
	wire signed [width_p+2:0] CFL_11_3_neg;
	wire signed [width_p+2:0] CFL_11_4_neg;
	wire signed [width_p+2:0] CFL_11_5_neg;
	wire signed [width_p+2:0] CFL_11_6_neg;
	wire signed [width_p+2:0] CFL_11_7_neg;
	wire signed [width_p+2:0] CFL_11_8_neg;
	wire signed [width_p+2:0] CFL_11_9_neg;
	wire signed [width_p+2:0] CFL_11_10_neg;
	wire signed [width_p+2:0] CFL_11_11_neg;
	wire signed [width_p+2:0] CFL_11_12_neg;
	wire signed [width_p+2:0] CFL_11_13_neg;
	wire signed [width_p+2:0] CFL_11_14_neg;
	wire signed [width_p+2:0] CFL_11_15_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_11_pos 
	(
		.alpha_sign(alpha_sign_11_pos),
		.alpha_index(alpha_index_11),
		
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_11_0_pos),
		.CFL_01_o(CFL_11_1_pos),
		.CFL_02_o(CFL_11_2_pos),
		.CFL_03_o(CFL_11_3_pos),
		.CFL_04_o(CFL_11_4_pos),
		.CFL_05_o(CFL_11_5_pos),
		.CFL_06_o(CFL_11_6_pos),
		.CFL_07_o(CFL_11_7_pos),
		.CFL_08_o(CFL_11_8_pos),
		.CFL_09_o(CFL_11_9_pos),
		.CFL_10_o(CFL_11_10_pos),
		.CFL_11_o(CFL_11_11_pos),
		.CFL_12_o(CFL_11_12_pos),
		.CFL_13_o(CFL_11_13_pos),
		.CFL_14_o(CFL_11_14_pos),
		.CFL_15_o(CFL_11_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_11_neg 
	(
		.alpha_sign(alpha_sign_11_neg),
		.alpha_index(alpha_index_11),
		
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_11_0_neg),
		.CFL_01_o(CFL_11_1_neg),
		.CFL_02_o(CFL_11_2_neg),
		.CFL_03_o(CFL_11_3_neg),
		.CFL_04_o(CFL_11_4_neg),
		.CFL_05_o(CFL_11_5_neg),
		.CFL_06_o(CFL_11_6_neg),
		.CFL_07_o(CFL_11_7_neg),
		.CFL_08_o(CFL_11_8_neg),
		.CFL_09_o(CFL_11_9_neg),
		.CFL_10_o(CFL_11_10_neg),
		.CFL_11_o(CFL_11_11_neg),
		.CFL_12_o(CFL_11_12_neg),
		.CFL_13_o(CFL_11_13_neg),
		.CFL_14_o(CFL_11_14_neg),
		.CFL_15_o(CFL_11_15_neg)
    );

	// --------------- index = 12 --------------- //	

	wire [4:0] alpha_index_12 = 12; 
	wire alpha_sign_12_pos  = 0;
	wire alpha_sign_12_neg  = 1;
	
	assign alpha_index_12 	  = 12; 
	assign alpha_sign_12_pos  = 0;
	assign alpha_sign_12_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_12_0_pos;	
	wire signed [width_p+2:0] CFL_12_1_pos;
	wire signed [width_p+2:0] CFL_12_2_pos;
	wire signed [width_p+2:0] CFL_12_3_pos;
	wire signed [width_p+2:0] CFL_12_4_pos;
	wire signed [width_p+2:0] CFL_12_5_pos;
	wire signed [width_p+2:0] CFL_12_6_pos;
	wire signed [width_p+2:0] CFL_12_7_pos;
	wire signed [width_p+2:0] CFL_12_8_pos;
	wire signed [width_p+2:0] CFL_12_9_pos;
	wire signed [width_p+2:0] CFL_12_10_pos;
	wire signed [width_p+2:0] CFL_12_11_pos;
	wire signed [width_p+2:0] CFL_12_12_pos;
	wire signed [width_p+2:0] CFL_12_13_pos;
	wire signed [width_p+2:0] CFL_12_14_pos;
	wire signed [width_p+2:0] CFL_12_15_pos;

	wire signed [width_p+2:0] CFL_12_0_neg;	
	wire signed [width_p+2:0] CFL_12_1_neg;
	wire signed [width_p+2:0] CFL_12_2_neg;
	wire signed [width_p+2:0] CFL_12_3_neg;
	wire signed [width_p+2:0] CFL_12_4_neg;
	wire signed [width_p+2:0] CFL_12_5_neg;
	wire signed [width_p+2:0] CFL_12_6_neg;
	wire signed [width_p+2:0] CFL_12_7_neg;
	wire signed [width_p+2:0] CFL_12_8_neg;
	wire signed [width_p+2:0] CFL_12_9_neg;
	wire signed [width_p+2:0] CFL_12_10_neg;
	wire signed [width_p+2:0] CFL_12_11_neg;
	wire signed [width_p+2:0] CFL_12_12_neg;
	wire signed [width_p+2:0] CFL_12_13_neg;
	wire signed [width_p+2:0] CFL_12_14_neg;
	wire signed [width_p+2:0] CFL_12_15_neg;

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_12_pos 
	(
		.alpha_sign(alpha_sign_12_pos),
		.alpha_index(alpha_index_12),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_12_0_pos),
		.CFL_01_o(CFL_12_1_pos),
		.CFL_02_o(CFL_12_2_pos),
		.CFL_03_o(CFL_12_3_pos),
		.CFL_04_o(CFL_12_4_pos),
		.CFL_05_o(CFL_12_5_pos),
		.CFL_06_o(CFL_12_6_pos),
		.CFL_07_o(CFL_12_7_pos),
		.CFL_08_o(CFL_12_8_pos),
		.CFL_09_o(CFL_12_9_pos),
		.CFL_10_o(CFL_12_10_pos),
		.CFL_11_o(CFL_12_11_pos),
		.CFL_12_o(CFL_12_12_pos),
		.CFL_13_o(CFL_12_13_pos),
		.CFL_14_o(CFL_12_14_pos),
		.CFL_15_o(CFL_12_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_12_neg 
	(
		.alpha_sign(alpha_sign_12_neg),
		.alpha_index(alpha_index_12),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_12_0_neg),
		.CFL_01_o(CFL_12_1_neg),
		.CFL_02_o(CFL_12_2_neg),
		.CFL_03_o(CFL_12_3_neg),
		.CFL_04_o(CFL_12_4_neg),
		.CFL_05_o(CFL_12_5_neg),
		.CFL_06_o(CFL_12_6_neg),
		.CFL_07_o(CFL_12_7_neg),
		.CFL_08_o(CFL_12_8_neg),
		.CFL_09_o(CFL_12_9_neg),
		.CFL_10_o(CFL_12_10_neg),
		.CFL_11_o(CFL_12_11_neg),
		.CFL_12_o(CFL_12_12_neg),
		.CFL_13_o(CFL_12_13_neg),
		.CFL_14_o(CFL_12_14_neg),
		.CFL_15_o(CFL_12_15_neg)
    );

	// --------------- index = 13 --------------- //	

	wire [4:0] alpha_index_13 = 13; 
	wire alpha_sign_13_pos  = 0;
	wire alpha_sign_13_neg  = 1;

	assign alpha_index_13 = 13; 
	assign alpha_sign_13_pos  = 0;
	assign alpha_sign_13_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_13_0_pos;	
	wire signed [width_p+2:0] CFL_13_1_pos;
	wire signed [width_p+2:0] CFL_13_2_pos;
	wire signed [width_p+2:0] CFL_13_3_pos;
	wire signed [width_p+2:0] CFL_13_4_pos;
	wire signed [width_p+2:0] CFL_13_5_pos;
	wire signed [width_p+2:0] CFL_13_6_pos;
	wire signed [width_p+2:0] CFL_13_7_pos;
	wire signed [width_p+2:0] CFL_13_8_pos;
	wire signed [width_p+2:0] CFL_13_9_pos;
	wire signed [width_p+2:0] CFL_13_10_pos;
	wire signed [width_p+2:0] CFL_13_11_pos;
	wire signed [width_p+2:0] CFL_13_12_pos;
	wire signed [width_p+2:0] CFL_13_13_pos;
	wire signed [width_p+2:0] CFL_13_14_pos;
	wire signed [width_p+2:0] CFL_13_15_pos;

	wire signed [width_p+2:0] CFL_13_0_neg;	
	wire signed [width_p+2:0] CFL_13_1_neg;
	wire signed [width_p+2:0] CFL_13_2_neg;
	wire signed [width_p+2:0] CFL_13_3_neg;
	wire signed [width_p+2:0] CFL_13_4_neg;
	wire signed [width_p+2:0] CFL_13_5_neg;
	wire signed [width_p+2:0] CFL_13_6_neg;
	wire signed [width_p+2:0] CFL_13_7_neg;
	wire signed [width_p+2:0] CFL_13_8_neg;
	wire signed [width_p+2:0] CFL_13_9_neg;
	wire signed [width_p+2:0] CFL_13_10_neg;
	wire signed [width_p+2:0] CFL_13_11_neg;
	wire signed [width_p+2:0] CFL_13_12_neg;
	wire signed [width_p+2:0] CFL_13_13_neg;
	wire signed [width_p+2:0] CFL_13_14_neg;
	wire signed [width_p+2:0] CFL_13_15_neg;

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_13_pos 
	(
		.alpha_sign(alpha_sign_13_pos),
		.alpha_index(alpha_index_13),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_13_0_pos),
		.CFL_01_o(CFL_13_1_pos),
		.CFL_02_o(CFL_13_2_pos),
		.CFL_03_o(CFL_13_3_pos),
		.CFL_04_o(CFL_13_4_pos),
		.CFL_05_o(CFL_13_5_pos),
		.CFL_06_o(CFL_13_6_pos),
		.CFL_07_o(CFL_13_7_pos),
		.CFL_08_o(CFL_13_8_pos),
		.CFL_09_o(CFL_13_9_pos),
		.CFL_10_o(CFL_13_10_pos),
		.CFL_11_o(CFL_13_11_pos),
		.CFL_12_o(CFL_13_12_pos),
		.CFL_13_o(CFL_13_13_pos),
		.CFL_14_o(CFL_13_14_pos),
		.CFL_15_o(CFL_13_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_13_neg 
	(
		.alpha_sign(alpha_sign_13_neg),
		.alpha_index(alpha_index_13),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_13_0_neg),
		.CFL_01_o(CFL_13_1_neg),
		.CFL_02_o(CFL_13_2_neg),
		.CFL_03_o(CFL_13_3_neg),
		.CFL_04_o(CFL_13_4_neg),
		.CFL_05_o(CFL_13_5_neg),
		.CFL_06_o(CFL_13_6_neg),
		.CFL_07_o(CFL_13_7_neg),
		.CFL_08_o(CFL_13_8_neg),
		.CFL_09_o(CFL_13_9_neg),
		.CFL_10_o(CFL_13_10_neg),
		.CFL_11_o(CFL_13_11_neg),
		.CFL_12_o(CFL_13_12_neg),
		.CFL_13_o(CFL_13_13_neg),
		.CFL_14_o(CFL_13_14_neg),
		.CFL_15_o(CFL_13_15_neg)
    );

	// --------------- index = 14 --------------- //	

	wire [4:0] alpha_index_14 = 14; 
	wire alpha_sign_14_pos  = 0;
	wire alpha_sign_14_neg  = 1;

	assign alpha_index_14     = 14; 
	assign alpha_sign_14_pos  = 0;
	assign alpha_sign_14_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_14_0_pos;	
	wire signed [width_p+2:0] CFL_14_1_pos;
	wire signed [width_p+2:0] CFL_14_2_pos;
	wire signed [width_p+2:0] CFL_14_3_pos;
	wire signed [width_p+2:0] CFL_14_4_pos;
	wire signed [width_p+2:0] CFL_14_5_pos;
	wire signed [width_p+2:0] CFL_14_6_pos;
	wire signed [width_p+2:0] CFL_14_7_pos;
	wire signed [width_p+2:0] CFL_14_8_pos;
	wire signed [width_p+2:0] CFL_14_9_pos;
	wire signed [width_p+2:0] CFL_14_10_pos;
	wire signed [width_p+2:0] CFL_14_11_pos;
	wire signed [width_p+2:0] CFL_14_12_pos;
	wire signed [width_p+2:0] CFL_14_13_pos;
	wire signed [width_p+2:0] CFL_14_14_pos;
	wire signed [width_p+2:0] CFL_14_15_pos;

	wire signed [width_p+2:0] CFL_14_0_neg;	
	wire signed [width_p+2:0] CFL_14_1_neg;
	wire signed [width_p+2:0] CFL_14_2_neg;
	wire signed [width_p+2:0] CFL_14_3_neg;
	wire signed [width_p+2:0] CFL_14_4_neg;
	wire signed [width_p+2:0] CFL_14_5_neg;
	wire signed [width_p+2:0] CFL_14_6_neg;
	wire signed [width_p+2:0] CFL_14_7_neg;
	wire signed [width_p+2:0] CFL_14_8_neg;
	wire signed [width_p+2:0] CFL_14_9_neg;
	wire signed [width_p+2:0] CFL_14_10_neg;
	wire signed [width_p+2:0] CFL_14_11_neg;
	wire signed [width_p+2:0] CFL_14_12_neg;
	wire signed [width_p+2:0] CFL_14_13_neg;
	wire signed [width_p+2:0] CFL_14_14_neg;
	wire signed [width_p+2:0] CFL_14_15_neg;

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_14_pos 
	(
		.alpha_sign(alpha_sign_14_pos),
		.alpha_index(alpha_index_14),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_14_0_pos),
		.CFL_01_o(CFL_14_1_pos),
		.CFL_02_o(CFL_14_2_pos),
		.CFL_03_o(CFL_14_3_pos),
		.CFL_04_o(CFL_14_4_pos),
		.CFL_05_o(CFL_14_5_pos),
		.CFL_06_o(CFL_14_6_pos),
		.CFL_07_o(CFL_14_7_pos),
		.CFL_08_o(CFL_14_8_pos),
		.CFL_09_o(CFL_14_9_pos),
		.CFL_10_o(CFL_14_10_pos),
		.CFL_11_o(CFL_14_11_pos),
		.CFL_12_o(CFL_14_12_pos),
		.CFL_13_o(CFL_14_13_pos),
		.CFL_14_o(CFL_14_14_pos),
		.CFL_15_o(CFL_14_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_14_neg 
	(
		.alpha_sign(alpha_sign_14_neg),
		.alpha_index(alpha_index_14),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_14_0_neg),
		.CFL_01_o(CFL_14_1_neg),
		.CFL_02_o(CFL_14_2_neg),
		.CFL_03_o(CFL_14_3_neg),
		.CFL_04_o(CFL_14_4_neg),
		.CFL_05_o(CFL_14_5_neg),
		.CFL_06_o(CFL_14_6_neg),
		.CFL_07_o(CFL_14_7_neg),
		.CFL_08_o(CFL_14_8_neg),
		.CFL_09_o(CFL_14_9_neg),
		.CFL_10_o(CFL_14_10_neg),
		.CFL_11_o(CFL_14_11_neg),
		.CFL_12_o(CFL_14_12_neg),
		.CFL_13_o(CFL_14_13_neg),
		.CFL_14_o(CFL_14_14_neg),
		.CFL_15_o(CFL_14_15_neg)
    );

	// --------------- index = 15 --------------- //	

	wire [4:0] alpha_index_15 = 15; 
	wire alpha_sign_15_pos  = 0;
	wire alpha_sign_15_neg  = 1;

	assign alpha_index_15     = 15; 
	assign alpha_sign_15_pos  = 0;
	assign alpha_sign_15_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_15_0_pos;	
	wire signed [width_p+2:0] CFL_15_1_pos;
	wire signed [width_p+2:0] CFL_15_2_pos;
	wire signed [width_p+2:0] CFL_15_3_pos;
	wire signed [width_p+2:0] CFL_15_4_pos;
	wire signed [width_p+2:0] CFL_15_5_pos;
	wire signed [width_p+2:0] CFL_15_6_pos;
	wire signed [width_p+2:0] CFL_15_7_pos;
	wire signed [width_p+2:0] CFL_15_8_pos;
	wire signed [width_p+2:0] CFL_15_9_pos;
	wire signed [width_p+2:0] CFL_15_10_pos;
	wire signed [width_p+2:0] CFL_15_11_pos;
	wire signed [width_p+2:0] CFL_15_12_pos;
	wire signed [width_p+2:0] CFL_15_13_pos;
	wire signed [width_p+2:0] CFL_15_14_pos;
	wire signed [width_p+2:0] CFL_15_15_pos;

	wire signed [width_p+2:0] CFL_15_0_neg;	
	wire signed [width_p+2:0] CFL_15_1_neg;
	wire signed [width_p+2:0] CFL_15_2_neg;
	wire signed [width_p+2:0] CFL_15_3_neg;
	wire signed [width_p+2:0] CFL_15_4_neg;
	wire signed [width_p+2:0] CFL_15_5_neg;
	wire signed [width_p+2:0] CFL_15_6_neg;
	wire signed [width_p+2:0] CFL_15_7_neg;
	wire signed [width_p+2:0] CFL_15_8_neg;
	wire signed [width_p+2:0] CFL_15_9_neg;
	wire signed [width_p+2:0] CFL_15_10_neg;
	wire signed [width_p+2:0] CFL_15_11_neg;
	wire signed [width_p+2:0] CFL_15_12_neg;
	wire signed [width_p+2:0] CFL_15_13_neg;
	wire signed [width_p+2:0] CFL_15_14_neg;
	wire signed [width_p+2:0] CFL_15_15_neg;

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_15_pos 
	(
		.alpha_sign(alpha_sign_15_pos),
		.alpha_index(alpha_index_15),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_15_0_pos),
		.CFL_01_o(CFL_15_1_pos),
		.CFL_02_o(CFL_15_2_pos),
		.CFL_03_o(CFL_15_3_pos),
		.CFL_04_o(CFL_15_4_pos),
		.CFL_05_o(CFL_15_5_pos),
		.CFL_06_o(CFL_15_6_pos),
		.CFL_07_o(CFL_15_7_pos),
		.CFL_08_o(CFL_15_8_pos),
		.CFL_09_o(CFL_15_9_pos),
		.CFL_10_o(CFL_15_10_pos),
		.CFL_11_o(CFL_15_11_pos),
		.CFL_12_o(CFL_15_12_pos),
		.CFL_13_o(CFL_15_13_pos),
		.CFL_14_o(CFL_15_14_pos),
		.CFL_15_o(CFL_15_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_15_neg 
	(
		.alpha_sign(alpha_sign_15_neg),
		.alpha_index(alpha_index_15),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_15_0_neg),
		.CFL_01_o(CFL_15_1_neg),
		.CFL_02_o(CFL_15_2_neg),
		.CFL_03_o(CFL_15_3_neg),
		.CFL_04_o(CFL_15_4_neg),
		.CFL_05_o(CFL_15_5_neg),
		.CFL_06_o(CFL_15_6_neg),
		.CFL_07_o(CFL_15_7_neg),
		.CFL_08_o(CFL_15_8_neg),
		.CFL_09_o(CFL_15_9_neg),
		.CFL_10_o(CFL_15_10_neg),
		.CFL_11_o(CFL_15_11_neg),
		.CFL_12_o(CFL_15_12_neg),
		.CFL_13_o(CFL_15_13_neg),
		.CFL_14_o(CFL_15_14_neg),
		.CFL_15_o(CFL_15_15_neg)
    );

	// --------------- index = 16 --------------- //	

	wire [4:0] alpha_index_16 = 16; 
	wire alpha_sign_16_pos  = 0;
	wire alpha_sign_16_neg  = 1;
	
	assign alpha_index_16 = 16;
	assign alpha_sign_16_pos = 0;
	assign alpha_sign_16_neg  = 1;	
	
	wire signed [width_p+2:0] CFL_16_0_pos;	
	wire signed [width_p+2:0] CFL_16_1_pos;
	wire signed [width_p+2:0] CFL_16_2_pos;
	wire signed [width_p+2:0] CFL_16_3_pos;
	wire signed [width_p+2:0] CFL_16_4_pos;
	wire signed [width_p+2:0] CFL_16_5_pos;
	wire signed [width_p+2:0] CFL_16_6_pos;
	wire signed [width_p+2:0] CFL_16_7_pos;
	wire signed [width_p+2:0] CFL_16_8_pos;
	wire signed [width_p+2:0] CFL_16_9_pos;
	wire signed [width_p+2:0] CFL_16_10_pos;
	wire signed [width_p+2:0] CFL_16_11_pos;
	wire signed [width_p+2:0] CFL_16_12_pos;
	wire signed [width_p+2:0] CFL_16_13_pos;
	wire signed [width_p+2:0] CFL_16_14_pos;
	wire signed [width_p+2:0] CFL_16_15_pos;

	wire signed [width_p+2:0] CFL_16_0_neg;	
	wire signed [width_p+2:0] CFL_16_1_neg;
	wire signed [width_p+2:0] CFL_16_2_neg;
	wire signed [width_p+2:0] CFL_16_3_neg;
	wire signed [width_p+2:0] CFL_16_4_neg;
	wire signed [width_p+2:0] CFL_16_5_neg;
	wire signed [width_p+2:0] CFL_16_6_neg;
	wire signed [width_p+2:0] CFL_16_7_neg;
	wire signed [width_p+2:0] CFL_16_8_neg;
	wire signed [width_p+2:0] CFL_16_9_neg;
	wire signed [width_p+2:0] CFL_16_10_neg;
	wire signed [width_p+2:0] CFL_16_11_neg;
	wire signed [width_p+2:0] CFL_16_12_neg;
	wire signed [width_p+2:0] CFL_16_13_neg;
	wire signed [width_p+2:0] CFL_16_14_neg;
	wire signed [width_p+2:0] CFL_16_15_neg;	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_16_pos 
	(
		.alpha_sign(alpha_sign_16_pos),
		.alpha_index(alpha_index_16),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_16_0_pos),
		.CFL_01_o(CFL_16_1_pos),
		.CFL_02_o(CFL_16_2_pos),
		.CFL_03_o(CFL_16_3_pos),
		.CFL_04_o(CFL_16_4_pos),
		.CFL_05_o(CFL_16_5_pos),
		.CFL_06_o(CFL_16_6_pos),
		.CFL_07_o(CFL_16_7_pos),
		.CFL_08_o(CFL_16_8_pos),
		.CFL_09_o(CFL_16_9_pos),
		.CFL_10_o(CFL_16_10_pos),
		.CFL_11_o(CFL_16_11_pos),
		.CFL_12_o(CFL_16_12_pos),
		.CFL_13_o(CFL_16_13_pos),
		.CFL_14_o(CFL_16_14_pos),
		.CFL_15_o(CFL_16_15_pos)
    );	

	alpha_scaling #(
	
		.width_p(width_p)
		
	) alpha_scaling_16_neg 
	(
		.alpha_sign(alpha_sign_16_neg),
		.alpha_index(alpha_index_16),
		.AC_value_00(AC_value_00_wire),
		.AC_value_01(AC_value_01_wire),
		.AC_value_02(AC_value_02_wire),
		.AC_value_03(AC_value_03_wire),
		.AC_value_04(AC_value_04_wire),
		.AC_value_05(AC_value_05_wire),
		.AC_value_06(AC_value_06_wire),
		.AC_value_07(AC_value_07_wire),
		.AC_value_08(AC_value_08_wire),
		.AC_value_09(AC_value_09_wire),
		.AC_value_10(AC_value_10_wire),
		.AC_value_11(AC_value_11_wire),
		.AC_value_12(AC_value_12_wire),
		.AC_value_13(AC_value_13_wire),
		.AC_value_14(AC_value_14_wire),
		.AC_value_15(AC_value_15_wire),

		.CFL_00_o(CFL_16_0_neg),
		.CFL_01_o(CFL_16_1_neg),
		.CFL_02_o(CFL_16_2_neg),
		.CFL_03_o(CFL_16_3_neg),
		.CFL_04_o(CFL_16_4_neg),
		.CFL_05_o(CFL_16_5_neg),
		.CFL_06_o(CFL_16_6_neg),
		.CFL_07_o(CFL_16_7_neg),
		.CFL_08_o(CFL_16_8_neg),
		.CFL_09_o(CFL_16_9_neg),
		.CFL_10_o(CFL_16_10_neg),
		.CFL_11_o(CFL_16_11_neg),
		.CFL_12_o(CFL_16_12_neg),
		.CFL_13_o(CFL_16_13_neg),
		.CFL_14_o(CFL_16_14_neg),
		.CFL_15_o(CFL_16_15_neg)
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

	always @(posedge clk_i) begin
		if(rst_i) begin
			CFL_0_0_reg 		<= 0;
		    CFL_0_1_reg 		<= 0;
		    CFL_0_2_reg 		<= 0;
		    CFL_0_3_reg 		<= 0;
		    CFL_0_4_reg 		<= 0;
		    CFL_0_5_reg 		<= 0;
		    CFL_0_6_reg 		<= 0;
		    CFL_0_7_reg 		<= 0;
		    CFL_0_8_reg 		<= 0;
		    CFL_0_9_reg 		<= 0;
		    CFL_0_10_reg		<= 0;
		    CFL_0_11_reg		<= 0;
		    CFL_0_12_reg		<= 0;
		    CFL_0_13_reg		<= 0;
		    CFL_0_14_reg		<= 0;
		    CFL_0_15_reg		<= 0;
			CFL_1_0_pos_reg 	<= 0;
			CFL_1_1_pos_reg     <= 0;
			CFL_1_2_pos_reg     <= 0;
			CFL_1_3_pos_reg     <= 0;
			CFL_1_4_pos_reg     <= 0;
			CFL_1_5_pos_reg     <= 0;
			CFL_1_6_pos_reg     <= 0;
			CFL_1_7_pos_reg     <= 0;
			CFL_1_8_pos_reg     <= 0;
			CFL_1_9_pos_reg     <= 0;
			CFL_1_10_pos_reg    <= 0;
			CFL_1_11_pos_reg    <= 0;
			CFL_1_12_pos_reg    <= 0;
			CFL_1_13_pos_reg    <= 0;
			CFL_1_14_pos_reg    <= 0;
			CFL_1_15_pos_reg    <= 0;
			CFL_1_0_neg_reg 	<= 0;
			CFL_1_1_neg_reg     <= 0;
			CFL_1_2_neg_reg     <= 0;
			CFL_1_3_neg_reg     <= 0;
			CFL_1_4_neg_reg     <= 0;
			CFL_1_5_neg_reg     <= 0;
			CFL_1_6_neg_reg     <= 0;
			CFL_1_7_neg_reg     <= 0;
			CFL_1_8_neg_reg     <= 0;
			CFL_1_9_neg_reg     <= 0;
			CFL_1_10_neg_reg    <= 0;
			CFL_1_11_neg_reg    <= 0;
			CFL_1_12_neg_reg    <= 0;
			CFL_1_13_neg_reg    <= 0;
			CFL_1_14_neg_reg    <= 0;
			CFL_1_15_neg_reg    <= 0;
			CFL_2_0_pos_reg 	<= 0;
			CFL_2_1_pos_reg     <= 0;
			CFL_2_2_pos_reg     <= 0;
			CFL_2_3_pos_reg     <= 0;
			CFL_2_4_pos_reg     <= 0;
			CFL_2_5_pos_reg     <= 0;
			CFL_2_6_pos_reg     <= 0;
			CFL_2_7_pos_reg     <= 0;
			CFL_2_8_pos_reg     <= 0;
			CFL_2_9_pos_reg     <= 0;
			CFL_2_10_pos_reg    <= 0;
			CFL_2_11_pos_reg    <= 0;
			CFL_2_12_pos_reg    <= 0;
			CFL_2_13_pos_reg    <= 0;
			CFL_2_14_pos_reg    <= 0;
			CFL_2_15_pos_reg    <= 0;
			CFL_2_0_neg_reg 	<= 0;
			CFL_2_1_neg_reg     <= 0;
			CFL_2_2_neg_reg     <= 0;
			CFL_2_3_neg_reg     <= 0;
			CFL_2_4_neg_reg     <= 0;
			CFL_2_5_neg_reg     <= 0;
			CFL_2_6_neg_reg     <= 0;
			CFL_2_7_neg_reg     <= 0;
			CFL_2_8_neg_reg     <= 0;
			CFL_2_9_neg_reg     <= 0;
			CFL_2_10_neg_reg    <= 0;
			CFL_2_11_neg_reg    <= 0;
			CFL_2_12_neg_reg    <= 0;
			CFL_2_13_neg_reg    <= 0;
			CFL_2_14_neg_reg    <= 0;
			CFL_2_15_neg_reg    <= 0;
			CFL_3_0_pos_reg 	<= 0;
			CFL_3_1_pos_reg     <= 0;
			CFL_3_2_pos_reg     <= 0;
			CFL_3_3_pos_reg     <= 0;
			CFL_3_4_pos_reg     <= 0;
			CFL_3_5_pos_reg     <= 0;
			CFL_3_6_pos_reg     <= 0;
			CFL_3_7_pos_reg     <= 0;
			CFL_3_8_pos_reg     <= 0;
			CFL_3_9_pos_reg     <= 0;
			CFL_3_10_pos_reg    <= 0;
			CFL_3_11_pos_reg    <= 0;
			CFL_3_12_pos_reg    <= 0;
			CFL_3_13_pos_reg    <= 0;
			CFL_3_14_pos_reg    <= 0;
			CFL_3_15_pos_reg    <= 0;
			CFL_3_0_neg_reg 	<= 0;
			CFL_3_1_neg_reg     <= 0;
			CFL_3_2_neg_reg     <= 0;
			CFL_3_3_neg_reg     <= 0;
			CFL_3_4_neg_reg     <= 0;
			CFL_3_5_neg_reg     <= 0;
			CFL_3_6_neg_reg     <= 0;
			CFL_3_7_neg_reg     <= 0;
			CFL_3_8_neg_reg     <= 0;
			CFL_3_9_neg_reg     <= 0;
			CFL_3_10_neg_reg    <= 0;
			CFL_3_11_neg_reg    <= 0;
			CFL_3_12_neg_reg    <= 0;
			CFL_3_13_neg_reg    <= 0;
			CFL_3_14_neg_reg    <= 0;
			CFL_3_15_neg_reg    <= 0;
			CFL_4_0_pos_reg 	<= 0;
			CFL_4_1_pos_reg     <= 0;
			CFL_4_2_pos_reg     <= 0;
			CFL_4_3_pos_reg     <= 0;
			CFL_4_4_pos_reg     <= 0;
			CFL_4_5_pos_reg     <= 0;
			CFL_4_6_pos_reg     <= 0;
			CFL_4_7_pos_reg     <= 0;
			CFL_4_8_pos_reg     <= 0;
			CFL_4_9_pos_reg     <= 0;
			CFL_4_10_pos_reg    <= 0;
			CFL_4_11_pos_reg    <= 0;
			CFL_4_12_pos_reg    <= 0;
			CFL_4_13_pos_reg    <= 0;
			CFL_4_14_pos_reg    <= 0;
			CFL_4_15_pos_reg    <= 0;
			CFL_4_0_neg_reg 	<= 0;
			CFL_4_1_neg_reg     <= 0;
			CFL_4_2_neg_reg     <= 0;
			CFL_4_3_neg_reg     <= 0;
			CFL_4_4_neg_reg     <= 0;
			CFL_4_5_neg_reg     <= 0;
			CFL_4_6_neg_reg     <= 0;
			CFL_4_7_neg_reg     <= 0;
			CFL_4_8_neg_reg     <= 0;
			CFL_4_9_neg_reg     <= 0;
			CFL_4_10_neg_reg    <= 0;
			CFL_4_11_neg_reg    <= 0;
			CFL_4_12_neg_reg    <= 0;
			CFL_4_13_neg_reg    <= 0;
			CFL_4_14_neg_reg    <= 0;
			CFL_4_15_neg_reg    <= 0;
			CFL_5_0_pos_reg 	<= 0;
			CFL_5_1_pos_reg     <= 0;
			CFL_5_2_pos_reg     <= 0;
			CFL_5_3_pos_reg     <= 0;
			CFL_5_4_pos_reg     <= 0;
			CFL_5_5_pos_reg     <= 0;
			CFL_5_6_pos_reg     <= 0;
			CFL_5_7_pos_reg     <= 0;
			CFL_5_8_pos_reg     <= 0;
			CFL_5_9_pos_reg     <= 0;
			CFL_5_10_pos_reg    <= 0;
			CFL_5_11_pos_reg    <= 0;
			CFL_5_12_pos_reg    <= 0;
			CFL_5_13_pos_reg    <= 0;
			CFL_5_14_pos_reg    <= 0;
			CFL_5_15_pos_reg    <= 0;
			CFL_5_0_neg_reg 	<= 0;
			CFL_5_1_neg_reg     <= 0;
			CFL_5_2_neg_reg     <= 0;
            CFL_5_3_neg_reg     <= 0;
			CFL_5_4_neg_reg     <= 0;
			CFL_5_5_neg_reg     <= 0;
			CFL_5_6_neg_reg     <= 0;
			CFL_5_7_neg_reg     <= 0;
			CFL_5_8_neg_reg     <= 0;
			CFL_5_9_neg_reg     <= 0;
			CFL_5_10_neg_reg    <= 0;
			CFL_5_11_neg_reg    <= 0;
			CFL_5_12_neg_reg    <= 0;
			CFL_5_13_neg_reg    <= 0;
			CFL_5_14_neg_reg    <= 0;
			CFL_5_15_neg_reg    <= 0;
			CFL_6_0_pos_reg 	<= 0;
			CFL_6_1_pos_reg     <= 0;
			CFL_6_2_pos_reg     <= 0;
			CFL_6_3_pos_reg     <= 0;
			CFL_6_4_pos_reg     <= 0;
			CFL_6_5_pos_reg     <= 0;
			CFL_6_6_pos_reg     <= 0;
			CFL_6_7_pos_reg     <= 0;
			CFL_6_8_pos_reg     <= 0;
			CFL_6_9_pos_reg     <= 0;
			CFL_6_10_pos_reg    <= 0;
			CFL_6_11_pos_reg    <= 0;
			CFL_6_12_pos_reg    <= 0;
			CFL_6_13_pos_reg    <= 0;
			CFL_6_14_pos_reg    <= 0;
			CFL_6_15_pos_reg    <= 0;
			CFL_6_0_neg_reg 	<= 0;
			CFL_6_1_neg_reg     <= 0;
			CFL_6_2_neg_reg     <= 0;
			CFL_6_3_neg_reg     <= 0;
			CFL_6_4_neg_reg     <= 0;
			CFL_6_5_neg_reg     <= 0;
			CFL_6_6_neg_reg     <= 0;
			CFL_6_7_neg_reg     <= 0;
			CFL_6_8_neg_reg     <= 0;
			CFL_6_9_neg_reg     <= 0;
			CFL_6_10_neg_reg    <= 0;
			CFL_6_11_neg_reg    <= 0;
			CFL_6_12_neg_reg    <= 0;
			CFL_6_13_neg_reg    <= 0;
			CFL_6_14_neg_reg    <= 0;
			CFL_6_15_neg_reg    <= 0;
			CFL_7_0_pos_reg		<= 0; 
			CFL_7_1_pos_reg     <= 0;
			CFL_7_2_pos_reg     <= 0;
			CFL_7_3_pos_reg     <= 0;
			CFL_7_4_pos_reg     <= 0;
			CFL_7_5_pos_reg     <= 0;
			CFL_7_6_pos_reg     <= 0;
			CFL_7_7_pos_reg     <= 0;
			CFL_7_8_pos_reg     <= 0;
			CFL_7_9_pos_reg     <= 0;
			CFL_7_10_pos_reg    <= 0;
			CFL_7_11_pos_reg    <= 0;
			CFL_7_12_pos_reg    <= 0;
			CFL_7_13_pos_reg    <= 0;
			CFL_7_14_pos_reg    <= 0;
			CFL_7_15_pos_reg    <= 0;
			CFL_7_0_neg_reg 	<= 0;
			CFL_7_1_neg_reg     <= 0;
			CFL_7_2_neg_reg     <= 0;
			CFL_7_3_neg_reg     <= 0;
			CFL_7_4_neg_reg     <= 0;
			CFL_7_5_neg_reg     <= 0;
			CFL_7_6_neg_reg     <= 0;
			CFL_7_7_neg_reg     <= 0;
			CFL_7_8_neg_reg     <= 0;
			CFL_7_9_neg_reg     <= 0;
			CFL_7_10_neg_reg    <= 0;
			CFL_7_11_neg_reg    <= 0;
			CFL_7_12_neg_reg    <= 0;
			CFL_7_13_neg_reg    <= 0;
			CFL_7_14_neg_reg    <= 0;
			CFL_7_15_neg_reg    <= 0;
			CFL_8_0_pos_reg 	<= 0;
			CFL_8_1_pos_reg     <= 0;
			CFL_8_2_pos_reg     <= 0;
			CFL_8_3_pos_reg     <= 0;
			CFL_8_4_pos_reg     <= 0;
			CFL_8_5_pos_reg     <= 0;
			CFL_8_6_pos_reg     <= 0;
			CFL_8_7_pos_reg     <= 0;
			CFL_8_8_pos_reg     <= 0;
			CFL_8_9_pos_reg     <= 0;
			CFL_8_10_pos_reg    <= 0;
			CFL_8_11_pos_reg    <= 0;
			CFL_8_12_pos_reg    <= 0;
			CFL_8_13_pos_reg    <= 0;
			CFL_8_14_pos_reg    <= 0;
			CFL_8_15_pos_reg    <= 0;
			CFL_8_0_neg_reg 	<= 0;
			CFL_8_1_neg_reg     <= 0;
			CFL_8_2_neg_reg     <= 0;
			CFL_8_3_neg_reg     <= 0;
			CFL_8_4_neg_reg     <= 0;
			CFL_8_5_neg_reg     <= 0;
			CFL_8_6_neg_reg     <= 0;
			CFL_8_7_neg_reg     <= 0;
			CFL_8_8_neg_reg     <= 0;
			CFL_8_9_neg_reg     <= 0;
			CFL_8_10_neg_reg    <= 0;
			CFL_8_11_neg_reg    <= 0;
			CFL_8_12_neg_reg    <= 0;
			CFL_8_13_neg_reg    <= 0;
			CFL_8_14_neg_reg    <= 0;
			CFL_8_15_neg_reg    <= 0;
			CFL_9_0_pos_reg 	<= 0;
			CFL_9_1_pos_reg     <= 0;
			CFL_9_2_pos_reg     <= 0;
			CFL_9_3_pos_reg     <= 0;
			CFL_9_4_pos_reg     <= 0;
			CFL_9_5_pos_reg     <= 0;
			CFL_9_6_pos_reg     <= 0;
			CFL_9_7_pos_reg     <= 0;
			CFL_9_8_pos_reg     <= 0;
			CFL_9_9_pos_reg     <= 0;
			CFL_9_10_pos_reg    <= 0;
			CFL_9_11_pos_reg    <= 0;
			CFL_9_12_pos_reg    <= 0;
			CFL_9_13_pos_reg    <= 0;
			CFL_9_14_pos_reg    <= 0;
			CFL_9_15_pos_reg    <= 0;
			CFL_9_0_neg_reg 	<= 0;
			CFL_9_1_neg_reg     <= 0;
			CFL_9_2_neg_reg     <= 0;
			CFL_9_3_neg_reg     <= 0;
			CFL_9_4_neg_reg     <= 0;
			CFL_9_5_neg_reg     <= 0;
			CFL_9_6_neg_reg     <= 0;
			CFL_9_7_neg_reg     <= 0;
			CFL_9_8_neg_reg     <= 0;
			CFL_9_9_neg_reg     <= 0;
			CFL_9_10_neg_reg    <= 0;
			CFL_9_11_neg_reg    <= 0;
			CFL_9_12_neg_reg    <= 0;
			CFL_9_13_neg_reg    <= 0;
			CFL_9_14_neg_reg    <= 0;
			CFL_9_15_neg_reg    <= 0;
			CFL_10_0_pos_reg	<= 0; 
			CFL_10_1_pos_reg    <= 0;
			CFL_10_2_pos_reg    <= 0;
			CFL_10_3_pos_reg    <= 0;
			CFL_10_4_pos_reg    <= 0;
			CFL_10_5_pos_reg    <= 0;
			CFL_10_6_pos_reg    <= 0;
			CFL_10_7_pos_reg    <= 0;
			CFL_10_8_pos_reg    <= 0;
			CFL_10_9_pos_reg    <= 0;
			CFL_10_10_pos_reg   <= 0;
			CFL_10_11_pos_reg   <= 0;
			CFL_10_12_pos_reg   <= 0;
			CFL_10_13_pos_reg   <= 0;
			CFL_10_14_pos_reg   <= 0;
			CFL_10_15_pos_reg   <= 0;
			CFL_10_0_neg_reg 	<= 0;
			CFL_10_1_neg_reg    <= 0;
			CFL_10_2_neg_reg    <= 0;
			CFL_10_3_neg_reg    <= 0;
			CFL_10_4_neg_reg    <= 0;
			CFL_10_5_neg_reg    <= 0;
			CFL_10_6_neg_reg    <= 0;
			CFL_10_7_neg_reg    <= 0;
			CFL_10_8_neg_reg    <= 0;
			CFL_10_9_neg_reg    <= 0;
			CFL_10_10_neg_reg   <= 0;
			CFL_10_11_neg_reg   <= 0;
			CFL_10_12_neg_reg   <= 0;
			CFL_10_13_neg_reg   <= 0;
			CFL_10_14_neg_reg   <= 0;
			CFL_10_15_neg_reg   <= 0;
			CFL_11_0_pos_reg	<= 0; 
			CFL_11_1_pos_reg    <= 0;
			CFL_11_2_pos_reg    <= 0;
			CFL_11_3_pos_reg    <= 0;
			CFL_11_4_pos_reg    <= 0;
			CFL_11_5_pos_reg    <= 0;
			CFL_11_6_pos_reg    <= 0;
			CFL_11_7_pos_reg    <= 0;
			CFL_11_8_pos_reg    <= 0;
			CFL_11_9_pos_reg    <= 0;
			CFL_11_10_pos_reg   <= 0;
			CFL_11_11_pos_reg   <= 0;
			CFL_11_12_pos_reg   <= 0;
			CFL_11_13_pos_reg   <= 0;
			CFL_11_14_pos_reg   <= 0;
			CFL_11_15_pos_reg   <= 0;
			CFL_11_0_neg_reg 	<= 0;
			CFL_11_1_neg_reg    <= 0;
			CFL_11_2_neg_reg    <= 0;
			CFL_11_3_neg_reg    <= 0;
			CFL_11_4_neg_reg    <= 0;
			CFL_11_5_neg_reg    <= 0;
			CFL_11_6_neg_reg    <= 0;
			CFL_11_7_neg_reg    <= 0;
			CFL_11_8_neg_reg    <= 0;
			CFL_11_9_neg_reg    <= 0;
			CFL_11_10_neg_reg   <= 0;
			CFL_11_11_neg_reg   <= 0;
			CFL_11_12_neg_reg   <= 0;
			CFL_11_13_neg_reg   <= 0;
			CFL_11_14_neg_reg   <= 0;
			CFL_11_15_neg_reg   <= 0;
            CFL_12_0_pos_reg 	<= 0;
            CFL_12_1_pos_reg    <= 0;
            CFL_12_2_pos_reg    <= 0;
            CFL_12_3_pos_reg    <= 0;
            CFL_12_4_pos_reg    <= 0;
            CFL_12_5_pos_reg    <= 0;
            CFL_12_6_pos_reg    <= 0;
            CFL_12_7_pos_reg    <= 0;
            CFL_12_8_pos_reg    <= 0;
            CFL_12_9_pos_reg    <= 0;
            CFL_12_10_pos_reg   <= 0;
            CFL_12_11_pos_reg   <= 0;
            CFL_12_12_pos_reg   <= 0;
            CFL_12_13_pos_reg   <= 0;
            CFL_12_14_pos_reg   <= 0;
            CFL_12_15_pos_reg   <= 0;  
            CFL_12_0_neg_reg 	<= 0;
            CFL_12_1_neg_reg    <= 0;
            CFL_12_2_neg_reg    <= 0;
            CFL_12_3_neg_reg    <= 0;
            CFL_12_4_neg_reg    <= 0;
            CFL_12_5_neg_reg    <= 0;
            CFL_12_6_neg_reg    <= 0;
            CFL_12_7_neg_reg    <= 0;
            CFL_12_8_neg_reg    <= 0;
            CFL_12_9_neg_reg    <= 0;
            CFL_12_10_neg_reg   <= 0;
            CFL_12_11_neg_reg   <= 0;
            CFL_12_12_neg_reg   <= 0;
            CFL_12_13_neg_reg   <= 0;
            CFL_12_14_neg_reg   <= 0;
            CFL_12_15_neg_reg   <= 0;
            CFL_13_0_pos_reg 	<= 0;
            CFL_13_1_pos_reg    <= 0;
            CFL_13_2_pos_reg    <= 0;
            CFL_13_3_pos_reg    <= 0;
            CFL_13_4_pos_reg    <= 0;
            CFL_13_5_pos_reg    <= 0;
            CFL_13_6_pos_reg    <= 0;
            CFL_13_7_pos_reg    <= 0;
            CFL_13_8_pos_reg    <= 0;
            CFL_13_9_pos_reg    <= 0;
            CFL_13_10_pos_reg   <= 0;
            CFL_13_11_pos_reg   <= 0;
            CFL_13_12_pos_reg   <= 0;
            CFL_13_13_pos_reg   <= 0;
            CFL_13_14_pos_reg   <= 0;
            CFL_13_15_pos_reg   <= 0;
            CFL_13_0_neg_reg 	<= 0;
            CFL_13_1_neg_reg    <= 0;
            CFL_13_2_neg_reg    <= 0;
            CFL_13_3_neg_reg    <= 0;
            CFL_13_4_neg_reg    <= 0;
            CFL_13_5_neg_reg    <= 0;
            CFL_13_6_neg_reg    <= 0;
            CFL_13_7_neg_reg    <= 0;
            CFL_13_8_neg_reg    <= 0;
            CFL_13_9_neg_reg    <= 0;
            CFL_13_10_neg_reg   <= 0;
            CFL_13_11_neg_reg   <= 0;
            CFL_13_12_neg_reg   <= 0;
            CFL_13_13_neg_reg   <= 0;
            CFL_13_14_neg_reg   <= 0;
            CFL_13_15_neg_reg   <= 0;
            CFL_14_0_pos_reg	<= 0; 
            CFL_14_1_pos_reg    <= 0;
            CFL_14_2_pos_reg    <= 0;
            CFL_14_3_pos_reg    <= 0;
            CFL_14_4_pos_reg    <= 0;
            CFL_14_5_pos_reg    <= 0;
            CFL_14_6_pos_reg    <= 0;
            CFL_14_7_pos_reg    <= 0;
            CFL_14_8_pos_reg    <= 0;
            CFL_14_9_pos_reg    <= 0;
            CFL_14_10_pos_reg   <= 0;
            CFL_14_11_pos_reg   <= 0;
            CFL_14_12_pos_reg   <= 0;
            CFL_14_13_pos_reg   <= 0;
            CFL_14_14_pos_reg   <= 0;
            CFL_14_15_pos_reg   <= 0;
            CFL_14_0_neg_reg 	<= 0;
            CFL_14_1_neg_reg    <= 0;
            CFL_14_2_neg_reg    <= 0;
            CFL_14_3_neg_reg    <= 0;
            CFL_14_4_neg_reg    <= 0;
            CFL_14_5_neg_reg    <= 0;
            CFL_14_6_neg_reg    <= 0;
            CFL_14_7_neg_reg    <= 0;
            CFL_14_8_neg_reg    <= 0;
            CFL_14_9_neg_reg    <= 0;
            CFL_14_10_neg_reg   <= 0;
            CFL_14_11_neg_reg   <= 0;
            CFL_14_12_neg_reg   <= 0;
            CFL_14_13_neg_reg   <= 0;
            CFL_14_14_neg_reg   <= 0;
            CFL_14_15_neg_reg   <= 0;
            CFL_15_0_pos_reg	<= 0; 
            CFL_15_1_pos_reg    <= 0;
            CFL_15_2_pos_reg    <= 0;
            CFL_15_3_pos_reg    <= 0;
            CFL_15_4_pos_reg    <= 0;
            CFL_15_5_pos_reg    <= 0;
            CFL_15_6_pos_reg    <= 0;
            CFL_15_7_pos_reg    <= 0;
            CFL_15_8_pos_reg    <= 0;
            CFL_15_9_pos_reg    <= 0;
            CFL_15_10_pos_reg   <= 0;
            CFL_15_11_pos_reg   <= 0;
            CFL_15_12_pos_reg   <= 0;
            CFL_15_13_pos_reg   <= 0;
            CFL_15_14_pos_reg   <= 0;
            CFL_15_15_pos_reg   <= 0;
            CFL_15_0_neg_reg 	<= 0;
            CFL_15_1_neg_reg    <= 0;
            CFL_15_2_neg_reg    <= 0;
            CFL_15_3_neg_reg    <= 0;
            CFL_15_4_neg_reg    <= 0;
            CFL_15_5_neg_reg    <= 0;
            CFL_15_6_neg_reg    <= 0;
            CFL_15_7_neg_reg    <= 0;
            CFL_15_8_neg_reg    <= 0;
            CFL_15_9_neg_reg    <= 0;
            CFL_15_10_neg_reg   <= 0;
            CFL_15_11_neg_reg   <= 0;
            CFL_15_12_neg_reg   <= 0;
            CFL_15_13_neg_reg   <= 0;
            CFL_15_14_neg_reg   <= 0;
            CFL_15_15_neg_reg   <= 0;
            CFL_16_0_pos_reg	<= 0; 
            CFL_16_1_pos_reg    <= 0;
            CFL_16_2_pos_reg    <= 0;
            CFL_16_3_pos_reg    <= 0;
            CFL_16_4_pos_reg    <= 0;
            CFL_16_5_pos_reg    <= 0;
            CFL_16_6_pos_reg    <= 0;
            CFL_16_7_pos_reg    <= 0;
            CFL_16_8_pos_reg    <= 0;
            CFL_16_9_pos_reg    <= 0;
            CFL_16_10_pos_reg   <= 0;
            CFL_16_11_pos_reg   <= 0;
            CFL_16_12_pos_reg   <= 0;
            CFL_16_13_pos_reg   <= 0;
            CFL_16_14_pos_reg   <= 0;
            CFL_16_15_pos_reg   <= 0;
            CFL_16_0_neg_reg 	<= 0;
            CFL_16_1_neg_reg    <= 0;
            CFL_16_2_neg_reg    <= 0;
            CFL_16_3_neg_reg    <= 0;
            CFL_16_4_neg_reg    <= 0;
            CFL_16_5_neg_reg    <= 0;
            CFL_16_6_neg_reg    <= 0;
            CFL_16_7_neg_reg    <= 0;
            CFL_16_8_neg_reg    <= 0;
            CFL_16_9_neg_reg    <= 0;
            CFL_16_10_neg_reg   <= 0;
            CFL_16_11_neg_reg   <= 0;
            CFL_16_12_neg_reg   <= 0;
            CFL_16_13_neg_reg   <= 0;
            CFL_16_14_neg_reg   <= 0;
            CFL_16_15_neg_reg   <= 0;
		end
	end
	
   // Pipeline First Stage - Memory load + Transform to signed
   // Evaluate if we can remove the first stage of the pipeline 
	always @(posedge clk_i) begin
		if(rst_i) begin 
			address_row_first_reg    	<= 0; 
			address_column_first_reg 	<= 0;
			AC_value_00_reg				<= 0;
			AC_value_01_reg             <= 0;
			AC_value_02_reg             <= 0;
			AC_value_03_reg             <= 0;
			AC_value_04_reg             <= 0;
			AC_value_05_reg             <= 0;
			AC_value_06_reg             <= 0;
			AC_value_07_reg				<= 0;
			AC_value_08_reg             <= 0;
			AC_value_09_reg             <= 0;
			AC_value_10_reg             <= 0;
			AC_value_11_reg             <= 0;
			AC_value_12_reg             <= 0;
			AC_value_13_reg             <= 0;
			AC_value_14_reg             <= 0;
			AC_value_15_reg             <= 0;
			count_en				 	<= 0;
			CFL_final_ready_first_reg 	<= 0;
			sample_in_00_reg			<= 0;
			sample_in_01_reg			<= 0;
			sample_in_02_reg			<= 0;
			sample_in_03_reg			<= 0;
			sample_in_04_reg			<= 0;
			sample_in_05_reg			<= 0;
			sample_in_06_reg			<= 0;
			sample_in_07_reg			<= 0;
			sample_in_08_reg			<= 0;
			sample_in_09_reg			<= 0;
			sample_in_10_reg			<= 0;
			sample_in_11_reg			<= 0;
			sample_in_12_reg			<= 0;
			sample_in_13_reg			<= 0;
			sample_in_14_reg			<= 0;
			sample_in_15_reg			<= 0;
		
		end else if(pipe_en_i) begin 						
			sample_in_00_reg			<= sample_in_00_i;
			sample_in_01_reg            <= sample_in_01_i;
			sample_in_02_reg			<= sample_in_02_i;
			sample_in_03_reg            <= sample_in_03_i;
			sample_in_04_reg			<= sample_in_04_i;
			sample_in_05_reg            <= sample_in_05_i;
			sample_in_06_reg            <= sample_in_06_i;
			sample_in_07_reg            <= sample_in_07_i;
			sample_in_08_reg			<= sample_in_08_i;
			sample_in_09_reg            <= sample_in_09_i;
			sample_in_10_reg            <= sample_in_10_i;
			sample_in_11_reg            <= sample_in_11_i;
			sample_in_12_reg			<= sample_in_12_i;
			sample_in_13_reg            <= sample_in_13_i;
			sample_in_14_reg            <= sample_in_14_i;
			sample_in_15_reg            <= sample_in_15_i;
			
			address_row_first_reg 	 	<= address_row_i;
			address_column_first_reg 	<= address_column_i;
			DC_Intra_Chr_first		 	<= DC_Intra_Chr_reg;
			CFL_final_ready_first_reg 	<= CFL_final_ready_i;
			
			if(mem_read_finish_i) begin 
				count_en   <= 1;
				if((block_width_i == 8 && block_height_i == 8) || (block_width_i == 8 && block_height_i == 4)) begin 
					avg_first  <= avg_reg_in;
				end 
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
		AC_value_00_reg				<= $signed(sample_in_00_reg) - $signed(avg_first);
        AC_value_01_reg				<= $signed(sample_in_01_reg) - $signed(avg_first);
        AC_value_02_reg				<= $signed(sample_in_02_reg) - $signed(avg_first);
        AC_value_03_reg				<= $signed(sample_in_03_reg) - $signed(avg_first);
        AC_value_04_reg				<= $signed(sample_in_04_reg) - $signed(avg_first);
        AC_value_05_reg				<= $signed(sample_in_05_reg) - $signed(avg_first);
        AC_value_06_reg				<= $signed(sample_in_06_reg) - $signed(avg_first);
        AC_value_07_reg				<= $signed(sample_in_07_reg) - $signed(avg_first);
        AC_value_08_reg				<= $signed(sample_in_08_reg) - $signed(avg_first);
        AC_value_09_reg				<= $signed(sample_in_09_reg) - $signed(avg_first);
        AC_value_10_reg				<= $signed(sample_in_10_reg) - $signed(avg_first);
        AC_value_11_reg				<= $signed(sample_in_11_reg) - $signed(avg_first);
        AC_value_12_reg				<= $signed(sample_in_12_reg) - $signed(avg_first);
        AC_value_13_reg				<= $signed(sample_in_13_reg) - $signed(avg_first);
        AC_value_14_reg				<= $signed(sample_in_14_reg) - $signed(avg_first);
        AC_value_15_reg				<= $signed(sample_in_15_reg) - $signed(avg_first);

		address_row_second_reg    	<= address_row_first_reg;
		address_column_second_reg 	<= address_column_first_reg;
		DC_Intra_Chr_second		  	<= DC_Intra_Chr_first;
		CFL_final_ready_second_reg	<= CFL_final_ready_first_reg; 
	end 
	
	assign AC_value_00_wire = AC_value_00_reg;
    assign AC_value_01_wire = AC_value_01_reg;
    assign AC_value_02_wire = AC_value_02_reg;
    assign AC_value_03_wire = AC_value_03_reg;
    assign AC_value_04_wire = AC_value_04_reg;
    assign AC_value_05_wire = AC_value_05_reg;
    assign AC_value_06_wire = AC_value_06_reg;
    assign AC_value_07_wire = AC_value_07_reg;
    assign AC_value_08_wire = AC_value_08_reg;
    assign AC_value_09_wire = AC_value_09_reg;
    assign AC_value_10_wire = AC_value_10_reg;
    assign AC_value_11_wire = AC_value_11_reg;
    assign AC_value_12_wire = AC_value_12_reg;
    assign AC_value_13_wire = AC_value_13_reg;
    assign AC_value_14_wire = AC_value_14_reg;
    assign AC_value_15_wire = AC_value_15_reg;

 	// Pipeline Third Stage - Alpha Multipl	
	always @(posedge clk_i) begin
		address_row_third_reg	 	<= address_row_second_reg;
		address_column_third_reg 	<= address_column_second_reg;
		DC_Intra_Chr_third		 	<= DC_Intra_Chr_second; 
		CFL_final_ready_third_reg	<= CFL_final_ready_second_reg; 
		
		CFL_0_0_reg 		<=	CFL_0_0;	
		CFL_0_1_reg 		<=  CFL_0_1;
		CFL_0_2_reg 		<=  CFL_0_2;
		CFL_0_3_reg    		<=  CFL_0_3;
		CFL_0_4_reg    		<=  CFL_0_4;
		CFL_0_5_reg 		<=  CFL_0_5;
		CFL_0_6_reg    		<=  CFL_0_6;
		CFL_0_7_reg    		<=  CFL_0_7;
		CFL_0_8_reg 		<=  CFL_0_8;
		CFL_0_9_reg    		<=  CFL_0_9;
		CFL_0_10_reg    	<=  CFL_0_10;
		CFL_0_11_reg 		<=  CFL_0_11;
		CFL_0_12_reg    	<=  CFL_0_12;
		CFL_0_13_reg    	<=  CFL_0_13;
		CFL_0_14_reg 		<=  CFL_0_14;
		CFL_0_15_reg    	<=  CFL_0_15;

// -------------- 

		CFL_1_0_pos_reg 	<=	CFL_1_0_pos;	
		CFL_1_1_pos_reg 	<=  CFL_1_1_pos;
		CFL_1_2_pos_reg 	<=  CFL_1_2_pos;
		CFL_1_3_pos_reg    	<=  CFL_1_3_pos;
		CFL_1_4_pos_reg    	<=  CFL_1_4_pos;
		CFL_1_5_pos_reg 	<=  CFL_1_5_pos;
		CFL_1_6_pos_reg    	<=  CFL_1_6_pos;
		CFL_1_7_pos_reg    	<=  CFL_1_7_pos;
		CFL_1_8_pos_reg 	<=  CFL_1_8_pos;
		CFL_1_9_pos_reg    	<=  CFL_1_9_pos;
		CFL_1_10_pos_reg    <=  CFL_1_10_pos;
		CFL_1_11_pos_reg 	<=  CFL_1_11_pos;
		CFL_1_12_pos_reg    <=  CFL_1_12_pos;
		CFL_1_13_pos_reg    <=  CFL_1_13_pos;
		CFL_1_14_pos_reg 	<=  CFL_1_14_pos;
		CFL_1_15_pos_reg    <=  CFL_1_15_pos;

		CFL_1_0_neg_reg 	<=	CFL_1_0_neg;	
		CFL_1_1_neg_reg 	<=  CFL_1_1_neg;
		CFL_1_2_neg_reg 	<=  CFL_1_2_neg;
		CFL_1_3_neg_reg    	<=  CFL_1_3_neg;
		CFL_1_4_neg_reg    	<=  CFL_1_4_neg;
		CFL_1_5_neg_reg 	<=  CFL_1_5_neg;
		CFL_1_6_neg_reg    	<=  CFL_1_6_neg;
		CFL_1_7_neg_reg    	<=  CFL_1_7_neg;
		CFL_1_8_neg_reg 	<=  CFL_1_8_neg;
		CFL_1_9_neg_reg    	<=  CFL_1_9_neg;
		CFL_1_10_neg_reg    <=  CFL_1_10_neg;
		CFL_1_11_neg_reg 	<=  CFL_1_11_neg;
		CFL_1_12_neg_reg    <=  CFL_1_12_neg;
		CFL_1_13_neg_reg    <=  CFL_1_13_neg;
		CFL_1_14_neg_reg 	<=  CFL_1_14_neg;
		CFL_1_15_neg_reg    <=  CFL_1_15_neg;

// -------------- 

		CFL_2_0_pos_reg 	<=	CFL_2_0_pos;	
		CFL_2_1_pos_reg 	<=  CFL_2_1_pos;
		CFL_2_2_pos_reg 	<=  CFL_2_2_pos;
		CFL_2_3_pos_reg    	<=  CFL_2_3_pos;
		CFL_2_4_pos_reg    	<=  CFL_2_4_pos;
		CFL_2_5_pos_reg 	<=  CFL_2_5_pos;
		CFL_2_6_pos_reg    	<=  CFL_2_6_pos;
		CFL_2_7_pos_reg    	<=  CFL_2_7_pos;
		CFL_2_8_pos_reg 	<=  CFL_2_8_pos;
		CFL_2_9_pos_reg    	<=  CFL_2_9_pos;
		CFL_2_10_pos_reg    <=  CFL_2_10_pos;
		CFL_2_11_pos_reg 	<=  CFL_2_11_pos;
		CFL_2_12_pos_reg    <=  CFL_2_12_pos;
		CFL_2_13_pos_reg    <=  CFL_2_13_pos;
		CFL_2_14_pos_reg 	<=  CFL_2_14_pos;
		CFL_2_15_pos_reg    <=  CFL_2_15_pos;

		CFL_2_0_neg_reg 	<=	CFL_2_0_neg;	
		CFL_2_1_neg_reg 	<=  CFL_2_1_neg;
		CFL_2_2_neg_reg 	<=  CFL_2_2_neg;
		CFL_2_3_neg_reg    	<=  CFL_2_3_neg;
		CFL_2_4_neg_reg    	<=  CFL_2_4_neg;
		CFL_2_5_neg_reg 	<=  CFL_2_5_neg;
		CFL_2_6_neg_reg    	<=  CFL_2_6_neg;
		CFL_2_7_neg_reg    	<=  CFL_2_7_neg;
		CFL_2_8_neg_reg 	<=  CFL_2_8_neg;
		CFL_2_9_neg_reg    	<=  CFL_2_9_neg;
		CFL_2_10_neg_reg    <=  CFL_2_10_neg;
		CFL_2_11_neg_reg 	<=  CFL_2_11_neg;
		CFL_2_12_neg_reg    <=  CFL_2_12_neg;
		CFL_2_13_neg_reg    <=  CFL_2_13_neg;
		CFL_2_14_neg_reg 	<=  CFL_2_14_neg;
		CFL_2_15_neg_reg    <=  CFL_2_15_neg;

// --------------

		CFL_3_0_pos_reg 	<=	CFL_3_0_pos;	
		CFL_3_1_pos_reg 	<=  CFL_3_1_pos;
		CFL_3_2_pos_reg 	<=  CFL_3_2_pos;
		CFL_3_3_pos_reg    	<=  CFL_3_3_pos;
		CFL_3_4_pos_reg    	<=  CFL_3_4_pos;
		CFL_3_5_pos_reg 	<=  CFL_3_5_pos;
		CFL_3_6_pos_reg    	<=  CFL_3_6_pos;
		CFL_3_7_pos_reg    	<=  CFL_3_7_pos;
		CFL_3_8_pos_reg 	<=  CFL_3_8_pos;
		CFL_3_9_pos_reg    	<=  CFL_3_9_pos;
		CFL_3_10_pos_reg    <=  CFL_3_10_pos;
		CFL_3_11_pos_reg 	<=  CFL_3_11_pos;
		CFL_3_12_pos_reg    <=  CFL_3_12_pos;
		CFL_3_13_pos_reg    <=  CFL_3_13_pos;
		CFL_3_14_pos_reg 	<=  CFL_3_14_pos;
		CFL_3_15_pos_reg    <=  CFL_3_15_pos;

		CFL_3_0_neg_reg 	<=	CFL_3_0_neg;	
		CFL_3_1_neg_reg 	<=  CFL_3_1_neg;
		CFL_3_2_neg_reg 	<=  CFL_3_2_neg;
		CFL_3_3_neg_reg    	<=  CFL_3_3_neg;
		CFL_3_4_neg_reg    	<=  CFL_3_4_neg;
		CFL_3_5_neg_reg 	<=  CFL_3_5_neg;
		CFL_3_6_neg_reg    	<=  CFL_3_6_neg;
		CFL_3_7_neg_reg    	<=  CFL_3_7_neg;
		CFL_3_8_neg_reg 	<=  CFL_3_8_neg;
		CFL_3_9_neg_reg    	<=  CFL_3_9_neg;
		CFL_3_10_neg_reg    <=  CFL_3_10_neg;
		CFL_3_11_neg_reg 	<=  CFL_3_11_neg;
		CFL_3_12_neg_reg    <=  CFL_3_12_neg;
		CFL_3_13_neg_reg    <=  CFL_3_13_neg;
		CFL_3_14_neg_reg 	<=  CFL_3_14_neg;
		CFL_3_15_neg_reg    <=  CFL_3_15_neg;

// --------------

		CFL_4_0_pos_reg 	<=	CFL_4_0_pos;	
		CFL_4_1_pos_reg 	<=  CFL_4_1_pos;
		CFL_4_2_pos_reg 	<=  CFL_4_2_pos;
		CFL_4_3_pos_reg    	<=  CFL_4_3_pos;
		CFL_4_4_pos_reg    	<=  CFL_4_4_pos;
		CFL_4_5_pos_reg 	<=  CFL_4_5_pos;
		CFL_4_6_pos_reg    	<=  CFL_4_6_pos;
		CFL_4_7_pos_reg    	<=  CFL_4_7_pos;
		CFL_4_8_pos_reg 	<=  CFL_4_8_pos;
		CFL_4_9_pos_reg    	<=  CFL_4_9_pos;
		CFL_4_10_pos_reg    <=  CFL_4_10_pos;
		CFL_4_11_pos_reg 	<=  CFL_4_11_pos;
		CFL_4_12_pos_reg    <=  CFL_4_12_pos;
		CFL_4_13_pos_reg    <=  CFL_4_13_pos;
		CFL_4_14_pos_reg 	<=  CFL_4_14_pos;
		CFL_4_15_pos_reg    <=  CFL_4_15_pos;

		CFL_4_0_neg_reg 	<=	CFL_4_0_neg;	
		CFL_4_1_neg_reg 	<=  CFL_4_1_neg;
		CFL_4_2_neg_reg 	<=  CFL_4_2_neg;
		CFL_4_3_neg_reg    	<=  CFL_4_3_neg;
		CFL_4_4_neg_reg    	<=  CFL_4_4_neg;
		CFL_4_5_neg_reg 	<=  CFL_4_5_neg;
		CFL_4_6_neg_reg    	<=  CFL_4_6_neg;
		CFL_4_7_neg_reg    	<=  CFL_4_7_neg;
		CFL_4_8_neg_reg 	<=  CFL_4_8_neg;
		CFL_4_9_neg_reg    	<=  CFL_4_9_neg;
		CFL_4_10_neg_reg    <=  CFL_4_10_neg;
		CFL_4_11_neg_reg 	<=  CFL_4_11_neg;
		CFL_4_12_neg_reg    <=  CFL_4_12_neg;
		CFL_4_13_neg_reg    <=  CFL_4_13_neg;
		CFL_4_14_neg_reg 	<=  CFL_4_14_neg;
		CFL_4_15_neg_reg    <=  CFL_4_15_neg;

// --------------

		CFL_5_0_pos_reg 	<=	CFL_5_0_pos;	
		CFL_5_1_pos_reg 	<=  CFL_5_1_pos;
		CFL_5_2_pos_reg 	<=  CFL_5_2_pos;
		CFL_5_3_pos_reg    	<=  CFL_5_3_pos;
		CFL_5_4_pos_reg    	<=  CFL_5_4_pos;
		CFL_5_5_pos_reg 	<=  CFL_5_5_pos;
		CFL_5_6_pos_reg    	<=  CFL_5_6_pos;
		CFL_5_7_pos_reg    	<=  CFL_5_7_pos;
		CFL_5_8_pos_reg 	<=  CFL_5_8_pos;
		CFL_5_9_pos_reg    	<=  CFL_5_9_pos;
		CFL_5_10_pos_reg    <=  CFL_5_10_pos;
		CFL_5_11_pos_reg 	<=  CFL_5_11_pos;
		CFL_5_12_pos_reg    <=  CFL_5_12_pos;
		CFL_5_13_pos_reg    <=  CFL_5_13_pos;
		CFL_5_14_pos_reg 	<=  CFL_5_14_pos;
		CFL_5_15_pos_reg    <=  CFL_5_15_pos;

		CFL_5_0_neg_reg 	<=	CFL_5_0_neg;	
		CFL_5_1_neg_reg 	<=  CFL_5_1_neg;
		CFL_5_2_neg_reg 	<=  CFL_5_2_neg;
		CFL_5_3_neg_reg    	<=  CFL_5_3_neg;
		CFL_5_4_neg_reg    	<=  CFL_5_4_neg;
		CFL_5_5_neg_reg 	<=  CFL_5_5_neg;
		CFL_5_6_neg_reg    	<=  CFL_5_6_neg;
		CFL_5_7_neg_reg    	<=  CFL_5_7_neg;
		CFL_5_8_neg_reg 	<=  CFL_5_8_neg;
		CFL_5_9_neg_reg    	<=  CFL_5_9_neg;
		CFL_5_10_neg_reg    <=  CFL_5_10_neg;
		CFL_5_11_neg_reg 	<=  CFL_5_11_neg;
		CFL_5_12_neg_reg    <=  CFL_5_12_neg;
		CFL_5_13_neg_reg    <=  CFL_5_13_neg;
		CFL_5_14_neg_reg 	<=  CFL_5_14_neg;
		CFL_5_15_neg_reg    <=  CFL_5_15_neg;
		
// --------------
		
		CFL_6_0_pos_reg 	<=	CFL_6_0_pos;	
		CFL_6_1_pos_reg 	<=  CFL_6_1_pos;
		CFL_6_2_pos_reg 	<=  CFL_6_2_pos;
		CFL_6_3_pos_reg    	<=  CFL_6_3_pos;
		CFL_6_4_pos_reg    	<=  CFL_6_4_pos;
		CFL_6_5_pos_reg 	<=  CFL_6_5_pos;
		CFL_6_6_pos_reg    	<=  CFL_6_6_pos;
		CFL_6_7_pos_reg    	<=  CFL_6_7_pos;
		CFL_6_8_pos_reg 	<=  CFL_6_8_pos;
		CFL_6_9_pos_reg    	<=  CFL_6_9_pos;
		CFL_6_10_pos_reg    <=  CFL_6_10_pos;
		CFL_6_11_pos_reg 	<=  CFL_6_11_pos;
		CFL_6_12_pos_reg    <=  CFL_6_12_pos;
		CFL_6_13_pos_reg    <=  CFL_6_13_pos;
		CFL_6_14_pos_reg 	<=  CFL_6_14_pos;
		CFL_6_15_pos_reg    <=  CFL_6_15_pos;

		CFL_6_0_neg_reg 	<=	CFL_6_0_neg;	
		CFL_6_1_neg_reg 	<=  CFL_6_1_neg;
		CFL_6_2_neg_reg 	<=  CFL_6_2_neg;
		CFL_6_3_neg_reg    	<=  CFL_6_3_neg;
		CFL_6_4_neg_reg    	<=  CFL_6_4_neg;
		CFL_6_5_neg_reg 	<=  CFL_6_5_neg;
		CFL_6_6_neg_reg    	<=  CFL_6_6_neg;
		CFL_6_7_neg_reg    	<=  CFL_6_7_neg;
		CFL_6_8_neg_reg 	<=  CFL_6_8_neg;
		CFL_6_9_neg_reg    	<=  CFL_6_9_neg;
		CFL_6_10_neg_reg    <=  CFL_6_10_neg;
		CFL_6_11_neg_reg 	<=  CFL_6_11_neg;
		CFL_6_12_neg_reg    <=  CFL_6_12_neg;
		CFL_6_13_neg_reg    <=  CFL_6_13_neg;
		CFL_6_14_neg_reg 	<=  CFL_6_14_neg;
		CFL_6_15_neg_reg    <=  CFL_6_15_neg;
		
// --------------		
		
		CFL_7_0_pos_reg 	<=	CFL_7_0_pos;	
		CFL_7_1_pos_reg 	<=  CFL_7_1_pos;
		CFL_7_2_pos_reg 	<=  CFL_7_2_pos;
		CFL_7_3_pos_reg    	<=  CFL_7_3_pos;
		CFL_7_4_pos_reg    	<=  CFL_7_4_pos;
		CFL_7_5_pos_reg 	<=  CFL_7_5_pos;
		CFL_7_6_pos_reg    	<=  CFL_7_6_pos;
		CFL_7_7_pos_reg    	<=  CFL_7_7_pos;
		CFL_7_8_pos_reg 	<=  CFL_7_8_pos;
		CFL_7_9_pos_reg    	<=  CFL_7_9_pos;
		CFL_7_10_pos_reg    <=  CFL_7_10_pos;
		CFL_7_11_pos_reg 	<=  CFL_7_11_pos;
		CFL_7_12_pos_reg    <=  CFL_7_12_pos;
		CFL_7_13_pos_reg    <=  CFL_7_13_pos;
		CFL_7_14_pos_reg 	<=  CFL_7_14_pos;
		CFL_7_15_pos_reg    <=  CFL_7_15_pos;

		CFL_7_0_neg_reg 	<=	CFL_7_0_neg;	
		CFL_7_1_neg_reg 	<=  CFL_7_1_neg;
		CFL_7_2_neg_reg 	<=  CFL_7_2_neg;
		CFL_7_3_neg_reg    	<=  CFL_7_3_neg;
		CFL_7_4_neg_reg    	<=  CFL_7_4_neg;
		CFL_7_5_neg_reg 	<=  CFL_7_5_neg;
		CFL_7_6_neg_reg    	<=  CFL_7_6_neg;
		CFL_7_7_neg_reg    	<=  CFL_7_7_neg;
		CFL_7_8_neg_reg 	<=  CFL_7_8_neg;
		CFL_7_9_neg_reg    	<=  CFL_7_9_neg;
		CFL_7_10_neg_reg    <=  CFL_7_10_neg;
		CFL_7_11_neg_reg 	<=  CFL_7_11_neg;
		CFL_7_12_neg_reg    <=  CFL_7_12_neg;
		CFL_7_13_neg_reg    <=  CFL_7_13_neg;
		CFL_7_14_neg_reg 	<=  CFL_7_14_neg;
		CFL_7_15_neg_reg    <=  CFL_7_15_neg;		

// --------------		
		
		CFL_8_0_pos_reg 	<=	CFL_8_0_pos;	
		CFL_8_1_pos_reg 	<=  CFL_8_1_pos;
		CFL_8_2_pos_reg 	<=  CFL_8_2_pos;
		CFL_8_3_pos_reg    	<=  CFL_8_3_pos;
		CFL_8_4_pos_reg    	<=  CFL_8_4_pos;
		CFL_8_5_pos_reg 	<=  CFL_8_5_pos;
		CFL_8_6_pos_reg    	<=  CFL_8_6_pos;
		CFL_8_7_pos_reg    	<=  CFL_8_7_pos;
		CFL_8_8_pos_reg 	<=  CFL_8_8_pos;
		CFL_8_9_pos_reg    	<=  CFL_8_9_pos;
		CFL_8_10_pos_reg    <=  CFL_8_10_pos;
		CFL_8_11_pos_reg 	<=  CFL_8_11_pos;
		CFL_8_12_pos_reg    <=  CFL_8_12_pos;
		CFL_8_13_pos_reg    <=  CFL_8_13_pos;
		CFL_8_14_pos_reg 	<=  CFL_8_14_pos;
		CFL_8_15_pos_reg    <=  CFL_8_15_pos;

		CFL_8_0_neg_reg 	<=	CFL_8_0_neg;	
		CFL_8_1_neg_reg 	<=  CFL_8_1_neg;
		CFL_8_2_neg_reg 	<=  CFL_8_2_neg;
		CFL_8_3_neg_reg    	<=  CFL_8_3_neg;
		CFL_8_4_neg_reg    	<=  CFL_8_4_neg;
		CFL_8_5_neg_reg 	<=  CFL_8_5_neg;
		CFL_8_6_neg_reg    	<=  CFL_8_6_neg;
		CFL_8_7_neg_reg    	<=  CFL_8_7_neg;
		CFL_8_8_neg_reg 	<=  CFL_8_8_neg;
		CFL_8_9_neg_reg    	<=  CFL_8_9_neg;
		CFL_8_10_neg_reg    <=  CFL_8_10_neg;
		CFL_8_11_neg_reg 	<=  CFL_8_11_neg;
		CFL_8_12_neg_reg    <=  CFL_8_12_neg;
		CFL_8_13_neg_reg    <=  CFL_8_13_neg;
		CFL_8_14_neg_reg 	<=  CFL_8_14_neg;
		CFL_8_15_neg_reg    <=  CFL_8_15_neg;	

// --------------		
		
		CFL_9_0_pos_reg 	<=	CFL_9_0_pos;	
		CFL_9_1_pos_reg 	<=  CFL_9_1_pos;
		CFL_9_2_pos_reg 	<=  CFL_9_2_pos;
		CFL_9_3_pos_reg    	<=  CFL_9_3_pos;
		CFL_9_4_pos_reg    	<=  CFL_9_4_pos;
		CFL_9_5_pos_reg 	<=  CFL_9_5_pos;
		CFL_9_6_pos_reg    	<=  CFL_9_6_pos;
		CFL_9_7_pos_reg    	<=  CFL_9_7_pos;
		CFL_9_8_pos_reg 	<=  CFL_9_8_pos;
		CFL_9_9_pos_reg    	<=  CFL_9_9_pos;
		CFL_9_10_pos_reg    <=  CFL_9_10_pos;
		CFL_9_11_pos_reg 	<=  CFL_9_11_pos;
		CFL_9_12_pos_reg    <=  CFL_9_12_pos;
		CFL_9_13_pos_reg    <=  CFL_9_13_pos;
		CFL_9_14_pos_reg 	<=  CFL_9_14_pos;
		CFL_9_15_pos_reg    <=  CFL_9_15_pos;

		CFL_9_0_neg_reg 	<=	CFL_9_0_neg;	
		CFL_9_1_neg_reg 	<=  CFL_9_1_neg;
		CFL_9_2_neg_reg 	<=  CFL_9_2_neg;
		CFL_9_3_neg_reg    	<=  CFL_9_3_neg;
		CFL_9_4_neg_reg    	<=  CFL_9_4_neg;
		CFL_9_5_neg_reg 	<=  CFL_9_5_neg;
		CFL_9_6_neg_reg    	<=  CFL_9_6_neg;
		CFL_9_7_neg_reg    	<=  CFL_9_7_neg;
		CFL_9_8_neg_reg 	<=  CFL_9_8_neg;
		CFL_9_9_neg_reg    	<=  CFL_9_9_neg;
		CFL_9_10_neg_reg    <=  CFL_9_10_neg;
		CFL_9_11_neg_reg 	<=  CFL_9_11_neg;
		CFL_9_12_neg_reg    <=  CFL_9_12_neg;
		CFL_9_13_neg_reg    <=  CFL_9_13_neg;
		CFL_9_14_neg_reg 	<=  CFL_9_14_neg;
		CFL_9_15_neg_reg    <=  CFL_9_15_neg;	

// --------------		
		
		CFL_10_0_pos_reg 	 <=	 CFL_10_0_pos;	
		CFL_10_1_pos_reg 	 <=  CFL_10_1_pos;
		CFL_10_2_pos_reg 	 <=  CFL_10_2_pos;
		CFL_10_3_pos_reg     <=  CFL_10_3_pos;
		CFL_10_4_pos_reg     <=  CFL_10_4_pos;
		CFL_10_5_pos_reg 	 <=  CFL_10_5_pos;
		CFL_10_6_pos_reg     <=  CFL_10_6_pos;
		CFL_10_7_pos_reg     <=  CFL_10_7_pos;
		CFL_10_8_pos_reg 	 <=  CFL_10_8_pos;
		CFL_10_9_pos_reg     <=  CFL_10_9_pos;
		CFL_10_10_pos_reg    <=  CFL_10_10_pos;
		CFL_10_11_pos_reg 	 <=  CFL_10_11_pos;
		CFL_10_12_pos_reg    <=  CFL_10_12_pos;
		CFL_10_13_pos_reg    <=  CFL_10_13_pos;
		CFL_10_14_pos_reg 	 <=  CFL_10_14_pos;
		CFL_10_15_pos_reg    <=  CFL_10_15_pos;

		CFL_10_0_neg_reg 	<=	CFL_10_0_neg;	
		CFL_10_1_neg_reg 	<=  CFL_10_1_neg;
		CFL_10_2_neg_reg 	<=  CFL_10_2_neg;
		CFL_10_3_neg_reg    <=  CFL_10_3_neg;
		CFL_10_4_neg_reg    <=  CFL_10_4_neg;
		CFL_10_5_neg_reg 	<=  CFL_10_5_neg;
		CFL_10_6_neg_reg    <=  CFL_10_6_neg;
		CFL_10_7_neg_reg   	<=  CFL_10_7_neg;
		CFL_10_8_neg_reg 	<=  CFL_10_8_neg;
		CFL_10_9_neg_reg    <=  CFL_10_9_neg;
		CFL_10_10_neg_reg   <=  CFL_10_10_neg;
		CFL_10_11_neg_reg 	<=  CFL_10_11_neg;
		CFL_10_12_neg_reg   <=  CFL_10_12_neg;
		CFL_10_13_neg_reg   <=  CFL_10_13_neg;
		CFL_10_14_neg_reg 	<=  CFL_10_14_neg;
		CFL_10_15_neg_reg   <=  CFL_10_15_neg;

// --------------		
		
		CFL_11_0_pos_reg 	 <=	 CFL_11_0_pos;	
		CFL_11_1_pos_reg 	 <=  CFL_11_1_pos;
		CFL_11_2_pos_reg 	 <=  CFL_11_2_pos;
		CFL_11_3_pos_reg     <=  CFL_11_3_pos;
		CFL_11_4_pos_reg     <=  CFL_11_4_pos;
		CFL_11_5_pos_reg 	 <=  CFL_11_5_pos;
		CFL_11_6_pos_reg     <=  CFL_11_6_pos;
		CFL_11_7_pos_reg     <=  CFL_11_7_pos;
		CFL_11_8_pos_reg 	 <=  CFL_11_8_pos;
		CFL_11_9_pos_reg     <=  CFL_11_9_pos;
		CFL_11_10_pos_reg    <=  CFL_11_10_pos;
		CFL_11_11_pos_reg 	 <=  CFL_11_11_pos;
		CFL_11_12_pos_reg    <=  CFL_11_12_pos;
		CFL_11_13_pos_reg    <=  CFL_11_13_pos;
		CFL_11_14_pos_reg 	 <=  CFL_11_14_pos;
		CFL_11_15_pos_reg    <=  CFL_11_15_pos;

		CFL_11_0_neg_reg 	<=	CFL_11_0_neg;	
		CFL_11_1_neg_reg 	<=  CFL_11_1_neg;
		CFL_11_2_neg_reg 	<=  CFL_11_2_neg;
		CFL_11_3_neg_reg    <=  CFL_11_3_neg;
		CFL_11_4_neg_reg    <=  CFL_11_4_neg;
		CFL_11_5_neg_reg 	<=  CFL_11_5_neg;
		CFL_11_6_neg_reg    <=  CFL_11_6_neg;
		CFL_11_7_neg_reg   	<=  CFL_11_7_neg;
		CFL_11_8_neg_reg 	<=  CFL_11_8_neg;
		CFL_11_9_neg_reg    <=  CFL_11_9_neg;
		CFL_11_10_neg_reg   <=  CFL_11_10_neg;
		CFL_11_11_neg_reg 	<=  CFL_11_11_neg;
		CFL_11_12_neg_reg   <=  CFL_11_12_neg;
		CFL_11_13_neg_reg   <=  CFL_11_13_neg;
		CFL_11_14_neg_reg 	<=  CFL_11_14_neg;
		CFL_11_15_neg_reg   <=  CFL_11_15_neg;

// --------------		
		
		CFL_12_0_pos_reg 	 <=	 CFL_12_0_pos;	
		CFL_12_1_pos_reg 	 <=  CFL_12_1_pos;
		CFL_12_2_pos_reg 	 <=  CFL_12_2_pos;
		CFL_12_3_pos_reg     <=  CFL_12_3_pos;
		CFL_12_4_pos_reg     <=  CFL_12_4_pos;
		CFL_12_5_pos_reg 	 <=  CFL_12_5_pos;
		CFL_12_6_pos_reg     <=  CFL_12_6_pos;
		CFL_12_7_pos_reg     <=  CFL_12_7_pos;
		CFL_12_8_pos_reg 	 <=  CFL_12_8_pos;
		CFL_12_9_pos_reg     <=  CFL_12_9_pos;
		CFL_12_10_pos_reg    <=  CFL_12_10_pos;
		CFL_12_11_pos_reg 	 <=  CFL_12_11_pos;
		CFL_12_12_pos_reg    <=  CFL_12_12_pos;
		CFL_12_13_pos_reg    <=  CFL_12_13_pos;
		CFL_12_14_pos_reg 	 <=  CFL_12_14_pos;
		CFL_12_15_pos_reg    <=  CFL_12_15_pos;

		CFL_12_0_neg_reg 	<=	CFL_12_0_neg;	
		CFL_12_1_neg_reg 	<=  CFL_12_1_neg;
		CFL_12_2_neg_reg 	<=  CFL_12_2_neg;
		CFL_12_3_neg_reg    <=  CFL_12_3_neg;
		CFL_12_4_neg_reg    <=  CFL_12_4_neg;
		CFL_12_5_neg_reg 	<=  CFL_12_5_neg;
		CFL_12_6_neg_reg    <=  CFL_12_6_neg;
		CFL_12_7_neg_reg   	<=  CFL_12_7_neg;
		CFL_12_8_neg_reg 	<=  CFL_12_8_neg;
		CFL_12_9_neg_reg    <=  CFL_12_9_neg;
		CFL_12_10_neg_reg   <=  CFL_12_10_neg;
		CFL_12_11_neg_reg 	<=  CFL_12_11_neg;
		CFL_12_12_neg_reg   <=  CFL_12_12_neg;
		CFL_12_13_neg_reg   <=  CFL_12_13_neg;
		CFL_12_14_neg_reg 	<=  CFL_12_14_neg;
		CFL_12_15_neg_reg   <=  CFL_12_15_neg;

// --------------		
		
		CFL_13_0_pos_reg 	 <=	 CFL_13_0_pos;	
		CFL_13_1_pos_reg 	 <=  CFL_13_1_pos;
		CFL_13_2_pos_reg 	 <=  CFL_13_2_pos;
		CFL_13_3_pos_reg     <=  CFL_13_3_pos;
		CFL_13_4_pos_reg     <=  CFL_13_4_pos;
		CFL_13_5_pos_reg 	 <=  CFL_13_5_pos;
		CFL_13_6_pos_reg     <=  CFL_13_6_pos;
		CFL_13_7_pos_reg     <=  CFL_13_7_pos;
		CFL_13_8_pos_reg 	 <=  CFL_13_8_pos;
		CFL_13_9_pos_reg     <=  CFL_13_9_pos;
		CFL_13_10_pos_reg    <=  CFL_13_10_pos;
		CFL_13_11_pos_reg 	 <=  CFL_13_11_pos;
		CFL_13_12_pos_reg    <=  CFL_13_12_pos;
		CFL_13_13_pos_reg    <=  CFL_13_13_pos;
		CFL_13_14_pos_reg 	 <=  CFL_13_14_pos;
		CFL_13_15_pos_reg    <=  CFL_13_15_pos;

		CFL_13_0_neg_reg 	<=	CFL_13_0_neg;	
		CFL_13_1_neg_reg 	<=  CFL_13_1_neg;
		CFL_13_2_neg_reg 	<=  CFL_13_2_neg;
		CFL_13_3_neg_reg    <=  CFL_13_3_neg;
		CFL_13_4_neg_reg    <=  CFL_13_4_neg;
		CFL_13_5_neg_reg 	<=  CFL_13_5_neg;
		CFL_13_6_neg_reg    <=  CFL_13_6_neg;
		CFL_13_7_neg_reg   	<=  CFL_13_7_neg;
		CFL_13_8_neg_reg 	<=  CFL_13_8_neg;
		CFL_13_9_neg_reg    <=  CFL_13_9_neg;
		CFL_13_10_neg_reg   <=  CFL_13_10_neg;
		CFL_13_11_neg_reg 	<=  CFL_13_11_neg;
		CFL_13_12_neg_reg   <=  CFL_13_12_neg;
		CFL_13_13_neg_reg   <=  CFL_13_13_neg;
		CFL_13_14_neg_reg 	<=  CFL_13_14_neg;
		CFL_13_15_neg_reg   <=  CFL_13_15_neg;

// --------------		
		
		CFL_14_0_pos_reg 	 <=	 CFL_14_0_pos;	
		CFL_14_1_pos_reg 	 <=  CFL_14_1_pos;
		CFL_14_2_pos_reg 	 <=  CFL_14_2_pos;
		CFL_14_3_pos_reg     <=  CFL_14_3_pos;
		CFL_14_4_pos_reg     <=  CFL_14_4_pos;
		CFL_14_5_pos_reg 	 <=  CFL_14_5_pos;
		CFL_14_6_pos_reg     <=  CFL_14_6_pos;
		CFL_14_7_pos_reg     <=  CFL_14_7_pos;
		CFL_14_8_pos_reg 	 <=  CFL_14_8_pos;
		CFL_14_9_pos_reg     <=  CFL_14_9_pos;
		CFL_14_10_pos_reg    <=  CFL_14_10_pos;
		CFL_14_11_pos_reg 	 <=  CFL_14_11_pos;
		CFL_14_12_pos_reg    <=  CFL_14_12_pos;
		CFL_14_13_pos_reg    <=  CFL_14_13_pos;
		CFL_14_14_pos_reg 	 <=  CFL_14_14_pos;
		CFL_14_15_pos_reg    <=  CFL_14_15_pos;

		CFL_14_0_neg_reg 	<=	CFL_14_0_neg;	
		CFL_14_1_neg_reg 	<=  CFL_14_1_neg;
		CFL_14_2_neg_reg 	<=  CFL_14_2_neg;
		CFL_14_3_neg_reg    <=  CFL_14_3_neg;
		CFL_14_4_neg_reg    <=  CFL_14_4_neg;
		CFL_14_5_neg_reg 	<=  CFL_14_5_neg;
		CFL_14_6_neg_reg    <=  CFL_14_6_neg;
		CFL_14_7_neg_reg   	<=  CFL_14_7_neg;
		CFL_14_8_neg_reg 	<=  CFL_14_8_neg;
		CFL_14_9_neg_reg    <=  CFL_14_9_neg;
		CFL_14_10_neg_reg   <=  CFL_14_10_neg;
		CFL_14_11_neg_reg 	<=  CFL_14_11_neg;
		CFL_14_12_neg_reg   <=  CFL_14_12_neg;
		CFL_14_13_neg_reg   <=  CFL_14_13_neg;
		CFL_14_14_neg_reg 	<=  CFL_14_14_neg;
		CFL_14_15_neg_reg   <=  CFL_14_15_neg;

// --------------		
		
		CFL_15_0_pos_reg 	 <=	 CFL_15_0_pos;	
		CFL_15_1_pos_reg 	 <=  CFL_15_1_pos;
		CFL_15_2_pos_reg 	 <=  CFL_15_2_pos;
		CFL_15_3_pos_reg     <=  CFL_15_3_pos;
		CFL_15_4_pos_reg     <=  CFL_15_4_pos;
		CFL_15_5_pos_reg 	 <=  CFL_15_5_pos;
		CFL_15_6_pos_reg     <=  CFL_15_6_pos;
		CFL_15_7_pos_reg     <=  CFL_15_7_pos;
		CFL_15_8_pos_reg 	 <=  CFL_15_8_pos;
		CFL_15_9_pos_reg     <=  CFL_15_9_pos;
		CFL_15_10_pos_reg    <=  CFL_15_10_pos;
		CFL_15_11_pos_reg 	 <=  CFL_15_11_pos;
		CFL_15_12_pos_reg    <=  CFL_15_12_pos;
		CFL_15_13_pos_reg    <=  CFL_15_13_pos;
		CFL_15_14_pos_reg 	 <=  CFL_15_14_pos;
		CFL_15_15_pos_reg    <=  CFL_15_15_pos;

		CFL_15_0_neg_reg 	<=	CFL_15_0_neg;	
		CFL_15_1_neg_reg 	<=  CFL_15_1_neg;
		CFL_15_2_neg_reg 	<=  CFL_15_2_neg;
		CFL_15_3_neg_reg    <=  CFL_15_3_neg;
		CFL_15_4_neg_reg    <=  CFL_15_4_neg;
		CFL_15_5_neg_reg 	<=  CFL_15_5_neg;
		CFL_15_6_neg_reg    <=  CFL_15_6_neg;
		CFL_15_7_neg_reg   	<=  CFL_15_7_neg;
		CFL_15_8_neg_reg 	<=  CFL_15_8_neg;
		CFL_15_9_neg_reg    <=  CFL_15_9_neg;
		CFL_15_10_neg_reg   <=  CFL_15_10_neg;
		CFL_15_11_neg_reg 	<=  CFL_15_11_neg;
		CFL_15_12_neg_reg   <=  CFL_15_12_neg;
		CFL_15_13_neg_reg   <=  CFL_15_13_neg;
		CFL_15_14_neg_reg 	<=  CFL_15_14_neg;
		CFL_15_15_neg_reg   <=  CFL_15_15_neg;

// --------------		
		
		CFL_16_0_pos_reg 	 <=	 CFL_16_0_pos;	
		CFL_16_1_pos_reg 	 <=  CFL_16_1_pos;
		CFL_16_2_pos_reg 	 <=  CFL_16_2_pos;
		CFL_16_3_pos_reg     <=  CFL_16_3_pos;
		CFL_16_4_pos_reg     <=  CFL_16_4_pos;
		CFL_16_5_pos_reg 	 <=  CFL_16_5_pos;
		CFL_16_6_pos_reg     <=  CFL_16_6_pos;
		CFL_16_7_pos_reg     <=  CFL_16_7_pos;
		CFL_16_8_pos_reg 	 <=  CFL_16_8_pos;
		CFL_16_9_pos_reg     <=  CFL_16_9_pos;
		CFL_16_10_pos_reg    <=  CFL_16_10_pos;
		CFL_16_11_pos_reg 	 <=  CFL_16_11_pos;
		CFL_16_12_pos_reg    <=  CFL_16_12_pos;
		CFL_16_13_pos_reg    <=  CFL_16_13_pos;
		CFL_16_14_pos_reg 	 <=  CFL_16_14_pos;
		CFL_16_15_pos_reg    <=  CFL_16_15_pos;

		CFL_16_0_neg_reg 	<=	CFL_16_0_neg;	
		CFL_16_1_neg_reg 	<=  CFL_16_1_neg;
		CFL_16_2_neg_reg 	<=  CFL_16_2_neg;
		CFL_16_3_neg_reg    <=  CFL_16_3_neg;
		CFL_16_4_neg_reg    <=  CFL_16_4_neg;
		CFL_16_5_neg_reg 	<=  CFL_16_5_neg;
		CFL_16_6_neg_reg    <=  CFL_16_6_neg;
		CFL_16_7_neg_reg   	<=  CFL_16_7_neg;
		CFL_16_8_neg_reg 	<=  CFL_16_8_neg;
		CFL_16_9_neg_reg    <=  CFL_16_9_neg;
		CFL_16_10_neg_reg   <=  CFL_16_10_neg;
		CFL_16_11_neg_reg 	<=  CFL_16_11_neg;
		CFL_16_12_neg_reg   <=  CFL_16_12_neg;
		CFL_16_13_neg_reg   <=  CFL_16_13_neg;
		CFL_16_14_neg_reg 	<=  CFL_16_14_neg;
		CFL_16_15_neg_reg   <=  CFL_16_15_neg;
		
	end  

 	// Pipeline Fourth Stage - CFL_Final = CFL + DC_Chroma	
	always @(posedge clk_i) begin
		
		address_row_fourth_reg	  	<= address_row_third_reg;
		address_column_fourth_reg 	<= address_column_third_reg;
		CFL_final_ready_fourth_reg	<= CFL_final_ready_third_reg; 
		
			case (alpha_index_i)
			
				5'd0  : begin
							CFL_final_0_reg  <= CFL_0_0_reg   +  DC_Intra_Chr_third; 
							CFL_final_1_reg  <= CFL_0_1_reg   +  DC_Intra_Chr_third;  
							CFL_final_2_reg  <= CFL_0_2_reg   +  DC_Intra_Chr_third;  
							CFL_final_3_reg  <= CFL_0_3_reg   +  DC_Intra_Chr_third;  
							CFL_final_4_reg  <= CFL_0_4_reg   +  DC_Intra_Chr_third;  
							CFL_final_5_reg  <= CFL_0_5_reg   +  DC_Intra_Chr_third;  
							CFL_final_6_reg  <= CFL_0_6_reg   +  DC_Intra_Chr_third;  
							CFL_final_7_reg  <= CFL_0_7_reg   +  DC_Intra_Chr_third;  
							CFL_final_8_reg  <= CFL_0_8_reg   +  DC_Intra_Chr_third;  
							CFL_final_9_reg  <= CFL_0_9_reg   +  DC_Intra_Chr_third;  
							CFL_final_10_reg <= CFL_0_10_reg  +  DC_Intra_Chr_third; 
							CFL_final_11_reg <= CFL_0_11_reg  +  DC_Intra_Chr_third; 
							CFL_final_12_reg <= CFL_0_12_reg  +  DC_Intra_Chr_third; 
							CFL_final_13_reg <= CFL_0_13_reg  +  DC_Intra_Chr_third; 
							CFL_final_14_reg <= CFL_0_14_reg  +  DC_Intra_Chr_third; 
							CFL_final_15_reg <= CFL_0_15_reg  +  DC_Intra_Chr_third; 
						end

				5'd1  : begin 			
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_1_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_1_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_1_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_1_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_1_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_1_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_1_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_1_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_1_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_1_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_1_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_1_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_1_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_1_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_1_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_1_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_1_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_1_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_1_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_1_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_1_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_1_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_1_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_1_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_1_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_1_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_1_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_1_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_1_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_1_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_1_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_1_15_neg_reg  +  DC_Intra_Chr_third;
							end
						end 
					
				5'd2  :	begin 
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_2_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_2_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_2_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_2_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_2_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_2_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_2_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_2_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_2_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_2_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_2_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_2_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_2_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_2_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_2_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_2_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_2_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_2_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_2_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_2_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_2_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_2_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_2_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_2_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_2_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_2_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_2_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_2_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_2_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_2_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_2_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_2_15_neg_reg  +  DC_Intra_Chr_third;
							end				
						end 
					
				5'd3  :	begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_3_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_3_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_3_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_3_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_3_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_3_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_3_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_3_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_3_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_3_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_3_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_3_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_3_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_3_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_3_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_3_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_3_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_3_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_3_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_3_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_3_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_3_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_3_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_3_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_3_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_3_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_3_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_3_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_3_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_3_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_3_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_3_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end
						
				5'd4  : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_4_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_4_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_4_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_4_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_4_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_4_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_4_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_4_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_4_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_4_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_4_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_4_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_4_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_4_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_4_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_4_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_4_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_4_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_4_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_4_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_4_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_4_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_4_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_4_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_4_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_4_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_4_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_4_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_4_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_4_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_4_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_4_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end
					
				5'd5  : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_5_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_5_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_5_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_5_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_5_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_5_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_5_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_5_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_5_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_5_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_5_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_5_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_5_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_5_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_5_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_5_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_5_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_5_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_5_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_5_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_5_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_5_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_5_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_5_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_5_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_5_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_5_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_5_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_5_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_5_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_5_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_5_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end

				5'd6  : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_6_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_6_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_6_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_6_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_6_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_6_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_6_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_6_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_6_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_6_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_6_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_6_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_6_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_6_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_6_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_6_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_6_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_6_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_6_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_6_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_6_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_6_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_6_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_6_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_6_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_6_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_6_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_6_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_6_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_6_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_6_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_6_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end

				5'd7  : begin 
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_7_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_7_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_7_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_7_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_7_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_7_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_7_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_7_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_7_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_7_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_7_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_7_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_7_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_7_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_7_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_7_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_7_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_7_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_7_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_7_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_7_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_7_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_7_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_7_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_7_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_7_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_7_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_7_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_7_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_7_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_7_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_7_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end 
						
				5'd8  : begin 
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_8_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_8_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_8_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_8_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_8_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_8_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_8_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_8_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_8_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_8_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_8_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_8_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_8_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_8_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_8_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_8_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_8_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_8_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_8_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_8_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_8_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_8_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_8_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_8_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_8_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_8_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_8_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_8_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_8_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_8_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_8_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_8_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end 

				5'd9  :	begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_9_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_9_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_9_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_9_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_9_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_9_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_9_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_9_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_9_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_9_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_9_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_9_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_9_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_9_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_9_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_9_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_9_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_9_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_9_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_9_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_9_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_9_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_9_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_9_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_9_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_9_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_9_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_9_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_9_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_9_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_9_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_9_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end 
				
				5'd10 : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_10_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_10_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_10_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_10_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_10_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_10_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_10_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_10_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_10_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_10_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_10_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_10_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_10_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_10_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_10_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_10_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_10_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_10_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_10_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_10_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_10_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_10_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_10_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_10_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_10_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_10_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_10_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_10_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_10_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_10_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_10_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_10_15_neg_reg  +  DC_Intra_Chr_third;
							end		
						end 

				5'd11 : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_11_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_11_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_11_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_11_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_11_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_11_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_11_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_11_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_11_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_11_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_11_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_11_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_11_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_11_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_11_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_11_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_11_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_11_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_11_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_11_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_11_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_11_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_11_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_11_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_11_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_11_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_11_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_11_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_11_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_11_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_11_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_11_15_neg_reg  +  DC_Intra_Chr_third;
							end
						end
	
				5'd12 : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_12_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_12_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_12_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_12_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_12_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_12_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_12_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_12_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_12_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_12_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_12_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_12_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_12_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_12_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_12_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_12_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_12_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_12_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_12_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_12_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_12_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_12_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_12_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_12_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_12_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_12_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_12_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_12_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_12_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_12_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_12_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_12_15_neg_reg  +  DC_Intra_Chr_third;
							end		
						end 
				
				5'd13 : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_13_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_13_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_13_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_13_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_13_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_13_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_13_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_13_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_13_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_13_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_13_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_13_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_13_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_13_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_13_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_13_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_13_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_13_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_13_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_13_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_13_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_13_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_13_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_13_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_13_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_13_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_13_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_13_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_13_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_13_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_13_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_13_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end
				
				5'd14 : begin 
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_14_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_14_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_14_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_14_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_14_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_14_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_14_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_14_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_14_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_14_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_14_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_14_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_14_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_14_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_14_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_14_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_14_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_14_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_14_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_14_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_14_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_14_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_14_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_14_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_14_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_14_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_14_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_14_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_14_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_14_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_14_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_14_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end 
				
				5'd15 : begin 
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_15_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_15_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_15_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_15_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_15_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_15_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_15_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_15_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_15_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_15_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_15_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_15_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_15_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_15_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_15_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_15_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_15_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_15_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_15_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_15_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_15_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_15_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_15_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_15_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_15_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_15_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_15_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_15_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_15_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_15_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_15_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_15_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end
						
				5'd16 : begin
							if(!alpha_sign_i) begin 
								CFL_final_0_reg    <= 	CFL_16_0_pos_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_16_1_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_16_2_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_16_3_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_16_4_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_16_5_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_16_6_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_16_7_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_16_8_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_16_9_pos_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_16_10_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_16_11_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_16_12_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_16_13_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_16_14_pos_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_16_15_pos_reg  +  DC_Intra_Chr_third;
							end else begin 
								CFL_final_0_reg    <= 	CFL_16_0_neg_reg   +  DC_Intra_Chr_third;
								CFL_final_1_reg    <= 	CFL_16_1_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_2_reg    <=   CFL_16_2_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_3_reg    <=   CFL_16_3_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_4_reg    <=   CFL_16_4_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_5_reg    <=   CFL_16_5_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_6_reg    <=   CFL_16_6_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_7_reg    <=   CFL_16_7_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_8_reg    <=	CFL_16_8_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_9_reg    <=	CFL_16_9_neg_reg   +  DC_Intra_Chr_third;
                                CFL_final_10_reg   <=	CFL_16_10_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_11_reg   <=	CFL_16_11_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_12_reg   <=	CFL_16_12_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_13_reg   <=	CFL_16_13_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_14_reg   <=	CFL_16_14_neg_reg  +  DC_Intra_Chr_third;
                                CFL_final_15_reg   <=	CFL_16_15_neg_reg  +  DC_Intra_Chr_third;
							end	
						end
						
				default: begin 
							CFL_final_0_reg    <=	0; 
							CFL_final_1_reg    <=	0; 
							CFL_final_2_reg    <=	0; 
							CFL_final_3_reg    <=	0; 
							CFL_final_4_reg    <=	0; 
							CFL_final_5_reg    <=	0; 
							CFL_final_6_reg    <=	0; 
							CFL_final_7_reg    <=	0; 
							CFL_final_8_reg    <=	0; 
							CFL_final_9_reg    <=	0; 
							CFL_final_10_reg   <=	0; 
							CFL_final_11_reg   <=	0; 
							CFL_final_12_reg   <=	0; 
							CFL_final_13_reg   <=	0; 
							CFL_final_14_reg   <=	0; 
						    CFL_final_15_reg   <=	0; 
						end 
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
	assign address_row_o     = address_row_fourth_reg;
	assign address_column_o  = address_column_fourth_reg;
	assign CFL_final_ready_o = CFL_final_ready_fourth_reg;

	assign CFL_final_0_o	 = (CFL_final_0_reg < 0)    ? 0    :
							   (CFL_final_0_reg > 1023) ? 1023 : 
							   CFL_final_0_reg;

	assign CFL_final_1_o	 = (CFL_final_1_reg < 0)    ? 0    :
							   (CFL_final_1_reg > 1023) ? 1023 : 
							   CFL_final_1_reg;							   
							   
	assign CFL_final_2_o	 = (CFL_final_2_reg < 0)    ? 0    :
							   (CFL_final_2_reg > 1023) ? 1023 : 
							   CFL_final_2_reg;		

	assign CFL_final_3_o	 = (CFL_final_3_reg < 0)    ? 0    :
							   (CFL_final_3_reg > 1023) ? 1023 : 
							   CFL_final_3_reg;	

	assign CFL_final_4_o	 = (CFL_final_4_reg < 0)    ? 0    :
							   (CFL_final_4_reg > 1023) ? 1023 : 
							   CFL_final_4_reg;	

	assign CFL_final_5_o	 = (CFL_final_5_reg < 0)    ? 0    :
							   (CFL_final_5_reg > 1023) ? 1023 : 
							   CFL_final_5_reg;	

	assign CFL_final_6_o	 = (CFL_final_6_reg < 0)    ? 0    :
							   (CFL_final_6_reg > 1023) ? 1023 : 
							   CFL_final_6_reg;	

	assign CFL_final_7_o	 = (CFL_final_7_reg < 0)    ? 0    :
							   (CFL_final_7_reg > 1023) ? 1023 : 
							   CFL_final_7_reg;		

	assign CFL_final_8_o	 = (CFL_final_8_reg < 0)    ? 0    :
							   (CFL_final_8_reg > 1023) ? 1023 : 
							   CFL_final_8_reg;

	assign CFL_final_9_o	 = (CFL_final_9_reg < 0)    ? 0    :
							   (CFL_final_9_reg > 1023) ? 1023 : 
							   CFL_final_9_reg;	

	assign CFL_final_10_o	 = (CFL_final_10_reg < 0)    ? 0    :
							   (CFL_final_10_reg > 1023) ? 1023 : 
							   CFL_final_10_reg;		

	assign CFL_final_11_o	 = (CFL_final_11_reg < 0)    ? 0    :
							   (CFL_final_11_reg > 1023) ? 1023 : 
							   CFL_final_11_reg;

	assign CFL_final_12_o	 = (CFL_final_12_reg < 0)    ? 0    :
							   (CFL_final_12_reg > 1023) ? 1023 : 
							   CFL_final_12_reg;

	assign CFL_final_13_o	 = (CFL_final_13_reg < 0)    ? 0    :
							   (CFL_final_13_reg > 1023) ? 1023 : 
							   CFL_final_13_reg;

	assign CFL_final_14_o	 = (CFL_final_14_reg < 0)    ? 0    :
							   (CFL_final_14_reg > 1023) ? 1023 : 
							   CFL_final_14_reg;	

	assign CFL_final_15_o	 = (CFL_final_15_reg < 0)    ? 0    :
							   (CFL_final_15_reg > 1023) ? 1023 : 
							   CFL_final_15_reg;							   

endmodule 