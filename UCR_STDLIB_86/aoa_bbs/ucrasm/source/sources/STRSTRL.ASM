StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp

;
;
; strstrl- Returns the position of a substring in another string.
;
; inputs:
;
;	es:di- address of string to search through.
;	return address- address of substring to search for.
;
;
; returns: 
;
;	cx- position of character in string (if present).
;	carry=0 if character found.
;	carry=1 if character is not present in string.
;
		public	sl_strstrl
;
sl_strstrl	proc	far
		push	bp
		mov	bp, sp
		push	ds
		push	es
		pushf
		push	si
		push	di
		push	ax
		push	bx
		push	dx
		cld
		mov	ax, es
		mov	ds, ax
		mov	si, di
		les	di, 2[bp]
;
		mov	bx, di		;Save ptr to substring.
;
; Compute the length of the substring:
;
		mov	cx, 0ffffh
		mov	al, 0
	repne	scasb
		neg	cx
		dec	cx
		dec	cx
		mov	dx, cx		;Save length of smaller string.
		mov	2[bp], di	;Save new return address.
;
		mov	ax, si		;Save ptr to string.
StrLp:		mov	cx, dx
	repe	cmpsb			;Compare the strings
		jz	StrsAreEql	;Jump if substring exists.
		inc	ax		;Bump pointer into string.
		mov	si, ax		;Restore pointers.
		mov	di, bx
		cmp	byte ptr [si], 0 ;Done yet?
		jne	StrLp
;
; Bad news down here, the substring isn't present in the source string.
;
		xor	cx, cx
		pop	dx
		pop	bx
		pop	ax
		pop	di
		pop	si
		popf
		pop	es
		pop	ds
		pop	bp
		stc
		ret
;
StrsAreEql:
		mov	cx, ax			;Save ptr to string
		pop	dx
		pop	bx
		pop	ax
		pop	di
		sub	cx, di			;Compute index to substring.
		pop	si
		popf
		clc
		pop	es
		pop	ds
		pop	bp
		ret
sl_strstrl	endp
;
;
stdlib		ends
		end
