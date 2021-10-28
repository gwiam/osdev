;
; Function to read disk sections
;

read_disk:
	push dx			; dx: sectors that are requested to be read
					; save them in stack just in case the dx registry will be overwritten
	mov ah, 0x02	; indicate BIOS read sector mode
	mov al, dh		; copy how many sectors we should read into al regstry for interrupt
	mov ch, 0x00	; select cylinder 0
	mov dh, 0x00	; select head 0
	mov cl, 0x02	; start reading from the sector after the bootsector (2nd sector)
	
	int 0x13		; trigger interrupt for reading

	jc disk_error	; jump to error routine
	
	pop dx			; restore the no of sectors we wanted to read
	cmp dh, al		; check if al (sec read) == (sec expected)
					; please note: stack is always 16bit only
	jne disk_error	; if they did not match, jump to error routine
	ret				; otherwise return

disk_error:			; error routine
	mov bx, error_msg
	call print_string16	; just print out the error message

error_msg:
	db "Error during disk read operation!", 0
