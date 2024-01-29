#!/bin/bash

# posit_sqrt
## Simulation with questasim
export PATH="$PATH:/homelocal/raul_local/intelFPGA_lite/20.1/modelsim_ase/bin"

vsim -c -do 'vdel -all -lib work; vlib work; vcom -2008 ../src/input.vhdl ../src/output.vhdl ../src/sqrt_core.vhdl ../src/fp_sqrt.vhdl test.vhd; vsim TestBench_FPSqrt; add wave -r *; run -all'