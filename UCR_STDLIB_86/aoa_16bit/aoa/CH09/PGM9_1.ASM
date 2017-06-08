; Pgm9_1.ASM
;
; Several examples demonstrating how to convert various
; arithmetic expressions into assembly language.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

; Arbitrary variables this program uses.

u		word	?
v		word	?
w		word	?
x		word	?
y		word	?

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; GETI-	Reads an integer variable from the user and returns its
;	its value in the AX register.

geti		textequ	<call _geti>
_geti		proc
		push	es
		push	di

		getsm
		atoi
		free

		pop	di
		pop	es
		ret
_geti		endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


		print
		byte	"Abitrary expression program",cr,lf
		byte	"---------------------------",cr,lf
		byte	lf
		byte	"Enter a value for u: ",0

		geti
		mov	u, ax

		print
		byte	"Enter a value for v: ",0
		geti
		mov	v, ax

		print
		byte	"Enter a value for w: ",0
		geti
		mov	w, ax

		print
		byte	"Enter a non-zero value for x: ",0
		geti
		mov	x, ax

		print
		byte	"Enter a non-zero value for y: ",0
		geti
		mov	y, ax


; Okay, compute Z := (X+Y)*(U+V*W)/X and print the result.

		print
		byte	cr,lf
		byte	"(X+Y) * (U+V*W)/X is ",0

		mov	ax, v		;Compute V*W
		imul	w		; and then add in
		add	ax, u	      	; U.
		mov	bx, ax		;Save in a temp location for now.

		mov	ax, x		;Compute X+Y, multiply this
		add	ax, y		; sum by the result above,
		imul	bx		; and then divide the whole
		idiv	x		; thing by X.

		puti
		putcr

; Compute ((X-Y*U) + (U*V) - W)/(X*Y)

		print
		byte	"((X-Y*U) + (U*V) - W)/(X*Y) = ",0

		mov	ax, y		;Compute y*u first
		imul	u
		mov	dx, X		;Now compute X-Y*U
		sub	dx, ax
		mov	cx, dx		;Save in temp

		mov	ax, u		;Compute U*V
		imul	V
		add	cx, ax		;Compute (X-Y*U) + (U*V)

		sub	cx, w		;Compute ((X-Y*U) + (U*V) - W)

		mov	ax, x		;Compute (X*Y)
		imul	y

		xchg	ax, cx
		cwd			;Compute NUMERATOR/(X*Y)
		idiv	cx

		puti
		putcr



Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
