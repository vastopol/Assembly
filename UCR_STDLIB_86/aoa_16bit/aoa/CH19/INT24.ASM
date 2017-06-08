; Sample INT 24h critical error handler.
;
; This code demonstrates a sample critical error handler.
; It patches into INT 24h and displays an appropriate error
; message and asks the user if they want to retry, abort, ignore,
; or fail (just like DOS).

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

Value		word	0
ErrCode		word	0

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; A replacement critical error handler.  Note that this routine
; is even worse than DOS', but it demonstrates how to write
; such a routine.  Note that we cannot call any Standard Library
; I/O routines in the critical error handler because they do not
; use DOS calls 1-0Ch, which are the only allowable DOS calls at
; this point.


CritErrMsg	byte	cr,lf
		byte	"DOS Critical Error!",cr,lf
		byte	"A)bort, R)etry, I)gnore, F)ail? $"

MyInt24		proc	far
		push	dx
		push	ds
		push	ax

		push	cs
		pop	ds
Int24Lp:	lea	dx, CritErrMsg
		mov	ah, 9			;DOS print string call.
		int	21h

		mov	ah, 1			;DOS read character call.
		int	21h
		and	al, 5Fh			;Convert l.c. -> u.c.

		cmp	al, 'I'			;Ignore?
		jne	NotIgnore
		pop	ax
		mov	al, 0
		jmp	Quit24

NotIgnore:	cmp	al, 'r'			;Retry?
		jne	NotRetry
		pop	ax
		mov	al, 1
		jmp	Quit24

NotRetry:	cmp	al, 'A'			;Abort?
		jne	NotAbort
		pop	ax
		mov	al, 2
		jmp	Quit24

NotAbort:	cmp	al, 'F'
		jne	BadChar
		pop	ax
		mov	al, 3
Quit24:		pop	ds
		pop	dx
		iret

BadChar:	mov	ah, 2
		mov	dl, 7			;Bell character
		jmp	Int24Lp
MyInt24		endp



Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		mov	ax, 0
		mov	es, ax
		mov	word ptr es:[24h*4], offset MyInt24
		mov	es:[24h*4 + 2], cs

		mov	ah, 5
		mov	dl, 'a'
		int	21h
		rcl	Value, 1
		and	Value, 1
		mov	ErrCode, ax
		printf
		byte	cr,lf,lf
		byte	"Print char returned with error status %d and "
		byte	"error code %d\n",0
		dword	Value, ErrCode

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends



; Allocate a reasonable amount of space for the stack (8k).
; Note: if you use the pattern matching package you should set up a
;	somewhat larger stack.

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


; zzzzzzseg must be the last segment that gets loaded into memory!
; This is where the heap begins.

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
