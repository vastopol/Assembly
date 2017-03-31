StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
;
; strrevm- reverses the characters in a string.
;
; inputs:
;
;	ES:DI- Points at the string to reverse.
;
; outputs:
;
;	ES:DI- Points at new string on the heap.
;	Carry=1 if memory allocation error, 0 if no error.
;
;
; Created by Mike Blaszczak (.B ekiM)  8/8/90
; Some minor tweaking by R. Hyde 8/9/90
;
;
		public	sl_strrevm
;
;
sl_strrevm	proc	far
		push	ds
		push	si
		push	ax
		push	cx
		pushf
		cld
;
;
; Compute the length (+1 for zero byte) of the string:
;
		mov	cx, 0ffffh
		mov	al, 0
	repne	scasb
		neg	cx
		dec	cx
;
; Save ptr to end of the string
;
		mov	si, es
		mov	ds, si
		lea	si, (0-1)[di]		;Points at zero byte.
;
; Allocate storage for the new string:
;
		mov	ax, cx			;Save length
		call	sl_malloc
		mov	cx, ax			;Restore length
		jc	BadStrRev
		push	es			;Save ptr to string.
		push	di
;
; Note that string length is always at least one (for the zero byte).
; Copy and reverse the string down here.
;
CopyBytes:	dec	si
		mov	al, [si]
		stosb
		loop	CopyBytes
		mov	byte ptr es:[di], 0
		pop	di			;Restore ptr to new string.
		pop	es
;
		popf
		pop	cx
		pop	ax
		pop	si
		pop	ds
		clc
		ret
;
BadStrRev:	popf
		pop	cx
		pop	ax
		pop	si
		pop	ds
		stc
		ret
sl_strrevm	endp
;
;
stdlib		ends
		end
