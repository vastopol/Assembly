; Sample variable declarations
; This sample file demonstrates how to declare and access some single
; dimension array variables in an assembly language program.
;
; Randall Hyde


		.386			;Need to use some 80386 addressing
		option	segment:use16	; modes.

dseg		segment	para public 'data'

J		word	?
K		word	?
L		word	?
M		word	?

JD		dword	0
KD		dword	1
LD		dword	2
MD		dword	3

; Some simple uninitialized array declarations:

ByteAry		byte	4 dup (?)
WordAry		word	4 dup (?)
DwordAry	dword	4 dup (?)
RealAry		real8	4 dup (?)


; Some arrays with initialized values:

BArray		byte	0, 1, 2, 3
WArray		word	0, 1, 2, 3
DWArray		dword	0, 1, 2, 3
RArray		real8	0.0, 1.0, 2.0, 3.0


; An array of pointers:

PtrArray	dword	ByteAry, WordAry, DwordAry, RealAry

dseg		ends





; The following program demonstrates how to access each of the above
; variables.

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.


; Initialize the index variables.  Note that these variables provide
; logical indices into the arrays.  Don't forget that we've got to
; multiply these values by the element size when accessing elements of
; an array.

		mov	J, 0
		mov	K, 1
		mov	L, 2
		mov	M, 3

; The following code shows how to access elements of the arrays using
; simple 80x86 addressing modes:

		mov	bx, J		;AL := ByteAry[J]
		mov	al, ByteAry[bx]

		mov	bx, K		;AX := WordAry[K]
		add	bx, bx		;Index*2 since this is a word array.
		mov	ax, WordAry[bx]

		mov	bx, L		;EAX := DwordAry[L]
		add	bx, bx		;Index*4 since this is a double
		add	bx, bx		; word array.
		mov	eax, DwordAry[bx]

		mov	bx, M		;BX := address(RealAry[M])
		add	bx, bx		;Index*8 since this is a quad
		add	bx, bx		; word array.
		add	bx, bx
		lea	bx, RealAry[bx]	;Base address + index*8.


; If you have an 80386 or later CPU, you can use the 386's scaled indexed
; addressing modes to simplify array access.


		mov	ebx, JD
		mov	al, ByteAry[ebx]

		mov	ebx, KD
		mov	ax, WordAry[ebx*2]

		mov	ebx, LD
		mov	eax, DwordAry[ebx*4]

		mov	ebx, MD
		lea	bx, RealAry[ebx*8]



Quit:		mov	ah, 4ch		;Magic number for DOS
		int	21h		; to tell this program to quit.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
