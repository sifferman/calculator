
yosys -import
plugin -i systemverilog
yosys -import

read_json synth/build/synth.json

synth_xilinx -top calculator -family xc7

write_edif synth/build/xc7.edif
