; EX8_2a.asm
;
; Example demonstrating the EVEN directive.

dseg		segment

; Force an odd location counter within
; this segment:

i		byte	0

; This word is at an odd address, which is bad!

j		word	0

; Force the next word to align itself on an
; even address so we get faster access to it.

		even
k		word	0

; Note that even has no effect if we're already
; at an even address.

		even
l		word	0
dseg		ends

cseg		segment
		assume	ds:dseg
procedure	proc
		mov	ax, [bx]
		mov     i, al
		mov	bx, ax

; The following instruction would normally lie on
; an odd address.  The EVEN directive inserts a
; NOP so that it falls on an even address.

		even
		mov	bx, cx

; Since we're already at an even address, the
; following EVEN directive has no effect.

		even
		mov	dx, ax
		ret
procedure	endp
cseg		ends
		end