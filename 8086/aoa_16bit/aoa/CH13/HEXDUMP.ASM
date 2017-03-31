		include		stdlib.a
		includelib	stdlib.lib
cseg		segment		byte public 'CODE'
		assume		cs:cseg, ds:dseg, es:dseg, ss:sseg

; Note CR and LF are already defined in STDLIB.A

tab		equ	09h

MainPgm 	proc	far

; Properly set up the segment registers:

		mov	ax, seg dseg
		mov	es, ax			;Leave DS pointing at PSP

;---------------------------------------------------------------
;
; First, parse the command line to get the filename:

		mov	si, 81h		 	;Pointer to command line
		lea	di, FileName		;Pointer to FileName buffer
SkipDelimiters:
		lodsb				;Get next character
		call	TestDelimiter
		je	SkipDelimiters

; Assume that what follows is an actual filename

		dec	si			;Point at 1st char of name
GetFName:	lodsb
		cmp	al, 0dh
		je	GotName
		call	TestDelimiter
		je	GotName
		stosb				;Save character in file name
		jmp	GetFName

; We're at the end of the filename, so zero-terminate it as 
; required by DOS.

GotName:	mov	byte ptr es:[di], 0
		mov	ax, es			;Point DS at DSEG
		mov	ds, ax

; Now process the file

		mov	ah, 3dh
		mov	al, 0			;Open file for reading
		lea	dx, Filename		;File to open
		int	21h
		jnc	GoodOpen
		print
		byte	'Cannot open file, aborting program...',cr,0
		jmp	PgmExit

GoodOpen:	mov	FileHandle, ax		;Save file handle
		mov	Position, 0		;Initialize file position
ReadFileLp:	mov	al, byte ptr Position
		and	al, 0Fh		 	;Compute (Position MOD 16)
		jnz	NotNewLn		;Every 16 bytes start a line
		putcr
		mov	ax, Position		;Print offset into file
		xchg	al, ah
		puth
		xchg	al, ah
		puth
		print
		byte	': ',0

NotNewLn:	inc	Position		;Increment character count
		mov	bx, FileHandle
		mov	cx, 1			;Read one byte
		lea	dx, buffer		;Place to store that byte
		mov	ah, 3Fh		 	;Read operation
		int	21h
		jc	BadRead
		cmp	ax, 1			;Reached EOF?
		jnz	AtEOF
		mov	al, Buffer		;Get the character read and
		puth				; print it in hex
		mov	al, ' ' 		;Print a space between values
		putc
		jmp	ReadFileLp

BadRead:		print
		byte	cr, lf
		byte	'Error reading data from file, aborting.'
		byte	cr,lf,0

AtEOF:		mov	bx, FileHandle		;Close the file
		mov	ah, 3Eh
		int	21h

;---------------------------------------------------------------

PgmExit:	ExitPgm
MainPgm 	endp

TestDelimiter	proc	near
		cmp	al, ' '
		je	xit
		cmp	al, ','
		je	xit
		cmp	al, Tab
		je	xit
		cmp	al, ';'
		je	xit
		cmp	al, '='
xit:		ret
TestDelimiter	endp
cseg		ends

dseg		segment	byte public 'data'

PSP		word	?
Filename	byte	64 dup (0)		;Filename to dump
FileHandle	word	?
Buffer		byte	?
Position		word	0

dseg		ends

sseg		segment	byte stack 'stack'
stk		word	0ffh dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	MainPgm
