; GETI.ASM
;
; This module contains the integer input routine for the matrix
; example in Chapter Eight

		.nolist
		include	stdlib.a
		.list

		include	matrix.a

InpSeg		segment	para public 'input'

; Geti-	On entry, es:di points at a string of characters.
;	This routine skips any leading spaces and comma characters and then
;	tests the first (non-space/comma) character to see if it is a digit.
;	If not, this routine returns the carry flag set denoting an error.
;	If the first character is a digit, then this routine calls the
;	standard library routine "atoi2" to convert the value to an integer.
;	It then ensures that the number ends with a space, comma, or zero
;	byte.
;
;	Returns carry clear and value in AX if no error.
;	Returns carry set if an error occurs.
;
;	This routine leaves ES:DI pointing at the character it fails on when
; 	converting the string to an integer.  If the conversion occurs without
;	an error, the ES:DI points at a space, comma, or zero terminating byte.


geti		proc	far

		ifdef	debug
		print
		char	"Inside GETI",cr,lf,0
		endif

; First, skip over any leading spaces or commas.
; Note the use of the "byp" symbol to save having to type "byte ptr".
; BYP is a text equate appearing in the macros.a file.
; A "byte ptr" coercion operator is required here because MASM cannot
; determine the size of the memory operand (byte, word, dword, etc)
; from the operands.  I.e., "es:[di]" and ' ' could be any of these
; three sizes.
;
; Also note a cute little trick here; by decrementing di before entering
; the loop and then immediately incrementing di, we can increment di before
; testing the character in the body of the loop.  This makes the loop
; slightly more efficient and a lot more elegant.

		dec	di
SkipSpcs:	inc	di
		cmp	byp es:[di], ' '
		je	SkipSpcs
		cmp	byp es:[di], ','
		je	SkipSpcs

; See if the first non-space/comma character is a decimal digit:

		mov	al, es:[di]
		cmp	al, '-'		;Minus sign is also legal in integers.
		jne	TryDigit
		mov	al, es:[di+1]	;Get next char, if "-"

TryDigit:	isdigit
		jne	BadGeti		;Jump if not a digit.

; Okay, convert the characters that follow to an integer:

ConvertNum:	atoi2			;Leaves integer in AX
		jc	BadGeti		;Bomb if illegal conversion.

; Make sure this number ends with a reasonable character (space, comma,
; or a zero byte):

		cmp	byp es:[di], ' '
		je	GoodGeti
		cmp	byp es:[di], ','
		je	GoodGeti
		cmp	byp es:[di], 0
		je	GoodGeti

		ifdef	debug
		print
		char	"GETI: Failed because number did not end with "
		char	"a space, comma, or zero byte",cr,lf,0
		endif

BadGeti:	stc			;Return an error condition.
		ret

GoodGeti:	clc			;Return no error and an integer in AX
		ret
geti		endp


InpSeg		ends
		end