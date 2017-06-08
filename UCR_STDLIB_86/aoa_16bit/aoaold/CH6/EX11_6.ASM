; Type Operators

		.386
		option	segment:use16

dseg		segment	para public 'data'

MyRec		struct
a		word	?
b		byte	?
d		dword	?
MyRec		ends

J		word	1
K		word	2

; Note the use of equates to define the array
; dimensions.  This code can use the values of
; these equates to compute the index into the
; array.  In the future, it is easy to modify
; this code by simply changing the equates.

Dim1		=	8
Dim2		=	6

MRArray		MyRec	Dim1 dup (Dim2 dup ({}))


dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Load AX with the segment and offset of
; the address of MRArray.  These two instructions
; use the immediate addressing mode.

		mov	ax, offset MRArray
		mov	ax, seg MRARRAY

; Compute address of MRArray[J,K]
; adrs := (J*Dim2 + K) * sizeof(MyRec)

		mov	bx, J
		imul	bx, Dim2
		add	bx, K
		imul	bx, sizeof MyRec

Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
