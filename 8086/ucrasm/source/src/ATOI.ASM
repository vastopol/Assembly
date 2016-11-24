StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; ATOI-	Converts the string pointed at by ES:DI to a signed integer value
;	and returns this integer in the AX register.
;
;	Returns with the carry flag clear if no error, set if overflow.
;
		public	sl_atoi
sl_atoi		proc	far
		push	di
		call	far ptr sl_atoi2
		pop	di
		ret
sl_atoi		endp
;
		public	sl_atoi2
sl_atoi2	proc	far
		push	cx
		push	dx
		xor	cx, cx
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
		neg	cx
		clc
		jmp	WasError			;Not really an error.
;
IsPositive:	or	cx, cx				;See if overflow
		clc
		jns	WasError			;Not an error
                stc					;Error if negative.
WasError:	mov	ax, cx
		pop	dx
		pop	cx
		ret
sl_atoi2	endp
;
;
;
; ATOU-	Just like ATOI but this guy only does unsigned numbers.
;
		public	sl_atou
sl_atou		proc	far
		push	di
		call	far ptr sl_atou2
		pop	di
		ret
sl_atou		endp
;
;
		public	sl_atou2
sl_atou2	proc	far
		push	cx
		push	dx
		xor	cx, cx
		call	NAtoI
		mov	ax, cx
		pop	dx
		pop	cx
		ret
sl_atou2	endp
;
;
;
;
NAtoI		proc	near
		pushf
		cld
;
lp:		mov	al, es:[di]		;Get byte at es:di
		inc	di
		xor	al, '0'
		cmp	al, 10
		ja	NotDigit
		shl	cx, 1
		jc	Error
		mov	dx, cx
		shl	cx, 1
		jc	Error
		shl	cx, 1
		jc	Error
		add	cx, dx
		jc	Error
		add	cl, al
		adc	ch, 0
		jc	Error
		jmp	lp
;
NotDigit:	dec	di		;Because we inc'd after non-digit.
		popf
		clc
		ret
;
Error:		popf
		stc
		ret
NAtoI		endp
;
stdlib		ends
		end
