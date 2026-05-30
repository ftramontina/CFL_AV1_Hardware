# CFL_AV1_Hardware
RTL design for the Chroma From Luma Intraprediction mode of the AV1 codec. 

There are two versions:      

High throughput version
     - 16x 10-bit sample input  (16x samples input per clock cycle)
     - 16x 10-bit sample output (16x samples output per clock cycle)
     - 420 and 422 subsampling mode
     - pipelines, more complicated to understand
     - 4k @60fps and 8k @24fps 


SLow version
     - 16x 10-bit sample input  (16x samples input per clock cycle)
     - 1x  10-bit sample output (1x samples output per clock cycle)
     - 420 and 422 subsampling mode
     - Full HD 60fps 
     - Easier to understand 


