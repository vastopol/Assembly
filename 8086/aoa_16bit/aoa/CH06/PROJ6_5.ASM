; PROJ6_5.ASM-
;
; An integer output routine.
;
; PUTINT is passed an unsigned integer value in the AX register.
; It should print the value of that integer as a sequence of characters
; providing the decimal representation of that integer.  See the lab
; manual for the exact algorithm.



dseg		segment	para public 'data'
; Put any variables you need here.
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


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



; Here is the routine you've got to write for this project.
; On entry, AX contains an unsigned integer value.  It needs to
; print this value as a string of decimal digits.  Be sure to
; preserve (on the stack) all registers you modify.

PutInt		proc
		ret
PutInt		endp




; Main program to test the PutInt routine.

Main		proc
		mov	ax, dseg
		mov	ds, ax


		mov	ax, 12345
		call	PutInt
		call	NewLine

		mov	ax, 54321
		call	PutInt
		call	NewLine

		mov	ax, 0
		call	PutInt
		call	NewLine

		mov	ax, 65535
		call	PutInt
		call	NewLine

		mov	ax, 1
		call	PutInt
		call	NewLine

		mov	ax, 10
		call	PutInt
		call	NewLine

		mov	ax, 100
		call	PutInt
		call	NewLine

		mov	ax, 1000
		call	PutInt
		call	NewLine

		mov	ax, 10000
		call	PutInt
		call	NewLine


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
