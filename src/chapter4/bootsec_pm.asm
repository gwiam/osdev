;
; A short boot sector program to let us jump into 32bit protected mode
;
[org 0x7c00]	; count all addresses from here

[bits 16]

mov bp, 0x9000	; set stack base safely away from this code part
mov sp, bp

mov bx, MSG_REAL_MODE
before_call:
call print_string16		; write out via BIOS interrupt that we are in 16bit real mode

after_call:
; switch to PM
call switch_to_pm		; we will never return from this call!

jmp	$					; endless loop which will never get executed

MSG_REAL_MODE:
	db "We have started in 16-bit real mode",0

%include "../print_string16.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 32]				; this part is rendered in 32bits
BEGIN_PM:

	mov ebx, MSG_PROTECTED_MODE
	call print_string_pm		; write out via framebuffer VGA color mode 80x25
								; that we are in PM now

	jmp $				; endless loop

; data

MSG_PROTECTED_MODE:
	db "We have successfully switched into 32-bit protected mode",0

; magic number and 0 padding until sector is full
times 510-($-$$) db 0
dw 0xaa55
