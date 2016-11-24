StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; AddStrl-	Unions into a set the characters in the string immediately
;		following the CALL.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;
;
;
		public	sl_AddStrl
;
sl_AddStrl	proc	far
		push	bp
		mov	bp, sp
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	si
                push	di
;
		mov	si, di
		mov	ax, es
		mov	ds, ax
		les	di, 2[bp]
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
		xchg	2[bp], di
;
		mov	al, [si]		;Get mask byte
		add	si, 8			;Skip to start of set
		mov	bh, 0
                jmp	IntoLp
BldLp:		or	[si][bx], al		;Add to set
		inc	di			;Move on to next char.
IntoLp:		mov	bl, es:[di]
		cmp	bl, 0
		jnz	BldLp
;
		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		pop	bp
		ret
sl_AddStrl	endp
;
;
stdlib		ends
		end
