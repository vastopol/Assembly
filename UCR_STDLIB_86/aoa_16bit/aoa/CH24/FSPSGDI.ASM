		.286
		page	58, 132
		name	FSPSGDI
		title	FSPSGDI (CH Products Standard Game Device Interface).

; CHSGDI.EXE
;
;	Usage:
;		CHSDGI	{LEFT}
;
; This program loads a TSR which patches INT 15 so arbitrary game programs
; can read the CH Products FlightStick Pro joystick in a portable fashion.


wp		equ	<word ptr>
byp		equ	<byte ptr>



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

Int15Vect	dd	0

PSP		dw	?

; Port addresses for a typical joystick card:

JoyPort		equ	201h
JoyTrigger	equ	201h


CurrentReading	dw	0

Pot		struc
PotMask		db	0			;Pot mask for hardware.
DidCal		db	0			;Is this pot calibrated?
min		dw	5000			;Minimum pot value
max		dw	0			;Max pot value
center		dw	0			;Pot value in the middle
Pot		ends

Pot0		Pot	<1>
Pot1		Pot	<2>
Pot3		Pot	<8>


; SwapButtons-	0 if we should use normal flightstick pro buttons,
;		1 if we should swap the left and right buttons.

SwapButtons	byte	0

; SwBits- the four bit input value from the Flightstick Pro selects one
;	  of the following bit patterns for a given switch position.

SwBits		byte	10h		;Sw4
		byte	0		;NA
		byte	0		;NA
		byte	0		;NA
		byte	40h		;Sw6
		byte	0		;NA
		byte	0		;NA
		byte	4		;Sw 2

		byte	80h		;Sw 7
		byte	0		;NA
		byte	0		;NA
		byte	8		;Sw 3
		byte	20h		;Sw 5
		byte	2		;Sw 1
		byte	1		;Sw 0
		byte	0		;NA

SwBitsL		byte	10h		;Sw4
		byte	0		;NA
		byte	0		;NA
		byte	0		;NA
		byte	40h		;Sw6
		byte	0		;NA
		byte	0		;NA
		byte	4		;Sw 2

		byte	80h		;Sw 7
		byte	0		;NA
		byte	0		;NA
		byte	2		;Sw 3
		byte	20h		;Sw 5
		byte	8		;Sw 1
		byte	1		;Sw 0
		byte	0		;NA



; The IDstring address gets passed back to the caller on a testpresence
; call.  The four bytes before the IDstring must contain the serial number
; and current driver number.

SerialNumber	db	0,0,0
IDNumber	db	0
IDString	db	"CH Products:Flightstick Pro",0
		db	"Written by Randall Hyde",0






;============================================================================
;
; ReadPots- AH contains a bit mask to determine which pots we should read.
;	    Bit 0 is one if we should read pot 0, bit 1 is one if we should
;	    read pot 1, bit 3 is one if we should read pot 3.  All other bits
;	    will be zero.
;
;	This code returns the pot values in SI, BX, BP, and DI for Pot 0, 1,
;	2, & 3.
;

ReadPots	proc	near
		sub	bp, bp
		mov	si, bp
		mov	di, bp
		mov	bx, bp

; Wait for pots to finish any past junk:

		mov	dx, JoyPort
		out	dx, al		;Trigger pots
		mov	cx, 400h
Wait4Pots:	in	al, dx
		and	al, 0Fh
		loopnz	Wait4Pots

; Okay, read the pots:

		mov	dx, JoyTrigger
		out	dx, al		;Trigger pots
		mov	dx, JoyPort
		mov	cx, 8000h	;Don't let this go on forever.
PotReadLoop:	in	al, dx
		and	al, ah
		jz	PotReadDone
		shr	al, 1
		adc	si, 0
		shr	al, 1
		adc	bp, 0
		shr	al, 2
		adc	di, 0
		loop	PotReadLoop
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

		cmp	[bx].Pot.DidCal, 0
		je	BadNorm
		mov	dx, [bx].Pot.Center
		cmp	dx, [bx].Pot.Min
		jbe	BadNorm
		cmp	dx, [bx].Pot.Max
		jae	BadNorm

; Clip the value if it is out of range.

		cmp	ax, [bx].Pot.Min
		ja	MinOkay
		mov	ax, [bx].Pot.Min
MinOkay:

		cmp	ax, [bx].Pot.Max
		jb	MaxOkay
		mov	ax, [bx].Pot.Max
MaxOkay:

; Scale this guy around the center:

		cmp	ax, [bx].Pot.Center
		jb	Lower128

; Scale in the range 128..255 here:

		sub	ax, [bx].Pot.Center
		mov	dl, ah		;Multiply by 128
		mov	ah, al
		mov	dh, 0
		mov	al, dh
		shr	dl, 1
		rcr	ax, 1
		mov	cx, [bx].Pot.Max
		sub	cx, [bx].Pot.Center
		jz	BadNorm		;Prevent division by zero.
		div	cx		;Compute normalized value.
		add	ax, 128		;Scale to range 128..255.
		cmp	ah, 0
		je	NormDone
		mov	ax, 0ffh	;Result must fit in 8 bits!
		jmp	NormDone

; Scale in the range 0..127 here:

Lower128:	sub	ax, [bx].Pot.Min
		mov	dl, ah		;Multiply by 128
		mov	ah, al
		mov	dh, 0
		mov	al, dh
		shr	dl, 1
		rcr	ax, 1
		mov	cx, [bx].Pot.Center
		sub	cx, [bx].Pot.Min
		jz	BadNorm
		div	cx		;Compute normalized value.
		cmp	ah, 0
		je	NormDone
		mov	ax, 0ffh	;Result must fit in 8 bits!
		jmp	NormDone

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
		pop	bx
		jmp	cs:Int15Vect	;Let someone else handle it!

Read4Sw:	push	dx
		mov	dx, JoyPort
		in	al, dx
		shr	al, 4
		mov	bl, al
		mov	bh, 0
		cmp	cs:SwapButtons, 0
		je	DoLeft2
		mov	al, cs:SwBitsL[bx]
		jmp	SBDone

DoLeft2:	mov	al, cs:SwBits[bx]
SBDone:		rol	al, 4		;Put Sw0..3 in upper bits and make
		not	al		; 0=switch down, just like game card.
		pop	dx
		pop	bx
		iret

ReadBIOSPots:	pop	bx		;Return a value in BX!
		push	si
		push	di
		push	bp
		mov	ah, 0bh
		call	ReadPots
		mov	ax, si
		mov	bx, bp
		mov	dx, di
		sub	cx, cx
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

		cmp	dl, 0
		jne	Try1
		mov	ah, Pot0.PotMask
		call	ReadPots
		lea	bx, Pot0
		mov	ax, si
		call	Normalize
		jmp	GotPot

Try1:		cmp	dl, 1
		jne	Try3
		mov	ah, Pot1.PotMask
		call	ReadPots
		lea	bx, Pot1
		mov	ax, bp
		call	Normalize
		jmp	GotPot

Try3:		cmp	dl, 3
		jne	BadPot
		mov	ah, Pot3.PotMask
		call	ReadPots
		lea	bx, Pot3
		mov	ax, di
		call	Normalize
		jmp	GotPot

BadPot:		sub	ax, ax		;Question: Should we pass this on
					; or just return zero?
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
;		Read that pot and return the unnormalized result in AL.

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

		cmp	dl, 0
		jne	Try1
		mov	ah, Pot0.PotMask
		call	ReadPots
		mov	ax, si
		jmp	GotPot

Try1:		cmp	dl, 1
		jne	Try3
		mov	ah, Pot1.PotMask
		call	ReadPots
		mov	ax, bp
		jmp	GotPot

Try3:		cmp	dl, 3
		jne	BadPot
		mov	ah, Pot3.PotMask
		call	ReadPots
		mov	ax, di
		jmp	GotPot

BadPot:		sub	ax, ax		;Question: Should we pass this on
					; or just return zero?
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
;		values in AL, AH, DL, and DH.  Since the flightstick
;		Pro doesn't have a pot 2 installed, return zero for
;		that guy.

Read4Pots	proc	near
;;;;;;;;;;;	push	bx		;Already on stack
		push	ds
		push	cx
		push	si
		push	di
		push	bp

		mov	dx, cseg
		mov	ds, dx

		mov	ah, 0bh		;Read pots 0, 1, and 3.
		call	ReadPots

		mov	ax, si
		lea	bx, Pot0
		call	Normalize
		mov	cl, al

		mov	ax, bp
		lea	bx, Pot1
		call	Normalize
		mov	ch, al

		mov	ax, di
		lea	bx, Pot3
		call	Normalize
		mov	dh, al		;Pot 3 value.
		mov	ax, cx		;Pots 0 and 1.
		mov	dl, 0		;Pot 2 is non-existant.

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
		cmp	bx, cx
		ja	GoodMax
		xchg	bx, cx
GoodMax:	cmp	ax, cx
		jb	GoodMin
		xchg	ax, cx
GoodMin:	cmp	cx, bx
		jb	GoodCenter
		xchg	cx, bx
GoodCenter:


; Okay, figure out who were supposed to calibrate:

		lea	si, Pot0
		cmp	dl, 1
		jb	DoCal
		lea	si, Pot1
		je	DoCal
		cmp	dl, 3
		jne	CalDone
		lea	si, Pot3

DoCal:		mov	[si].Pot.min, ax
		mov	[si].Pot.max, bx
		mov	[si].Pot.center, cx
		mov	[si].Pot.DidCal, 1
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

		sub	ax, ax		;Assume no calibration
		lea	bx, Pot0
		cmp	dl, 1
		jb	GetCal
		lea	bx, Pot1
		je	GetCal
		cmp	dl, 3
		jne	BadCal
		lea	bx, Pot3

GetCal:		mov	al, [bx].Pot.DidCal
		mov	ah, 0
BadCal:		pop	ds
		pop	bx
		iret
TestCal		endp
		assume	ds:nothing


;----------------------------------------------------------------------------
;
; ReadSw-	Reads the switch whose switch number appears in DL.

SwTable		byte	11100000b, 11010000b, 01110000b, 10110000b
		byte	00000000b, 11000000b, 01000000b, 10000000b

SwTableL	byte	11100000b, 10110000b, 01110000b, 11010000b
		byte	00000000b, 11000000b, 01000000b, 10000000b

ReadSw		proc	near
;;;;;;;		push	bx		;Already on stack
		mov	bl, dl		;Save switch to read.
		mov	bh, 0
		mov	dx, JoyPort
		in	al, dx
		and  	al, 0f0h
		cmp	cs:SwapButtons, 0
		je	DoLeft0
		cmp	al, cs:SwTableL[bx]
		jne	NotDown
		jmp	IsDown

DoLeft0:	cmp	al, cs:SwTable[bx]
		jne	NotDown

IsDown:		mov	ax, 1
		pop	bx
		iret

NotDown:	sub	ax, ax
		pop	bx
		iret
ReadSw		endp


;----------------------------------------------------------------------------
;
; Read16Sw-	Reads all eight switches and returns their values in AX.

Read16Sw	proc	near
;;;;;;;;	push	bx		;Already on stack
		mov	ah, 0		;Switches 8-15 are non-existant.
		mov	dx, JoyPort
		in	al, dx
		shr	al, 4
		mov	bl, al
		mov	bh, 0
		cmp	cs:SwapButtons, 0
		je	DoLeft1
		mov	al, cs:SwBitsL[bx]
		jmp	R8Done

DoLeft1:	mov	al, cs:SwBits[bx]
R8Done:		pop	bx
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
;
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



; The following segment is tossed when this code goes resident.

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
		byte	"� CH Products Flightstick Pro           �",cr,lf
		byte	"� Written by Randall Hyde               �",cr,lf
		byte	"聃컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�",cr,lf
		byte	cr,lf
		byte	"'FSPSGDI LEFT' swaps the left and right buttons for "
		byte	"left handed players",cr,lf
		byte	"'FSPSGDI REMOVE' removes the driver from memory",cr,lf
		byte	lf
		byte	0

		mov	ax, 1
		argv				;If no parameters, empty str.
		stricmpl
		byte	"LEFT",0
		jne	NoLEFT
		mov	SwapButtons, 1
		print
		byte	"Left and right buttons swapped",cr,lf,0
		jmp	SwappedLeft

NoLEFT:		stricmpl
		byte	"REMOVE",0
		jne	NoRmv
		mov	dh, 81h
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
