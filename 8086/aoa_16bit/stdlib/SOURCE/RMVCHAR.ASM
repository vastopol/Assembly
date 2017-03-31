StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; RmvChar-	Removes a character from a set.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	AL-	Character to remove from the set.
;
;
;
		public	sl_RmvChar
;
sl_RmvChar	proc	far
		push	ax
		push	bx
;
		mov	bl, al
                mov	bh, 0
		mov	al, es:[di]		;Get mask byte
		not	al
		and	es:8[di][bx], al	;Add to set
;
		pop	bx
		pop	ax
		ret
sl_RmvChar	endp
;
;
stdlib		ends
		end
