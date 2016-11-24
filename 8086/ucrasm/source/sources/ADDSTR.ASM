StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; AddStr-	Unions into a set the characters in a string.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	DX:SI-	Points at the string.
;
;
;
		public	sl_AddStr
;
sl_AddStr	proc	far
		push	ds
		push	ax
		push	bx
		push	si
                push	di
;
		mov	ds, dx
		mov	al, es:[di]		;Get mask byte
		add	di, 8			;Skip to start of set
		mov	bh, 0
                jmp	IntoLp
BldLp:		or	es:[di][bx], al		;Add to set
		inc	si			;Move on to next char.
IntoLp:		mov	bl, [si]
		cmp	bl, 0
		jnz	BldLp
;
		pop	di
		pop	si
		pop	bx
		pop	ax
		pop	ds
		ret
sl_AddStr	endp
;
;
stdlib		ends
		end
