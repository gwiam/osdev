;
; A simple boot sector which can print a string to screen for legacy BIOS x86
;
[org 0x7c00]	; memory shortcut: since BIOS always puts boot sector
				; at mem addr 0x7c00, tell program that it should count
				; mem offset always from 0x7c00. This avoids manually
				; calculating memory addresses 0x7c00 + offset
mov ah, 0x0e 	; interrupt 0x10 switches on the number in the ah register
			 	; 0x0e indicates teletype
				; start to print each character by moving value into al register
				; and then triggering int 0x10

jmp $			; endless loop: jump to current address

my_str:
	db 'My boot sector string', 0

;
; section indicating bootable sector
;

times 510-($-$$) db 0	; pad the entire rest of the sector with 0 until
						; the 510st byte

dw 0xaa55			; magic number 0xaa55 starting at 511st byte to indicate
					; the first sector block on disk is indeed a bootable section
					; caution: little-endianness on x86 ensures that
					; byte 510 is 0x55 and byte 511 is 0xaa
