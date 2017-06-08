; PROJ8_5.asm
;
; LED Light Show.
;
; This program displays a little "light show" on the LEDs on your
; lab circuitry.  The project is to modify and improve this program.
; Note that this code runs on an 80286 or later processor only.
; You may need to modify it if you are running on an 8088.


		.286
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; Location of BIOS variables:

LPT1		textequ	<es:[08h]>		;LPT1 port base address.
						; 0ah=lpt2, 0ch=lpt3.

RTC		textequ	<es:[6ch]>		;Real Time Clock variable.



dseg		segment	para public 'data'

; Timed value is an emprically determined constant which provides a
; suitable delay on whatever machine we are running on.  The program
; computes a reasonable value for this variable.

TimedValue	word	0

; ShowData is a sequence of bytes to write to the LEDs.
; You should modify this table to produce your own light show.

ShowData	byte	000h, 001h, 002h, 004h, 008h, 080h, 040h, 020h, 010h
		byte	001h, 002h, 004h, 008h, 080h, 040h, 020h, 010h
		byte	001h, 002h, 004h, 008h, 080h, 040h, 020h, 010h
		byte	001h, 002h, 004h, 008h, 080h, 040h, 020h, 010h
		byte    001h, 003h, 007h, 00fh, 08fh, 0cfh, 0efh, 0ffh
		byte	0feh, 0fdh, 0fbh, 0f7h, 07fh, 0bfh, 0dfh, 0efh
		byte	0feh, 0fdh, 0fbh, 0f7h, 07fh, 0bfh, 0dfh, 0efh
		byte	0ffh, 0feh, 0fch, 0f8h, 0f0h, 070h, 030h, 010h
		byte	000h, 001h, 020h, 004h, 080h, 008h, 040h, 002h
		byte	010h
		byte	000h, 001h, 020h, 004h, 080h, 008h, 040h, 002h
		byte	010h
		byte	000h, 001h, 020h, 004h, 080h, 008h, 040h, 002h
		byte	010h
		byte	000h, 001h, 020h, 004h, 080h, 008h, 040h, 002h
		byte	010h
		byte	011h, 022h, 044h, 088h, 000h, 088h, 044h, 022h
		byte	011h, 000h
		byte	011h, 022h, 044h, 088h, 000h, 088h, 044h, 022h
		byte	011h, 000h
		byte	018h, 024h, 042h, 081h, 042h, 024h, 018h
		byte	018h, 024h, 042h, 081h, 042h, 024h, 018h
		byte	018h, 024h, 042h, 081h, 042h, 024h, 018h
		byte	018h, 024h, 042h, 081h, 042h, 024h, 018h
		byte	001h, 010h, 020h, 002h, 004h, 040h, 080h, 008h
		byte	008h, 080h, 040h, 004h, 002h, 020h, 010h, 001h
		byte	001h, 010h, 020h, 002h, 004h, 040h, 080h, 008h
		byte	008h, 080h, 040h, 004h, 002h, 020h, 010h, 001h
		byte	001h, 010h, 020h, 002h, 004h, 040h, 080h, 008h
		byte	008h, 080h, 040h, 004h, 002h, 020h, 010h, 001h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	009h, 082h, 044h, 028h, 090h, 040h, 021h, 012h
		byte	004h
		byte	000h, 011h, 033h, 077h, 0ffh, 0eeh, 0cch, 088h
		byte	000h, 088h, 0cch, 0eeh, 0ffh, 077h, 033h, 011h
		byte	000h, 011h, 033h, 077h, 0ffh, 0eeh, 0cch, 088h
		byte	000h, 088h, 0cch, 0eeh, 0ffh, 077h, 033h, 011h
		byte	000h, 011h, 033h, 077h, 0ffh, 0eeh, 0cch, 088h
		byte	000h, 088h, 0cch, 0eeh, 0ffh, 077h, 033h, 011h
		byte	000h, 011h, 033h, 077h, 0ffh, 0eeh, 0cch, 088h
		byte	000h, 088h, 0cch, 0eeh, 0ffh, 077h, 033h, 011h


SizeShow	equ	$-ShowData

dseg		ends






cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg





; Delay0-	This routine is a short delay whose actual delay time
;		varies from machine to machine.

Delay0		proc
		push	dx
TimeRTC:	mov	dx, 4000h
DelayLp:	dec	dx
		jne	DelayLp
		pop	dx
		ret
Delay0		endp





; Delay-	This routine delays for roughly a fixed time period on
;		any machine, regardless of CPU or clock rate (May vary by
;		a factor of two or so, but it not as sensitive to CPU
;		speed as a simple LOOP instr).

Delay		proc
		push	cx
		mov	ax, es:[0]		;This is a dummy value.
		mov	cx, TimedValue
DlyLp:		call	Delay0
		cmp	ax, es:[0]		;Dummy compare.
		loope	DlyLp			;Always equal.
		pop	cx
		ret
Delay		endp


; ReadSw-	The following routine reads the four switch values and
;		returns them in bit positions 0..3 of AX.  All other bits
;		in AX are set to zero.
;		If you want to use a printer port other than LPT1:, you
;		will need to change the appropriate equate at the beginning
;		of this code.

ReadSw		proc
		push	dx
		push	es
		mov	ax, 40h			;Point at BIOS vars, also sets
		mov	es, ax			; AH to zero.
		mov	dx, LPT1		;Get LPT1: address.
		add	dx, 2			;Point at ctrl port.
		mov	al, 0			;Output power on to switches.
		out	dx, al
		dec	dx			;Point at input port.
		in	al, dx			;Read Switches
		shl	al, 1			;Pack data in L.O. bits.
		rcl	al, 1
		rol	al, 3
		and	al, 0Fh			;Clear other bits (AH is 0).
		xor	al, 7			;Invert necessary bits.
		pop	es
		pop	dx
		ret
ReadSw		endp


; WriteLEDs-	Writes the eight bits in AL to the parallel output port.

WriteLEDs	proc
		push	dx
		push	es
		mov	dx, 40h
		mov	es, dx
		mov	dx, LPT1		;Get LPT1: base address.
		out	dx, al
		pop	es
		pop	dx
		ret
WriteLEDs	endp




Main		proc
		mov	ax, dseg
		mov	ds, ax

		cpuident
		cmp	ax, 286
		jae	CPUisOkay
		print
		byte	"This program requires an 80286 or better CPU."
		byte	cr,lf,0
		jmp	Quit

CPUisOkay:


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
; second to pass.

		mov	cx, 0
		mov	ax, RTC
TimeRTC:	call	Delay0
		cmp	ax, RTC
		loope	TimeRTC

; Okay, take the count down value and convert it from an 18th of a second
; to get our fixed time delay.

		neg	cx			;CX counted down!
		shl	cx, 2			;1/9 second.
		mov	TimedValue, cx		;Save away

		mov	ax, ds
		mov	es, ax


Restart:	lea	bx, ShowData
		mov	cx, SizeShow
LEDLoop:	mov	ah, 1		;Quit on keypress.
		int	16h
		jnz	Quit
		mov	al, [bx]
		call	WriteLEDs
		call	Delay
		inc	bx
		loop	LEDLoop
		jmp	Restart



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
