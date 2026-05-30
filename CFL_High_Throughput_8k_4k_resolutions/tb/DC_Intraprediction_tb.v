// reg N BITS 

`timescale 1ns/1ps

module tb_load_sample_top;

	parameter width_p 	     = 10; 		
	parameter samples_n_p	 = 16;

	// sinais que serão executados dentro do initial begin são reg 
	// sinais que serão lidos na saída do teste bench são wire 
	
    reg clk = 0;
    reg rst = 0;

	reg data_in_valid_left = 0; 
	reg data_in_valid_top  = 0;   
	
	reg [6:0] sample_number_left = 0;
	reg [6:0] sample_number_top = 0;
	
	reg [width_p-1:0] sample_left = 0;
	reg [width_p-1:0] sample_top  = 0;
	
	reg above = 0;
	reg left  = 0;
	
	wire ready_to_load_left;	
	wire ready_to_load_top; 
	wire ready;
	wire signed [width_p+1:0] intrapred_data_out; 

	integer i; 
	
    DC_intraprediction #(
	
		.width_p(width_p),
		.samples_n_p(samples_n_p)
		
	) uut 
	(
        .clk_i(clk),
        .rst_i(rst),
        .data_in_valid_left_i(data_in_valid_left),
        .data_in_valid_top_i(data_in_valid_top),
        .sample_number_left_i(sample_number_left),
		.sample_number_top_i(sample_number_top),
		.sample_left_i(sample_left),
		.sample_top_i(sample_top),
		.above(above),
		.left(left),
		
		.ready_to_load_left_o(ready_to_load_left),
		.ready_to_load_top_o(ready_to_load_top),
		.ready_o(ready),
		.intrapred_data_out_o(intrapred_data_out)
    );


	task load_sample_left(input [width_p-1:0] sample_val);
		begin
			sample_left = sample_val;
			data_in_valid_left = 1;
			@(posedge clk);
			data_in_valid_left = 0;
		end
	endtask

	task load_sample_top(input [width_p-1:0] sample_val);
		begin
			sample_top = sample_val;
			data_in_valid_top = 1;
			@(posedge clk);
			data_in_valid_top = 0;
		end
	endtask

	task load_sample_left_top(input [width_p-1:0] sample_val_left, input [width_p-1:0] sample_val_top);
		begin
			sample_top  = sample_val_top;
			sample_left = sample_val_left;
			data_in_valid_top  = 1;
			data_in_valid_left = 1;			
			@(posedge clk);
			data_in_valid_top  = 0;
			data_in_valid_left = 0;	
		end
	endtask


    // Clock: 10ns período (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Inicio da simulacao");
		
        rst <= 1;
        repeat (2) @(posedge clk); 
        rst <= 0;
        @(posedge clk);
		repeat (2) @(posedge clk);

// -------------- 4 samples sum --------------

 		sample_number_left <= 7'h04;
		above <= 0;
		left  <= 1; 
				
        @(posedge clk);

		load_sample_left(10'h37); 		
		load_sample_left(10'hFF); 
		load_sample_left(10'h0); 
		load_sample_left(10'h22B); 			

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);

		// result is 0xd8

		sample_number_top <= 7'h04;
		above <= 1;
		left  <= 0; 
				
        @(posedge clk);

		load_sample_top(10'h37); 		
		load_sample_top(10'hFF); 
		load_sample_top(10'h0); 
		load_sample_top(10'h22B); 

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
		
		// result is 0xd8
	
		sample_number_top  <= 7'h04;
		sample_number_left <= 7'h04;		
		above <= 1;
		left  <= 1;
		
        @(posedge clk);

		load_sample_left_top(10'hFF,10'hF0);
		load_sample_left_top(10'h2F,10'h3F);
		load_sample_left_top(10'hA0,10'hFF);		
		load_sample_left_top(10'hB3,10'hD4);
		
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);		

		// result is 0xb0

		sample_number_top  <= 7'h04;
		sample_number_left <= 7'h08;		
		above <= 1;
		left  <= 1;
		
        @(posedge clk);

		load_sample_left_top(10'h02,10'h01);
		load_sample_left_top(10'h02,10'h01);
		load_sample_left_top(10'h02,10'h01);		
		load_sample_left_top(10'h02,10'h01);
		load_sample_left(10'h2);
		load_sample_left(10'h2);
		load_sample_left(10'h2);
		load_sample_left(10'h2);

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	

		// result is 0x2
		
// ----------------------------

/*      rst <= 1;
        repeat (2) @(posedge clk); 
        rst <= 0;
        @(posedge clk); */

 		sample_number_top  <= 7'h40;
		sample_number_left <= 7'h40;		
		above <= 1;
		left  <= 1;
		
        @(posedge clk);

		for (i = 0; i < 64; i = i + 1) begin
			if(i == 15 || i == 31 || i == 47 || i == 63) begin 
				load_sample_left_top(10'h02,10'h01);
				@(posedge clk);
			end else begin 
				load_sample_left_top(10'h02,10'h01);
			end 	
		end

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	 	

		// result is 0x2

 		sample_number_top  <= 7'h40;
		sample_number_left <= 7'h40;		
		above <= 1;
		left  <= 1;
		
        @(posedge clk);

		for (i = 0; i < 64; i = i + 1) begin
			if(i == 15 || i == 31 || i == 47 || i == 63) begin 
				load_sample_left_top(10'hDC,10'h7B);
				@(posedge clk);
			end else begin 
				load_sample_left_top(10'hDC,10'h7B);
			end 	
		end

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	 

		// result is 0xAC
		
 		sample_number_top  <= 7'h20;
		sample_number_left <= 7'h20;		
		above <= 1;
		left  <= 1;
		
        @(posedge clk);

		for (i = 0; i < 32; i = i + 1) begin
			if(i == 15 || i == 31) begin 
				load_sample_left_top(10'hDC,10'h7B);
				@(posedge clk);
			end else begin 
				load_sample_left_top(10'hDC,10'h7B);
			end 	
		end

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);		
		
		// result is 0xAC		
		
// -------------- 8 samples sum --------------

/*         rst = 1;
		@(posedge clk);  // Espera 2 bordas de clk
        rst = 0;
		repeat (2) @(posedge clk);
		repeat (2) @(posedge clk);
		
		sample_number <= 5'h08;	
		
        @(posedge clk);			
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);

// -------------- 16 samples sum --------------

        rst = 1;
		@(posedge clk);  // Espera 2 bordas de clk
        rst = 0;
		repeat (2) @(posedge clk);
		repeat (2) @(posedge clk);
		
		sample_number <= 5'h10;	
		
        @(posedge clk);			
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);		
        @(posedge clk);	

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);

// -------------- 32 samples sum --------------
	
        rst = 1;
		@(posedge clk);  
        rst = 0;
		repeat (2) @(posedge clk);
		repeat (2) @(posedge clk);
		
		sample_number <= 7'h20;	
		
        @(posedge clk);			
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		
        @(posedge clk);			
		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);		
        @(posedge clk);	

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);

// -------------- 64 samples sum --------------
	
        rst = 1;
		@(posedge clk);  
        rst = 0;
		repeat (2) @(posedge clk);
		repeat (2) @(posedge clk);
		
		sample_number <= 7'h40;	

        @(posedge clk);			
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		
        @(posedge clk);			
		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);	
		
        @(posedge clk);	
	
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		
        @(posedge clk);			
		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 	
		load_sample(10'h01);		
        @(posedge clk);	

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk); */
		
// -------------- load finish --------------
		
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);		
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);			
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);	
		
        $finish;
    end

endmodule


