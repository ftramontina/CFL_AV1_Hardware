
// Luma Avg Processing  

module Luma_Avg_Processing 
  #(
  
   parameter width_p = 10 		
   
  )
  (

	input  wire [3:0]  div_shift_i,
	input  wire [20:0] acc_i,  
	
	output wire [9:0] avg_o

   );
    
	assign avg_o   = (div_shift_i == 2)  ? acc_i  >> 2  :
					 (div_shift_i == 3)  ? acc_i  >> 3  :
					 (div_shift_i == 4)  ? acc_i  >> 4  :
					 (div_shift_i == 5)  ? acc_i  >> 5  :	
					 (div_shift_i == 6)  ? acc_i  >> 6  :	
					 (div_shift_i == 7)  ? acc_i  >> 7  :
					 (div_shift_i == 8)  ? acc_i  >> 8  :
					 (div_shift_i == 9)  ? acc_i  >> 9  :	
					 (div_shift_i == 10) ? acc_i  >> 10 :	
					 (div_shift_i == 11) ? acc_i  >> 11 :							 
					 0;
						
endmodule 