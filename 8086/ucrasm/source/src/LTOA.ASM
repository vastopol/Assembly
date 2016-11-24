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
		push	bx
		push	cx
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
		pop	cx
		pop	bx
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
		push	bx
		push	cx
		push	dx
		call	PutI4
		clc
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
sl_ultoa2	endp
;
;
;
; PutI4- Recursive routine to actually print the value in DX:AX as an integer.
;
Puti4		proc	near
		call	Div10
		cmp	ax, dx		;See if dx:ax=0
		jnz	NotDone
		or	ax, ax
		jz	Done
NotDone:	push	bx
		call	Puti4
		pop	bx
Done:		mov	al, bl
		or	al, '0'
		mov	es:[di], al
		inc	di
		ret
PutI4 		endp
;
; Div10- Divides DX:AX by 10 leaving the remainder in BL and the quotient
;	 in DX:AX.
;
Div10		proc	near
		mov	cx, 10
		mov	bx, ax
		xchg	ax, dx
		xor	dx, dx
		div	cx
		xchg	bx, ax
		div	cx
		xchg	dx, bx
		ret
Div10		endp
stdlib		ends
		end
