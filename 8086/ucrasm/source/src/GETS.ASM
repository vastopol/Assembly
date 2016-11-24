StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_putc:far, sl_getc:far
;
;
; GETS-	Reads a line of text from the user and stores the characters into
;	the buffer pointed at by ES:DI.  The string must be large enough
;	to hold the result.
;
;	The returned string is zero terminated and does not include the
;	carriage return (ENTER) key code.
;
; Released to the public domain.
; Created by: Randall Hyde
; Date: 10/5/91
; Updates:
;
;	10/5/91-	Modified original GETS (GETSM) routine to produce
;			this one.
;
;
;
;
		public	sl_gets
sl_gets		proc	far
		push	es
		push	ax
		push	bx
		push	cx
		push	di
		pushf
;
; Read data from keyboard until the user hits the enter key.
;
		xor	bx, bx
RdKbdLp:	call	sl_getc
		jc	BadGetc
		cmp	ah, 0
		jz	EndString
		cmp	al, 0				;Scan code?
		jnz	GotKey				;If so, ignore it.
		call	sl_getc
		jmp	RdKbdLp
;
GotKey:		cmp	al, 08				;Backspace
		jne	NotBS
		or	bx, bx 				;Don't do it if at
		jz	RdKbdLp				; beginning of line.
		dec	bx
		call	sl_putc
		jmp	RdKbdLp
;
NotBS:		cmp	al, 13				;See if ENTER.
		jnz	NotCR
		call	sl_putc
		mov	al, 0ah
		call	sl_putc
		mov	byte ptr es:[bx][di], 0
		inc	bx
		jmp	GetsDone
;
NotCR:		cmp	al, 1bh				;ESC
		jne	NotESC
		mov	al, 8
EraseLn:	call	sl_putc
		dec	bx
		jne	EraseLn
		jmp	RdKbdLp
;
NotESC:		mov	es:[bx][di], al
		call	sl_putc
		inc	bx
		cmp	bx, 255
		jb	RdKbdLp
		mov	al, 7				;Bell
		call	sl_putc
		dec	bx
		jmp	RdKbdLp
;
; Deallocate any left over storage:
;
GetsDone:	popf
		clc
		pop	di
		pop     cx
		pop	bx
		pop	ax
		pop	es
		ret
;
EndString:	mov	ax, 0			;End of file.
		jmp	short BadGetc
;
BadGets:	mov	ax, 1			;Memory allocation error.
BadGetc:	popf
		pop	di
		pop	cx
		pop	bx
		add	sp, 2			;Don't restore AX.
		pop	es
		stc				;Pass error status.
		ret
sl_gets		endp
stdlib		ends
		end
