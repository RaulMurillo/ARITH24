### Directory structure
Each `n_bit` directory contains three folders:
- `src/` contains the source RTL code. The top module, `flopoco.vhdl`, is generated with [FloPoCo](https://www.flopoco.org/). The square root computation is done within the `sqrt_nr.vhd` module.
- `syn/` contains the synthesis script and reports.
- `sim/` contains a testbench with a counter to get the number of cycles required for every posit square root computation. Input files are omitted since they can become too large.

The `n_bit_opt` folders contain optimized versions of the units presented in the paper.


### Misc
`PERCIVAL_n` directories contain similar `src/` and `syn/` folders regarding the units presented in [this paper](https://doi.org/10.1109/TC.2024.3377890).