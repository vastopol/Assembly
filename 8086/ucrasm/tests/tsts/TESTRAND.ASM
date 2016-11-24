		include		stdlib.a
		includelib 	stdlib.lib
;
lesi		macro	adrs
		mov     di, seg adrs
		mov	es, di
		lea	di, adrs
		endm
;
ldxi		macro	adrs
		mov	dx, seg adrs
		lea	si, adrs
		endm
;
;****************************************************************************
;
; T  E  S  T       S  U  I  T  E      F  O  R
;
;
; R  A  N  D  Y      H  Y  D  E ' S     S  T  A  N  D  A  R  D
;
; L  I  B  R  A  R  Y     F  O  R     A  S  S  E  M  B  L  Y
;
; L  A  N  G  U  A  G  E     P  R  O  G  R  A  M  M  E  R  S
;
;****************************************************************************
;
;
; Global variables go here:
;
dseg		segment	para public 'data'
i		dw	?
j		dw	?
k		dw	?
dseg		ends
;
;
dseg		segment	para public 'data'
;
MemAvail	dw	?
;
dseg		ends
;
;
;
;
cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg
;
;
;
;
		public	PSP
PSP		dw	?
;
cr		equ	13
lf		equ	10
;
;
; Main is the main program.  Program execution always begins here.
;
Main		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
		mov	dx, 0			;Allocate all available RAM.
		MemInit
		mov	MemAvail, cx
		printf
		db	"There are %x paragraphs of memory available."
		db	cr,lf,lf,0
		dd	MemAvail
;
;
;
;
;***************************************************************************
;
; Test the random number generator:
;
		mov	k, 3
loop0:		mov	i, 20
loop1:		mov	j, 12
loop2:		random
		mov	cx, 6
		putusize
		dec	j
		jnz	loop2
		putcr
		dec	i
		jnz	loop1
		print
		db	"Press any key to continue:",0
		getc
		print
		db	"...randomizing...",cr,lf,lf,0
		randomize
		dec	k
		jnz	loop0
;
;
;***************************************************************************
;
;
;
Quit:		mov     ah, 4ch
		int     21h
;
;
Main		endp
;
;
;
;
cseg            ends
;
;
; Allocate a reasonable amount of space for the stack (2k).
;
sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends
;
;
;
; zzzzzzseg must be the last segment that gets loaded into memory!
;
zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
heap		db	1024 dup (?)
zzzzzzseg	ends
		end	Main
