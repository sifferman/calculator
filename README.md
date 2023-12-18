
# Pocket Calculator Chip-on-Board

> [!Warning]
> This project is a work-in-progress. Some features may be incomplete or missing.

## About

This project serves as a recreation of the chip-on-board found in most basic 8-digit calculators. The goal is to become highly accurate to the function and architecture of real calculators.

This project is fully simulatable and synthesizable with open-source tools.

## Required Tools

```bash
wget -O - https://raw.githubusercontent.com/sifferman/hdl-tool-installer/main/install | bash -s -- <build_dir> --oss-cad-suite --zachjs-sv2v
```

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

## References

* [T6M14S Datasheet](https://datasheetspdf.com/pdf-file/610519/ToshibaSemiconductor/T6M14S/1)
