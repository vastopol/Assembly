;
StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
;
PutcAdrs	dd	sl_putcstdout
PutcStkIndx	dw	0
PutcStk		dd	16 dup (sl_putcstdout)
PSIsize		=	$-PutcStk
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp,ds:nothing
;
;
;
; Putc- Sends the character in AL to the current output routine.
;	By default, this is "putstdout".  PutcAdrs contains the address of the
;	current output routine.
;
		public	sl_putc
sl_putc		proc	far
		jmp	dword ptr StdGrp:PutcAdrs
sl_putc		endp
;
;
;
;
; PutCR-	Prints a new line to the standard output device.
;
		public	sl_putcr
sl_putcr	proc	far
		push	ax
		mov	al, 13		;Carriage return
		call	dword ptr StdGrp:PutcAdrs
		mov	al, 10		;Line feed
		call	dword ptr StdGrp:PutcAdrs
		pop	ax
		ret
sl_putcr	endp
;
;
;
; PutStdOut- Prints the character in AL to the standard output device by
;	     calling DOS to print the character.
;
		public	sl_putcstdout
sl_putcstdout	proc	far
		push	ax
		push	dx
		mov	dl, al
		mov	ah, 2
		int	21h
		pop	dx
		pop	ax
		ret
sl_putcstdout	endp
;
;
; PutcBIOS-	Prints the character in AL by calling the BIOS output routine.
;
		public	sl_PutcBIOS
sl_PutcBIOS	proc	far
		push	ax
		mov	ah, 14
		int	10h
		pop	ax
		ret
sl_PutcBIOS	endp
;
;
; GetOutAdrs-	Returns the address of the current output routine in ES:DI.
;
		public	sl_GetOutAdrs
sl_GetOutAdrs	proc	far
		les	di, StdGrp:PutcAdrs
		ret
sl_GetOutAdrs	endp
;
;
; SetOutAdrs-	Stores the address in ES:DI into PutcAdrs.  This must be the
;		address of a valid output routine which outputs the character
;		in the AL register.  This routine must preserve all registers.
;
		public	sl_SetOutAdrs
sl_SetOutAdrs	proc	far
		mov	word ptr StdGrp:PutcAdrs, di
		mov	word ptr StdGrp:PutcAdrs+2, es
		ret
sl_SetOutAdrs	endp
;
;
;
; PushOutAdrs-	Pushes the current output address onto the output stack
;		and then stores the address in es:di into the output address
;		pointer.  Returns carry clear if no problems.  Returns carry
;		set if there is an address stack overflow.  Does NOT modify
;		anything if the stack is full.
;
		public	sl_PushOutAdrs
sl_PushOutAdrs	proc	far
		push	ax
		push	di
		cmp	StdGrp:PutcStkIndx, PSIsize
		jae	BadPush
		mov	di, StdGrp:PutcStkIndx
		add	StdGrp:PutcStkIndx, 4
		mov	ax, word ptr StdGrp:PutcAdrs
		mov	word ptr StdGrp:PutcStk[di], ax
		mov	ax, word ptr StdGrp:PutcAdrs+2
		mov	word ptr StdGrp:PutcStk+2[di], ax
		pop	di
		mov	word ptr StdGrp:PutcAdrs, di
		mov	word ptr StdGrp:PutcAdrs+2, es
		pop	ax
		clc
		ret
;
BadPush:	pop	di
		pop	ax
		stc
		ret
sl_PushOutAdrs	endp
;
;
; PopOutAdrs-	Pops an output address off of the stack and stores it into
;		the PutcAdrs variable.
;
		public	sl_PopOutAdrs
sl_PopOutAdrs	proc	far
		push	ax
		mov	di, StdGrp:PutcStkIndx
		sub	di, 4
		jns	GoodPop
;
; If this guy just went negative, set it to zero and push the address
; of the stdout routine onto the stack.
;
		xor	di, di			
		mov	word ptr StdGrp:PutcStk, offset stdgrp:sl_PutcStdOut
		mov	word ptr StdGrp:PutcStk+2, stdgrp
;
GoodPop:	mov	StdGrp:PutcStkIndx, di
		mov	es, word ptr PutcAdrs+2
		mov	ax, word ptr StdGrp:PutcStk+2[di]
		mov	word ptr StdGrp:PutcAdrs+2, ax
		mov	ax, word ptr StdGrp:PutcStk[di]
		xchg	word ptr StdGrp:PutcAdrs, ax
		mov	di, ax
		pop	ax
		ret
sl_PopOutAdrs	endp
;
stdlib		ends
		end
