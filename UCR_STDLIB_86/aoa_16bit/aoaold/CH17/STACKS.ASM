		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

MaxStkSize	equ	256
StkPtr		word	0
TheStk		word	MaxStkSize dup (0)

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; InitStk-	Initializes the stack.

InitStk		proc
		mov	StkPtr, 0
		ret
InitStk		endp



; PushStk-	Pushes the integer in AX onto the stack.
;		Returns carry clear if the operation is successful.
;		Returns carry set if stack overflow (exceeding the
;		size of the stack) occurs.

PushStk		proc
		push	bx
		mov	bx, StkPtr
		cmp	bx, MaxStkSize	;Stack overflow occur?
		jae	BadStack
		mov	TheStk[bx], ax	;If not, push AX.
		add	bx, 2		;Two bytes per item pushed
		mov	StkPtr, bx	;Save the new SP value away
		pop	bx
		clc
		ret

BadStack:	pop	bx
		stc
		ret
PushStk		endp


; PopStk-	Pops the integer on TOS (top of stack ) into AX.
;		Returns carry clear if the operation is successful.
;		Returns carry set if stack underflow (attempting to pop
;		an item from an empty stack) occurs.

PopStk		proc
		push	bx
		mov	bx, StkPtr
		test	bx, bx	       		;BX = 0?
		je	StackUnderFlw		;Error if nothing here
		sub	bx, 2			;Two bytes per item
		mov	ax, TheStk[bx]		;Get the popped item.
		mov	StkPtr, bx		;Save new SP value.
		pop	bx
		clc
		ret

StackUnderFlw:	pop	bx
		stc
		ret
PopStk		endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; This program pushes 10 random integers onto the stack and them
; pops them off:

		randomize
		mov	cx, 10
PushLoop:	print
		byte	"Pushing ",0
		random
		puti
		putcr
		call	PushStk
		loop	PushLoop

		print
		byte	cr,lf
		byte	"The values in reversed order are",cr,lf,lf,0

PopLoop:	call	PopStk
		jc	PoppingDone
		puti
		putcr
		jmp	PopLoop
PoppingDone:

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
