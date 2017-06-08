		include		stdlib.a
		includelib	stdlib.lib

cseg		segment		byte public 'CODE'
		assume		cs:cseg, ds:nothing, es:dseg, ss:sseg

; Note: The constants CR (0dh) and LF (0ah) appear within the
; stdlib.a include file.

tab		equ	09h

MainPgm 	proc	far

; Properly set up the segment registers:

		mov	ax, seg dseg
		mov	es, ax			;Leave DS pointing at PSP

;---------------------------------------------------------------

; First, parse the command line to get the filename:

		mov	es:GotName1, 0		;Init flags that tell us if
		mov	es:GotName2, 0		; we’ve parsed the filenames 
		mov	es:ConvertLC,0		; and the “/U" switch.

; Okay, begin scanning and parsing the command line

		mov	si, 81h		 	;Pointer to command line
SkipDelimiters:	
		lodsb				;Get next character
		call	TestDelimiter
		je	SkipDelimiters

; Determine if this is a filename or the /U switch

		cmp	al, '/'
		jnz	MustBeFN

; See if it's "/U" here-

		lodsb
		and	al, 5fh		 	;Convert "u" to "U"
		cmp	al, 'U'
		jnz	NotGoodSwitch
		lodsb				;Make sure next char is
		cmp	al, cr			; a delimiter of some sort
		jz	GoodSwitch
		call	TestDelimiter
		jne	NotGoodSwitch

; Okay, it's "/U" here.

GoodSwitch:	mov	es:ConvertLC, 1		;Convert LC to UC
		dec	si			;Back up in case it's CR
		jmp	SkipDelimiters		;Move on to next item.

; If a bad switch was found on the command line, print an error 
; message and abort-

NotGoodSwitch:
		print
		byte	cr,lf
		byte	'Illegal switch, only "/U" is allowed!',cr,lf
		byte	'Aborting program execution.',cr,lf,0
		jmp	PgmExit

; If it's not a switch, assume that it's a valid filename and 
; handle it down here-

MustBeFN:	cmp	al, cr			;See if at end of cmd line
		je	EndOfCmdLn

; See if it's filename one, two, or if too many filenames have been
; specified-

		cmp	es:GotName1, 0
		jz	Is1stName
		cmp	es:GotName2, 0
		jz	Is2ndName

; More than two filenames have been entered, print an error message
; and abort.

		print
		byte	cr,lf
		byte	'Too many filenames specified.',cr,lf
		byte	'Program aborting...',cr,lf,lf,0
		jmp	PgmExit

; Jump down here if this is the first filename to be processed-

Is1stName:	lea	di, FileName1
		mov	es:GotName1, 1
		jmp	ProcessName

Is2ndName:	lea	di, FileName2
		mov	es:GotName2, 1
ProcessName:
		stosb				;Store away character in name
		lodsb				;Get next char from cmd line
		cmp	al, cr
		je	NameIsDone
		call	TestDelimiter
		jne	ProcessName

NameIsDone:	mov	al, 0			;Zero terminate filename
		stosb
		dec	si			;Point back at previous char
		jmp	SkipDelimiters		;Try again.

; When the end of the command line is reached, come down here and 
; see if both filenames were specified.

		assume		ds:dseg

EndOfCmdLn:	mov	ax, es			;Point DS at DSEG
		mov	ds, ax

; We're at the end of the filename, so zero-terminate it as
;  required by DOS.

GotName:	mov	ax, es			;Point DS at DSEG
		mov	ds, ax

; See if the names were supplied on the command line.
; If not, prompt the user and read them from the keyboard

		cmp	GotName1, 0		;Was filename #1 supplied?
		jnz	HasName1
		mov	al, '1'			;Filename #1
		lea	si, Filename1
		call	GetName 		;Get filename #1

HasName1:	cmp	GotName2, 0		;Was filename #2 supplied?
		jnz	HasName2
		mov	al, '2' 		;If not, read it from kbd.
		lea	si, FileName2
		call	GetName

; Okay, we've got the filenames, now open the files and copy the 
; source file to the destination file.

HasName2:       mov     ah, 3dh
		mov	al, 0			;Open file for reading
		lea	dx, Filename1		;File to open
		int	21h
		jnc	GoodOpen1

		print
		byte	'Cannot open file, aborting program...',cr,lf,0
		jmp	PgmExit

; If the source file was opened successfully, save the file handle.

GoodOpen1:	mov	FileHandle1, ax		;Save file handle

; Open (CREATE, actually) the second file here.

		mov	ah, 3ch		 	;Create file
		mov	cx, 0			;Standard attributes
		lea	dx, Filename2		;File to open
		int	21h
		jnc	GoodCreate

; Note: the following error code relies on the fact that DOS 
; automatically closes any open source files when the program
; terminates.

		print
		byte	cr,lf
		byte	'Cannot create new file, aborting operation'
		byte	cr,lf,lf,0
		jmp	PgmExit

GoodCreate:	mov	FileHandle2, ax		;Save file handle

; Now process the files

CopyLoop:	mov	ah, 3Fh			;DOS read opcode
		mov	bx, FileHandle1		;Read from file #1
		mov	cx, 512 		;Read 512 bytes
		lea	dx, buffer		;Buffer for storage
		int	21h
		jc	BadRead
		mov	bp, ax			;Save # of bytes read

		cmp	ConvertLC,0		;Conversion option active?
		jz	NoConversion

; Convert all LC in buffer to UC-

		mov	cx, 512
		lea	si, Buffer
		mov	di, si
ConvertLC2UC:
		lodsb
		cmp	al, 'a'
		jb	NoConv
		cmp	al, 'z'
		ja	NoConv
		and	al, 5fh
NoConv: 	stosb
		loop	ConvertLC2UC

NoConversion:
		mov	ah, 40h			;DOS write opcode
		mov	bx, FileHandle2		;Write to file #2
		mov	cx, bp			;Write however many bytes
		lea	dx, buffer		;Buffer for storage
		int	21h
		jc	BadWrite
		cmp	ax, bp			;Did we write all of the 
		jnz	jDiskFull		; bytes?
		cmp	bp, 512			;Were there 512 bytes read?
		jz	CopyLoop
		jmp	AtEOF
jDiskFull:	jmp	DiskFull

; Various error messages:

BadRead:	print
		byte	cr,lf
		byte	'Error while reading source file, aborting '
		byte	'operation.',cr,lf,0
		jmp	AtEOF

BadWrite:		print
		byte	cr,lf
                byte    'Error while writing destination file, aborting'
		byte	' operation.',cr,lf,0
		jmp	AtEOF

DiskFull:		print
		byte	cr,lf
		byte	'Error, disk full.  Aborting operation.',cr,lf,0

AtEOF:		mov	bx, FileHandle1		;Close the first file
		mov	ah, 3Eh
		int	21h
		mov	bx, FileHandle2		;Close the second file
		mov	ah, 3Eh
		int	21h

PgmExit:	ExitPgm
MainPgm 	endp

TestDelimiter		proc	near
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
TestDelimiter		endp

; GetName- Reads a filename from the keyboard.  On entry, AL 
; contains the filename number and DI points at the buffer in ES 
; where the zero-terminated filename must be stored.

GetName		proc	near
		print
		byte	'Enter filename #',0
		putc
		mov	al, ':'
		putc
		gets
		ret
GetName		endp
cseg		ends

dseg		segment	byte public 'data'

PSP		word	?
Filename1	byte	128 dup (?)	;Source filename
Filename2	byte	128 dup (?)	;Destination filename
FileHandle1	word	?
FileHandle2	word	?
GotName1	byte	?
GotName2	byte	?
ConvertLC	byte	?
Buffer		byte	512 dup (?)

dseg		ends

sseg		segment		byte stack 'stack'
stk		word	0ffh dup (?)
sseg		ends

zzzzzzseg	segment		para public 'zzzzzz'
LastBytes	byte		16 dup (?)
zzzzzzseg	ends
		end	MainPgm
