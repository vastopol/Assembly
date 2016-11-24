StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn   sl_putc:far, sl_ISize:far, sl_USize:far
;
; Puti prints the value in AX as a signed integer value.  CX contains the
; minimum field width for the number.
;
		public  sl_PutiSize
sl_PutiSize     proc    far
		push    ax
		push    bx
		push    cx
		push    dx
		push    ax
		call    sl_ISize
		sub     cx, ax
		js      NoSpaces
		jcxz    NoSpaces
		mov     al, ' '
SpcsLoop:       call    sl_Putc
		loop    SpcsLoop
NoSpaces:       pop     ax
		cmp	ax, 0
		jge	Doit
		push	ax
		mov	al, '-'
		call	sl_Putc
		pop	ax
		neg	ax
;
DoIt:		call	puti2
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret
sl_PutiSize     endp
;
; Putu prints the value in AX as an unsigned integer value.
;
		public  sl_PutUSize
sl_PutUSize     proc    far
		push    ax
		push    bx
		push    cx
		push    dx
		push    ax
		call    sl_USize
		sub     cx, ax
		js      NoUSpaces
		jcxz    NoUSpaces
		mov     al, ' '
SpcsLp2:        call    sl_Putc
		loop    SpcsLp2
NoUSpaces:      pop     ax
		call	PutI2
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret
sl_PutUSize     endp
;
; PutI2- Recursive routine to actually print the value in AX as an integer.
;
Puti2		proc	near
		mov	bx, 10
		xor	dx, dx
		div	bx
		or	ax, ax		;See if ax=0
		jz	Done
		push	dx
		call	Puti2
		pop	dx
Done:		mov	al, dl
		or	al, '0'
		call	sl_Putc
		ret
PutI2		endp
stdlib		ends
		end
