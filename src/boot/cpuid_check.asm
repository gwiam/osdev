;
; Check program to verify that CPUID is indeed supported
;
[bits 32]

cpuid_check:
pushfd			; push EFLAGS registers (32bits total, 4x8 bit)
pushfd			; push EFLAGS registers again, working copy

xor	dword [esp], 0x00200000	; try to flip the ID-bit of the EFLAGS register, position 21
popfd			; replace the current EFLAGS register with the supposedly flipped
				; bit from the stack by popping it
pushfd			; copy EFLAGS register onto stack again
				; the ID-bit may or may not be different, we check against the previous pushed one
pop eax			; copy maybe-modified EFLAGS contents to eax
				; the only remaining thing on the stack now is the original EFLAGS
xor eax, [esp]	; eax now only contains potential bits that were changed
popfd			; restore original EFLAGS into the EFLAGS register
and eax, 0x00200000		; bitwise AND, if it comes up as 000000 then ID bit was not changed
						; ergo could not be changed => CPUID instruction not supported!
						; if non-zero then CPUID supported
jz no_cpuid
ret
no_cpuid:
	mov ebx, MSG_NOTSUPP_CPUID	
	call print_string_pm	


MSG_NOTSUPP_CPUID:
	db "CPUID not supported",13,0
