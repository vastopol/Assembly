StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strlen- Computes the length of the string which ES:DI points at.
;
; inputs:
;
;	ES:DI- Points at string to compute the length of.
;
; output:
;
;	CX- Length of string.
;
;
		public	sl_strlen
;
sl_strlen	proc	far
		push	ax
		pushf
		push	si
		push	di
;
		cld
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
		neg	cx
		dec	cx
		dec	cx
;
		pop	di
		pop	si
		popf
		pop	ax
		ret
sl_strlen	endp
;
;
stdlib		ends
		end
