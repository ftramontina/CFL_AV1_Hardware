// reg N BITS 

`timescale 1ns/1ps

module tb_luma_memory;

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
	reg [6:0] row_addr_a	= 0; 
	reg [6:0] column_addr_a = 0; 
	reg [6:0] row_addr_b	= 0; 
	reg [6:0] column_addr_b = 0; 
	
	reg subsampling_we 	   = 0; 
	reg subsampling_re	   = 0;

	reg  [width_p-1:0] subsampled_sample = 0; 
	reg  [width_p-1:0] sample = 0; 
	
	wire ready_to_load;	
	wire seq_mem_ready;
	wire [width_p-1:0] sample_2_subsampling;
	
	integer f;
	integer i = 0;
	integer j = 0;  	

    luma_memory #(
	
		.width_p(width_p),
		.columns(columns),
		.rows(rows)
		
	) uut 
	(
        .clk_i(clk),
        .rst_i(rst),
        .data_in_valid_i(data_in_valid),
        .block_width_i(block_width),
        .block_height_i(block_height),
		.subsampling_we_i(subsampling_we),
		.subsampling_re_i(subsampling_re),	
		.sample_i(sample),	
		.row_addr_a_i(row_addr_a),
		.column_addr_a_i(column_addr_a),	
		.row_addr_b_i(row_addr_b),
		.column_addr_b_i(column_addr_b),
		.subsampled_sample_i(subsampled_sample),
		.ready_to_load_o(ready_to_load),
		.seq_mem_ready_o(seq_mem_ready),
		.sample_2_subsampling_o(sample_2_subsampling)
		
    );

    // Clock: 10ns período (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Inicio da simulacao");
		
		rst <= 0;
		@(posedge clk); 
		rst <= 1;
        repeat (2) @(posedge clk); 
        rst <= 0;
		repeat (2) @(posedge clk);

 		block_width    <= 32;
		block_height   <= 32;
		
		repeat (2) @(posedge clk);
		
		data_in_valid  <= 1;
		subsampling_we <= 0;
		subsampling_re <= 0; 
		sample 		   <= 1;
		
        repeat (500) @(posedge clk);
		subsampling_re = 1'b1;		
		f = $fopen("mem_output.txt", "w");

		  // Espera inicial para garantir sistema estável
		#200000;
		if(seq_mem_ready) begin 
		  for (i = 0; i < 64; i=i+1) begin
			for (j = 0; j < 64; j=j+1) begin
			  // Atribui endereço
			  row_addr_a    = i;
			  column_addr_a = j;


			  // Aguarda borda de clock ou tempo de leitura (ajuste se necessário)
			  @(posedge clk);
			  #1; // pequeno delay para estabilizar leitura

			  // Grava no arquivo
			  $fwrite(f, "%4h ", sample_2_subsampling);
			end
			$fwrite(f, "\n");
		  end
		end
		
		  $fclose(f);
		  $display("Leitura da memória finalizada.");
 
        $finish;
    end

endmodule


