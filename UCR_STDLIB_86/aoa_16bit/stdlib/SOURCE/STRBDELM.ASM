StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp

		extrn	sl_strdup:far
;
; strBDelm-	Removes leading blanks from a string and stores this string
;		on the heap.
;
; inputs:
;		es:di-	Zero-terminated source string.
;
; outputs:	es:di-	Points at destination string (allocated on heap).
;		carry-	Set if memory manager error, clear otherwise.
;
; Written by Randall Hyde 11/13/92


		public	sl_strbdelm

sl_strbdelm	proc	far


		dec	di
WhlBlank:	inc	di
		cmp	byte ptr es:[di], ' '
		je	WhlBlank
		call	sl_strdup

		ret
sl_strbdelm	endp

stdlib		ends
		end
