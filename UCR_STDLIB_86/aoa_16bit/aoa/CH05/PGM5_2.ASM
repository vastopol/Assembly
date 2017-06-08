; Using Pointer Variables in an Assembly Language Program
;
; This short sample program demonstrates the use of pointers in
; an assembly language program.
;
; Randall Hyde

dseg		segment	para public 'data'


; Some variables we will access indirectly (using pointers):

J		word	0, 0, 0, 0
K		word	1, 2, 3, 4
L		word	5, 6, 7, 8

; Near pointers are 16-bits wide and hold an offset into the current data
; segment (dseg in this program).  Far pointers are 32-bits wide and hold
; a complete segment:offset address.  The following type definitions let
; us easily create near and far pointers

nWrdPtr		typedef	near ptr word
fWrdPtr		typedef	far ptr word


; Now for the actual pointer variables:

Ptr1		nWrdPtr	?
Ptr2            nWrdPtr	K		;Initialize with K's address.
Ptr3		fWrdPtr	L		;Initialize with L's segmented adrs.

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.


; Initialize Ptr1 (a near pointer) with the address of the J variable.

		lea	ax, J
		mov	Ptr1, ax

; Add the four words in variables J, K, and L together using pointers to
; these variables:

		mov	bx, Ptr1	;Get near ptr to J's 1st word.
		mov	si, Ptr2	;Get near ptr to K's 1st word.
		les	di, Ptr3	;Get far ptr to L's 1st word.



		mov	ax, ds:[si]	;Get data at K+0.
		add	ax, es:[di]	;Add in data at L+0.
		mov	ds:[bx], ax	;Store result to J+0.

		add	bx, 2		;Move to J+2.
		add	si, 2		;Move to K+2.
		add	di, 2		;Move to L+2.



		mov	ax, ds:[si]	;Get data at K+2.
		add	ax, es:[di]	;Add in data at L+2.
		mov	ds:[bx], ax	;Store result to J+2.

		add	bx, 2		;Move to J+4.
		add	si, 2		;Move to K+4.
		add	di, 2		;Move to L+4.



		mov	ax, ds:[si]	;Get data at K+4.
		add	ax, es:[di]	;Add in data at L+4.
		mov	ds:[bx], ax	;Store result to J+4.

		add	bx, 2		;Move to J+6.
		add	si, 2		;Move to K+6.
		add	di, 2		;Move to L+6.



		mov	ax, ds:[si]	;Get data at K+6.
		add	ax, es:[di]	;Add in data at L+6.
		mov	ds:[bx], ax	;Store result to J+6.



Quit:		mov	ah, 4ch		;Magic number for DOS
		int	21h		; to tell this program to quit.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
