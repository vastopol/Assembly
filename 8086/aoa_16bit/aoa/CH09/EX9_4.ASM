; EX9_4.asm
;
; Hardware-based software timing loop example.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; Location of BIOS variables:

RTC		textequ	<es:[6ch]>		;Real Time Clock variable.


dseg		segment	para public 'data'


; Dummy is a variable the timing loop compares against itself to match
; the timing in the InitDelay routine.

Dummy		word	0


; Timed value is an empirically determined constant which provides a
; suitable delay on whatever machine we are running on.  The program
; computes a reasonable value for this variable.

TimerValue	dword	0


dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


wp		textequ	<word ptr>


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
		mov	es, ax


		call	InitDelay

		printf
		byte	cr,lf
		byte	"Hardware Based Software delay loop test",cr,lf
		byte	"---------------------------------------",cr,lf,lf
		byte	"Delay factor: %ld",cr,lf
		byte	cr,lf
		byte	"Press any key to begin an 11 second delay "
		byte	"(approx).",0
		dword	TimerValue

		getc
		putcr
		mov	cx, 200		;55 msec * 200 = 11 sec.
Delay18:	call	Delay
		loop	Delay18

		print
		byte	cr,lf
		byte	"Delay complete.",cr,lf
		byte	cr,lf
		byte	"If you have a turbo button on your PC, press it "
		byte	"now to see the effect",cr,lf
		byte	"of clock speed on a software delay loop.",cr,lf
		byte	"Press any key to start timing delay.",0

		getc
		putcr
		mov	cx, 200		;55 msec * 200 = 11 sec.
Delay18a:	call	Delay
		loop	Delay18a

		print
		byte	cr,lf
		byte	"Delay Complete",cr,lf,0




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
