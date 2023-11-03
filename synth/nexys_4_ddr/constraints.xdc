
# Clock Signal
create_generated_clock -name slow_clk -source [get_pins clk_divider/clk_i] -divide_by 100000 [get_pins clk_divider/clk_o]
