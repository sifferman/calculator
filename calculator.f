
rtl/calc_pkg.sv
rtl/alu.sv
rtl/register.sv
rtl/sanitize_buttons.sv
rtl/controller.sv
rtl/calculator.sv

dv/controller_tb.sv

--timing
-j 0
--trace-fst
--trace-structs
--x-assign unique
--x-initial unique

// +verilator+rand+reset+2
