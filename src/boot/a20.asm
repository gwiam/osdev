;
; Probing A20 line and enabling it
;

; The A20 line is a legacy issue that carries over
; starting with the Intel 80286 processor, the addressable memory was far larger than
; 1MB but many legacy programs relied on the fact that in real-mode 8086 etc processors
; memory was still only 1MB addressable
; trying to address memory over 1MB caused a wrap around
; Example: 0xffff as the highest address. addressing 0xffff:0010 however causes a
; wrap around, as 0xffff:0010 = 0x0000 due to overflow.

; Intel refused to remove this in real-mode due to legacy programs relying on the overflow
; wrap around effect

; to get to more addressable space, the 21st line, the A20 line needs to be enabled

; on 32bit protected mode, not enabling A20 would curiously cause every odd-numbered MB
; region to be inaccessible. address 1-2MB refers to 0-1MB, address 3-4MB refers to 2-3MB etc

; After the Haswell architecture which released in (June 2013) and the Broadwell arch which is based on it, Intel CPUs don't necessarily support emulation of the A20 line
; A20 is enabled by default and cannot be changed.

; to test A20 line enabled or not, we check if we experience wrap around effect
; i.e. put a value onto 0000:0500, put another value in 0xffff:0510
; check if the two values are the same or not
; if values differ, then A20 is already enabled

[bits 32]

check_a20_pm:	; check whether or not A20 is enabled in 32bit PM
	 pushad			; push eax register to save values
	 mov edi,0x112345	; odd megabyte addr
	 mov esi, 0x012345	; even megabyte addr
	 mov [edi], edi		; put edi addr value into memory at edi location
	 mov [esi], esi		; put esi addr value into memory at esi location
						 ; check whether or not one of the two is being overwritten
						 ; if both contain the same value now, there is memory wraparound
						 ; if both contain different values, A20 is enabled
	 cmpsd				; compare string operand, compares dw at ESI with dw at ESI
						 ; Zero-Flag is set to the result of the comparison
	 popad				; restore eax register	
	 jne a20_is_on		; if ZF is indeed 0, we jump to a20_is_on
	 mov ebx, MSG_A20_OFF
	 call print_string_pm
	 ret					; ZF was 1 and we signal that

a20_is_on:
	mov ebx, MSG_A20_ON
	call print_string_pm
	ret

MSG_A20_OFF:
	db "A20 is off",13,10,0
MSG_A20_ON:
	db "A20 is on",13,10,0
