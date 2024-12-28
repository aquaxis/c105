VIVADO_DIR := /tools/Xilinx/Vivado/2024.2
XVLOG := $(VIVADO_DIR)/bin/xvlog
XELAB := $(VIVADO_DIR)/bin/xelab
XSIM  := $(VIVADO_DIR)/bin/xsim

SRC_DIR   := ../rtl
SRC_FILES := $(shell ls $(SRC_DIR)/*.sv)

all:
	verilator --cc --exe  --trace --trace-params --trace-structs --trace-underscore ../rtl/adder.sv -exe tb_adder.cpp
	make -C obj_dir -f Vadder.mk
	./obj_dir/Vadder
	gtkwave sim.vcd

compile:
	make -C obj_dir -f Vadder.mk

install:
	sudo apt install verilator -y
	sudo apt install gtkwave -y

clean:
	rm -rf obj_dir sim.vcd
