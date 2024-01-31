#!/bin/bash

# posit_sqrt
## Simulation with questasim
export PATH="$PATH:/homelocal/raul_local/intelFPGA_lite/20.1/modelsim_ase/bin"

# vsim -c -do 'vdel -all -lib work; vlib work; vcom -2008 ../src/sqrt_nr.vhd ../src/flopoco.vhdl test.vhd; vsim TestBench_PositSqrt; add wave -r *; run -all'

# Faster simulation
vsim -batch -nostdout -logfile trascript.log -msgfile error.log -nosyncio -noappendclose -do 'vdel -all -lib work; vlib work; vcom -quiet -2008 ../src/sqrt_nr.vhd ../src/flopoco.vhdl test.vhd; vsim -quiet -t 1ns TestBench_PositSqrt; set StdArithNoWarnings 1; set NumericStdNoWarnings 1; run -all'
