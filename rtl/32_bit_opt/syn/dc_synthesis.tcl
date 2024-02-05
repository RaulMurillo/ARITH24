# Launch synthesis with Synopsys DC
# run as:
#   dc_shell -f dc_synthesis.tcl
#
# or in the dc_shell:
#   source dc_syntyesis.tcl

free -design

# Synopsys DC setup
set MYLIB /scratch/synLibs/tcbn28hpcplusbwp30p140_180a_FE/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt1v25c.db

set target_library $MYLIB
set link_library $MYLIB

read_db $MYLIB
define_design_lib WORK -path "./dc_work"

# Preserve the hierarchy information of the RTL objects in the RTL design
set power_preserve_rtl_hier_names true

# Set directory structure
set REPORT_DIR  ./rpt;      # synthesis reports: timing, area, etc.
set OUT_DIR ./db;           # output files: netlist, sdf sdc etc.
set SOURCE_DIR ../src;       # rtl code that should be synthesised
set SYN_DIR ./syn;          # synthesis directory, synthesis scripts constraints etc.

# Design specific variables
set TOP_NAME PositSqrt

# Read a HDL file, check for proper syntax and synthesizable logic, and store the design in an intermediate format.
# Analyze the files in order: 1- Packages, 2- All HDL modules except top module, 3- Top level module.
analyze -format vhdl -lib WORK "${SOURCE_DIR}/sqrt_nr.vhd"
analyze -format vhdl -lib WORK "${SOURCE_DIR}/flopoco.vhdl"

# Create a design from the intermediate format produced by analyze.
elaborate ${TOP_NAME} -library WORK

#rtl2saif -output "${TOP_NAME}.RT.saif" -design "${TOP_NAME}"
# Make unique copies of replicated modules
uniquify

#set_max_delay 0.75 [all_outputs]
set_switching_activity -type inputs -toggle_rate 0.1
set_switching_activity -type registers -toggle_rate 0.1

##compile
#derive_timing_constraints

# Set the wire load mode to (top/enclosed/segmented)
set_wire_load_mode top

create_clock -name "clk" -period 1 -waveform {0 0.5} {clk}
#set_false_path -from [get_port rst]

set_host_options -max_cores 4 ; # only supported by compile_ultra
compile
# compile_ultra ; # supports the use of multiple cores for optimization

# Generate the reports
if {![file isdirectory $REPORT_DIR]} {
    # Directory doesn't exist, create it
    file mkdir $REPORT_DIR
}
set_host_options -max_cores 4
parallel_execute [list \
    "report_constraints > ${REPORT_DIR}/${TOP_NAME}_constraints.txt" \
    "report_area > ${REPORT_DIR}/${TOP_NAME}_area.txt" \
    "report_area -hierarchy > ${REPORT_DIR}/${TOP_NAME}_area_hier.txt" \
    "report_cell > ${REPORT_DIR}/${TOP_NAME}_cells.txt" \
    "report_timing > ${REPORT_DIR}/${TOP_NAME}_timing.txt" \
    ]
#report_timing -to Z[31] > ${REPORT_DIR}/${TOP_NAME}_timing_cp.txt
report_power > ${REPORT_DIR}/${TOP_NAME}_power.txt
report_power -hierarchy > ${REPORT_DIR}/${TOP_NAME}_power_hier.txt

# Export netlist
if {![file isdirectory $OUT_DIR]} {
    # Directory doesn't exist, create it
    file mkdir $OUT_DIR
}
write -hierarchy -format ddc -output ${OUT_DIR}/${TOP_NAME}.ddc
write -hierarchy -format verilog -output ${OUT_DIR}/${TOP_NAME}.v

exit