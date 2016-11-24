StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strcatl- Appends one string to the end of another.
;
; inputs:
;
;	ES:DI-  Points at destination string, the one to which the follow
;	        string will be appended.
;
;	CS:RET	Points at the follow string.
;
;
; Note: The destination string's (ES:DI) buffer must be sufficiently large
;	to hold the result of the concatentation of the two strings.
;
		public	sl_strcatl
;
sl_strcatl	proc	far
		push	bp
		mov	bp, sp
		push	ds
		push	cx
		push	ax
		pushf
		push	si
		push	di
;
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
		lds	si, 2[bp]		;Get Return Address
		dec	di
CpyLp:		lodsb
		stosb
		cmp	al, 0
		jnz	CpyLp
;
		mov	2[bp], si		;Save new return address.
		pop	di
		pop	si
		popf
		pop	ax
		pop	cx
		pop	ds
		pop	bp
		ret
sl_strcatl	endp
;
;
stdlib		ends
		end
