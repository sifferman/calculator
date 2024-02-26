
RTL := $(shell python3 misc/convert_filelist.py Makefile rtl/rtl.f)
# TOP := calculator_tb
# TOP := screen_driver_tb
TOP := alu_add_tb

YOSYS_DATDIR := $(shell yosys-config --datdir)

.PHONY: lint sim synth gls nexys_4_ddr_gls clean

all: clean sim gls

lint:
	verilator -f rtl/rtl.f --lint-only --top calculator

sim:
	verilator --Mdir $@_dir -f rtl/rtl.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

gls: synth/build/synth.v
	verilator -I${YOSYS_DATDIR} --Mdir $@_dir -f synth/gls.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

synth/build/rtl.sv2v.v: ${RTL}
	mkdir -p synth/build
	sv2v $^ -w $@

synth synth/build/synth.json synth/build/synth.v: synth/build/rtl.sv2v.v synth/yosys.tcl
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -p 'tcl synth/yosys.tcl synth/build/rtl.sv2v.v' -l synth/build/yosys.log

synth/build/nexys_4_ddr.sv2v.v: ${RTL} synth/nexys_4_ddr/nexys_4_ddr.sv
	mkdir -p synth/build
	sv2v $^ -w $@

synth/build/nexys_4_ddr.v: synth/build/nexys_4_ddr.sv2v.v synth/nexys_4_ddr/yosys.tcl
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -c synth/nexys_4_ddr/yosys.tcl -l synth/build/nexys_4_ddr.log

nexys_4_ddr_gls: synth/build/nexys_4_ddr.v synth/nexys_4_ddr/nexys_4_ddr.f dv/dv.f
	verilator -I${YOSYS_DATDIR} --Mdir $@_dir -f synth/nexys_4_ddr/nexys_4_ddr.f -f dv/dv.f --binary --top nexys_4_ddr_tb
	./$@_dir/Vnexys_4_ddr_tb +verilator+rand+reset+2

nexys_4_ddr synth/build/nexys_4_ddr/nexys_4_ddr.runs/impl_1/nexys_4_ddr.bit: synth/build/nexys_4_ddr.v synth/nexys_4_ddr/vivado.tcl synth/nexys_4_ddr/nexys_4_ddr.xdc synth/nexys_4_ddr/constraints.xdc
	rm -rf synth/build/nexys_4_ddr
	vivado -nolog -nojournal -mode tcl -source synth/nexys_4_ddr/vivado.tcl

clean:
	rm -rf \
	 synth/build slpp_all abc.history \
	 obj_dir gls_dir sim_dir nexys_4_ddr_gls_dir dump.fst \
	 .Xil *.jou
