
yosys -import
plugin -i systemverilog
yosys -import

read_systemverilog -noinfo -nonote \
rtl/calc_pkg.sv \
rtl/alu/alu_add.sv \
rtl/alu/alu.sv \
rtl/calculator.sv \
rtl/num_register.sv \
rtl/sanitize_buttons.sv \
rtl/screen_driver.sv \
rtl/controller.sv

prep
opt
stat
write_verilog -noexpr -noattr -simple-lhs synth/build/synth.v
write_json synth/build/synth.json
