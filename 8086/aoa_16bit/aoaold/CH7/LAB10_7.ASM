; LAB10_7 -	Processing keystrokes.
;		This program reads and processes the momentary contact switch
;		as though it were a key switch on a typical keyboard.  Each
;		time the user presses a key, this program outputs a string.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; Location of BIOS variables:

LPT1		textequ	<es:[0ah]>		;LPT1 port base address.
						; Change to 0Ah for LPT2
						; or 0Ch for LPT3.

RTC		textequ	<es:[6ch]>		;Real Time Clock variable.




wp		textequ	<word ptr>


dseg		segment	para public 'data'

; Parallel Port addresses:

InPort		word	?


; Dummy is a variable the timing loop compares against itself to match
; the timing in the InitDelay routine.

Dummy		word	0


; Timed value is an empirically determined constant which provides a
; suitable delay on whatever machine we are running on.  The program
; computes a reasonable value for this variable.

TimerValue	dword	0

; The following variables hold the readings for the previous and current
; scans of the momentary contact switch.

LastScan	byte	0
ThisScan	byte	0


; The following variable counts the number of key presses.

KeyCnt		word	0

dseg		ends






cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



; Initialize the TimerValue variable that contains the number of loop
; interations for a 1/18th second delay.

InitDelay	proc
		push	es
		push	ax

; Okay, let's see how long it takes to count down 1/18th of a second.
; RTC is a magic location in the BIOS variables (segment 40h) which
; the Real Time Clock code increments every 55 ms (about 1/18.2 secs).
; This code waits for this location to change, then it counts off how
; long it takes to change again.  By executing that same loop again
; we can get (roughly) equivalent time delays on two separate machines.


		mov	ax, 40h			;Segment address of BIOS vars.
		mov	es, ax
		mov	ax, RTC			;Wait for timer to change.
RTCMustChange:	cmp	ax, RTC
		je	RTCMustChange

; Okay, begin timing the number of iterations it takes for an 18th of a
; second to pass.  The align directive ensures that this loop and Delay's
; corresponding loop both fall on the same cache line boundary.

		mov	wp TimerValue, 0
		mov	wp TimerValue+2, 0
		mov	ax, RTC

		align	16

TimeRTC:	cmp	ax, RTC
		jne	TimerDone

		sub	wp TimerValue, 1
		sbb	wp TimerValue+2, 0
		jne	TimeRTC
		cmp	wp TimerValue, 0
		jne	TimeRTC

; Negate the count down value and decrement it to compute the number
; of times the delay loop must repeat the loop above.

TimerDone:	neg	wp TimerValue+2		;32-bit negate of
		neg	wp TimerValue		; TimerValue.
		sbb	wp TimerValue+2, 0

		pop	ax
		pop	es
		ret
InitDelay	endp






; Delay-	This routine delays for roughly a fixed time period on
;		any machine, regardless of CPU or clock rate (May vary by
;		a factor of two or so, but it not as sensitive to CPU
;		speed as a simple LOOP instr).

Delay		proc
		push	es
		push	ax

		mov	ax, dseg
		mov	es, ax

		push	wp TimerValue+2		;Save these values
		push	wp TimerValue		; so we can modify them
		mov	ax, Dummy		;Compare this with itself.

		align	16

TimeRTC:	cmp	ax, es:Dummy
		jne	DelayDone		;Never taken.

		sub	wp TimerValue, 1
		sbb	wp TimerValue+2, 0
		jne	TimeRTC
		cmp	wp TimerValue, 0
		jne	TimeRTC


DelayDone:
		pop	wp TimerValue
		pop	wp TimerValue+2
		pop	ax
		pop	es
		ret
Delay		endp






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


		print
		byte	cr,lf
		byte	"Key Switch Processing",cr,lf
		byte	"---------------------",cr,lf
		byte	cr,lf
		byte	"Press the momentary contact switch to simulate "
		byte	"a keypress",cr,lf
		byte	"Press any key on the main keyboard to stop program"
		byte	cr,lf
		byte	lf
		byte	0


; Initialize the software delay routine and adjust the TimerDelay
; variable (by dividing it by two) to produce a 28 msec delay rather
; than a 55 ms delay.

		call	InitDelay

		shr     wp TimerValue+2, 1	;32-bit shr operation.
		rcr	wp TimerValue, 1


; Initialize the ThisScan variable (key in UP position).
; This will become the LastScan value upon entering the loop below.

		mov	ThisScan, 0

; Okay, continually process the momentary contact switch until the
; user presses a key on the main keyboard.

ScanLoop:	call	Delay		;Debounce keys.
		mov	al, ThisScan	;Copy previous scan value
		mov	LastScan, al	; to LastScan.

		mov	dx, InPort	;Read the current switch
		in	al, dx		; value from the parallel
		and	al, 80h		; input port, bit #7.

		mov	ThisScan, al
		xor	al, LastScan
		jz	NoDifference

; If al is not zero, either a key just went down or a key just went
; up.  The following code determines the direction.

		and	al, ThisScan
		jz	NoDifference	;Branch if it just went up.

; Okay, the key just went down.  Process that here.

		inc	KeyCnt
		printf
		byte	"Key down: %d",cr,lf,0
		dword	KeyCnt


; See if the user has pressed a key on the real keyboard (to terminate
; execution of this program).

NoDifference:	mov	ah, 1
		int	16h
		je	ScanLoop
		getc			;Read key press.


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
