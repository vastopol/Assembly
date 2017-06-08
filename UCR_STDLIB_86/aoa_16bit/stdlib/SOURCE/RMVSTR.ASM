StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; RmvStr-	Subtracts the characters in a string from a set.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	DX:SI-	Points at the string.
;
;
;
		public	sl_RmvStr
;
sl_RmvStr	proc	far
		push	ds
		push	ax
		push	bx
		push	si
		push	di
		mov	ds, dx
;
		mov	al, es:[di]		;Get mask byte
		not	al
		add	di, 8			;Skip to start of set
		mov	bh, 0
                jmp	IntoLp
RmvLp:		and	es:[di][bx], al		;Add to set
		inc	si			;Move on to next char.
IntoLp:		mov	bl, [si]
		cmp	bl, 0
		jnz	RmvLp
;
		pop	di
		pop	si
		pop	bx
		pop	ax
		pop	ds
		ret
sl_RmvStr	endp
;
;
stdlib		ends
		end
