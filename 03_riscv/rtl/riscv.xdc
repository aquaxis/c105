
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports RST_N]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports CLK]

set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]

set_property -dict {PACKAGE_PIN AA1 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]

create_clock -period 20.000 -name CLK -waveform {0.000 10.000} -add [get_ports CLK]
