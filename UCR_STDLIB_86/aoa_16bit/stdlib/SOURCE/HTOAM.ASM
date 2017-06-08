StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far,sl_htoa:far,sl_wtoa:far
;
;
;
; HTOAM-	Processes 8-bit hex value in AL.
;
		public	sl_htoam
sl_htoam	proc	far
		push	cx
		mov	cx, 3		;Needs exactly three chars.
		call	sl_malloc
		pop	cx
		jnc	GotoHTOA
		ret
GotoHTOA:	jmp	sl_htoa
sl_htoam	endp
;
;
; WTOAM-	Processes 16-bit hex value in AX.
;
		public	sl_wtoam
sl_wtoam	proc	far
		push	cx
		mov	cx, 5		;Needs exactly five chars.
		call	sl_malloc
		pop	cx
		jnc	GotoWTOA
		ret
GotoWTOA:	jmp	sl_wtoa
sl_wtoam	endp
;
;
stdlib		ends
		end