; This program measures the latency of an INT 01ch ISR.
; It works by reading the timer chip immediately upon entering
; the INT 01ch ISR  By averaging this value for some number of
; executions, we can determine the average latency for this
; code.

		.xlist
		.386
		option		segment:use16
		include 	stdlib.a
		includelib	stdlib.lib
		.list


cseg		segment	para public 'code'
		assume	cs:cseg, ds:nothing

; All the variables are in the code segment in order to reduce ISR
; latency (we don't have to push and set up DS, saving a few instructions
; at the beginning of the ISR).

OldInt1ch		dword	?
SumLatency	dword	0
Executions	dword	0
Average		dword	0

; This program reads the 8254 timer chip.  This chip counts from
; 0FFFFh down to zero and then generates an interrupt.  It wraps
; around from 0 to 0FFFFh and continues counting down once it
; generates the interrupt.
;
; 8254 Timer Chip port addresses:

Timer0_8254	equ	40h
Cntrl_8254	equ	43h


; The following ISR reads the 8254 timer chip, negates the result
; (because the timer counts backwards), adds the result to the
; SumLatency variable, and then increments the Executions variable
; that counts the number of times we execute this code.  In the
; mean time, the main program is busy computing and displaying the
; average latency time for this ISR.
;
; To read the 16 bit 8254 counter value, this code needs to
; write a zero to the 8254 control port and then read the
; timer port twice (reads the L.O. then H.O. bytes).  There
; needs to be a short delay between reading the two bytes
; from the same port address.

TimerISR	proc	near
		push	ax
		mov	eax, 0		;Ch 0, latch & read data.
		out	Cntrl_8254, al	;Output to 8253 cmd register.
		in	al, Timer0_8254	;Read latch #0 (LSB) & ignore.
		mov	ah, al
		jmp	SettleDelay	;Settling delay for 8254 chip.
SettleDelay:	in	al, Timer0_8254	;Read latch #0 (MSB)
		xchg	ah, al
		neg	ax		;Fix, 'cause timer counts down.
		add     cseg:SumLatency, eax
		inc	cseg:Executions
		pop	ax
		jmp	cseg:OldInt1ch
TimerISR	endp



Main		proc
		meminit

; Begin by patching in the address of our ISR into int 1ch's vector.
; Note that we must turn off the interrupts while actually patching
; the interrupt vector and we must ensure that interrupts are turned
; back on afterwards;  hence the cli and sti instructions.  These are
; required because a timer interrupt could come along between the two
; instructions that write to the int 1ch interrupt vector.  Since the
; interrupt vector is in an inconsistent state at that point, this
; could cause the system to crash.

		mov	ax, 0
		mov	es, ax
		mov	ax, es:[1ch*4]
		mov	word ptr OldInt1ch, ax
		mov	ax, es:[1ch*4 + 2]
		mov	word ptr OldInt1ch+2, ax

		cli
		mov	word ptr es:[1ch*4], offset TimerISR
		mov	es:[1ch*4 + 2], cs
		sti

; First, wait for the first call to the ISR above.  Since we will be dividing
; by the value in the Executions variable, we need to make sure that it is
; greater than zero before we do anything.

Wait4Non0:	cmp	cseg:Executions, 0
		je	Wait4Non0


; Okay, start displaying the good values until the user presses a key at
; the keyboard to stop everything:

DisplayLp:	mov	eax, SumLatency
		cdq				;Extends eax->edx.
		div	Executions
		mov     Average, eax
		printf
		byte	"Count: %ld, average: %ld\n",0
		dword	Executions, Average

		mov	ah, 1			;Test for keystroke.
		int	16h
		je	DisplayLp
		mov	ah, 0			;Read that keystroke.
		int	16h



; Okay, restore the interrupt vector.  We need the interrupts off
; here for the same reason as above.

		mov	ax, 0
		mov	es, ax
		cli
		mov	ax, word ptr OldInt1ch
		mov	es:[1ch*4], ax
		mov	ax, word ptr OldInt1ch+2
		mov	es:[1ch*4+2], ax
		sti

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
