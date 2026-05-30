// reg N BITS 

`timescale 1ns/1ps

module tb_integration;

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
	
	wire [width_p-1:0] sample_in_a_1;
	wire [width_p-1:0] sample_in_a_2;
	wire [width_p-1:0] sample_in_b_1;
	wire [width_p-1:0] sample_in_b_2;
	
	reg subsampling_x = 0;
	reg subsampling_y = 0;
	
	reg  load_en = 0; 

	wire [6:0] row_addr_a_1;	
	wire [6:0] row_addr_a_2;		
	wire [6:0] column_addr_a_1;  
	wire [6:0] column_addr_a_2;
	
	wire [width_p-1:0] sample_out_a;
	wire [width_p-1:0] sample_out_b;
	
	wire signed [width_p+1:0] CFL_final;
	reg [4:0] alpha_index;
	reg alpha_sign; 
	
	wire [6:0] row_addr_b_1;	
	wire [6:0] row_addr_b_2;		
	wire [6:0] column_addr_b_1;  
	wire [6:0] column_addr_b_2; 
	
	wire [6:0] row_addr_c_1;	
	wire [6:0] row_addr_c_2;		
	wire [6:0] column_addr_c_1;  
	wire [6:0] column_addr_c_2; 
	
	wire subsampling_re; 	
	wire subsampling_we; 
	wire samples_loaded; 
	
	wire mem_ready_to_be_read;
	wire [width_p-1:0] sample_out_o;
	reg  read_en_mem_sub = 0;
	wire [3:0] div_shift;
	
	wire [6:0] address_column_out;
	wire [6:0] address_row_out;	
	wire [6:0] address_column_final;
	wire [6:0] address_row_final;	
	
	wire [6:0] block_sub_row;
	wire [6:0] block_sub_column;
	wire mem_read_finish; 
	
	reg DC_Chr_ready = 0;
	reg [width_p+1:0] DC_Intra_Chr = 12'h0000;
	
	reg avg_en; 
	wire [6:0] avg;
	
	wire pipe_en; 
	wire CFL_final_ready_out;
	wire CFL_final_ready; 
	
    luma_memory #(
	
		.width_p(width_p),
		.columns(columns),
		.rows(rows)
		
	) uut_mem
	(
		.clk_i(clk),
		.rst_i(rst),
		
		.data_in_valid_i(data_in_valid),
		.block_width_i(block_width), 
		.block_height_i(block_height), 
		.sample_i(sample),
		
		.ready_to_load_o(ready_to_load),
		.seq_mem_ready_o(seq_mem_ready),
		
		.subsampling_re_i(subsampling_re),
		
		.row_addr_a_1_i(row_addr_a_1), 
		.column_addr_a_1_i(column_addr_a_1), 
		.row_addr_a_2_i(row_addr_a_2), 
		.column_addr_a_2_i(column_addr_a_2), 
		
		.row_addr_b_1_i(row_addr_b_1), 
		.column_addr_b_1_i(column_addr_b_1), 
		.row_addr_b_2_i(row_addr_b_2),
		.column_addr_b_2_i(column_addr_b_2),
		
		.sample_out_a_1_o(sample_in_a_1),
		.sample_out_a_2_o(sample_in_a_2),
		.sample_out_b_1_o(sample_in_b_1),
		.sample_out_b_2_o(sample_in_b_2)

    );

    subsampling_machine #(
	
		.width_p(width_p)
		
	) uut_sub_machine
	(
		.clk_i(clk),
		.rst_i(rst),
	
		.subsampling_x_i(subsampling_x),
		.subsampling_y_i(subsampling_y),
	
		.block_width_i(block_width), 
		.block_height_i(block_height), 
	
		.sample_in_a_1_i(sample_in_a_1),
		.sample_in_a_2_i(sample_in_a_2),
	
		.sample_in_b_1_i(sample_in_b_1),
		.sample_in_b_2_i(sample_in_b_2),
	
		.load_en_i(load_en), 
		.mem_read_en_o(subsampling_re),
		.mem_write_en_o(subsampling_we),
		
		.row_addr_a_1_o(row_addr_a_1),
		.column_addr_a_1_o(column_addr_a_1),	
		.row_addr_a_2_o(row_addr_a_2),
		.column_addr_a_2_o(column_addr_a_2),
	
		.row_addr_b_1_o(row_addr_b_1),
		.column_addr_b_1_o(column_addr_b_1),
		.row_addr_b_2_o(row_addr_b_2),
		.column_addr_b_2_o(column_addr_b_2),

		.row_addr_c_1_o(row_addr_c_1),
		.column_addr_c_1_o(column_addr_c_1),
		.row_addr_c_2_o(row_addr_c_2),
		.column_addr_c_2_o(column_addr_c_2),

		.sample_out_a_o(sample_out_a), 
		.sample_out_b_o(sample_out_b),
		
		.div_shift_o(div_shift),

		.samples_loaded_o(samples_loaded),
		.block_sub_row_o(block_sub_row),
		.block_sub_column_o(block_sub_column)
		
    );
	
    subsampling_memory #(
	
		.width_p(width_p),
		.columns(columns),
		.rows(rows)
		
	) uut_sub_memory
	(	

	.clk_i(clk),
	.rst_i(rst),
	
	.mem_write_en_i(subsampling_we),
	.mem_read_en_i(read_en_mem_sub),
	
	.sample_in_a_i(sample_out_a),
	.sample_in_b_i(sample_out_b),

	.block_sub_row_i(block_sub_row),
	.block_sub_column_i(block_sub_column),
	
	.row_addr_c_1_i(row_addr_c_1),
	.column_addr_c_1_i(column_addr_c_1),
	.row_addr_c_2_i(row_addr_c_2),
	.column_addr_c_2_i(column_addr_c_2),

	.div_shift_i(div_shift),
	.samples_loaded_i(samples_loaded),
	
	.sample_out_o(sample_out_o),
	.mem_ready_to_be_read_o(mem_ready_to_be_read),
	
	.address_row_o(address_row_out),
	.address_column_o(address_column_out),
	.avg_o(avg),
	
	.pipe_en_o(pipe_en),
	.CFL_final_ready_o(CFL_final_ready),
	
	.mem_read_finish_o(mem_read_finish)
	
	);

    output_pipeline #(
	
		.width_p(width_p)
		
	) uut_output_pipeline
	(		
		.clk_i(clk),
	    .rst_i(rst),
		.sample_i(sample_out_o),
		.address_row_i(address_row_out),
	    .address_column_i(address_column_out),
		
		.DC_Chr_ready_i(DC_Chr_ready),
		.DC_Intra_Chr_i(DC_Intra_Chr),
		
		.avg_en_i(mem_ready_to_be_read),
		.avg_i(avg),
		
		.alpha_sign_i(alpha_sign),
		.alpha_index_i(alpha_index),
		
		.pipe_en_i(pipe_en),
		.mem_read_finish_i(mem_read_finish),
		.CFL_final_ready_i(CFL_final_ready),
		
		.address_row_o(address_row_final),
		.address_column_o(address_column_final),
		.CFL_final_o(CFL_final), 
		.CFL_final_ready_o(CFL_final_ready_out)
		
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


