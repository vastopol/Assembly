		.xlist

		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list



dseg		segment	para public 'data'

TestString	byte	"This is the string 'xyz' in it",cr,lf,0

TestPat		pattern	{matchtoistr,xyz}
xyz		byte	"XYZ",0

dseg		ends





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; MatchToiStr-	Matches all characters in a string up to, and including, the
;		specified parameter string.  The parameter string must be
;		all upper case characters.  This guy matches string using
;		a case insensitive comparison.
;
; inputs:
;		es:di-	Source string
;		ds:si-	String to match
;		cx- 	Maximum match position
;
; outputs:
;		ax-	Points at first character beyond the end of the matched
;			string if success, contains the initial DI value if
;			failure occurs.
;		carry-	0 if failure, 1 if success.


MatchToiStr	proc	far
		pushf
		push	di
		push	si
		cld

; Check to see if we're already past the point were we're allowed
; to scan in the input string.

		cmp	di, cx
		jae	MTiSFailure


; If the pattern string is the empty string, always match.

		cmp	byte ptr ds:[si], 0
		je	MTSsuccess


; The following loop scans through the input string looking for
; the first character in the pattern string.

ScanLoop:	push	si
		lodsb			;Get first char of string

		dec	di
FindFirst:	inc	di		;Move on to next (or 1st) char.
		cmp	di, cx		;If at cx, then we've got to
		jae    CantFind1st	; fail.

		mov	ah, es:[di]	;Get input character.
		cmp	ah, 'a'		;Convert input character to
		jb	DoCmp		; upper case if it's a lower
		cmp	ah, 'z'		; case character.
		ja	DoCmp
		and	ah, 5fh
DoCmp:		cmp	al, ah		;Compare input character against
		jne	FindFirst	; pattern string.


; At this point, we've located the first character in the input string
; that matches the first character of the pattern string.  See if the
; strings are equal.

		push	di		;Save restart point.

CmpLoop:	cmp	di, cx		;See if we've gone beyond the
		jae	StrNotThere	; last position allowable.
		lodsb			;Get next input character.
		cmp	al, 0		;At the end of the parameter
		je	MTSsuccess2	; string?  If so, succeed.

		inc	di
		mov	ah, es:[di]	;Get the next input character.
		cmp	ah, 'a'		;Convert input character to
		jb	DoCmp2		; upper case if it's a lower
		cmp	ah, 'z'		; case character.
		ja	DoCmp2
		and	ah, 5fh
DoCmp2:		cmp	al, ah		;Compare input character against
		je	CmpLoop
		pop	di
		pop	si
		jmp	ScanLoop


StrNotThere:	add	sp, 2		;Remove di from stack.
CantFind1st:	add	sp, 2		;Remove si from stack.
MTiSFailure:	pop	si
		pop	di
		mov	ax, di		;Return failure position in AX.
		popf
		clc			;Return failure.
		ret

MTSSuccess2:	add	sp, 2		;Remove DI value from stack.
MTSSuccess:	add	sp, 2		;Remove SI value from stack.
		mov	ax, di		;Return next position in AX.
		pop	si
		pop	di
		popf
		stc			;Return success.
		ret
MatchToiStr	endp








Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


		lesi	TestString
		ldxi	TestPat
		xor	cx, cx
		match
		jnc	Quit
		print
		byte	"Matched",cr,lf,0


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
