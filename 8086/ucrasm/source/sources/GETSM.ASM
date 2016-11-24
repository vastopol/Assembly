StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far, sl_realloc:far, sl_free:far
		extrn	sl_putc:far, sl_getc:far
;
;
; GETSM-Reads a line of text from the user and returns a pointer to the
;	string read.  Returns the pointer in ES:DI.  Carry=0 if no error,
;	1 if heap overflow, EOF, or some other error (DOS).
;
;	The returned string is zero terminated and does not include the
;	carriage return (ENTER) key code.
;
; Note: This routine always allocates 256 bytes when you call
;	it.
;
; Released to the public domain.
; Created by: Randall Hyde
; Date: 7/90
; Updates:
;
;	8/11/90-	Modification to handle eof and other errors.
;	10/5/91-	Renamed to new naming conventions.
;
;
;
;
		public	sl_getsm
sl_getsm	proc	far
		push	ax
		push	bx
		push	cx
		pushf
;
; Allocate storage for return string:
;
		mov	cx, 256
		call	sl_malloc
		jc	BadGETS
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
GetsDone:	mov	cx, bx
		call	sl_realloc
		popf
		clc
		pop     cx
		pop	bx
		pop	ax
		ret
;
EndString:	mov	ax, 0			;End of file.
		call	sl_free			;Deallocate storage
		jmp	short BadGetsx
;
BadGetc:	call	sl_free
		jmp	short BadGetsx
;
BadGets:	mov	ax, 1			;Memory allocation error.
BadGetsx:	popf
		pop	cx
		pop	bx
		add	sp, 2			;Don't restore AX.
		stc				;Pass error status.
		ret
sl_getsm	endp
stdlib		ends
		end
