
// DC processing  

module DC_1d 
  #(
  
   parameter width_p = 10 		
   
  )
  (

	input  wire [6:0]  sample_number_1d_i,
	input  wire [19:0] sum_1d_i, 
	
	output wire [width_p+1:0] DC_1d_o

   );
    
	assign DC_1d_o = (sample_number_1d_i == 4)  ? sum_1d_i >> 2 :
					 (sample_number_1d_i == 8)  ? sum_1d_i >> 3 :
					 (sample_number_1d_i == 16) ? sum_1d_i >> 4 :
					 (sample_number_1d_i == 32) ? sum_1d_i >> 5 :	
					 (sample_number_1d_i == 64) ? sum_1d_i >> 6 :		
					 0;
						
endmodule 