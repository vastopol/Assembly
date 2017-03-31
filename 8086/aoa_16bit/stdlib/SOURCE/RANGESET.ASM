StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; RangeSet-	Unions into a set the characters in a specified range.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	AL-	Lower bound for range.
;	AH-	Upper bound for range (note: al must be less than ah).
;
;
;
		public	sl_RangeSet
;
sl_RangeSet	proc	far
		push	ax
		push	bx
		push	cx
		pushf
		push	di
;
		mov	ch, 0
		mov	cl, ah
		sub	cl, al
		inc	cx
		mov	bh, 0
		mov	bl, al
		mov	al, es:[di]
		lea	di, 8[di][bx]
SetRange:	or	es:[di], al
		inc	di
		loop	SetRange
;
		pop	di
		popf
		pop	cx
		pop	bx
		pop	ax
		ret
sl_RangeSet	endp
;
;
stdlib		ends
		end
