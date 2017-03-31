; Pgm7_2.asm - Numeric I/O.
;
; Randall Hyde
; 2/6/96
;
; The standard library routines do not provide simple to use numeric input
; routines.  This code demonstrates how to read decimal and hexadecimal values 
; from the user using the Getsm, ATOI, ATOU, ATOH, IsDigit, and IsXDigit routines.


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

inputLine	byte	128 dup (0)

SignedInteger	sword	?
UnsignedInt	word	?
HexValue	word	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


; Read a signed integer value from the user.

InputInteger:	print
		byte	"Input a signed integer value: ",0

		lesi	inputLine		;Point es:di at inputLine buffer
		gets				;Read a line of text from the user.

		mov	bx, -1
SkipSpcs1:	inc	bx
		cmp	inputLine[bx], ' '	;Skip over any leading spaces.
		je	SkipSpcs1

		cmp	inputLine[bx], '-'	;See if it's got a minus sign
		jne	NoSign
		inc	bx			;Skip if a negative number

NoSign:		dec	bx			;Back up one place.
TestDigs:	inc	bx			;Move on to next char
		mov	al, inputLine[bx]
		IsDigit				;See if it's a decimal digit.
		je	TestDigs		;Repeat process if it is.

		cmp	inputLine[bx], ' '	;See if we end with a reasonable
		je	GoodDec			; character.
		cmp	inputLine[bx], ','
		je	GoodDec
		cmp	inputLine[bx], 0	;Input line ends with a zero byte.
		je	GoodDec
		printf
		byte	"'%s' is an illegal signed integer.  Please reenter.",cr,lf,0
		dword	inputLine
		jmp	InputInteger

; Okay, all the characters are cool, let's do the conversion here.  Note that ES:DI
; is still pointing at inputLine.

GoodDec:	ATOI				;Do the conversion
		mov	SignedInteger, ax	;Save the value away.







; Read an unsigned integer value from the user.

InputUnsigned:	print
		byte	"Input an unsigned integer value: ",0

		lesi	inputLine		;Point es:di at inputLine buffer
		gets				;Read a line of text from the user.

; Note the sneakiness in the following code.  It starts with an index of minus two
; and then increments it by one.  When accessing data in this loop it compares
; against locatoin inputLine[bx+1] which effectively starts bx at zero.  In the
; "TestUnsigned" loop below, this code increments bx again so that bx then 
; contains the index into the string when the action is occuring.

		mov	bx, -2
SkipSpcs2:	inc	bx
		cmp	inputLine[bx+1], ' '	;Skip over any leading spaces.
		je	SkipSpcs2

TestUnsigned:	inc	bx			;Move on to next char
		mov	al, inputLine[bx]
		IsDigit				;See if it's a decimal digit.
		je	TestUnsigned		;Repeat process if it is.

		cmp	inputLine[bx], ' '	;See if we end with a reasonable
		je	GoodUnSigned		; character.
		cmp	inputLine[bx], ','
		je	GoodUnsigned
		cmp	inputLine[bx], 0	;Input line ends with a zero byte.
		je	GoodUnsigned
		printf
		byte	"'%s' is an illegal unsigned integer.  Please reenter.",cr,lf,0
		dword	inputLine
		jmp	InputUnsigned

; Okay, all the characters are cool, let's do the conversion here.  Note that ES:DI
; is still pointing at inputLine.

GoodUnsigned:	ATOU				;Do the conversion
		mov	UnsignedInt, ax		;Save the value away.






; Read a hexadecimal value from the user.

InputHex:	print
		byte	"Input a hexadecimal value: ",0

		lesi	inputLine		;Point es:di at inputLine buffer
		gets				;Read a line of text from the user.

; The following code uses the same sneaky trick as the code above.

		mov	bx, -2
SkipSpcs3:	inc	bx
		cmp	inputLine[bx+1], ' '	;Skip over any leading spaces.
		je	SkipSpcs3

TestHex:	inc	bx			;Move on to next char
		mov	al, inputLine[bx]
		IsXDigit			;See if it's a hex digit.
		je	TestHex			;Repeat process if it is.

		cmp	inputLine[bx], ' '	;See if we end with a reasonable
		je	GoodHex			; character.
		cmp	inputLine[bx], ','
		je	GoodHex
		cmp	inputLine[bx], 0	;Input line ends with a zero byte.
		je	GoodHex
		printf
		byte	"'%s' is an illegal hexadecimal value.  Please reenter.",cr,lf,0
		dword	inputLine
		jmp	InputHex

; Okay, all the characters are cool, let's do the conversion here.  Note that ES:DI
; is still pointing at inputLine.

GoodHex:	ATOH				;Do the conversion
		mov	HexValue, ax		;Save the value away.




; Display the results:

		printf
		byte	"Values input:",cr,lf
		byte	"Signed:   %4d",cr,lf
		byte	"Unsigned: %4d",cr,lf
		byte	"Hex:      %4x",cr,lf,0
		dword	SignedInteger, UnsignedInt, HexValue







Quit:		ExitPgm
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
