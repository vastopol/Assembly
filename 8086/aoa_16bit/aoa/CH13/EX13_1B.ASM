; EX13_1b.asm
;
; This program copies one file to another using blocked I/O.
; Run this program and time its execution.  Compare the execution time of
; this program against that of the character at a time I/O and the
; Standard Library File I/O example (ex13_1a and ex13_1c).

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

; File handles for the files we will open.

FHndl		word	?			;Input file handle
FHndl2		word	?			;Output file handle

Buffer		byte	256 dup (?)		;File buffer area

FName		equ	this word		;Ptr to current file name
FNamePtr	dword	FileName

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


; The following loop reads 256 bytes at a time from the file and then
; writes those 256 bytes to the output file.

LP:		mov	ah,3fh			;Read data from the file
		lea	dx, Buffer		;Address of data buffer
		mov	cx, 256			;Read 256 bytes
		mov	bx, FHndl		;Get file handle value
		int	21h
		jc	ReadError
		cmp	ax, cx			;EOF reached?
		jne	EOF

		mov	ah, 40h			;Write data to file
		lea	dx, Buffer		;Address of output buffer
		mov	cx, 256			;Write 256 bytes
		mov	bx, FHndl2		;Output handle
		int	21h
		jc	WriteError
		jmp	LP			;Read next block

; Note, just because the number of bytes read does not equal 256, 
; don't get the idea we're through, there could be up to 255 bytes 
; in the buffer still waiting to be processed.

EOF:		mov	cx, ax			;Put # of bytes to write in CX.
		jcxz	EOF2			;If CX is zero, we're really done.
		mov	ah, 40h			;Write data to file
		lea	dx, Buffer		;Address of output buffer
		mov	bx, FHndl2		;Output handle
		int	21h
		jc	WriteError


EOF2:		mov	bx, FHndl
		mov	ah, 3eh 		;Close file
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
