VIVADO_DIR := /tools/Xilinx/Vivado/2024.2
XVLOG := $(VIVADO_DIR)/bin/xvlog
XELAB := $(VIVADO_DIR)/bin/xelab
XSIM  := $(VIVADO_DIR)/bin/xsim

SRC_DIR   := ../rtl
SRC_FILES := $(shell ls $(SRC_DIR)/*.sv)

TOP := tb_riscv

gui: sim
	$(XSIM) $(TOP) -gui

dump: sim ./dump.tcl
	$(XSIM) $(TOP) -t ./dump.tcl -wdb dump.wdb

wave: dump.wdb
	$(XSIM) dump.wdb -gui

sim: $(SRC_FILES)
	$(XVLOG) -sv $(SRC_FILES) \
	-d FILE_IMEM="\"../software/sample_imem.hex\"" \
	-d FILE_DMEM="\"../software/sample_dmem.hex\""
	$(XELAB) $(TOP) --debug all

clean:
	rm -rf *.log *.jou *.pb xsim.dir *.sh *.wdb .Xil dump.tcl

./dump.tcl:
	echo 'log_wave -r *'  > $@
	echo 'run 10ms'       >> $@
	echo 'quit'          >> $@
