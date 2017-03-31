StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; Member-	Checks to see if a character is in a set.
;
; inputs:
;
;	ES:DI-  Points at the set (at its mask byte).
;	AL-	Character to check.
;
; outputs:
;	zero flag is set if the character is not in the set.
;	zero flag is clear if the character is in the set.
;
;
		public	sl_member
;
sl_member	proc	far
		push	ax
		push	bx
;
		mov	bl, al
                mov	bh, 0
		mov	al, es:[di]		;Get mask byte
		test	al, es:8[di][bx]	;See if char is in set.
;
		pop	bx
		pop	ax
		ret
sl_member	endp
;
;
stdlib		ends
		end
