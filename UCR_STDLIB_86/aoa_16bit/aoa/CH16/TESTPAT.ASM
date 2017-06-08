		include		stdlib.a
		includelib 	stdlib.lib
		matchfuncs

; PATTERNS test code.

dseg		segment	para public 'data'
MemAvail	dw	?

Pat1		pattern	<MatchStr,MyStr,0,Pat1_5>
MyStr		db	"Hello There",0

Pat1_5		pattern	<Spancset,Mycset,0,Pat2>

Pat2		pattern	<MatchStr,MyStr2,AltPat,Pat3>
MyStr2		db	"You?",0

AltPat		pattern	<MatchStr,MyStr3,0,Pat3>
MyStr3		db	"you?",0

Pat3		pattern	<EOS>


Str2Test	db	"Hello There, how are you?"
Lastbyte2tst	db	0


; The following pattern matches "apap" or "apapap".  I use this pattern
; to test backtracking in the matching algorithm.

APAPAP		pattern	<MatchStr,APAPstr,APAP,AP2>
APAP		pattern	<MatchStr,APstr,0,AP2>
AP2		pattern	<MatchStr,APstr>

APAPstr		db	"ap"
APstr		db	"ap",0


; Some patterns to check the code in the documentation.
; HAA (has an alphabetic) checks for patterns containing at least one alphabetic
; char followed by some digits.  Alphax and Digitsx are required by the
; corresponding MatchAlpha and MatchDigits routines.

HAA		pattern	<ARB,0,0,HAA2>
HAA2		pattern	<MatchAlpha,0,0,HAA3>
HAA3		pattern	<MatchDigits>

Alpha1		pattern	<Anycset,alpha,0,Alpha2>
Alpha2		pattern	<Spancset,alpha>

Digits1		pattern	<Anycset,digits,0,Digits2>
Digits2		pattern	<Spancset,digits>


HaaStr1		db	"ThisStringMatchesOK1234",0
HaaStr2		db	"This String should match2",0



HAAagain	pattern	<ARB,0,0,Alpha1ormore>

Alpha1ormore	pattern	<OneOrMore,alphaset,0,Digits1ormore>
AlphaSet	pattern	<Anycset,alpha>

Digits1ormore	pattern	<OneOrMore, DigitSet>
DigitSet	pattern	<Anycset, digits>


HAAadp		pattern	<arb,0,0,AlphaDigitsPat>
AlphaDigitsPat	pattern	<AlphaDigits>

ParenPat	pattern	<ARB,0,0,HAAparen>
HAAparen	pattern	<sl_match2,HAA2>	;Sneaky use of match2!

; Some patterns to check the built-in pattern matching functions:

; Check the spancset matching function:

SCtest		pattern	<Spancset, alphanum>
SCtestStr	db	"Hello there, how are you?",0

; Check the brkcset matching fuction:

BCtest		pattern	<Brkcset, delimiters>

; Check the MatchStr matching function:

MStest		pattern	<MatchStr, MSstr>
MSstr		db	"Hello there,",0

; Quick check of the MatchToString pattern function

MTSTest		pattern	<MatchToStr,Str2Match>
Str2Match	db	"Hello there",0
MainString	db	"This is a test, Hello there, how are you?",0

; Check the MatchChar matching function:

MCtest		pattern	<MatchChar, 'H'>

; Check the anycset matching function:

ACtest		pattern	<Anycset, alpha>

; Check the NotAnycset matching function:

NACtest		pattern	<NotAnycset, digits>
NACstr		db	"abcd, #$ 345",0

; Check the EOS and ARB matching functions:

EOStest		pattern	<arb,0,0,EOStest2>
EOStest2	pattern	<EOS>

;Check the skip pattern matching function:

SKIPtest	pattern	<Skip, 6>

; Check the POS pattern matching function:

POStest		pattern	<ARB,0,0,POStest2>
POStest2	pattern	<POS,6>

; Check the RPOS pattern matching function:

RPOStest	pattern	<ARB,0,0,RPOStest2>
RPOStest2	pattern	<RPOS,6>

; Check the GOTOpos pattern matching function:

GOTOposTest	pattern	<GOTOpos,6>

; Check the RGOTOpos pattern matching function:

RGOTOposTest	pattern	<RGOTOpos, 6>

; Check the MatchToChar pattern matching function:

Match2ChTest	pattern	<MatchToChar, ' '>


; Check the MatchToPat pattern matching function:

Match2PTest	pattern	<MatchToPat, Match2PTest2>
Match2PTest2	pattern	<anycset, delimiters>


; Check the ARBNUM pattern matching function:

ArbNumTest	pattern	<MatchToStr, ArbStr, 0, ArbNumTest2>
ArbNumTest2	pattern	<ArbNum,ArbNumTest3>

ArbNumTest3	pattern	<anycset, delimiters>
ArbStr		db	"Hello there",0




; A character set variable for some specific tests.

		set	Mycset


; Bring in the standard character sets.

		include	stdsets.a
dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



; Variables that wind up being used by the standard library routines.
; The MemInit routine uses "PSP" and "zzzzzzseg" labels.  They must be
; present if you intend to use getenv, MemInit, malloc, and free.


		public	PSP
PSP		dw	?

cr		equ	13
lf		equ	10




; MatchAlpha and MatchDigits are procedures used to test the code appearing
; in the documentation.
;
; Note that ES:DI & CX are already set up for these routines by the
; Match procedure.

MatchAlpha	proc	far		;Must be a far proc!
		push	dx
		push	si		;Preserve modified registers.
		ldxi	Alpha1		;Get pointer to "Match one or more
		match2			; alpha" pattern and match it.
		pop	si
		pop	dx
		ret
MatchAlpha	endp

MatchDigits	proc	far		;Must be a far proc!
		push	dx
		push	si		;Preserve modified registers.
		ldxi	Digits1		;Get pointer to "Match one or more
		match2			; digits" pattern and match it.
		pop	si
		pop	dx
		ret
MatchDigits	endp




; OneOrMore- Matches one or more items appearing in its MatchParm field.
;
; Assume the "MatchParm" field contains a pointer to the pattern we
; want to repeat one or more times:

OneOrMore	proc	far
		push	dx
		push	di

		mov	dx, ds			;Point DX:SI at pattern.
		match2				;Make sure we get at least 1.
		jnc	Fails
MatchMore:      mov	di, ax			;Move on in string.
		match2
		jc	MatchMore
		pop	di
		pop	dx
		stc				;Return success
		ret

Fails:		pop	di
		pop	dx
		clc				;Return failure
		ret
OneOrMore	endp



; AlphaDigits-	Brute force way (though a little faster) to check for a
;		string which begins with one or more alpha followed by
;		one or more digits.

AlphaDigits	proc	far
		push	di

		mov	al, es:[di]
		and	al, 5fh			;Convert l.c. -> U.C.
		cmp	al, 'A'
		jb	Failure
		cmp	al, 'Z'
		ja	Failure
DoTheMore0:	inc	di
		mov	al, es:[di]
		and	al, 5fh
		cmp	al, 'A'
		jb	TryDigits
		cmp	al, 'Z'
		jbe	DoTheMore0

TryDigits:	mov	al, es:[di]
		xor	al, '0'			;See if in range '0'..'9'
		cmp	al, 10
		jae	Failure
DoTheMore1:	inc	di
		mov	al, es:[di]
		xor	al, '0'
		cmp	al, 10
		jb	DoTheMore1
		mov	ax, di			;Return ending posn in AX.
		pop	di
		stc				;Success!
		ret

Failure:	mov	ax, di			;Return failure position.
		pop	di
		clc				;Return failure.
		ret
AlphaDigits	endp





; PutPat-	Outputs "^" symbols at the beginning and end+1 positions
;		of a matched pattern.  ES:DI points at the pattern upon
;		entry to this routine, DS:SI points at the beginning of the
;		string.

PutPat		proc	near
		push	si
		push	cx
		push	ax


		mov	cx, es:[di].Pattern.StartPattern
		sub	cx, si
		jcxz	Nospcs
PutPatLp:	mov	al, ' '
		putc
		loop	PutPatLp
Nospcs:         mov	cx, es:[di].Pattern.EndPattern
		sub	cx, es:[di].Pattern.StartPattern
		jne	PutCarot
		mov	al, '*'
		putc
		jmp	PutPatDone

PutCarot:	mov	al, '^'
PutPatLp2:	putc
		loop	PutPatLp2

PutPatDone:	putcr
		pop	ax
		pop	cx
		pop	si
		ret
PutPat		endp





Main		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
		mov	dx, 0			;Allocate all available RAM.
		MemInit
		mov	MemAvail, cx
		printf
		db	"There are %x paragraphs of memory available."
		db	cr,lf,lf,0
		dd	MemAvail

; Init Mycset to contain lowercase alphabetics, comma, and a space:

		lesi	Mycset
		mov	al, 'a'
		mov	ah, 'z'
		RangeSet
		AddStrl
		db	" ,",0

; Okay, see if we've got a match.  The pattern is described by the
; regular expression ["Hello There" (a-z space)* "you?"]

		printf
		db	'Testing the pattern ["Hello There" (a-z space)* "you?"]'
		db	cr,lf,lf
		db	"String to test: %s\n",0
		dd	Str2Test

		ldxi    Pat1
		lesi	Str2Test
		mov	cx, offset LastByte2tst
		Match
		jc	Matched
		print
		db	"Strings did not match",cr,lf,0
		jmp	Test1Done

Matched:	printf
		db	"The Strings did match\n"
		db	"Pat1:   %2d %2d\n"
		db	"Pat1_5: %2d %2d\n"
		db	"Pat2:   %2d %2d\n"
		db	"Alt:    %2d %2d\n"
		db	"EOS:    %2d %2d\n"
		db	cr,lf
		db	"        %s\n"
		db	0
		dd	Pat1.StartPattern, Pat1.EndPattern
		dd	Pat1_5.StartPattern, Pat1_5.EndPattern
		dd	Pat2.StartPattern, Pat2.EndPattern
		dd	AltPat.StartPattern, AltPat.EndPattern
		dd	Pat3.StartPattern, Pat3.EndPattern
		dd	Str2Test

		lea	si, Str2Test
		print
		db	"Pat1:   ",0
		lesi	Pat1
		call	PutPat

		print
		db	"Pat1_5: ",0
		lesi	Pat1_5
		call	PutPat

		print
		db	"Pat2:   ",0
		lesi	Pat2
		call	PutPat

		print
		db	"Alt:    ",0
		lesi	AltPat
		call	PutPat

		print
		db	"EOS:   ",0
		lesi	Pat3
		call	PutPat


Test1Done:

		printf
		db	cr,lf,lf
		db	'Testing the pattern ["APAP" | "AP"] "AP"',cr,lf
		db	"String to test: %s\n\n",0
		dd	APAPstr

		lesi	APAPstr
		ldxi	APAPAP
		mov	cx, 0
		match
		jc	MatchedAP
		print
		db	"Error: should have matched 'apap'",cr,lf,0
		jmp	Test2Done

MatchedAP:	printf
		db	"Properly matched 'apap'",cr,lf
		db	"APAPAP: %3d %3d",cr,lf
		db	"APAP:   %3d %3d",cr,lf
		db	"AP2:    %3d %3d",cr,lf
		db	cr,lf
		db	"        %s",cr,lf
		db	0
		dd	APAPAP.startpattern, APAPAP.endpattern
		dd	APAP.startpattern, APAP.endpattern
		dd	AP2.startpattern, AP2.endpattern
		dd      APAPStr

		lea	si, APAPStr
		print
		db	"APAPAP: ",0
		lesi	APAPAP
		call	PutPat
		print
		db	"APAP:   ",0
		lesi	APAP
		call	PutPat
		print
		db	"AP2:    ",0
		lesi	AP2
		call	PutPat

Test2Done:

; Now let's run some tests to verify the code in the documentation:

		print
		db	cr,lf,lf
		db	"Testing the pattern 'ARB [a-zA-Z]+ [0-9]+'"
		db	cr,lf,lf,0
		ldxi	HAA
		lesi	HaaStr1
		xor	cx, cx
		match
		jnc	HAADidntWork1
		print
		db	"HAA properly matched HaaStr1",cr,lf
		db	"Starting address:  ",0
		lea	ax, HaaStr1
		putw
		printf
		db	cr,lf
		db	"ARB component:     %4x %4x\n"
		db	"Alpha component:   %4x %4x\n"
		db	"Numeric component: %4x %4x\n\n"
		db	"      %s\n",0
		dd	Haa.StartPattern,  Haa.EndPattern
		dd	Haa2.StartPattern, Haa2.EndPattern
		dd	Haa3.StartPattern, Haa3.EndPattern
		dd	HaaStr1


		lea	si, HaaStr1
		print
		db	"HAA:  ",0
		lesi	HAA
		call	PutPat

		print
		db	"HAA2: ",0
		lesi	HAA2
		call	PutPat

		print
		db	"HAA3: ",0
		lesi	HAA3
		call	PutPat
		jmp	Test3Done

HAADidntWork1:	print
		db	"HAA failed to match HaaStr1",cr,lf,0

Test3Done:

		print
		db	cr,lf,lf
		db	"Testing the pattern 'ARB [a-zA-Z]+ [0-9]+'"
		db	cr,lf,lf,0
		ldxi	HAA
		lesi	HaaStr2
		xor	cx, cx
		match
		jnc	HAADidntWork2
		print
		db	"HAA properly matched HaaStr2",cr,lf
		db	"Starting address:  ",0
		lea	ax, HaaStr2
		putw
		printf
		db	cr,lf
		db	"ARB component:     %4x %4x\n"
		db	"Alpha component:   %4x %4x\n"
		db	"Numeric component: %4x %4x\n\n"
		db	"      %s\n",0
		dd	Haa.StartPattern,  Haa.EndPattern
		dd	Haa2.StartPattern, Haa2.EndPattern
		dd	Haa3.StartPattern, Haa3.EndPattern
		dd	HaaStr2


		lea	si, HaaStr2
		print
		db	"HAA:  ",0
		lesi	HAA
		call	PutPat

		print
		db	"HAA2: ",0
		lesi	HAA2
		call	PutPat

		print
		db	"HAA3: ",0
		lesi	HAA3
		call	PutPat
		jmp	Test4Done

HAADidntWork2:	print
		db	"HAA failed to match HaaStr2",cr,lf,0

Test4Done:

		print
		db	cr,lf,lf
		db	"Testing the pattern 'ARB [a-zA-Z]+ [0-9]+' "
		db	"using OneOrMore pattern"
		db	cr,lf,lf,0

		ldxi	HAAagain
		lesi	HaaStr1
		xor	cx, cx
		match
		jnc	HAADidntWork3
		print
		db	"HAAagain properly matched HaaStr1",cr,lf
		db	"Starting address:  ",0
		lea	ax, HaaStr1
		putw
		printf
		db	cr,lf
		db	"ARB component:     %4x %4x\n"
		db	"Alpha1 component:  %4x %4x\n"
		db	"Alpha2 component:  %4x %4x\n"
		db	"Digits1 component: %4x %4x\n"
		db	"Digits2 component: %4x %4x\n\n"
		db	"         %s\n",0
		dd	HAAagain.StartPattern,  HAAagain.EndPattern
		dd	Alpha1ormore.StartPattern, Alpha1ormore.EndPattern
		dd	Alphaset.StartPattern, Alphaset.EndPattern
		dd	Digits1ormore.StartPattern, Digits1ormore.EndPattern
		dd	DigitSet.StartPattern, DigitSet.EndPattern
		dd	HaaStr1


		lea	si, HaaStr1
		print
		db	"ARB:     ",0
		lesi	HAAagain
		call	PutPat

		print
		db	"Alpha1:  ",0
		lesi	Alpha1ormore
		call	PutPat

		print
		db	"Alpha2:  ",0
		lesi	AlphaSet
		call	PutPat

		print
		db	"Digits1: ",0
		lesi	Digits1ormore
		call	PutPat

		print
		db	"Digits2: ",0
		lesi	DigitSet
		call	PutPat

		jmp	Test5Done

HAADidntWork3:	print
		db	"HAAagain failed to match HaaStr1",cr,lf,0

Test5Done:


		print
		db	cr,lf,lf
		db	"Testing the pattern 'ARB [a-zA-Z]+ [0-9]+' "
		db	"using AlphaDigits pattern"
		db	cr,lf,lf,0

		ldxi	HAAadp
		lesi	HaaStr1
		xor	cx, cx
		match
		jnc	HAADidntWork4
		print
		db	"AlphaDigitsPat properly matched HaaStr1",cr,lf
		db	"Starting address:  ",0
		lea	ax, HaaStr1
		putw
		printf
		db	cr,lf
		db	"ARB component:          %4x %4x\n"
		db	"AlphaDigits component:  %4x %4x\n"
		db	"                 %s\n",0
		dd	HAAadp.StartPattern,  HAAadp.EndPattern
		dd	AlphaDigitsPat.StartPattern
		dd	AlphaDigitsPat.EndPattern
		dd	HaaStr1


		lea	si, HaaStr1
		print
		db	"ARB:             ",0
		lesi	HAAadp
		call	PutPat

		print
		db	"AlphaDigitsPat:  ",0
		lesi	AlphaDigitsPat
		call	PutPat

		jmp	Test6Done

HAADidntWork4:	print
		db	"HAAagain failed to match HaaStr1",cr,lf,0

Test6Done:


		print
		db	cr,lf,lf
		db	"Testing the pattern 'ARB [a-zA-Z]+ [0-9]+' "
		db	"using ParenPat pattern"
		db	cr,lf,lf,0


		ldxi	ParenPat
		lesi	HaaStr1
		xor	cx, cx
		match
		jnc	HAADidntWork5
		print
		db	"ParenPat properly matched HaaStr1",cr,lf
		db	"Starting address:  ",0
		lea	ax, HaaStr1
		putw
		printf
		db	cr,lf
		db	"ARB component:       %4x %4x\n"
		db	"ParenPat component:  %4x %4x\n"
		db	"HAA2 component:      %4x %4x\n"
		db	"HAA3 component:      %4x %4x\n"
		db	"           %s\n",0
		dd	ParenPat.StartPattern,  ParenPat.EndPattern
		dd	HAAparen.StartPattern,  HAAparen.EndPattern
		dd	HAA2.StartPattern, HAA2.EndPattern
		dd	HAA3.StartPattern, HAA3.EndPattern
		dd	HaaStr1


		lea	si, HaaStr1
		print
		db	"ARB:       ",0
		lesi	ParenPat
		call	PutPat

		print
		db	"ParenPat:  ",0
		lesi	HAAParen
		call	PutPat

		print
		db	"HAA2:      ",0
		lesi	HAA2
		call	PutPat

		print
		db	"HAA3:      ",0
		lesi	HAA3
		call	PutPat
		jmp	Test7Done

HAADidntWork5:	print
		db	"HAAagain failed to match HaaStr1",cr,lf,0

Test7Done:

		print
		db	cr,lf
		db	"Testing MatchToString:",cr,lf,lf,0

		ldxi	MTStest
		lesi	MainString
		xor	cx, cx
		Match
		jnc	MTSFailed
		printf
		db	"MatchToString worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"               %s",cr,lf,0
		dd	MTStest.StartPattern, MTStest.EndPattern
		dd	MainString

		lea	si, MainString
		print
		db	"MatchToString: ",0
		lesi	MTStest
		call	PutPat
		jmp	Test8Done

MTSFailed:	print
		db	"MatchToString did not work",cr,lf,0

Test8Done:

		print
		db	cr,lf
		db	"Testing Spancset:",cr,lf,lf,0

		ldxi	SCtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	SCFailed
		printf
		db	"Spancset worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"          %s",cr,lf,0
		dd	SCtest.StartPattern, SCtest.EndPattern
		dd      SCtestStr

		lea	si,  SCTestStr
		print
		db	"Spancset: ",0
		lesi	SCtest
		call	PutPat
		jmp	Test9Done

SCFailed:	print
		db	"Spancset did not work",cr,lf,0

Test9Done:

		print
		db	cr,lf
		db	"Testing Brkcset:",cr,lf,lf,0

		ldxi	BCtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	BCFailed
		printf
		db	"Brkcset worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"         %s",cr,lf,0
		dd	BCtest.StartPattern, BCtest.EndPattern
		dd      SCtestStr

		lea	si,  SCTestStr
		print
		db	"Brkcset: ",0
		lesi	BCtest
		call	PutPat
		jmp	Test10Done

BCFailed:	print
		db	"Brkcset did not work",cr,lf,0

Test10Done:

		print
		db	cr,lf
		db	"Testing MatchStr:",cr,lf,lf,0

		ldxi	MStest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	MSFailed
		printf
		db	"MatchString worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"          %s",cr,lf,0
		dd	MStest.StartPattern, MStest.EndPattern
		dd      SCtestStr

		lea	si,  SCTestStr
		print
		db	"MatchStr: ",0
		lesi	MStest
		call	PutPat
		jmp	Test11Done

MSFailed:	print
		db	"MatchStr did not work",cr,lf,0

Test11Done:


		print
		db	cr,lf
		db	"Testing MatchChar:",cr,lf,lf,0

		ldxi	MCtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	MCFailed
		printf
		db	"MatchChar worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"           %s",cr,lf,0
		dd	MCtest.StartPattern, MCtest.EndPattern
		dd      SCtestStr

		lea	si,  SCTestStr
		print
		db	"MatchChar: ",0
		lesi	MCtest
		call	PutPat
		jmp	Test12Done

MCFailed:	print
		db	"MatchChar did not work",cr,lf,0

Test12Done:


		print
		db	cr,lf
		db	"Testing Anycset:",cr,lf,lf,0

		ldxi	ACtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	ACFailed
		printf
		db	"Anycset worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"         %s",cr,lf,0
		dd	ACtest.StartPattern, ACtest.EndPattern
		dd      SCtestStr

		lea	si,  SCTestStr
		print
		db	"Anycset: ",0
		lesi	ACtest
		call	PutPat
		jmp	Test13Done

ACFailed:	print
		db	"Anycset did not work",cr,lf,0

Test13Done:

		print
		db	cr,lf
		db	"Testing NotAnycset:",cr,lf,lf,0

		ldxi	NACtest
		lesi	NACStr
		xor	cx, cx
		Match
		jnc	NACFailed
		printf
		db	"NotAnycset worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"               %s",cr,lf,0
		dd	NACtest.StartPattern, NACtest.EndPattern
		dd      NACStr

		lea	si,  NACStr
		print
		db	"NotAnycset:    ",0
		lesi	NACtest
		call	PutPat
		jmp	Test14Done

NACFailed:	print
		db	"NotAnycset did not work",cr,lf,0

Test14Done:



		print
		db	cr,lf
		db	"Testing ARB/EOS:",cr,lf,lf,0

		ldxi	EOStest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	EOSFailed
		printf
		db	"EOS/ARB worked",cr,lf
		db	"ARB range:    %4x %4x",cr,lf
		db	"EOS position: %4x %4x",cr,lf,lf
		db	"       %s",cr,lf,0
		dd	EOStest.StartPattern, EOStest.EndPattern
		dd	EOStest2.StartPattern, EOStest2.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"ARB:   ",0
		lesi	EOStest
		call	PutPat

		print
		db	"EOS:   ",0
		lesi	EOStest2
		call	PutPat
		jmp	Test15Done

EOSFailed:	print
		db	"EOS/ARB did not work",cr,lf,0

Test15Done:



		print
		db	cr,lf
		db	"Testing Skip:",cr,lf,lf,0

		ldxi	SKIPtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	SkipFailed
		printf
		db	"Skip worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"       %s",cr,lf,0
		dd	Skiptest.StartPattern, Skiptest.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"Skip:  ",0
		lesi	SkipTest
		call	PutPat
		jmp	Test16Done

SkipFailed:	print
		db	"Skip did not work",cr,lf,0

Test16Done:



		print
		db	cr,lf
		db	"Testing ARB/POS:",cr,lf,lf,0

		ldxi	POStest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	POSFailed
		printf
		db	"POS/ARB worked",cr,lf
		db	"ARB range:    %4x %4x",cr,lf
		db	"POS position: %4x %4x",cr,lf,lf
		db	"       %s",cr,lf,0
		dd	POStest.StartPattern, POStest.EndPattern
		dd	POStest2.StartPattern, POStest2.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"ARB:   ",0
		lesi	POStest
		call	PutPat

		print
		db	"POS:   ",0
		lesi	POStest2
		call	PutPat
		jmp	Test17Done

POSFailed:	print
		db	"POS/ARB did not work",cr,lf,0

Test17Done:



		print
		db	cr,lf
		db	"Testing ARB/RPOS:",cr,lf,lf,0

		ldxi	RPOStest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	RPOSFailed
		printf
		db	"RPOS/ARB worked",cr,lf
		db	"ARB range:    %4x %4x",cr,lf
		db	"RPOS position: %4x %4x",cr,lf,lf
		db	"       %s",cr,lf,0
		dd	RPOStest.StartPattern, RPOStest.EndPattern
		dd	RPOStest2.StartPattern, RPOStest2.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"ARB:   ",0
		lesi	RPOStest
		call	PutPat

		print
		db	"RPOS:  ",0
		lesi	RPOStest2
		call	PutPat
		jmp	Test18Done

RPOSFailed:	print
		db	"RPOS/ARB did not work",cr,lf,0

Test18Done:



		print
		db	cr,lf
		db	"Testing GOTOpos:",cr,lf,lf,0

		ldxi	GOTOposTest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	GOTOFailed
		printf
		db	"GOTOpos worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"          %s",cr,lf,0
		dd	GOTOposTest.StartPattern, GOTOposTest.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"GOTOpos:  ",0
		lesi	SkipTest
		call	PutPat
		jmp	Test19Done

GOTOFailed:	print
		db	"GOTOpos did not work",cr,lf,0

Test19Done:



		print
		db	cr,lf
		db	"Testing RGOTOpos:",cr,lf,lf,0

		ldxi	RGOTOposTest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	RGOTOFailed
		printf
		db	"RGOTOpos worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"           %s",cr,lf,0
		dd	RGOTOposTest.StartPattern, RGOTOposTest.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"RGOTOpos:  ",0
		lesi	RGOTOposTest
		call	PutPat
		jmp	Test20Done

RGOTOFailed:	print
		db	"RGOTOpos did not work",cr,lf,0

Test20Done:



		print
		db	cr,lf
		db	"Testing MatchToChar:",cr,lf,lf,0

		ldxi	Match2Chtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	MTCFailed
		printf
		db	"MatchToChar worked",cr,lf
		db	"Character range: %4x %4x",cr,lf,lf
		db	"             %s",cr,lf,0
		dd	Match2ChTest.StartPattern, Match2ChTest.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"MatchToChar: ",0
		lesi	Match2ChTest
		call	PutPat
		jmp	Test21Done

MTCFailed:	print
		db	"MatchToChar did not work",cr,lf,0

Test21Done:



		print
		db	cr,lf
		db	"Testing MatchToPat:",cr,lf,lf,0

		ldxi	Match2Ptest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	MTPFailed
		printf
		db	"MatchToPat worked",cr,lf
		db	"Character range: %4x %4x",cr,lf
		db	"Pattern range: %4x %4x",cr,lf,lf
		db	"             %s",cr,lf,0
		dd	Match2PTest.StartPattern, Match2PTest.EndPattern
		dd	Match2PTest2.StartPattern, Match2PTest2.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"MatchToPat:  ",0
		lesi	Match2PTest
		call	PutPat

		print
		db	"MatchToPat2: ",0
		lesi	Match2PTest2
		call	PutPat
		jmp	Test22Done

MTPFailed:	print
		db	"MatchToPat did not work",cr,lf,0

Test22Done:



		print
		db	cr,lf
		db	"Testing ARBNUM:",cr,lf,lf,0

		ldxi	ArbNumtest
		lesi	SCtestStr
		xor	cx, cx
		Match
		jnc	ARBNumFailed
		printf
		db	"ARBNUM worked",cr,lf
		db	"Character range: %4x %4x",cr,lf
		db	"Pattern range: %4x %4x",cr,lf,lf
		db	"           %s",cr,lf,0
		dd	ArbNumTest.StartPattern, ArbNumTest.EndPattern
		dd	ArbNumTest2.StartPattern, ArbNumTest2.EndPattern
		dd      SCtestStr

		lea	si,  SCtestStr
		print
		db	"MatchStr:  ",0
		lesi	ArbNumTest
		call	PutPat

		print
		db	"ARBNUM:    ",0
		lesi	ArbNumTest2
		call	PutPat
		jmp	Test23Done

ArbNumFailed:	print
		db	"ARBNUM did not work",cr,lf,0

Test23Done:





Quit:		mov     ah, 4ch
		int     21h
Main		endp

cseg            ends

; Allocate a reasonable amount of space for the stack (2k).

sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends



; zzzzzzseg must be the last segment that gets loaded into memory!

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
heap		db	1024 dup (?)
zzzzzzseg	ends
		end	Main
