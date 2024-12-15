set project_name "adder"

# Open Project
open_checkpoint ${project_name}_route.dcp

write_bitstream -force ${project_name}.bit
write_cfgmem -force -format BIN -interface SPIx4 -disablebitswap -loadbit "up 0x0 ${project_name}.bit" ${project_name}.bin

close_project
