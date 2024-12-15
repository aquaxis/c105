SHELL=/bin/bash
SOURCE_VIVADO?=/tools/Xilinx/Vivado/2024.2/settings64.sh

all:
	make compile

compile:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/compile.tcl

bitwrite:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/bitwrite.tcl

flashwrite:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/flashwrite.tcl

clean:
	rm -rf .Xil *.jou *.log *.bin *.bit *.dcp clockInfo.txt adder
