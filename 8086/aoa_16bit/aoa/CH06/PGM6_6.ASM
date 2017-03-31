; String Instructions

		.386			;So we can use extended registers
		option	segment:use16	; and addressing modes.

dseg		segment	para public 'data'

String1		byte	"String",0
String2		byte	7 dup (?)

Array1		word	1, 2, 3, 4, 5, 6, 7, 8
Array2		word	8 dup (?)

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax


; The string instructions let you easily copy data from one array to
; another.  If the direction flag is clear, the movsb instruction
; does the equivalent of the following:
;
;	mov es:[di], ds:[si]
;	inc	si
;	inc	di
;
; The following code copies the seven bytes from String1 to String2:

		cld			;Required if you want to INC SI/DI

		lea	si, String1
		lea	di, String2

		movsb			;String2[0] := String1[0]
		movsb			;String2[1] := String1[1]
		movsb			;String2[2] := String1[2]
		movsb			;String2[3] := String1[3]
		movsb			;String2[4] := String1[4]
		movsb			;String2[5] := String1[5]
		movsb			;String2[6] := String1[6]

; The following code sequence demonstrates how you can use the LODSW and
; STOWS instructions to manipulate array elements during the transfer.
; The following code computes
;
;	Array2[0] := Array1[0]
;	Array2[1] := Array1[0] * Array1[1]
;	Array2[2] := Array1[0] * Array1[1] * Array1[2]
;	etc.
;
; Of course, it would be far more efficient to put the following code
; into a loop, but that will come later.

		lea	si, Array1
		lea	di, Array2

		lodsw
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw

		lodsw
		imul	ax, dx
		mov	dx, ax
		stosw



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
