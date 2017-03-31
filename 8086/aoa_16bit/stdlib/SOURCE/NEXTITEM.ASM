StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; NextItem-	Locates the first (next) character in the set.
;
; inputs:
;
;	ES:DI-  Points at the set to search through.
;
; outputs:
;
;	AL-	Next available character in set (zero if set is empty).
;
;
		public	sl_NextItem
;
sl_NextItem	proc	far
		push	cx
		push	di
;
		mov	al, es:[di]
		mov	cx, 256
		add	di, 7
NextLp:		inc	di
		test	al, es:[di]
		loopz	NextLp
;
		neg	cx
		mov	al, cl
		pop	si
		pop	cx
		ret
sl_NextItem	endp
;
;
stdlib		ends
		end
