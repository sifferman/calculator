
RTL := rtl/calc_pkg.sv rtl/alu/alu.sv rtl/num_register.sv rtl/sanitize_buttons.sv rtl/controller.sv rtl/calculator.sv rtl/alu/alu_add.sv rtl/rtl.f
# TOP := controller_tb
TOP := alu_add_tb

.PHONY: gls sim lint clean

all: clean sim gls

lint:
	verilator -f rtl/rtl.f --lint-only --top calculator

sim:
	verilator --Mdir $@_dir -f dv/dv.f -f rtl/rtl.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

gls: synth/build.v
	verilator --Mdir $@_dir -f dv/dv.f -f synth/gls.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

synth/build.v: ${RTL} synth/yosys.tcl
	rm -rf slpp_all
	yosys -c synth/yosys.tcl -l synth/yosys.log

clean:
	rm -rf \
	 synth/build.v slpp_all synth/yosys.log abc.history \
	 obj_dir gls_dir sim_dir dump.fst
