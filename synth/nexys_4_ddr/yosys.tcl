
yosys -import

read_verilog synth/build/nexys_4_ddr.sv2v.v

synth_xilinx -top nexys_4_ddr -family xc7 -edif synth/build/nexys_4_ddr.edif

write_verilog -noexpr -noattr -simple-lhs synth/build/nexys_4_ddr.v
