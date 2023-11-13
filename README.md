
# Pocket Calculator Chip-on-Board

> **Warning**
> This project is a work-in-progress. Some features may be incomplete or missing.

## About

This project serves as a recreation of the chip-on-board found in most basic 8-digit calculators. The goal is to become highly accurate to the function and architecture of real calculators.

This project is fully simulatable and synthesizable with open-source tools.

## Required Tools

Install all required open-source tools in one commmand:

```bash
curl -sSL https://raw.githubusercontent.com/sifferman/hdl-tool-installer/main/install | bash -s -- <build_dir> --oss-cad-suite --synlig
```

> :warning: Verilator's binary on OSS CAD Suite is broken as of Nov 3rd, 2023: [verilator/verilator#4621](https://github.com/verilator/verilator/issues/4621), [YosysHQ/oss-cad-suite-build#84](https://github.com/YosysHQ/oss-cad-suite-build/issues/84). The last known-good version is [2023-10-20](https://github.com/YosysHQ/oss-cad-suite-build/releases/tag/2023-10-20).

*Note: Vivado is required for Artix-7 FPGA PNR and bitstream generation: <https://www.xilinx.com/support/download.html>.*

## Usage

You can either run behavioral simulation or gate-level-simulation.

```bash
# Initialize submodules
git submodule update --init --recursive

# Lint files in rtl/rtl.f
make lint

# Run specific test
# sim - Simulate the SystemVerilog
# gls - Simulate the synthesized netlist
make sim TOP=calculator_tb
make gls TOP=calculator_tb

make sim TOP=controller_tb
make gls TOP=controller_tb

make sim TOP=alu_add_tb
make gls TOP=alu_add_tb

make sim TOP=screen_driver_tb
make gls TOP=screen_driver_tb

# Simulate nexys_4_ddr top module
make nexys_4_ddr_gls
# Generate a bitstream for the nexys_4_ddr
make nexys_4_ddr
```

## HardFloat

[HardFloat Documentation](http://www.jhauser.us/arithmetic/HardFloat-1/doc/HardFloat-Verilog.html).

* Conversions from Integer: [iNToRecFN](https://github.com/bsg-external/HardFloat/blob/master/source/iNToRecFN.v)
* Conversions to Integer: [recFNToIN](https://github.com/bsg-external/HardFloat/blob/master/source/recFNToIN.v)
* Addition and Subtraction: [addRecFN](https://github.com/bsg-external/HardFloat/blob/master/source/addRecFN.v)
* Multiplication: [mulRecFN](https://github.com/bsg-external/HardFloat/blob/master/source/mulRecFN.v)
* Division and Square Root: [divSqrtRecFN_small](https://github.com/bsg-external/HardFloat/blob/master/source/divSqrtRecFN_small.v)

## References

* [T6M14S Datasheet](https://datasheetspdf.com/pdf-file/610519/ToshibaSemiconductor/T6M14S/1)
