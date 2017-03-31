; EX13_1a.asm
;
; This program copies one file to another using character at a time I/O.
; It is easy to write, read, and understand, but character at a time I/O
; is quite slow.  Run this program and time its execution.  Then run the
; corresponding blocked I/O exercise and compare the execution times of
; the two programs.

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

FHndl		word	?
FHndl2		word	?
Buffer		byte	?

FName		equ	this word
FNamePtr	dword	FileName

Filename	byte	"Ex13_1.in",0
Filename2	byte	"Ex13_1.out",0

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		mov	ah, 3dh 		;Open the input file
		mov	al, 0			; for reading
		lea	dx, Filename		;Presume DS points at filename
		int	21h			; segment
		jc	BadOpen
		mov	FHndl, ax		;Save file handle


		mov	FName, offset Filename2	;Set this up in case there
		mov	FName+2, seg FileName2	; is an error during open.

		mov	ah, 3ch 		;Open the output file for writing
		mov	cx, 0			; with normal file attributes
		lea	dx, Filename2		;Presume DS points at filename
		int	21h			; segment
		jc	BadOpen
		mov	FHndl2, ax		;Save file handle

LP:		mov	ah,3fh			;Read data from the file
		lea	dx, Buffer		;Address of data buffer
		mov	cx, 1			;Read one byte
		mov	bx, FHndl		;Get file handle value
		int	21h
		jc	ReadError
		cmp	ax, cx			;EOF reached?
		jne	EOF

		mov	ah,40h			;Write data to the file
		lea	dx, Buffer		;Address of data buffer
		mov	cx, 1			;Write one byte
		mov	bx, FHndl2		;Get file handle value
		int	21h
		jc	WriteError
		jmp	LP			;Read next byte

EOF:		mov	bx, FHndl
		mov	ah, 3eh			;Close file
		int	21h
		jmp	Quit

ReadError:	printf
		byte	"Error while reading data from file '%s'.",cr,lf,0
		dword	FileName
		jmp	Quit

WriteError:	printf
		byte	"Error while writing data to file '%s'.",cr,lf,0
		dword	FileName2
		jmp	Quit

BadOpen:	printf
		byte	"Could not open '%^s'.  Make sure this file is in the ",cr,lf
		byte	"current directory before attempting to run this program again."
		byte	cr,lf,0
		dword	FName

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
