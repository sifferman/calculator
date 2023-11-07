
RTL := $(shell cat rtl/rtl.f)
# TOP := calculator_tb
# TOP := screen_driver_tb
TOP := alu_add_tb

.PHONY: lint sim synth gls nexys_4_ddr_gls clean

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

synth/build/nexys_4_ddr.edif synth/build/nexys_4_ddr.v: ${RTL} synth/nexys_4_ddr/nexys_4_ddr.sv synth/nexys_4_ddr/yosys.tcl
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -c synth/nexys_4_ddr/yosys.tcl -l synth/build/nexys_4_ddr.log

nexys_4_ddr_gls: synth/build/nexys_4_ddr.v
	verilator --Mdir $@_dir -f synth/nexys_4_ddr/nexys_4_ddr.f -f dv/dv.f --binary --top nexys_4_ddr_tb
	./$@_dir/Vnexys_4_ddr_tb +verilator+rand+reset+2

nexys_4_ddr: synth/build/nexys_4_ddr.edif
	rm -rf synth/build/nexys_4_ddr
	vivado -nolog -nojournal -mode tcl -source synth/nexys_4_ddr/vivado.tcl

clean:
	rm -rf \
	 synth/build slpp_all abc.history \
	 obj_dir gls_dir sim_dir dump.fst
