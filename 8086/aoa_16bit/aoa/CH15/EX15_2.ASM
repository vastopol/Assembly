; EX15_2.asm
;
; This program compares the performance of the MOVS instruction against
; a manual block move operation.  It also compares MOVS against a LODS/STOS
; loop.

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


; MOVSB version done here:

		print
		byte	"The following code moves a block of 2,048 bytes "
		byte	"around 100,000 times.",cr,lf
		byte	"The first phase does this using the movsb "
		byte	"instruction; the second",cr,lf
		byte	"phase does this using the lods/stos instructions; "
		byte	"the third phase does",cr,lf
		byte	"this using a loop with MOV instructions.",cr,lf,lf,lf
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

LodsStosLp:	lea	si, Buffer1
		lea	di, Buffer2
		cld
		mov	cx, 2048
lodsstoslp2:	lodsb
		stosb
		loop	LodsStosLp2
		dec	edx
		jnz	LodsStosLp

		print
		byte	cr,lf
		byte	"Phase two complete",cr,lf,lf
		byte	"Press any key to begin phase three:",0

		getc
		putcr

		mov	edx, 100000

MovLp:		lea	si, Buffer1
		lea	di, Buffer2
		cld
		mov	cx, 2048
MovLp2:		mov	al, ds:[si]
		mov	es:[di], al
		inc	si
		inc	di
		loop	MovLp2
		dec	edx
		jnz	MovLp


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
