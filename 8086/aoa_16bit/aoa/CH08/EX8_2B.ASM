; EX8_2b.asm
;
; Example demonstrating the align
; directive.

dseg		segment

; Force an odd location counter
; within this segment:

i		byte	0

; This word is at an odd address,
; which is bad!

j		word	0

; Force the next word to align itself
; on an even address so we get faster
; access to it.

		align	2
k		word	0

; Force odd address again:

k_odd		byte	0

; Align the next entry on a double
; word boundary.

		align	4
l		dword	0

; Align the next entry on a quad
; word boundary:

		align	8
RealVar		real8	3.14159

; Start the following on a paragraph
; boundary:

		align	16
Table		dword	1,2,3,4,5
dseg		ends
		end