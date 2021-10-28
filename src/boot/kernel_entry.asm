;
; Short entry code in asm to ensure kernel main function is always found
; and executed on the correct address even if main() is not first function
; after kernel offset jump in the bootsector code
;

[bits 32]
[extern main]

call main

jmp $
