; Address Expressions.

		.386
		option	segment:use16

dseg		segment	para public 'data'

One		equ	1
Two		equ	2

Var1		word	?
Var2		word	?

; Note the values MASM initializes these
; variables with:

Var3		word	One+Two
Var4		word	Two*3 + 6

Var5		word	One eq 2
Var6		word	Two ne 1

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc	near
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Note the displacements for the following
; instructions:

		mov	ax, Var1
		mov	ax, Var1+1
		mov	ax, Var1+One

		mov	ax, Var2
		mov	ax, Var1+2

		lea	bx, Var1+2
		mov	ax, One+2[bx]

Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
