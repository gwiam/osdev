;
; Exercising conditional jumps and stack movements in legacy BIOS boot sector
;

[org 0x7c00] 		; mem shortcut to set memory base to 0x7c00 and count
					; any offset from there

mov bp, 0x8000		; set base stack pointer to a little above where BIOS puts
					; this code
mov sp, bp			; set sp to bp == empty stack

push 'S'			; remember: in real-mode, pushing to stack is always
					; 16bit/2bytes, so msb will be 0x00 in this case

mov bx, 30			; number 30 in bx
cmp bx, 4			; execute comparison op on bx value

jle smaller_four	; jump to smaller_four if <=4
cmp bx, 30		; compare if bx < 40
jl smaller_fourty	; jump to smaller_fourty if <40
mov al, 'C'			; execute this if the first two jumps did not happen
push ax

jmp end_of_if		; IMPORTANT: jump to end label, otherwise
					; we would execute everything below

smaller_four:
	mov al, 'A'
	push ax			; we just want to push al but we cannot since
					; only 16bits can be pushed and al is only 8bits
					; we need to push ax

smaller_fourty:
	mov al, 'B'
	push ax

end_of_if:

; print out stuff
mov ah, 0x0e		; indicates teletype for interrupt 0x10
int 0x10

pop bx				; pop the next stack value to bx
mov al, bl			; copy lower bits to al register (due to msb being 0x00
					; on the stack and the lower bits being the actual char)
int 0x10			; print char in al

					; two 'AA' on screen for smaller_four
					; two 'BB' on screen for smaller_fourty
mov al, [0x7ffe]		; just to demonstrate that stack grows in negative direction
					; from 0x8000: we show what is at 0x8000 - 0x2 address
					; which should be the first pushed char 'S'
int 0x10

endl_loop:
	jmp endl_loop	; define endless loop for the boot sector to not
					; screw up after recognizing bootable section
;
; boot sector marker
;

times 510-($-$$) db 0	; pad the entire rest of the sector with 0 until
						; the 510st byte

dw 0xaa55			; magic number 0xaa55 starting at 511st byte to indicate
					; the first sector block on disk is indeed a bootable section
					; caution: little-endianness on x86 ensures that
					; byte 510 is 0x55 and byte 511 is 0xaa
