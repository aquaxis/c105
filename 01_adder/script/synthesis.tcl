set project_name "adder"

# Create Project
create_project ${project_name} ./${project_name} -part xc7a35tfgg484-2 -force

# Read RTL
read_verilog -sv ../rtl/${project_name}.sv

# Synthesis
synth_design -name ${project_name} -top ${project_name} -part xc7a35tfgg484-2

# Save 
write_checkpoint -force ${project_name}_synth.dcp

close_project
