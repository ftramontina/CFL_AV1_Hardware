# Clock principal 180 MHz
create_clock -name clk -period 2.3 [get_ports clk_i]

# Incerteza (jitter + skew)
set_clock_uncertainty 0.2 [get_clocks clk]

# Input delay (todas as entradas exceto clock)
set_input_delay -clock clk -max 0.2 \
  [remove_from_collection [all_inputs] [get_ports clk_i]]

set_input_delay -clock clk -min 0.0 \
  [remove_from_collection [all_inputs] [get_ports clk_i]]

set_input_transition -rise 0.2 -fall 0.2 \
  [remove_from_collection [all_inputs] [get_ports clk_i]]

# Output delay
set_output_delay -clock clk -max 0.5 [all_outputs]
set_output_delay -clock clk -min -0.1 [all_outputs]
