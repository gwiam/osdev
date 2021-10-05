;
; Simple boot sector program reading from disk
;

mov ah, 0x02		; BIOS read sector mode

					; prepare registers for interrupt 0x13

; disk reading requires specifying C(ylinder)H(ead)S(ector)
mov dl, 0			; read from drive 0
mov ch, 0			; select cylinder 0
mov dh, 1			; select 2nd side of floppy disk
mov cl, 4			; select 4th sector on the track
mov al, 5			; trying to read 5 sectors from the 4th sector beginning

; set address that the sectors should be read into
; int 0x13 expects this address to be at ES with BX offset, so 16*ES + BX
; will be the final address

mov bx, 0xa000		; set es via bx, 0xa000 is a random address outside of code section
mov es, bx
mov bx, 0x1234		; set bx offset

int 0x13			; trigger interrupt 0x13

; now we need some error routines for reading:
; what if we read a faulty sector?
; what if we read outside of sector?
; what if there is no disk etc

jc disk_error		; jump to label if carry flag is set
					; why? the carry flag indicates a general fault during int 0x13
					; if it is set, then there was an error, if not then not

cmp al, 5			; al register contains no. of actual read sectors
					; check if it is what we wanted it to be
jne disk_error		; if read sector != what we want, then error occured somewhere
jmp endl_loop		; otherwise jump over the error section and continue

disk_error:
	mov bx, error_msg	; print out error message
	call print_string

%include "../chapter2/print_string.asm"
endl_loop:
	jmp endl_loop	; define endless loop for the boot sector to not
					; screw up after recognizing bootable section

error_msg:
	db 'Disk reading error.',0

times 510-($-$$) db 0	; pad the entire rest of the sector with 0 until
						; the 510st byte

dw 0xaa55			; magic number 0xaa55 starting at 511st byte to indicate
					; the first sector block on disk is indeed a bootable section
					; caution: little-endianness on x86 ensures that
					; byte 510 is 0x55 and byte 511 is 0xaa
