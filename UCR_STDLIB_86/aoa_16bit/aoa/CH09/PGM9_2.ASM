; Pgm9_2.ASM
;
; This program demonstrates DeMorgan's theorems and
; various other logical computations.


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'


; Boolean input variables for the various functions
; we are going to test.

a		byte	0
b		byte	0


dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Get0or1-	Reads a "0" or "1" from the user and returns its
;		its value in the AX register.

get0or1		textequ	<call _get0or1>
_get0or1	proc
		push	es
		push	di

		getsm
		atoi
		free

		pop	di
		pop	es
		ret
_get0or1	endp




Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


		print
		byte	"Demorgan's Theorems",cr,lf
		byte	"-------------------",cr,lf
		byte	lf
		byte	"According to Demorgan's theorems, all results "
		byte	"between the dashed lines",cr,lf
		byte	"should be equal.",cr,lf
		byte	lf
		byte	"Enter a value for a: ",0

		get0or1
		mov	a, al

		print
		byte	"Enter a value for b: ",0
		get0or1
		mov	b, al


		print
                byte	"---------------------------------",cr,lf
		byte	"Computing not (A and B): ",0

		mov	ah, 0
		mov	al, a
		and	al, b
		xor	al, 1		;Logical NOT operation.

		puti
		putcr

		print
		byte	"Computing (not A) OR (not B): ",0
		mov	al, a
		xor	al, 1
		mov	bl, b
		xor	bl, 1
		or	al, bl
		puti

		print
		byte	cr,lf
		byte	"---------------------------------",cr,lf
		byte	"Computing (not A) OR B: ",0
		mov	al, a
		xor	al, 1
		or	al, b
		puti

		print
		byte	cr,lf
		byte	"Computing not (A AND (not B)): ",0
		mov	al, b
		xor	al, 1
		and	al, a
		xor	al, 1
		puti

		print
		byte	cr,lf
		byte	"---------------------------------",cr,lf
		byte	"Computing (not A) OR B: ",0
		mov	al, a
		xor	al, 1
		or	al, b
		puti

		print
		byte	cr,lf
		byte	"Computing not (A AND (not B)): ",0
		mov	al, b
		xor	al, 1
		and	al, a
		xor	al, 1
		puti

		print
		byte	cr,lf
		byte	"---------------------------------",cr,lf
		byte	"Computing not (A OR B): ",0
		mov	al, a
		or	al, b
		xor	al, 1
		puti

		print
		byte	cr,lf
		byte	"Computing (not A) AND (not B): ",0
		mov	al, a
		xor	al, 1
		and	bl, b
		xor	bl, 1
		and	al, bl
		puti

		print
		byte	cr,lf
		byte	"---------------------------------",cr,lf
		byte	0




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
