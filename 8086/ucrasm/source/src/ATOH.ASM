StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; ATOH-	Converts the hexadecimal string pointed at by ES:DI to an integer
;	and returns it in the AX register.
;
;	Returns with the carry flag clear if no error, set if overflow.
;
; ATOH- preserves di.  ATOH2- Leaves di pointing at first char beyond
;	hex data.
;
		public	sl_atoh
sl_atoh		proc	far
		push	di
		call	far ptr sl_atoh2
		pop	di
		ret
sl_atoh		endp
;
		public	sl_atoh2
sl_atoh2	proc	far
		pushf
		cld
		push	cx
		xor	cx, cx
CnvrtLp:	mov	al, es:[di]
		inc	di
		cmp	al, 'a'
		jb	SkipConvert
		and	al, 5fh
;
SkipConvert:	xor	al, '0'
		cmp	al, 10
		jb	GotDigit
		add	al, 89h				;A->0fah.
		cmp	al, 0fah
		jb	Done
		and	al, 0fh				;0fa..0ff->a..f
GotDigit:	shl	cx, 1				;Make room for new
		jc	Overflow			; nibble.
		shl	cx, 1
                jc	Overflow
		shl	cx, 1
                jc	Overflow
		shl	cx, 1
		jc	Overflow
		or	cl, al				;Add in new nibble.
		jmp	CnvrtLp
;
Overflow:	stc
		jmp	short WasError
;
Done:		clc
WasError:	mov	ax, cx
		pop	cx
		popf
		ret
sl_atoh2	endp
;
;
; AtoLH - Converts a string of up to 8 hex digits into a long integer
;	  value and returns the result in DX:AX.
;
; AtoH- preserves di.  AtoH2- Returns with di pointing at the first char
;	beyond the string.
;
sl_atolh	proc	far
		push	di
		call	far ptr sl_atolh2
		pop	di
		ret
sl_atolh	endp
;
;
		public	sl_atolh2
sl_atolh2	proc	far
		pushf
		cld
		push	cx
		xor	cx, cx
                mov	dx, cx
CnvrtLp2:      	mov	al, es:[di]
		inc	di
		and	al, 05fh			;l.c. -> U.C.
		xor	al, '0'
		cmp	al, 10
		jb	GotDigit2
		add	al, 89h				;A->10.
		cmp	al, 0fah
		jb	Done2
		and	al, 0fh
GotDigit2:	shl	cx, 1				;Make room for new
		rcl	dx, 1                           ; nibble.
		jc	Overflow2
		shl	cx, 1
		rcl	dx, 1
		jc	Overflow2
		shl	cx, 1
		rcl	dx, 1
		jc	Overflow2
		shl	cx, 1
		rcl	dx, 1
		jc	Overflow2
		or	cl, al				;Add in new nibble.
		jmp	CnvrtLp2
;
Overflow2:	stc
		jmp	short WasError2
;
Done2:		clc
WasError2:	mov	ax, cx
		pop	cx
		popf
		ret
sl_atolh2	endp
;
;
;
;
stdlib		ends
		end
