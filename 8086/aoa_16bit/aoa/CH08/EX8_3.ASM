; Ex8_3.asm
;
; Comparison of numeric equates with textual equates
; and the differences they produce at assembly time.
;
cseg		segment
equ1		equ	$+2		;Evaluates "$" at this stmt.
equ2		equ	<$+2>		;Evaluates "$" on use.
MyProc		proc
		mov	ax, 0
		lea	bx, equ1
		lea	bx, equ2
		lea	bx, equ1
		lea	bx, equ2
MyProc		endp
cseg		ends
		end
