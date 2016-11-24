StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
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
		push	bx
		push	dx
		cmp	ax, 0
		jge	Doit
		push	ax
		mov	al, '-'
		call	sl_Putc
		pop	ax
		neg	ax
;
DoIt:		call	puti2
		pop	dx
		pop	bx
		pop	ax
		ret
sl_Puti		endp
;
; Putu prints the value in AX as an unsigned integer value.
;
		public	sl_PutU
sl_PutU		proc	far
		push	ax
		push	bx
		push	dx
		call	PutI2
		pop	dx
		pop	bx
		pop	ax
		ret
sl_PutU		endp
;
; PutI2- Recursive routine to actually print the value in AX as an integer.
;
Puti2		proc	near
		mov	bx, 10
		xor	dx, dx
		div	bx
		or	ax, ax		;See if ax=0
		jz	Done
		push	dx
		call	Puti2
		pop	dx
Done:		mov	al, dl
		or	al, '0'
		call	sl_Putc
		ret
PutI2		endp
stdlib		ends
		end
