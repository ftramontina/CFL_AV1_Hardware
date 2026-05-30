
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
	
	input wire [width_p-1:0] sample_in_a_1_i,
	input wire [width_p-1:0] sample_in_a_2_i,
	
	input wire [width_p-1:0] sample_in_b_1_i,
	input wire [width_p-1:0] sample_in_b_2_i,
	
	input wire load_en_i,
	
	output wire mem_read_en_o, 
	output wire mem_write_en_o, 
	//output wire luma_memory_rst_o,
	
	output wire [6:0] row_addr_a_1_o,
	output wire [6:0] column_addr_a_1_o,	
	output wire [6:0] row_addr_a_2_o,
	output wire [6:0] column_addr_a_2_o,
	
	output wire [6:0] row_addr_b_1_o,
	output wire [6:0] column_addr_b_1_o,
	output wire [6:0] row_addr_b_2_o,
	output wire [6:0] column_addr_b_2_o,

	output wire [6:0] row_addr_c_1_o,
	output wire [6:0] column_addr_c_1_o,
	output wire [6:0] row_addr_c_2_o,
	output wire [6:0] column_addr_c_2_o,

	output wire [width_p-1:0] sample_out_a_o,
	output wire [width_p-1:0] sample_out_b_o,
	
	output wire [3:0] div_shift_o,
	output wire samples_loaded_o,
	
	output wire [7:0] block_sub_row_o,
	output wire [7:0] block_sub_column_o
	
  );

// State definitions
parameter IDLE 		= 3'b000;
parameter LOAD_1	= 3'b001;
parameter LOAD_2 	= 3'b010;
parameter STOP_1	= 3'b011;
parameter STOP_2  	= 3'b100;
parameter DIV       = 3'b101;  
parameter WRITE     = 3'b111; 

reg sub_4_2_0_en; 
reg sub_4_2_2_en; 
reg start_reg_4_2_0;

reg [6:0] row_addr_a_1_reg    = 0;
reg [6:0] column_addr_a_1_reg = 0;	
reg [6:0] row_addr_a_2_reg    = 0;
reg [6:0] column_addr_a_2_reg = 0;

reg [6:0] row_addr_b_1_reg    = 0;
reg [6:0] column_addr_b_1_reg = 0;	
reg [6:0] row_addr_b_2_reg    = 0;
reg [6:0] column_addr_b_2_reg = 0;

reg [6:0] row_addr_c_1_reg    = 0;
reg [6:0] column_addr_c_1_reg = 0;	
reg [6:0] row_addr_c_2_reg    = 0;
reg [6:0] column_addr_c_2_reg = 0;

reg sample_load_finished_ch_a = 0;
reg sample_load_finished_ch_b = 0; 

reg [15:0] sample_in_a_reg = 0;
reg [15:0] sample_in_b_reg = 0;

reg [15:0] sample_out_a_reg = 0;
reg [15:0] sample_out_b_reg = 0;

reg [2:0] state; 

reg mem_read_en_reg    = 0;
reg mem_write_en_reg   = 0; 
reg first_write_reg    = 0;
reg samples_loaded_reg = 0;  

reg [3:0] counter_1 = 0;  
reg [3:0] counter_2 = 0;  

reg [7:0] block_width_reg;
reg [7:0] block_height_reg;

reg [3:0] div_shift_reg = 0; 

reg [7:0] block_sub_row_reg    = 0;
reg [7:0] block_sub_column_reg = 0;

//reg luma_memory_rst; 

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
	
	// FSM for load 4:2:0 and 4:2:2 samples 
	
	always @(posedge clk_i) begin
		if (rst_i) begin
			state <= IDLE;
			sample_in_a_reg <= 0; 
			sample_in_b_reg <= 0; 
			sample_load_finished_ch_a  <= 0; 
			sample_load_finished_ch_b  <= 0;
			sample_out_a_reg <= 0; 
			row_addr_a_1_reg <= 0; 
			row_addr_a_2_reg <= 0; 
			row_addr_b_1_reg <= 0; 
			row_addr_b_2_reg <= 0; 
			column_addr_a_1_reg <= 0; 
			column_addr_a_2_reg <= 0; 
			column_addr_b_1_reg <= 0; 
			column_addr_b_2_reg <= 0; 
			mem_read_en_reg  <= 0; 
			start_reg_4_2_0  <= 0;
			first_write_reg  <= 0; 
			div_shift_reg    <= 0; 
			
		end else begin		
			case(state)				
			
				IDLE: begin
					block_width_reg  <= block_width_i;
					block_height_reg <= block_height_i;
					sample_load_finished_ch_a <= 0; 
					sample_load_finished_ch_b <= 0; 
					samples_loaded_reg        <= 0;
					//luma_memory_rst			  <= 0;
					
					if(sub_4_2_0_en || sub_4_2_2_en) begin
						state <= LOAD_1;
						
						if(sub_4_2_0_en) begin 
							start_reg_4_2_0 <= 1;
						end  
						
					end else begin 
						state <= IDLE;
					end 
				end
				
				LOAD_1: begin 
						
					row_addr_a_1_reg    <= row_addr_a_1_reg;
					column_addr_a_1_reg <= column_addr_a_1_reg;

					row_addr_a_2_reg    <= row_addr_a_2_reg;
					column_addr_a_2_reg <= column_addr_a_2_reg + 1;
					
					row_addr_b_1_reg    <= row_addr_b_1_reg;
					column_addr_b_1_reg <= column_addr_b_1_reg + 2; 

					row_addr_b_2_reg    <= row_addr_b_2_reg;
					column_addr_b_2_reg <= column_addr_b_2_reg + 3;
					
					state            <= STOP_1; 
					mem_read_en_reg <= 1; 
				end
				
				STOP_1: begin 
					mem_read_en_reg <= 0; 
					
					if(counter_1 < 1) begin 
						counter_1 <= counter_1 + 1; 
						state   <= STOP_1;
						
					end else begin 
						if(sample_load_finished_ch_a && sample_load_finished_ch_b) begin 
							sample_in_a_reg <= 0; 
							sample_in_b_reg <= 0;
							state <= IDLE; 
						end else begin 
							sample_in_a_reg <= sample_in_a_1_i + sample_in_a_2_i + sample_in_a_reg;
							sample_in_b_reg <= sample_in_b_1_i + sample_in_b_2_i + sample_in_b_reg;		
						end 
						
						if(sub_4_2_0_en) begin 
							counter_1 <= 0;
							state <= LOAD_2;
							
						end else if(sub_4_2_2_en) begin 
							counter_1 <= 0;
							state <= DIV;
						end 
					end
				 end  
					
				LOAD_2: begin 
				
					mem_write_en_reg <= 0;

  					if(sub_4_2_0_en) begin 
						if((row_addr_c_2_reg == (block_height_reg/2)-1) && (column_addr_c_2_reg == (block_width_reg/2)-1)) begin 
							row_addr_c_1_reg    <= 0;
							row_addr_c_2_reg    <= 0; 
							column_addr_c_1_reg <= 0;									
							column_addr_c_2_reg <= 0;
							first_write_reg     <= 0;
							samples_loaded_reg  <= 1;
							sample_out_a_reg    <= 0;
							sample_out_b_reg    <= 0; 
						end 
						
					end else if(sub_4_2_2_en) begin
						if((row_addr_c_2_reg == (block_height_reg)-1) && (column_addr_c_2_reg == (block_width_reg/2)-1)) begin 
							row_addr_c_1_reg    <= 0;
							row_addr_c_2_reg    <= 0; 
							column_addr_c_1_reg <= 0;									
							column_addr_c_2_reg <= 0;
							first_write_reg     <= 0;
							samples_loaded_reg  <= 1;
							sample_out_a_reg    <= 0;
							sample_out_b_reg    <= 0; 
						end
					end 
						
					if(row_addr_a_1_reg == block_height_reg-1) begin   
						if(column_addr_a_2_reg < (block_width_reg-2-1)) begin
							row_addr_a_1_reg 	  <= 0;
							column_addr_a_1_reg   <= column_addr_a_1_reg + 4; 
							
							row_addr_a_2_reg 	  <= 0;
							column_addr_a_2_reg   <= column_addr_a_2_reg + 4;	
							mem_read_en_reg 	  <= 1;
							
							if(sub_4_2_0_en) begin 
								if(start_reg_4_2_0) begin 
									state <= STOP_2;
									start_reg_4_2_0 <= 0;
 									
								end else begin 
									state <= STOP_1;
									start_reg_4_2_0 <= 1; 
								end
								
							end else if(sub_4_2_2_en) begin
								state <= STOP_2;
							end 							

						end else begin
							state <= IDLE; 
							row_addr_a_1_reg    <= 0; 
							column_addr_a_1_reg <= 0; 
							row_addr_a_2_reg    <= 0; 
							column_addr_a_2_reg <= 0; 
							sub_4_2_0_en 		<= 0; 
							sub_4_2_2_en        <= 0;
							mem_read_en_reg 	<= 0; 
							//luma_memory_rst		<= 1; 
							sample_load_finished_ch_a <= 1;
						end 
				
					end else begin 
						row_addr_a_1_reg 	  <= row_addr_a_1_reg + 1;
						column_addr_a_1_reg   <= column_addr_a_1_reg; 

						row_addr_a_2_reg 	  <= row_addr_a_2_reg + 1;
						column_addr_a_2_reg   <= column_addr_a_2_reg;	
						mem_read_en_reg 	  <= 1;
						
						if(sub_4_2_0_en) begin 
							if(start_reg_4_2_0) begin 
								state <= STOP_2;
								
								start_reg_4_2_0 <= 0; 
							end else begin 
								state <= STOP_1;
								start_reg_4_2_0 <= 1; 
							end
							
						end else if(sub_4_2_2_en) begin
							state <= STOP_2;
						end 
					end				

					if(row_addr_b_1_reg == block_height_reg-1) begin   
						if(column_addr_b_2_reg < (block_width_reg-1)) begin
							row_addr_b_1_reg 	  <= 0;
							column_addr_b_1_reg   <= column_addr_b_1_reg + 4; 
							
							row_addr_b_2_reg 	  <= 0;
							column_addr_b_2_reg   <= column_addr_b_2_reg + 4;	
							
						end else begin
							row_addr_b_1_reg    <= 0; 
							column_addr_b_1_reg <= 0; 
							row_addr_b_2_reg    <= 0; 
							column_addr_b_2_reg <= 0; 
							sub_4_2_0_en        <= 0; 
							sub_4_2_2_en        <= 0;
							sample_load_finished_ch_b <= 1;
						end 
				
					end else begin 
						row_addr_b_1_reg 	  <= row_addr_b_1_reg + 1;
						column_addr_b_1_reg   <= column_addr_b_1_reg; 

						row_addr_b_2_reg 	  <= row_addr_b_2_reg + 1;
						column_addr_b_2_reg   <= column_addr_b_2_reg;	
					end						
				end					

				STOP_2: begin 
					mem_read_en_reg <= 0;  
					
					if(counter_2 < 1) begin 
						counter_2 <= counter_2 + 1; 
						state   <= STOP_2;
						
					end else begin
						if(sample_load_finished_ch_a && sample_load_finished_ch_b) begin 
							sample_in_a_reg <= 0; 
							sample_in_b_reg <= 0;
						end else begin 
							sample_in_a_reg <= sample_in_a_1_i + sample_in_a_2_i + sample_in_a_reg;
							sample_in_b_reg <= sample_in_b_1_i + sample_in_b_2_i + sample_in_b_reg;		
						end 

						if(sub_4_2_0_en || sub_4_2_2_en) begin 
							counter_2 <= 0;
							state <= DIV;	
						end
					end
				end 
					
				DIV: begin 
					if(sub_4_2_0_en) begin 
						sample_in_a_reg  <= sample_in_a_reg >> 2;
						sample_in_b_reg  <= sample_in_b_reg >> 2;
						mem_write_en_reg <= 0; 
						state <= WRITE;  
						
						if(!first_write_reg) begin 
							row_addr_c_1_reg    <= row_addr_c_1_reg; 
							column_addr_c_1_reg <= column_addr_c_1_reg;						
							row_addr_c_2_reg    <= row_addr_c_2_reg; 
							column_addr_c_2_reg <= column_addr_c_2_reg + 1;										
							first_write_reg 	<= 1; 
						
						end else begin
							if(row_addr_c_1_reg == (block_height_reg/2)-1) begin
								if(column_addr_c_2_reg < (block_width_reg/2)-1) begin 
									row_addr_c_1_reg    <= 0;
									row_addr_c_2_reg    <= 0; 
									column_addr_c_1_reg <= column_addr_c_1_reg + 2;									
									column_addr_c_2_reg <= column_addr_c_2_reg + 2;
									
								end else begin 
									row_addr_c_1_reg    <= 0;
									row_addr_c_2_reg    <= 0; 
									column_addr_c_1_reg <= 0;									
									column_addr_c_2_reg <= 0;
									first_write_reg     <= 0; 
								end 

							end else begin 
								row_addr_c_1_reg    <= row_addr_c_1_reg + 1; 
								column_addr_c_1_reg <= column_addr_c_1_reg;	
								row_addr_c_2_reg    <= row_addr_c_2_reg + 1; 
								column_addr_c_2_reg <= column_addr_c_2_reg;									
							end 
						end 
						
					end else if(sub_4_2_2_en) begin 
						sample_in_a_reg <= sample_in_a_reg >> 1;
						sample_in_b_reg <= sample_in_b_reg >> 1;
						mem_write_en_reg <= 0; 						
						state <= WRITE; 
						
						if(!first_write_reg) begin 
							row_addr_c_1_reg    <= row_addr_c_1_reg; 
							column_addr_c_1_reg <= column_addr_c_1_reg;						
							row_addr_c_2_reg    <= row_addr_c_2_reg; 
							column_addr_c_2_reg <= column_addr_c_2_reg + 1;										
							first_write_reg 	<= 1; 
							
						end else begin
							if(row_addr_c_1_reg == (block_height_reg)-1) begin
								if(column_addr_c_2_reg < (block_width_reg/2)-1) begin
									row_addr_c_1_reg    <= 0;
									row_addr_c_2_reg    <= 0; 
									column_addr_c_1_reg <= column_addr_c_1_reg + 2;									
									column_addr_c_2_reg <= column_addr_c_2_reg + 2;
									
								end else begin 
									row_addr_c_1_reg    <= 0;
									row_addr_c_2_reg    <= 0; 
									column_addr_c_1_reg <= 0;									
									column_addr_c_2_reg <= 0;
									first_write_reg     <= 0; 
								end
								
							end else begin 
								row_addr_c_1_reg    <= row_addr_c_1_reg + 1; 
								column_addr_c_1_reg <= column_addr_c_1_reg;	
								row_addr_c_2_reg    <= row_addr_c_2_reg + 1; 
								column_addr_c_2_reg <= column_addr_c_2_reg;									
							end
						end 						
					end						
				end

				WRITE: begin 
					
					sample_out_a_reg <= sample_in_a_reg;	// address c1 
					sample_out_b_reg <= sample_in_b_reg;	// address c2 
					sample_in_a_reg  <= 0; 
					sample_in_b_reg  <= 0;
					mem_write_en_reg <= 1; 	
					
					if(sub_4_2_0_en || sub_4_2_2_en) begin 
						state <= LOAD_2;
					end 
				end
					
				default: begin
					state <= IDLE; 
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

	assign row_addr_a_1_o	   =  row_addr_a_1_reg;
	assign row_addr_a_2_o	   =  row_addr_a_2_reg;
	assign row_addr_b_1_o	   =  row_addr_b_1_reg;
	assign row_addr_b_2_o	   =  row_addr_b_2_reg;	
	assign column_addr_a_1_o   =  column_addr_a_1_reg;	
	assign column_addr_a_2_o   =  column_addr_a_2_reg;
	assign column_addr_b_1_o   =  column_addr_b_1_reg;
	assign column_addr_b_2_o   =  column_addr_b_2_reg;
	assign row_addr_c_1_o	   =  row_addr_c_1_reg;
	assign row_addr_c_2_o	   =  row_addr_c_2_reg;	
	assign column_addr_c_1_o   =  column_addr_c_1_reg;	
	assign column_addr_c_2_o   =  column_addr_c_2_reg;	
	assign sample_out_a_o      =  sample_out_a_reg; 
	assign sample_out_b_o      =  sample_out_b_reg; 
	assign mem_read_en_o       =  mem_read_en_reg; 
	assign mem_write_en_o      =  mem_write_en_reg;
	assign samples_loaded_o    = samples_loaded_reg;
	assign div_shift_o		   = div_shift_reg;
	assign block_sub_row_o	   = block_sub_row_reg;
	assign block_sub_column_o  = block_sub_column_reg; 
	//assign luma_memory_rst_o   = luma_memory_rst; 
	
endmodule

