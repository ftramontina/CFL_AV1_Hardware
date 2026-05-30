onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/clk_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/rst_i
add wave -noupdate -color Yellow -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/address_i_final
add wave -noupdate -color Yellow -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/address_j_final
add wave -noupdate -color Yellow -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_final
add wave -noupdate /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_final_ready
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/chr_data_in_valid_top_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/chr_data_in_valid_left_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/luma_data_in_valid_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/block_height_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/block_width_i
add wave -noupdate -group Chr_Sample_Left -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_left_0
add wave -noupdate -group Chr_Sample_Left -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_left_1
add wave -noupdate -group Chr_Sample_Left -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_left_2
add wave -noupdate -group Chr_Sample_Left -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_left_3
add wave -noupdate -group Chr_Sample_Top -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_top_0
add wave -noupdate -group Chr_Sample_Top -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_top_1
add wave -noupdate -group Chr_Sample_Top -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_top_2
add wave -noupdate -group Chr_Sample_Top -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/chr_sample_top_3
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_0_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_1_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_2_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_3_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_4_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_5_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_6_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_7_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_8_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_9_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_10_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_11_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_12_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_13_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_14_i
add wave -noupdate -group Luma_samples -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/luma_sample_15_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/CFL_Top_inst/luma_mem_inst/mem
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/CFL_Top_inst/sub_memory_inst/mem
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/CFL_Top_inst/DC_Intra_Chr_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/CFL_Top_inst/DC_Chr_ready_i
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/CFL_Top_inst/avg
add wave -noupdate /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/intrapred_data_out_o
add wave -noupdate /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/ready_o
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/DC_left_top_32_32_reg
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/DC_left_top_32_32_inst/sum_left_top
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/DC_left_top_32_32_inst/DC_left_top
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/DC_Sum_Top/sum_16_reg
add wave -noupdate -radix unsigned /tb_CFL_Intra_top_all_block_comb_sizes_420/CFL_Intraprediction_Top_Inst/DC_intraprediction_inst/DC_Sum_Left/sum_16_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18448415 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 731
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {18040977 ps} {18554783 ps}
