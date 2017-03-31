		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list

dseg		segment	para public 'data'

; Variables used to hold the number of shares bought/sold, a pointer to
; a string containing the buy/sell command, and a pointer to a string
; containing the company name.

Count		word	0
CmdPtr		dword	?
CompPtr		dword	?


; Some test strings to try out:

Cmd1		byte	"Buy 25 shares of apple stock",0
Cmd2		byte	"Sell 50 shares of hp stock",0
Cmd3		byte	"Buy 123 shares of dec stock",0
Cmd4		byte	"Sell 15 shares of ibm stock",0
BadCmd0		byte	"This is not a buy/sell command",0


; Patterns for the stock buy/sell command:
;
; StkCmd matches buy or sell and creates a parenthetical pattern
; that contains the string "buy" or "sell".

StkCmd		pattern	{sl_match2, buyPat, 0, skipspcs1}

buyPat		pattern	{matchistr,buystr,sellpat}
buystr		byte	"BUY",0

sellpat		pattern	{matchistr,sellstr}
sellstr		byte	"SELL",0

; Skip zero or more white space characters after the buy command.

skipspcs1	pattern	{spancset, whitespace, 0, CountPat}

; CountPat is a parenthetical pattern that matches one or more
; digits.

CountPat	pattern	{sl_match2, Numbers, 0, skipspcs2}
Numbers		pattern	{anycset, digits, 0, RestOfNum}
RestOfNum	pattern	{spancset, digits}

; The following patterns match " shares of " allowing any amount
; of white space between the words.

skipspcs2	pattern	{spancset, whitespace, 0, sharesPat}

sharesPat	pattern	{matchistr, sharesStr, 0, skipspcs3}
sharesStr	byte	"SHARES",0

skipspcs3	pattern	{spancset, whitespace, 0, ofPat}

ofPat		pattern	{matchistr, ofStr, 0, skipspcs4}
ofStr		byte	"OF",0

skipspcs4	pattern	{spancset, whitespace, 0, CompanyPat}



; The following parenthetical pattern matches a company name.
; The patgrab-available string will contain the corporate name.

CompanyPat	pattern	{sl_match2, ibmpat}

ibmpat		pattern	{matchistr, ibm, applePat}
ibm		byte	"IBM",0

applePat	pattern	{matchistr, apple, hpPat}
apple		byte	"APPLE",0

hpPat		pattern	{matchistr, hp, decPat}
hp		byte	"HP",0

decPat		pattern	{matchistr, decstr}
decstr		byte	"DEC",0


		include	stdsets.a
dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; DoBuySell-	This routine processes a stock buy/sell command.
;		After matching the command, it grabs the components
;		of the command and outputs them as appropriate.
;		This routine demonstrates how to use patgrab to
;		extract substrings from a pattern string.
;
;		On entry, es:di must point at the buy/sell command
;		you want to process.

DoBuySell	proc	near
		ldxi    StkCmd
		xor	cx, cx
		match
		jnc	NoMatch

		lesi	StkCmd
		patgrab
		mov	word ptr CmdPtr, di
		mov	word ptr CmdPtr+2, es

		lesi	CountPat
		patgrab
		atoi			;Convert digits to integer
		mov	Count, ax
		free			;Return storage to heap.

		lesi	CompanyPat
		patgrab
		mov	word ptr CompPtr, di
		mov	word ptr CompPtr+2, es

		printf
		byte	"Stock command: %^s\n"
		byte	"Number of shares: %d\n"
		byte	"Company to trade: %^s\n\n",0
		dword	CmdPtr, Count, CompPtr

		les	di, CmdPtr
		free
		les	di, CompPtr
		free
		ret

NoMatch:	print
		byte	"Illegal buy/sell command",cr,lf,0
		ret
DoBuySell	endp

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		meminit

		lesi	Cmd1
		call	DoBuySell
		lesi	Cmd2
		call	DoBuySell
		lesi	Cmd3
		call	DoBuySell
		lesi	Cmd4
		call	DoBuySell
		lesi	BadCmd0
		call	DoBuySell

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
