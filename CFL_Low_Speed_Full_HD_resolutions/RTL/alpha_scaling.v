
// Alpha processing  

module alpha_scaling 
  #(
  
   parameter width_p = 10 			
   
  )
  (

	input wire alpha_sign, 
	input wire [4:0] alpha_index, 
	input wire signed  [width_p+2:0] AC_value, 
	
	output wire signed [width_p+2:0] CFL_o 
   
   );
   
 // signal = 1 --> negative 
 // signal = 0 --> positive 
 
 // alpha index table 
 // alpha index | alpha value | calc 
 // ------------|-------------|----------
 // 	0		|  0		  |	0
 // 	1		|  0.125      | x >> 3
 //		2		|  0.250      | x >> 2
 //		3		|  0.375      | (x>>2) + (x>>3)
 // 	4		|  0.500      | (x >> 1)
 //		5       |  0.625      | (x >>> 1) + (x >>> 3)
 //		6       |  0.750      | (x >>> 1) + (x >>> 2)
 //		7       |  0.875      | (x >>> 1) + (x >>> 2) + (x >>> 3) ----/---- 		x - (x >> 3)
 //		8		|  1.000      |
 //		9       |  1.125      | (x + (x >>> 3))
 //	    10      |  1.250      | (x + (x >>> 2))
 //		11      |  1.375      | (x + (x >>> 2) + (x >>> 3))
 // 	12		|  1.500      | (x + (x >>> 1))
 //	    13      |  1.625      |  x + (x >>> 1) + (x >>> 3)
 //		14      |  1.750      |  x + (x >>> 1) + (x >>> 2)    ----------/------- 	(x << 1) - (x >> 2)
 // 	15      |  1.875      |  x + (x >>> 1) + (x >>> 2) + (x >>> 3) ----- / ---- (x << 1) - (x >> 3)
 // 	16		|  2.000      |	 x << 2
 
 
	assign CFL_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 														:								       					 
				   (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value  >>> 3) 					    				 				:
		           (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value >>> 3) 					     				 				: 		   
		           (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value  >>> 2) 					     				 				:
		           (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value >>> 2) 					     				 				: 	
		           (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value  >>> 2) + (AC_value >>> 3)    	 				 			:
		           (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value >>> 2) + (AC_value >>> 3)) 	 				 				:
		           (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value  >>> 1) 					   					 				:
		           (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value >>> 1) 					    				 				:		   		   
		           (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value  >>> 1) + (AC_value >>> 3)      				 				:
		           (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value >>> 1) + (AC_value >>> 3))      			 	 			:
		           (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value  >>> 1) + (AC_value >>> 2)       			 	 			:
		           (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value >>> 1) + (AC_value >>> 2))     			 	 				:			   
		           (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value - (AC_value >>> 3))	 										: 
		           (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value - (AC_value >>> 3))   										: 
		           (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value) 					   						 	 			:
		           (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value)							    			 	 			:			   
		           (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value) + (AC_value >>> 3))  						 	 			:
		           (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value) + (AC_value >>> 3))		    			 	 			:
		           (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value) + (AC_value >>> 2)) 						 	 			:
		           (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value) + (AC_value >>> 2))		    			 	 			:
		           (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value) + (AC_value >>> 2) + (AC_value >>> 3))	 	 				:
		           (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value) + (AC_value >>> 2) + (AC_value >>> 3))  	 	 			:		   
		           (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value) + (AC_value >>> 1)) 	 					 	 			:
		           (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value) + (AC_value >>> 1))  	 					     			:	
		           (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value) + (AC_value >>> 1) + (AC_value >>> 3))	 	 				:
		           (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value) + (AC_value >>> 1) + (AC_value >>> 3))  	 	 			:
		           (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value <<< 1) - (AC_value >>> 2))	 	 							:		
		           (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value <<< 1) - (AC_value >>> 2))	 								:		   
		           (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value <<< 1) - (AC_value >>> 3))									: 
		           (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value <<< 1) - (AC_value >>> 3)) 									: 	
		           (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value <<< 1) 		   												:
		           (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value <<< 1) 														:
				   0; 
		   
endmodule 