;
; A simple boot sector which can print stuff to screen for legacy BIOS x86
;

mov ah, 0x0e 	; interrupt 0x10 switches on the number in the ah register
			 	; 0x0e indicates teletype
				; start to print each character by moving value into al register
				; and then triggering int 0x10
mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
mov al, 'l'
int 0x10
mov al, 'o'
int 0x10

jmp $			; endless loop: jump to current address

;
; section indicating bootable sector
;

times 510-($-$$) db 0	; pad the entire rest of the sector with 0 until
						; the 510st byte

dw 0xaa55			; magic number 0xaa55 starting at 511st byte to indicate
					; the first sector block on disk is indeed a bootable section
					; caution: little-endianness on x86 ensures that
					; byte 510 is 0x55 and byte 511 is 0xaa
