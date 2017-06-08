		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list



dseg		segment	para public 'data'
InputValues	word	10 dup (?)
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; GetValues: Reads ten integers from the user
; and stores their values into the "InputValues"
; array.

GetValues	proc	near
		push	ax
		push	bx
		push	cx

		mov	cx, 10
		lea	bx, InputValues
GVLoop:		print
		byte	"Input value #",0

; Print 0..9:
		mov	ax, 10
		sub	ax, cx
		puti

		print
		byte	": ",0

; Read a line of input from the user (getsm),
; strip away leading spaces (strblkdel), convert
; the remaining characters to an integer (atoi),
; and then return storage allocated on the
; heap back to the system (free):

		getsm
		strblkdel
		atoi
		free

; Save away the integer in the array, move on to
; the next array element, and then repeat this
; loop ten times:

		mov	[bx], ax
		add	bx, 2
		loop	GVLoop

		pop	cx
		pop	bx
		pop	ax
		ret
GetValues	endp


; Average: Computes the average of the ten items
; in the array and returns this average in AX.

Average		proc	near
		push	bx
		push	cx
		push	dx

		mov	cx, 10
		lea	bx, InputValues
		xor	ax, ax		;AX:=0
AveLoop:	add	ax, [bx]
		add	bx, 2
		loop	AveLoop

; We must divide the sum by ten to get the average.
; Don't forget the weirdness of the 80x86 IDIV
; instruction!

		cwd
		mov	bx, 10
		idiv	bx

		pop	dx
		pop	cx
		pop	bx
		ret
Average		endp



Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		meminit

		call	GetValues
		call	Average
		print
		byte	"The average is ",0
		puti
		putcr

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
