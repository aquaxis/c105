clean:
	make clean -C 01_adder/build
	make clean -C 01_adder/sim
	make clean -C 01_adder/verilator
	make clean -C 02_beacon/build
	make clean -C 02_beacon/sim
	make clean -C 03_riscv/build
	make clean -C 03_riscv/software
	make clean -C 03_riscv/sim 
