StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn   sl_putc:far, sl_LSize:far, sl_ULSize:far
;
; Putl prints the value in DX:AX as a signed dword integer value.
;
		public  sl_putlsize
sl_Putlsize     proc    far
		push	ax
		push	bx
		push	cx
		push    dx
		push    ax
		call    sl_LSize
		sub     cx, ax
		js      NoSpcs
		jcxz    NoSpcs
		mov     al, ' '
PutSpcs:        call    sl_Putc
		loop    PutSpcs
;
NoSpcs:         pop     ax
		cmp     dx, 0
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
		pop	cx 
		pop	bx 
		pop	ax
		ret
sl_Putlsize     endp
;
; Putul prints the value in DX:AX as an unsigned dword integer value.
;
		public	sl_PutULSize
sl_PutULSize	proc	far
		push	ax 
		push	bx 
		push	cx 
		push    dx
		push    ax
		call    sl_ULSize
		sub     cx, ax
		js      NoSpcs2
		jcxz    NoSpcs2
		mov     al, ' '
PutSpcs2:       call    sl_Putc
		loop    PutSpcs2
NoSpcs2:        pop     ax
;
		call	PutI2
		pop	dx 
		pop	cx 
		pop	bx 
		pop	ax
		ret
sl_PutULSize	endp
;
; PutI2- Recursive routine to actually print the value in AX as an integer.
;
Puti2		proc	near
		call	Div10
		cmp	ax, dx		;See if dx:ax=0
		jnz	NotDone
		or	ax, ax
		jz	Done
NotDone:	push	bx
		call	Puti2
		pop	bx
Done:		mov	al, bl
		or	al, '0'
		call	sl_Putc
		ret
PutI2		endp
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
