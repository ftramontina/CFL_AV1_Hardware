
// sum module 

module sum_2_samples  
  #(
  
   parameter width_p = 10 			
   
  )
  (
  
   input  wire  [width_p-1:0] data_in_A_i, 
   input  wire  [width_p-1:0] data_in_B_i,
 
   output wire  [width_p:0] Sum_o
   
   );
   
   assign Sum_o = data_in_A_i + data_in_B_i; 
   
endmodule 