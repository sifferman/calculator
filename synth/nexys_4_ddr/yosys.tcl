
yosys -import
plugin -i systemverilog
yosys -import

# Get file list from "rtl/rtl.f"
set f [open rtl/rtl.f r]
set contents [read $f]
close $f
set RTL [regexp -all -inline {\S+} $contents]

read_systemverilog -noinfo -nonote {*}$RTL synth/nexys_4_ddr/nexys_4_ddr.sv

synth_xilinx -top nexys_4_ddr -family xc7 -edif synth/build/nexys_4_ddr.edif

write_verilog -noexpr -noattr -simple-lhs synth/build/nexys_4_ddr.v
