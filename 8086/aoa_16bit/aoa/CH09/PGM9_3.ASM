; Pgm9_3.ASM
;
; This sample program provides two procedures that read and write
; 64-bit unsigned integer values on an 80386 or later processor.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386
		option	segment:use16

dp		textequ	<dword ptr>
byp		textequ	<byte ptr>

dseg		segment	para public 'data'

; Acc64 is a 64 bit value that the ATOU64 routine uses to input
; a 64-bit value.

Acc64		qword	0



; Quotient holds the result of dividing the current PUTU value by
; ten.

Quotient	qword	0


; NumOut holds the string of digits created by the PUTU64 routine.

NumOut		byte	32 dup (0)



; A sample test string for the ATOI64 routine:

LongNumber	byte	"123456789012345678",0


dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; ATOU64-	On entry, ES:DI point at a string containing a
;		sequence of digits.  This routine converts that
;		string to a 64-bit integer and returns that
;		unsigned integer value in EDX:EAX.
;
;		This routine uses the algorithm:
;
;		Acc := 0
;		while digits left
;
;			Acc := (Acc * 10) + (Current Digit - '0')
;			Move on to next digit
;
;		endwhile


ATOU64		proc	near
		push	di		;Save because we modify it.
		mov	dp Acc64, 0	;Initialize our accumulator.
		mov	dp Acc64+4, 0

; While we've got some decimal digits, process the input string:

		sub	eax, eax	;Zero out eax's H.O. 3 bytes.
WhileDigits:	mov	al, es:[di]
		xor	al, '0'		;Translates '0'..'9' -> 0..9
		cmp	al, 10		; and everything else is > 9.
		ja	NotADigit

; Multiply Acc64 by ten.  Use shifts and adds to accomplish this:

		shl	dp Acc64, 1	;Compute Acc64*2
		rcl	dp Acc64+4, 1

		push	dp Acc64+4	;Save Acc64*2
		push	dp Acc64

		shl	dp Acc64, 1	;Compute Acc64*4
		rcl	dp Acc64+4, 1
		shl	dp Acc64, 1	;Compute Acc64*8
		rcl	dp Acc64+4, 1

		pop	edx		;Compute Acc64*10 as
		add	dp Acc64, edx	; Acc64*2 + Acc64*8
		pop	edx
		adc	dp Acc64+4, edx

; Add in the numeric equivalent of the current digit.
; Remember, the H.O. three words of eax contain zero.

		add	dp Acc64, eax	;Add in this digit

		inc	di		;Move on to next char.
		jmp	WhileDigits	;Repeat for all digits.

; Okay, return the 64-bit integer value in eax.

NotADigit:	mov	eax, dp Acc64
		mov	edx, dp Acc64+4
		pop	di
		ret
ATOU64		endp






; PUTU64-	On entry, EDX:EAX contain a 64-bit unsigned value.
;		Output a string of decimal digits providing the
;		decimal representation of that value.
;
;		This code uses the following algorithm:
;
;		    di := 30;
;		    while edx:eax <> 0 do
;
;                       OutputNumber[di] := digit;
;			edx:eax := edx:eax div 10
;			di := di - 1;
;
;		    endwhile
;		    Output digits from OutNumber[di+1]
;			through OutputNumber[30]

PUTU64		proc
		push	es
		push	eax
		push	ecx
		push	edx
		push	di
		pushf



		mov	di, dseg	;This is where the output
		mov	es, di		; string will go.
		lea	di, NumOut+30	;Store characters in string
		std			; backwards.
		mov	byp es:[di+1],0	;Output zero terminating byte.


; Save the value to print so we can divide it by ten using an
; extended precision division operation.

		mov	dp Quotient, eax
		mov	dp Quotient+4, edx


; Okay, begin converting the number into a string of digits.

		mov	ecx, 10			;Value to divide by.
DivideLoop:	mov	eax, dp Quotient+4	;Do a 64-bit by
		sub	edx, edx		; 32-bit division
		div	ecx                     ; (see the text
		mov	dp Quotient+4, eax	;  for details).

		mov	eax, dp Quotient
		div	ecx
		mov	dp Quotient, eax

; At this time edx (dl, actually) contains the remainder of the
; above division by ten, so dl is in the range 0..9.  Convert
; this to an ASCII character and save it away.

		mov	al, dl
		or	al, '0'
		stosb

; Now check to see if the result is zero.  When it is, we can
; quit.

		mov	eax, dp Quotient
		or	eax, dp Quotient+4
		jnz	DivideLoop

OutputNumber:	inc	di
		puts
		popf
		pop	di
		pop	edx
		pop	ecx
		pop	eax
		pop	es
		ret
PUTU64		endp



; The main program provides a simple test of the two routines
; above.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		lesi	LongNumber
		call	ATOU64
		call	PutU64
		printf
		byte	cr,lf
		byte	"%x %x %x %x",cr,lf,0
		dword	Acc64+6, Acc64+4, Acc64+2, Acc64


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
