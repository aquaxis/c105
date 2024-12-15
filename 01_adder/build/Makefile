SHELL=/bin/bash
SOURCE_VIVADO?=/tools/Xilinx/Vivado/2024.2/settings64.sh

all:
	make synthesis
	make par
	make bitstream

synthesis:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/synthesis.tcl

par:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/par.tcl

bitstream:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/bitstream.tcl

bitwrite:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/bitwrite.tcl

flashwrite:
	source $(SOURCE_VIVADO); vivado -mode batch -source ../script/flashwrite.tcl

clean:
	rm -rf .Xil *.jou *.log *.bin *.bit *.dcp clockInfo.txt adder
