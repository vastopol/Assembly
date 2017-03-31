; Delay18.asm
;
; Software/Hardware based Delay Subroutine

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; PPI_B is the I/O address of the keyboard/speaker control
; port.  This program accesses it simply to introduce a
; large number of wait states on faster machines.  Since the
; PPI (Programmable Peripheral Interface) chip runs at about
; the same speed on all PCs, accessing this chip slows most
; machines down to within a factor of two of the slower
; machines.

PPI_B		equ	61h


; RTC is the address of the BIOS timer variable (40:6ch).
; The BIOS timer interrupt code increments this 32-bit
; location about every 55 ms (1/18.2 seconds).  The code
; which initializes everything for the Delay routine
; reads this location to determine when 1/18th seconds
; have passed.

RTC		textequ	<es:[6ch]>



dseg		segment	para public 'data'

; TimedValue contains the number of iterations the delay
; loop must repeat in order to waste 1/18.2 seconds.

TimedValue	word	0

; RTC2 is a dummy variable used by the Delay routine to
; simulate accessing a BIOS variable.

RTC2		word	0


dseg		ends

;********************************************************





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Main program which tests out the DELAY subroutine.

Main		proc
		mov	ax, dseg
		mov	ds, ax

		print
		byte	"Delay test routine",cr,lf,0

; Okay, let's see how long it takes to count down 1/18th
; of a second.  First, point ES as segment 40h in memory.
; The BIOS variables are all in segment 40h.
;
; This code begins by reading the memory timer variable
; and waiting until it changes.  Once it changes we can
; begin timing until the next change occurs.  That will
; give us 1/18.2 seconds.  We cannot start timing right
; away because  we might  be in the  middle of a 1/18.2
; second period.

		mov	ax, 40h
		mov	es, ax
		mov	ax, RTC
RTCMustChange:	cmp	ax, RTC
		je	RTCMustChange

; Okay, begin timing the number of iterations it takes
; for an 18th of a second to pass.  Note that this
; code must be very similar to the code in the Delay
; routine.

		mov	cx, 0
		mov	si, RTC
		mov	dx, PPI_B
		align	4
TimeRTC:	mov	bx, 50
		align	4
DelayLp:	;in	al, dx			;Slow to hardware speed.
		dec	bx
		jne	DelayLp
		cmp	si, RTC
		loope	TimeRTC

		neg	cx			;CX counted down!
		mov	TimedValue, cx		;Save away

		mov	ax, ds
		mov	es, ax

		printf
		byte	"TimedValue = %d",cr,lf
		byte	"Press any key to continue",cr,lf
		byte	"This will begin a delay of five seconds",cr,lf,0
		dword	TimedValue

		getc


		mov	cx, 180
DelayIt:	call	Delay18
		loop	DelayIt



Quit:		ExitPgm			;DOS macro to quit program.
Main		endp



; Delay- This routine delays for approximately 1/18th second.
; 	 Presumably, the variable "TimedValue" in DS has been
;	 initialized with an appropriate count down value
;	 before calling this code.

Delay18		proc	near
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si

		mov	ax, dseg
		mov	es, ax
		mov	ds, ax

; The following code contains two loops.  The inside
; nested loop repeats 10 times.  The outside loop
; repeats the number of times determined to waste
; 1/18.2 seconds.  This loop accesses the hardware
; port "PPI_B" in order to introduce many wait states
; on the faster processors.  This helps even out the
; timings on very fast machines by slowing them down.
; Note that accessing PPI_B is only done to introduce
; these wait states, the data read is of no interest
; to this code.

		mov	cx, TimedValue
		mov	si, es:RTC2
		mov	dx, PPI_B

		align	4
TimeRTC:	mov	bx, 50
		align	4
DelayLp:	;in	al, dx
		dec	bx
		jne	DelayLp
		cmp	si, es:RTC2
		loope	TimeRTC

		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		ret
Delay18		endp




cseg            ends



sseg		segment	para stack 'stack'
stk		dw	1024 dup (0)
sseg		ends
		end	Main
