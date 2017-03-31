StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strcmp- Compares two strings.
;
; inputs:
;
;	es:di-	First string (The string to compare)
;	dx:si-	Second string (The string to compare against)
;
;	e.g.,
;		"if (es:di < dx:si) then ..."
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
		public	sl_strcmp
;
sl_strcmp	proc	far
		push	es
		push	ds
		push	bx
		push	ax
		push	si
		push	di
;
; Swap pointers so they're more convenient for the LODSB/SCASB instrs.
;
		xchg	si, di
		mov	ax, es
		mov	ds, ax
		mov	es, dx
;
		xor	bx, bx		;Set initial index to zero.
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
sclp:		lodsb
		scasb
		jne	scNE		;If strings are <>, quit.
		inc	bx	        ;Increment index into strs.
		cmp	al, 0		;Check for end of strings.
		jne	sclp
		pushf
		dec	bx
		popf
;
scNE:		pop	di
		pop	si
		mov	cx, bx
		pop	ax
		pop	bx
		pop	ds
		pop	es
		ret			;Return with direction flag clear.
;
;
DirIsSet:	lodsb
		scasb
		jne	scNE2		 ;If strings are <>, quit.
		inc	bx
		cmp	al, 0		 ;Check for end of strings.
		jne	DirIsSet
		pushf
		dec	bx
		popf
;
scNE2:		pop	di
		pop	si
		mov	cx, bx
		pop	ax
		pop	bx
		pop	ds
		pop	es
		std			;Return with direction flag set.
                ret

sl_strcmp	endp
;
;
stdlib		ends
		end
