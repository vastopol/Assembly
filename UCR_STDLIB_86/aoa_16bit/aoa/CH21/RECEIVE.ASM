; RECEIVE.ASM
;
; This program is the receiver portion of the programs that transmit files
; across a Laplink compatible parallel cable.
;
; This program assumes that the user want to use LPT1: for transmission.
; Adjust the equates, or read the port from the command line if this
; is inappropriate.

		.286
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

TimeOutConst	equ	100			;About 1 min on 66Mhz 486.
PrtrBase	equ	8			;Offset to LPT1: adrs.

MyPortAdrs	word	?			;Holds printer port address.
FileHandle	word	?			;Handle for output file.
FileBuffer	byte	512 dup (?)		;Buffer for incoming data.

FileSize	dword	?			;Size of incoming file.
FileName	byte	128 dup (0)		;Holds filename

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; TestAbort-	Reads the keyboard and gives the user the opportunity to
;		hit the ctrl-C key.

TestAbort	proc	near
		push	ax
		mov	ah, 1
		int	16h			;See if keypress.
		je	NoKeypress
		mov	ah, 8			;Read char, chk for ctrl-C
		int	21h
NoKeyPress:	pop	ax
		ret
TestAbort	endp



; GetByte-	Reads a single byte from the parallel port (four bits at
;		at time).  Returns the byte in AL.

GetByte		proc	near
		push	cx
		push	dx

; Receive the L.O. Nibble.

		mov	dx, MyPortAdrs
		mov	al, 10h			;Signal not busy.
		out	dx, al

		inc	dx			;Point at status port

W4DLp:		mov	cx, 10000
Wait4Data:	in	al, dx			;See if data available.
		test	al, 80h			; (bit 7=0 if data available).
		loopne	Wait4Data
		je	DataIsAvail		;Is data available?
		call	TestAbort		;If not, check for ctrl-C.
		jmp	W4DLp

DataIsAvail:	shr	al, 3			;Save this four bit package
		and	al, 0Fh			; (This is the L.O. nibble
		mov	ah, al			; for our byte).

		dec	dx			;Point at data register.
		mov	al, 0			;Signal data taken.
		out	dx, al

		inc	dx			;Point at status register.
W4ALp:		mov	cx, 10000
Wait4Ack:	in	al, dx			;Wait for transmitter to
		test	al, 80h			; retract data available.
		loope	Wait4Ack		;Loop until data not avail.
		jne	NextNibble		;Branch if data not avail.
		call	TestAbort		;Let user hit ctrl-C.
		jmp	W4ALp

; Receive the H.O. nibble:

NextNibble:	dec	dx			;Point at data register.
		mov	al, 10h			;Signal not busy
		out	dx, al
		inc	dx			;Point at status port
W4D2Lp:		mov	cx, 10000
Wait4Data2:	in	al, dx			;See if data available.
		test	al, 80h			; (bit 7=0 if data available).
		loopne	Wait4Data2		;Loop until data available.
		je	DataAvail2		;Branch if data available.
		call	TestAbort		;Check for ctrl-C.
		jmp	W4D2Lp

DataAvail2:	shl	al, 1			;Merge this H.O. nibble
		and	al, 0F0h		; with the existing L.O.
		or	ah, al			; nibble.
		dec	dx			;Point at data register.
		mov	al, 0			;Signal data taken.
		out	dx, al

		inc	dx			;Point at status register.
W4A2Lp:		mov	cx, 10000
Wait4Ack2:	in	al, dx			;Wait for transmitter to
		test	al, 80h			; retract data available.
		loope	Wait4Ack2               ;Wait for data not available.
		jne	ReturnData		;Branch if ack.
		call	TestAbort		;Check for ctrl-C
		jmp	W4A2Lp

ReturnData:	mov	al, ah			;Put data in al.
		pop	dx
		pop	cx
		ret
GetByte		endp




; Synchronize-	This procedure waits until it sees all zeros on the input
;		bits we receive from the transmiting site.  Once it receives
;		all zeros, it writes all ones to the output port.  When
;		all ones come back, it writes all zeros.  It repeats this
;		process until the transmiting site writes the value 05h.

Synchronize	proc	near

		print
		byte	"Synchronizing with transmitter program"
		byte	cr,lf,0

		mov	dx, MyPortAdrs
		mov	al, 0			;Initialize our output port
		out	dx, al			; to prevent confusion.
		mov	bx, TimeOutConst	;Time out condition.
SyncLoop:	mov	cx, 0			;For time out purposes.
SyncLoop0:	inc	dx			;Point at input port.
		in	al, dx			;Read our input bits.
		dec	dx
		and	al, 78h			;Keep only the data bits.
		cmp	al, 78h			;Check for all ones.
		je	Got1s			;Branch if all ones.
		cmp	al, 0			;See if all zeros.
		loopne	SyncLoop0

; Since we just saw a zero, write all ones to the output port.

		mov	al, 0FFh		;Write all ones
		out	dx, al

; Now wait for all ones to arrive from the transmiting site.

SyncLoop1:	inc	dx			;Point at status register.
		in	al, dx			;Read status port.
		dec	dx			;Point back at data register.
		and	al, 78h			;Keep only the data bits.
		cmp	al, 78h			;Are they all ones?
		loopne	SyncLoop1		;Repeat while not ones.
		je	Got1s			;Branch if got ones.

; If we've timed out, check to see if the user has pressed ctrl-C to
; abort.

		call	TestAbort		;Check for ctrl-C.
		dec	bx			;See if we've timed out.
		jne	SyncLoop		;Repeat if time-out.

		print
		byte	"Receive: connection timed out during synchronization"
		byte	cr,lf,0
		clc				;Signal time-out.
		ret

; Jump down here once we've seen both a zero and a one.  Send the two
; in combinations until we get a 05h from the transmiting site or the
; user presses Ctrl-C.

Got1s:          inc	dx			;Point at status register.
		in	al, dx			;Just copy whatever appears
		dec	dx			; in our input port to the
		shr	al, 3			; output port until the
		and	al, 0Fh			; transmiting site sends
		cmp	al, 05h			; us the value 05h
		je	Synchronized
		not	al			;Keep inverting what we get
		out	dx, al			; and send it to xmitter.
		call	TestAbort		;Check for CTRL-C here.
		jmp	Got1s


; Okay, we're synchronized.  Return to the caller.

Synchronized:
		and	al, 0Fh			;Make sure busy bit is one
		out	dx, al			; (bit 4=0 for busy=1).
		print
		byte	"Synchronized with transmiting site"
		byte	cr,lf,0
		stc
		ret
Synchronize	endp


; GetFileInfo-	The transmitting program sends us the file length and a
;		zero terminated filename.  Get that data here.

GetFileInfo	proc	near
		mov	dx, MyPortAdrs
		mov	al, 10h			;Set busy bit to zero.
		out	dx, al			;Tell xmit pgm, we're ready.

; First four bytes contain the filesize:

		call	GetByte
		mov	byte ptr FileSize, al
		call	GetByte
		mov	byte ptr FileSize+1, al
		call	GetByte
		mov	byte ptr FileSize+2, al
		call	GetByte
		mov	byte ptr FileSize+3, al

; The next n bytes (up to a zero terminating byte) contain the filename:

		mov	bx, 0
GetFileName:	call	GetByte
		mov	FileName[bx], al
		call	TestAbort
		inc	bx
		cmp	al, 0
		jne	GetFileName

		ret
GetFileInfo	endp


; GetFileData-	Receives the file data from the transmitting site
;		and writes it to the output file.

GetFileData	proc	near

; First, see if we have more than 512 bytes left to go

		cmp	word ptr FileSize+2, 0		;If H.O. word is not
		jne	MoreThan512			; zero, more than 512.
		cmp	word ptr FileSize, 512		;If H.O. is zero, just
		jbe	LastBlock			; check L.O. word.

; We've got more than 512 bytes left to go in this file, read 512 bytes
; at this point.

MoreThan512:	mov	cx, 512				;Receive 512 bytes
		lea	bx, FileBuffer			; from the xmitter.
ReadLoop:	call	GetByte				;Read a byte.
		mov	[bx], al			;Save the byte away.
		inc	bx				;Move on to next
		loop	ReadLoop			; buffer element.

; Okay, write the data to the file:

		mov	ah, 40h				;DOS write opcode.
		mov	bx, FileHandle			;Write to this file.
		mov	cx, 512				;Write 512 bytes.
		lea	dx, Filebuffer			;From this address.
		int	21h
		jc	BadWrite			;Quit if error.

; Decrement the file size by 512 bytes:

		sub	word ptr FileSize, 512		;32-bit subtraction
		sbb	word ptr FileSize, 0		; of 512.
		jmp	GetFileData

; Process the last block, that contains 1..511 bytes, here.

LastBlock:
		mov	cx, word ptr FileSize		;Receive the last
		lea	bx, FileBuffer			; 1..511 bytes from
ReadLB:		call	GetByte				; the transmitter.
		mov	[bx], al
		inc	bx
		loop	ReadLB

		mov	ah, 40h				;Write the last block
		mov	bx, FileHandle			; of bytes to the
		mov	cx, word ptr FileSize		; file.
		lea	dx, Filebuffer
		int	21h
		jnc	Closefile

BadWrite:	print
		byte	"DOS error #",0
		puti
		print
		byte	" while writing data.",cr,lf,0

; Close the file here.

CloseFile:	mov	bx, FileHandle			;Close this file.
		mov	ah, 3Eh				;DOS close opcode.
		int	21h
		ret
GetFileData	endp



; Here's the main program that gets the whole ball rolling.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		meminit


; First, get the address of LPT1: from the BIOS variables area.

		mov	ax, 40h		;Point at BIOS variable segment.
		mov	es, ax
		mov	ax, es:[PrtrBase]
		mov	MyPortAdrs, ax

		call	Synchronize	;Wait for the transmitter program.
		jnc	Quit

		call	GetFileInfo	;Get file name and size.

		printf
		byte	"Filename: %s\nFile size: %ld\n",0
		dword	Filename, FileSize

		mov	ah, 3Ch		;Create file.
		mov	cx, 0		;Standard attributes
		lea	dx, Filename
		int	21h
		jnc	GoodOpen
		print
		byte	"Error opening file",cr,lf,0
		jmp	Quit

GoodOpen:	mov	FileHandle, ax
		call	GetFileData	;Get the file's data.

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
