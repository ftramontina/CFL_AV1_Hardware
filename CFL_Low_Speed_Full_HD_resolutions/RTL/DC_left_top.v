
// Alpha processing  

module DC_left_top
  #(
  
   parameter width_p = 10 		
   
  )
  (

	input  wire [6:0]  sample_number_left_i,
	input  wire [6:0]  sample_number_top_i,
	input  wire [19:0] sum_left_top, 
	
	output wire [width_p+1:0] DC_left_top

   );
    
	assign DC_left_top = (sample_number_left_i == 4  && sample_number_top_i == 4)   ? sum_left_top  >> 3 : 
						 (sample_number_left_i == 8  && sample_number_top_i == 8)   ? sum_left_top  >> 4 :
						 (sample_number_left_i == 16 && sample_number_top_i == 16)  ? sum_left_top  >> 5 :
						 (sample_number_left_i == 32 && sample_number_top_i == 32)  ? sum_left_top  >> 6 :		
						 (sample_number_left_i == 64 && sample_number_top_i == 64)  ? sum_left_top  >> 7 :
						 
						 (sample_number_left_i == 4  && sample_number_top_i == 8)   ? ((sum_left_top >> 4) + (sum_left_top >> 5) - (sum_left_top >> 7) - (sum_left_top >> 9)) : 
						 (sample_number_left_i == 8  && sample_number_top_i == 4)   ? ((sum_left_top >> 4) + (sum_left_top >> 5) - (sum_left_top >> 7) - (sum_left_top >> 9)) : 		
						 
						 (sample_number_left_i == 4  && sample_number_top_i == 16)  ? ((sum_left_top >> 4) - (sum_left_top >> 6) + (sum_left_top >> 8)) : 						 
						 (sample_number_left_i == 16 && sample_number_top_i == 4)   ? ((sum_left_top >> 4) - (sum_left_top >> 6) + (sum_left_top >> 8)) : 	

						 (sample_number_left_i == 8  && sample_number_top_i == 16)  ? ((sum_left_top >> 4) - (sum_left_top >> 6) - (sum_left_top >> 8) - (sum_left_top >> 10) - (sum_left_top >> 12)) : 						 
						 (sample_number_left_i == 16 && sample_number_top_i == 8)   ? ((sum_left_top >> 4) - (sum_left_top >> 6) - (sum_left_top >> 8) - (sum_left_top >> 10) - (sum_left_top >> 12)) : 

						 (sample_number_left_i == 8  && sample_number_top_i == 32)  ? ((sum_left_top >> 5) - (sum_left_top >> 7) + (sum_left_top >> 9)) : 						 
						 (sample_number_left_i == 32 && sample_number_top_i == 8)   ? ((sum_left_top >> 5) - (sum_left_top >> 7) + (sum_left_top >> 9)) : 	

						 (sample_number_left_i == 16 && sample_number_top_i == 32)  ? ((sum_left_top >> 5) - (sum_left_top >> 7) - (sum_left_top >> 9) - (sum_left_top >> 11)) : 						 
						 (sample_number_left_i == 32 && sample_number_top_i == 16)  ? ((sum_left_top >> 5) - (sum_left_top >> 7) - (sum_left_top >> 9) - (sum_left_top >> 11)) : 	

						 (sample_number_left_i == 16 && sample_number_top_i == 64)  ? ((sum_left_top >> 6) - (sum_left_top >> 8) + (sum_left_top >> 10) - (sum_left_top >> 12)) : 						 
						 (sample_number_left_i == 64 && sample_number_top_i == 16)  ? ((sum_left_top >> 6) - (sum_left_top >> 8) + (sum_left_top >> 10) - (sum_left_top >> 12)) : 

						 (sample_number_left_i == 32 && sample_number_top_i == 64)  ? ((sum_left_top >> 7) + (sum_left_top >> 9) + (sum_left_top >> 11) + (sum_left_top >> 13)) : 						 
						 (sample_number_left_i == 64 && sample_number_top_i == 32)  ? ((sum_left_top >> 7) + (sum_left_top >> 9) + (sum_left_top >> 11) + (sum_left_top >> 13)) : 
						 0; 
					
endmodule 