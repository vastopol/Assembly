StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
		extrn	$uprtbl:byte
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
;
; strcmpl- Compares the string pointed at by es:si to the string following
;	   the call instruction.
;
; inputs:
;
;	es:si-	First string (The string to compare)
;	cs:rtn-	Second string (The string to compare against)
;
;	e.g.,
;		"if (es:si < cs:rtn) then ..."
;
; returns: 
;
;	ax- index into strings where they differ (points at the zero byte
;	    if the two strings are equal).
; 
;	Condition codes set according to the string comparison.  You should
;	use the unsigned branches (ja, jb, je, etc.) after calling this
;	routine.
;
		public	sl_stricmpl
;
sl_stricmpl	proc	far
		push	bp
		mov	bp, sp
		push	es
		push	ds
		push	bx
		push	cx
		push	si
		push	di
		mov	ax, es
		mov	ds, ax
		les	di, 2[bp]
		lea	bx, stdgrp:$uprtbl
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
;
		xor	cx, cx		;Set char index to zero.
sclp:		lodsb
		xlat	StdGrp:$uprtbl
		mov	ah, al
		mov	al, es:[di]
		xlat	StdGrp:$uprtbl
		cmp	ah, al		
		jne	scNE		;If strings are <>, quit.
		inc	cx	        ;Increment index into strs.
		inc	di		;Incrment str2 ptr.
		cmp	al, 0		;Check for end of strings.
		jne	sclp
		pushf
		dec	cx
		popf
;
scNE:		mov	ax, cx
		pop	di
		pop	si
		pop	cx
		pop	bx
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
;
		xor	cx, cx		;Set char index to zero.
sclp2:		lodsb
		xlat	StdGrp:$uprtbl
		mov	ah, al
		mov	al, es:[di]
		xlat	StdGrp:$uprtbl
		cmp	ah, al		
		jne	scNE2		;If strings are <>, quit.
		inc	cx	        ;Increment index into strs.
		inc	di		;Incrment str2 ptr.
		cmp	al, 0		;Check for end of strings.
		jne	sclp2
		pushf
		dec	cx
		popf
;
scNE2:		mov	ax, cx
		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ds
		pop	es
		pop	bp
		std
		ret			;Return with direction flag set.
;
;
;
sl_stricmpl	endp
;
;
stdlib		ends
		end
