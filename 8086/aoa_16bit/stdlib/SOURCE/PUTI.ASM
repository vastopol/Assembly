StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
; Changed Puti2 as per suggestion by David Holm, 10/22/91.
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_putc:far
;
; Puti prints the value in AX as a signed integer value.
;
		public	sl_puti
sl_Puti		proc	far
		push	ax
		cmp	ax, 0
		jge	Doit
		push	ax
		mov	al, '-'
		call	sl_Putc
		pop	ax
		neg	ax
;
DoIt:		call	puti2
		pop	ax
		ret
sl_Puti		endp
;
; Putu prints the value in AX as an unsigned integer value.
;
		public	sl_PutU
sl_PutU		proc	far
		push	ax
		call	PutI2
		pop	ax
		ret
sl_PutU		endp
;
; PutI2- Iterative routine to actually print the value in AX as an integer.
;	 (Submitted by David Holm)
;
Puti2		proc	near
		push	bx
		push	cx
		push	dx
		mov	bx, 10
		xor	cx, cx
Puti2Lp:	xor	dx, dx
		div	bx
		or	dl, '0'
		push	dx
		inc	cx
		or	ax, ax
		jnz	Puti2Lp
Popi2lp:	pop	ax
		call	sl_putc
		loop	Popi2lp
		pop	dx
		pop	cx
		pop	bx
		ret
PutI2		endp
stdlib		ends
		end
