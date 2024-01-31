#!/bin/bash

# posit_sqrt
## Simulation with questasim
export PATH="$PATH:/homelocal/raul_local/intelFPGA_lite/20.1/modelsim_ase/bin"

vsim -c -do 'vdel -all -lib work; vlib work; vcom -2008 ../src/input.vhdl ../src/output.vhdl ../src/sqrt_core.vhdl ../src/fp_sqrt.vhd test.vhd; vsim TestBench_FPSqrt; add wave -r *; run -all'



vsim -c -do 'vdel -all -lib work; vlib work; vcom -2008 ../src/input.vhdl ../src/output.vhdl ../src/sqrt_nr.vhd ../src/fp_sqrt.vhd test.vhd; vsim TestBench_FPSqrt; add wave -r *; run -all'


vcom -2008 ../src/input.vhdl ../src/output.vhdl 
vcom -2008 ../src/sqrt_nr.vhd
vcom -2008 ../src/fp_sqrt.vhd
vcom -2008 test.vhd