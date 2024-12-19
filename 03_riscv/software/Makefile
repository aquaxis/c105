RISCV=riscv32i
CC = riscv32-unknown-elf-gcc
LD = riscv32-unknown-elf-ld
CFLAGS = -I../common -march=rv32i_zicsr -mabi=ilp32 -g
LDFLAGS = -L/opt/$(RISCV)/riscv32-unknown-elf/lib -Tlink.ld -static
LIBS = -lc
OBJS = main.o start.o
PROGRAM = sample
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump

export PATH := $(PATH):/opt/$(RISCV)/bin/

all: $(PROGRAM)

$(PROGRAM): $(OBJS)
	$(LD) $(OBJS) $(LIBS) $(LDFLAGS) -o $(PROGRAM)

start.o: start.S
	$(CC) $(CFLAGS) -c -o start.o start.S

main.o: main.c
	$(CC) $(CFLAGS) -c -o main.o main.c

binary:
	$(OBJCOPY) -O binary $(PROGRAM) $(PROGRAM).bin
	$(OBJDUMP) -s -S $(PROGRAM) > $(PROGRAM).dump
	$(OBJCOPY) -O binary --only-section=.rodata* $(PROGRAM) $(PROGRAM)_dmem.bin
	$(OBJCOPY) -O binary --only-section=.text* $(PROGRAM) $(PROGRAM)_imem.bin
	hexdump -v -e '1/4 "%08x" "\n"' $(PROGRAM)_imem.bin > $(PROGRAM)_imem.hex
	hexdump -v -e '1/4 "%08x" "\n"' $(PROGRAM)_dmem.bin > $(PROGRAM)_dmem.hex

clean:
	rm -rf *.o *.bin *.dump *.hex $(PROGRAM)
