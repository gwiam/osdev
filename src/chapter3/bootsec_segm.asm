;
; A simple boot sector program to understand mem segmentation
; 

; The problem with direct addressing storage is that within
; 16-bit real-mode, direct addresses can only be 16-bits long,
; meaning that you can max. address 64kB of memory, which is too small

; segmentation by saying real address= segment * 16 + our specified offset from segment
; offers us a little over 1MB of addressable mem space

mov ah, 0x0e			; teletype BIOS mode
mov al, [the_char]
int 0x10			; try to print X, won't work because
					; without the [org 0x7c00] statement, it now thinks we start
					; addressing from 0x0000

mov bx, 0x7c0		; manually setting the ds register (data segment register)
					; to 0x7c00 is now setting the segment base address
					; effect == [org 0x7c00]
					; you cannot set ds directly, hardware limit
					; BE WARE: 0x7c0 and 0x7c00 are confusing at first:
					; 0x7c00 (segment 0, offset 0x7c00) resolves
					; to the same address as (segment 0x7c0, offset 0)
					; meaning real address is: 0x00007c00
					; [org 0x7c00] means segment 0, offset 0x7c00
					; while here you say 16 * 0x7c0 + offset 0 (implied because
					; you did not write any addition op in the brackets)

mov ds, bx			; copy bx to ds
mov al, [the_char]	; copy from address the_char + 16 * 0x7c0
int 0x10

mov al, [es:the_char]	; setting the general purpose es segment register
						; to the_char address and then load value at that
						; address into al
int 0x10

mov bx, 0x7c0
mov es, bx
mov al, [es:the_char]	; doing the same to the es register as to the ds
						; register produces same effect
int 0x10

jmp $					; endless loop

the_char:
	db 'X'

; Padding and magic number for boot sect

times 510-($-$$) db 0
dw 0xaa55
