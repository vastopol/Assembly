; Ex9_3.asm
; Software Delay Loop

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'


; TimerValue is the count-down value that produces a 55 millisecond delay.
; This is a magic number empirically determined for a 66 Mhz 80486 System.

TimerValue	dword	222000


dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

wp		textequ	<word ptr>


; Delay-	This is a software timer procedure that counts down a timer value
;		until it hits zero.  This procedure is extremely senstive to type
;		of CPU and CPU clock rate.

Delay		proc
		push	es
		push	ax

		push	wp TimerValue+2
		push	wp TimerValue

TimeRTC:	sub	wp TimerValue, 1
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



		printf
		byte	cr,lf
		byte	"Software delay loop test",cr,lf
		byte	"------------------------",cr,lf,lf
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
