; PROJ6_6.ASM-
;
; An integer input routine.
;



dseg		segment	para public 'data'

; Put any variables you need here.

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; GetChar is a subroutine you can call to read a single key from the
; keyboard.  It returns the character it reads in the AL register.

GetChar		proc
		mov	ah, 0		;BIOS call to read a key.
		int	16h
		ret
GetChar		endp



; PutChar prints the character in the AL register to the display.

PutChar		proc
		push	ax		;Preserve value in AH
		mov	ah, 0eh		;BIOS call to print a character.
		int	10h
		pop	ax		;Restore AH's value.
		ret
PutChar		endp


; Newline-	Prints the cr/lf pair to the screen (a new line).

NewLine		proc
		push	ax
		mov	ax, 0e0dh	;Carriage return
		int	10h
		mov	ax, 0e0ah	;Linefeed
		int	10h
		pop	ax
		ret
NewLine		endp



; Copy this routine from Project #5 (or see project five for details on
; how to write this routine if you've not done project five).

PutInt		proc
		ret
PutInt		endp



; GetInt-	Read a sequence of characters from the keyboard.
;		As long as the characters a decimal digits, convert
;		them into an integer.  This routine should preserve
;		all registers except AX.  It should return the unsigned
;		integer in AX.

GetInt		proc
		ret
GetInt		endp


; Main program to test the PutInt routine.

Main		proc
		mov	ax, dseg
		mov	ds, ax


		mov	cx, 4
LoopIt:
		call	GetInt
		call	PutInt
		call	NewLine
		loop	LoopIt



Quit:		mov	ah, 4ch	  	;DOS opcode to quit program.
		int	21h		;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
