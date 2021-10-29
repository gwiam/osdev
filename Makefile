#Makefile for building a basic bootable kernel

all: os-image

# symbol $< is first dependency file in the list
# symbol $@ is the target file
# symbol $^ is substituted with all dependency files in the list

# To ensure that we don't have to manually type in all the files we want to compile
# we can automate this:
# Match all .c files in the kernel and driver folders
C_FILES = $(wildcard ./src/kernel/*.c ./src/drivers/*.c)
OBJ_FILES = $(addprefix ./bin/obj/, $(notdir $(patsubst %.c,%.o,$(C_FILES))))	# create list of filenames where you just replace every .c with .o
test:
	echo $(C_FILES)
	echo $(OBJ_FILES)
# Build boot sector
./bin/obj/bootsec_kernel.o:
	$(info Building the boot sector)
	nasm ./src/boot/bootsec_kernel.asm -f elf32 -o ./bin/obj/bootsec_kernel.o -i ./src/boot/

# Link boot sector ELF to get the correct starting address 0x7c00
./bin/bootsec_kernel.bin: ./bin/obj/bootsec_kernel.o
	$(info Linking boot sector to 0x7c00)
	i386-elf-ld -o $@ -Ttext=0x7c00 $^  --oformat binary

# Build short kernel entry function looking for main
./bin/obj/kernel_entry.o:
	nasm ./src/boot/kernel_entry.asm -f elf32 -o $@

# Build actual kernel file
# fno-pie option might be necesssary to not generate position-independent-executables
# by default.
./bin/obj/kernel.o:
	$(info Building kernel)
	i386-elf-gcc -ffreestanding -c ./src/kernel/kernel.c -o $@

# Generic rule to build all c files into o files
./bin/obj/%.o : %.c
	i386-elf-gcc -ffreestanding -c $< -o $@

# Link kernel and kernel entry into one coherent bin file
# here order of the dependency files is important!
# ld respects ordering so kernel_entry code MUST be before actual kernel
# in order to attach it to the beginning section
./bin/kernel.bin: ./bin/obj/kernel_entry.o $(OBJ_FILES) 
	$(info Linking all files to kernel binary)
	i386-elf-ld -o $@ -Ttext=0x1000 $^ --oformat binary

# Concatenate kernel behind the boot sector
os-image: ./bin/bootsec_kernel.bin ./bin/kernel.bin
	$(info Concat boot sector and kernel)
	cat ./bin/bootsec_kernel.bin ./bin/kernel.bin > ./bin/os-image

# cleaning operation
clean:
	$(info Cleaning compiled files)
	rm -f ./bin/bootsec_kernel.bin ./bin/os-image ./bin/bsec_kernel.bin ./bin/*.o ./bin/obj/*.o
