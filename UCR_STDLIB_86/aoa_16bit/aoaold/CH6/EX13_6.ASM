; This sample program demonstrates some really tricky macros.
;
; It implements two dimensional array access and
; a for/next loop with macros.
;
; This is the second version, using the catstr and @catstr macro and
; macro function.


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list
		.386
		option		segment:use16


dseg		segment	para public 'data'

a		sword	16 dup (7 dup (?))
b		sword	16 dup (7 dup (2))
x		sword	7 dup (16 dup (?))

I		word	?
J		word	?

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

;****************************************************************************
;
; Array Index Support macros

ldax		macro	Array, RowIndex, ColIndex, instr

		imul	bx, RowIndex, (lengthof Array) / (length Array)
		add	bx, ColIndex
		add	bx, bx

		ifb	<instr>
		mov	ax, Array[bx]
		else
		instr	ax, Array[bx]
		endif
		endm


stax		macro	Array, RowIndex, ColIndex

		imul	bx, RowIndex, (lengthof Array) / (length Array)
		add	bx, ColIndex
		add	bx, bx
		mov	Array[bx], ax
		endm




;****************************************************************************
;
; For Loop Support macros



ForLp		macro	LCV, start, stop	;LCV="Loop Ctrl Var"
		local	ForLoop

		ifndef	$$For&LCV&
$$For&LCV&	=	0
		else
$$For&LCV&	=	$$For&LCV& + 1
		endif

;; Emit the instructions to initialize the loop control variable.

		mov	ax, Start
		mov	LCV, ax

;; Output Loop Label:

ForLoop		catstr	<$$For&LCV&>, %$$For&LCV&
&ForLoop&:

;; Output test to see if the loop is done:

		mov	ax, LCV
		cmp	ax, Stop
		jg	@catstr(<$$Next&LCV&>, %$$For&LCV&)
		endm




; Here is the NEXT macro:


Next		macro	LCV
		local	ForDone

		inc	LCV
		jmp	@catstr(<$$For&LCV&>, %$$For&LCV&)
ForDone		catstr	<$$Next&LCV&>, %$$For&LCV&
&ForDone&:
		endm

;****************************************************************************


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Initialize the A array to some arbitrary values.
; (B is already initialized)
;
; C version:
;
;	for (i=0; i<=15; ++i)
;	    for (j=0; j<=6; ++j)
;		a[i][j] = i+j;


		ForLp	I, 0, 15
		ForLp	J, 0, 6

		mov	ax, I
		add	ax, J
		stax	a, I, J

		Next	J
		Next	I

; Compute the values for the X array.
;
; C version:
;
;	for (i=0; i<=15; ++i)
;	    for (j=0; j<=6; ++j)
;		x[j][i] = a[i][j] * b[15-i][j];

		ForLp	I, 0, 15
		ForLp	J, 0, 6

		ldax	a, I, J
		mov	bx, 15
		sub	bx, I
		ldax	b, bx, J, imul
		stax	x, J, I

		Next	J
		Next	I


; Print the result:

		ForLp	I, 0, 6
		ForLp	J, 0, 15

		ldax	x, I, J
		mov	cx, 3
		putisize

		Next	J

		putcr

		Next	I


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
