StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strtrim-	Removes trailing blanks from a string by moving the
;		terminating zero byte down in memory.
;
; inputs:
;		es:di-	Zero-terminated source string.
;
; outputs:	es:di-	Points at destination string.
;
; Written by Randall Hyde 11/12/92


		public	sl_strtrim

sl_strtrim	proc	far
		pushf
		push	ax
		push	cx
		push	di
		cld

		mov	cx, 0ffffh		;Allow any length string.
		mov	al, 0
		cmp	al, es:[di]		;Zero length string?
		je	StrTrimDone

	repne	scasb				;Find end of string.
		dec	di			;Back up one char (di is 2
		dec	di			; chars beyond the end).

		not	cx			;Only allow as many chars as
		dec	cx			; we started with.
		std
		mov	al, ' '
	repe	scasb
		inc	di
		inc	di
		cmp	al, es:[di]
		jne	StrTrimDone		;Only if no blanks at the end.
		mov	byte ptr es:[di], 0

StrTrimDone:	pop	di
		pop	cx
		pop	ax
		popf
		ret
sl_strtrim	endp

stdlib		ends
		end
