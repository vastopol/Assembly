StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strcat- Appends one string to the end of another.
;
; inputs:
;
;	ES:DI- Points at destination string, the one to which the source
;	       string will be appended.
;
;	DX:DI- Points at the string to append.
;
;
; Note: The destination string's (ES:DI) buffer must be sufficiently large
;	to hold the result of the concatentation of the two strings.
;
		public	sl_strcat
;
sl_strcat	proc	far
		push	ds
		push	cx
		push	ax
		pushf
		push	si
		push	di
;
		mov	ds, dx
		cld
;
; Find the end of the destination string:
;
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
;
; Copy the second string to the end of the current string.
;
		dec	di
CpyLp:		lodsb
		stosb
		cmp	al, 0
		jnz	CpyLp
;
		pop	di
		pop	si
		popf
		pop	ax
		pop	cx
		pop	ds
		ret
sl_strcat	endp
;
;
stdlib		ends
		end
