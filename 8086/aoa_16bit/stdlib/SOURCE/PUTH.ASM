StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
; Contains modifications suggested by David Holm, 10/22/91
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_Putc:far
;
;
; Puth- Outputs value in AL as two hex digits.
;
		public	sl_Puth
sl_Puth		proc	far
		push	ax
		mov	ah, al
		shr	al, 1
		shr	al, 1
		shr	al, 1
		shr	al, 1
		cmp	al, 0ah		;Sequence provided by David Holm
		sbb	al, 69h		; which converts 0-F to "0"-"F"
		das			; ...
		call	sl_Putc
		mov	al, ah
		and	al, 0fh
		cmp	al, 0ah		; As above
		sbb	al, 69h		;
		das			;
		call	sl_Putc
		pop	ax
		ret
sl_Puth		endp
;
; Putw- Outputs word in AX as four hexadecimal digits:
;
		public	sl_Putw
sl_Putw		proc	far
		xchg	al, ah
		call	sl_Puth
		xchg	al, ah
		jmp	sl_Puth
sl_Putw		endp
;
stdlib		ends
		end
