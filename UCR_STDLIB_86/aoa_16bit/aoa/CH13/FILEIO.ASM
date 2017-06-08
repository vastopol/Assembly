; FILEIO
;
; This program copies the input file to the output file and adds line
; numbers while it is copying the file.

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

ArgCnt		word	0
LineNumber	word	0
DOSErrorCode	word	0
InFile		dword	?		;Ptr to Input file name.
OutFile		dword	?		;Ptr to Output file name.
InputLine	byte	1024 dup (0)	;Input/Output data buffer.
OutputFile	FileVar	{}
InputFile	FileVar	{}

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; ReadLn- Reads a line of text from the input file and stores the
;         data into the InputLine buffer:

ReadLn		proc
		push	ds
		push	es
		push	di
		push	si
		push	ax

		mov	si, dseg
		mov	ds, si
		mov	si, offset InputLine
		lesi    InputFile

GetLnLp:
		fgetc
		jc	RdLnDone		;If some bizzarre error.
		cmp	ah, 0			;Check for EOF.
		je	RdLnDone		;Note:carry is set.
		mov	ds:[si], al
		inc	si
		cmp	al, lf			;At EOLN?
		jne	GetLnLp
		dec	si			;Back up before LF.
		cmp	byte ptr ds:[si-1], cr	;CR before LF?
		jne	RdLnDone
		dec	si			;If so, skip it too.

RdLnDone:	mov	byte ptr ds:[si], 0	;Zero terminate.
		pop	ax
		pop	si
		pop	di
		pop	es
		pop	ds
		ret
ReadLn		endp

; MyOutput- Writes the single character in AL to the output file.

MyOutput	proc	far
		push	es
		push	di
		lesi	OutputFile
		fputc
		pop	di
		pop	es
		ret
MyOutput	endp



; The main program which does all the work:

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Must call the memory manager initialization routine if you use
; any routine which calls malloc!  ARGV is a good example of a
; routine calls malloc.

		meminit

; We expect this program to be called as follows:
;		fileio file1, file2
; anything else is an error.

		argc
		cmp	cx, 2		;Must have two parameters.
		je	Got2Parms
BadParms:	print
		byte	"Usage: FILEIO infile, outfile",cr,lf,0
		jmp	Quit

; Okay, we've got two parameters, hopefully they're valid filenames.
; Get copies of the filenames and store away the pointers to them.

Got2Parms:	mov	ax, 1		;Get the input filename
		argv
		mov	word ptr InFile, di
		mov	word ptr InFile+2, es

		mov	ax, 2		;Get the output filename
		argv
		mov	word ptr OutFile, di
		mov	word ptr OutFile+2, es

; Output the filenames to the standard output device

		printf
		byte	"Input file: %^s\n"
		byte	"Output file: %^s\n",0
		dword   InFile, OutFile

; Open the input file:

		lesi	InputFile
		mov	dx, word ptr InFile+2
		mov	si, word ptr InFile
		mov	ax, 0
		fopen
		jnc	GoodOpen
		mov	DOSErrorCode, ax
		printf
		byte	"Could not open input file, DOS: %d\n",0
		dword	DOSErrorCode
		jmp	Quit

; Create a new file for output:

GoodOpen:	lesi	OutputFile
		mov	dx, word ptr OutFile+2
		mov	si, word ptr OutFile
		fcreate
		jnc	GoodCreate
		mov	DOSErrorCode, AX
		printf
		byte	"Could not open output file, DOS: %d\n",0
		dword	DOSErrorCode
		jmp	Quit

; Okay, save the output hook and redirect the output.

GoodCreate:	PushOutAdrs
		lesi	MyOutput
		SetOutAdrs


WhlNotEOF:	inc	LineNumber

; Okay, read the input line from the user:

		call	ReadLn
		jc	BadInput

; Okay, redirect the output to our output file and write the last line
; read prefixed with a line number:

		printf
		byte	"%4d:   %s\n",0
		dword   LineNumber, InputLine
		jmp	WhlNotEOF


BadInput:	push	ax		;Save error code.
		PopOutAdrs		;Restore output hook.
		pop	ax		;Retrieve error code.
		test	ax, ax		;EOF error? (AX = 0)
		jz	CloseFiles
		mov     DOSErrorCode, ax
		printf
		byte	"Input error, DOS: %d\n",0
		dword	LineNumber

; Okay, close the files and quit:

CloseFiles:     lesi    OutputFile
		fclose
		lesi	InputFile
		fclose

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends



sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


;zzzzzzseg is required by the standard library routines.

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
