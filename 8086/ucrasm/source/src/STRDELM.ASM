StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; strdelm- deletes characters from a string.
;
; inputs:
;
;	ES:DI- Points at the string to delete characters from.
;
;	CX-	Index into source string (ES:DI) to begin deletion.
;
;	AX-	Number of characters to delete.
;
; outputs:
;
;	ES:DI-	Points at new string on stack which is the image of the
;		source string minus the specified characters.
;
;	Carry=1 if memory allocation error, 0 if sufficient memory for the
;		new string.
;
;
		public	sl_strdelm
;
;
sl_strdelm	proc	far
		push	es
		push	di
		push    si
		push	ds
		push	ax
		push	bx
		push	cx
		mov	bx, ax			;Save length
;
; Compute the length of the source string:
;
		push	es
		push	di
		push	cx
		mov	cx, 0ffffh
		mov	al, 0
	repne	scasb
		neg	cx
		sub	cx, bx			;Compute length of new str.
		jnc	DoAlloc			;Too much to delete?
		pop	cx			;Use insertion point as
		push	cx			; the length.
;
DoAlloc:	call	sl_malloc
		jnc	GoodAlloc
		add	sp, 6
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		pop	si
		pop	di
		pop	es
		ret
;
GoodAlloc:	pop	cx
		pop	si
		pop	ds
		push	es			;Save ptr to new string.
		push	di
Cpy1:		lodsb
		stosb
		cmp	al, 0
		loopne	Cpy1
		jz	DelDone
Skp1:		mov	cx, bx			;Get # chars to delete
Skp2:		lodsb
		cmp	al, 0
		loopne	Skp2
		jz	DelDone
Cpy2:		lodsb
		stosb
		cmp	al, 0
		jnz	Cpy2
;
DelDone:	mov	byte ptr es:[di], 0
		pop	di
		pop	es
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		pop	si
		add	sp, 4			;Don't restore es:di
		ret
sl_strdelm	endp
;
;
stdlib		ends
		end
