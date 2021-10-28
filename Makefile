#Makefile for building a basic bootable kernel

all: os-image

# symbol $< is first dependency file in the list
# symbol $@ is the target file
# symbol $^ is substituted with all dependency files in the list

# Build boot sector
./bin/bootsec_kernel.o:
	nasm ./src/boot/bootsec_kernel.asm -f elf32 -o ./bin/bootsec_kernel.o -i ./src/boot/

# Link boot sector ELF to get the correct starting address 0x7c00
./bin/bootsec_kernel.bin: ./bin/bootsec_kernel.o
	i386-elf-ld -o ./bin/bootsec_kernel.bin -Ttext=0x7c00 ./bin/bootsec_kernel.o --oformat binary

# Build short kernel entry function looking for main
./bin/kernel_entry.o:
	nasm ./src/boot/kernel_entry.asm -f elf32 -o $@

# Build actual kernel file
# fno-pie option might be necesssary to not generate position-independent-executables
# by default.
# -m32 for 32bit
./bin/kernel.o:
	i386-elf-gcc -ffreestanding -c ./src/kernel/kernel.c -o ./bin/kernel.o

# Link kernel and kernel entry into one coherent bin file
# here order of the dependency files is important!
# ld respects ordering so kernel_entry code MUST be before actual kernel
# in order to attach it to the beginning section
./bin/kernel.bin: ./bin/kernel_entry.o ./bin/kernel.o
	i386-elf-ld -o ./bin/kernel.bin -Ttext=0x1000 $^ --oformat binary

# Concatenate kernel behind the boot sector
os-image: ./bin/bootsec_kernel.bin ./bin/kernel.bin
	cat ./bin/bootsec_kernel.bin ./bin/kernel.bin > ./bin/os-image

# cleaning operation
clean:
	rm -f ./bin/kernel.o ./bin/bootsec_kernel.bin ./bin/os-image ./bin/bsec_kernel.bin ./bin/bootsec_kernel.o ./bin/kernel_entry.o
