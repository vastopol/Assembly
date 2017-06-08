; PROJ6_4.ASM-
;
;	A PutString routine.  You are to write a subroutine that outputs the
;	zero terminated string pointed at by the ES:DI register pair.  Your
;	subroutine should preserve all registers it modifies.  It should *not*
;	print the zero terminating byte.



dseg		segment	para public 'data'

TestString	byte	"This is a test string to print", 0dh, 0ah, 0
TSAdrs		dword	TestString


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



; Here is the routine you've got to write for this project:
; ES:DI points at the zero terminated string to print.
; Be sure to preserve all registers.
; You call call the PutChar routine to print the individual characters.

PutString	proc
		ret
PutString	endp




; Main program to test the PutString routine.

Main		proc
		mov	ax, dseg
		mov	ds, ax


		les	di, TSAdrs	;Load address of string into es:di
		call	PutString


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
