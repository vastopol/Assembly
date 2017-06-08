		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; Location of BIOS variables:

LPT1		textequ	<es:[0ah]>		;LPT1 port base address.
						; Change to 0Ah for LPT2
						; or 0Ch for LPT3.



dseg		segment	para public 'data'

; Parallel Port addresses:

InPort		word	?

; The following array holds 50000 consecutive readings of the
; momentary contact switch.  The H.O. bit of each byte contains
; the switch status (1=closed, 0=open).

KeyValues	byte	50000 dup (?)

dseg		ends






cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



Main		proc
		mov	ax, dseg
		mov	ds, ax

; First, get the base address of the printer port:

		mov	dx, 40h
		mov	es, dx

		mov	dx, LPT1	;Get printer port base address.
		inc	dx		;Add one to get the address
		mov	InPort, dx	; of the input port.
		inc	dx		;Point DX at prtr control port.
		mov	al, 0		;Turn on power to circuitry.
		out	dx, al



; Continually read the momentary contact switch until its state changes:

		print
		byte	cr,lf
		byte	"Keybounce Experiment",cr,lf
		byte	"--------------------",cr,lf,lf
		byte	"Waiting for closure of momentary contact switch:"
		byte	cr,lf,0

		mov	dx, InPort
		in	al, dx
		and	al, 80h		;Mask out all but momentary switch.
		mov	ah, al		;Save for comparison.
Wait4Change:	in	al, dx
		and	al, 80h
		xor	al, ah		;Non-zero if they are different
		jz	Wait4Change	;Repeat until different.

; Okay, either the user has just pressed the switch or they've just
; released it.  In either case, keybounce will probably occur.
; Let's measure the amount of keybounce that occurs.

		mov	cx, 50000	;Take 50000 readings.
		lea	bx, KeyValues
ReadSwitchLp:	in	al, dx		;Read the switch.
		and	al, 80h
		mov	[bx], al	;Save away reading.
		inc	bx
		loop	ReadSwitchLp	;Repeat 50000 times.


; Okay, now go count the number of times that this key bounced on those
; 50,000 readings.

		mov	cx, 49999	;Process 49999+1 elements.
		mov	dx, 0		;Bounce count.
		lea	bx, KeyValues	;Start at beginning of array.
CountBounces:	mov	al, [bx]	;Determine if there is a state
		cmp	al, [bx+1]	; change between consecutive
		je	NoChange	; array elements.
		inc	dx		;If so, bump our counter.
NoChange:	inc	bx
		loop	CountBounces

; Now DX contains the number of times that the input changed states.
; If we divide this number by two we get the number of times the
; key bounced (because there are two state changes for each bounce).

		print
		byte	cr,lf
		byte	"There were ",0

		mov	ax, dx
		shr	ax, 1	       	;Divide count by two.
		puti

		print
		byte	" key bounces.",cr,lf,0


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends



sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
