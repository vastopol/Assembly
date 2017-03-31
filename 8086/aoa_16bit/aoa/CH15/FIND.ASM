; Find.asm
;
; This program opens a file specified on the command line and searches for
; a string (also specified on the command line).
;
; Program Usage:
;
;	find "string" filename


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

wp		textequ	<word ptr>

dseg		segment	para public 'data'

StrPtr		dword	?
FileName	dword	?
LineCnt		dword	?

FVar		filevar	{}

InputLine	byte	1024 dup (?)
dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Readln-	This procedure reads a line of text from the input
;		file and buffers it up in the "InputLine" array.

ReadLn		proc
		push	es
		push	ax
		push	di
		push	bx

		lesi	FVar		;Read from our file.
		mov	bx, 0		;Index into InputLine.
ReadLp:		fgetc			;Get next char from file.
		jc	EndRead		;Quit on EOF

		cmp	al, cr		;Ignore carriage returns.
		je	ReadLp
		cmp	al, lf		;End of line on line feed.
		je	EndRead

		mov	InputLine[bx], al
		inc	bx
		jmp	ReadLp

; If we hit the end of a line or the end of the file,
; zero-terminate the string.

EndRead:	mov	InputLine[bx], 0
		pop	bx
		pop	di
		pop	ax
		pop	es
		ret
ReadLn		endp


; The following main program extracts the search string and the
; filename from the command line, opens the file, and then searches
; for the string in that file.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		argc
		cmp	cx, 2
		je	GoodArgs
		print
		byte	"Usage: find 'string' filename",cr,lf,0
		jmp	Quit

GoodArgs:	mov	ax, 1		;Get the string to search for
		argv			; off the command line.
		mov	wp StrPtr, di
		mov	wp StrPtr+2, es

		mov	ax, 2		;Get the filename from the
		argv			; command line.
		mov	wp Filename, di
		mov	wp Filename+2, es

; Open the input file for reading

		mov	ax, 0		;Open for read.
		mov	si, wp FileName
		mov	dx, wp FileName+2
		lesi	Fvar
		fopen
		jc	BadOpen

; Okay, start searching for the string in the file.

		mov	wp LineCnt, 0
		mov	wp LineCnt+2, 0
SearchLp:	call	ReadLn
		jc	AtEOF


; Bump the line number up by one.  Note that this is 8086 code
; so we have to use extended precision arithmetic to do a 32-bit
; add.  LineCnt is a 32-bit variable because some files have more
; that 65,536 lines.

		add	wp LineCnt, 1
		adc	wp LineCnt+2, 0

; Search for the user-specified string on the current line.

		lesi	InputLine
		mov	dx, wp StrPtr+2
		mov	si, wp StrPtr
		strstr
		jc	SearchLp	;Jump if not found.

; Print an appropriate message if we found the string.

		printf
		byte	"Found '%^s' at line %ld\n",0
		dword	StrPtr, LineCnt
		jmp	SearchLp

; Close the file when we're done.

AtEOF:		lesi	FVar
		fclose
		jmp	Quit

BadOpen:	printf
		byte	"Error attempting to open %^s\n",cr,lf,0
		dword	FileName


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
