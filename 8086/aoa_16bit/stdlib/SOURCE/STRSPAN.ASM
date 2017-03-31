StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strspan-	Returns the number of characters (from a set) which
;		precede a string.
;
; inputs:
;
;	ES:DI-  Points at string to test.
;	DX:SI-	Points at set of characters (zero terminated string).
;
; outputs:
;
;	CX-	Number of characters in set which are the prefix of
;		the test string.
;
;
;
;
		public	sl_strspan
;
sl_strspan	proc	far
		pushf
		push	es
		push	ds
		push	ax
		push	bx
		push	dx
		push	si
		push	di
		cld
;
		xchg	di, si
		mov	ax, es
		mov	es, dx
		mov	ds, ax
;
		mov	bx, di			;Preserve ptr to char set.
		mov	cx, 0ffffh
		mov	al, 0
	repne	scasb				;Compute length of char set.
		neg	cx
		dec	cx
		dec	cx
		mov	dx, cx			;Save for use later.
;
; Okay, now we can see how many characters from the set match the prefix
; characters in the string.
;
StrLp:		lodsb				;Get next char in string.
		mov	cx, dx			;Get length of char set.
		mov	di, bx			;Get ptr to char set
	repne	scasb				;See if in set
		jz	StrLp			;Repeat while in set.
;
		pop	cx
		mov	di, cx
		sub	cx, si
		neg	cx
		dec	cx
		pop	si
		pop	dx
		pop	bx
		pop	ax
		pop	ds
		pop	es
		popf
		ret
sl_strspan	endp
;
;
;
;
stdlib		ends
		end
