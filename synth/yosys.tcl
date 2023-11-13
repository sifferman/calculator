
yosys -import
plugin -i systemverilog
yosys -import

# Get file list from "rtl/rtl.f"
set pipe [open "| python3 ./misc/convert_filelist.py Synlig rtl/rtl.f" r]
set RTL [read $pipe]
close $pipe

read_systemverilog -noinfo -nonote {*}$RTL

prep
opt
stat
write_verilog -noexpr -noattr -simple-lhs synth/build/synth.v
write_json synth/build/synth.json
