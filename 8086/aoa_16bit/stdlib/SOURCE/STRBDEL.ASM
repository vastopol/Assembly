
StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strBDel-	Removes leading blanks from a string.
;
; inputs:
;		es:di-	Zero-terminated source string.
;
; outputs:	es:di-	Points at destination string.
;
; Written by Randall Hyde 11/13/92


		public	sl_strbdel

sl_strbdel	proc	far
		push	ds
		push	ax
		push	di
		push	si
		mov	ax, es
		mov	ds, ax

		mov	al, ' '
		cmp	al, [di]		;Any leading blanks?
		jne	StrBDDone

		mov	si, di
WhlBlank:	lodsb
		cmp	al, ' '
		je	WhlBlank

WhlNotZero:	stosb
		cmp	al, 0
		lodsb
		jne	WhlNotZero

StrBDDone:	pop	si
		pop	di
		pop	ax
		pop	ds
		ret
sl_strbdel	endp

stdlib		ends
		end
