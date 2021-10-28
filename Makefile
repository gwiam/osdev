#Makefile for building a basic bootable kernel

all: os-image

#Build bootsector to load kernel

./bin/bootsec_kernel.o:
	nasm ./src/boot/bootsec_kernel.asm -f elf32 -o ./bin/bootsec_kernel.o -i ./src/boot/

./bin/bootsec_kernel.bin: ./bin/bootsec_kernel.o
	i386-elf-ld -o ./bin/bootsec_kernel.bin -Ttext=0x7c00 ./bin/bootsec_kernel.o --oformat binary

# Build kernel
# fno-pie option might be necesssary to not generate position-independent-executables
# by default.
# -m32 for 32bit
./bin/kernel.o:
	i386-elf-gcc -ffreestanding -fno-pie -c ./src/kernel/kernel.c -o ./bin/kernel.o

# compiling on x86-64 systems requires the -m elf_i386 option to compile
# into a compatible 32bit format
./bin/kernel.bin: ./bin/kernel.o
	i386-elf-ld -o ./bin/kernel.bin -Ttext=0x1000 ./bin/kernel.o --oformat binary

os-image: ./bin/bootsec_kernel.bin ./bin/kernel.bin
	cat ./bin/bootsec_kernel.bin ./bin/kernel.bin > ./bin/os-image

clean:
	rm -f ./bin/kernel.o ./bin/bootsec_kernel.bin ./bin/os-image ./bin/bsec_kernel.bin ./bin/bootsec_kernel.o
