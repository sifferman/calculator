
yosys -import
plugin -i systemverilog
yosys -import

# Get file list from "rtl/rtl.f"
set f [open rtl/rtl.f r]
set contents [read $f]
close $f
set RTL [regexp -all -inline {\S+} $contents]

read_systemverilog -noinfo -nonote {*}$RTL

prep
opt
stat
write_verilog -noexpr -noattr -simple-lhs synth/build/synth.v
write_json synth/build/synth.json
