; EX13_1c.asm
;
; This program copies one file to another using the standard library
; file I/O routines.  The Standard Library file I/O routines let you do
; character at a time I/O, but they block up the data to transfer to improve
; system performance.  You should find that the execution time of this
; code is somewhere between blocked I/O (ex13_1b) and character at a time
; I/O (EX13_1a);  it will, however, be much closer to the block I/O time
; (probably about twice as long as block I/O).

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

InFile		filevar	{}
OutFile		filevar	{}

Filename	byte	"Ex13_1.in",0		;Input file name
Filename2	byte	"Ex13_1.out",0		;Output file name

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; Open the input file:

		mov	ax, 0			;Open for reading
		ldxi	Filename
		lesi	InFile
		fopen
		jc	BadOpen

; Open the output file:

		mov	ax, 1			;Open for output
		ldxi	Filename2
		lesi	OutFile
		fcreate
		jc	BadCreate

; Copy the input file to the output file:

CopyLp:		lesi	InFile
		fgetc
		jc	GetDone

		lesi	OutFile
		fputc
		jmp	CopyLp

BadOpen:	printf
		byte	"Error opening '%s'",cr,lf,0
		dword	Filename
		jmp	Quit

BadCreate:	printf
		byte	"Error creating '%s'",cr,lf,0
		dword	Filename2
		jmp	CloseIn

GetDone:	cmp	ax, 0			;Check for EOF
		je	AtEOF

		print
		byte	"Error copying files (read error)",cr,lf,0

AtEOF:		lesi	OutFile
		fclose
CloseIn:	lesi	InFile
		fclose
	
Quit:		ExitPgm				;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
