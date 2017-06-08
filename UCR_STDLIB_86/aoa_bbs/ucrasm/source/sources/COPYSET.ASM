StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; CopySet-	Copies one set to another.
;
; inputs:
;
;	ES:DI-  Points at the destination set (at its mask byte).
;	DX:SI-	Points at the mask byte of the source set.
;
;
;
		public	sl_CopySet
;
sl_CopySet	proc	far
		push	ds
		push	es
		push	ax
		push	cx
                push	dx
		push	si
		push	di
		mov	ds, dx
;
		mov	ah, es:[di]		;Get mask bytes
		mov	al, [si]
		mov	dl, ah
		not	dl
		add	si, 8			;Skip to start of set
                add	di, 8
		mov	cx, 256
CpySetLp:	test	al, [si]
		jnz	SetBit
		and	es:[di], dl
		inc	si
		inc	di
		loop	CpySetLp
		jmp	CpySetDone
;
SetBit:		or	es:[di], ah
		inc	si
		inc	di
		loop	CpySetLp
;
CpySetDone:	pop	di
		pop	si
		pop	dx
		pop	cx
		pop	ax
		pop	es
		pop	ds
		ret
sl_CopySet	endp
;
;
stdlib		ends
		end
