StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far, sl_utoa:far,sl_itoa:far
;
;		These routines convert the value in AX to a string
;		of digits.  They automatically allocate storage on the
;		heap for their results and return a pointer to the new
;		string in ES:DI.
;
;		These routines return the carry set if there was a memory
;		allocation error (insufficient room on heap).
;
;
; ITOAM-	Processes 16-bit signed value in AX.
;
		public	sl_itoam
sl_itoam	proc	far
		push	cx
		mov	cx, 7		;Max 7 chars.
		call	sl_malloc
		pop	cx
		jnc	GotoITOA
		ret
GotoITOA:	jmp	sl_itoa
sl_itoam	endp
;
;
stdlib		ends
		end