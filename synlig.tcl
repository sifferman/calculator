
rename eval tcl_eval

yosys -import
plugin -i systemverilog
yosys -import

read_systemverilog -noinfo -nonote -defer rtl/alu.sv
read_systemverilog -noinfo -nonote -defer rtl/calc_pkg.sv
read_systemverilog -noinfo -nonote -defer rtl/calculator.sv
read_systemverilog -noinfo -nonote -defer rtl/controller.sv
read_systemverilog -noinfo -nonote -defer rtl/register.sv
read_systemverilog -noinfo -nonote -defer rtl/sanitize_buttons.sv
read_systemverilog -link

synth -top calculator
opt
stat
