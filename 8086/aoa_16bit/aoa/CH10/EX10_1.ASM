; Ex10_1.asm
;
; Software that plays Musical notes.
; Intended for use with Chapter 10 Laboratory Experiments


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; Hardware related equates

PPI_B		equ	61h		;8255 port B address
PIT_Ch2		equ	42h		;Timer channel 2 address
PIT_CW		equ	43h		;Timer control word address.

RTC		textequ	<es:[6ch]>	;Real Time clock writes here.





; The following macros program the 8254 timer chip to play a
; note or a rest.

Note		macro	frequency, duration
		mov	ax, frequency
		mov	cx, duration
		call	PlayNote
		endm

Rest		macro	Duration
		local	RestLoop

;; Turn off the speaker.

		in	al, PPI_B
		and	al, 0FCh
		out	PPI_B, al

		mov	cx, Duration
RestLoop:	call	Delay18
		loop	RestLoop
		endm




dseg		segment	para public 'data'

; See Delay18.asm for details about the following variables.

TimedValue	word	0
RTC2		word	0


; DivisorConst is the constant that, when divided by a desired frequency
; produces the divisor constant to feed into the timer chip to produce
; a tone of the given frequency.

DivisorConst	dword	1193180


dseg		ends

;********************************************************





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Delay- This routine delays for approximately 1/18th second.
; 	 See the Delay18.asm file for comments about this code.

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
		mov	cx, TimedValue
		mov	si, es:RTC2
		mov	dx, PPI_B

		align	4
TimeRTC:	mov	bx, 50
		align	4
DelayLp:	dec	bx
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



; DelayInit-	Computes the timing constant for the Delay18 routine
;		by watching when the RTC code updates the RTC variable.

DelayInit	proc
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si

		mov	ax, 40h
		mov	es, ax
		mov	ax, RTC
RTCMustChange:	cmp	ax, RTC
		je	RTCMustChange

		mov	cx, 0
		mov	si, RTC
		mov	dx, PPI_B
		align	4
TimeRTC:	mov	bx, 50
		align	4
DelayLp:	dec	bx
		jne	DelayLp
		cmp	si, RTC
		loope	TimeRTC

		neg	cx			;CX counted down!
		shl	cx, 1			;Increase delay time.
		mov	TimedValue, cx		;Save away

		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
DelayInit	endp





; PlayNote-	This procedure programs the 8254 timer chip to play a given
;		note (frequency is passed in AX) for a given duration (passed
;		in cx).

PlayNote	proc
		push	dx
		push	cx
		push	ax

; Turn on the speaker.

		in	al, PPI_B
		or	al, 3
		out	PPI_B, al

; Tell the chip we want to program it with a new 16-bit divisor value.

		mov	al, 0B6h	;Magic value to program chip.
		out	PIT_CW, al

; Convert the frequency to a divisor constant.

		pop	cx		;Get the frequency.

		mov	dx, word ptr DivisorConst+2
		mov	ax, word ptr DivisorConst
		div	cx

		out	PIT_Ch2, al
		xchg	al, ah
		out	PIT_Ch2, al

		mov	ax, cx		;Restore original AX value.
		pop	cx		;Retrieve duration
		mov	dx, cx		;Save Duration.
DelayLp:	call	Delay18
		loop	DelayLp
		mov	cx, dx		;Restore original CX value

		pop	dx		;Restore original DX value.
		ret
PlayNote	endp


; Main program which tests out the DELAY subroutine.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		call	DelayInit

; Play "Amazing Grace"

		note	294, 4
		note	392, 8
		note	494, 2
		note	392, 2
		note	494, 8
		note	440, 4
		note	392, 8
		note	330, 4
		note	294, 8
		rest	2
		note	294, 4
		note	392, 8
		note	494, 2
		note	392, 2
		note	494, 8
		note	440, 4
		note	587, 16

		note	494, 4
		note	587, 4
		note	494, 2
		note	587, 2
		note	494, 2
		note	392, 8
		note	294, 4
		note	330, 4
		note	392, 2
		rest	2
		note	392, 2
		note	330, 2
		note	294, 8
		rest	2
		note	294, 4
		note 	392, 8
		note	494, 2
		note	392, 2
		note	494, 8
		note	440, 4
		note	392, 16


		rest	1



Quit:		ExitPgm			;DOS macro to quit program.
Main		endp







cseg            ends



sseg		segment	para stack 'stack'
stk		dw	1024 dup (0)
sseg		ends
		end	Main
