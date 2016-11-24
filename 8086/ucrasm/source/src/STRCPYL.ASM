StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strcpyl- Copies string pointed at by cs:rtnadrs to dx:si.
;
;
; inputs:
;		cs:rtn-	Zero-terminated source string.
;		dx:si-  Buffer for destination string.
; outputs:
;		dx:si-	Still points at destination string.
;
;
; Note: The destination buffer must be large enough to hold the string and
;	zero terminating byte.
;
		public	sl_strcpyl
;
rtnadrs		equ	6[bp]
destptr		equ	2[bp]
;
sl_strcpyl	proc	far
		push	dx
		push	si
		push	bp
		mov	bp, sp
		push	ds
		push	es
		push	di
		push	cx
		push	ax
		pushf
;
		cld
		mov	al, 0
		mov	cx, 0ffffh
		les	di, rtnadrs
	repne	scasb
		lds	si, rtnadrs
		mov	rtnadrs, di
		les	di, destptr
		neg	cx
		dec	cx
		shr	cx, 1
		jnc	CpyWrd
		lodsb
		stosb
CpyWrd:	rep	movsw
;
DidByte:	popf
		pop	ax
		pop	cx
		pop	di
		pop	es
		pop	ds
		pop	bp
		pop	si
		pop	dx
		ret
sl_strcpyl	endp
;
;
stdlib		ends
		end
