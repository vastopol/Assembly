StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; EmptySet-	Clears an existing set's elements changing it to the empty
;		set.
;
;		ES:DI must point at set (first byte of desired set) upon
;		entry.
;
;
		public	sl_EmptySet
;
sl_EmptySet	proc	far
		push	ds
		push	ax
		push	cx
		pushf
		push	di
		push	si
;
		mov	ax, es
		mov	ds, ax
		mov	ah, [di]		;Get Mask byte.
		not	ah
		add	di, 8			;Point at start of set
		mov	si, di
		mov	cx, 256
ClearSet:	lodsb
		and	al, ah
		stosb
		loop	ClearSet
;
		pop	si
		pop	di
		popf
                pop	cx
		pop	ax
		pop	ds
		clc
		ret
;
sl_EmptySet	endp
;
;
stdlib		ends
		end
