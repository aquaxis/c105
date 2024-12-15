set project_name "adder"

# Open Project
open_checkpoint ${project_name}_synth.dcp

# Read XDC
read_xdc ../rtl/${project_name}.xdc

# Place & Route
opt_design
place_design
route_design

# Save Design
write_checkpoint -force ${project_name}_route.dcp

close_project
