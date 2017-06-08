; FCMP.ASM-	A file comparison program that demonstrates the use
;		of the 80x86 string instructions.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

Name1		dword	?		;Ptr to filename #1
Name2		dword	?		;Ptr to filename #2
Handle1		word	?		;File handle for file #1
Handle2		word	?		;File handle for file #2
LineCnt		word	0		;# of lines in the file.

Buffer1		db	256 dup (0)	;Block of data from file 1
Buffer2		db	256 dup (0)	;Block of data from file 2

dseg		ends

wp		equ	<word ptr>


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Error- Prints a DOS error message depending upon the error type.

Error		proc	near
		cmp	ax, 2
		jne	NotFNF
		print
		db	"File not found",0
		jmp	ErrorDone

NotFNF:		cmp	ax, 4
		jne	NotTMF
		print
		db	"Too many open files",0
		jmp	ErrorDone

NotTMF:		cmp	ax, 5
		jne	NotAD
		print
		db	"Access denied",0
		jmp	ErrorDone

NotAD:		cmp	ax, 12
		jne	NotIA
		print
		db	"Invalid access",0
		jmp	ErrorDone

NotIA:
ErrorDone:	putcr
		ret
Error		endp




; Okay, here's the main program.  It opens two files, compares them, and
; complains if they're different.

Main		proc
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax

		meminit

; File comparison routine.  First, open the two source files.

		argc
		cmp	cx, 2		;Do we have two filenames?
		je	GotTwoNames
		print
		db	"Usage: fcmp file1 file2",cr,lf,0
		jmp	Quit

GotTwoNames:	mov	ax, 1		;Get first file name
		argv
		mov	wp Name1, di
		mov	wp Name1+2, es

; Open the files by calling DOS.

		mov	ax, 3d00h	;Open for reading
		lds	dx, Name1
		int	21h
		jnc	GoodOpen1
		printf
		db	"Error opening %^s:",0
		dd	Name1
		call	Error
		jmp	Quit

GoodOpen1:	mov	dx, dseg
		mov	ds, dx
		mov	Handle1, ax

		mov	ax, 2		;Get second file name
		argv
		mov	wp Name2, di
		mov	wp Name2+2, es

		mov	ax, 3d00h	;Open for reading
		lds	dx, Name2
		int	21h
		jnc	GoodOpen2
		printf
		db	"Error opening %^s:",0
		dd	Name2
		call	Error
		jmp	Quit

GoodOpen2:	mov	dx, dseg
		mov	ds, dx
		mov	Handle2, ax

; Read the data from the files using blocked I/O
; and compare it.

		mov	LineCnt, 1
CmpLoop:	mov	bx, Handle1	;Read 256 bytes from
		mov	cx, 256		; the first file into
		lea	dx, Buffer1	; Buffer1.
		mov	ah, 3fh
		int	21h
		jc	FileError
		cmp	ax, 256		;Leave if at EOF.
		jne	EndOfFile

		mov	bx, Handle2	;Read 256 bytes from
		mov	cx, 256		; the second file into
		lea	dx, Buffer2	; Buffer2
		mov	ah, 3fh
		int	21h
		jc	FileError
		cmp	ax, 256		;If we didn't read 256 bytes,
		jne	BadLen		; the files are different.

; Okay, we've just read 256 bytes from each file, compare the buffers
; to see if the data is the same in both files.

		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		mov	cx, 256
		lea	di, Buffer1
		lea	si, Buffer2
		cld
	repe	cmpsb
		jne	BadCmp
		jmp	CmpLoop


FileError:	print
		db	"Error reading files: ",0
		call	Error
		jmp	Quit


BadLen:		print
		db	"File lengths were different",cr,lf,0

BadCmp:		print
		db      7,"Files were not equal",cr,lf,0

		mov	ax, 4c01h		;Exit with error.
		int	21h


; If we reach the end of the first file, compare any remaining bytes
; in that first file against the remaining bytes in the second file.

EndOfFile:	push	ax			;Save final length.
		mov	bx, Handle2
		mov	cx, 256
		lea	dx, Buffer2
		mov	ah, 3fh
		int	21h
		jc	BadCmp

		pop	bx			;Retrieve file1's length.
		cmp	ax, bx			;See if file2 matches it.
		jne	BadLen

		mov	cx, ax			;Compare the remaining
		mov	ax, dseg		; bytes down here.
		mov	ds, ax
		mov	es, ax
		lea	di, Buffer2
		lea	si, Buffer1
	repe	cmpsb
		jne	BadCmp

Quit:		mov	ax, 4c00h		;Set Exit code to okay.
		int	21h
Main		endp

cseg            ends



; Allocate a reasonable amount of space for the stack (2k).

sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends


; zzzzzzseg must be the last segment that gets loaded into memory!

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
