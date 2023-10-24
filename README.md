
# Pocket Calculator Recreation

> **Warning**
> This project is a work-in-progress. Not everything is accurate to the function or architecture of real calculators. :warning:

## About

This project serves as a recreation of the chip-on-board found in most basic 8-digit calculators.

## Usage

```bash
verilator -f calculator.f --lint-only --top calculator
verilator -f calculator.f --binary --top controller_tb && ./obj_dir/Vcontroller_tb +verilator+rand+reset+2
rm -rf slpp_all ; yosys -c synlig.tcl
```

## References

This hardware is similar to the T6M14S chip.
