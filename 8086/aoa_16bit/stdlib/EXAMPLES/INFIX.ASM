; INFIX.ASM
;
; A simple program which demonstrates the pattern matching routines in the
; UCR library.  This program accepts an arithmetic expression on the command
; line (no interleaving spaces in the expression is allowed, that is, there
; must be only one command line parameter) and converts it from infix notation
; to postfix (rpn) notation.
;
; It would be a fairly trivial exercise to convert this to an integer (or
; floating point) calculator.  All that's really required is to stack up the
; numbers on a stack data structure (not the 80x86 stack!) and then perform
; the arithmetic rather than simply print the operators in the appropriate
; routines below.
;
; Randy Hyde
; 10/28/92
;
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list


dseg		segment	para public 'data'

; Grammar for simple infix -> postfix translation operation:
;
; E -> FE'
; E' -> +F {output '+'} E' | -F {output '-'} E' | <empty string>
; F -> TF'
; F -> *T {output '*'} F' | /T {output '/'} F' | <empty string>
; T -> -T {output 'neg'} | S
; S -> <constant> {output constant} | (E)
;
; UCR Standard Library Pattern which handles the grammar above:

; An expression consists of an "E" item followed by the end of the string:

infix2rpn	pattern	{sl_Match2,E,,EndOfString}
EndOfString	pattern	{EOS}

; An "E" item consists of an "F" item optionally followed by "+" or "-"
; and another "E" item:

E		pattern	{sl_Match2, F,,Eprime}
Eprime		pattern	{MatchChar, '+', Eprime2, epf}
epf		pattern	{sl_Match2, F,,epPlus}
epPlus		pattern	{OutputPlus,,,Eprime}

Eprime2		pattern	{MatchChar, '-', Succeed, emf}
emf		pattern	{sl_Match2, F,,epMinus}
epMinus		pattern	{OutputMinus,,,Eprime}

; An "F" item consists of a "T" item optionally followed  by "*" or "/"
; followed by another "T" item:

F		pattern	{sl_Match2, T,,Fprime}
Fprime		pattern	{MatchChar, '*', Fprime2, fmf}
fmf		pattern	{sl_Match2, T, 0, pMul}
pMul		pattern	{OutputMul,,,Fprime}

Fprime2		pattern	{MatchChar, '/', Succeed, fdf}
fdf		pattern	{sl_Match2, T, 0, pDiv}
pDiv		pattern	{OutputDiv, 0, 0,Fprime}

; T item consists of an "S" item or a "-" followed by another "T" item:

T		pattern	{MatchChar, '-', S, TT}
TT		pattern	{sl_Match2, T, 0,tpn}
tpn		pattern	{OutputNeg}

; An "S" item is either a string of one or more digits or "(" followed by
; and "E" item followed by ")":

Const		pattern	{sl_Match2, DoDigits, 0, spd}
spd		pattern	{OutputDigits}
DoDigits	pattern	{Anycset, Digits, 0, SpanDigits}
SpanDigits	pattern	{Spancset, Digits}

S		pattern	{MatchChar, '(', Const, IntE}
IntE		pattern	{sl_Match2, E, 0, CloseParen}
CloseParen	pattern	{MatchChar, ')'}


Succeed		pattern	{DoSucceed}


		include	stdsets.a

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

		public	PSP
PSP		dw	?

; DoSucceed matches the empty string.  In other words, it matches anything
; and always returns success without eating any characters from the input
; string.

DoSucceed	proc	far
		mov	ax, di
		stc
		ret
DoSucceed	endp


; OutputPlus is a semantic rule which outputs the "+" operator after the
; parser sees a valid addition operator in the infix string.

OutputPlus	proc	far
		print
		byte	" +",0
		mov	ax, di			;Required by sl_Match
		stc
		ret
OutputPlus	endp


; OutputMinus is a semantic rule which outputs the "-" operator after the
; parser sees a valid subtraction operator in the infix string.

OutputMinus	proc	far
		print
		byte	" -",0
		mov	ax, di			;Required by sl_Match
		stc
		ret
OutputMinus	endp


; OutputMul is a semantic rule which outputs the "*" operator after the
; parser sees a valid multiplication operator in the infix string.

OutputMul	proc	far
		print
		byte	" *",0
		mov	ax, di			;Required by sl_Match
		stc
		ret
OutputMul	endp


; OutputDiv is a semantic rule which outputs the "/" operator after the
; parser sees a valid division operator in the infix string.

OutputDiv	proc	far
		print
		byte	" /",0
		mov	ax, di			;Required by sl_Match
		stc
		ret
OutputDiv	endp


; OutputNeg is a semantic rule which outputs the unary "-" operator after the
; parser sees a valid negation operator in the infix string.

OutputNeg	proc	far
		print
		byte	" neg",0
		mov	ax, di			;Required by sl_Match
		stc
		ret
OutputNeg	endp


; OutputDigits outputs the numeric value when it encounters a legal integer
; value in the input string.

OutputDigits	proc	far
		push	es
		push	di
		mov	al, ' '
		putc
		lesi	const
		patgrab
		puts
		free
		stc
		pop	di
		mov	ax, di
		pop	es
		ret
OutputDigits	endp



; Okay, here's the main program which fetches the command line parameter
; and parses it.

Main		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax

		mov	dx, 0			;Allocate all available
		meminit				; memory to the heap.
		jnc	GoodMemInit

		print
		db	"Error initializing memory manager",cr,lf,0
		jmp	Quit
GoodMemInit:

; Make sure there is only one command line parameter:

		argc
		cmp	cx, 1
		je	Okay
		print
		byte	"Usage: infix <expr>",cr,lf,0
		jmp	Quit

; Fetch the command line parameter and then call match to parse it.

Okay:		mov	ax, 1
		argv
		ldxi	infix2rpn
		xor	cx, cx
		match
		jc	Succeeded

; Generic BISON-influenced error message.

		print
		byte	"Parse error",0

Succeeded:	putcr

Quit:		ExitPgm
Main		endp

cseg            ends



; Allocate a reasonable amount of space for the stack (8k).

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


; zzzzzzseg must be the last segment that gets loaded into memory!

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
