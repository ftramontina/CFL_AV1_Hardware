set DESIGN CFL_Intraprediction_Top

set_db init_hdl_search_path /home/mic02/felipe.tramontina/FLP/lab_sintese/rtl
set_db init_lib_search_path /home/mic02/felipe.tramontina/FLP/lab_sintese/gpdk045_workspace/gsclib045_all_v4.4/gsclib045/timing

read_libs { slow_vdd1v0_basicCells.lib }

read_hdl alpha_scaling.v
read_hdl CFL_Intraprediction_Top.v
read_hdl CFL_Top_Level.v
read_hdl Control_Unit.v
read_hdl DC_1d.v
read_hdl DC_Intraprediction.v
read_hdl DC_left_top.v
read_hdl DC_sum.v
read_hdl Luma_avg_processing.v
read_hdl -language sv Luma_memory.sv
read_hdl Output_pipeline.v
read_hdl subsampling.v
read_hdl -language sv Subsampling_Memory.sv
read_hdl sum_2_samples.v

elaborate $DESIGN

check_design > reports/check_design.rpt
report_hierarchy > reports/report_hierarchy.rpt
report_design > reports/report_design.rpt

set_db auto_ungroup none
read_sdc ../constraints/constraints.sdc

set_db syn_generic_effort medium
syn_generic

report_area > reports/report_area_generic.rpt
report_timing > reports/report_timing_generic.rpt
report_power > reports/report_power_generic.rpt

set_db syn_map_effort medium
syn_map

#report_unmapped > reports/report_unmapped.rpt
report_area > reports/report_area_map.rpt
report_timing > reports/report_timing_map.rpt
report_power > reports/report_power_map.rpt

set_db syn_opt_effort medium
syn_opt

report_area > reports/report_area_opt.rpt
report_timing > reports/report_timing_opt.rpt
report_power > reports/report_power_opt.rpt

#Outputs
write_hdl > outputs/CFL_netlist.v
write_sdc > outputs/CFL_netlist_constraints.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > outputs/delays.sdf