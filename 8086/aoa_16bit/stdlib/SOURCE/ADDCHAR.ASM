StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; AddChar-	Unions a character into a set.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	AL-	Character to union into the set.
;
;
;
		public	sl_AddChar
;
sl_AddChar	proc	far
		push	ax
		push	bx
;
		mov	bl, al
                mov	bh, 0
		mov	al, es:[di]		;Get mask byte
		or	es:8[di][bx], al	;Add to set
;
		pop	bx
		pop	ax
		ret
sl_AddChar	endp
;
;
stdlib		ends
		end
