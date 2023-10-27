
yosys -import
plugin -i systemverilog
yosys -import

read_systemverilog -noinfo -nonote \
rtl/calc_pkg.sv \
rtl/alu.sv \
rtl/calculator.sv \
rtl/num_register.sv \
rtl/sanitize_buttons.sv \
rtl/alu/alu_add.sv \
rtl/controller.sv

prep
opt
stat
write_verilog -noexpr -noattr -simple-lhs synth/build.v
