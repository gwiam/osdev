;
; Function to enable us to switch into 32bit protected mode (PM) in x86
;
[bits 16]
switch_to_pm:
	cli			; clear interrupt=disable all interrupts until later when we activate them again
				; interrupts are handled differently in PM, so continuing with the
				; 16bit real mode interrupts that we currently have with BIOS is not possible

	lgdt	[gdt_descriptor]	; load GDT descriptor register
	; now actually switch into PM
	; critical step in which we set the highest bit of the control register cr0 to 1
	mov eax, cr0	; we cannot set the highest bit of cr0 directly, so we copy out its content
	or	eax, 0x1	; manipulate the highest bit by OR operation with 0x1
	mov cr0, eax	; which is just 100000000 OR EAX and copy this back to cr0

	; we are now in 32bit protected mode (theoretically)...but:
	; 
	; it is important now to flush the CPU pipeline as the first thing into PM
	; to ensure that all future operations are executed in the right mode
	; half-loaded instructions need to finish and we need to start from a fresh slate
	
	jmp CODE_SEGMENT:start_protected_mode	; long jump enable us to flush the pipeline
										; long jumps are coded as jmp <segment>:<offset>A
										; name might be confusing because we do not need to
										; jump 'far'. It is just how we jumped that is important
										; to be able to clear the pipeline and set the
										; cs register correctly

[bits 32]		; indicating 32bit protected mode code instructions

start_protected_mode:
	; definitely in protected mode now!
	; first things first: all of our old segment values in the registeres are meaningless now
	; they are 16bit stuff, we are now in 32bit mode
	mov ax, DATA_SEGMENT	; point all of our segment registeres to the segment value from
							; our GDT
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; update our stack pointers
	mov ebp, 0x90000		; our stack is now right at top of free space
	mov esp, ebp			; reset stack pointer to new base
	
	call BEGIN_PM			; call to the new 32bit section
							; we will never return from here!
