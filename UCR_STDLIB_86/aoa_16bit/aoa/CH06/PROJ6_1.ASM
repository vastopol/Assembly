; PROJ6_1.ASM
; Project #1: Write a short "GetLine routine that reads up to 80 characters
; from the user and places the characters in successive locations in a buffer
; in the data segment.  You can call the "GETChar" and "PUTChar" subroutines
; provided in this code to read characters and write characters.
;
; Terminate user input when you encounter a carriage return (ASCII code=0Dh)
; or after reading the 80th character.  Place a zero in the buffer where the
; carriage return would have went or in the 81st character position.
;
; Count the number of characters read by the user and return this count to
; the caller in the CX register.
;
; Be sure to delete all project explanations from the comments in this
; program before you submit it as your own work.  Of course, you are
; expected to *fully* comment your own code.

dseg		segment	para public 'data'

; Put the declaration for "BUFFER" (the input buffer) here.  It must
; support at least 81 characters.  You should put any other variable
; declarations you need here as well.

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




; GetLine- Here's the subroutine you've got to write.
;	   Besure to preserve all register you modify using push and pop
;	   instructions (do not preserve CX, though, since this contains
;	   a return value).

GetLine		proc

; ****************   Insert your code here.  **************************

		ret
GetLine		endp




Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Main program to get the GetLine routine:

		call	GetLine


; Print the data read by GetLine

		lea	bx, Buffer
PrintLoop:	mov	al, [bx]
		call	PutChar
		inc	bx
		loop	PrintLoop

		mov	al, 0dh			;Print a carriage return
		call	PutChar			; and a line feed in order
		mov	al, 0ah			; to terminate this line.
		call	PutChar


Quit:		mov	ah, 4ch			;DOS opcode to quit program.
		int	21h			;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
