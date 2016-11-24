StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strinsl- Inserts one string within another.
;
; inputs:
;
;	ES:DI- 	Points at destination string, the one into which the source
;	       	string will be appended.
;
;	CS:RET-	Points at the string to insert.
;
;	CX-	Index into source string (ES:DI) to begin insertion.
;
;
; Note: The destination string's (ES:DI) buffer must be sufficiently large
;	to hold the result of the concatentation of the two strings.
;
		public	sl_strinsl
;
rtnadrs		equ	2[bp]
srcseg		equ	(0-2)[bp]
destseg		equ	(0-4)[bp]
insindx		equ	(0-6)[bp]
source		equ	(0-8)[bp]
dest		equ	(0-10)[bp]
;
sl_strinsl	proc	far
		push	bp
		mov	bp, sp
		push	dx		;Dummy spot
		push	es
		push	cx
		push	si		;Dummy spot
		push	di
		pushf
		push	ax
                push	bx
		push	ds
		push	dx
		push	si
;
		mov	si, rtnadrs
		mov	source, si
		mov	dx, rtnadrs+2
		mov	srcseg, dx
		cld
;
; Compute the length of the string to insert.
;
		xchg	si, di
		mov	es, dx			;(srcseg)
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
		mov	rtnadrs, di
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
		pop	si
		pop	dx
		pop	ds
		pop	bx
		pop	ax
		popf
		pop	di
		pop	cx		;Dummy
		pop	cx
		pop	es
		pop	bp		;Dummy
		pop	bp
		ret
sl_strinsl	endp
;
;
stdlib		ends
		end
