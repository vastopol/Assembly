StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; Release 2.0 modifications 9/22/91, R. Hyde
; Created three versions of each routine: LTOA, LTOA2, and LTOAm
;
; LTOA-	converts the value in DX:AX to a string.  ES:DI points at the target
;	location.
;
; LTOA2-Like the routine above, except it does not preserve DI.  Leaves DI
;	pointing at the terminating zero byte.
;
		public	sl_ltoa
sl_ltoa		proc	far
		push	di
		call	far ptr sl_ltoa2
		pop	di
		ret
sl_ltoa		endp
;
		public	sl_ltoa2
sl_ltoa2	proc	far
		push	ax
		push	dx
;
		cmp	dx, 0
		jge	Doit
		mov	byte ptr es:[di], '-'
		inc	di
		neg	dx
		neg	ax
		sbb	dx, 0
;
DoIt:		call	puti4
		mov	byte ptr es:[di], 0
		clc				;Needed by sl_ltoam
		pop	dx
		pop	ax
		ret
sl_ltoa2	endp
;
;
;
; ULTOA converts the unsigned dword value in DX:AX to a string.
; ULTOA does not preserve DI, rather, it leaves DI pointing at the 0 byte.
;
		public	sl_ultoa
sl_ultoa	proc	far
		push	di
		call	far ptr sl_ultoa2
		pop	di
		ret
sl_ultoa	endp
;
;
		public	sl_ultoa2
sl_ultoa2	proc	far
		push	ax
		push	dx
		call	PutI4
		clc
		pop	dx
		pop	ax
		ret
sl_ultoa2	endp
;
;
;
; PutI4- Iterative routine to actually print the value in DX:AX as an integer.
;	 Suggested by terje m and david holm.
;
Puti4		proc
		push	bx
		push	cx
		push	si
		mov	bx, dx
		mov	si, 10
		xor	cx, cx
		jmp	TestBX
;
Puti2Lp32:	xchg	ax, bx
		xor	dx, dx
		div	si
		xchg	ax, bx
		div	si
		add	dl, '0'
		push	dx
		inc	cx
TestBX:		or	bx, bx
		jnz	Puti2Lp32
;
Puti2Lp2:	xor	dx, dx
		div	si
		add	dl, '0'
		push	dx
		inc	cx
		or	ax, ax
		jnz	Puti2Lp2
;
PrintEm:	pop	ax
		stosb
		loop	PrintEm
		mov	byte ptr es:[di], 0
		pop	si
		pop	cx
		pop	bx
		ret
Puti4		endp
;
stdlib		ends
		end
