
# Pocket Calculator Chip-on-Board

> [!Warning]
> This project is a work-in-progress. Some features may be incomplete or missing.

## About

This project serves as a recreation of the chip-on-board found in most basic 8-digit calculators. The goal is to become highly accurate to the function and architecture of real calculators.

This project is fully simulatable and synthesizable with open-source tools.

## Required Tools

<!-- Install all required open-source tools in one commmand:

```bash
curl -sSL https://raw.githubusercontent.com/sifferman/hdl-tool-installer/main/install | bash -s -- <build_dir> --oss-cad-suite --synlig
``` -->

Check [`".github/workflows/test.yml"`](https://github.com/sifferman/calculator/blob/main/.github/workflows/test.yml) to see all required tools.

> [!WARNING]
>
> * Verilator's latest binary on OSS CAD Suite is broken ([YosysHQ/oss-cad-suite-build#84](https://github.com/YosysHQ/oss-cad-suite-build/issues/84)). The last known-good version is [YosysHQ/oss-cad-suite-build@2023-10-20](https://github.com/YosysHQ/oss-cad-suite-build/releases/tag/2023-10-20).
> * Synlig's latest release is broken ([chipsalliance/synlig#2166](https://github.com/chipsalliance/synlig/pull/2166)). The last known-good version is [chipsalliance/synlig@2023-10-24-dd28e6d](https://github.com/chipsalliance/synlig/releases/tag/2023-10-24-dd28e6d).

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
