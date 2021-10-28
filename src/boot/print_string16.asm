;
; Include file which provides a routine for printing null-terminated strings
;

print_string16:
	; print a string which starting address is given in bx
	pusha		; store all previous registers onto the stack
	mov ah, 0x0e	; set teletype mode for int 0x10

start_print:		; start printing process by looping through string
	mov al, [bx]
	cmp al, 0		; check if we hit the 0 termination char on the string
	je	end_of_str	; jumpt to end_of_string
	int 0x10		; activate interrupt 0x10 to print char
	add bx, 1		; add 1 to the address to get the next character
	jmp start_print

end_of_str:
	popa			; restore all registers from stack to prepare jumping
	ret
