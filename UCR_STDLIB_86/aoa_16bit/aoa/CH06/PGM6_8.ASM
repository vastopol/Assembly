; CALL and INT Instructions

		.386
		option	segment:use16

dseg		segment	para public 'data'

; Some pointers to our subroutines:

SPtr1		word	Subroutine1
SPtr2		dword	Subroutine2

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Subroutine1	proc	near
		ret
Subroutine1	endp

Subroutine2	proc	far
		ret
Subroutine2	endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Near call:

		call	Subroutine1

; Far call:

		call	Subroutine2

; Near register-indirect call:

		lea	cx, Subroutine1
		call	cx

; Near memory-indirect call:

		call	SPtr1

; Far memory-indirect call:

		call	SPtr2


; INT transfers control to a routine whose
; address appears in the interrupt vector
; table (see Chapter 15 for details on
; the interrupt vector table). The following
; call tells the PC's BIOS to print the
; ASCII character in AL to the display.

		mov	ah, 0eh
		mov	al, 'A'
		int	10h

; INTO generates an INT 4 if the 80x86
; overflow flag is set.  It becomes a
; NOP if the overflow flag is clear.
; You can use this instruction after
; an arithmetic operation to quickly
; test for a fatal overflow.  Note:
; the following sequence does *not*
; generate an overflow.  Do not modify
; it so that it does unless you add an
; INT 4 interrupt service routine to
; the interrupt vector table (see Chapter
; 15 for details)

		mov	ax, 2
		add	ax, 4
		into


Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
