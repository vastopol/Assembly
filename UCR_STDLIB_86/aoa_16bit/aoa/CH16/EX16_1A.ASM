; EX16_1a.asm
;
; A simple floating point calculator that demonstrates the use of the
; UCR Standard Library pattern matching routines.  Note that this
; program requires an FPU.

		.xlist
		.386
		.387
		option		segment:use16
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list


dseg		segment	para public 'data'

; The following is a temporary used when converting a floating point
; string to a 64 bit real value.

CurValue	real8	0.0


; A Test String:

TestStr		byte	"5+2-(3-1)",0


; If the symbol "DEBUG" is defined, then call the MatchSP routine
; to do stack overflow checking.  If "DEBUG" is not defined, just
; call the sl_Match2 routine directly.

DEBUG		=	0		;Define for debugging.

		ifdef	DEBUG
MatchPat	textequ	<MatchSP>
		else
MatchPat	textequ	<sl_Match2>
		endif


; Grammar for simple infix -> postfix translation operation:
; Semantic rules appear in braces.
;
; NOTE: This code has a serious problem.  The first production
; is left recursive and will generate an infinite loop.
;
; E -> E+T {print result} | T {print result}
; T -> <constant> {fld constant} | (E)
;
;
;
; UCR Standard Library Pattern that handles the grammar above:

; An expression consists of an "E" item followed by the end of the string:

Expression      pattern {MatchPat,E,,EndOfString}
EndOfString	pattern	{EOS}


; An "E" item consists of an "E" item optionally followed by "+" or "-"
; and a "T" item (E -> E+T | T):

E               pattern {MatchPat, E,T,Eplus}
Eplus		pattern	{MatchChar, '+', T, epPlus}
epPlus		pattern	{DoFadd}


; A "T" item is either a floating point constant or "(" followed by
; an "E" item followed by ")".
;
; The regular expression for a floating point constant is
;
;	[0-9]+ ( "." [0-9]* | ) ( ((e|E) (+|-| ) [0-9]+) | )
;
; Note: the pattern "Const" matches exactly the characters specified
;	by the above regular expression.  It is the pattern the calc-
;	ulator grabs when converting a string to a floating point number.


Const           pattern {MatchPat, ConstStr, 0, FLDConst}
ConstStr        pattern {MatchPat, DoDigits, 0, Const2}
Const2		pattern	{matchchar, '.', Const4, Const3}
Const3          pattern {MatchPat, DoDigits, Const4, Const4}
Const4		pattern	{matchchar, 'e', const5, const6}
Const5		pattern	{matchchar, 'E', Succeed, const6}
Const6		pattern	{matchchar, '+', const7, const8}
Const7		pattern	{matchchar, '-', const8, const8}
Const8          pattern {MatchPat, DoDigits}

FldConst	pattern	{PushValue}

; DoDigits handles the regular expression [0-9]+

DoDigits	pattern	{Anycset, Digits, 0, SpanDigits}
SpanDigits	pattern	{Spancset, Digits}

; The S production handles constants or an expression in parentheses.

T		pattern	{MatchChar, '(', Const, IntE}
IntE            pattern {MatchPat, E, 0, CloseParen}
CloseParen	pattern	{MatchChar, ')'}


; The Succeed pattern always succeeds.

Succeed		pattern	{DoSucceed}


; We use digits from the UCR Standard Library cset standard sets.

		include	stdsets.a

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Debugging feature #1:
; This is a special version of sl_Match2 that checks for
; stack overflow.  Stack overflow occurs whenever there
; is an infinite loop (i.e., left recursion) in a pattern.

MatchSP		proc    far
		cmp	sp, offset StkOvrfl
		jbe	AbortPgm
		jmp	sl_Match2

AbortPgm:	print
                byte    cr,lf,lf
		byte	"Error: Stack overflow in MatchSP routine.",cr,lf,0
		ExitPgm
MatchSP          endp


; DoSucceed matches the empty string.  In other words, it matches anything
; and always returns success without eating any characters from the input
; string.

DoSucceed	proc	far
		mov	ax, di
		stc
		ret
DoSucceed	endp


; DoFadd - Adds the two items on the top of the FPU stack.

DoFadd		proc	far
		faddp	st(1), st
		mov	ax, di			;Required by sl_Match
		stc				;Always succeed.
		ret
DoFadd		endp


; PushValue-	We've just matched a string that corresponds to a
;		floating point constant.  Convert it to a floating
;		point value and push that value onto the FPU stack.

PushValue	proc	far
		push	ds
		push	es
		pusha
		mov	ax, dseg
		mov	ds, ax

		lesi	Const		;FP val matched by this pat.
		patgrab			;Get a copy of the string.
		atof			;Convert to real.
		free			;Return mem used by patgrab.
		lesi	CurValue	;Copy floating point accumulator
		sdfpa			; to a local variable and then
		fld	CurValue	; copy that value to the FPU stk.

		popa
		mov	ax, di
		pop	es
		pop	ds
		stc
		ret
PushValue	endp



; The main program tests the expression evaluator.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		finit			;Be sure to do this!
		fwait

		lesi	TestStr
		puts			;Print the expression

		ldxi	Expression
		xor	cx, cx
		match
		jc	GoodVal
		printff
		byte	" is an illegal expression",cr,lf,0
		ret

GoodVal:	fstp	CurValue
		printff
		byte	" = %12.6ge\n",0
		dword	CurValue

Quit:		ExitPgm
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
		word	64 dup (?)		;Buffer for stack overflow
StkOvrfl	word	?			;Stack overflow if drops
stk		db	1024 dup ("stack   ")	; below StkOvrfl.
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
