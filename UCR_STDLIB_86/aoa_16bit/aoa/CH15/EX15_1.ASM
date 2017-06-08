; EX15_1.asm
;
; This program demonstrates the proper use of the 80x86 string instructions.

		.386
		option		segment:use16

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

Buffer1		byte	2048 dup (0)
Buffer2		byte	2048 dup (0)

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


; Demo of the movsb, movsw, and movsd instructions

		print
		byte	"The following code moves a block of 2,048 bytes "
		byte	"around 100,000 times.",cr,lf
		byte	"The first phase does this using the movsb "
		byte	"instruction; the second",cr,lf
		byte	"phase does this using the movsw instruction; "
		byte	"the third phase does",cr,lf
		byte	"this using the movsd instruction.",cr,lf,lf,lf
		byte	"Press any key to begin phase one:",0

		getc
		putcr

		mov	edx, 100000

movsbLp:	lea	si, Buffer1
		lea	di, Buffer2
		cld
		mov	cx, 2048
	rep	movsb
		dec	edx
		jnz	movsbLp

		print
		byte	cr,lf
		byte	"Phase one complete",cr,lf,lf
		byte	"Press any key to begin phase two:",0

		getc
		putcr

		mov	edx, 100000

movswLp:	lea	si, Buffer1
		lea	di, Buffer2
		cld
		mov	cx, 1024
	rep	movsw
		dec	edx
		jnz	movswLp

		print
		byte	cr,lf
		byte	"Phase two complete",cr,lf,lf
		byte	"Press any key to begin phase three:",0

		getc
		putcr

		mov	edx, 100000

movsdLp:	lea	si, Buffer1
		lea	di, Buffer2
		cld
		mov	cx, 512
	rep	movsd
		dec	edx
		jnz	movsdLp


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
