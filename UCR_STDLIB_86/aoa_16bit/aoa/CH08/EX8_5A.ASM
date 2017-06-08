; Ex8_5a.asm
;
; Randall Hyde
; 2/7/96
; 
; This program reads a string of symbols from the user and prints the vowels.
; It demonstrates the use of make files


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; The following include file brings in the external
; definitions of the routine(s) in the Lab6x10b
; module.  In particular, it gives this module
; access to the "PrtVowels" routine found in
; Lab8_5b.asm.

		include		Ex8_5.a


cseg		segment	para public 'code'

Main		proc

		meminit

; Read a string from the user, print all the vowels
; present in that string, and then free up the memory
; allocated by the GETSM routine:

		print
		byte	"I will find all your vowels"
		byte	cr,lf
		byte	"Enter a line of text: ",0

		getsm
		print
		byte	"Vowels on input line: ",0
		PrtVowels
		putcr
		free

Quit:		ExitPgm
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
