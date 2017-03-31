; This program demonstrates how to compute the minimum and maximum values
; for an array of signed integers using the bound instruction

		.xlist
                .286
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

; The following two values contain the bounds for the BOUND instruction.

LowerBound	word	?
UpperBound	word	?

; Save the INT 5 address here:

OldInt5		dword	?

; Here is the array we want to compute the minimum and maximum for:

Array		word	1, 2, -5, 345, -26, 23, 200, 35, -100, 20, 45
		word	62, -30, -1, 21, 85, 400, -265, 3, 74, 24, -2
		word	1024, -7, 1000, 100, -1000, 29, 78, -87, 60
ArraySize	=	($-Array)/2

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Our interrupt 5 ISR.  It compares the value in AX with the upper and
; lower bounds and stores AX in one of them (we know AX is out of range
; by virtue of the fact that we are in this ISR).
;
; Note: in this particular case, we know that DS points at dseg, so this
; ISR will get cheap and not bother reloading it.
;
; Warning: This code does not handle the conflict between bound/int5 and
; the print screen key.  Pressing prtsc while executing this code may
; produce incorrect results (see the text).

BoundISR	proc	near
		cmp	ax, LowerBound
		jl	NewLower

; Must be an upper bound violation.

		mov	UpperBound, ax
		iret

NewLower:	mov	LowerBound, ax
		iret
BoundISR	endp



Main		proc
		mov	ax, dseg
		mov	ds, ax
		meminit

; Begin by patching in the address of our ISR into int 5's vector.

		mov	ax, 0
		mov	es, ax
		mov	ax, es:[5*4]
		mov	word ptr OldInt5, ax
		mov	ax, es:[5*4 + 2]
		mov	word ptr OldInt5+2, ax

		mov	word ptr es:[5*4], offset BoundISR
		mov	es:[5*4 + 2], cs


; Okay, process the array elements.  Begin by initializing the upper
; and lower bounds values with the first element of the array.

		mov	ax, Array
		mov	LowerBound, ax
		mov	UpperBound, ax

; Now process each element of the array:

		mov	bx, 2			;Start with second element.
		mov	cx, ArraySize
GetMinMax:	mov	ax, Array[bx]
		bound	ax, LowerBound
		add	bx, 2			;Move on to next element.
		loop	GetMinMax		;Repeat for each element.

		printf
		byte	"The minimum value is %d\n"
		byte	"The maximum value is %d\n",0
		dword	LowerBound, UpperBound

; Okay, restore the interrupt vector:

		mov	ax, 0
		mov	es, ax
		mov	ax, word ptr OldInt5
		mov	es:[5*4], ax
		mov	ax, word ptr OldInt5+2
		mov	es:[5*4+2], ax


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
