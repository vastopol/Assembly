; Simple Arithmetic
; This program demonstrates some simple arithmetic instructions.

		.386			;So we can use extended registers
		option	segment:use16	; and addressing modes.

dseg		segment	para public 'data'

; Some type definitions for the variables we will declare:

uint		typedef	word		;Unsigned integers.
integer		typedef	sword		;Signed integers.


; Some variables we can use:

j		integer	?
k		integer	?
l		integer	?

u1      	uint	?
u2		uint	?
u3		uint	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Initialize our variables:

		mov	j, 3
		mov	k, -2

		mov	u1, 254
		mov	u2, 22


; Extended multiplication using 8086 instructions.
;
; Note that there are separate multiply instructions for signed and
; unsigned operands.
;
; L := J * K (ignoring overflow)

		mov	ax, J
		imul	K		;Computes DX:AX := AX * K
		mov	L, ax		;Ignore overflow into DX.

; u3 := u1 * u2

		mov	ax, u1
		mul	u2		;Computes DX:AX := AX * U2
		mov	u3, ax		;Ignore overflow in DX.


; Extended division using 8086 instructions.
;
; Like multiplication, there are separate instructions for signed
; and unsigned operands.
;
; It is absolutely imperative that these instruction sequences sign
; extend or zero extend their operands to 32 bits before dividing.
; Failure to do so will may produce a divide error and crash the
; program.
;
; L := J div K

		mov	ax, J
		cwd			;*MUST* sign extend AX to DX:AX!
		idiv	K		;AX := DX:AX/K, DX := DX:AX mod K
		mov	L, ax

; u3 := u1/u2

		mov	ax, u1
		mov	dx, 0		;Must zero extend AX to DX:AX!
		div	u2		;AX := DX:AX/u2, DX := DX:AX mod u2
		mov	u3, ax

; Special forms of the IMUL instruction available on 80286, 80386, and
; later processors.  Technically, these instructions operate on signed
; operands only, however, they do work fine for unsigned operands as well.
; Note that these instructions produce a 16-bit result and set the overflow
; flag if overflow occurs.
;
; L := J * 10 (80286 and later only)

		imul	ax, J, 10	;AX := J*10
		mov	L, ax

; L := J * K (80386 and later only)

		mov	ax, J
		imul	ax, K
		mov	L, ax



Quit:		mov	ah, 4ch			;DOS opcode to quit program.
		int	21h			;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
