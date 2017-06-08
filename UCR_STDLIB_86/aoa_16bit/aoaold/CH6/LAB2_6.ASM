; File: lab2_6.asm for Chapter Six laboratory exercise #2 in
;	"The Art of Assembly Language Programming"
;
; Create an assembly listing of the following file.
; Then obey the comments found in this code and create a new
; assembly listing.  Compare the object code produced by the
; two assemblies.


; Modify the following segment directive, adding the "para" operand
; to force paragraph alignment.

cseg		segment
Misalign	db	?

; Insert an "align 4" directive before the following procedure.

Proc1		proc
		push	ax
		mov	bx, 0
		add	ax, bx
		mov	bx, ax
		mov	ds:[1000h], ax
		pop	ax
		ret
Proc1		endp

; Insert an "align 4" directive before the following procedure.

Proc2		proc
		mov	ax, 0
		mov	bx, 0
		mov	cx, 0
		mov	dx, 0
		ret
Proc2		endp
cseg		ends
		end
