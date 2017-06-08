		.286
		page	58, 132
		name	SGDI
		title	SGDI Driver for Standard Game Adapter Card
		subttl	This Program is Public Domain Material.

; SGDI.EXE
;
;	Usage:
;		SDGI
;
; This program loads a TSR which patches INT 15 so arbitrary game programs
; can read the joystick in a portable fashion.
;
;
; We need to load cseg in memory before any other segments!

cseg		segment	para public 'code'
cseg		ends


; Initialization code, which we do not need except upon initial load,
; goes in the following segment:

Initialize	segment	para public 'INIT'
Initialize	ends

; UCR Standard Library routines which get dumped later on.

		.xlist
		include		stdlib.a
		includelib	stdlib.lib
		.list

sseg		segment	para stack 'stack'
sseg		ends

zzzzzzseg	segment	para public 'zzzzzzseg'
zzzzzzseg	ends



CSEG		segment	para public 'CODE'
		assume	cs:cseg, ds:nothing

wp		equ	<word ptr>
byp		equ	<byte ptr>

Int15Vect	dd	0

PSP		dw	?

; Port addresses for a typical joystick card:

JoyPort		equ	201h
JoyTrigger	equ	201h

; Data structure to hold information about each pot.
; (mainly for calibration and normalization purposes).

Pot		struc
PotMask		db	0			;Pot mask for hardware.
DidCal		db	0			;Is this pot calibrated?
min		dw	5000			;Minimum pot value
max		dw	0			;Max pot value
center		dw	0			;Pot value in the middle
Pot		ends

; Variables for each of the pots.  Must initialize the masks so they
; mask out all the bits except the incomming bit for each pot.

Pot0		Pot	<1>
Pot1		Pot	<2>
Pot2		Pot	<4>
Pot3		Pot	<8>



; The IDstring address gets passed back to the caller on a testpresence
; call.  The four bytes before the IDstring must contain the serial number
; and current driver number.

SerialNumber	db	0,0,0
IDNumber	db	0
IDString	db	"Standard SGDI Driver",0
		db	"Public Domain Driver Written by Randall L. Hyde",0


;============================================================================
;
; ReadPots- AH contains a bit mask to determine which pots we should read.
;	    Bit 0 is one if we should read pot 0, bit 1 is one if we should
;	    read pot 1, bit 2 is one if we should read pot 2, bit 3 is one
;	    if we should read pot 3.  All other bits will be zero.
;
;	This code returns the pot values in SI, BX, BP, and DI for Pot 0, 1,
;	2, & 3.
;

ReadPots	proc	near
		sub	bp, bp
		mov	si, bp
		mov	di, bp
		mov	bx, bp

; Wait for any previous signals to finish up before trying to read this
; guy.  It is possible that the last pot we read was very short.  However,
; the trigger signal starts timers running for all four pots.  This code
; terminates as soon as the current pot times out.  If the user immediately
; reads another pot, it is quite possible that the new pot's timer has
; not yet expired from the previous read.  The following loop makes sure we
; aren't measuring the time from the previous read.

		mov	dx, JoyPort
		mov	cx, 400h
Wait4Clean:	in	al, dx
		and	al, 0Fh
		loopnz	Wait4Clean

; Okay, read the pots.  The following code triggers the 558 timer chip
; and then sits in a loop until all four pot bits (masked with the pot mask
; in AL) become zero.  Each time through this loop that one or more of these
; bits contain zero, this loop increments the corresponding register(s).

		mov	dx, JoyTrigger
		out	dx, al		;Trigger pots
		mov	dx, JoyPort
		mov	cx, 1000h	;Don't let this go on forever.
PotReadLoop:	in	al, dx
		and	al, ah
		jz	PotReadDone
		shr	al, 1
		adc	si, 0		;Increment SI if pot 0 still active.
		shr	al, 1
		adc	bx, 0		;Increment BX if pot 1 still active.
		shr	al, 1
		adc	bp, 0		;Increment BP if pot 2 still active.
		shr	al, 1
		adc	di, 0		;Increment DI if pot 3 still active.
		loop	PotReadLoop	;Stop, eventually, if funny hardware.

		and	si, 0FFFh	;If we drop through to this point,
		and	bx, 0FFFh	; one or more pots timed out (usually
		and	bp, 0FFFh	; because they are not connected).
		and	di, 0FFFh	; The reg contains 4000h, set it to 0.
PotReadDone:
		ret
ReadPots	endp



;----------------------------------------------------------------------------
;
; Normalize- 	BX contains a pointer to a pot structure, AX contains
;		a pot value.  Normalize that value according to the
;		calibrated pot.
;
; Note: DS must point at cseg before calling this routine.


		assume	ds:cseg
Normalize	proc	near
		push	cx

; Sanity check to make sure the calibration process went okay.

		cmp	[bx].Pot.DidCal, 0	;Is this pot calibrated?
		je	BadNorm			;If not, quit.

		mov	dx, [bx].Pot.Center	;Do a sanity check on the
		cmp	dx, [bx].Pot.Min	; min, center, and max
		jbe	BadNorm			; values to make sure
		cmp	dx, [bx].Pot.Max	; min < center < max.
		jae	BadNorm

; Clip the value if it is out of range.

		cmp	ax, [bx].Pot.Min	;If the value is less than
		ja	MinOkay			; the minimum value, set it
		mov	ax, [bx].Pot.Min	; to the minimum value.
MinOkay:

		cmp	ax, [bx].Pot.Max	;If the value is greater than
		jb	MaxOkay			; the maximum value, set it
		mov	ax, [bx].Pot.Max	; to the maximum value.
MaxOkay:

; Scale this guy around the center:

		cmp	ax, [bx].Pot.Center	;See if less than or greater
		jb	Lower128		; than centered value.

; Okay, current reading is greater than the centered value, scale the reading
; into the range 128..255 here:

		sub	ax, [bx].Pot.Center
		mov	dl, ah			;Multiply by 128
		mov	ah, al
		mov	dh, 0
		mov	al, dh
		shr	dl, 1
		rcr	ax, 1
		mov	cx, [bx].Pot.Max
		sub	cx, [bx].Pot.Center
		jz	BadNorm			;Prevent division by zero.
		div	cx			;Compute normalized value.
		add	ax, 128			;Scale to range 128..255.
		cmp	ah, 0
		je	NormDone
		mov	ax, 0ffh	;Result must fit in 8 bits!
		jmp	NormDone

; If the reading is below the centered value, scale it into the range
; 0..127 here:

Lower128:	sub	ax, [bx].Pot.Min
		mov	dl, ah
		mov	ah, al
		mov	dh, 0
		mov	al, dh
		shr	dl, 1
		rcr	ax, 1
		mov	cx, [bx].Pot.Center
		sub	cx, [bx].Pot.Min
		jz	BadNorm
		div	cx
		cmp	ah, 0
		je	NormDone
		mov	ax, 0ffh
		jmp	NormDone

; If something went wrong, return zero as the normalized value.

BadNorm:	sub	ax, ax

NormDone:	pop	cx
		ret
Normalize	endp
		assume	ds:nothing

;============================================================================
; INT 15h handler functions.
;============================================================================
;
; Although these are defined as near procs, they are not really procedures.
; The MyInt15 code jumps to each of these with BX, a far return address, and
; the flags sitting on the stack.  Each of these routines must handle the
; stack appropriately.
;
;----------------------------------------------------------------------------
; BIOS- Handles the two BIOS calls, DL=0 to read the switches, DL=1 to
;	read the pots.  For the BIOS routines, we'll ignore the cooley
;	switch (the hat) and simply read the other four switches.

BIOS		proc	near
		cmp	dl, 1		;See if switch or pot routine.
		jb	Read4Sw
		je	ReadBIOSPots

; If not a valid BIOS call, jump to the original INT 15 handler and
; let it take care of this call.

		pop	bx
		jmp	cs:Int15Vect	;Let someone else handle it!

; BIOS read switches function.

Read4Sw:	push	dx
		mov	dx, JoyPort
		in	al, dx
		and	al, 0F0h	;Return only switch values.
		pop	dx
		pop	bx
		iret

; BIOS read pots function.

ReadBIOSPots:	pop	bx		;Return a value in BX!
		push	si
		push	di
		push	bp
		mov	ah, 0Fh		;Read all four pots.
		call	ReadPots
		mov	ax, si
		mov	cx, bp		;BX already contains pot 1 reading.
		mov	dx, di
		pop	bp
		pop	di
		pop	si
		iret
BIOS		endp

;----------------------------------------------------------------------------
;
; ReadPot-	On entry, DL contains a pot number to read.
;		Read and normalize that pot and return the result in AL.

		assume	ds:cseg
ReadPot		proc	near
;;;;;;;;;;	push	bx		;Already on stack.
		push	ds
		push	cx
		push	dx
		push	si
		push	di
		push	bp

		mov	bx, cseg
		mov	ds, bx

; If dl = 0, read and normalize the value for pot 0, if not, try some
; other pot.

		cmp	dl, 0
		jne	Try1
		mov	ah, Pot0.PotMask	;Get bit for this pot.
		call	ReadPots		;Read pot 0.
		lea	bx, Pot0		;Pointer to pot data.
		mov	ax, si			;Get pot 0 reading.
		call	Normalize		;Normalize to 0..FFh.
		jmp	GotPot			;Return to caller.

; Test for DL=1 here (read and normalize pot 1).

Try1:		cmp	dl, 1
		jne	Try2
		mov	ah, Pot1.PotMask
		call	ReadPots
		mov	ax, bx
		lea	bx, Pot1
		call	Normalize
		jmp	GotPot

; Test for DL=2 here (read and normalize pot 2).

Try2:		cmp	dl, 2
		jne	Try3
		mov	ah, Pot2.PotMask
		call	ReadPots
		lea	bx, Pot2
		mov	ax, bp
		call	Normalize
		jmp	GotPot

; Test for DL=3 here (read and normalize pot 3).

Try3:		cmp	dl, 3
		jne	BadPot
		mov	ah, Pot3.PotMask
		call	ReadPots
		lea	bx, Pot3
		mov	ax, di
		call	Normalize
		jmp	GotPot

; Bad value in DL if we drop to this point.  The standard game card
; only supports four pots.

BadPot:		sub	ax, ax		;Pot not available, return zero.
GotPot:		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		iret
ReadPot		endp
		assume	ds:nothing


;----------------------------------------------------------------------------
;
; ReadRaw-	On entry, DL contains a pot number to read.
;		Read that pot and return the unnormalized result in AX.

		assume	ds:cseg
ReadRaw		proc	near
;;;;;;;;;;	push	bx		;Already on stack.
		push	ds
		push	cx
		push	dx
		push	si
		push	di
		push	bp

		mov	bx, cseg
		mov	ds, bx

; This code is almost identical to the ReadPot code.  The only difference
; is that we don't bother normalizing the result and (of course) we return
; the value in AX rather than AL.

		cmp	dl, 0
		jne	Try1
		mov	ah, Pot0.PotMask
		call	ReadPots
		mov	ax, si
		jmp	GotPot

Try1:		cmp	dl, 1
		jne	Try2
		mov	ah, Pot1.PotMask
		call	ReadPots
		mov	ax, bx
		jmp	GotPot

Try2:		cmp	dl, 2
		jne	Try3
		mov	ah, Pot2.PotMask
		call	ReadPots
		mov	ax, bp
		jmp	GotPot

Try3:		cmp	dl, 3
		jne	BadPot
		mov	ah, Pot3.PotMask
		call	ReadPots
		mov	ax, di
		jmp	GotPot

BadPot:		sub	ax, ax		;Pot not available, return zero.
GotPot:		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		iret
ReadRaw		endp
		assume	ds:nothing


;----------------------------------------------------------------------------
; Read4Pots-	Reads pots zero, one, two, and three returning their
;		values in AL, AH, DL, and DH.
;
;		On entry, AL contains the pot mask to select which pots
;		we should read (bit 0=1 for pot 0, bit 1=1 for pot 1, etc).

Read4Pots	proc	near
;;;;;;;;;;;	push	bx		;Already on stack
		push	ds
		push	cx
		push	si
		push	di
		push	bp

		mov	dx, cseg
		mov	ds, dx

		mov	ah, al
		call	ReadPots

		push	bx			;Save pot 1 reading.
		mov	ax, si			;Get pot 0 reading.
		lea	bx, Pot0		;Point bx at pot0 vars.
		call	Normalize		;Normalize.
		mov	cl, al			;Save for later.

		pop	ax			;Retreive pot 1 reading.
		lea	bx, Pot1
		call	Normalize
		mov	ch, al			;Save normalized value.

		mov	ax, bp
		lea	bx, Pot2
		call	Normalize
		mov	dl, al			;Pot 2 value.

		mov	ax, di
		lea	bx, Pot3
		call	Normalize
		mov	dh, al			;Pot 3 value.
		mov	ax, cx			;Pots 0 and 1.

		pop	bp
		pop	di
		pop	si
		pop	cx
		pop	ds
		pop	bx
		iret
Read4Pots	endp




;----------------------------------------------------------------------------
; CalPot-	Calibrate the pot specified by DL.  On entry, AL contains
;		the minimum pot value (it better be less than 256!), BX
;		contains the maximum pot value, and CX contains the centered
;		pot value.

		assume	ds:cseg
CalPot		proc	near
		pop	bx		;Retrieve maximum value
		push	ds
		push	si
		mov	si, cseg
		mov	ds, si

; Sanity check on parameters, sort them in ascending order:

		mov	ah, 0
		cmp	bx, cx			;Make sure center < max
		ja	GoodMax
		xchg	bx, cx
GoodMax:	cmp	ax, cx			;Make sure min < center.
		jb	GoodMin			; (note: may make center<max).
		xchg	ax, cx
GoodMin:	cmp	cx, bx			;Again, be sure center < max.
		jb	GoodCenter
		xchg	cx, bx
GoodCenter:


; Okay, figure out who were supposed to calibrate:

		lea	si, Pot0
		cmp	dl, 1
		jb	DoCal			;Branch if this is pot 0
		lea	si, Pot1
		je	DoCal			;Branch if this is pot 1
		lea	si, Pot2
		cmp	dl, 3
		jb	DoCal			;Branch if this is pot 2
		jne	CalDone			;Branch if not pot 3
		lea	si, Pot3

DoCal:		mov	[si].Pot.min, ax	;Store away the minimum,
		mov	[si].Pot.max, bx	; maximum, and
		mov	[si].Pot.center, cx	; centered values.
		mov	[si].Pot.DidCal, 1	;Note we've cal'd this pot.
CalDone:	pop	si
		pop	ds
		iret
CalPot		endp
		assume	ds:nothing


;----------------------------------------------------------------------------
; TestCal-	Just checks to see if the pot specified by DL has already
;		been calibrated.

		assume	ds:cseg
TestCal		proc	near
;;;;;;;;	push	bx		;Already on stack
		push	ds
		mov	bx, cseg
		mov	ds, bx

		sub	ax, ax		;Assume no calibration (also zeros AH)
		lea	bx, Pot0	;Get the address of the specified
		cmp	dl, 1		; pot's data structure into the
		jb	GetCal		; BX register.
		lea	bx, Pot1
		je	GetCal
		lea	bx, Pot2
		cmp	dl, 3
		jb	GetCal
		jne	BadCal
		lea	bx, Pot3

GetCal:		mov	al, [bx].Pot.DidCal
BadCal:		pop	ds
		pop	bx
		iret
TestCal		endp
		assume	ds:nothing


;----------------------------------------------------------------------------
;
; ReadSw-	Reads the switch whose switch number appears in DL.

ReadSw		proc	near
;;;;;;;		push	bx		;Already on stack
		push	cx

		sub	ax, ax		;Assume no such switch.
		cmp	dl, 3  		;Return if the switch number is
		ja	NotDown		; greater than three.

		mov	cl, dl		;Save switch to read.
		add	cl, 4		;Move from position four down to zero.
		mov	dx, JoyPort
		in	al, dx		;Read the switches.
		shr	al, cl		;Move desired switch bit into bit 0.
		xor	al, 1		;Invert so sw down=1.
		and	ax, 1		;Remove other junk bits.
NotDown:	pop	cx
		pop	bx
		iret
ReadSw		endp


;----------------------------------------------------------------------------
;
; Read16Sw-	Reads all four switches and returns their values in AX.

Read16Sw	proc	near
;;;;;;;;	push	bx		;Already on stack
		mov	dx, JoyPort
		in	al, dx
		shr	al, 4
		xor	al, 0Fh		;Invert all switches.
		and	ax, 0Fh		;Set other bits to zero.
		pop	bx
		iret
Read16Sw	endp


;****************************************************************************
;
; MyInt15-	Patch for the BIOS INT 15 routine to control reading the
;		joystick.

MyInt15		proc	far
		push	bx
		cmp	ah, 84h			;Joystick code?
		je	DoJoystick
OtherInt15:	pop	bx
		jmp	cs:Int15Vect

DoJoystick:	mov	bh, 0
		mov	bl, dh
		cmp	bl, 80h
		jae	VendorCalls
		cmp	bx, JmpSize
		jae	OtherInt15
		shl	bx, 1
		jmp	wp cs:jmptable[bx]

jmptable	word	BIOS
		word	ReadPot, Read4Pots, CalPot, TestCal
		word	ReadRaw, OtherInt15, OtherInt15
		word	ReadSw, Read16Sw
JmpSize		=	($-jmptable)/2


; Handle vendor specific calls here.

VendorCalls:	je	RemoveDriver
		cmp	bl, 81h
		je	TestPresence
		pop	bx
		jmp	cs:Int15Vect


; TestPresence- Returns zero in AX and a pointer to the ID string in ES:BX

TestPresence:	pop	bx		;Get old value off stack.
		sub	ax, ax
		mov	bx, cseg
		mov	es, bx
		lea	bx, IDString
		iret

; RemoveDriver- If there are no other drivers loaded after this one in
;		memory, disconnect it and remove it from memory.

RemoveDriver:
		push	ds
		push	es
		push	ax
		push	dx

		mov	dx, cseg
		mov	ds, dx

; See if we're the last routine patched into INT 15h

		mov	ax, 3515h
		int	21h
		cmp	bx, offset MyInt15
		jne	CantRemove
		mov	bx, es
		cmp	bx, wp seg MyInt15
		jne	CantRemove

		mov	ax, PSP			;Free the memory we're in
		mov	es, ax
		push	es
		mov	ax, es:[2ch] 		;First, free env block.
		mov	es, ax
		mov	ah, 49h
		int	21h

		pop	es			;Now free program space.
		mov	ah, 49h
		int	21h

		lds	dx, Int15Vect		;Restore previous int vect.
		mov	ax, 2515h
		int	21h

CantRemove:	pop	dx
		pop	ax
		pop	es
		pop	ds
		pop	bx
		iret
MyInt15		endp
cseg		ends



Initialize	segment	para public 'INIT'
		assume	cs:Initialize, ds:cseg
Main		proc
		mov	ax, cseg		;Get ptr to vars segment
		mov	es, ax
		mov	es:PSP, ds		;Save PSP value away
		mov	ds, ax

		mov	ax, zzzzzzseg
		mov	es, ax
		mov	cx, 100h
		meminit2

		print
		byte	"靈컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�",cr,lf
		byte	"� Standard Game Device Interface driver �",cr,lf
		byte	"� PC Compatible Game Adapter Cards      �",cr,lf
		byte	"� Written by Randall Hyde               �",cr,lf
		byte	"聃컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�",cr,lf
		byte	cr,lf
		byte	"'SGDI REMOVE' removes the driver from memory",cr,lf
		byte	lf
		byte	0

		mov	ax, 1
		argv				;If no parameters, empty str.
		stricmpl
		byte	"REMOVE",0
		jne	NoRmv

		mov	dh, 81h		;Remove opcode.
		mov	ax, 84ffh
		int	15h		;See if we're already loaded.
		test	ax, ax		;Get a zero back?
		jz	Installed
		print
		byte	"SGDI driver is not present in memory, REMOVE "
		byte	"command ignored.",cr,lf,0
		mov	ax, 4c01h	;Exit to DOS.
		int	21h

Installed:	mov	ax, 8400h
		mov	dh, 80h		;Remove call
		int 	15h
		mov	ax, 8400h
		mov	dh, 81h		;TestPresence call
		int	15h
		cmp	ax, 0
		je	NotRemoved
		print
		byte	"Successfully removed SGDI driver from memory."
		byte	cr,lf,0
		mov	ax, 4c01h	;Exit to DOS.
		int	21h

NotRemoved:	print
		byte	"SGDI driver is still present in memory.",cr,lf,0
		mov	ax, 4c01h	;Exit to DOS.
		int	21h



NoRmv:


; Okay, Patch INT 15 and go TSR at this point.

SwappedLeft:	mov	ax, 3515h
		int	21h
		mov	wp Int15Vect, bx
		mov	wp Int15Vect+2, es

		mov	dx, cseg
		mov	ds, dx
		mov	dx, offset MyInt15
		mov	ax, 2515h
		int	21h

		mov	dx, cseg
		mov	ds, dx
		mov	dx, seg Initialize
		sub	dx, ds:psp
		add	dx, 2
		mov	ax, 3100h		;Do TSR
		int	21h
Main		endp

Initialize	ends




sseg		segment	para stack 'stack'
		dw	128 dup (0)
endstk		dw	?
sseg		ends


zzzzzzseg	segment	para public 'zzzzzzseg'
		db 	16 dup (0)
zzzzzzseg	ends
		end	Main
