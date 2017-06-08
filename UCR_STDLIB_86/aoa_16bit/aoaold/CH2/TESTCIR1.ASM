; Simple version of SHELL.ASM with the dumb comments removed (except this one)

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386			;Comment out these two statements
		option	segment:use16	; if you are not using an 80386.


Attribute	equ	07h		;White letters on black screen




dseg		segment	para public 'data'

OutPort		word	?		;Parallel port base address.
InPort		word	?		;Base address plus one.


; The following are the bit patterns we get back from the parallel port
; if the switches are in the proper positions.

SwVals		byte	01110000b	;Bit value if sw A is closed
		byte	01101000b	;Bit value if sw B is closed
		byte	01011000b	;Bit value if sw C is closed
		byte	00111000b	;Bit value if sw D is closed

; The following are the bit patterns we will get back if the user
; has the switches in the opposite positions.

AltSwVals	byte	00001000b	;Bit value if A is open
		byte	00010000b	;Bit value if B is open
		byte	00100000b	;Bit value if C is open
		byte	01000000b	;Bit value if D is open

; Dummy input line buffer so we can use gets to read an ENTER key from
; the user.

InputLn		byte	128 dup (0)
dseg		ends




cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



; ClrScrn-	Clears the display screen and positions the cursor at the
;		upper left hand position on the screen.


ClrScrn		proc	near
		push	ax
		push	bx
		push	cx
		push	dx

		mov	ax, 600h
		mov	bh, Attribute
		mov	cx, 0
		mov	dx, 184fh
		int	10h

		mov	ah, 2
		mov	bh, 0
		mov	dx, 0
		int	10h

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
ClrScrn		endp


; TstLEDs- prints a little diagram representing which LED should be on.
;	   On entry, ax contains the LED number to test.

TstLEDs		proc	near
		push	es
		push	cx
		push	dx
		push	di

		mov	cx, 7		;Repeat for eight LEDs.
PrtLoop:	print
		byte	" (",0		;Print "( )" or "(*)" depending
		cmp	ax, cx		; on whether the current LED
		je	PrtStar		; matches the value in AX.
		print
		byte	" )",0
		jmp	FinishLED

PrtStar:	print
		byte	"*)",0
FinishLED:      dec	cx
		cmp	cx, 3
		jg	PrtLoop
		jne	Next4

		print
		byte	"  Testing LED #",0
		puti
		print
		byte	", verify that it is on.",cr,lf,0
		jmp	PrtLoop

Next4:		cmp	cx, 0
		jge	PrtLoop

		print
		byte	"  Hit ENTER if it is, CTRL-C if not."
		byte	cr,lf,0

		mov	cx, ax			;Put a one in the appropriate
		mov	ax, 1			; bit position to turn on the
		shl	ax, cl
		mov	dx, OutPort		;Write this bit to the output
		out	dx, al			; port.

		lesi	InputLn                 ;Read an ENTER key from the
		gets				; user.

		pop	di
		pop	dx
		pop	cx
		pop	es
		ret
TstLEDs		endp



; TstSw-	Tests the switches in the circuit to see if they are
;		working properly.  On entry, AX contains the switch
;		number to test.

TstSw		proc	near
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	di

		mov	bx, ax		;Save away switch number.

SwitchLp:	print
		byte	"ÚÄÄÄÄÄÄÄÄÄ¿   Testing switch ",0

		add	al, 'A'		;Convert 0-3 to A-D.
		putc

		print
		byte	".  Please put the switch",cr,lf
		byte	"³",0

		mov	al, bl		;Restore switch number.
		mov	cx, 3
PrtTLp:		cmp	ax, cx
		je	PrtBrt
		print
		byte	" °",0
		jmp	NextT

PrtBrt:		print
		byte	" ²",0

NextT:		dec	cx
		jns	PrtTLp

		print
		byte	" ³   in the closed position (ON).",cr,lf
		byte	"³",0

		mov	cx, 3
PrtDLp:		cmp	ax, cx
		je	PrtDim
		print
		byte	" ²",0
		jmp	NextB

PrtDim:		print
		byte	" °",0

NextB:		dec	cx
		jns	PrtDLp

		print
		byte	" ³   Press ENTER when the switches are in",cr,lf
		byte	"ÀÄÄÄÄÄÄÄÄÄÙ   this configuration.",cr,lf,lf,0

		lesi	InputLn
		gets

; Check to see if the switches are in the proper position:

		mov	dx, InPort		;Read the switches.
		in	al, dx
		and	al, 01111000b		;Strip unnecessary bits.
		cmp	al, SwVals[bx]		;See if we've got the right
		je	GotPattern		; pattern.

		cmp	al, AltSwVals[bx]	;Try an alternate pattern
		jne	Failure			; if no match.
		print
		byte	"The switch seems to be working, but you've set the"
		byte	" switches in their opposite",cr,lf
		byte	"positions.  Please reverse the switches and try "
		byte	"again or press CTRL-C to quit.",cr,lf,lf,0

		mov	ax, bx
		jmp	SwitchLp

Failure:	print
		byte	"The switches do not seem to be set properly.",cr,lf
		byte	"Please reset them and try again or press CTRL-C "
		byte	"to abort.",cr,lf,lf,0

		mov	ax, bx
		jmp	SwitchLp

GotPattern:
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
TstSw		endp





; Main-		Determines which printer port to use and controls the
;		test routines.


Main		proc
		mov	ax, dseg
		mov	ds, ax
		meminit

		mov	bx, 1		;Assume LPT1
		argc			;Get the number of parameters.
		cmp	cx, 1		;We allow zero or one parameters
		jb	LPT1		; to this command.
		ja	Usage		;Error if more than one.

		mov	ax, cx		;Fetch the only parameter (1).
		argv
		strupr
		strcmpl
		byte	"LPT1",0
		je	LPT1
		strcmpl
		byte	"LPT1:",0
		je	LPT1

		strcmpl
		byte	"LPT2",0
		je	LPT2
		strcmpl
		byte	"LPT2:",0
		je	LPT2

		strcmpl
		byte	"LPT3",0
		je	LPT3
		strcmpl
		byte	"LPT3:",0
		je	LPT3

Usage:		print
		byte	bell, "Usage: TESTCIR1 lpt1:",cr,lf
		byte	      "       TESTCIR1 lpt2:",cr,lf
		byte	      "    or TESTCIR1 lpt3:",cr,lf
		byte	0
		jmp	Quit

LPT3:		inc	bx
LPT2:		inc	bx
LPT1:		free			;We're done with parameter string.
		mov	ax, 40h		;Point at BIOS variables
		mov	es, ax
		shl	bx, 1		;Index into word array.
		mov	ax, es:[bx+6]	;Fetch parallel port address.
		test	ax, ax		;If zero, no printer card installed
		jne	GotPort
		print
		byte	"There does not seem to be a parallel port adapter "
		byte	"card installed for",cr,lf
		byte	"the print port you've specified.  Please check your"
		byte	"hardware and try again.",cr,lf,0
		jmp	Quit

GotPort:      	mov	OutPort, ax	;Save away output port address.
		inc	ax		;Compute input port address.
		mov	InPort, ax	;Save away input port address.
		inc	ax		;Point at control port so we can
		mov	dx, ax		; write a zero to it.  This provides
		mov	al, 0		; power to the circuitry.
		out	dx, al

		call	ClrScrn

		mov	ax, 0
		call	TstLEDs

		mov	ax, 1
		call	TstLEDs

		mov	ax, 2
		call	TstLEDs

		mov	ax, 3
		call	TstLEDs

		mov	ax, 4
		call	TstLEDs

		mov	ax, 5
		call	TstLEDs

		mov	ax, 6
		call	TstLEDs

		mov	ax, 7
		call	TstLEDs

		mov	dx, OutPort	;Turn off LED #7 that was left on
		mov	al, 0		; by the call to TstLEDs above.
		out	dx, al


; Okay, test the switches:

		call	ClrScrn

		mov	ax, 0
		call	TstSw

		mov	ax, 1
		call	TstSw

		mov	ax, 2
		call	TstSw

		mov	ax, 3
		call	TstSw

		print
		byte	"The circuit seems to be working fine",cr,lf
		byte	"you may now proceed with the laboratory exercises."
		byte	cr,lf,lf,lf,0


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
