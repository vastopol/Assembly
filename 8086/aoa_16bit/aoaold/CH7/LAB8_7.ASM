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

OutPort		word	?
InPort		word	?

; Switch bit map.  Bits zero through three correspond to the
; various switches on the dip switch.

Switches	byte	?


; LED bit map.  Bits zero through three correspond to the four LEDs
; in the LED matrix.

LEDs		byte	?

dseg		ends






cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



; ScanSw-	Scans the switches and reads their current settings.
;		D4 and D5 control the columns on the switches.  They
;		need to contain 01 and then 10 while reading the
;		four switches.  The switch readings for each column
;		appear on bits D4 and D5 of the input port.
;
;			D4(out)	D5(out)
;			  |	  |
;		D4(in)----+-------+---
;			  |	  |	  "+" = a switch on the matrix.
;		D5(in)----+-------+---
;			  |       |


ScanSw		proc
		push	ax
		push	dx

; Scan the first column:

		mov	dx, OutPort
		in	al, dx		;Must read this port to
		and	al, 0Fh		; preserve bits 0..3.
		or	al, 10h		;Output 01 to D5/D4
		out	dx, al

		mov	dx, InPort	;Read the input bits.
		in	al, dx
		shr	al, 1		;Move bits 4/5 to 2/3 and
		shr	al, 1		; clear out all other bits.
		and	al, 1100b
		mov	ah, al		;Save for now.

		mov	dx, OutPort
		in	al, dx		;Retrieve output port value.
		xor	al, 30h		;Change 01 to 10 in bits D5/D4.
		out	dx, al

		mov	dx, InPort	;Read the second column of switches.
		in	al, dx
		and	al, 110000b	;Mask out unwanted bits.
		or	al, ah		;Merge with previous bits.
		shr	al, 1		;Move into bits 0..3
		shr	al, 1

		xor	al, 0Fh		;Flip bits (to get 1=on, 0=off).
		mov     Switches, al	;Save switches bit map value

		pop	dx
		pop	ax
		ret
ScanSw		endp



; ScanLED-	Scans the LEDs and outputs the LED values.
;		D0 and D1 control the columns (cathodes) on the LEDs  They
;		should contain 01 (D0/D1) while lighting LEDs in the first
;		column, they should contain 10 (D0/D1) while lighting the
;		second column.  Likewise, D2 and D3 should contain ones
;		while light LEDs on that particular row.
;
;			D0(out)	D1(out)
;			  |	  |
;			  |0	  |1
;		D2(in)----+-------+---
;			  |	  |	  "+" = an LED on the matrix.
;			  |2	  |3
;		D3(in)----+-------+---
;			  |       |


ScanLED		proc
		push	ax
		push	dx

		mov	dx, OutPort

; Handle the first row (LEDs zero and one) here:

		mov	al, LEDs
		xor	al, 11b		;Flip bits because 0=on, 1=off.
		and	al, 11b		;Strip values for LEDs zero and one.
		or	al, 100b	;Enable row one.
		out	dx, al

; Handle the second row down here:

		mov	al, LEDs
		shr	al, 1
		shr	al, 1
		xor	al, 11b		;Flip bits.
		and	al, 11b
		or	al, 1000b
		out	dx, al

; Short delay to leave those LEDs on for a while.

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		mov	al, 0		;Turn the LEDs off.
		out	dx, al
		pop	dx
		pop	ax
		ret
ScanLED		endp








Main		proc
		mov	ax, dseg
		mov	ds, ax

; First, get the base address of the printer port:

		mov	dx, 40h
		mov	es, dx

		mov	dx, LPT1	;Get printer port base address.
		mov	OutPort, dx	;Save as output port address.
		inc	dx		;Add one to get the address
		mov	InPort, dx	; of the input port.
		inc	dx		;Point DX at prtr control port.
		mov	al, 0		;Turn on power to circuitry.
		out	dx, al


loopit:		call	ScanSw
		mov	al, Switches
		mov	LEDs, al
		call	ScanLED
		mov	ah, 1
		int	16h
		jz	loopit
		getc



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
