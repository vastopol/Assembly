StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strcmpl- Compares the string pointed at by es:si to the string following
;	   the call instruction.
;
; inputs:
;
;	es:di-	First string (The string to compare)
;	cs:rtn-	Second string (The string to compare against)
;
;	e.g.,
;		"if (es:si < cs:rtn) then ..."
;
; returns: 
;
;	cx- index into strings where they differ (points at the zero byte
;	    if the two strings are equal).
; 
;	Condition codes set according to the string comparison.  You should
;	use the unsigned branches (ja, jb, je, etc.) after calling this
;	routine.
;
		public	sl_strcmpl
;
sl_strcmpl	proc	far
		push	bp
		mov	bp, sp
		push	es
		push	ds
		push	cx
		push	si
		push	di
		mov	ax, es
		mov	ds, ax
		mov	si, di
		les	di, 2[bp]
;
; In order to preserve the direction flag across this call, we have to
; test whether or not it is set here and execute two completely separate
; pieces of code (so we know which state to exit in.  Unfortunately, we
; cannot use pushf to preserve this flag since we need to return status
; info in the other flags.
;
		pushf
		pop	ax
		test	ah, 4		;Test direction bit.
		jnz	DirIsSet
;
; Compute the length of the string following the CALL instruction:
;
		cld
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
		xchg	di, 2[bp]	;Save as new return address.
		neg	cx
		dec	cx		;Length of string.
		mov	ax, cx
        repe	cmpsb			;Compare the two strings.
;
		pushf
		sub	ax, cx
		dec	ax
                popf
		pop	di
		pop	si
		pop	cx
		pop	ds
		pop	es
		pop	bp
		ret			;Return with direction flag clear.
;
;
DirIsSet:	cld
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
		xchg	di, 2[bp]	;Save as new return address.
		neg	cx
		dec	cx		;Length of string.
		mov	ax, cx
        repe	cmpsb			;Compare the two strings.
;
		pushf
		sub	ax, cx
		dec	ax
		popf
		pop	di
		pop	si
		pop	cx
		pop	ds
		pop	es
		pop	bp
		std
		ret			;Return with direction flag set.
;
;
;
sl_strcmpl	endp
;
;
stdlib		ends
		end
