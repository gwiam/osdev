;
; Define the GDT (Global descriptor table) in asm
;
[bits 16]
gdt_begin:

; GDT consists of a bunch of segment descriptors (SD)
; each SD is an 8byte(64bit) structure describing various
; aspects of a memory segment: where it starts, how large it is
; what type, what priviledge etc
; look up the structure of an SD
gdt_null:		; first segment descriptor is always null descriptor
	dd	0x0		; dd= double word, i.e. 4bytes since word=2bytes
	dd 	0x0		; 8bytes full of 0
				; the idea behind a null descriptor is that in case we
				; accidentally forget to reset segment registers to the correct addresses
				; after the switch to protected mode. Addressing
				; attempts at the null descriptor will be met with an interrupt

gdt_code_seg:	; first proper segment is the code segment where code is executed
	dw 0xffff		; [15:0] bits 0-15 of the limit sets the size of the segment
	dw 0x0			; [31:16] bits 0-15 of the segment base addr
	db 0x0			; [upper 7:0] bits 16-23 of the segment base addr
	db 10011010b	; [upper 15:8] set binary flags for type of segment:
					; set to maximum addressable 16-bit number
					; [BIT15]
					; P=1 segment present
					; [BIT14,13]
					; DPL=00 descriptor priviledge level: we want segment to be
					; ring 0, the highest priviledge
					; [BIT12]
					; S=1 segment descriptor type, 1 is for either code or data
					; [BITS11-8] TYPE-bits:
					; [BIT11]
					; Type=1 describing a code segment (0 is data segment)
					; [BIT10]
					; IF Type=1 then this bit is Conforming-bit:
					;	C=0 means another segment with lower priviledge cannot call
					;	code from this segment
					;	C=1 means a lower priviledge segment can access code from this segment
					; IF Type=0 then this bit is the Expand-down bit:
					;	E=0 means that the segment can expand to base_addr+limit
					;	E=1 means that it expands from MAX_OFFSET down to limit
					; [BIT9]
					; IF Type=1 then the next bit is the Readable bit:
					;	R=1 means that this segment is executable AND readable
					;	R=0 means this segment is only executable
					; IF Type=0	then this bit would be the Writable bit:
					;	W=1 means this data segment is readable and writable
					;	w=0 means this data segment is only readable
					; [BIT8] Access bit, normally set to 0. Will be one if hardware has accessed this segment
	db 11001111b			; since we cannot set anything under 1 byte explicitly,
							; we have to set them all explictly one by one like here
							; [upper 19:16] bits 16-19 of the segment limit
							; [upper 23-20] further flags
							; [BIT23] Granularity
							; IF G=1, then limit is in units of single bytes, meaning
							; addressable space is max 2^20 bytes
							; IF G=0, then limit is in units of 4K byte pages, meaning
							; max addressable space is 2^32 bytes
							; [BIT22]
							; IF Type=1 then this is the default operand size bit
							;	D=1 means this is a 32bit code segment
							;	D=0 means this is a 16bit code segment
							; IF Type=0 then this is the Big bit:
							;	B=0 the max offset size for the data segment is 16bit 0xffff
							;	B=1 means the max offset site for the segment is 32bit 0xffffffff
							; [BIT21] Long bit, if set to 1, then this is a 64bit segment
							;	L=1 can only be set if D/B=0
							; [BIT20] AVL software flag for debugging for example
	db 0x0					; [upper 31:24] bits 24-31 of segment base addr

gdt_data_seg:
	; data segment descriptor generally same as the code segment descriptor above
	; just with slightly different flag meanings
	dw 0xffff				; segment limit
	dw 0x0					; segment base
	db 0x0					; segment base rest bits
	db 10010010b			; type flags of segments
	db 11001111b			; upper flags + rest of the limit bits
	db 0x0					; rest of the base addr bits

gdt_end:					; put an empty label here so we can let asm calculate
							; size of GDT on its own dynamically for the GDT descriptor

; define the GDT descriptor to which the GDT register points to at the start
gdt_descriptor:
	; GDT descriptor is a 6byte structure containing
	;	1. sizeof(GDT) (16bits)
	;	2. GDT beginning address (32 bits)
	dw	gdt_end - gdt_begin - 1		; end-start - 1, always one less of the true size
	dd	gdt_begin					; start address of our GDT

; define some useful constants to refer back to
; the segment registeres must contain offsets which when calculated point to the appropriate
; segment descriptors in our GDT
; ex. DS=0x10 means 0x10 + GDT base address = our data segment descriptor address

CODE_SEGMENT equ gdt_code_seg - gdt_begin	; offset from GDT base address
DATA_SEGMENT equ gdt_data_seg - gdt_begin	; offset from GDT base address
