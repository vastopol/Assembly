; Arrays of Structures
;
; Randall Hyde


dseg		segment	para public 'data'


; A structure that defines an (x,y) coordinate.
; Note that the Point data type requires four bytes.

Point		struct
X		word	?
Y		word	?
Point		ends



; An uninitialized point:

Pt1		Point	{}

; An initialized point:

Pt2		Point	{12,45}


; A one-dimensional array of uninitialized points:

PtAry1		Point	16 dup ({})	;Note the "{}" inside the parens.


; A one-dimensional array of points, all initialized to the origin.

PtAry1i		Point	16 dup ({0,0})


; A two-dimensional array of points:

PtAry2		Point	4 dup (4 dup ({}))


; A three-dimensional array of points, all initialized to the origin.

PtAry3		Point	2 dup (3 dup (4 dup ({0,0})))



; A one-dimensional array of points, all initialized to different values:

iPtAry		Point	{0,0}, {1,2}, {3,4}, {5,6}


; Some indices for the arrays:

J		word	1
K		word	2
L		word	3

dseg		ends





; The following program demonstrates how to access each of the above
; variables.

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.

; PtAry1[J] := iPtAry[J]

		mov	bx, J		;Index := J*4 since there are four
		add	bx, bx		; bytes per array element (each
		add	bx, bx		; element contains two words).

		mov	ax, iPtAry[bx].X
		mov	PtAry1[bx].X, ax

		mov	ax, iPtAry[bx].Y
		mov	PtAry1[bx].Y, ax

; CX := PtAry2[K,L].X;  DX := PtAry2[K,L].Y

		mov	bx, K		;Index := (K*4 + J)*4
		add	bx, bx		;K*2
		add	bx, bx		;K*4
		add	bx, J		;K*4 + J
		add	bx, bx		;(K*4 + J)*2
		add	bx, bx		;(K*4 + J)*4

		mov	cx, PtAry2[bx].X
		mov	dx, PtAry2[bx].Y

; PtAry3[j,k,l].X := 0

		mov	ax, j		;Index := ((j*3 +k)*4 + l)*4
		mov	bx, 3
		mul	bx		;j*3
		add	ax, k		;j*3 + k
		add	ax, ax		;(j*3 + k)*2
		add	ax, ax		;(j*3 + k)*4
		add	ax, l		;(j*3 + k)*4 + l
		add	ax, ax		;((j*3 + k)*4 + l)*2
		add	ax, ax		;((j*3 + k)*4 + l)*4
		mov	bx, ax
		mov	PtAry3[bx].X, 0

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
