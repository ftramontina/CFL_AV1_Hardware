// reg N BITS 

`timescale 1ns/1ps

module tb_integration_CFL_Top;

	parameter width_p 	 = 10; 		
	parameter columns	 = 64;
	parameter rows		 = 64;

	// sinais que serão executados dentro do initial begin são reg 
	// sinais que serão lidos na saída do teste bench são wire 
	
    reg clk = 0;
    reg rst = 0;
	
	reg data_in_valid 	   = 0; 
	
	reg [6:0] block_width   = 0;
	reg [6:0] block_height  = 0;

	reg  [width_p-1:0] sample = 0; 
	
	wire ready_to_load;	
	wire seq_mem_ready;
	
	reg subsampling_x = 0;
	reg subsampling_y = 0;
	
	reg  load_en = 0; 
	
	wire signed [width_p+1:0] CFL_final;
	reg [4:0] alpha_index;
	reg alpha_sign; 

	reg  read_en_mem_sub = 0;
	
	wire [6:0] address_row_final;	
	wire [6:0] address_column_final;
	
	wire mem_read_finish; 
	wire CFL_final_ready_o; 
	
	reg DC_Chr_ready = 0;
	reg [width_p+1:0] DC_Intra_Chr = 12'h0000;
		
    CFL_Top #(
	
		.width_p(width_p),
		.columns(columns),
		.rows(rows)
		
	) CFL_Top_inst
	(
		.clk_i(clk),
		.rst_i(rst),

		.block_width_i(block_width), 
		.block_height_i(block_height),
	
		.data_in_valid_i(data_in_valid),
		.load_en(load_en), 
		.read_en_mem_sub_i(read_en_mem_sub),
	
		.subsampling_x_i(subsampling_x),
		.subsampling_y_i(subsampling_y),

		.alpha_sign_i(alpha_sign), 
		.alpha_index_i(alpha_index),

		.sample_i(sample),
	
		.DC_Chr_ready_i(DC_Chr_ready), 
		.DC_Intra_Chr_i(DC_Intra_Chr),

		.ready_to_load_o(ready_to_load),
		.seq_mem_ready_o(seq_mem_ready),	

		.mem_read_finish_o(mem_read_finish),
		
		.address_row_final_o(address_row_final),
		.address_column_final_o(address_column_final),
	
		.CFL_final_o(CFL_final),
		.CFL_final_ready_o(CFL_final_ready_o)

    );
	
    // Clock: 10ns período (100 MHz)
    always #5 clk = ~clk;

 	always @(posedge clk) begin
		if(mem_read_finish) begin 
			read_en_mem_sub <= 0; 
		end
	end  

    initial begin
        $display("Inicio da simulacao");
		
		rst <= 0;
		@(posedge clk); 
		rst <= 1;
        repeat (2) @(posedge clk); 
        rst <= 0;
		repeat (2) @(posedge clk);

 		block_width    <= 4;
		block_height   <= 4;
		
		repeat (2) @(posedge clk);
		
		data_in_valid  <= 1;

		sample 		   <= 1;
		load_en		   <= 0;	
		
	   repeat (1) @(posedge clk);
	   sample <= 2;	
	   repeat (1) @(posedge clk);
	   sample <= 3;	
	   repeat (1) @(posedge clk);
	   sample <= 4;	
	   repeat (1) @(posedge clk);
	   sample <= 5;		  
	   repeat (1) @(posedge clk);
	   sample <= 6;		  
	   repeat (1) @(posedge clk);
	   sample <= 7;
	   repeat (1) @(posedge clk);
	   sample <= 8;	 
	   repeat (1) @(posedge clk);
	   sample <= 9;	  
	   repeat (1) @(posedge clk);
	   sample <= 10;	  
	   repeat (1) @(posedge clk);
	   sample <= 11;
	   repeat (1) @(posedge clk);
	   sample <= 12;
	   repeat (1) @(posedge clk);
	   sample <= 13;	
	   repeat (1) @(posedge clk);
	   sample <= 14;
	   repeat (1) @(posedge clk);
	   sample <= 15;
	   repeat (1) @(posedge clk);
	   sample <= 16;	  	   
	   
	   repeat (1) @(posedge clk);

		data_in_valid  <= 0;				
		subsampling_x  <= 1;
		subsampling_y  <= 1; 
		load_en		   <= 1; 
	
	   repeat (1) @(posedge clk);
	   load_en		   <= 0; 		
	   repeat (1) @(posedge clk);
	   repeat (1) @(posedge clk);	   
		
	   repeat (15) @(posedge clk);
	  
	   repeat (100) @(posedge clk);

	   repeat (1) @(posedge clk);

		// start pipeline analysis here 
		
		read_en_mem_sub <= 1;
		DC_Chr_ready	<= 1; 
		alpha_sign 	 	<= 0; 
		alpha_index  	<= 8;
		DC_Intra_Chr 	<= 12'h0FF; 	// +255 --> it needs to be synchronize 
		
	   repeat (50) @(posedge clk);
	   
	   DC_Chr_ready		<= 0;
	   DC_Intra_Chr 	<= 0;
	   read_en_mem_sub  <= 0; 
	   
	   repeat (1) @(posedge clk);
	   
		data_in_valid  <= 0;				
		subsampling_x  <= 1;
		subsampling_y  <= 0; 
		load_en		   <= 1; 
	
	   repeat (1) @(posedge clk);
	   load_en		   <= 0; 		   
	   repeat (1) @(posedge clk);
	   repeat (1) @(posedge clk);	   
		
	   repeat (15) @(posedge clk);
	  
	   repeat (100) @(posedge clk);	
	   
	   read_en_mem_sub  <= 1; // here the chroma DC pred must be ready 
	   DC_Chr_ready		<= 1;
	   alpha_sign 		<= 0; 
	   alpha_index 		<= 8;
	   DC_Intra_Chr 	<= 12'h0FF; 	// +255
	   
	   repeat (1) @(posedge clk);	   
	   repeat (50) @(posedge clk); 
		
	   repeat (50) @(posedge clk);
	   read_en_mem_sub <= 0; 
		   
        $display("Fim da simulacao");
    end

endmodule


