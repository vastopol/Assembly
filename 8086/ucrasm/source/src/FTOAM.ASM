StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far, sl_ftoa:far
;
;
;
; FTOAM-	Converts floating point accumulator to a string on heap.
;
		public	sl_ftoam
sl_ftoam	proc	far
		push	cx
		mov	cl, al
		mov	ch, 0
		inc	cx
		call	sl_malloc
		pop	cx
		jc	Badftoam
		jmp	near ptr sl_ftoa
BadFtoam:	ret
sl_ftoam	endp
;
;
;
stdlib		ends
		end