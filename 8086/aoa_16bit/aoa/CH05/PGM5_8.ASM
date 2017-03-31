; Pointers to structures
; Pointers to arrays of structures
;
; Randall Hyde


		.386			;Need these two statements so we can
		option	segment:use16	; use 80386 register set.

dseg		segment	para public 'data'

; Sample structure.
; Note: size is seven bytes.

Sample		struct
b		byte	?
w		word	?
d		dword	?
Sample		ends


; Some variable declarations:

OneSample	Sample	{}
SampleAry	Sample	16 dup ({})

; Pointers to the above

OnePtr		word	OneSample	;A near pointer.
AryPtr		dword	SampleAry


; Index into the array:

Index		word	8

dseg		ends





; The following program demonstrates how to access each of the above
; variables.

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.

; AryPtr^[Index] := OnePtr^


		mov	si, OnePtr	;Get pointer to OneSample
		les	bx, AryPtr	;Get pointer to array of samples
		mov	ax, Index	;Need index*7
		mov	di, 7
		mul	di
		mov	di, ax

		mov	al, ds:[si].Sample.b
		mov	es:[bx][di].Sample.b, al

		mov	ax, ds:[si].Sample.w
		mov	es:[bx][di].Sample.w, ax

		mov	eax, ds:[si].Sample.d
		mov	es:[bx][di].Sample.d, eax


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
