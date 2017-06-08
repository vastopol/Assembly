; Example of a reasonably well-formatted program.


dseg		segment	para public 'data'

; Some type definitions for the variables we will declare:

uint		typedef	word		;Unsigned integers.
integer		typedef	sword		;Signed integers.


; Some variables we can use:

j		integer	?
k		integer	?
l		integer	?

u1      	uint	?
u2		uint	?
u3		uint	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Initialize our variables:

		mov	j, 3
		mov	k, -2

		mov	u1, 254
		mov	u2, 22

; Compute L := j+k and u3 := u1+u2

		mov	ax, J
		add	ax, K
		mov	L, ax

		mov	ax, u1		;Note that we use the "ADD"
		add	ax, u2		; instruction for both signed
		mov	u3, ax		; and unsigned arithmetic.


Quit:		mov	ah, 4ch		;DOS opcode to quit program.
		int	21h		;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
