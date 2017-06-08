; This program demonstrates how to patch into the int 1Ch timer interrupt
; vector and create an interrupt chain.

		.xlist
		.286
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

; The TIMERISR will update the following two variables.
; It will update the MSEC variable every 55 ms.
; It will update the TIMER variable every second.

MSEC		word	0
TIMER		word	0

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; The OldInt1C variable must be in the code segment because of the
; way TimerISR transfers control to the next ISR in the int 1Ch chain.

OldInt1C	dword	?


TimerISR	proc	near
		push	ds
		push	ax
		mov	ax, dseg
		mov	ds, ax

		mov	ax, MSEC
		add	ax, 55		;Interrupt every 55 msec.
		cmp	ax, 1000
		jb	SetMSEC
		inc	Timer		;A second just passed.
		sub	ax, 1000	;Adjust MSEC value.
SetMSEC:	mov	MSEC, ax
		pop	ax
		pop	ds
		jmp	cseg:OldInt1C
TimerISR	endp



Main		proc
		mov	ax, dseg
		mov	ds, ax
		meminit

; Begin by patching in the address of our ISR into int 1ch's vector.
; Note that we must turn off the interrupts while actually patching
; the interrupt vector and we must ensure that interrupts are turned
; back on afterwards;  hence the cli and sti instructions.  These are
; required because a timer interrupt could come along between the two
; instructions that write to the int 1Ch interrupt vector.  This would
; be a big mess.

		mov	ax, 0
		mov	es, ax
		mov	ax, es:[1ch*4]
		mov	word ptr OldInt1C, ax
		mov	ax, es:[1ch*4 + 2]
		mov	word ptr OldInt1C+2, ax

		cli
		mov	word ptr es:[1Ch*4], offset TimerISR
		mov	es:[1Ch*4 + 2], cs
		sti

; Okay, the ISR updates the TIMER variable every second.
; Continuously print this value until ten seconds have
; elapsed.  Then quit.

		mov	Timer, 0
TimerLoop:	printf
		byte	"Timer = %d\n",0
		dword	Timer
		cmp	Timer, 10
		jbe	TimerLoop



; Okay, restore the interrupt vector.  We need the interrupts off
; here for the same reason as above.

		mov	ax, 0
		mov	es, ax
		cli
		mov	ax, word ptr OldInt1C
		mov	es:[1Ch*4], ax
		mov	ax, word ptr OldInt1C+2
		mov	es:[1Ch*4+2], ax
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
