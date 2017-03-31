; TRANSMIT.ASM
;
; This program is the transmitter portion of the programs that transmit files
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

TimeOutConst	equ	4000			;About 1 min on 66Mhz 486.
PrtrBase	equ	10			;Offset to LPT1: adrs.

MyPortAdrs	word	?			;Holds printer port address.
FileHandle	word	?			;Handle for output file.
FileBuffer	byte	512 dup (?)		;Buffer for incoming data.

FileSize	dword	?			;Size of incoming file.
FileNamePtr	dword	?			;Holds ptr to filename

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; TestAbort-	Check to see if the user has pressed ctrl-C and wants to
;		abort this program.  This routine calls BIOS to see if the
;		user has pressed a key.  If so, it calls DOS to read the
;		key (function AH=8, read a key w/o echo and with ctrl-C
;		checking).

TestAbort	proc	near
		push	ax
		push	cx
		push	dx
		mov	ah, 1
		int	16h			;See if keypress.
		je	NoKeyPress		;Return if no keypress.
		mov	ah, 8			;Read char, chk for ctrl-C.
		int	21h			;DOS aborts if ctrl-C.
NoKeyPress:	pop	dx
		pop	cx
		pop	ax
		ret
TestAbort	endp



; SendByte-	Transmit the byte in AL to the receiving site four bits
;		at a time.

SendByte	proc	near
		push	cx
		push	dx
		mov	ah, al		;Save byte to xmit.

		mov	dx, MyPortAdrs	;Base address of LPT1: port.

; First, just to be sure, write a zero to bit #4.  This reads as a one
; in the busy bit of the receiver.

		mov	al, 0
		out	dx, al		;Data not ready yet.

; Wait until the receiver is not busy.  The receiver will write a zero
; to bit #4 of its data register while it is busy. This comes out as a
; one in our busy bit (bit 7 of the status register).  This loop waits
; until the receiver tells us its ready to receive data by writing a
; one to bit #4 (which we read as a zero).  Note that we check for a
; ctrl-C every so often in the event the user wants to abort the
; transmission.

		inc	dx		;Point at status register.
W4NBLp:		mov	cx, 10000
Wait4NotBusy:	in	al, dx		;Read status register value.
		test	al, 80h		;Bit 7 = 1 if busy.
		loopne	Wait4NotBusy	;Repeat while busy, 10000 times.
		je	ItsNotbusy	;Leave loop if not busy.
		call	TestAbort	;Check for Ctrl-C.
		jmp	W4NBLp

; Okay, put the data on the data lines:

ItsNotBusy:	dec	dx		;Point at data register.
		mov	al, ah		;Get a copy of the data.
		and	al, 0Fh		;Strip out H.O. nibble
		out	dx, al		;"Prime" data lines, data not avail.
		jmp	$+2		;Short delay to allow the data time
		jmp	$+2		; to stablize on the data lines.
		or	al, 10h		;Turn data available on.
		out	dx, al		;Send data w/data available strobe.

; Wait for the acknowledge from the receiving site.  Every now and then
; check for a ctrl-C so the user can abort the transmission program from
; within this loop.

		inc	dx		;Point at status register.
W4ALp:		mov	cx, 10000	;Times to loop between ctrl-C checks.
Wait4Ack:	in	al, dx		;Read status port.
		test	al, 80h		;Ack = 1 when rcvr acknowledges.
		loope	Wait4Ack	;Repeat 10000 times or until ack.
		jne	GotAck		;Branch if we got an ack.
		call	TestAbort	;Every 10000 calls, check for a
		jmp	W4ALp		; ctrl-C from the user.

; Send the data not available signal to the receiver:

GotAck:		dec	dx		;Point at data register.
		mov	al, 0		;Write a zero to bit 4, this appears
		out	dx, al		; as a one in the rcvr's busy bit.


; Okay, on to the H.O. nibble:

		inc	dx		;Point at status register.
W4NB2:		mov	cx, 10000	;10000 calls between ctrl-C checks.
Wait4NotBusy2:	in	al, dx		;Read status register.
		test	al, 80h		;Bit 7 = 1 if busy.
		loopne	Wait4NotBusy2	;Loop 10000 times while busy.
		je	NotBusy2	;H.O. bit clear (not busy)?
		call	TestAbort	;Check for ctrl-C.
		jmp	W4NB2

; Okay, put the data on the data lines:

NotBusy2:	dec	dx		;Point at data register.
		mov	al, ah		;Retrieve data to get H.O. nibble.
		shr	al, 4		;Move H.O. nibble to L.O. nibble.
		out	dx, al		;"Prime" data lines.
		or	al, 10h		;Data + data available strobe.
		out	dx, al		;Send data w/data available strobe.

; Wait for the acknowledge from the receiving site:

		inc	dx		;Point at status register.
W4A2Lp:		mov	cx, 10000
Wait4Ack2:	in	al, dx		;Read status port.
		test	al, 80h		;Ack = 1
		loope	Wait4Ack2	;While while no acknowledge
		jne	GotAck2		;H.O. bit = 1 (ack)?
		call	TestAbort	;Check for ctrl-C
		jmp	W4A2Lp

; Send the data not available signal to the receiver:

GotAck2:	dec	dx		;Point at data register.
		mov	al, 0		;Output a zero to bit #4 (that
		out	dx, al		; becomes busy=1 at rcvr).

		mov	al, ah		;Restore original data in AL.
		pop	dx
		pop	cx
		ret
SendByte	endp



; Synchronization routines:
;
; Send0s-	Transmits a zero to the receiver site and then waits to
;		see if it gets a set of ones back.  Returns carry set if
;		this works, returns carry clear if we do not get a set of
;		ones back in a reasonable amount of time.

Send0s		proc	near
		push	cx
		push	dx

		mov	dx, MyPortAdrs

		mov	al, 0			;Write the initial zero
		out	dx, al			; value to our output port.

		xor	cx, cx			;Checks for ones 10000 times.
Wait41s:	inc	dx			;Point at status port.
		in	al, dx			;Read status port.
		dec	dx			;Point back at data port.
		and	al, 78h			;Mask input bits.
		cmp	al, 78h			;All ones yet?
		loopne	Wait41s
		je	Got1s			;Branch if success.
		clc				;Return failure.
		pop	dx
		pop	cx
		ret

Got1s:		stc				;Return success.
		pop	dx
		pop	cx
		ret
Send0s		endp


; Send1s-	Transmits all ones to the receiver site and then waits to
;		see if it gets a set of zeros back.  Returns carry set if
;		this works, returns carry clear if we do not get a set of
;		zeros back in a reasonable amount of time.

Send1s		proc	near
		push	cx
		push	dx

		mov	dx, MyPortAdrs		;LPT1: base address.

		mov	al, 0Fh			;Write the "all ones"
		out	dx, al			; value to our output port.

		mov	cx, 0
Wait40s:	inc	dx			;Point at input port.
		in	al, dx			;Read the status port.
		dec	dx			;Point back at data port.
		and	al, 78h			;Mask input bits.
		loopne	Wait40s			;Loop until we get zero back.
		je	Got0s			;All zeros?  If so, branch.
		clc				;Return failure.
		pop	dx
		pop	cx
		ret


Got0s:		stc				;Return success.
		pop	dx
		pop	cx
		ret
Send1s		endp




; Synchronize-	This procedure slowly writes all zeros and all ones to its
;		output port and checks the input status port to see if the
;		receiver site has synchronized.  When the receiver site
;		is synchronized, it will write the value 05h to its output
;		port.  So when this site sees the value 05h on its input
;		port, both sites are synchronized.  Returns with the
;		carry flag set if this operation is successful, clear if
;		unsuccessful.

Synchronize	proc	near
		print
		byte	"Synchronizing with receiver program"
		byte	cr,lf,0

		mov	dx, MyPortAdrs

		mov	cx, TimeOutConst	;Time out delay.
SyncLoop:	call	Send0s			;Send zero bits, wait for
		jc	Got1s			; ones (carry set=got ones).

; If we didn't get what we wanted, write some ones at this point and see
; if we're out of phase with the receiving site.

Retry0:		call	Send1s			;Send ones, wait for zeros.
		jc	SyncLoop		;Carry set = got zeros.

; Well, we didn't get any response yet, see if the user has pressed ctrl-C
; to abort this program.

DoRetry:	call	TestAbort

; Okay, the receiving site has yet to respond.  Go back and try this again.

		loop	SyncLoop

; If we've timed out, print an error message and return with the carry
; flag clear (to denote a timeout error).

		print
		byte	"Transmit: Timeout error waiting for receiver"
		byte	cr,lf,0
		clc
		ret

; Okay, we wrote some zeros and we got some ones.  Let's write some ones
; and see if we get some zeros.  If not, retry the loop.

Got1s:
		call	Send1s			;Send one bits, wait for
		jnc	DoRetry			; zeros (carry set=got zeros).

; Well, we seem to be synchronized.  Just to be sure, let's play this out
; one more time.

		call	Send0s			;Send zeros, wait for ones.
		jnc	Retry0
		call	Send1s			;Send ones, wait for zeros.
		jnc	DoRetry

; We're syncronized.  Let's send out the 05h value to the receiving
; site to let it know everything is cool:

		mov	al, 05h			;Send signal to receiver to
		out	dx, al			; tell it we're sync'd.

		xor	cx, cx			;Long delay to give the rcvr
FinalDelay:	loop	FinalDelay		; time to prepare.

		print
		byte	"Synchronized with receiving site"
		byte	cr,lf,0
		stc
		ret
Synchronize	endp



; File I/O routines:
;
; GetFileInfo-	Opens the user specified file and passes along the file
;		name and file size to the receiving site.  Returns the
;		carry flag set if this operation is successful, clear if
;		unsuccessful.

GetFileInfo	proc	near

; Get the filename from the DOS command line:

		mov	ax, 1
		argv
		mov	word ptr FileNamePtr, di
		mov	word ptr FileNamePtr+2, es

		printf
		byte	"Opening %^s\n",0
		dword	FileNamePtr

; Open the file:

		push	ds
		mov	ax, 3D00h		;Open for reading.
		lds	dx, FileNamePtr
		int	21h
		pop	ds
		jc	BadFile
		mov	FileHandle, ax

; Compute the size of the file (do this by seeking to the last position
; in the file and using the return position as the file length):

		mov	bx, ax			;Need handle in BX.
		mov	ax, 4202h		;Seek to end of file.
		xor	cx, cx			;Seek to position zero
		xor	dx, dx			; from the end of file.
		int	21h
		jc	BadFile

		mov	word ptr FileSize, ax	;Save file length
		mov	word ptr FileSize+2, dx

; Need to rewind file back to the beginning (seek to position zero):

		mov	bx, FileHandle		;Need handle in BX.
		mov	ax, 4200h		;Seek to beginning of file.
		xor	cx, cx			;Seek to position zero
		xor	dx, dx
		int	21h
		jc	BadFile


; Okay, transmit the good stuff over to the receiving site:

		mov	al, byte ptr FileSize		;Send the file
		call	SendByte			; size over.
		mov	al, byte ptr FileSize+1
		call	SendByte
		mov	al, byte ptr FileSize+2
		call	SendByte
		mov	al, byte ptr FileSize+3
		call	SendByte

		les	bx, FileNamePtr			;Send the characters
SendName:	mov	al, es:[bx]			; in the filename to
		call	SendByte			; the receiver until
		inc	bx				; we hit a zero byte.
		cmp	al, 0
		jne	SendName
		stc					;Return success.
		ret

BadFile:	print
		byte	"Error transmitting file information:",0
		puti
		putcr
		clc
		ret
GetFileInfo	endp


; GetFileData-	This procedure reads the data from the file and transmits
;		it to the receiver a byte at a time.

GetFileData	proc	near
		mov	ah, 3Fh			;DOS read opcode.
		mov	cx, 512			;Read 512 bytes at a time.
		mov	bx, FileHandle		;File to read from.
		lea	dx, FileBuffer		;Buffer to hold data.
		int	21h			;Read the data
		jc	GFDError		;Quit if error reading data.

		mov	cx, ax			;Save # of bytes actually read.
		jcxz	GFDDone			; quit if at EOF.
		lea	bx, FileBuffer		;Send the bytes in the file
XmitLoop:	mov	al, [bx]		; buffer over to the rcvr
		call	SendByte		; one at a time.
		inc	bx
		loop	XmitLoop
		jmp	GetFileData		;Read rest of file.

GFDError:	print
		byte	"DOS error #",0
		puti
		print
		byte	" while reading file",cr,lf,0
GFDDone:	ret
GetFileData	endp



; Okay, here's the main program that controls everything.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		meminit


; First, get the address of LPT1: from the BIOS variables area.

		mov	ax, 40h
		mov	es, ax
		mov	ax, es:[PrtrBase]
		mov	MyPortAdrs, ax

; See if we have a filename parameter:

		argc
		cmp	cx, 1
		je	GotName
		print
		byte	"Usage: transmit <filename>",cr,lf,0
		jmp	Quit



GotName:	call	Synchronize	;Wait for the transmitter program.
		jnc	Quit

		call	GetFileInfo	;Get file name and size.
		jnc	Quit

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
