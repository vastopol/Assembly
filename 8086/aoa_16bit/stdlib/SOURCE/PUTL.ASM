StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_putc:far
;
; Putl prints the value in DX:AX as a signed dword integer value.
;
		public	sl_putl
sl_Putl		proc	far
		push	ax
		push	bx
		cmp	dx, 0
		jge	Doit
		push	ax
		mov	al, '-'
		call	sl_Putc
		pop	ax
		neg	dx
		neg	ax
		sbb	dx, 0
;
DoIt:		call	puti2
		pop	dx
		pop	ax
		ret
sl_Putl		endp
;
; Putul prints the value in DX:AX as an unsigned dword integer value.
;
		public	sl_PutUL
sl_PutUL	proc	far
		push	ax
		push	dx
		call	PutI2
		pop	dx
		pop	ax
		ret
sl_PutUL	endp
;
; Puti2- Iterative routine to print a 32-bit unsigned value.
;	 This code was suggested by terge m and david holm.
;
Puti2		proc
		push	bx
		push	cx
		push	di
		mov	bx, dx
		mov	di, 10
		xor	cx, cx
		jmp	TestBX
;
Puti2Lp32:	xchg	ax, bx
		xor	dx, dx
		div	di
		xchg	ax, bx
		div	di
		add	dl, '0'
		push	dx
		inc	cx
TestBX:		or	bx, bx
		jnz	Puti2Lp32
;
Puti2Lp2:	xor	dx, dx
		div	di
		add	dl, '0'
		push	dx
		inc	cx
		or	ax, ax
		jnz	Puti2Lp2
;
PrintEm:	pop	ax
		call	sl_putc
		loop	PrintEm
		pop	di
		pop	cx
		pop	bx
		ret
Puti2		endp
stdlib		ends
		end
