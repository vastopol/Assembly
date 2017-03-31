StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; RmvItem-	Locates and removes the first (next) character in the set.
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
		public	sl_RmvItem
;
sl_RmvItem	proc	far
		push	cx
		push	di
;
		mov	al, es:[di]
		mov	cx, 256
		add	di, 7
NextLp:		inc	di
		test	al, es:[di]
		loopz	NextLp
		jz	NoMask
		not	al
		and	es:[di], al
		inc	cx
;
NoMask:		neg	cx
		mov	al, cl
		pop	di
		pop	cx
		ret
sl_RmvItem	endp
;
;
stdlib		ends
		end
