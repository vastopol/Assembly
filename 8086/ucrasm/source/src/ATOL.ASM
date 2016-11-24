StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; ATOL-	Converts the string pointed at by ES:DI to a signed long integer value
;	and returns this integer in the DX:AX registers.
;
;	Returns with the carry flag clear if no error, set if overflow.
;
		public	sl_atol
sl_atol		proc	far
		push	di
		call	far ptr sl_atol2
		pop	di
		ret
sl_atol		endp
;
;
		public	sl_atol2
sl_atol2	proc	far
		push	cx
		xor	cx, cx
		mov	dx, cx
		mov	ah, ch				;Assume it's positive
		cmp	byte ptr es:[di], '-'
		jne	DoAtoI
;
; Set up for negative numbers.
;
		inc	di				;Skip "-"
		mov	ah, 1				;Flag negative value.
;
DoAtoI:		call	NAtoI
		jc	WasError			;Quit if error.
		cmp	ah, 0
		je	IsPositive
		neg	dx
		neg	cx
		sbb	dx, 0
		clc
		jmp	WasError			;Not really an error.
;
IsPositive:	or	cx, cx				;See if overflow
		clc
		jns	WasError			;Not an error
                stc					;Error if negative.
WasError:	mov	ax, cx
		pop	cx
		ret
sl_atol2	endp
;
;
;
; ATOUL-	Just like ATOL but this guy only does unsigned numbers.
;
		public	sl_atoul
sl_atoul	proc	far
		push	di
		call	far ptr sl_atoul2
		pop	di
		ret
sl_atoul	endp
;
;
		public	sl_atoul2
sl_atoul2	proc	far
		push	cx
		xor	cx, cx
		mov	dx, cx
		call	NAtoI
		mov	ax, cx
		pop	cx
		ret
sl_atoul2	endp
;
;
;
;
NAtoI		proc	near
		push	bx
		push	si
		pushf
		cld
;
lp:		mov	al, es:[di]		;Get byte at es:si
		inc	di
		xor	al, '0'
		cmp	al, 10
		ja	NotDigit
		shl	cx, 1
		rcl	dx, 1
		jc	Error
		mov	bx, cx
		mov	si, dx
		shl	cx, 1
		rcl	dx, 1
		jc	Error
		shl	cx, 1
		rcl	dx, 1
		jc	Error
		add	cx, bx
		adc	dx, si
		jc	Error
		add	cl, al
		adc	ch, 0
		adc	dx, 0
		jc	Error
		jmp	lp
;
NotDigit:	popf
		pop	si
		pop	bx
		clc
		ret
;
Error:		popf
		pop	si
		pop	bx
		stc
		ret
NAtoI		endp
;
stdlib		ends
		end
