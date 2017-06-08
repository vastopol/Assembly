; Note: uncomment the following statement for one
; of the assemblies.  Leave it commented out for
; the other.

;		.286

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'
I		word	1
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

shli		macro	operand, count
		if	(@CPU and 100b) ne 0
		shl	operand, count
		else
		repeat	count
		shl	operand,1
		endm
		endif
		endm

Main		proc
		mov	ax, dseg
		mov	ds, ax

		mov	ax, 1
		mov	bx, 0FFFFh
		mov	cl, 80h
		shli	ax, 4
		shli	I, 6
		shli	bx, 2
		shli	cl, 1



Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
