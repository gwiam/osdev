;
; A short boot sector program to let us jump into 32bit protected mode
;
;[org 0x7c00]	; count all addresses from here

[bits 16]
KERNEL_OFFSET equ 0x1000	; location where we want to load our kernel into

mov [BOOT_DRIVE], dl		; save the bootdrive which BIOS stores in dl register

mov bp, 0x9000	; set stack base safely away from this code part
mov sp, bp

mov bx, MSG_REAL_MODE
before_call:
call print_string16		; write out via BIOS interrupt that we are in 16bit real mode

loading_kernel:
call load_kernel		; loading the kernel
; switch to PM
call switch_to_pm		; we will never return from this call!

jmp	$					; endless loop which will never get executed

%include "print_string16.asm"
%include "read_disk.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

[bits 16]
load_kernel:			; load kernel from disk routine
	mov bx, MSG_LOADING_KERNEL	; print msg of loading kernel
	call print_string16
	
	mov bx, KERNEL_OFFSET		; set parameter for the disk_load routine
	mov dh, 15					; base address to load is now in bx
								; we want to load 15 disk sectors from addr
								; why 15? kernel is so small right now it fits
								; into 1 sector. Reason: It's fine right now and does
								; not hurt to read a lot of empty data. It might become
								; a problem later on though...
	mov dl, [BOOT_DRIVE]		; from the boot drive
	call read_disk				; begin to read from disk
	ret

[bits 32]				; this part is rendered in 32bits
BEGIN_PM:

	mov ebx, MSG_PROTECTED_MODE
	call print_string_pm		; write out via framebuffer VGA color mode 80x25
								; that we are in PM now
	call KERNEL_OFFSET			; jump to the address that is now loaded with
								; kernel code
	jmp $				; endless loop

; data
BOOT_DRIVE:
	db 0		; store the boot drive into a temp storage
MSG_REAL_MODE:
	db "We have started in 16-bit real mode",0

MSG_PROTECTED_MODE:
	db "We have successfully switched into 32-bit protected mode",0
MSG_LOADING_KERNEL:
	db "We are loading the kernel...",0
; magic number and 0 padding until sector is full
times 510-($-$$) db 0
dw 0xaa55
