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
; stricmp- Compares two strings, ignoring differences in case.
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
		public	sl_stricmp
;
sl_stricmp	proc	far
		push	es
		push	ds
		push	bx
		push	ax
		push	si
		push	di
		xchg	di, si
		mov	ax, es
		mov	ds, ax
		mov	es, dx
		xor	cx, cx		;Set initial index to zero.
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
scNE:		pop	di
		pop	si
		pop	ax
		pop	bx
		pop	ds
		pop	es
		ret			;Return with direction flag clear.
;
;
DirIsSet:	lodsb
		xlat	StdGrp:$uprtbl
		mov	ah, al
		mov	al, es:[di]
		xlat	StdGrp:$uprtbl
		cmp	ah, al
		jne	scNE2		 ;If strings are <>, quit.
		inc	cx
		inc	di
		cmp	al, 0		 ;Check for end of strings.
		jne	DirIsSet
		pushf
		dec	cx
		popf
;
scNE2:		pop	di
		pop	si
		pop	ax
		pop	bx
		pop	ds
		pop	es
		std			;Return with direction flag set.
                ret

sl_stricmp	endp
;
;
stdlib		ends
		end
