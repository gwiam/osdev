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
%include "cpuid_check.asm"
%include "a20.asm"	
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
								; begin preparation to enter long mode
	call cpuid_check			; check if CPUID instruction available
	mov eax, 0x80000000			; set eax to check if extended functions of CPUID are available
	cpuid						; long mode is only checkable with extendend functions
	cmp eax, 0x80000001			; compare
	jb no_long_mode				; jump if there is no long mode available
	mov eax, 0x80000001			; set eax register to pulling extended function
	cpuid
	test edx, 1<<29				; edx register contains extended information
								; check if the 29th bit, the long-mode bit, is set
	jz no_long_mode				; if there is nothing set, then long mode unsupported	
	call check_a20_pm			; check if the A20 is already on
								; ZF is set to the result, if ZF=1 then A20 off
								; ZF=0 then it is on
	
	call KERNEL_OFFSET			; jump to the address that is now loaded with
								; kernel code
no_long_mode:
	mov ebx, MSG_NO_LONG_MODE	; there is no long mode on this CPU
	call print_string_pm

	jmp $
; data
BOOT_DRIVE:
	db 0		; store the boot drive into a temp storage
MSG_REAL_MODE:
	db "In 16bit real mode!",13,10,0 ; 13dec,10dec is CR+LF
MSG_PROTECTED_MODE:
	db "Successfully switched to 32bit PM!",0
MSG_LOADING_KERNEL:
	db "Loading kernel...",13,10,0
MSG_NO_LONG_MODE:
	db "No long mode!",13,10,0
; magic number and 0 padding until sector is full
times 510-($-$$) db 0
dw 0xaa55
