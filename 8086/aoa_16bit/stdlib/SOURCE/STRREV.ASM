StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strrev- reverses the characters in a string.
;
; inputs:
;
;	ES:DI- Points at the string to reverse.
;
;
; Created by Mike Blaszczak (.B ekiM)  8/8/90
; Some minor tweaking by R. Hyde 8/9/90
;
;
		public	sl_strrev
;
;
sl_strrev	proc	far
		push	ds
		push	si
		push	di
		push	ax
		push	cx
		pushf
		cld
;
; Init ptr to the start of the string
;
		mov	si, es
		mov	ds, si
		mov	si, di
;
; Compute the length of the string:
;
		mov	cx, 0ffffh
		mov	al, 0
	repne	scasb
		neg	cx
		dec	cx
		dec	cx
		shr	cx, 1		;Only have to do half the bytes.
		jcxz	StrRvsd
		dec	di     		;Point at zero byte.
;
; Okay, swap the bytes in the string.
;
SwapBytes:	dec	di
		lodsb
		xchg	al, [di]	;Note: es=ds.
		mov	(0-1)[si], al
		loop	SwapBytes
;
StrRvsd:        popf
		pop	cx
		pop	ax
		pop	di
		pop	si
		pop	ds
		ret
sl_strrev	endp
;
;
stdlib		ends
		end
