# Before creating a simple kernel

Read up on GCC cross-compilation. If the targeted platform is not the same as the platform the kernel was compiled on, it will lead to problems.

In this case host platform was Linux x86_64 but target platform was x86

## What to do?

Necessary to recompile GCC and ld tools to compile on x86_64 but targeting x86
* 1. download source codes from GNU project websites
* 2. configure environment to not get native gcc compiler and cross-compiled gcc, ld confused
* 3. install into new environment
* 4. Compile and link all kernel source code with new gcc

## In this repo

target platform: i386-elf
gcc 9.4.0
binutils 2.37
