		include 	stdlib.a
		includelib	stdlib.lib
;
;
; Global variables go here:
;
dseg		segment	para public 'data'
;
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
; Variables that wind up being used by the standard library routines.
; The MemInit routine uses "PSP" and "zzzzzzseg" labels.  They must be
; present if you intend to use getenv, MemInit, malloc, and free.
;
;
		public	PSP
PSP		dw	?
;
cr		equ	13
lf		equ	10
;
;
;--------------------------------------------
; Here is a good place to put other routines:
;
;
;
;
;-----------------------------------------------------------------
; Main is the main program.  Program execution always begins here.
;
Main		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
;
		mov	dx, 0
		meminit
;
;***************************************************************************
;
; Put your main program here.
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
zzzzzzseg	ends
		end	Main
