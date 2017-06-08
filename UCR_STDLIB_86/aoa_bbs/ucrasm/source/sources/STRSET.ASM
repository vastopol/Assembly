StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strset- Copies the character in al over the top of each character in the
;	  string the es:si points at.  Does not affect the trailing zero
;	  byte in the string.
;
; inputs:
;
;	AL-	Character to copy.
;	ES:DI-  Points at string to overwrite.
;
;
;
;
		public	sl_strset
;
sl_strset	proc	far
		pushf
		push	di
		push	ax
;
		cld
		mov	ah, 0			;Zero terminating byte
		jmp	short StartLp
;
SetLp:		stosb				;Store next char
StartLp:	cmp	ah, es:[di]		;End of string?
		jnz	SetLp
;
		pop	ax
		pop	di
		popf
		ret
sl_strset	endp
;
;
;
;
stdlib		ends
		end
