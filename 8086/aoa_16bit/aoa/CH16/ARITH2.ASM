; ARITH2.ASM
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


; Some sample strings containing expressions to try out:


Str1		byte	"5+2*(3-1)",0
Str2		byte	"(5+2)*(7-10)",0
Str3		byte	"5",0
Str4		byte	"(6+2)/(5+1)-7e5*2/1.3e2+1.5",0
Str5		byte	"2.5*(2-(3+1)/4+1)",0
Str6		byte	"6+(-5*2)",0
Str7		byte	"6*-1",0
Str8		byte	"1.2e5/2.1e5",0
Str9		byte	"0.9999999999999999+1e-15",0
str10		byte	"2.1-1.1",0


; Grammar for simple infix -> postfix translation operation:
; Semantic rules appear in braces.
;
; E -> FE' {print result}
; E' -> +F {fadd} E' | -F {fsub} E' | <empty string>
; F -> TF'
; F -> *T {fmul} F' | /T {fdiv} F' | <empty string>
; T -> -T {fchs} | S
; S -> <constant> {fld constant} | (E)
;
;
;
; UCR Standard Library Pattern which handles the grammar above:

; An expression consists of an "E" item followed by the end of the string:

Expression	pattern	{sl_Match2,E,,EndOfString}
EndOfString	pattern	{EOS}


; An "E" item consists of an "F" item optionally followed by "+" or "-"
; and another "E" item:

E		pattern	{sl_Match2, F,,Eprime}
Eprime		pattern	{MatchChar, '+', Eprime2, epf}
epf		pattern	{sl_Match2, F,,epPlus}
epPlus		pattern	{DoFadd,,,Eprime}

Eprime2		pattern	{MatchChar, '-', Succeed, emf}
emf		pattern	{sl_Match2, F,,epMinus}
epMinus		pattern	{DoFsub,,,Eprime}

; An "F" item consists of a "T" item optionally followed  by "*" or "/"
; followed by another "T" item:

F		pattern	{sl_Match2, T,,Fprime}
Fprime		pattern	{MatchChar, '*', Fprime2, fmf}
fmf		pattern	{sl_Match2, T, 0, pMul}
pMul		pattern	{DoFmul,,,Fprime}

Fprime2		pattern	{MatchChar, '/', Succeed, fdf}
fdf		pattern	{sl_Match2, T, 0, pDiv}
pDiv		pattern	{DoFdiv, 0, 0,Fprime}

; T item consists of an "S" item or a "-" followed by another "T" item:

T		pattern	{MatchChar, '-', S, TT}
TT		pattern	{sl_Match2, T, 0,tpn}
tpn		pattern	{DoFchs}

; An "S" item is either a floating point constant or "(" followed by
; and "E" item followed by ")".
;
; The regular expression for a floating point constant is
;
;	[0-9]+ ( "." [0-9]* | ) ( ((e|E) (+|-| ) [0-9]+) | )
;
; Note: the pattern "Const" matches exactly the characters specified
;	by the above regular expression.  It is the pattern the calc-
;	ulator grabs when converting a string to a floating point number.


Const		pattern	{sl_match2, ConstStr, 0, FLDConst}
ConstStr	pattern	{sl_match2, DoDigits, 0, Const2}
Const2		pattern	{matchchar, '.', Const4, Const3}
Const3		pattern	{sl_match2, DoDigits, Const4, Const4}
Const4		pattern	{matchchar, 'e', const5, const6}
Const5		pattern	{matchchar, 'E', Succeed, const6}
Const6		pattern	{matchchar, '+', const7, const8}
Const7		pattern	{matchchar, '-', const8, const8}
Const8		pattern	{sl_match2, DoDigits}

FldConst	pattern	{PushValue}

; DoDigits handles the regular expression [0-9]+

DoDigits	pattern	{Anycset, Digits, 0, SpanDigits}
SpanDigits	pattern	{Spancset, Digits}

; The S production handles constants or an expression in parentheses.

S		pattern	{MatchChar, '(', Const, IntE}
IntE		pattern	{sl_Match2, E, 0, CloseParen}
CloseParen	pattern	{MatchChar, ')'}


; The Succeed pattern always succeeds.

Succeed		pattern	{DoSucceed}


; We use digits from the UCR Standard Library cset standard sets.

		include	stdsets.a

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

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


; DoFsub - Subtracts the two values on the top of the FPU stack.

DoFsub		proc	far
		fsubp	st(1), st
		mov	ax, di			;Required by sl_Match
		stc
		ret
DoFsub		endp


; DoFmul- Multiplies the two values on the FPU stack.

DoFmul		proc	far
		fmulp	st(1), st
		mov	ax, di			;Required by sl_Match
		stc
		ret
DoFmul		endp


; DoFdiv- Divides the two values on the FPU stack.

DoFDiv		proc	far
		fdivp	st(1), st
		mov	ax, di			;Required by sl_Match
		stc
		ret
DoFDiv		endp


; DoFchs- Negates the value on the top of the FPU stack.

DoFchs		proc	far
		fchs
		mov	ax, di			;Required by sl_Match
		stc
		ret
DoFchs		endp


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



; DoExp-	This routine expects a pointer to a string containing
;		an arithmetic expression in ES:DI.  It evaluates the
;		given expression and prints the result.

DoExp		proc	near
		finit			;Be sure to do this!
		fwait

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
		ret
DoExp		endp



; The main program tests the expression evaluator.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		lesi	Str1
		call	DoExp
		lesi	Str2
		call	DoExp
		lesi	Str3
		call	DoExp
		lesi	Str4
		call	DoExp
		lesi	Str5
		call	DoExp
		lesi	Str6
		call	DoExp
		lesi	Str7
		call	DoExp
		lesi	Str8
		call	DoExp
		lesi	Str9
		call	DoExp
		lesi	Str10
		call	DoExp

Quit:		ExitPgm
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
