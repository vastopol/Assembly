StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strins- Inserts one string within another.
;
; inputs:
;
;	ES:DI- Points at destination string, the one into which the source
;	       string will be appended.
;
;	DX:SI- Points at the string to insert.
;
;	CX-	Index into source string (ES:DI) to begin insertion.
;
;
; Note: The destination string's (ES:DI) buffer must be sufficiently large
;	to hold the result of the concatentation of the two strings.
;
		public	sl_strins
;
srcseg		equ	(0-2)[bp]
destseg		equ     (0-4)[bp]
insindx		equ	(0-6)[bp]
source		equ	(0-8)[bp]
dest		equ	(0-10)[bp]
;
sl_strins	proc	far
		push	bp
		mov	bp, sp
		push	dx
		push	es
		push	cx
		push	si
		push	di
		pushf
		push	ax
		push	bx
		push	ds
;
		cld
;
; Compute the length of the string to insert.
;
		xchg	si, di
		mov	es, dx			;(srcseg)
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
		neg	cx
		dec	cx
		dec	cx
		mov	bx, cx			;Save for later.
;
; Find the length of the dest string.
;
		xchg	si, di
		mov	es, destseg
		mov	cx, 0ffffh
	repne	scasb
;
; Compute the address of the insertion point:
;
		mov	dx, dest
		add	dx, insindx
		cmp	dx, di			;See if beyond end of string.
		jb	InsOkay
		lea	dx, (0-1)[di]
InsOkay:
;
; Make room for the insertion.
;
		mov	ds, destseg
		mov	si, di
		add	si, bx
		xchg	si, di
		mov	cx, bx
		std
	rep	movsb
;
; Now perform the insertion.
;
		cld
		mov	si, source
		mov	di, dx
		mov	cx, bx
		mov	ds, srcseg
	rep	movsb
;
;
		pop	ds
		pop	bx
		pop	ax
		popf
		pop	di
		pop	si
		pop	cx
		pop	es
		pop	dx
		pop	bp
		ret
sl_strins	endp
;
;
stdlib		ends
		end
