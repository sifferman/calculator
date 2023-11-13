
// packages
rtl/calc_pkg.sv
dv/dv_pkg.sv
dv/model/alu_model_pkg.sv

// common
rtl/common/clk_divider.sv

// HardFloat
+incdir+third_party/HardFloat/source
+incdir+third_party/HardFloat/source/RISCV
+incdir+third_party/basejump_stl/bsg_misc
third_party/basejump_stl/bsg_misc/bsg_counting_leading_zeros.v
third_party/basejump_stl/bsg_misc/bsg_encode_one_hot.v
third_party/basejump_stl/bsg_misc/bsg_priority_encode.v
third_party/basejump_stl/bsg_misc/bsg_priority_encode_one_hot_out.v
third_party/basejump_stl/bsg_misc/bsg_scan.v
third_party/HardFloat/source/addRecFN.v
third_party/HardFloat/source/divSqrtRecFN_small.v
third_party/HardFloat/source/HardFloat_primitives.v
third_party/HardFloat/source/recFNToIN.v
third_party/HardFloat/source/isSigNaNRecFN.v
third_party/HardFloat/source/iNToRecFN.v
third_party/HardFloat/source/recFNToRecFN.v
third_party/HardFloat/source/HardFloat_rawFN.v
third_party/HardFloat/source/mulRecFN.v
third_party/HardFloat/source/RISCV/HardFloat_specialize.v

// calculator
rtl/alu/alu_add.sv
rtl/alu/alu.sv
rtl/num_register.sv
rtl/sanitize_buttons.sv
rtl/controller.sv
rtl/screen_driver.sv
rtl/calculator.sv
