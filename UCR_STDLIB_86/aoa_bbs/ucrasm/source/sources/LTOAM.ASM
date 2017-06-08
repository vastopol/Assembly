StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far, sl_ltoa:far, sl_ultoa:far
;
;
;
; LTOAM-	Processes 32-bit signed value in DX:AX.
;
		public	sl_ltoam
sl_ltoam	proc	far
		push	cx
		mov	cx, 11		;Needs up to 11 chars.
		call	sl_malloc
		pop	cx
		jnc	GotoLTOA
		ret
GotoLTOA:	jmp	sl_ltoa
sl_ltoam	endp
;
;
; ULTOAM-	Processes 32-bit unsigned value in DX:AX.
;
		public	sl_ultoam
sl_ultoam	proc	far
		push	cx
		mov	cx, 11		;Needs up to 11 chars.
		call	sl_malloc
		pop	cx
		jnc	GotoULTOA
		ret
GotoULTOA:	jmp	sl_ultoa
sl_ultoam	endp
;
stdlib		ends
		end