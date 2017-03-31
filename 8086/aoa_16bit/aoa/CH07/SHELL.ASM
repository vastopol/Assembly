		.xlist

; Includes for the library routines.  For performance reasons you may want
; to replace the "stdlib.a" include with the names of the individual packages
; you actually use.  Doing so will speed up assembly by quite a bit.

		include 	stdlib.a
		includelib	stdlib.lib

; Note: if you want to use the pattern matching functions in the patterns
; 	package, uncomment the following line:

;		matchfuncs

		.list



;*****************************************************************************

dseg		segment	para public 'data'

; Global variables go here:


; Note:	If you want to use the STDLIB standard character sets (alpha, digits,
;	etc.) uncomment the following line:

;		include	stdsets.a

dseg		ends

;*****************************************************************************





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


;-----------------------------------------------------------------
;
; Here is a good place to put your procedures,
; functions, and other routines:
;
;
;
;
;-----------------------------------------------------------------
;
; Main is the main program.  Program execution always begins here.
;
Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Start by calling the memory manager initialization routine.  This
; particular call allocates all available memory to the heap.  See
; MEMINIT2 if you want to allocate a fixed heap.
;
; Many library routines use the heap, hence the presence of this call
; in this file.  On the other hand, you may safely remove this call
; if you do not call any library routines which use the heap.

		meminit



;***************************************************************************
;
; Put your main program here.
;
;***************************************************************************





Quit:		ExitPgm			;DOS macro to quit program.
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
