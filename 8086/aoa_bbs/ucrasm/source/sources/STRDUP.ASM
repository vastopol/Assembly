StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; strdup- On entry, es:di points at a source string.  Strdup allocates
;	  storage for a new string the same size and copies the data from
;	  the source string to the new destination string.  Returns a ptr
;	  to the new string in ES:dI.  Calls malloc to allocate storage
;	  for the new string.
;
; inputs:
;		es:di-  Address of string to copy.
;
; outputs:
;		es:di-  Ptr to newly allocated string.
;
;
		public	sl_strdup
;
sl_strdup	proc	far
		push	ds
		push	cx
		push	ax
		pushf
		push	si
;
		mov	ax, es
		mov	ds, ax
		cld
		mov	al, 0
		mov	cx, 0ffffh
		mov	si, di
	repne	scasb
		neg	cx
		dec	cx
		push	cx
		call	sl_malloc
		pop	cx
		jc	QuitStrDup
		push	di
		shr	cx, 1
		jnc	IsWord
		lodsb
		stosb
IsWord:	rep	movsw
;
		pop	di
		pop	si
		popf
		pop	ax
		pop	cx
		pop	ds
		clc
		ret
;
QuitStrDup:	pop	si
		popf
		pop	ax
		pop	cx
		pop	ds
		stc
		ret
;
sl_strdup	endp
;
;
stdlib		ends
		end
