// control block 

module Control_Unit  
  #(
  	parameter width_p = 10
  )
  (

	input wire clk_i,
	input wire rst_i, 
   
	input wire DC_ready_i,
	input wire mem_read_finish_i,
	input wire seq_mem_ready_i, 
	input wire mem_ready_to_be_read_i,

	input wire signed [width_p+1:0] DC_intrapred_i,
	
	output wire load_en_o, 
	output wire read_en_mem_sub_o,
	output wire DC_intrapred_data_out_ready_o,
	output wire signed [width_p+1:0] DC_intrapred_data_out_o
	
  );
 
	reg read_en_mem_sub_reg = 0;
	reg load_en_reg = 0; 
	reg DC_intrapred_data_out_ready_reg = 0;
	reg signed [width_p+1:0] DC_intrapred_data_reg = 0;
	reg signed [width_p+1:0] DC_intrapred_data_out_reg = 0;
	
	// start subsampling after load luma memory
	always @(posedge clk_i) begin
		if(seq_mem_ready_i) begin 
			load_en_reg <= 1; 
		end else begin 
			load_en_reg <= 0; 
		end 
	end 
	
	// if DC_ready_i, the DC intra pred is stored 
	always @(posedge clk_i) begin
		if(rst_i) begin 
			DC_intrapred_data_reg <= 0; 	
			read_en_mem_sub_reg   <= 0;
		end else if(DC_ready_i) begin 
			DC_intrapred_data_reg <= DC_intrapred_i; 
		end 		
	end 
	
	// when the subsampling process is completed and subsampling memory is read to be read  
	always @(posedge clk_i) begin
		
		if(mem_ready_to_be_read_i) begin 
			read_en_mem_sub_reg 			<= 1;
			DC_intrapred_data_out_reg 		<= DC_intrapred_data_reg; 
			DC_intrapred_data_out_ready_reg <= 1; 
		end
		
		if(mem_read_finish_i) begin 
			read_en_mem_sub_reg <= 0;
			DC_intrapred_data_out_reg 		<= 0;
			DC_intrapred_data_out_ready_reg <= 0; 			
		end 
		
	end
	
	assign DC_intrapred_data_out_o 		 = DC_intrapred_data_out_reg; 
	assign DC_intrapred_data_out_ready_o = DC_intrapred_data_out_ready_reg; 
	assign load_en_o 					 = load_en_reg; 
	assign read_en_mem_sub_o			 = read_en_mem_sub_reg; 

endmodule
