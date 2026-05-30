
// Alpha processing  

module alpha_scaling 
  #(
  
   parameter width_p = 10 			
   
  )
  (

	input wire alpha_sign, 
	input wire [4:0] alpha_index,
	
	input wire signed  [width_p+2:0] AC_value_00, 
	input wire signed  [width_p+2:0] AC_value_01, 
	input wire signed  [width_p+2:0] AC_value_02,
	input wire signed  [width_p+2:0] AC_value_03,
	input wire signed  [width_p+2:0] AC_value_04,
	input wire signed  [width_p+2:0] AC_value_05,
	input wire signed  [width_p+2:0] AC_value_06,
	input wire signed  [width_p+2:0] AC_value_07,	
	input wire signed  [width_p+2:0] AC_value_08,
	input wire signed  [width_p+2:0] AC_value_09,
	input wire signed  [width_p+2:0] AC_value_10,
	input wire signed  [width_p+2:0] AC_value_11,
	input wire signed  [width_p+2:0] AC_value_12,
	input wire signed  [width_p+2:0] AC_value_13,
	input wire signed  [width_p+2:0] AC_value_14,
	input wire signed  [width_p+2:0] AC_value_15,
	
	output wire signed [width_p+2:0] CFL_00_o, 
 	output wire signed [width_p+2:0] CFL_01_o, 
	output wire signed [width_p+2:0] CFL_02_o, 
	output wire signed [width_p+2:0] CFL_03_o, 
	output wire signed [width_p+2:0] CFL_04_o,
	output wire signed [width_p+2:0] CFL_05_o, 
	output wire signed [width_p+2:0] CFL_06_o, 
	output wire signed [width_p+2:0] CFL_07_o, 
	output wire signed [width_p+2:0] CFL_08_o, 
	output wire signed [width_p+2:0] CFL_09_o, 
	output wire signed [width_p+2:0] CFL_10_o, 
	output wire signed [width_p+2:0] CFL_11_o, 
	output wire signed [width_p+2:0] CFL_12_o, 
	output wire signed [width_p+2:0] CFL_13_o, 
	output wire signed [width_p+2:0] CFL_14_o, 
	output wire signed [width_p+2:0] CFL_15_o 
	
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
 
 
	assign CFL_00_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_00  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_00 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_00  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_00 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_00  >>> 2) + (AC_value_00 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_00 >>> 2) + (AC_value_00 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_00  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_00 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_00  >>> 1) + (AC_value_00 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_00 >>> 1) + (AC_value_00 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_00  >>> 1) + (AC_value_00 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_00 >>> 1) + (AC_value_00 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_00 - (AC_value_00 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_00 - (AC_value_00 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_00) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_00)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_00) + (AC_value_00 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_00) + (AC_value_00 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_00) + (AC_value_00 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_00) + (AC_value_00 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_00) + (AC_value_00 >>> 2) + (AC_value_00 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_00) + (AC_value_00 >>> 2) + (AC_value_00 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_00) + (AC_value_00 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_00) + (AC_value_00 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_00) + (AC_value_00 >>> 1) + (AC_value_00 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_00) + (AC_value_00 >>> 1) + (AC_value_00 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_00 <<< 1) - (AC_value_00 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_00 <<< 1) - (AC_value_00 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_00 <<< 1) - (AC_value_00 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_00 <<< 1) - (AC_value_00 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_00 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_00 <<< 1) 														:
					 0;

	assign CFL_01_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_01  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_01 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_01  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_01 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_01  >>> 2) + (AC_value_01 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_01 >>> 2) + (AC_value_01 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_01  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_01 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_01  >>> 1) + (AC_value_01 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_01 >>> 1) + (AC_value_01 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_01  >>> 1) + (AC_value_01 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_01 >>> 1) + (AC_value_01 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_01 - (AC_value_01 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_01 - (AC_value_01 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_01) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_01)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_01) + (AC_value_01 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_01) + (AC_value_01 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_01) + (AC_value_01 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_01) + (AC_value_01 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_01) + (AC_value_01 >>> 2) + (AC_value_01 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_01) + (AC_value_01 >>> 2) + (AC_value_01 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_01) + (AC_value_01 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_01) + (AC_value_01 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_01) + (AC_value_01 >>> 1) + (AC_value_01 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_01) + (AC_value_01 >>> 1) + (AC_value_01 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_01 <<< 1) - (AC_value_01 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_01 <<< 1) - (AC_value_01 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_01 <<< 1) - (AC_value_01 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_01 <<< 1) - (AC_value_01 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_01 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_01 <<< 1) 														:
					 0;

	assign CFL_02_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_02  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_02 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_02  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_02 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_02  >>> 2) + (AC_value_02 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_02 >>> 2) + (AC_value_02 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_02  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_02 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_02  >>> 1) + (AC_value_02 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_02 >>> 1) + (AC_value_02 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_02  >>> 1) + (AC_value_02 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_02 >>> 1) + (AC_value_02 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_02 - (AC_value_02 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_02 - (AC_value_02 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_02) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_02)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_02) + (AC_value_02 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_02) + (AC_value_02 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_02) + (AC_value_02 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_02) + (AC_value_02 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_02) + (AC_value_02 >>> 2) + (AC_value_02 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_02) + (AC_value_02 >>> 2) + (AC_value_02 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_02) + (AC_value_02 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_02) + (AC_value_02 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_02) + (AC_value_02 >>> 1) + (AC_value_02 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_02) + (AC_value_02 >>> 1) + (AC_value_02 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_02 <<< 1) - (AC_value_02 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_02 <<< 1) - (AC_value_02 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_02 <<< 1) - (AC_value_02 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_02 <<< 1) - (AC_value_02 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_02 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_02 <<< 1) 														:
					 0;

	assign CFL_03_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_03  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_03 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_03  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_03 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_03  >>> 2) + (AC_value_03 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_03 >>> 2) + (AC_value_03 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_03  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_03 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_03  >>> 1) + (AC_value_03 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_03 >>> 1) + (AC_value_03 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_03  >>> 1) + (AC_value_03 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_03 >>> 1) + (AC_value_03 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_03 - (AC_value_03 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_03 - (AC_value_03 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_03) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_03)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_03) + (AC_value_03 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_03) + (AC_value_03 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_03) + (AC_value_03 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_03) + (AC_value_03 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_03) + (AC_value_03 >>> 2) + (AC_value_03 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_03) + (AC_value_03 >>> 2) + (AC_value_03 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_03) + (AC_value_03 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_03) + (AC_value_03 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_03) + (AC_value_03 >>> 1) + (AC_value_03 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_03) + (AC_value_03 >>> 1) + (AC_value_03 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_03 <<< 1) - (AC_value_03 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_03 <<< 1) - (AC_value_03 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_03 <<< 1) - (AC_value_03 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_03 <<< 1) - (AC_value_03 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_03 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_03 <<< 1) 														:
					 0;

	assign CFL_04_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_04  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_04 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_04  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_04 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_04  >>> 2) + (AC_value_04 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_04 >>> 2) + (AC_value_04 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_04  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_04 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_04  >>> 1) + (AC_value_04 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_04 >>> 1) + (AC_value_04 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_04  >>> 1) + (AC_value_04 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_04 >>> 1) + (AC_value_04 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_04 - (AC_value_04 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_04 - (AC_value_04 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_04) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_04)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_04) + (AC_value_04 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_04) + (AC_value_04 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_04) + (AC_value_04 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_04) + (AC_value_04 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_04) + (AC_value_04 >>> 2) + (AC_value_04 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_04) + (AC_value_04 >>> 2) + (AC_value_04 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_04) + (AC_value_04 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_04) + (AC_value_04 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_04) + (AC_value_04 >>> 1) + (AC_value_04 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_04) + (AC_value_04 >>> 1) + (AC_value_04 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_04 <<< 1) - (AC_value_04 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_04 <<< 1) - (AC_value_04 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_04 <<< 1) - (AC_value_04 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_04 <<< 1) - (AC_value_04 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_04 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_04 <<< 1) 														:
					 0;

	assign CFL_05_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_05  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_05 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_05  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_05 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_05  >>> 2) + (AC_value_05 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_05 >>> 2) + (AC_value_05 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_05  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_05 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_05  >>> 1) + (AC_value_05 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_05 >>> 1) + (AC_value_05 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_05  >>> 1) + (AC_value_05 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_05 >>> 1) + (AC_value_05 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_05 - (AC_value_05 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_05 - (AC_value_05 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_05) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_05)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_05) + (AC_value_05 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_05) + (AC_value_05 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_05) + (AC_value_05 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_05) + (AC_value_05 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_05) + (AC_value_05 >>> 2) + (AC_value_05 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_05) + (AC_value_05 >>> 2) + (AC_value_05 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_05) + (AC_value_05 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_05) + (AC_value_05 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_05) + (AC_value_05 >>> 1) + (AC_value_05 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_05) + (AC_value_05 >>> 1) + (AC_value_05 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_05 <<< 1) - (AC_value_05 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_05 <<< 1) - (AC_value_05 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_05 <<< 1) - (AC_value_05 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_05 <<< 1) - (AC_value_05 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_05 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_05 <<< 1) 														:
					 0; 	

	assign CFL_06_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_06  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_06 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_06  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_06 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_06  >>> 2) + (AC_value_06 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_06 >>> 2) + (AC_value_06 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_06  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_06 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_06  >>> 1) + (AC_value_06 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_06 >>> 1) + (AC_value_06 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_06  >>> 1) + (AC_value_06 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_06 >>> 1) + (AC_value_06 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_06 - (AC_value_06 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_06 - (AC_value_06 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_06) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_06)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_06) + (AC_value_06 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_06) + (AC_value_06 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_06) + (AC_value_06 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_06) + (AC_value_06 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_06) + (AC_value_06 >>> 2) + (AC_value_06 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_06) + (AC_value_06 >>> 2) + (AC_value_06 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_06) + (AC_value_06 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_06) + (AC_value_06 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_06) + (AC_value_06 >>> 1) + (AC_value_06 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_06) + (AC_value_06 >>> 1) + (AC_value_06 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_06 <<< 1) - (AC_value_06 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_06 <<< 1) - (AC_value_06 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_06 <<< 1) - (AC_value_06 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_06 <<< 1) - (AC_value_06 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_06 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_06 <<< 1) 														:
					 0;

	assign CFL_07_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_07  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_07 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_07  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_07 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_07  >>> 2) + (AC_value_07 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_07 >>> 2) + (AC_value_07 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_07  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_07 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_07  >>> 1) + (AC_value_07 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_07 >>> 1) + (AC_value_07 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_07  >>> 1) + (AC_value_07 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_07 >>> 1) + (AC_value_07 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_07 - (AC_value_07 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_07 - (AC_value_07 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_07) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_07)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_07) + (AC_value_07 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_07) + (AC_value_07 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_07) + (AC_value_07 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_07) + (AC_value_07 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_07) + (AC_value_07 >>> 2) + (AC_value_07 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_07) + (AC_value_07 >>> 2) + (AC_value_07 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_07) + (AC_value_07 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_07) + (AC_value_07 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_07) + (AC_value_07 >>> 1) + (AC_value_07 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_07) + (AC_value_07 >>> 1) + (AC_value_07 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_07 <<< 1) - (AC_value_07 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_07 <<< 1) - (AC_value_07 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_07 <<< 1) - (AC_value_07 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_07 <<< 1) - (AC_value_07 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_07 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_07 <<< 1) 														:
					 0; 

	assign CFL_08_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_08  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_08 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_08  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_08 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_08  >>> 2) + (AC_value_08 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_08 >>> 2) + (AC_value_08 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_08  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_08 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_08  >>> 1) + (AC_value_08 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_08 >>> 1) + (AC_value_08 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_08  >>> 1) + (AC_value_08 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_08 >>> 1) + (AC_value_08 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_08 - (AC_value_08 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_08 - (AC_value_08 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_08) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_08)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_08) + (AC_value_08 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_08) + (AC_value_08 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_08) + (AC_value_08 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_08) + (AC_value_08 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_08) + (AC_value_08 >>> 2) + (AC_value_08 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_08) + (AC_value_08 >>> 2) + (AC_value_08 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_08) + (AC_value_08 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_08) + (AC_value_08 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_08) + (AC_value_08 >>> 1) + (AC_value_08 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_08) + (AC_value_08 >>> 1) + (AC_value_08 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_08 <<< 1) - (AC_value_08 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_08 <<< 1) - (AC_value_08 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_08 <<< 1) - (AC_value_08 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_08 <<< 1) - (AC_value_08 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_08 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_08 <<< 1) 														:
					 0; 	

	assign CFL_09_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_09  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_09 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_09  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_09 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_09  >>> 2) + (AC_value_09 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_09 >>> 2) + (AC_value_09 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_09  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_09 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_09  >>> 1) + (AC_value_09 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_09 >>> 1) + (AC_value_09 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_09  >>> 1) + (AC_value_09 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_09 >>> 1) + (AC_value_09 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_09 - (AC_value_09 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_09 - (AC_value_09 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_09) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_09)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_09) + (AC_value_09 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_09) + (AC_value_09 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_09) + (AC_value_09 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_09) + (AC_value_09 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_09) + (AC_value_09 >>> 2) + (AC_value_09 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_09) + (AC_value_09 >>> 2) + (AC_value_09 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_09) + (AC_value_09 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_09) + (AC_value_09 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_09) + (AC_value_09 >>> 1) + (AC_value_09 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_09) + (AC_value_09 >>> 1) + (AC_value_09 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_09 <<< 1) - (AC_value_09 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_09 <<< 1) - (AC_value_09 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_09 <<< 1) - (AC_value_09 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_09 <<< 1) - (AC_value_09 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_09 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_09 <<< 1) 														:
					 0; 

	assign CFL_10_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_10  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_10 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_10  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_10 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_10  >>> 2) + (AC_value_10 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_10 >>> 2) + (AC_value_10 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_10  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_10 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_10  >>> 1) + (AC_value_10 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_10 >>> 1) + (AC_value_10 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_10  >>> 1) + (AC_value_10 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_10 >>> 1) + (AC_value_10 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_10 - (AC_value_10 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_10 - (AC_value_10 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_10) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_10)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_10) + (AC_value_10 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_10) + (AC_value_10 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_10) + (AC_value_10 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_10) + (AC_value_10 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_10) + (AC_value_10 >>> 2) + (AC_value_10 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_10) + (AC_value_10 >>> 2) + (AC_value_10 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_10) + (AC_value_10 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_10) + (AC_value_10 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_10) + (AC_value_10 >>> 1) + (AC_value_10 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_10) + (AC_value_10 >>> 1) + (AC_value_10 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_10 <<< 1) - (AC_value_10 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_10 <<< 1) - (AC_value_10 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_10 <<< 1) - (AC_value_10 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_10 <<< 1) - (AC_value_10 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_10 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_10 <<< 1) 														:
					 0;

	assign CFL_11_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_11  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_11 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_11  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_11 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_11  >>> 2) + (AC_value_11 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_11 >>> 2) + (AC_value_11 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_11  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_11 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_11  >>> 1) + (AC_value_11 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_11 >>> 1) + (AC_value_11 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_11  >>> 1) + (AC_value_11 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_11 >>> 1) + (AC_value_11 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_11 - (AC_value_11 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_11 - (AC_value_11 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_11) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_11)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_11) + (AC_value_11 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_11) + (AC_value_11 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_11) + (AC_value_11 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_11) + (AC_value_11 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_11) + (AC_value_11 >>> 2) + (AC_value_11 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_11) + (AC_value_11 >>> 2) + (AC_value_11 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_11) + (AC_value_11 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_11) + (AC_value_11 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_11) + (AC_value_11 >>> 1) + (AC_value_11 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_11) + (AC_value_11 >>> 1) + (AC_value_11 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_11 <<< 1) - (AC_value_11 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_11 <<< 1) - (AC_value_11 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_11 <<< 1) - (AC_value_11 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_11 <<< 1) - (AC_value_11 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_11 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_11 <<< 1) 														:
					 0;  				

	assign CFL_12_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_12  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_12 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_12  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_12 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_12  >>> 2) + (AC_value_12 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_12 >>> 2) + (AC_value_12 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_12  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_12 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_12  >>> 1) + (AC_value_12 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_12 >>> 1) + (AC_value_12 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_12  >>> 1) + (AC_value_12 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_12 >>> 1) + (AC_value_12 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_12 - (AC_value_12 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_12 - (AC_value_12 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_12) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_12)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_12) + (AC_value_12 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_12) + (AC_value_12 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_12) + (AC_value_12 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_12) + (AC_value_12 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_12) + (AC_value_12 >>> 2) + (AC_value_12 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_12) + (AC_value_12 >>> 2) + (AC_value_12 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_12) + (AC_value_12 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_12) + (AC_value_12 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_12) + (AC_value_12 >>> 1) + (AC_value_12 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_12) + (AC_value_12 >>> 1) + (AC_value_12 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_12 <<< 1) - (AC_value_12 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_12 <<< 1) - (AC_value_12 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_12 <<< 1) - (AC_value_12 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_12 <<< 1) - (AC_value_12 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_12 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_12 <<< 1) 														:
					 0; 

	assign CFL_13_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_13  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_13 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_13  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_13 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_13  >>> 2) + (AC_value_13 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_13 >>> 2) + (AC_value_13 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_13  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_13 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_13  >>> 1) + (AC_value_13 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_13 >>> 1) + (AC_value_13 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_13  >>> 1) + (AC_value_13 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_13 >>> 1) + (AC_value_13 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_13 - (AC_value_13 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_13 - (AC_value_13 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_13) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_13)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_13) + (AC_value_13 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_13) + (AC_value_13 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_13) + (AC_value_13 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_13) + (AC_value_13 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_13) + (AC_value_13 >>> 2) + (AC_value_13 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_13) + (AC_value_13 >>> 2) + (AC_value_13 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_13) + (AC_value_13 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_13) + (AC_value_13 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_13) + (AC_value_13 >>> 1) + (AC_value_13 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_13) + (AC_value_13 >>> 1) + (AC_value_13 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_13 <<< 1) - (AC_value_13 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_13 <<< 1) - (AC_value_13 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_13 <<< 1) - (AC_value_13 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_13 <<< 1) - (AC_value_13 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_13 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_13 <<< 1) 														:
					 0; 

	assign CFL_14_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_14  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_14 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_14  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_14 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_14  >>> 2) + (AC_value_14 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_14 >>> 2) + (AC_value_14 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_14  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_14 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_14  >>> 1) + (AC_value_14 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_14 >>> 1) + (AC_value_14 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_14  >>> 1) + (AC_value_14 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_14 >>> 1) + (AC_value_14 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_14 - (AC_value_14 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_14 - (AC_value_14 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_14) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_14)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_14) + (AC_value_14 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_14) + (AC_value_14 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_14) + (AC_value_14 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_14) + (AC_value_14 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_14) + (AC_value_14 >>> 2) + (AC_value_14 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_14) + (AC_value_14 >>> 2) + (AC_value_14 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_14) + (AC_value_14 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_14) + (AC_value_14 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_14) + (AC_value_14 >>> 1) + (AC_value_14 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_14) + (AC_value_14 >>> 1) + (AC_value_14 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_14 <<< 1) - (AC_value_14 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_14 <<< 1) - (AC_value_14 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_14 <<< 1) - (AC_value_14 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_14 <<< 1) - (AC_value_14 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_14 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_14 <<< 1) 														:
					 0; 	

	assign CFL_15_o = ((alpha_index == 0) && ((alpha_sign) || (!alpha_sign))) ?  0 															:								       					 
					 (alpha_index == 1   &&  alpha_sign  == 0)  ?  (AC_value_15  >>> 3) 					    				 			:
					 (alpha_index == 1   &&  alpha_sign  == 1)  ?  (-AC_value_15 >>> 3) 					     				 			: 		   
					 (alpha_index == 2   &&  alpha_sign  == 0)  ?  (AC_value_15  >>> 2) 					     				 			:
					 (alpha_index == 2   &&  alpha_sign  == 1)  ?  (-AC_value_15 >>> 2) 					     				 			: 	
					 (alpha_index == 3   &&  alpha_sign  == 0)  ?  (AC_value_15  >>> 2) + (AC_value_15 >>> 3)    	 				 		:
					 (alpha_index == 3   &&  alpha_sign  == 1)  ? -((AC_value_15 >>> 2) + (AC_value_15 >>> 3)) 	 				 			:
					 (alpha_index == 4   &&  alpha_sign  == 0)  ?  (AC_value_15  >>> 1) 					   					 			:
					 (alpha_index == 4   &&  alpha_sign  == 1)  ?  (-AC_value_15 >>> 1) 					    				 			:		   		   
					 (alpha_index == 5   &&  alpha_sign  == 0)  ?  (AC_value_15  >>> 1) + (AC_value_15 >>> 3)      				 			:
					 (alpha_index == 5   &&  alpha_sign  == 1)  ? -((AC_value_15 >>> 1) + (AC_value_15 >>> 3))      			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 0)  ?  (AC_value_15  >>> 1) + (AC_value_15 >>> 2)       			 	 		:
					 (alpha_index == 6   &&  alpha_sign  == 1)  ? -((AC_value_15 >>> 1) + (AC_value_15 >>> 2))     			 	 			:			   
					 (alpha_index == 7   &&  alpha_sign  == 0)  ?  (AC_value_15 - (AC_value_15 >>> 3))	 									: 
					 (alpha_index == 7   &&  alpha_sign  == 1)  ? -(AC_value_15 - (AC_value_15 >>> 3))   									: 
					 (alpha_index == 8   &&  alpha_sign  == 0)  ?  (AC_value_15) 					   						 	 			:
					 (alpha_index == 8   &&  alpha_sign  == 1)  ?  (-AC_value_15)							    			 	 			:			   
					 (alpha_index == 9   &&  alpha_sign  == 0)  ?  ((AC_value_15) + (AC_value_15 >>> 3))  						 	 		:
					 (alpha_index == 9   &&  alpha_sign  == 1)  ? -((AC_value_15) + (AC_value_15 >>> 3))		    			 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 0)  ?  ((AC_value_15) + (AC_value_15 >>> 2)) 						 	 		:
					 (alpha_index == 10  &&  alpha_sign  == 1)  ? -((AC_value_15) + (AC_value_15 >>> 2))		    			 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 0)  ?  ((AC_value_15) + (AC_value_15 >>> 2) + (AC_value_15 >>> 3))	 	 		:
					 (alpha_index == 11  &&  alpha_sign  == 1)  ? -((AC_value_15) + (AC_value_15 >>> 2) + (AC_value_15 >>> 3))  	 	 	:		   
					 (alpha_index == 12  &&  alpha_sign  == 0)  ?  ((AC_value_15) + (AC_value_15 >>> 1)) 	 					 	 		:
					 (alpha_index == 12  &&  alpha_sign  == 1)  ? -((AC_value_15) + (AC_value_15 >>> 1))  	 					     		:	
					 (alpha_index == 13  &&  alpha_sign  == 0)  ?  ((AC_value_15) + (AC_value_15 >>> 1) + (AC_value_15 >>> 3))	 	 		:
					 (alpha_index == 13  &&  alpha_sign  == 1)  ? -((AC_value_15) + (AC_value_15 >>> 1) + (AC_value_15 >>> 3))  	 	 	:
					 (alpha_index == 14  &&  alpha_sign  == 0)  ?  ((AC_value_15 <<< 1) - (AC_value_15 >>> 2))	 	 						:		
					 (alpha_index == 14  &&  alpha_sign  == 1)  ? -((AC_value_15 <<< 1) - (AC_value_15 >>> 2))	 							:		   
					 (alpha_index == 15  &&  alpha_sign  == 0)  ?  ((AC_value_15 <<< 1) - (AC_value_15 >>> 3))								: 
					 (alpha_index == 15  &&  alpha_sign  == 1)  ? -((AC_value_15 <<< 1) - (AC_value_15 >>> 3)) 								: 	
					 (alpha_index == 16  &&  alpha_sign  == 0)  ?  (AC_value_15 <<< 1) 		   												:
					 (alpha_index == 16  &&  alpha_sign  == 1)  ? -(AC_value_15 <<< 1) 														:
					 0; 					 
		   
endmodule 