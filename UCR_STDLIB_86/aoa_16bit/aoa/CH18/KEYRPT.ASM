; This program reads the file created by the KEYEVAL.EXE TSR program.
; It displays the log containing dates, times, and number of keystrokes.

		.xlist
		.286
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

FileHandle	word	?

month		byte	0
day		byte	0
year		word	0
hour		byte	0
minute		byte	0
second		byte	0
KeyStrokes	word	0
RecSize		=	$-month

dseg		ends




cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; SeeIfPresent-	Checks to see if our TSR is present in memory.
;		Sets the zero flag if it is, clears the zero flag if
;		it is not.

SeeIfPresent	proc	near
		push	es
		push	ds
		pusha
		mov	cx, 0ffh		;Start with ID 0FFh.
IDLoop:		mov	ah, cl
		push	cx
		mov	al, 0			;Verify presence call.
		int	2Fh
		pop	cx
		cmp	al, 0			;Present in memory?
		je	TryNext
		strcmpl
		byte	"Keypress Logger TSR",0
		je	Success

TryNext:	dec	cl			;Test USER IDs of 80h..FFh
		js	IDLoop
		cmp	cx, 0			;Clear zero flag.
Success:	popa
		pop	ds
		pop	es
		ret
SeeIfPresent	endp



Main		proc
		meminit

		mov	ax, dseg
		mov	ds, ax



		argc
		cmp	cx, 1			;Must have exactly 1 parm.
		je	GoodParmCnt
		print
		byte	"Usage:",cr,lf
		byte	"       KEYRPT filename",cr,lf,0
		ExitPgm



GoodParmCnt:	mov	ax, 1
		argv

		print
		byte	"Keypress logger report program",cr,lf
		byte	"Processing file:",0
		puts
		putcr

		mov	ah, 3Dh			;Open file command.
		mov	al, 0			;Open for reading.
		push	ds
		push	es    			;Point ds:dx at name
		pop	ds
		mov	dx, di
		int	21h			;Open the file
		jnc	GoodOpen
		print
		byte	"DOS error #",0
		puti
		print
		byte	" opening file.",cr,lf,0
		ExitPgm

GoodOpen:	pop	ds
		mov	FileHandle, ax		;Save file handle.


; Okay, read the data and display it:

ReadLoop:	mov	ah, 3Fh			;Read file command
		mov	bx, FileHandle
		mov	cx, RecSize		;Number of bytes.
		mov	dx, offset month	;Place to put data.
		int	21h
		jc	ReadError
		test	ax, ax			;EOF?
		je	Quit

		mov	cx, year
		mov	dl, day
		mov	dh, month
		dtoam
		puts
		free
		print
		byte	",  ",0

		mov	ch, hour
		mov	cl, minute
		mov	dh, second
		mov	dl, 0
		ttoam
		puts
		free
		printf
		byte	",   keystrokes = %d\n",0
		dword	KeyStrokes
		jmp	ReadLoop

ReadError:	print
		byte	"Error reading file",cr,lf,0

Quit:		mov	bx, FileHandle
		mov	ah, 3Eh			;Close file
		int	21h
		ExitPgm

Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
