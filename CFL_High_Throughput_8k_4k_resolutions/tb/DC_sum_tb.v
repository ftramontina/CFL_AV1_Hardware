// reg N BITS 

`timescale 1ns/1ps

module tb_load_sample;

	parameter width_p 	     = 10; 		
	parameter samples_n_p	 = 16;

	// sinais que serão executados dentro do initial begin são reg 
	// sinais que serão lidos na saída do teste bench são wire 
	
    reg clk = 0;
    reg rst = 0;
	//reg en = 0;
	reg data_in_valid = 0; 
	
	reg [6:0] sample_number;
	reg [width_p-1:0] sample;
	
    wire [19:0] data_out_test;
	wire data_available_o; 
	wire ready_to_load;

    // DUT
    DC_SUM_16 #(
	
		.width_p(width_p),
		.samples_n_p(samples_n_p)
		
	) uut 
	(
        .clk_i(clk),
        .rst_i(rst),
        .data_in_valid_i(data_in_valid),
        .sample_number_i(sample_number),
        .sample_i(sample),
		.data_available_o(data_available_o),
		.ready_to_load_o(ready_to_load),
		.DC_Sum_o(data_out_test)
    );

	task load_sample(input [width_p-1:0] sample_val);
		begin
			sample = sample_val;
			data_in_valid = 1;
			@(posedge clk);
			data_in_valid = 0;
		end
	endtask

    // Clock: 10ns período (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Inicio da simulacao");
		
        rst = 1;
        repeat (2) @(posedge clk); 
        rst = 0;
        @(posedge clk);
		repeat (2) @(posedge clk);

// -------------- 4 samples sum --------------

		sample_number <= 5'h04;
        	@(posedge clk);

		load_sample(10'h01); 		
		load_sample(10'h01); 
		load_sample(10'h01); 
		load_sample(10'h01); 			

        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);
        repeat (3) @(posedge clk);

// -------------- 8 samples sum --------------

        rst = 1;
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
        repeat (3) @(posedge clk);
		
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


