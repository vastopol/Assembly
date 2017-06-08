; Multidimensional Array declaration and access
;
; Randall Hyde


		.386			;Need these two statements to use
		option	segment:use16	; 80386 register set.


dseg		segment	para public 'data'


; Indices we will use for the arrays.

J		word	1
K		word	2
L		word	3

; Some two-dimensional arrays.
; Note how this code uses the "dup" operator to suggest the size
; of each dimension.

B2Ary		byte	3 dup (4 dup (?))
W2Ary		word	4 dup (3 dup (?))
D2Ary		dword	2 dup (6 dup (?))



; 2D arrays with initialization.
; Note the use of data layout to suggest the sizes of each array.

B2Ary2		byte	0, 1, 2, 3
		byte	4, 5, 6, 7
		byte	8, 9, 10, 11

W2Ary2		word	0,  1,  2
		word	3,  4,  5
		word	6,  7,  8
		word	9, 10, 11

D2Ary2		dword	0,  1,  2,  3,  4,  5
		dword	6,  7,  8,  9, 10, 11


; A sample three dimensional array.

W3Ary		word	2 dup (3 dup (4 dup (?)))

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.


; AL := B2Ary2[j,k]

		mov	bx, J		;index := (j*4+k)
		add	bx, bx		;j*2
		add	bx, bx		;j*4
		add	bx, K		;j*4+k
		mov	al, B2Ary2[bx]


; AX := W2Ary2[j,k]

		mov	ax, J		;index := (j*3 + k)*2
		mov	bx, 3
		mul	bx		;(j*3)-- This destroys DX!
		add	ax, k		;(j*3+k)
		add	ax, ax		;(j*3+k)*2
		mov	bx, ax
		mov	ax, W2Ary2[bx]


; EAX := D2Ary[i,j]

		mov	ax, J		;index := (j*6 + k)*4
		mov	bx, 6
		mul	bx		;DX:AX := j*6, ignore overflow in DX.
		add	ax, k		;j*6 + k
		add	ax, ax		;(j*6 + k)*2
		add	ax, ax		;(j*6 + k)*4
		mov	bx, ax
		mov	eax, D2Ary[bx]


; Sample access of a three dimensional array.
;
; AX := W3Ary[J,K,L]

		mov	ax, J		;index := ((j*3 + k)*4 + l)*2
		mov	bx, 3
		mul	bx		;j*3
		add	ax, K		;j*3 + k
		add	ax, ax		;(j*3 + k)*2
		add	ax, ax		;(j*3 + k)*4
		add	ax, l		;(j*3 + k)*4 + l
		add	ax, ax		;((j*3 + k)*4 + l)*2
		mov	bx, ax
		mov	ax, W3Ary[bx]


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
