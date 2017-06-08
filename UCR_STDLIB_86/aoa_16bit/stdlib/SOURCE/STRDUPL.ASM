StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far
;
;
; strdupl- Copies string pointed at by cs:rtnadrs to heap and returns a
;	   pointer to this new string in es:di.
;
;
; inputs:
;		cs:rtn-	Zero-terminated source string.
; outputs:
;		es:di-	Points at destination string on heap.
;
;
;
		public	sl_strdupl
;
rtnadrs		equ   	2[bp]
;
sl_strdupl	proc	far
		push	bp
		mov	bp, sp
		push	ds
		push	cx
		push	ax
		pushf
		push	si
;
		cld
		mov	al, 0
		mov	cx, 0ffffh
		les	di, rtnadrs
	repne	scasb
		lds	si, rtnadrs
		mov	rtnadrs, di
		neg	cx
		dec	cx
;
; Allocate some storage for the string.
;
		push	cx			;Save for later
		call	sl_malloc
		pop	cx
		jc	BadStrDupl
;
		push	es			;Save ptr to string
		push	di
;
; Copy the string to the new space on the heap.
;
		shr	cx, 1
		jnc	CpyWrd
		lodsb
		stosb
CpyWrd:	rep	movsw
		pop	di			;Restore pointer to string.
		pop	es
;
DidByte:	pop	si
		popf
		pop	ax
		pop	cx
		pop	ds
		pop	bp
		clc
		ret
;
BadStrDupl:	pop	si
		popf
		pop	ax
		pop	cx
		pop	ds
		pop	bp
		stc
		ret
sl_strdupl	endp
;
;
stdlib		ends
		end
