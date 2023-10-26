
RTL := rtl/calc_pkg.sv rtl/alu.sv rtl/num_register.sv rtl/sanitize_buttons.sv rtl/controller.sv rtl/calculator.sv rtl/rtl.f

.PHONY: gls sim lint clean

all: clean sim gls

lint:
	verilator -f rtl/rtl.f --lint-only --top calculator

sim:
	verilator --Mdir $@_dir -f dv/dv.f -f rtl/rtl.f --binary --top controller_tb
	./$@_dir/Vcontroller_tb +verilator+rand+reset+2

gls: synth/build.v
	verilator --Mdir $@_dir -f dv/dv.f -f synth/gls.f --binary --top controller_tb
	./$@_dir/Vcontroller_tb +verilator+rand+reset+2

synth/build.v: ${RTL}
	rm -rf slpp_all ; yosys -c synth/yosys.tcl -l synth/yosys.log

clean:
	rm -rf \
	 synth/build.v slpp_all synth/yosys.log abc.history \
	 obj_dir gls_dir sim_dir dump.fst
