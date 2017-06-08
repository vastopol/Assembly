		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'
Varb		byte	0
Varw		word	9876h
Vard		dword	12345678h
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Puthl- Outputs the double word in DX:AX.

Puthl		proc	near

		xchg	ax, dx
		putw
		xchg	ax, dx
		putw
		ret
Puthl    	endp

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		mov	ax, Varb
		putw
		putcr

		mov	dx, Vard
		mov	ax, Varw
		call	Puthl
		putcr

		les	di, Varw

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
