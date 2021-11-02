# Learning OS development

This repo is just a personal stash of things that I've learned trying to understand how modern day operating systems are programmed and work. It might not be 100% structured logically but take it as my learning process around it all.
Feel free to poke around.

## Structure
### PART I
* Chapter 1 was my first try at creating a basically empty boot sector for legacy x86 BIOS [check]
* Chapter 2 further familiarization of assembler language (x86): stack, conditional jumps, interrupt output, functions etc. [check]
* Chapter 3 memory access, segmentation etc [check]
* Chapter 4 32-bit protected mode [check]
* Chapter 5 C-assembly translation and study [check]
* Chapter 6 trying to create a simple kernel
  * learning GCC cross compilation [check]
  * simple kernel routine displaying an 'X' [check]
  * simple C library functions [memcpy, strcat, int2str]
* Chapter 7 Programming my own low level device drivers
  * IO controller routines [check]
  * VGA text-mode printing + clear screen [check]
  * scrolling [check]
* Chapter 8 Interrupt handling in PM and Kernel

Tutorials stop here and things diverge. For me, following topics I wanna know about:
### PART II
No particular order from here on out.
* Long mode: How to get to 64-bit
  * Look at branch longmode
* Getting to know Rootkits
* UEFI: my first attempt to do anything with UEFI
* Loading kernel with UEFI
* Linux kernel: Trying to understand it with the knowledge I gained now 
## Sources
The following sources where used to do the various things in this repo

* [1] https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf
* [2] https://littleosbook.github.io/#the-bootloader
* [3] https://github.com/cfenollosa/os-tutorial
* [4] https://0xax.gitbooks.io/linux-insides/content/Booting/linux-bootstrap-1.html
* [5] The wiki.osdev.org websites
