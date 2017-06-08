StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far
;
;
; strinsml- 	Inserts one string within another.
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
; outputs:
;
;	ES:DI-	Points at new string on the heap.
;	Carry-	Zero if no error, One if memory allocation error.
;
;
;
		public	sl_strinsml
;
rtnadrs		equ	2[bp]
srcseg		equ	(0-2)[bp]
source		equ	(0-4)[bp]
destseg		equ	(0-6)[bp]
dest		equ	(0-8)[bp]
insindx		equ	(0-10)[bp]
;
sl_strinsml	proc	far
		push	bp
		mov	bp, sp
		push	dx		;Dummy spot
		push	si		;Dummy spot
		push	es
		push	di
		push	cx
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
; Compute the length of the destination string.
;
		mov	al, 0
		mov	cx, 0ffffh
	repne	scasb
;
; Compute the length of the string to insert.
;
		mov	di, si
		mov	es, dx			;(srcseg)
		mov	al, 0
	repne	scasb
		mov	rtnadrs, di		;Restore return address.
		neg	cx
		dec	cx
;;;;;;;;;;;;;;	dec	cx			;Plus one for the zero byte.
;
; Allocate memory for the new string:
;
		call	sl_malloc
		jnc	GoodMalloc
;
		pop	si
		pop	dx
		pop	ds
		pop	bx
		pop	ax
		popf
		pop	cx
		pop	di
		pop	es
		add	sp, 4			;Remove junk bytes
		pop	bp
		stc				;Out of memory
		ret
;
;
; If we were able to malloc the string, drop down here:
;
GoodMalloc:	mov	dx, es			;Save ptr to new string
		mov	bx, di
		lds	si, dword ptr Dest
;
; Copy the first part of the destination string to the new string.
;
		mov	cx, insindx
CpyDest1:	lodsb
		stosb
		cmp	al, 0
		loopne	CpyDest1
		jnz	SkipDec
		dec	di			;Back up a character if we
		dec	si			; hit a zero byte.
;
SkipDec:	push si				;Save ptr to middle of dest.
;
; Copy the source string into the middle.
;
		lds	si,source
CpySrc:		lodsb
		stosb
		cmp	al, 0
		jnz	CpySrc
		dec	di
;
; Copy the remainder of the destination string to the new string.
;
		pop	si			;Retrieve ptr into dest.
		mov	ds, DestSeg
CpyDest:	lodsb
		stosb
		cmp	al, 0
		jnz	CpyDest
		mov	es, dx			;Retrieve ptr to new string.
		mov	di, bx
;
		pop	si
		pop	dx
		pop	ds
		pop	bx
		pop	ax
		popf
		pop	cx
		add	sp,8			;Don't restore es:di or junk.
		pop	bp
		clc				;Allocated string okay.
		ret
sl_strinsml	endp
;
;
stdlib		ends
		end
