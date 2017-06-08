
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
; This version of the program has all the bugs corrected.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; The following loop increments I until it reaches 10

ForILoop:	inc	I
		cmp	I, 10
		jb	ForILoop

; So does this loop.

		mov	I, 0		;Added this statement.
ForILoop2:	inc	I
		cmp	I, 10
		jb	ForILoop2


; So does this loop:

		mov	I, 0
ForILoop3:	inc	I
		cmp	I, 10
		jb	ForILoop3	;Corrected this statement.


; The following loop adds I to J until J reaches 100.

WhileJLoop:	mov	ax, I
		add	J, ax
		cmp	J, 100		;Corrected this statement.
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
