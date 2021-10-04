;
; The simplest possible boot sector for x86 legacy BIOS
;

endl_loop:
	jmp endl_loop	; define endless loop for the boot sector to not
					; screw up after recognizing bootable section

times 510-($-$$) db 0	; pad the entire rest of the sector with 0 until
						; the 510st byte

dw 0xaa55			; magic number 0xaa55 starting at 511st byte to indicate
					; the first sector block on disk is indeed a bootable section
					; caution: little-endianness on x86 ensures that
					; byte 510 is 0x55 and byte 511 is 0xaa
