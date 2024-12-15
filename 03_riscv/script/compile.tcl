set project_name "riscv"

# Create Project
create_project ${project_name} ./${project_name} -part xc7a35tfgg484-2 -force

# Read RTL
read_verilog -sv ../rtl/riscv.v
read_verilog -sv ../rtl/gpio.v
read_verilog -sv ../rtl/lct.v
read_verilog -sv ../rtl/memory.v
read_verilog -sv ../rtl/rv32i.v
read_verilog -sv ../rtl/rv32i_alu.v
read_verilog -sv ../rtl/rv32i_csr.v
read_verilog -sv ../rtl/rv32i_decode.v
read_verilog -sv ../rtl/rv32i_reg.v

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
write_cfgmem -force -format BIN -interface SPIx1 -disablebitswap -loadbit "up 0x0 ${project_name}.bit" ${project_name}.bin

close_project
