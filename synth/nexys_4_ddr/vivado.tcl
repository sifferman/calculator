# start_gui

# Create Project
create_project nexys_4_ddr synth/build/nexys_4_ddr -part xc7a100tcsg324-1
set_property design_mode GateLvl [current_fileset]

# Add EDIF
add_files -norecurse synth/build/nexys_4_ddr.edif
set_property top_file synth/build/nexys_4_ddr.edif [current_fileset]

# Add constraints
add_files -fileset constrs_1 -norecurse synth/nexys_4_ddr/nexys_4_ddr.xdc synth/nexys_4_ddr/constraints.xdc

# Run PNR
launch_runs impl_1
wait_on_run impl_1

# Artix-7
# set_property CONFIG_VOLTAGE 3.3 [current_design]
# set_property CFGBVS VCCO [current_design]

# Create Bitstream
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Done
exit
