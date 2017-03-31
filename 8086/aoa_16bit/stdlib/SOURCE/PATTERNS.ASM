		include	pattern.a

StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
StringAddress	dd	?
LastStringAdrs	dw	?
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp


; Special case to handle MASM 6.0 vs. all other assemblers:
; If not MASM 5.1 or MASM 6.0, set the version to 5.00:

		ifndef	@version
@version	equ	500
		endif


; sl_Match-	Saves away the address of the start of the string (for
;		those matching primitives which need it) and then transfers
;		control to the recursive sl_Match2 routine.

		public	sl_Match
sl_Match	proc	far
		assume	ds:stdgrp
		push	ds
		mov	ax, STDGrp
		mov	ds, ax
		mov	word ptr StdGrp:StringAddress, di
		mov	word ptr StdGrp:StringAddress+2, es

; Check to see if CX is zero.

		or	cx, cx			;If zero, adjust for whole str.
		jnz	PartialString

; If CX was zero, let's locate the end of the string and use that value for
; EndString/UptoString:

		pushf
		push	di
		mov	cx, 0ffffh		;Allow arbitrary length str.
		mov	al, 0			;Search for zero terminator.
		cld
	repne	scasb
		dec	di			;It goes one too far.
		mov	cx, di			;Save ptr to end of string.
		pop	di
		popf

PartialString:	mov	LastStringAdrs, cx
		pop	ds
sl_Match	endp			;Just falls into sl_Match2
					; so don't move it!
		assume	ds:nothing


; sl_Match2-	Matches a string against a pattern.  Returns success or
;		failure, depending.
;
; Inputs:
;		es:di-	String to compare against.
;		dx:si-	Pointer to pattern list to match.
;		cx-	Maximum position in string to check (zero for
;			entire string).
;
; Outputs:	ax-	Failure/success position (position in string
;			where the pattern matching stopped).
;		carry-	1 if success, 0 if failure.


		if	@version ge 600

MatchFunc	textequ	<dword ptr [bp-4]>
MLFuncL		textequ	<word ptr [bp-4]>
MLFuncH		textequ	<word ptr [bp-2]>
StartString	textequ	<word ptr [bp-6]>
EndString	textequ	<word ptr [bp-8]>
UptoString	textequ	<word ptr [bp-10]>

		public	sl_Match2
sl_Match2	proc	far
		push	ds
		push	dx
		push	cx
		push	si
		push	di
		push	bp
		mov	bp, sp
		sub	sp, 10
		mov	ds, dx


; Save a pointer to the "bounds" for the string.  DI points at the first
; location to start comparing against, cx points one byte beyond the end
; of the string (typically at the zero terminating byte if DI..CX is the
; whole string). EndString will mark the absolute end of the string (beyond
; which no comparison may take place).  UptoString marks the current end
; of string when performing backtracking.  If CX is zero upon entry into this
; routine, then this code will find the end of the source string and use that
; location for CX.

		mov	StartString, di
		mov	ds:[si].Pattern.StartPattern, di
		mov	ds:[si].Pattern.StrSeg, es
		mov	EndString, cx
		mov	UptoString, cx


; The address of the match function appears in the pattern structure (where
; ds:si is currently pointing).  However, we will soon lose access to this
; structure.  Therefore, it makes sense to copy that pointer into a local
; variable so we have easy access to it.

		mov	ax, word ptr ds:[si].Pattern.MatchFunction
		mov	MLFuncL, ax
		mov	ax, word ptr ds:[si+2].Pattern.MatchFunction
		mov	MLFuncH, ax


; Okay, begin the pattern matching down here.  See if the current pattern
; matches the (leading) characters in the string.

TryAgain:	mov	di, StartString		;The match function requires
		mov	cx, UptoString		; string address in ES:DI,
		push	ds			; last position+1 in CX, and
		push	si			; "pattern parameter" in DS:SI.
		push	dx
		lds	si, ds:[si].Pattern.MatchParm
		mov	dx, ds
		call	MatchFunc
		pop	dx
		pop	si			;Restore pointer to current
		pop	ds			; pattern structure.
		mov	ds:[si].Pattern.EndPattern, ax
		jnc	MatchFailed

; If this match succeeded, try the next guy in the pattern list.  If there
; is no next guy, we're done (and we've matched).  Note: this code only
; checks the segment portion of the pointer.  It assumes there are no
; pattern values down in segment zero (usually a very good assumption).

		cmp	word ptr ds:[si+2].Pattern.NextPattern, 0
		jne	TryNext

; If the string matches, drop down here and note the success.  First, we
; need to save the starting and ending positions of the string back into
; the pattern structure.

Success:        mov	sp, bp			;Success!  Let's go home
		pop	bp			; now.
		pop	di			;Note that AX currently con-
		pop	si			; tains the last match posn
		pop	cx			; returned by MatchFunc.
		pop	dx
		pop	ds
		stc				;Return success.
		ret

; If there are additional items in this pattern list, call them to see if
; they succeed (by making a recursive call to sl_Match2).  This must be a
; recursive call (rather than relying on tail recursion) because back
; tracking may be necessary to match this string.

TryNext:        push	dx			;Save ptr to current pattern.
		push	si

		mov	di, ax			;Start this match at the end
		mov	UptoString, ax		; of the previous match.
		mov	dx, word ptr ds:[si+2].Pattern.NextPattern
		mov	si, word ptr ds:[si].Pattern.NextPattern
		mov	cx, EndString

		call	sl_Match2

		pop	si
		pop	dx

		jc	Success			;If it matched, we're done.

; Time to try backtracking to see if we can get some other pattern match.

		dec	UptoString	;Disallow the last char and
		mov	ax, UptoString	; try again, though don't go past the
		cmp	ax, StartString	; beginning of the string.
		jge	TryAgain


; If we failed, there is still the possibility that there is an alternate
; pattern to match against.  If so, try matching the alternate pattern
; down here.  If it fails, then we really fail.  If it succeeds, so does
; this pattern.  As is the case throughout this code, the following statements
; assume that if the segment portion of a pointer is zero, the whole pointer
; is zero.


; First, see if there is an alternate pointer:

MatchFailed:	cmp	word ptr ds:[si+2].Pattern.MatchAlternate, 0
		je	ReallyFailed

; Mark the starting and ending offsets with the same value to denote the
; lack of a match on this string.

		mov     ax, ds:[si].Pattern.StartPattern
		mov	ds:[si].Pattern.EndPattern, ax

; If the alternate pointer is non-null, go off and match against the
; alternate string.


		mov	di, StartString
		mov	dx, word ptr ds:[si+2].Pattern.MatchAlternate
		mov	si, word ptr ds:[si].Pattern.MatchAlternate
		mov	cx, EndString
		call	sl_Match2
		jc	Success

; Don't forget, AX contains the failure point when we leave this code.

ReallyFailed:	mov	sp, bp
		pop	bp
		pop	di
		pop	si
		pop	cx
		pop	dx
		pop	ds
		clc
		ret
sl_Match2	endp




		else			;If TASM or MASM 5.1

MatchFunc	equ	<dword ptr [bp-4]>
MLFuncL		equ	<word ptr [bp-4]>
MLFuncH		equ	<word ptr [bp-2]>
StartString	equ	<word ptr [bp-6]>
EndString	equ	<word ptr [bp-8]>
UptoString	equ	<word ptr [bp-10]>

		public	sl_Match2
sl_Match2	proc	far
		push	ds
		push	dx
		push	cx
		push	si
		push	di
		push	bp
		mov	bp, sp
		sub	sp, 10
		mov	ds, dx


; Save a pointer to the "bounds" for the string.  DI points at the first
; location to start comparing against, cx points one byte beyond the end
; of the string (typically at the zero terminating byte if DI..CX is the
; whole string). EndString will mark the absolute end of the string (beyond
; which no comparison may take place).  UptoString marks the current end
; of string when performing backtracking.  If CX is zero upon entry into this
; routine, then this code will find the end of the source string and use that
; location for CX.

		mov	StartString, di
		mov	ds:[si].StartPattern, di
		mov	ds:[si].StrSeg, es
		mov	EndString, cx
		mov	UptoString, cx


; The address of the match function appears in the pattern structure (where
; ds:si is currently pointing).  However, we will soon lose access to this
; structure.  Therefore, it makes sense to copy that pointer into a local
; variable so we have easy access to it.

		mov	ax, word ptr ds:[si].MatchFunction
		mov	MLFuncL, ax
		mov	ax, word ptr ds:[si+2].MatchFunction
		mov	MLFuncH, ax


; Okay, begin the pattern matching down here.  See if the current pattern
; matches the (leading) characters in the string.

TryAgain:	mov	di, StartString		;The match function requires
		mov	cx, UptoString		; string address in ES:DI,
		push	ds			; last position+1 in CX, and
		push	si			; "pattern parameter" in DS:SI.
		push	dx
		lds	si, ds:[si].MatchParm
		mov	dx, ds
		call	MatchFunc
		pop	dx
		pop	si			;Restore pointer to current
		pop	ds			; pattern structure.
		mov	ds:[si].EndPattern, ax
		jnc	MatchFailed

; If this match succeeded, try the next guy in the pattern list.  If there
; is no next guy, we're done (and we've matched).  Note: this code only
; checks the segment portion of the pointer.  It assumes there are no
; pattern values down in segment zero (usually a very good assumption).

		cmp	word ptr ds:[si+2].NextPattern, 0
		jne	TryNext

; If the string matches, drop down here and note the success.  First, we
; need to save the starting and ending positions of the string back into
; the pattern structure.

Success:        mov	sp, bp			;Success!  Let's go home
		pop	bp			; now.
		pop	di			;Note that AX currently con-
		pop	si			; tains the last match posn
		pop	cx			; returned by MatchFunc.
		pop	dx
		pop	ds
		stc				;Return success.
		ret

; If there are additional items in this pattern list, call them to see if
; they succeed (by making a recursive call to sl_Match2).  This must be a
; recursive call (rather than relying on tail recursion) because back
; tracking may be necessary to match this string.

TryNext:        push	dx			;Save ptr to current pattern.
		push	si

		mov	di, ax			;Start this match at the end
		mov	UptoString, ax		; of the previous match.
		mov	dx, word ptr ds:[si+2].NextPattern
		mov	si, word ptr ds:[si].NextPattern
		mov	cx, EndString

		call	sl_Match2

		pop	si
		pop	dx

		jc	Success			;If it matched, we're done.

; Time to try backtracking to see if we can get some other pattern match.

		dec	UptoString	;Disallow the last char and
		mov	ax, UptoString	; try again, though don't go past the
		cmp	ax, StartString	; beginning of the string.
		jge	TryAgain


; If we failed, there is still the possibility that there is an alternate
; pattern to match against.  If so, try matching the alternate pattern
; down here.  If it fails, then we really fail.  If it succeeds, so does
; this pattern.  As is the case throughout this code, the following statements
; assume that if the segment portion of a pointer is zero, the whole pointer
; is zero.


; First, see if there is an alternate pointer:

MatchFailed:	cmp	word ptr ds:[si+2].MatchAlternate, 0
		je	ReallyFailed

; Mark the starting and ending offsets with the same value to denote the
; lack of a match on this string.

		mov     ax, ds:[si].StartPattern
		mov	ds:[si].EndPattern, ax

; If the alternate pointer is non-null, go off and match against the
; alternate string.


		mov	di, StartString
		mov	dx, word ptr ds:[si+2].MatchAlternate
		mov	si, word ptr ds:[si].MatchAlternate
		mov	cx, EndString
		call	sl_Match2
		jc	Success

; Don't forget, AX contains the failure point when we leave this code.

ReallyFailed:	mov	sp, bp
		pop	bp
		pop	di
		pop	si
		pop	cx
		pop	dx
		pop	ds
		clc
		ret
sl_Match2	endp

		endif		;If MASM 6.0






; spancset-	Skips over all characters in a string belonging to a
;		character set.  Note: you do not normally call this
;		routine directly from an application program (which is
;		why it is not called "sl_spancset").  Instead, you include
;		the address of this guy in a pattern and the MATCH routine
;		automatically calls this guy.
;
;	Note: spancset always succeeds.  It will match zero or more chars.
;	      The comments which follow discuss the fact that AX returns
;	      a "failure" position.  This is just the location where we
;	      encounter a character which is not in the specified set.
;	      This routine always succeeds and, thus, always returns with
;	      the carry flag set.  Note that chr(0) is not a legal character
;	      in a string, this code always stops when encountering the
;	      zero terminating byte of a string.
;
; inputs:
;		es:di-	Zero-terminated source string.
;		ds:si-  Pointer to first byte (containing mask) of cset.
;		cx-	Last position to compare in string.
;
; outputs:	ax-	Pointer to failure position in string (points at
;			zero terminating byte if there was a complete
;			match of the source string).


		public	spancset
spancset	proc	far
		push	di
		push	bx
		mov	bh, 0
		dec	di
SpanLp:		inc	di
		cmp	di, cx			;At last position to check?
		jae	Done
		mov	bl, es:[di]		;Get next char to compare
		cmp	bl, 0			;At end of string?
		je	Done
		mov	al, [si]		;Get cset mask byte
		and	al, 8[bx][si]		;See if member of cset.
		jnz	SpanLp

Done:		mov	ax, di			;Return failure posn in AX.
		pop	bx
		pop	di
		stc				;Return success in carry flag.
		ret
spancset	endp




; brkcset-	Skips over all characters in a string which are not a
;		character set.
;
;	Note: brkcset always succeeds.  It will match zero or more chars.
;	      The comments which follow discuss the fact that AX returns
;	      a "failure" position.  This is just the location where we
;	      encounter a character which is in the specified set.
;	      This routine always succeeds and, thus, always returns with
;	      the carry flag set.  Note that chr(0) is not a legal character
;	      in a string, this code always stops when encountering the
;	      zero terminating byte of a string.
;
; inputs:
;		es:di-	Zero-terminated source string.
;		ds:si-  Pointer to first byte (containing mask) of cset.
;		cx-	Last position to compare in string.
;
; outputs:	ax-	Pointer to failure position in string (points at
;			zero terminating byte if there was a complete
;			match of the source string).


		public	Brkcset
Brkcset		proc	far
		push	di
		push	bx
		mov	bh, 0
		dec	di
BrkLp:		inc	di
		cmp	di, cx			;At last position to check?
		jae	BrkDone
		mov	bl, es:[di]		;Get next char to compare
		cmp	bl, 0			;At end of string?
		je	BrkDone
		mov	al, [si]		;Get cset mask byte
		and	al, 8[bx][si]		;See if member of cset.
		jz	BrkLp

BrkDone:	mov	ax, di			;Return failure posn in AX.
		pop	bx
		pop	di
		stc				;Return success in carry flag.
		ret
Brkcset		endp


; MatchToPat-	Matches all characters in a string up to, and including, the
;		specified pattern.
;
; inputs:
;		es:di-	Source string
;		ds:si-	Pattern to match
;		cx- 	Maximum match position
;
; outputs:
;		ax-	Points at first character beyond the end of the matched
;			string if success, contains the initial DI value if
;			failure occurs.
;		carry-	0 if failure, 1 if success.

		public	MatchToPat
MatchToPat	proc	far
		push	dx
		push	di
		push	si
		mov	dx, ds		;Set segment of pattern to match.

MTPLoop:	cmp	di, cx		;See if beyond allowable point already.
		jae	MTPFailure
		match2
		jc	MTPSuccess
		inc	di
		jmp	MTPLoop

MTPFailure:	pop	si
		pop	di
		pop	dx
		mov	ax, di		;Return failure position in AX.
		clc			;Return failure.
		ret

MTPSuccess:	pop	si
		pop	di
		pop	dx
		stc			;Return success.
		ret
MatchToPat	endp







; MatchStr-	Matches a string of characters against the source string.
;		Returns success if all the characters in the string match
;		the next set of characters in the source string.  Returns
;		failure otherwise.
;
; inputs:
;		es:di-	Source string
;		ds:si-	String to match
;		cx- 	Maximum match position
;
; outputs:
;		ax-	failure position (or char position after match if
;			success).
;		carry-	0 if failure, 1 if success.

		public	MatchStr
MatchStr	proc	far
		pushf
		push	di

		cmp	di, cx		;See if beyond allowable point already.
		jae	Failure

		cld
MatchLp:	lodsb
		cmp	al, 0
		je	MSSuccess
		scasb
		jne	Failure
		cmp	di, cx
		jbe	MatchLp
		inc	di		;'cause we're about to dec it.
Failure:	dec	di		;Point back at source of failure.
		mov	ax, di		;Return failure position in AX.
		pop	di
		popf
		clc			;Return failure.
		ret

MSSuccess:      mov	ax, di		;Return next position in AX.
		pop	di
		popf
		stc			;Return success.
		ret
MatchStr	endp


; MatchiStr-	Matches a string of characters against the source string.
;		Returns success if all the characters in the string match
;		the next set of characters in the source string, ignoring
;		case in the source string (by converting to upper case).
;
; inputs:
;		es:di-	Source string
;		ds:si-	String to match, alphas must be upper case.
;		cx- 	Maximum match position
;
; outputs:
;		ax-	failure position (or char position after match if
;			success).
;		carry-	0 if failure, 1 if success.

		public	MatchiStr
MatchiStr	proc	far
		pushf
		push	di

		cmp	di, cx		;See if beyond allowable point already.
		jae	iFailure

		cld
MatchiLp:	lodsb
		cmp	al, 0
		je	MiSSuccess
		mov	ah, es:[di]
		cmp	ah, 'a'
		jb	NoLC
		cmp	ah, 'z'
		ja	NoLC
		and	ah, 5fh
NoLC:		inc	di		;Skip this char.
		cmp	al, ah
		jne	iFailure
		cmp	di, cx
		jbe	MatchiLp

		inc	di		;'cause we're about to dec it.
iFailure:	dec	di		;Point back at source of failure.
		mov	ax, di		;Return failure position in AX.
		pop	di
		popf
		clc			;Return failure.
		ret

MiSSuccess:     mov	ax, di		;Return next position in AX.
		pop	di
		popf
		stc			;Return success.
		ret
MatchiStr	endp



; MatchToStr-	Matches all characters in a string up to, and including, the
;		specified parameter string.
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

		public	MatchToStr
MatchToStr	proc	far
		pushf
		push	di
		push	si
		cld

		cmp	di, cx		;See if beyond allowable point already.
		jae	MTSFailure2

ScanLoop:	push	si
		lodsb			;Get first char of string
		cmp	al, 0		;If empty string, always match
		je	MTSsuccess
		push	cx
		sub	cx, di
	repne	scasb			;Find it.
		pop	cx
		push	di		;Save restart point.
		jne	MTSFailure

CmpLoop:	cmp	di, cx
		jae	MTSFailure3
		lodsb
		cmp	al, 0
		je	MTSsuccess2
		scasb
		je	CmpLoop
		pop	di
		pop	si
		jmp	ScanLoop


MTSFailure:	dec	di		;Point back at source of failure.
MTSFailure3:	add	sp, 4		;Remove si, di from stack.
MTSFailure2:	pop	si
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
MatchToStr	endp







; MatchChar-	Matches a single character against the source string.
;		Returns success if the next char matches, failure otherwise.
;
; inputs:
;		es:di-	Source string
;		si-	character to match (in L.O. byte)
;		cx- 	Maximum match position
;
; outputs:
;		ax-	failure position (or char position after match if
;			success).
;		carry-	0 if failure, 1 if success.

		public	MatchChar
MatchChar	proc	far
		push	di

		cmp	di, cx		;See if beyond allowable point already.
		jae	MCFailure
		mov	ax, si		;To get at L.O. byte
		cmp	al, es:[di]
		je	MCSuccess
MCFailure:	clc
		pop	di
		ret

MCSuccess:	cmp	di, cx		;At EOS?
		jae	NoIncMCS
		inc	di
NoIncMCS:	mov	ax, di
		pop	di
		stc			;Return success.
		ret
MatchChar	endp




; MatchToChar-	Matches all characters in a string up to, and including, the
;		specified parameter character.
;
; inputs:
;		es:di-	Source string
;		si-	Character to match
;		cx- 	Maximum match position
;
; outputs:
;		ax-	Points at first character beyond the end of the matched
;			char if success, contains the initial DI value if
;			failure occurs.
;		carry-	0 if failure, 1 if success.

		public	MatchToChar
MatchToChar	proc	far
		pushf
		push	cx
		push	di
		push	si
		cld

		cmp	di, cx		;See if beyond allowable point already.
		jae	MTCFailure2

		mov	ax, si		;Get char to match in AL
		sub	cx, di
	repne	scasb			;Find it.
		je	MTCsuccess

MTCFailure2:	pop	si
		pop	di
		mov	ax, di		;Return failure position in AX.
		pop	cx
		popf
		clc			;Return failure.
		ret

MTCSuccess:	mov	ax, di		;Return next position in AX.
		pop	si
		pop	di
		pop	cx
		popf
		stc			;Return success.
		ret
MatchToChar	endp





; MatchChars-	Matches a single character against the source string.
;		This guy matches zero or more characters in the string
;		(which must all be the same).  Always returns success.
;
; inputs:
;		es:di-	Source string
;		si-	character to match (in L.O. byte)
;		cx- 	Maximum match position
;
; outputs:
;		ax-	Current position plus one (unless EOS).
;		carry-  1

		public	MatchChars
MatchChars	proc	far
		push	di
		mov	ax, si		;To get at L.O. byte
		dec	di
MCsLoop:	inc	di
		cmp	di, cx		;See if beyond allowable point already.
		jae	MCsDone
		cmp	al, es:[di]
		je	MCsLoop
MCsDone:	mov	ax, di
		pop	di
		stc			;Return success.
		ret
MatchChars	endp



; Anycset-	Matches a single character from the string using the specified
;		character set.
;
; inputs:
;		es:di-	pointer to source string
;		ds:si-	pointer to cset
;		cx-	pointer just beyond the end of the string to compare
;
; Outputs-	ax-	di+1 if match, di if no match (failure position).
;		carry-	1 if success, 0 if failure.

		public	Anycset
Anycset		proc	far
		push	bx

		cmp	cx, di
		jbe	ACFailure

		mov	bh, 0
		mov	bl, es:[di]		;Get next char to compare
		cmp	bl, 0			;At end of string?
		je	ACFailure
		mov	al, [si]		;Get cset mask byte
		and	al, 8[bx][si]		;See if member of cset.
		jz	ACFailure
		lea	ax, 1[di]		;Return success position in AX.
		pop	bx
		stc				;Return success in carry flag.
		ret

ACFailure:	mov	ax, di			;Return failure position in AX.
		pop	bx
		clc				;Return failure in carry flag.
		ret
Anycset		endp




; NotAnycset-	Matches a single character from the string which is not in the
;		specified character set.
;
; inputs:
;		es:di-	pointer to source string
;		ds:si-	pointer to cset
;
; Outputs-	ax-	di+1 if no match, di if match (failure position).
;		carry-	1 if success, 0 if failure.

		public	NotAnycset
NotAnycset	proc	far
		push	bx

		cmp	cx, di
		jbe	NACFailure

		mov	bh, 0
		mov	bl, es:[di]		;Get next char to compare
		cmp	bl, 0			;At end of string?
		je	NACFailure
		mov	al, [si]		;Get cset mask byte
		and	al, 8[bx][si]		;See if member of cset.
		jnz	NACFailure
		lea	ax, 1[di]		;Return success position in AX.
		pop	bx
		stc				;Return success in carry flag.
		ret

NACFailure:	mov	ax, di			;Return failure position in AX.
		pop	bx
		clc				;Return failure in carry flag.
		ret
NotAnycset	endp


; EOS-		Matches the end of the string (i.e., the terminating zero
;		byte).  Fails if any other value is present.
;
; inputs:
;		es:di-	pointer to source string
;
; Outputs-	ax-	di (match or failure position).
;		carry-	1 if success, 0 if failure.
;
; Note that this code does not bump AX or DI to point beyond the matched
; character (since we don't want to go beyond the end of the string).

		public	EOS
EOS		proc	far
		mov	ax, di
		cmp	byte ptr es:[di], 0
		je	SetCarry
		clc
		ret
SetCarry:	stc
		ret
EOS		endp




; ARBNUM-	Matches an arbitrary number (zero or more) occurrences of
;		the specified pattern.
;
; inputs:
;		es:di-	Source string
;		ds:si-	Pattern to match an arbitrary number of times.
;		cx- 	Maximum match position
;
; outputs:
;		ax-	Points at first character beyond the end of the matched
;			patterns if success.
;
;		carry-	1 (this function always succeeds).

		public	ARBNUM
ARBNUM		proc	far
		push	dx
		push	di
		push	si

ARBLoop:	cmp	di, cx		;See if beyond allowable point already.
		jae	ARBSuccess
		mov	dx, ds
		match2
		mov	di, ax		;Move to next position.
		jc	ARBLoop		;If we matched, try again.

ARBSuccess:	pop	si
		pop	di
		pop	dx
		stc			;Always return success.
		ret
ARBNUM		endp





; ARB-		Matches an arbitrary number of characters and always returns
;		success.
;
; inputs:
;		es:di-	pointer to source string
;
; Outputs-	ax-	cx (since this matches any number of chars, we'll
;			match them all).
;		carry-	1.
;

		public	ARB
ARB		proc	far
		mov	ax, cx
		stc
		ret
ARB		endp



; Skip-		Skips over "n" characters in the string.  Returns success if
;		there were at least "n" characters in the string.
;
; inputs:
;		es:di-	pointer to source string
;		si-	number of characters to skip.
;
; Outputs-	ax-	points at first byte beyond skipped chars.
;		carry-	1 if success, 0 if not enough chars in string.
;

		public	Skip
Skip		proc	far

		or	si, si	   	;Immediate success if skip nothing.
		jz	SkipSucceeds

		mov	ax, di		;See where we would be if we skipped
		add	ax, si		; SI chars.
		cmp	ax, cx		;See if too many chars
		jbe	SkipSucceeds	; and return success if not.
		clc
		ret

SkipSucceeds:	stc			;Note: AX contains position after
		ret			; the skip chars.
Skip		endp




; POS-		Returns success if we are at position SI in the string.
;		Returns failure otherwise.
;
; inputs:
;		es:di-	pointer to source string
;		si-	offset into string we need to match.
;
; Outputs-	carry-	1 if success, 0 if failure.


		public	POS
POS		proc	far
		assume	ds:StdGrp
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
		mov	ax, di
		sub	ax, word ptr StdGrp:StringAddress
		cmp	ax, si
		jne	BadPosn
		pop	ds
		mov	ax, di
		stc
		ret

BadPosn:	pop	ds
		mov	ax, di
		clc
		ret
POS		endp
		assume	ds:nothing





; RPOS-		Returns success if we are at position SI from the end of the
;		string. Returns failure otherwise.
;
; inputs:
;		es:di-	pointer to source string
;		si-	offset from end of string to match (note: a value of
;			zero denotes the end of the string).
;
; Outputs-	carry-	1 if success, 0 if failure.


		public	RPOS
RPOS		proc	far
		assume	ds:stdgrp
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
		mov	ax, StdGrp:LastStringAdrs
		sub	ax, di
		cmp	ax, si
		jne	BadRposn
		pop	ds
		mov	ax, di
		stc
		ret

BadRposn:	pop	ds
		mov	ax, di
		clc
		ret
RPOS		endp
		assume	ds:nothing




; GOTOpos-	Moves the "cursor" to position SI in the string.  Succeeds
;		if this doesn't move the cursor beyond the end of the string.
;		fails otherwise.  Note that this command will not let you
;		back up in a string.
;
; inputs:
;		es:di-	pointer to source string
;		si-	position in string to transfer to (zero denotes the
;			first character in the string).
;
; Outputs-	ax-	new string position.
;		carry-	1 if success, 0 if failure.


		public	GOTOpos
GOTOpos		proc	far
		assume	ds:stdgrp
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
		mov	ax, word ptr StdGrp:StringAddress
		add	ax, si
		cmp	ax, StdGrp:LastStringAdrs
		ja	BadGOTO
		cmp	ax, word ptr StdGrp:StringAddress
		jb	BadGOTO
		pop	ds
		stc
		ret

BadGOTO:	pop	ds
		clc
		ret
GOTOpos		endp
		assume	ds:nothing




; RGOTOpos-	Moves the "cursor" to position SI from the end of the string.
;		Succeeds if this doesn't move the cursor beyond the end of
;		the string, fails otherwise.  Note that this command will not
;		let you	back up in a string.
;
; inputs:
;		es:di-	pointer to source string
;		si-	position in string to transfer to (zero denotes the
;			position just beyond the end of the string, i.e.,
;			the zero terminating byte).
;
; Outputs-	ax-	New position in string.
;		carry-	1 if success, 0 if failure.


		public	RGOTOpos
RGOTOpos	proc	far
		assume	ds:stdgrp
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
		mov	ax, word ptr StdGrp:LastStringAdrs
		sub	ax, si
		cmp	ax, StdGrp:LastStringAdrs
		ja	BadRGOTO
		cmp	ax, word ptr StdGrp:StringAddress
		jb	BadRGOTO
		pop	ds
		stc
		ret

BadRGOTO:	pop	ds
		clc
		ret
RGOTOpos	endp
		assume	ds:nothing


stdlib		ends
		end
