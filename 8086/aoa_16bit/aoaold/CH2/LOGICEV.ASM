; Logic evaluation program.
; Written by Randall Hyde
; 12/8/94
; (c) copyright 1994, all rights reserved.
; For use with the lab associated with Chapter Two in "The Art of Assembly
; Language Programming"

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list



; Some useful constants:

CtrlC		equ	3
Bell		equ	7
aESC		equ	1bh
MaxPropogation	equ	100


dseg		segment	para public 'data'

; Input buffer for interactive I/O

InputLn		byte	128 dup (0)


; Variables is an array that holds the current values for the A..Z variables.
; Note that A, B, C, and D are input from the parallel port, so the user
; cannot initialize these first four values.  The zero entry is reserved for
; the clock variable ("#").  WARNING: VAR1..VAR4 must remain in this order!
; They form an array of four words.
;
; The array contains extra entries to ease the generation of the truth table
; if there are less than four variables associated with a function.
;
; This code uses the TempVars arrays to hold results while computing results
; for logic equations implementing sequential logic (we need to compute all
; outputs before feeding those outputs back as inputs).


Variables	byte	32 dup (0)
TempVars	byte	32 dup (0)




TTStruc		struct
Next		dword	?		;Link to next truth table.
Equation	dword	?		;Pointer to string
Vars		word	4 dup (?)	;Indexes into Variables array.
VarChars	byte	4 dup (?)
HasClk		byte	?		;Flag denoting sequential logic.
FuncName	byte	?		;Function's name.
TT		byte	32 dup (?)	;Truth table.
TTStruc		ends


TTHead		dword	0		;Pointer to first TT in list.
TTTail		dword	0		;Pointer to last TT in list.
TTIndex		word	0		;Index we use while filling a table.

TruthTable	TTStruc	{}
ClkVar		word	0
Dummy		word	0
Has1		word	0
BadFuncName	word	0		;Set to one if bad function name.

Mode		byte	0		;Hardware mode or software simulation.
		byte	0		;Padding
Dly18Cnst	word	0		;Used to delay for 1/18th secs.

; EvalStk-	Evaluation stack.  We'll evaluate the boolean expressions
;		here.

EVSP		word	0		;Eval stack pointer.
EvalStk		byte	32 dup (0)	;32 bytes should be sufficient.



; Some sets we use throughout this program:
;
; ExpIDs-	IDs that may appear within an expression.
; Funcnames-	IDs you can specify as function names.
; TermSet-	List of IDs (terms) appearing within an expression.

		set	ExpIDs, FuncNames, TermSet




; ScrnBase-	Base Segment address for the display.

ScrnBase	word	0b800h		;0B000h for mono, 0b800h for color.

; Attribute-	Attribute byte for the screen.

Attribute	byte	1fH		;7 for mono, 1Fh for color

; ScreenMode-	Display adapter mode

ScreenMode	byte	01		;07 for mono, else color.

; DispPage-	Page number for color displays.

DispPage	byte	0		;Generally zero.

; Dim-		Screen attribute that creates a dimmed character.

Dim		byte	17h

; Inverse-	Screen attribute that creates an inverted character.

Inverse		byte	5Fh



; Function Name- Single character providing the name of the function
; we are currently parsing.

FunctionName	byte	?


; TermCnt- This variable counts the number of unique terms in an expression.

TermCnt		word	0



; Parallel Port variables:

OutPort		word	0		;Base address of parallel port.
InPort		word	0		;Address of input port.



; Patterns that provide a context free grammar we can use to parse the
; boolean expressions.


Function	pattern	{spancset, WhiteSpace,,F1}
F1		pattern	{SetFuncName,,,F2}
F2		pattern	{anycset,FuncNames,F5,F3}
F3		pattern	{spancset, WhiteSpace,,F4}
F4		pattern	{matchchar, "=",,Expression}

F5		pattern	{BadFnName}

Expression	pattern	{sl_match2, Sum,,ExpDone}
ExpDone		pattern	{EOS}

Sum		pattern	{sl_match2, Prdct,, S2}
S2		pattern	{matchchar, "+",Succeed,S3}
S3		pattern	{sl_match2, Prdct,,S2}

Prdct		pattern	{sl_match2, Term,, P2}
P2		pattern	{matchchar, "*", P4, P3}
P3		pattern	{sl_match2, Term,,P2}
P4		pattern	{sl_match2, Term,Succeed, P2}

Term		pattern	{spancset, WhiteSpace,, T1}
T1		pattern	{anycset, ExpIDs, T3, T2}
T2		pattern	{AddTerm,,,T7}

T3		pattern	{matchchar, "(",, T4}
T4		pattern	{spancset, WhiteSpace,, T5}
T5		pattern	{sl_match2, Sum,,T6}
T6		pattern {matchchar, ")",,T7}

T7		pattern	{matchchar, "'", EndTerm, EndTerm}
EndTerm		pattern	{spancset, WhiteSpace}





; Patterns, similar to the above, that actually evaluate an expression.


eFunction	pattern	{spancset, WhiteSpace,,eF1}
eF1		pattern	{anycset, FuncNames,,eF2}
eF2		pattern	{spancset, WhiteSpace,,eF3}
eF3		pattern	{matchchar, "=",,eExpression}

eExpression	pattern	{sl_match2, eSum,,eExpDone}
eExpDone	pattern	{EOS}

eSum		pattern	{sl_match2, ePrdct,, EPrime}
Eprime		pattern	{matchchar, "+",Succeed, eS2}
eS2		pattern	{sl_match2, ePrdct,,eS3}
eS3		pattern	{ORes,,,eS4}
eS4		pattern	{sl_match2, EPrime}

ePrdct		pattern	{sl_match2, eTerm,, ePPrime}
ePPrime		pattern	{matchchar, "*",eP4, eP2}
eP2		pattern	{sl_match2, eTerm,,eP3}
eP3		pattern	{ANDes,,,ePPrime}
eP4		pattern	{sl_match2, eTerm,Succeed, eP3}

eTerm		pattern	{spancset, WhiteSpace,, eT1}
eT1		pattern	{anycset, ExpIDs, eT3, eT2}
eT2		pattern	{PushTerm,,,eT7}

eT3		pattern	{matchchar, "(",, eT4}
eT4		pattern	{spancset, WhiteSpace,, eT5}
eT5		pattern	{sl_match2, eSum,,eT6}
eT6		pattern {matchchar, ")",,eT7}

eT7		pattern	{matchchar, "'", eEndTerm, eT8}
eT8		pattern	{NOTes,,,eEndTerm}
eEndTerm	pattern	{spancset, WhiteSpace}


Succeed		pattern	{DoSucceed}



		include	stdsets.a
dseg		ends







cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg




;************************************************************************
;*									*
;* BadFnName-	The match procedure calls this "matching function" if	*
;*		there is a bad function name.  This code sets an error	*
;*		flag we can test later if this occurs.			*
;*									*
;************************************************************************

BadFnName	proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax

		mov	BadFuncName, 1

		mov	ax, di
		pop	ds
		clc			;Return error/no match.
		ret
BadFnName	endp




;************************************************************************
;*									*
;* SetFuncName-	ES:DI points at a function name (hopefully).  Copy this	*
;*		into the FunctionName variable.  Also initializes the	*
;*		TermSet variable to the empty set.  This set represents	*
;*		the names of the terms appearing within the expression.	*
;*									*
;************************************************************************



SetFuncName	proc	far
		push	ds
		push	es
		push	di
		mov	ax, dseg
		mov	ds, ax

		mov	al, es:[di]
		mov	FunctionName, al


; Initialize the counter and set so we can keep track of how many
; terms appear in the expression.

		lesi	TermSet
		EmptySet
		mov	TermCnt, 0

		pop	di
		pop	es
		pop	ds
		mov	ax, di
		stc
		ret
SetFuncName	endp



;************************************************************************
;*									*
;* AddTerm-	Adds the current term to the TermSet.			*
;*									*
;************************************************************************

AddTerm		proc	far
		push	ds
		push	es
		push	di

		mov	ax, dseg
		mov	ds, ax

		mov	al, es:[di-1]	;It was the previous character
		lesi	TermSet
		Member
		jne	AlreadyThere
		AddChar
		inc	TermCnt
AlreadyThere:
		pop	di
		pop	es
		pop	ds
		mov	ax, di
		stc
		ret

AddTerm		endp



DoSucceed	proc	far
		mov	ax, di
		stc
		ret
DoSucceed	endp








;************************************************************************
;*									*
;* Evaluation Stack routines:						*
;*									*
;*	PSHes- Pushes AL onto the eval stk.				*
;* 	POPes- Pops AL from the eval stk.				*
;*	ANDes- ANDs the two values on the stk.				*
;*	ORes - ORs the two values on the stk.				*
;*	NOTes- Logically NOTs the value on TOS.				*
;*									*
;************************************************************************


PSHes		proc	near
		push	ds
		push	bx

		mov	bx, dseg
		mov	ds, bx

		mov	bx, EVsp
		mov	EvalStk[bx], al
		inc	EVsp
		pop	bx
		pop	ds
		ret
PSHes		endp

POPes		proc   	near

		push	ds
		push	bx

		mov	bx, dseg
		mov	ds, bx

		dec	EVsp
		mov	bx, EVsp
		mov	al, EvalStk[bx]
		pop	bx
		pop	ds
		ret
POPes		endp


ANDes		proc	far
		call	POPes
		mov	ah, al
		call	POPes
		and	al, ah
		call	PSHes
		mov	ax, di
		stc
		ret
ANDes		endp

ORes		proc	far
		call	POPes
		mov	ah, al
		call	POPes
		or	al, ah
		call	PSHes
		mov	ax, di
		stc
		ret
ORes		endp


NOTes		proc	far
		call	POPes
		xor	al, 1
		call	PSHes
		mov	ax, di
		stc
		ret
NOTes		endp





;************************************************************************
;*									*
;* PushTerm-	Decodes a variable name and pushes its value onto the	*
;*		evaluation stack.					*
;*									*
;************************************************************************



PushTerm	proc	far
		push	ds
		push	es
		push	bx
		push	di

		mov	ax, dseg
		mov	ds, ax

		mov	al, es:[di-1]	;It was the previous character
		cmp	al, "#"		;Special case for clock.
		jne	NotClk
		mov	al, 0

NotClk:		and	ax, 1fh		;Convert to 0..26
		mov	bx, ax
		mov	al, Variables[bx]
		call	PSHes

		pop	di
		pop	bx
		pop	es
		pop	ds
		mov	ax, di
		stc
		ret
PushTerm	endp






;************************************************************************
;*									*
;* PutTTRow-	Outputs a row in a truth table.  ES:DI points at the	*
;*		four bytes to print. BX contains the index into the ary.*
;*									*
;************************************************************************

PutTTRow	proc	near
		push	bx
		push	cx

		mov	cx, 4
TTLoop:		mov	al, es:[di].TTStruc.TT[bx]
		or	al, '0'
		putc
		mov	al, ' '
		putc
		inc	bx
		loop	TTLoop

		cmp	es:[di].TTStruc.HasClk, 0
		je	No2ndPart

		print
		byte	"    ",0

		add	bx, 12
		mov	cx, 4
TTLoop2:	mov	al, es:[di].TTStruc.TT[bx]
		or	al, '0'
		putc
		mov	al, ' '
		putc
		inc	bx
		loop	TTLoop2

No2ndPart:	putcr
		pop	cx
		pop	bx
		ret
PutTTRow	endp





;************************************************************************
;*									*
;* PrintTT-	Prints a truth table.  On entry, ES:DI points at a	*
;*		truth table structure.					*
;*									*
;************************************************************************



PrintTT		proc	near
		push	ax
		push	bx
		push	cx

		putcr

; If this function uses the clock signal, we will have to display *two*
; truth tables.

		cmp	es:[di].TTStruc.HasClk, 0
		je	ItsComb0

; Print the value of the clock signal above the two truth tables.

		print
		byte	"     # = 0       # = 1",cr,lf,0
ItsComb0:


; Print the two variable names above the truth table(s):

		print
		byte	"    ",0
		mov	al, es:[di].TTStruc.VarChars[1]
		putc
		mov	al, es:[di].TTStruc.VarChars[0]
		putc


; Print a second copy of the variable names if this circuit involves a
; clock signal:

		cmp	es:[di].TTStruc.HasClk, 0
		je	ItsComb1

		print
		byte	"          ",0
		mov	al, es:[di].TTStruc.VarChars[1]
		putc
		mov	al, es:[di].TTStruc.VarChars[0]
		putc

ItsComb1:

; Print out the third and fourth variable names to the left of the table:

		putcr
		mov	al, es:[di].TTStruc.VarChars[3]
		putc
		mov	al, es:[di].TTStruc.VarChars[2]
		putc
		print
		byte	"  ",0

; Print out each row of the truth table(s):

		mov	bx, 0
		call	PutTTRow

; If we have a "C" variable, print at least two rows:

		cmp	es:[di].TTStruc.VarChars[2], '*'
		je	TTDone

		print
		byte	"    ",0
		mov	bx, 4
		call	PutTTRow


; If we have a "D" variable, print all the rows

		cmp	es:[di].TTStruc.VarChars[3], '*'
		je	TTDone

		print
		byte	"    ",0
		mov	bx, 8
		call	PutTTRow

		print
		byte	"    ",0
		mov	bx, 12
		call	PutTTRow

TTDone:		putcr

; If this is a combinatorial equation (no use of clock), then print
; the canonical form of the boolean expression.

		cmp	es:[di].TTStruc.HasClk, 0
		je	IsComb0
		print
		byte	"Sequential Circuit (no canonical form given)."
		byte	cr,lf,lf,0
		jmp	PTTDone

; Determine the number of terms in the canonical form based on the
; number of variables present in the function.

IsComb0:	mov     cx, 16		;Maximum number of entries to try.

		cmp	es:[di].TTStruc.VarChars[3], '*'
		jne	IsComb
		mov	cx, 8

		cmp	es:[di].TTStruc.VarChars[2], '*'
		jne	IsComb
		mov	cx, 4

		cmp	es:[di].TTStruc.VarChars[1], '*'
		jne	IsComb
		mov	cx, 2

		cmp	es:[di].TTStruc.VarChars[0], '*'
		jne	IsComb
		mov	al, '0'
		putc
		putcr
		putcr
		jmp	PTTDone

IsComb:		mov	al, es:[di].TTStruc.FuncName
		putc
		print
		byte	" = ",0

		mov	Has1, 0
		mov	bx, 0

CLp:
		mov	al, es:[di].TTStruc.TT[bx]
		cmp	al, 0
		je	NoTerm

		cmp	Has1, 0
		je	NoPlus
		print
		byte	" + ",0
NoPlus:		mov	Has1, 1

		mov	al, es:[di].TTStruc.VarChars[0]
		mov	ah, 1
		call	PrintTerm

		mov	al, es:[di].TTStruc.VarChars[1]
		mov	ah, 10b
		call	PrintTerm

		mov	al, es:[di].TTStruc.VarChars[2]
		mov	ah, 100b
		call	PrintTerm

		mov	al, es:[di].TTStruc.VarChars[3]
		mov	ah, 1000b
		call	PrintTerm

NoTerm:		inc	bx
		cmp	bx, cx
		jb	CLp
		putcr
		putcr

PTTDone:
		pop	cx
		pop	bx
		pop	ax
		ret
PrintTT		endp






;************************************************************************
;*									*
;* PrintTerm-	BX contains a four bit number, print the minterm that	*
;*		corresponds to it.					*
;*									*
;************************************************************************


PrintTerm	proc	near
		cmp	al, '*'		;Don't bother with unused terms
		je	NotTerm
		putc			;Print term
		test	bl, ah		;See if we need a prime.
		jne	NotTerm
		mov	al, "'"
		putc
NotTerm:	ret

PrintTerm	endp






;************************************************************************
;*									*
;* Gotoxy-	Positions the cursor at location (dl, dh) on the screen *
;*									*
;************************************************************************


Gotoxy		textequ	<call	Gotoxy_p>

Gotoxy_p	proc	near
		push	bx
		push	ax
		mov	ah, 2
		mov	bh, DispPage
		int	10h
		pop	ax
		pop	bx
		ret
Gotoxy_p	endp




;************************************************************************
;*									*
;* ClearScreen-	This routine clears the display by writing blue spaces	*
;*		throughout screen memory.				*
;*									*
;************************************************************************

ClearScreen	proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	es

		mov	ax, ScrnBase		;Segment base address of
		mov	es, ax			; the screen.
		mov	cx, 80*25		;80 x 25 display only.
		mov	di, 0
		mov	ah, Attribute
		mov	al, ' '
	rep	stosw

		mov	dx, 0			;Position cursor at (0,0)
		GotoXY

		pop	es
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
ClearScreen	endp







;************************************************************************
;*									*
;* DispChar-	Writes the character in AL whose attribute appears in	*
;*		AH to the screen at position (dl,dh).			*
;*									*
;************************************************************************

DispChar	textequ	<call DispChar_p>

DispChar_p	proc
		push	ax
		push	bx
		push	cx
		push	dx

		GotoXY

		mov	bh, DispPage
		mov	bl, ah
		mov	cx, 1
		mov	ah, 9
		int	10h

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
DispChar_p	endp









;************************************************************************
;*									*
;* PrtXY-	The first two bytes following the call contain the	*
;*		(y,x) coordinates for the string that follows.		*
;*									*
;************************************************************************

PrtXY		textequ	<call printxy>

printxy		proc
		push	bp
		mov	bp, sp
		sub	sp, 2		;Make room for coordinates.
		push	ax
		push	bx
		push	dx

		mov	bx, 2[bp]	;Get return address.
		mov	dl, cs:[bx+1]	;Get x coordinate.
		mov	dh, cs:[bx]	;Get y coordinate.
		mov	[bp-2], dx	;Save coordinates.
		GotoXY
		add	bx, 2		;Skip to string.
PrtStrLp:	mov	al, cs:[bx]	;Get chars to print.
		cmp	al, 0		;Quit on zero byte.
		je	pxyDone
		cmp	al, cr		;Carriage return?
		je	PrtCR
		putc
		inc	bx
		jmp	PrtStrLp

; Handle the carriage return character here.  When encountering
; a carriage return, move to the beginning of the next line
; but start printing at the originally specified X coordinate.

prtCR:		inc	byte ptr [bp-1]	;Bump y coordinate.
		mov	dx, [bp-2]
		GotoXY
		inc	bx
		jmp	PrtStrLp

pxyDone:	inc	bx
		mov	2[bp], bx
		pop	dx
		pop	bx
		pop	ax
		add	sp, 2
		pop	bp
		ret
printxy		endp






;************************************************************************
;*									*
;* DrawBox-     DH contains an upper Y coordinate, DL contains a lower  *
;*		Y coordinate.  CL contains a rightmost X coordinate, CH *
;*		contains a leftmost X coordinate.  Draw a box through   *
;*		these coordinates using the PC's line drawing chars.	*
;*									*
;*		(cl,ch)				   (dl,ch)		*
;*		  +-----------------------------------+			*
;*		  |				      |			*
;*		  +-----------------------------------+			*
;*		(cl,dh)				   (dl,dh)		*
;*									*
;************************************************************************


DrawBox		textequ	<call DrawBox_p>
DB_left		textequ	<byte ptr [bp+5]>
DB_rt		textequ	<byte ptr [bp+4]>
DB_up		textequ	<byte ptr [bp+3]>
DB_dn		textequ	<byte ptr [bp+2]>

DrawBox_p	proc
		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp, sp


; First, output the upper two corners the and line between them:

		mov	dl, DB_left
		mov	dh, DB_up
		GotoXY

		mov	al, 218		;ASCII code for upper left corner.
		putc

		mov	ch, 0
		mov	cl, DB_rt
		sub	cl, DB_left
		dec	cx
		push	cx		;Save width of horz bar.
		je	NoHorz0

		mov	al, 196		;ASCII code for horz bar.
TopBarLp:	putc			;Output upper horizontal line.
		loop	TopBarLp

NoHorz0:	mov	al, 191		;ASCII code for upper right corner.
		putc


; Now output the lower two corners and the line between them:

		mov	dl, DB_left
		mov	dh, DB_dn
		GotoXY
		mov	al, 192		;ASCII code for lower right corner.
		putc
		pop	cx		;Retrieve width of box.
		jcxz	NoHorz1

		mov	al, 196		;ASCII code for Horz bar.
BtmBarLp:	putc			;Output lower horizontal line.
		loop	BtmBarLp

NoHorz1:	mov	al, 217		;ASCII code for lower right corner.
		putc


; Now output the two vertical bars:

		mov	cl, DB_dn
		sub	cl, DB_up
		dec	cx
		jz	DB_Done

		mov	dh, DB_up	;Position for start of vertical bars.
		inc	dh

		mov	al, 179		;ASCII code for vertical bar.
VBlp:		mov	dl, DB_left
		GotoXY
		putc
		mov	dl, DB_rt
		GotoXY
		putc
		inc	dh
		loop	VBlp

DB_Done:
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
DrawBox_p	endp





;************************************************************************
;*									*
;* PutInitial-	Writes the initial values for each of the variables to	*
;*		the display.						*
;*									*
;************************************************************************

PutInitial	proc
		push	ax
		push	bx
		push	cx
		push	dx


; Since the user cannot initialize A, B, C, and D, gray out these letters.

		mov	dx, 120eh
		mov	ah, Dim
		mov	al, 41h
		DispChar

		mov	dx, 1210h
		mov	ah, Dim
		mov	al, 42h
		DispChar

		mov	dx, 1212h
		mov	ah, Dim
		mov	al, 43h
		DispChar

		mov	dx, 1214h
		mov	ah, Dim
		mov	al, 44h
		DispChar

		mov	dx, 1216h
		mov	bx, 5			;Start with variable "E".
		mov	al, 'E'
DispVars:	mov	ah, Attribute		;Assume value = 0.
		cmp	Variables[bx], 0        ;Is this zero or one?
		je	GotAttr
		mov	ah, Inverse		;Nope, it's a one.
GotAttr:	DispChar
		inc	al			;Move on to next char.
		inc	bx			;Next item in variables.
		add	dx, 2			;Move on to next position.
		cmp	al, 'Z'
		jbe	DispVars		;Repeat for all variables.

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
PutInitial	endp






;************************************************************************
;*									*
;* GetInit-	Inputs initial values from the user for the logic 	*
;*		variables.  If the user presses A-Z this will invert 	*
;* 		the given variable (of course, A-D don't really count	*
;*		since they are switch inputs).  Pressing the return key	*
;*		completes the operation.				*
;*									*
;*		This code does *not* allow the user to initialize the	*
;*		clock variable.						*
;*									*
;************************************************************************

GetInit		proc	near
		push	ax
		push	bx
		push	cx
		push	dx

		call	ClearScreen

		PrtXY
		byte	2,31
		byte	"Initialize Variables",0

		mov	cx, 1d34h		;Draw a box around the
		mov	dx, 0103h		; Init message.
		DrawBox


		PrtXY
		byte	4,20
		byte	"All variables default to zero.  If you",cr
		byte	"want to change any particular variable,",cr
		byte	"simply press the alphabetic key that",cr
		byte	"corresponds to that variable.  Doing so",cr
		byte	"will invert the value of that variable.",cr,cr
		byte	"Note: since this program reads A, B, C,",cr
		byte	"and D's values from the switches, it",cr
		byte	"will ignore their initial values.  Keep",cr
		byte	"in mind, values written to W, X, Y, and",cr
		byte	"Z affect the LEDs.",0


		mov	dx, 1519h
		mov	ax, 1f41h
		DispChar
		PrtXY
		byte	15h, 1ah
		byte	" = initial value is zero.",0

		mov	dx, 1619h
		mov	ax, 5f41h
		DispChar
		PrtXY
		byte	16h, 1ah
		byte	" = initial value is one.",0

		PrtXY
		byte	17h, 19h
		byte	"Press ENTER after setting initial values",0


; The following loop reads keystrokes from the user and updates the
; specified variable.  When the user presses the enter key, this code
; terminates.

		mov	cx, 0847h		;Draw a box across the
		mov	dx, 1113h		; screen
		DrawBox



		mov	bh, 0
GetLp:		call	PutInitial
		mov	dx, 1900h	;Move the cursor off the screen.
		GotoXY
		mov	ah, 0		;Read ASCII code directly from
		int	16h		; BIOS.
		toupper
		isupper			;See if upper case.
		jne	NotUpperCase	;Ignore non-alpha characters.
		sub	al, "A"-1	;Convert to range 1..26
		mov     bl, al		;Use as index into Variables array.
		xor	Variables[bx],1	;Toggle value between zero and one.
		jmp	GetLp

NotUpperCase:	cmp	al, CtrlC	;Quit if user presses Ctrl-C
		je	QuitPgm
		cmp	al, cr		;If not alpha, is it CR?
		jne	GetLp		;If not, ignore and get next char.
					;Quit if it is a CR.
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret

QuitPgm:	call	ClearScreen
		ExitPgm

GetInit		endp





;************************************************************************
;*									*
;* GetFuncs-	Allows the user to enter an arbitrary number of logic	*
;*		equations to evaluate.  Generates a list of such func-	*
;*		tions for later evaluation.				*
;*									*
;************************************************************************


GetFuncs	proc
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si

; Repeat the following for each logic function the user inputs:

GFLoop:		call	ClearScreen
		print
		byte	"Current Functions:",cr,lf,lf,0

		les	di, TTHead	;Ptr to first function
		or	di, di		;See if NULL ptr
		je	NoMoreFuncs

		mov	cx, 1		;Counts the functions.
PFLoop:		push	es		;Save ptr to truth table
		push	di
		push	cx
		mov	ax, cx
		mov	cx, 2
		putisize
		print
		byte	") ",0
		les	di, es:[di].TTStruc.Equation
		puts
		putcr
		pop	cx
		pop	di
		pop	es

; Move on to next equation:

		inc	cx
		les	di, es:[di].TTStruc.Next
		or	di, di
		jne	PFLoop

NoMoreFuncs:    print
		byte	cr,lf
		byte	"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
		byte	cr,lf,lf,0

ExpLoop:	print
		byte	"Enter new function (blank line quits):",cr,lf,0

		lesi	InputLn
		gets
		strupr
		strlen
		cmp	cx, 0		;End of functions?
		je	NoMoreExp


; Check to see if the equation is syntactically correct:


		ldxi	Function
		mov	cx, 0
		mov	BadFuncName, cx		;Init so we can test it.
		match
		jc	GoodExpSoFar

		cmp	BadFuncName, 0		;See if illegal func name.
		jne	BFN

		print
		byte	"There was a syntax error in the expression, "
		byte	"please reenter",cr,lf,0
		jmp	ExpLoop

BFN:		print
		byte	"Illegal function name (A, B, C, or D, or you've "
		byte	"reused a name).",cr,lf
		byte	"Please reenter function.",cr,lf,0
		jmp	ExpLoop


; This program allows a maximum of four terms plus a clock per expression.
; Verify that they have not exceeded this number.

GoodExpSoFar:   cmp	TermCnt, 5
		jb	GoodExp2
		jg	BadExp
		mov	al, "#"
		lesi    TermSet
		Member
		jne	GoodExp2

BadExp:		print
		byte	"Expression contains too many variables (limit 4). "
		byte	"Please reenter"
		byte	cr,lf
		byte	0
		jmp	ExpLoop


; Make sure there is at least one variable in the expression.

GoodExp2:	cmp	TermCnt, 0	;Be sure there are *some* vars.
		jne	GoodExp3
		print
		byte	"Expression must contain some variables. "
		byte	"Please reenter.",cr,lf
		byte	0
		jmp	ExpLoop

GoodExp3:

; Well, we have a syntactically correct function definition, now let's
; generate the truth table for it:




SetVar		macro	var
		local	IsVar, PutVC, MaskVC


		lesi	TermSet
		RmvItem
		cmp	al, 0		;No more variables?
		jne	IsVar
		mov	ax, Dummy	;If no more, assign a slot that
		inc	Dummy		; we will never use.

; Save away the the character for this variable.

IsVar:		cmp	al, ' '
		jae	PutVC
		mov	TruthTable.VarChars[var], '*'
		jmp	MaskVC

PutVC:		mov	TruthTable.VarChars[var], al

; Convert the character into an index into the Variables array and
; save that away:

MaskVC:
		and	ax, 1Fh
		mov	TruthTable.Vars[var*2], ax
		add	bx, 2

		endm







		mov	Dummy, 27
		mov     TruthTable.HasClk, 0
		lesi	TermSet
		mov	al, '#'
		member
		je	NoClock
		RmvChar				;Remove "#" from set.
		mov	TruthTable.HasClk, 1


NoClock:

		SetVar	0
		SetVar	1
		SetVar	2
		SetVar	3


; To generate the truth table, use use the following loops:
;
;	For [ClkVar] = 0 to 1 do
;	  for [var4] = 0 to 1 do
;	    for [var3] = 0 to 1 do
;	      for [var2] = 0 to 1 do
;		for [Var1] = 0 to 1 do
;		  TT[Clk,v4,v3,v2,v1] = evaluation of function.


		mov	TTIndex, 0

		mov	Variables, 0		;Set clock value to zero.
ClkLoop:	cmp	Variables, 2
		jae	TTDone

		mov	bx, TruthTable.Vars[3*2]
		mov	Variables[bx], 0

v4Loop:		mov	bx, TruthTable.Vars[3*2]
		cmp	Variables[bx], 2
		jae	v4Done

		mov	bx, TruthTable.Vars[2*2]
		mov	Variables[bx], 0

v3Loop:		mov	bx, TruthTable.Vars[2*2]
		cmp	Variables[bx], 2
		jae	v3Done


		mov	bx, TruthTable.Vars[1*2]
		mov	Variables[bx], 0

v2Loop:		mov	bx, TruthTable.Vars[1*2]
		cmp	Variables[bx], 2
		jae	v2Done


		mov	bx, TruthTable.Vars[0*2]
		mov	Variables[bx], 0
v1Loop:		cmp	Variables[bx], 2
		jae	v1Done


		mov	EVsp, 0
		ldxi	eFunction
		lesi	InputLn
		mov	cx, 0
		match

		call	POPes
		mov	si, TTIndex
		mov	TruthTable.TT[si], al
		mov	al, FunctionName
		mov	TruthTable.FuncName, al

		inc	TTIndex

		mov	bx, TruthTable.Vars[0*2]
		inc	Variables[bx]
		jmp	V1Loop





v1Done:		mov	bx, TruthTable.Vars[1*2]
		inc	Variables[bx]
		jmp	V2Loop

v2Done:		mov	bx, TruthTable.Vars[2*2]
		inc	Variables[bx]
		jmp	V3Loop

v3Done:		mov	bx, TruthTable.Vars[3*2]
		inc	Variables[bx]
		jmp	V4Loop

v4Done:		inc	Variables
		jmp	ClkLoop


; Okay, we've built the truth table, now let's get the user's okay on it.

TTDone:		print
		byte	cr,lf
		byte	"Do you wish to see a truth table for this function? "
		byte	"(Y/N): ",0

		getc
		toupper
		cmp	al, 'N'
		je	StoreTT
		cmp	al, 'Y'
		jne	TTDone

		lesi	TruthTable
		call	PrintTT

		print
		byte	cr,lf
		byte	"Press any key to continue:",0
		getc
		putcr

; Okay, store away the truth table in memory:

StoreTT:	mov	cx, sizeof TTStruc
		malloc
		cmp	word ptr TTHead+2, 0
		jne	GotOneAlready
		mov	word ptr TTHead, di
		mov	word ptr TTHead+2, es

; Link allocated storage into the TT list:

GotOneAlready:  mov	ax, 0
		mov	word ptr es:[di].TTStruc.Next, ax
		mov	word ptr es:[di].TTStruc.Next+2, ax
		mov	ax, es
		mov	bx, di
		les	di, TTTail
		mov	word ptr es:[di].TTStruc.Next, bx
		mov	word ptr es:[di].TTStruc.Next+2, ax
		mov	word ptr TTTail, bx
		mov	word ptr TTTail+2, ax


		mov	cx, sizeof TTStruc
		lea	si, TruthTable
		les	di, TTTail
	rep	movsb


; Set up ptr to equation string.

		lesi	InputLn			;Make a copy of the logic
		strdup				; function's string.
		mov	bx, es
		mov	cx, di

		les	di, TTTail		;Retrive ptr to TT structure.
		mov	word ptr es:[di].TTStruc.Equation, cx
		mov	word ptr es:[di].TTStruc.Equation+2, bx

; Remove this function name from consideration:

		lesi	FuncNames
		mov	al, FunctionName
		RmvChar
		jmp	GFLoop


NoMoreExp:	cmp	word ptr TTHead+2, 0	;Is there at least one
		jne	HaveSome		; logic function here?

		PrtXY
		byte	22,2
		byte	bell
		byte	"You must enter at least one logic function!",cr
		byte	"Press any key to continue.",0
		getc
		jmp     GFLoop

HaveSome:
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
GetFuncs	endp






;************************************************************************
;*									*
;* EvalFuncs-	Evaluates the user specified logical functions.		*
;*		This routine repeatedly evaluates the functions 32	*
;*		times to give the data time to propogate through the	*
;*		system (32 times will do it since there are only 26	*
;*		variables plus a clock).				*
;*									*
;************************************************************************



EvalFuncs	proc
		push	es
		push	ax
		push	bx
		push	cx
		push	si
		push    di


; We need to evaluate the functions 32 times in order to propogate any
; changes throughout the circuitry.

		mov	cx, 32				;Repeat 32 times.
PropogateLp:	les	di, TTHead
ForEachFunc:	mov	al, Variables			;Get clock value.
		shl	al, 1

		mov	bx, es:[di].TTStruc.Vars[6]	;Get "D" value.
		or	al, Variables[bx]		;Merge into result.
		shl	al, 1

		mov	bx, es:[di].TTStruc.Vars[4]	;Get "C" value.
		or	al, Variables[bx]		;Merge into result.
		shl	al, 1

		mov	bx, es:[di].TTStruc.Vars[2]	;Get "B" value.
		or	al, Variables[bx]		;Merge into result.
		shl	al, 1

		mov	bx, es:[di].TTStruc.Vars[0]	;Get "A" value.
		or	al, Variables[bx]		;Merge into result.

		mov	ah, 0
		mov	bx, ax

		mov	al, es:[di].TTStruc.TT[bx]	;Fetch truth tbl value.
		mov	bl, es:[di].TTStruc.FuncName	;Fetch function name.
		sub	bl, '@'				;Convert to index.
		mov	TempVars[bx], al		;Store function result.

		cmp	word ptr es:[di].TTStruc.Next+2, 0
		je	FuncsDone
		les	di, es:[di].TTStruc.Next
		jmp	ForEachFunc



; We've evaluated all the functions, now it is time to copy the function
; results back to the real data array:

FuncsDone:	push	cx

		cld
		lea	si, TempVars
		lea	di, Variables
		mov	cx, ds
		mov	es, cx
		mov	cx, 32
	rep	movsb

		pop	cx
		loop	PropogateLp

		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
EvalFuncs	endp


;************************************************************************
;*									*
;* PrtLED-	AL contains zero or one corresponding to an LED value	*
;*		(logic functions W, X, Y, and Z).  Print a "( )" if	*
;*		AL is zero, print a "(*)" if AL is non-zero.		*
;*									*
;************************************************************************

PrtLED		proc
		cmp	al, 0
		je	LEDOff
		print
		byte	"(*) ",0
		ret

LEDOff:		print
		byte	"( ) ",0
		ret
PrtLED		endp


;************************************************************************
;*									*
;* PutVars-	Writes the current values for each of the variables to	*
;*		the display.						*
;*									*
;************************************************************************

PutVars		proc
		push	ax
		push	bx
		push	cx
		push	dx

		mov	cx, 0847h		;Draw a box across the
		mov	dx, 0103h		; screen
		DrawBox


; Since the user cannot initialize A, B, C, and D, gray out these letters.


		mov	ah, 1fh
		cmp	Variables[0], 0
		je	GotClkAttr
		mov	ah, 5fh
GotClkAttr:	mov	al, '#'
		mov	dx, 020dh
		DispChar
		mov	dx, 020fh
		mov	bx, 1			;Start with "A".
		mov	al, 'A'
DispVars:	mov	ah, 1fh			;Assume value = 0.
		cmp	Variables[bx], 0        ;Is this zero or one?
		je	GotAttr
		mov	ah, 5fh			;Nope, it's a one.
GotAttr:	DispChar
		inc	al			;Move on to next char.
		inc	bx			;Next item in variables.
		add	dx, 2			;Move on to next position.
		cmp	al, 'Z'
		jbe	DispVars		;Repeat for all variables.

; Provide a special "seven segment output" on the display screen using
; variables e, f, g, h, i, j, and k.  The segments are laid out as follows:
;
;		 E
;		___
;	       |   |
;            F |   | G
;	       | H |
;		___
;	       |   |
;	     I |   | J
;	       | K |
;		___

		PrtXY
		byte	4, 40
		byte	"Seven Segment Display Simulation:",0

		cmp	Variables['E'-'@'], 0
		je	EBlank
		PrtXY
		byte	5, 54
		byte	"---",0
		jmp	DoF

EBlank:		PrtXY
		byte	5, 54
		byte	"   ",0

DoF:		cmp	Variables["F"-"@"], 0
		je	FBlank
		PrtXY
		byte	6, 53
		byte	"|",cr,"|",0
		jmp	DoG

FBlank:		PrtXY
		byte	6, 53
		byte	" ",cr," ",0

DoG:		cmp	Variables["G"-"@"], 0
		je	GBlank
		PrtXY
		byte	6, 57
		byte	"|",cr,"|",0
		jmp	DoH

GBlank:		PrtXY
		byte	6, 57
		byte	" ",cr," ",0


DoH:		cmp	Variables['H'-'@'], 0
		je	HBlank
		PrtXY
		byte	8, 54
		byte	"---",0
		jmp	DoI

HBlank:		PrtXY
		byte	8, 54
		byte	"   ",0


DoI:		cmp	Variables["I"-"@"], 0
		je	IBlank
		PrtXY
		byte	9, 53
		byte	"|",cr,"|",0
		jmp	DoJ

IBlank:		PrtXY
		byte	9, 53
		byte	" ",cr," ",0

DoJ:		cmp	Variables["J"-"@"], 0
		je	JBlank
		PrtXY
		byte	9, 57
		byte	"|",cr,"|",0
		jmp	DoK

JBlank:		PrtXY
		byte	9, 57
		byte	" ",cr," ",0


DoK:		cmp	Variables['K'-'@'], 0
		je	KBlank
		PrtXY
		byte	11, 54
		byte	"---",0
		jmp	Done7

KBlank:		PrtXY
		byte	11, 54
		byte	"   ",0

Done7:

; Okay, now simulate the four LEDs on the student-built circuit.

		PrtXY
		byte	4,4
		byte	"LED Simulation:",0

		mov	dx, 0504h
		GotoXY
		mov	al, Variables['W'-'@']
		call	PrtLED
		mov	al, Variables['X'-'@']
		call	PrtLED
		mov	al, Variables['Y'-'@']
		call	PrtLED
		mov	al, Variables['Z'-'@']
		call	PrtLED

; Output the LED values to the LEDs:

		mov	al, Variables['D'-'@']
		shl	al, 1
		or	al, Variables['C'-'@']
		shl	al, 1
		or	al, Variables['B'-'@']
		shl	al, 1
		or	al, Variables['A'-'@']
		shl	al, 1

		or	al, Variables['W'-'@']
		shl	al, 1
		or	al, Variables['X'-'@']
		shl	al, 1
		or	al, Variables['Y'-'@']
		shl	al, 1
		or	al, Variables['Z'-'@']

		mov	dx, OutPort
		out	dx, al


		mov	dx, 1900h		;Position cursor off screen.
		GotoXY

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
PutVars		endp





;************************************************************************
;*									*
;* ReadInputs-	Reads the A, B, C, and D inputs from either the switches*
;*		or the PC's keyboard depending on the setting of the	*
;*		mode variable ('H'=hardware, "S" = PC Keyboard.		*
;*									*
;************************************************************************


ReadInputs	proc
		cmp	Mode, 'H'
		jne	SoftOnly

; If we're in the hardware mode, read the switch values from the
; parallel port:

DoHdwr:         push	dx
		mov	dx, InPort
		in	al, dx
		pop	dx
		shr	al, 1		;Put sw0 value in bit #0
		shr	al, 1
		shr	al, 1
		xor	al, 0Fh		;Invert the switch values.

		mov	Variables[1], 0	;Copy bit Sw0 value to Variables[0].
		shr	al, 1
		rcl	Variables[1], 1

		mov	Variables[2], 0	;Copy next bit to Variables[1].
		shr	al, 1
		rcl	Variables[2], 1

		mov	Variables[3], 0	;Copy next bit to Variables[2].
		shr	al, 1
		rcl	Variables[3], 1

		mov	Variables[4], 0	;Copy next bit to Variables[3].
		shr	al, 1
		rcl	Variables[4], 1

		mov	al, Variables[1]
		mov	TempVars[1], al
		mov	al, Variables[2]
		mov	TempVars[2], al
		mov	al, Variables[3]
		mov	TempVars[3], al
		mov	al, Variables[4]
		mov	TempVars[4], al




SoftOnly:	mov	ah, 1			;See if a key is available
		int	16h			; in the keyboard buffer.
		je	ReadInputs

		toupper
		cmp	al, 'A'
		jne	RIB
		xor	Variables[1], 1
		xor	TempVars[1], 1
		jmp	RdIt

RIB:		cmp	al, 'B'
		jne	RIC
		xor	Variables[2], 1
		xor	TempVars[2], 1
		jmp	RdIt

RIC:		cmp	al, 'C'
		jne	RID
		xor	Variables[3], 1
		xor	TempVars[3], 1
		jmp	RdIt

RID:		cmp	al, 'D'
		jne	RIClk
		xor	Variables[4], 1
		xor	TempVars[4], 1

RdIt:		mov	ah, 0
		int	16h			;Flush character from buffer.
		call	PutVars			;Redraw output values.
		jmp	ReadInputs		;Read any other chars.


RIClk:		cmp	al, cr
		jne	TryESC
		xor	Variables[0], 1		;Toggle the clock.
		xor	TempVars[0], 1
		mov	ah, 0
		int	16h
		call	PutVars
		mov	ax, 2
		ret


TryESC:		cmp	al, aESC
		jne	RdIt
		jmp	RIQuit






RIDone:		mov	ax, 1
		ret

RIQuit:		mov	ax, 0
		ret
ReadInputs	endp





;************************************************************************
;*									*
;* PrintEqns- Prints as many equations as will fit between lines 13 and	*
;*	      22 on the display.					*
;*									*
;************************************************************************

PrintEqns	proc
		push	es
		push	di
		push	ax
		push	bx
		push	cx
		push	dx

		PrtXY
		byte	9,0
		byte	"Functions:",cr
		byte	"----------",cr,cr,0

		les	di, TTHead
EachFn:		push	es
		push	di
		les	di, es:[di].TTStruc.Equation
		puts
		putcr
		pop	di
		pop	es

		mov	ah, 3		;Call BIOS to get the current
		mov	bh, DispPage	; cursor position.
		int	10h
		cmp	dh, 21		;Line 21 could flow into line 22.
		jae	EqnsDone

		cmp	word ptr es:[di].TTStruc.Next+2, 0
		je	EqnsDone
		les	di, es:[di].TTStruc.Next
		jmp	EachFn

EqnsDone:	pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	di
		pop	es
		ret
PrintEqns	endp





;************************************************************************
;*									*
;* Emulate-	Emulates the circuit the user has just entered.		*
;*		There are two modes of operation: H/W and S/W.  In the	*
;*		hardware mode of operation, this program reads the in-	*
;*		puts from the switches connected to the parallel port	*
;*		and it writes the outputs to the LEDs connected to the	*
;*		parallel port.  In the SW mode of operation, this pgm	*
;*		simulates the switches using keyboard keypresses and	*
;*		simulates LED output using the video display.		*
;*									*
;************************************************************************


Emulate		proc
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	di

		call	ClearScreen

		PrtXY
		byte	2,20
		byte	"Logic Simulation",0

		mov	cx, 1028h		;Draw a box across the
		mov	dx, 0103h		; screen
		DrawBox

AskAgain:	PrtXY
		byte	5,5
		byte	"Do you want to use the experimental hardware or "
		byte	"simulate it? (H/S): ",0
		getc
		toupper
		cmp	al, 'H'
		je	DoIt
		cmp	al, 'S'
		je	DoIt
		mov	al, Bell
		putc
		jmp	AskAgain

DoIt:		mov	Mode, al


; Print stuff on the screen that sticks around for a while:

		call	ClearScreen
		call	PrintEqns
		PrtXY
		byte	22, 2
		byte	"Pressing ENTER toggles the clock signal.",cr
		byte	"Pressing ESC terminates simulation.",cr,0

LogicLoop:	call	EvalFuncs
		call	PutVars
		call	ReadInputs

		PrtXY
		byte	2,1
		byte	"ÄÄÄ",0

; ReadInputs returns 0 if the user presses ESC, 2 if the user presses
; ENTER (to toggle the clock), and one if the user presses anything else.

		cmp	ax, 1
		jb	QuitSim
		je	LogicLoop

; If the user pressed enter, simulate a clock pulse.
; Animate a little clock pulse on the screen, set the clock from zero to
; one, evaluate the functions, and then set the clock back to zero.

		mov	Variables, 0
		mov	Tempvars, 0
		call	EvalFuncs
		call	PutVars

		PrtXY
		byte	1,3
		byte	"Ú",cr
		byte	"Ù",0

		mov	Variables, 1
		mov	TempVars, 1
		call	EvalFuncs
		call	PutVars
		call	Delay

		PrtXY
		byte	1,2
		byte	"Ú¿",cr
		byte	"ÙÀ",0

		call	Delay

		PrtXY
		byte	1,1
		byte	"Ú¿ ",cr
		byte	"ÙÀÄ",0

		call	Delay

		PrtXY
		byte	1,1
		byte	"¿ ",cr
		byte	"ÀÄ",0

		call	Delay

		PrtXY
		byte	1,1
		byte	"  ",cr
		byte	"ÄÄ",0


		mov	Variables, 0
		mov	TempVars, 0
		jmp	LogicLoop


QuitSim:
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
Emulate		endp







;************************************************************************
;*									*
;* DelayInit-	Computes the system-dependent timing constant for a	*
;*		short delay value.					*
;*									*
;************************************************************************

DelayInit	proc
		push	es
		push	ax
		push	bx
		push	cx
		push	dx

		mov	dx, 378h	;LPT1: port, just for wait states
		mov	ax, 40h		;Address of BIOS variables.
		mov	es, ax

; Wait until the BIOS timer variable changes.  Once this happens, count
; the number of loop iterations until it changes again.  The value in CX
; gives the number of loops to execute for approx 1/18th second delay.

		mov	bx, es:[6ch]
Wait4Change:	mov	ax, es:[6ch]
		cmp	bx, ax
		je	Wait4Change

		mov	bx, ax
		mov	cx, 0		;Allow up to 65,536 iterations.
		align	4
DelayLp:	in	al, dx		;Just wastes a lot of time.
		in	al, dx
		in	al, dx
		in	al, dx

		mov	ax, es:[6ch]	;L.O. word of timer value.
		cmp	ax, bx
		loope	DelayLp
		neg	cx		;Convert to a positive # we can use.
		mov	Dly18Cnst,cx	;Save for later use.

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
DelayInit	endp





;************************************************************************
;*									*
;* Delay-	Delays for about 1/4 second.				*
;*									*
;************************************************************************


Delay		proc
		call	Delay18
		call	Delay18
		call	Delay18
Delay		endp			;Falls through to Delay18!

Delay18		proc
		push	es
		push	ax
		push	bx
		push	cx
		push	dx

		mov	dx, 378h	;LPT1: port, just for wait states
		mov	ax, 40h		;Address of BIOS variables.
		mov	es, ax

; Wait until the BIOS timer variable changes.  Then we can start
; the actual delay operation.

		mov	bx, es:[6ch]
Wait4Change:	mov	ax, es:[6ch]
		cmp	bx, ax
		je	Wait4Change

		mov	cx, Dly18Cnst	;The number of times we have to
		align	4
DelayLp:	in	al, dx		; repeat this loop.
		in	al, dx
		in	al, dx
		in	al, dx

		mov	ax, es:[6ch]	;This is a dummy fetch and compare
		cmp	ax, ax		; so the timing will remain constant.
		loope	DelayLp

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		ret
Delay18		endp









;************************************************************************
;*									*
;* Main-	Does some initialization, prints the sign-on message,	*
;*		and calls the other routines that do the work.		*
;*									*
;************************************************************************





Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; Process the command line parameters to see if the user has specified
; some port other than LPT1:

		mov	bx, 1		;Assume LPT1
		argc			;Get the number of parameters.
		cmp	cx, 1		;We allow zero or one parameters
		jb	LPT1		; to this command.
		ja	Usage		;Error if more than one.

		mov	ax, cx		;Fetch the only parameter (1).
		argv
		strupr
		strcmpl
		byte	"LPT1",0
		je	LPT1
		strcmpl
		byte	"LPT1:",0
		je	LPT1

		strcmpl
		byte	"LPT2",0
		je	LPT2
		strcmpl
		byte	"LPT2:",0
		je	LPT2

		strcmpl
		byte	"LPT3",0
		je	LPT3
		strcmpl
		byte	"LPT3:",0
		je	LPT3

Usage:		print
		byte	bell, "Usage: LOGICEX lpt1:",cr,lf
		byte	      "       LOGICEX lpt2:",cr,lf
		byte	      "    or LOGICEX lpt3:",cr,lf
		byte	0
		jmp	Quit

LPT3:		inc	bx
LPT2:		inc	bx
LPT1:		free			;We're done with parameter string.
		mov	ax, 40h		;Point at BIOS variables
		mov	es, ax
		shl	bx, 1		;Index into word array.
		mov	ax, es:[bx+6]	;Fetch parallel port address.
		test	ax, ax		;If zero, no printer card installed
		jne	GotPort
		print
		byte	"There does not seem to be a parallel port adapter "
		byte	"card installed for",cr,lf
		byte	"the print port you've specified.  Please check your"
		byte	"hardware and try again.",cr,lf,0
		jmp	Quit

GotPort:      	mov	OutPort, ax	;Save away output port address.
		inc	ax		;Compute input port address.
		mov	InPort, ax	;Save away input port address.
		inc	ax		;Point at control port and initialize
		mov	dx, ax		; it to zero to supply power to our
		mov	al, 0		; circuit.
		out	dx, al


; Initialize some character sets we will use:

		lesi    ExpIDs		;Variable names allowed in an
		ldxi	Upper		; expression.
		CopySet
		AddStrl
		byte	"01#",0		;Allow constants and clocks.

		lesi    FuncNames	;Variable names allowed as function
		ldxi	ExpIDs		; names
		CopySet
		RmvStrl			;Disallow switch inputs and clocks
		byte	"ABCD#",0	; as function names.


; Initialize the delay counter:

		call	DelayInit




; Determine if this is a mono or color system.  Set up the display
; appropriately.

		mov	ah, 0Fh		;Get display mode opcode.
		int	10h

		mov	DispPage, bh	;Save away display page.
		mov	ScreenMode, al	;Save screen mode.
		cmp	al, 7		;Monochrome mode?
		je	MonoDisplay

		mov	Attribute, 1Fh	;Blue/white screen.
		mov	Dim, 17h	;Dimmed character attribute.
		mov	Inverse, 5fh	;Inverse character attribute.
		mov	ScrnBase, 0B800h
		jmp	DoCS

MonoDisplay:	mov	ScrnBase, 0B000h
		mov	Attribute, 0Fh	;White letters on black screen.
		mov	Dim, 07h     	;Dimmed character attribute.
		mov	Inverse, 70h	;Black letters on a white screen.

DoCS:


; Print sign-on screen and tell the user about this program:

		call	ClearScreen

		PrtXY
		byte	1, 16h
		byte	"Boolean Function Evaluation Program",cr
		byte	"(c) Copyright 1995 by Randall Hyde",0

		mov	cx, 0e3Eh		;Draw a box across the
		mov	dx, 0003h		; screen
		DrawBox

		PrtXY
		byte	5,16
		byte	"This program lets you enter several boolean",cr
		byte	"equations.  It will then evaluate those",cr
		byte	"equations and display the results.  This",cr
		byte	"program assumes that you have assembled and",cr
		byte	"installed the hardware module associated ",cr
		byte	"with Lab Two (from the Art of Assembly Language",cr
		byte	"Programming) prior to running this program.",cr
		byte	"If you have not done so, you should quit",cr
		byte	"this program and do so now.",cr,cr
		byte	"You can quit this program at any time by",cr
		byte	"pressing control-C or by hitting ctrl-Break.",cr,cr
		byte	"Press any key to continue:"
		byte	0

		getc




; Okay, read the logic functions from the user:

		call	GetFuncs


; Let them specify the initial values for the variables.  Note that A..D
; inputs come from the switches, so if the user attempts to initialize
; these guys, the attempt will be unsuccessful.

		mov	cx, ds		;Begin by zeroing out the
		mov	es, cx		; Variables array.
		lea	di, Variables
		mov	cx, 32
		mov	al, 0
		cld
	rep	stosb

		call	GetInit		;Get initial Variables values.





; Copy the Variables array to the TempVars array:


		lea	si, Variables
		lea	di, TempVars
		mov	cx, ds
		mov	es, cx
		mov	cx, 32
		cld
	rep	movsb


; Begin the logic emulation:

		call	Emulate



Quit:		call	ClearScreen
		mov	dx, OutPort		;Shut off the LEDs.
		mov	al, 0
		out	dx, al
		ExitPgm				;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
