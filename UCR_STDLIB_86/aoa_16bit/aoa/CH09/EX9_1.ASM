
dseg		segment	para public 'data'

I		word	0
J		word	0
K		word	0

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; This program is useful for debugging purposes only!
; The intent is to execute this code from inside CodeView.
;
; This program is riddled with bugs.  The bugs are very obvious in
; this short code sequence, within a larger program these bugs might
; not be quite so obvious.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; The following loop increments I until it reaches 10

ForILoop:	inc	I
		cmp	I, 10
		jb	ForILoop

; This loop is supposed to do the same thing as the loop above, but we
; forgot to reinitialize I back to zero.  What happens?

ForILoop2:	inc	I
		cmp	I, 10
		jb	ForILoop2


; The following loop, once again, attempts to do the same thing as the first
; for loop above.  However, this time we remembered to reinitialize I.  Alas,
; there is another problem with this code, a typo which the assembler cannot
; catch.

		mov	I, 0
ForILoop3:	inc	I
		cmp	I, 10
		jb	ForILoop	;<<<-- Whoops! Typo.

; The following loop adds I to J until J reaches 100.  Unfortunately,
; the author of this code must have been confused and thought that AX
; contained the sum accumulating in J.  It compares AX against 100 when
; it should really be comparing J against 100.

WhileJLoop:	mov	ax, I
		add	J, ax
		cmp	ax, 100		;This is a bug!
		jb	WhileJLoop




		mov	ah, 4ch		;Quit to CodeView/DOS.
		int	21h
Main		endp

cseg            ends



; Allocate a reasonable amount of space for the stack (8k).
; Note: if you use the pattern matching package you should set up a
;	somewhat larger stack.

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


; zzzzzzseg must be the last segment that gets loaded into memory!
; This is where the heap begins.

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
