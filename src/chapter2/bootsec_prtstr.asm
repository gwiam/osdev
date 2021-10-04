;
; A simple boot sector which can print a string to screen for legacy BIOS x86
;
[org 0x7c00]	; memory shortcut: since BIOS always puts boot sector
				; at mem addr 0x7c00, tell program that it should count
				; mem offset always from 0x7c00. This avoids manually
				; calculating memory addresses 0x7c00 + offset

; print two strings

mov bx, hello_str
call print_string
mov bx, goodbye_str
call print_string

jmp $			; endless loop: jump to current address

%include "print_string.asm"

hello_str:
	db 'Hello William :)', 0xA,0xD,0 ; 0xA 0xD are LF and CR in ASCII for new line
goodbye_str:
	db 'Goodbye!', 0

;
; section indicating bootable sector
;

times 510-($-$$) db 0	; pad the entire rest of the sector with 0 until
						; the 510st byte

dw 0xaa55			; magic number 0xaa55 starting at 511st byte to indicate
					; the first sector block on disk is indeed a bootable section
					; caution: little-endianness on x86 ensures that
					; byte 510 is 0x55 and byte 511 is 0xaa
