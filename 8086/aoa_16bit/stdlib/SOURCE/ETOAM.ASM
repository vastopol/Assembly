StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far, sl_etoa:far
;
;
;
; ETOAM-	Converts floating point accumulator to a string on heap.
;
		public	sl_etoam
sl_etoam	proc	far
		push	cx
		mov	cl, al
		mov	ch, 0
		inc	cx
		call	sl_malloc
		pop	cx
		jc	BadEtoam
		jmp	near ptr sl_etoa
BadEtoam:	ret
sl_etoam	endp
;
;
;
stdlib		ends
		end