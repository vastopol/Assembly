StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far, sl_free:far, sl_puts:far
		extrn	sl_ftoam:far, sl_etoam:far
;
;
; Putf-	FPACC contains a floating point value, print it to the display.
;	AL- Minimum field width
;	AH- Number of positions *after* the decimal point.
;
; Returns
;	Carry set if memory allocation error.
;
		public	sl_putf
sl_putf		proc	far
		push	es
		push	di
		push	cx
		mov	cl, al
		mov	ch, 0
		inc	cx		;Make room for zero terminating byte.
		call	sl_Malloc	;Go allocate the storage.
		jc	putfError
		call	sl_ftoam	;Convert FPACC to a string
		call	sl_puts		;Print it.
		call	sl_free		;Free up allocated storage.
		clc
PutfError:	pop	cx
		pop	di
		pop	es
		ret
sl_putf		endp
;
;
; Pute-	FPACC contains a floating point value, print it to the display using
;	scientific notion format.
;
;	AL- Minimum field width (should be at least eight!)
;
; Returns
;	Carry set if memory allocation error.
;
		public	sl_pute
sl_pute		proc	far
		push	es
		push	di
		push	cx
		mov	cl, al
		mov	ch, 0
		inc	cx		;Make room for zero terminating byte.
		call	sl_Malloc	;Go allocate the storage.
		jc	PuteError
		call	sl_etoam	;Convert FPACC to a string
		call	sl_puts		;Print it.
		call	sl_free		;Free up allocated storage.
		clc
PuteError:	pop	cx
		pop	di
		pop	es
		ret
sl_pute		endp
;
;
;
stdlib		ends
		end
