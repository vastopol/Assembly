StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; RmvStrl-	Removes a set of characters (given by the string following
;		the call) from a set.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	CS:RET- Points at the string.
;
;
		public	sl_RmvStrl
;
sl_RmvStrl	proc	far
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
;
		mov	al, [si]		;Get mask byte
                not	al
		add	si, 8			;Skip to start of set
		mov	bh, 0
                jmp	IntoLp
RmvLp:		and	[si][bx], al		;Add to set
		inc	di			;Move on to next char.
IntoLp:		mov	bl, es:[di]
		cmp	bl, 0
		jnz	RmvLp
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
sl_RmvStrl	endp
;
;
stdlib		ends
		end
