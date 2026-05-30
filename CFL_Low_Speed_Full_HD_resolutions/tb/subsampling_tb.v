// Test bench for the subsampling block 

`timescale 1ns/1ps

module tb_subsampling_machine;

	parameter width_p = 10; 		

    reg clk = 0;
    reg rst = 0;
	
	reg subsampling_x = 0;
	reg subsampling_y = 0;
	
	reg [6:0] block_width   = 0;
	reg [6:0] block_height  = 0;
	reg load_en = 0; 
	
	reg [width_p-1:0] sample_in_a_1 = 0; 
	reg [width_p-1:0] sample_in_a_2 = 0;
	reg [width_p-1:0] sample_in_b_1 = 0; 
	reg [width_p-1:0] sample_in_b_2 = 0;
	
	wire [6:0] row_addr_a_1;	
	wire [6:0] row_addr_a_2;	
	wire [6:0] row_addr_b_1;	
	wire [6:0] row_addr_b_2;
	wire [6:0] row_addr_c_1;	
	wire [6:0] row_addr_c_2;
	
	wire [6:0] column_addr_a_1;	
	wire [6:0] column_addr_a_2;	
	wire [6:0] column_addr_b_1;	
	wire [6:0] column_addr_b_2;		
	wire [6:0] column_addr_c_1;	
	wire [6:0] column_addr_c_2;	
	
	wire [width_p-1:0] sample_out_a;
	wire [width_p-1:0] sample_out_b;
	
	wire subsampling_re;
	
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
		.mem_ready_en_o(subsampling_re),
		
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
		.sample_out_b_o(sample_out_b)	
		
    );

    // Clock: 10ns período (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Inicio da simulacao");
		
		rst <= 0;
		@(posedge clk); 
		rst <= 1;
		@(posedge clk); 
        rst <= 0;
		repeat (2) @(posedge clk);
		
		subsampling_x <= 1;
		subsampling_y <= 1;
		block_width   <= 8;
		block_height  <= 8;
		load_en 	  <= 1;

		@(posedge clk); 

		load_en <= 0; 		
		
		// FSM starts here  
		
		repeat (300000) @(posedge clk); // for 64 x 64 

        $finish;
    end

endmodule


