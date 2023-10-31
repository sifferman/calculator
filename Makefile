
RTL := $(shell cat rtl/rtl.f)
# TOP := controller_tb
# TOP := screen_driver_tb
TOP := alu_add_tb

.PHONY: lint sim synth gls clean

all: clean sim gls

lint:
	verilator -f rtl/rtl.f --lint-only --top calculator

sim:
	verilator --Mdir $@_dir -f rtl/rtl.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

gls: synth/build/synth.v
	verilator --Mdir $@_dir -f synth/gls.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

synth synth/build/synth.json synth/build/synth.v: ${RTL} synth/yosys.tcl
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -p 'tcl synth/yosys.tcl ${RTL}' -l synth/build/yosys.log

clean:
	rm -rf \
	 synth/build slpp_all abc.history \
	 obj_dir gls_dir sim_dir dump.fst
