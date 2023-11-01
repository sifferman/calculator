
rtl/calc_pkg.sv
dv/dv_pkg.sv
dv/model/alu_model_pkg.sv

dv/calculator_tb.sv
dv/controller_tb.sv
dv/alu_add_tb.sv
dv/screen_driver_tb.sv

--timing
-j 0
-Wall
-Wno-fatal
--assert
--trace-fst
--trace-structs
+1364-2005ext+v
+1800-2012ext+sv

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique
