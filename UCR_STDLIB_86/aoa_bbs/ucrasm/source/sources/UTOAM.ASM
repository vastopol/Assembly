StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far, sl_utoa:far, sl_itoa:far
;
; UTOAM-
;		These routines convert the value in AX to a string
;		of digits.  They automatically allocate storage on the
;		heap for their results and return a pointer to the new
;		string in ES:DI.
;
;		These routines return the carry set if there was a memory
;		allocation error (insufficient room on heap).
;
;
; UTOAM- 	Processes 16-bit unsigned value in AX.
;
		public	sl_utoam
sl_utoam	proc	far
		push	cx
		mov	cx, 6		;Maximum 6 chars.
		call	sl_malloc
		pop	cx
		jnc	GotoUTOA
		ret
GotoUTOA:	jmp	sl_utoa
sl_utoam	endp
;
;
stdlib		ends
		end