set project_name "riscv"

# Create Project
create_project ${project_name} ./${project_name} -part xc7a35tfgg484-2 -force

# Read RTL
read_verilog -sv ../rtl/riscv.sv
read_verilog -sv ../rtl/gpio.sv
read_verilog -sv ../rtl/lct.sv
read_verilog -sv ../rtl/memory.sv
read_verilog -sv ../rtl/rv32i.sv
read_verilog -sv ../rtl/rv32i_alu.sv
read_verilog -sv ../rtl/rv32i_csr.sv
read_verilog -sv ../rtl/rv32i_decode.sv
read_verilog -sv ../rtl/rv32i_reg.sv

set_property verilog_define { \
  FILE_IMEM=\"../software/sample_imem.hex\" \
  FILE_DMEM=\"../software/sample_dmem.hex\" \
} [current_fileset]

# Synthesis
synth_design -name ${project_name} -top ${project_name} -part xc7a35tfgg484-2

# Read XDC
read_xdc ../rtl/${project_name}.xdc

# Place & Route
opt_design
place_design
route_design

# Report Timing Summary
report_timing_summary -file ${project_name}_timing.rpt

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force ${project_name}.bit
write_cfgmem -force -format BIN -interface SPIx4 -disablebitswap -loadbit "up 0x0 ${project_name}.bit" ${project_name}.bin

close_project
