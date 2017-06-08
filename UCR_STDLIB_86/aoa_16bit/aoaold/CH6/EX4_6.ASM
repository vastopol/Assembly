; Examples of constants within a program:


dseg		segment	para public 'data'

; Equates must appear before you use their values.  They do not,
; however, need to be in the data segment.

ArraySize	equ	10

Array		word	ArraySize dup (?)
ASVar		word	ArraySize		;Init this var to 10.

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax


; Simple loop that sets each element of "Array" to zero.

		mov	cx, ArraySize
		mov	bx, 0
LoopHere:	mov	Array[bx], 0		;Zero out each element.
		add	bx, 2			;Each element is two bytes.
		loop	LoopHere		;Repeat "ArraySize" times.

; Another way to do the same thing:

ABX		textequ	<Array[bx]>

		mov	cx, ArraySize
		mov	bx, 0
LoopHere2:	mov	ABX, 0
		add	bx, 2
		loop	LoopHere


Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
