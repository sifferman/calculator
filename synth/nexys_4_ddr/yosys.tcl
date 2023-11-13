
yosys -import
plugin -i systemverilog
yosys -import

# Get file list from "rtl/rtl.f"
set pipe [open "| python3 ./misc/convert_filelist.py Synlig rtl/rtl.f" r]
set RTL [read $pipe]
close $pipe

read_systemverilog -noinfo -nonote {*}$RTL synth/nexys_4_ddr/nexys_4_ddr.sv

synth_xilinx -top nexys_4_ddr -family xc7 -edif synth/build/nexys_4_ddr.edif

write_verilog -noexpr -noattr -simple-lhs synth/build/nexys_4_ddr.v
