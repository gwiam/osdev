;
; Include file which provides a routine for printing null-terminated strings
; directly into VGA video memory
; It will always print the string into the top-left corner!
;

; VGA color text mode has dim 80 rows x 25 cols
; this grid is directly mapped onto memory
; starting address is usually 0xb8000
; calculating display char -> memory cell: 0xb8000 + 2*(row*80+col)
; each character on screen is described by 2 bytes:
;	* 1 byte ASCII code
;	* 1 byte attribute: fore/background color, blinking
[bits 32]			; bits directive tells NASM what code it should generate specifically
					; [bits XX] WITH SPACE where XX is by default 16, can be 32 or 64
					; optional since we can also tell NASM in other ways to do it but
					; we have the option to explicity declare it here
; constants declaration
VIDEO_MEM equ 0xb8000			; declare VGA mem address start
WHITE_ON_BLACK_CHAR equ 0x0f	; declare color scheme for char attr

print_string_pm:
	; print string starting from video memory address edx

	pusha		; store all previous registers onto the stack
	mov edx, VIDEO_MEM		; set edx register to video mem start address

start_print_pm:		; start printing process by looping through string
	mov al, [ebx]	; copy char at address in ebx into al registry
	mov ah, WHITE_ON_BLACK_CHAR		; set attribute (white char on black background)
	cmp al, 0		; check if we hit the 0 termination char on the string
	je	end_of_str_pm	; jumpt to end_of_string
	mov [edx], ax	; copy [char,attr] at ax(ah:al) register into video mem cell
					; this equates to displaying the character
	
	add ebx, 1		; add 1 to the address to get the next character
	add edx, 2		; add 2 to the video mem address to get the next cell, adding 1
					; results in writing the char into attr cell causing color issues
	jmp start_print_pm

end_of_str_pm:
	popa			; restore all registers from stack to prepare jumping
	ret
