		include		stdlib.a
		includelib 	stdlib.lib
;****************************************************************************
;
; T  E  S  T       S  U  I  T  E      F  O  R
;
;
; R  A  N  D  Y      H  Y  D  E ' S     S  T  A  N  D  A  R  D
;
; L  I  B  R  A  R  Y     F  O  R     A  S  S  E  M  B  L  Y
;
; L  A  N  G  U  A  G  E     P  R  O  G  R  A  M  M  E  R  S
;
;****************************************************************************
;
;
; Global variables go here:
;
StdData		segment	para public 'sldata'
		extrn	fpacc:byte
StdData		ends
;
;
dseg		segment	para public 'data'
i		dw	-4321
pi		dd	i
u		dw	2345
pu		dd	u
l		dd	-1234567890
pl		dd	l
ul		dd	987654321
pul		dd	ul
;
ps		dd	s
s		db	"Printf string",0
TestString0	db	"This string gets printed by puts!",cr,lf,0
TestString1	db	"This string gets used by the STRxxx Routines",cr,lf,0
TestString2	db	"gets",0
TestString3	db	"Hello there",0
TestString4	db	"THIS STRING GETS USED BY THE STRXXX ROUTINES",cr,lf,0
TestString5	db	"all lower case",cr,lf,0
TestString6	db	"Clear out this string",0
StringSet1	db	"Tabcdefghijklmnopqrst ",0
StringSet2	db	"uvwxyz!",0
InsStrSrc	db	"Insert This",0
InsStrDest	db	"--><--",0
RevStr1		db	"012345",0
RevStr2		db	"0123456",0
RevStr3		db	"1",0
RevStr4		db	0
buffer		db	256 dup (?)
buffer2		db	256 dup (?)
sfstr1		db	"1 -1 1 65000 100000 -100000 1 4000000000 0abc x",0
sfstr2		db	"1, 2",0
hex1		db	"12ab",0
int1		db	"-12345",0
int2		db	"65000",0
lint1		db	"-2000000000",0
lint2		db	"4000000000",0
i1		dw	?
i2		dw	?
u1		dw	?
u2		dw	?
l1		dd	?
l2		dd	?
ul1		dd	?
ul2		dd	?
h1		dw	?
c1		db	?
c2		db	'!'
MemAvail	dw	?
;
;
;
; Allocate some character sets down here
;
		set	charset, cs2, cs3, cs4
;
;
; Floating point values:
;
SPConst1	dd	1.0
SPConst10	dd	10.25
SPConst100	dd	100.50
SPConst1000	dd	1000.75
SPConst10000	dd	10000.22
SPConst100000	dd	100000.44
SPConst1000000	dd	1000000.66
SPConst123456	dd	123456.88
SPConst65432	dd	65432.11
SPConst9876	dd	9876.33
SPConst192	dd	192.55
SPConst38	dd	38.77
SPConst9	dd	9.99
;
DPConst1	dq	1.0
DPConst10	dq	10.25
DPConst100	dq	100.50
DPConst1000	dq	1000.75
DPConst10000	dq	10000.22
DPConst100000	dq	100000.44
DPConst1000000	dq	123456789012345678.66
DPConst123456	dq	123456.88
DPConst65432	dq	65432.11
DPConst9876	dq	9876.33
DPConst192	dq	192.55
DPConst38	dq	38.77
DPConst9	dq	9.99
;
EPConst1	dt	1.0
EPConst10	dt	10.25
EPConst100	dt	100.50
EPConst1000	dt	1000.75
EPConst10000	dt	10000.22
EPConst100000	dt	100000.44
EPConst1000000	dt	123456789012345678901.66
EPConst123456	dt	123456.88
EPConst65432	dt	65432.11
EPConst9876	dt	9876.33
EPConst192	dt	192.55
EPConst38	dt	38.77
EPConst9	dt	9.99
;
;
;
HexTestString	db	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
;
dseg		ends
;
;
;
;
cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg
;
;
lesi		macro	adrs
		mov     di, seg adrs
		mov	es, di
		lea	di, adrs
		endm
;
ldxi		macro	adrs
		mov	dx, seg adrs
		lea	si, adrs
		endm
;
; Variables that wind up being used by the standard library routines.
; The MemInit routine uses "PSP" and "zzzzzzseg" labels.  They must be
; present if you intend to use getenv, MemInit, malloc, and free.
;
;
		public	PSP
PSP		dw	?
;
cr		equ	13
lf		equ	10
;
;
; Main is the main program.  Program execution always begins here.
;
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
;
;
;
;***************************************************************************
;
; Test the Argc and Argv functions:
;
		print
		db	"This routine has ",0
		argc
		mov	ax, cx
		puti
		print
		db	" command line arguments",cr,lf,0
;
;
;***************************************************************************
;
; Test the ToHex (Intel Hex string conversion) routine:
;
		lesi	HexTestString
		mov	cx, 16
		ToHex
		print
		db	"Intel hex string is ",0
		puts
		free
;
;
;***************************************************************************
;
; Test the floating point routines.
;
		print
		db	"Testing itof:",cr,lf,0
;
		mov	ax, 1
Testitoflp:	push	ax
		mov	cx, 6
		putisize
		print
		db	" = ",0
		itof
		mov	ax, 209h
		ftoam
		puts
		free
		call	putfpacc
		putcr
		pop	ax
		cmp	ax, 10000
		jg	TestItofDone
		cmp	ax, -10000
		jl	TestItofDone
		mov	cx, ax
		mov	bx, -10
		mul	bx
		add	ax, cx
		jmp   	Testitoflp
;
TestItofDone:   putcr
;
;----
;
		print
		db	"Testing utof:",cr,lf,0
;
		mov	ax, 1
Testutoflp:	push	ax
		mov	cx, 5
		putusize
		print
		db	" = ",0
		utof
		mov	ax, 209h
		ftoam
		puts
		free
		call	putfpacc
		putcr
		pop	ax
		cmp	ax, 10000
		ja	TestUtofDone
		mov	cx, ax
		mov	bx, 10
		mul	bx
		add	ax, cx
		jmp   	Testutoflp
;
TestUtofDone:   putcr
;
;----
;
		print
		db	"Testing ltof:",cr,lf,0
;
		mov	ax, 1
		mov	dx, 0
Testltoflp:	push	ax
		push	dx
		mov	cx, 11
		putlsize
		print
		db	" = ",0
		ltof
		mov	ax, 20eh
		ftoam
		puts
		free
		call	putfpacc
		putcr
		pop	dx
		pop	ax
		push	dx
		cmp	ax, 0ca00h		;low(1e9)
		sbb	dx, 3b9ah		;high(1e9)
		pop	dx
		ja	TestLtofDone
		shl	ax, 1			;Multiply by 10.
		rcl	dx, 1
		mov	si, ax
		mov	di, dx
		shl	ax, 1
		rcl	dx, 1
		shl	ax, 1
		rcl	dx, 1
		add	ax, si
		adc	dx, di
		jmp   	Testltoflp
;
TestLtofDone:   putcr
;
		mov	ax, -1
		mov	dx, -1
Testltoflp2:	push	ax
		push	dx
		mov	cx, 11
		putlsize
		print
		db	" = ",0
		ltof
		mov	ax, 20eh
		ftoam
		puts
		free
		call	putfpacc
		putcr
		pop	dx
		pop	ax
		push	dx
		push	ax
		sub	ax, 3600h		;low(-1e9)
		sbb	dx, 0c465h		;high(1e9)
		pop	ax
		pop	dx
		jb	TestLtofDone2
		shl	ax, 1			;Multiply by 10.
		rcl	dx, 1
		mov	si, ax
		mov	di, dx
		shl	ax, 1
		rcl	dx, 1
		shl	ax, 1
		rcl	dx, 1
		add	ax, si
		adc	dx, di
		jmp   	Testltoflp2
;
TestLtofDone2:  putcr
;
		print
		db	cr,lf
		db	"Testing ULTOF",cr,lf,0
;
		mov	ax, 1
		mov	dx, 0
Testultoflp2:	push	ax
		push	dx
		mov	cx, 11
		putulsize
		print
		db	" = ",0
		ultof
		mov	ax, 20eh
		ftoam
		puts
		free
		call	putfpacc
		putcr
		pop	dx
		pop	ax
		push	dx
		push	ax
		sub	ax, 3600h		;low(-1e9)
		sbb	dx, 0c465h		;high(1e9)
		pop	ax
		pop	dx
		ja	TestuLtofDone2
		shl	ax, 1			;Multiply by 10.
		rcl	dx, 1
		mov	si, ax
		mov	di, dx
		shl	ax, 1
		rcl	dx, 1
		shl	ax, 1
		rcl	dx, 1
		add	ax, si
		adc	dx, di
		jmp   	Testultoflp2
;
TestuLtofDone2:  putcr
;
;
;----
;
		print
		db	"Testing LSFPA:",cr,lf,0
;
		lesi	SPConst1
		lsfpa
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst10
		lsfpa
		print
		db	"     10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst100
		lsfpa
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst1000
		lsfpa
		print
		db	"   1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst10000
		lsfpa
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst100000
		lsfpa
		print
		db	"  10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst1000000
		lsfpa
		print
		db	"1000000.66 =",0
		mov	ax, 20bh
		ftoam
		puts
		print
		db	"  Note: only 6-7 significant digits.",cr,lf,0
		free
;
		lesi	SPConst123456
		lsfpa
		print
		db	" 123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst65432
		lsfpa
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst9876
		lsfpa
		print
		db	"   9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst192
		lsfpa
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst38
		lsfpa
		print
		db	"     38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst9
		lsfpa
		print
		db	"      9.99 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		putcr
		free
;
;
;----
;
		print
		db	"Testing LDFPA:",cr,lf,0
;
		lesi	DPConst1
		ldfpa
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst10
		ldfpa
		print
		db	"     10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst100
		ldfpa
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst1000
		ldfpa
		print
		db	"   1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst10000
		ldfpa
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst100000
		ldfpa
		print
		db	"  10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst1000000
		ldfpa
		print
		db	"123456789012345678.66 =",0
		mov	ax, 216h
		ftoam
		puts
		print
		db	"  Note: only 17 sig. digits.",cr,lf,0
		free
;
		lesi	DPConst123456
		ldfpa
		print
		db	" 123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst65432
		ldfpa
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst9876
		ldfpa
		print
		db	"   9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst192
		ldfpa
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst38
		ldfpa
		print
		db	"     38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst9
		ldfpa
		print
		db	"      9.99 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		putcr
		free
;
;
		print
		db	"Testing lefap:",cr,lf,0
;
		lesi	EPConst1
		lefpa
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst10
		lefpa
		print
		db	"     10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst100
		lefpa
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst1000
		lefpa
		print
		db	"   1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst10000
		lefpa
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst100000
		lefpa
		print
		db	"  10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst1000000
		lefpa
		print
		db	"123456789012345678901.66 =",0
		mov	ax, 219h
		ftoam
		puts
		print
		db	"  Note: only 17 sig. digits.",cr,lf,0
		free
;
		lesi	EPConst123456
		lefpa
		print
		db	" 123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst65432
		lefpa
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst9876
		lefpa
		print
		db	"   9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst192
		lefpa
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst38
		lefpa
		print
		db	"     38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst9
		lefpa
		print
		db	"      9.99 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		putcr
		free
;
;
		print
		db	"Testing lefapl:",cr,lf,0
;
		lefpal
		dt	1.0
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	10.25
		print
		db	"     10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	100.50
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	1000.75
		print
		db	"   1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	10000.22
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	100000.44
		print
		db	"  10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	123456789012345678901.66
		print
		db	"123456789012345678901.66 =",0
		mov	ax, 219h
		ftoam
		puts
		print
		db	"  Note: only 17 sig. digits.",cr,lf,0
		free
;
		lefpal
		dt	123456.88
		print
		db	" 123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	65432.11
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	9876.33
		print
		db	"   9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	192.55
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	38.77
		print
		db	"     38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpal
		dt	9.99
		print
		db	"      9.99 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		putcr
		free
;
;
;***************************************************************************
;
; Test the StrRev and StrRev2 routines here.
;
		print
		db	"Testing StrRev:",cr,lf,0
		lesi	RevStr1
		strrev
		puts
		putcr
		strrev
		puts
		putcr
                putcr
;
		lesi	RevStr2
		strrev
		puts
		putcr
		strrev
		puts
		putcr
                putcr
;
		lesi	RevStr3
		strrev
		puts
		putcr
		strrev
		puts
		putcr
                putcr
;
		lesi	RevStr4
		strrev
		puts
		putcr
		strrev
		puts
		putcr
;
;
		print
		db	"Testing StrRev2:",cr,lf,0
		lesi	RevStr1
		strrevm
		puts
		putcr
		free
;
		lesi	RevStr2
		strrevm
		puts
		putcr
		free
;
		lesi	RevStr3
		strrevm
		puts
		putcr
		free
;
		lesi	RevStr4
		strrevm
		puts
		putcr
		free
		putcr
;
;
;***************************************************************************
;
; Test the STRINS and STRDEL routines here.
;
		print
		db	"Testing StrDel:",cr,lf,0
		ldxi	buffer
		lesi	InsStrDest
		strcpy
		mov	ax, 2
		mov	cx, ax
		strdel
		puts
		putcr
;
		ldxi	buffer
		lesi	InsStrDest
		strcpy
		mov	ax, 20
		mov	cx, 2
		strdel
		puts
		putcr
;
		print
		db	"Testing StrDel2:",cr,lf,0
		lesi	InsStrDest
		mov	ax, 2
		mov	cx, ax
		strdelm
		puts
		putcr
		free
;
		lesi	InsStrDest
		mov	ax, 20
		mov	cx, 2
		strdelm
		puts
		putcr
		free
;
		print
		db	"Testing StrInsl:",cr,lf,0
		ldxi	buffer
		lesi	InsStrDest
		strcpy
;
		mov	cx, 3
		strinsl
		db	"Hi there",0
		puts
		putcr
;
		print
		db	"Testing StrIns2l:",cr,lf,0
		lesi	InsStrDest
		mov	cx, 3
		strinsml
		db	"Ho ho ho!",0
		puts
		putcr
		free
;
		lesi	InsStrDest
		mov	cx, 100
		strinsml
		db	"and a bottle of rum!",cr,lf,0
		puts
		putcr
		free
;
		print
		db	"Testing STRINS2:",cr,lf,0
		lesi	InsStrDest
		ldxi	InsStrSrc
		mov	cx, 3
		strinsm
		jnc	GoodStrins2
		print
		db	"Could not allocate memory for StrInsm",cr,lf,0
		jmp	short BadStrins2
;
GoodStrins2:	puts
		putcr
		free
;
BadStrIns2:	lesi	InsStrDest
		ldxi	InsStrSrc
		mov	cx, 100
		strinsm
		jnc	GoodSI2
		print
		db	"Strinsm:memory allocation error",cr,lf,0
		jmp	short BSI2
;
GoodSI2:	puts
		putcr
		free
;
BSI2:		print
		db	"Testing STRINS:",cr,lf,0
		lesi	InsStrDest
		ldxi	InsStrSrc
		mov	cx, 3
		strins
		puts
		putcr
		lesi	InsStrDest
		ldxi	InsStrSrc
		mov	cx, 100
		strins
		puts
		putcr
;
;
;***************************************************************************
;
; Test the character set routines down here:
;
		print  
		db	"Testing RangeSet:",cr,lf,0
		mov	al, 'A'
		mov	ah, 'F'
		lesi    CharSet
		rangeset
		print
		db	"Chars in set: ",0
		call	PrintSet
;
		print
		db	cr,lf,lf,"Testing addstr, addstrl:",cr,lf,0
		lesi	cs2
		ldxi	StringSet2
		addstr
		addstrl
		db	"aAbBcCdDeEfF",0
		print
		db	"Chars in set: ",0
		call	PrintSet
;
		print
		db	cr,lf,lf,"Testing rmvstr, rmvstrl:",cr,lf,0
		lesi	cs2
		ldxi	StringSet2
		rmvstr
		rmvstrl
		db	"ABCDEF",0
		print
		db	"Chars in set: ",0
		call	PrintSet
;
		print
		db	cr,lf,lf,"Testing addchar/rmvchar:",cr,lf,0
		lesi	cs2
		mov	al, 'A'
		addchar
		mov	al, 'a'
		rmvchar
		print
		db	"Chars in set: ",0
		call	PrintSet
;
		print
		db	cr,lf,lf,"Testing emptyset:",cr,lf,0
		emptyset
		print
		db	"Chars in set: ",0
		call	PrintSet
;
		print
		db	cr,lf,lf,"Testing member:",cr,lf,0
		addstrl
		db	"ABCDEF",0
		mov	al, 'A'
		member
		jne	NotInSet1
		print
		db	"A was not in the set",0
		jmp	short NIS1
;
NotInSet1:	print
		db	"A is in the set",0
NIS1:		putcr
		mov	al, "G"
		member
		jne	NotInSet2
		print
		db	"G is not in the set",0
		jmp	short NIS2
;
NotInSet2:	print
		db	"G is in the set",0
NIS2:		putcr
;
		print
		db	cr,lf,lf,"Testing copyset:",cr,lf,0
		mov	dx, es
		mov	si, di
		lesi	cs3
		copyset
		print
		db	"Value in cs3: ",0
		call	Printset
;
		print	
		db	cr,lf,lf,"Testing unionset:",cr,lf,0
		addstrl
		db	"ABCDEFuvwxyz",0
		ldxi	cs2
		setunion
		print
		db	"Chars in set: ",0
		call	Printset
;
		print
		db	cr,lf,lf,"Testing set difference",cr,lf,0
		ldxi	cs2
		setdifference
		print
		db	"Chars in set: ",0
		call	PrintSet
;
;
;
;***************************************************************************
;
; Test the STRxxx routines here.
;
;
;*Strspan
;
		print
		db	cr,lf,lf,"Testing strspan:",cr,lf,0
;
		lesi	TestString1
		ldxi	StringSet1
		strspan
		mov	i1, cx
		printf
		db	"TestString1 contains a character not found in "
		db	"StringSet1 at position %d\n\n",0
		dd	i1
;
;
;*Strspanl
;
		print
		db	"Testing strspanl:",cr,lf,0
;
		lesi	TestString1
		strspanl
		db	"Tabcdefghijklmnopqrst ",0
		mov	i1, cx
		printf
		db	"TestString1 contains a character not found in "
		db	"the set at position %d\n\n",0
		dd	i1
;
;
;*Strcspan
;
		print
		db	"Testing strcspan:",cr,lf,0
;
		lesi	TestString1
		ldxi	StringSet2
		strcspan
		mov	i1, cx
		printf
		db	"TestString1 contains a character found in "
		db	"StringSet2 at position %d\n\n",0
		dd	i1
;
;
;*Strcspanl
;
		print
		db	"Testing strcspanl:",cr,lf,0
;
		lesi	TestString1
		strcspanl
		db	"uvwxyz!",0
		mov	i1, cx
		printf
		db	"TestString1 contains a character not found in "
		db	"the set at position %d\n\n",0
		dd	i1
;
;
;*Strset, Strset2
;
		print
		db	"Testing Strset",cr,lf,0
;
		lesi	TestString6
		mov	al, '*'
		strset
		puts
;
;
		print
		db	cr,lf,lf,"Testing StrSetm:",cr,lf,0
		mov	cx, 32
		mov	al, '#'
		strsetm
		puts
		free
		putcr
		putcr
;
;
;*Strupr, Strupr2
;
		printf
		db	"Testing Strupr:\n"
		db	"Before: %s",0
		dd	TestString5
		lesi	TestString5
		strupr
		printf
		db	"After: %s",0
		dd	TestString5
;
;
;*Strlwr, Strlwr2
;
		printf
		db	cr,lf,"Testing Strlwr:\n"
		db	"Before: %s",0
		dd	TestString5
		lesi	TestString5
		strlwr
		printf
		db	"After: %s",0
		dd	TestString5
;
;
;
;*Strcmp, Strcmpl
;
		print
		db	"Testing Strcmp",cr,lf,0
;
		lesi	TestString1
		ldxi	TestString1
		strcmp
		jne	Sne1
		print
		db	"TestString1 == TestString1",cr,lf,0
		jmp	short s2
;
Sne1:		print
		db	"TestString1 <> TestString1",cr,lf,0
;
s2:		ldxi	TestString0
		strcmp
		jb	IsBelow
		ja	IsAbove
		printf
		db	"'%s' is equal to '%s'\n",0
		dd	TestString1, TestString0
		jmp	short s3
;
IsBelow:	printf
		db	"%s is less than \n%s\n",0
		dd	TestString1, TestString0
		jmp	short s3
;
IsAbove:	printf
		db	"%s is greater than \n%s\n",0
		dd	TestString1, TestString0
;
S3:
;
		print
		db	cr,lf,"Testing Strcmpl",cr,lf,0
;
		lesi	TestString2
		strcmpl
		db	"gets",0
		jne	Sne1a
		print
		db	"TestString2 == 'gets'",cr,lf,0
		jmp	short s2a
;
Sne1a:		print
		db	"TestString2 <> 'gets'",cr,lf,0
;
s2a:		lesi	TestString2
		strcmpl
		db	"itsa",0
		jb	IsBelowa
		ja	IsAbovea
		printf
		db	"'%s' is equal to 'itsa'\n",0
		dd	TestString2
		jmp	short s3a
;
IsBelowa:	printf
		db	"'%s' is less than 'itsa'\n",0
		dd	TestString2
		jmp	short s3a
;
IsAbovea:	printf
		db	"'%s' is greater than 'itsa'\n",0
		dd	TestString2
;
S3a:
;
;
;*Stricmp, Stricmpl
;
		print
		db	cr,lf,"Testing Stricmp",cr,lf,0
;
		lesi	TestString1
		ldxi	TestString4
		stricmp
		jne	Sne1c
		print
		db	"TestString1 == TestString4",cr,lf,0
		jmp	short s2c
;
Sne1c:		print
		db	"TestString1 <> TestString4",cr,lf,0
;
s2c:		lesi	TestString1
		ldxi	TestString4
		stricmp
		jb	IsBelowc
		ja	IsAbovec
		printf
		db	"'%s' is equal to '%s'\n",0
		dd	TestString1, TestString4
		jmp	short s3c
;
IsBelowc:	printf
		db	"'%s' is less than '%s'\n",0
		dd	TestString1, TestString4
		jmp	short s3c
;
IsAbovec:	printf
		db	"'%s' is greater than '%s'\n",0
		dd	TestString1, TestString4
;
S3c:
;
;
		print
		db	"Testing Stricmpl",cr,lf,0
;
		lesi	TestString2
		stricmpl
		db	"GETS",0
		jne	Sne1d
		print
		db	"TestString2 == 'gets'",cr,lf,0
		jmp	short s2d
;
Sne1d:		print
		db	"TestString2 <> 'gets'",cr,lf,0
;
s2d:		lesi	TestString2
		strcmpl
		db	"itsa",0
		jb	IsBelowd
		ja	IsAboved
		printf
		db	"'%s' is equal to 'itsa'\n",0
		dd	TestString2
		jmp	short s3d
;
IsBelowd:	printf
		db	"'%s' is less than 'itsa'\n",0
		dd	TestString2
		jmp	short s3d
;
IsAboved:	printf
		db	"'%s' is greater than 'itsa'\n",0
		dd	TestString2
;
S3d:
;
;
;*Strcpy
;
		lesi	TestString1
		ldxi	Buffer
		strcpy
		puts
;
;*Strcpyl
;
		print
		db	"Testing Strcpyl:",cr,lf,0
;
		ldxi	Buffer
		strcpyl
		db	"This is an strcpyl string",cr,lf,0
		puts
		ldxi	Buffer2
		strcpy
		puts
;
;*Strdup
;
		lesi	TestString1
		strdup          
		puts
		free
;
;*Strdupl
;
		print
		db	"Testing Strdupl:",cr,lf,0
;
		strdupl
		db	"This string is for strdupl",cr,lf,0
		puts
		free
;
;*Strlen
;
		lesi	s
		strlen
		mov	i1, cx
		printf
		db	"Length of string: '%s' is %d\n",0
		dd	s, i1
;
;*Strcat
;
		print
		db      "Testing strcat:",cr,lf,0
;
		lesi	Buffer
		strcpyl
		db	"Test String 1 --",0
		ldxi	TestString1
		strcat
		puts
;
;*Strcatl
;
		print
		db      "Testing strcatl:",cr,lf,0
;
		lesi	Buffer
		strcpyl
		db	"Strcatl test --",0
		strcatl
		db	"More stuff for Strcatl",cr,lf,0
		puts
;
;*Strcat2
;
		print
		db	"Testing strcatm:",cr,lf,0
;
		lesi	TestString1
		ldxi	TestString0
		strcatm
		puts
		free
;
		print
		db	"Testing strcatml:",cr,lf,0
;
		lesi	TestString1
		strcatml
		db	"Appended string",cr,lf,0
		puts
		free
;
;*Strchar
;                     
		lesi	TestString1
		mov	al, 'a'
		StrChr
		pushf
		mov	i1, cx
		printf
		db	"Testing strchr:",cr,lf
		db	"Searching for 'a' in '%s'\n"
		db	"Found it at position %d\n",0
		dd	TestString1, i1
		popf
		jnc	FndIt1
		print
		db	"Could not find character in string.",cr,lf,0
;
FndIt1:		lesi	TestString1
		mov	al, 'T'
		StrChr
		pushf
		mov	i1, cx
		printf
		db	"Testing strchr:",cr,lf
		db	"Searching for 'T' in '%s'\n"
		db	"Found it at position %d\n",0
		dd	TestString1, i1
		popf
		jnc	FndIt2
		print
		db	"Could not find character in string.",cr,lf,0
FndIt2:
;
;
;*Strstr
;
		print
		db	"Testing strstr:",cr,lf,0
;
		lesi	TestString1
		ldxi	TestString2
		strstr
		jc	NotFnd2
		mov	i1, cx
		printf
		db	"Found substring at position %i\n",0
		dd	i1
		jmp	short FndIt3
;
NotFnd2:	print
		db	"Didn't find substring #1.",cr,lf,0
;
FndIt3:		ldxi	TestString3
		strstr
		jc	NotFnd3
		print
		db	"Error, found a string which isn't present!",cr,lf,0
;
NotFnd3:
;
;
;*Strstrl
;
		print
		db	"Testing strstrl:",cr,lf,0
;
		lesi	TestString1
		strstrl
		db	"gets",0
		jc	NotFnd2a
		mov	i1, cx
		printf
		db	"Found substring at position %i\n",0
		dd	i1
		jmp	short FndIt3a
;
NotFnd2a:	print
		db	"Didn't find substring #1.",cr,lf,0
;
FndIt3a:	strstrl
		db	"Hello There",0
		jc	NotFnd3a
		print
		db	"Error, found a string which isn't present!",cr,lf,0
;
NotFnd3a:
;     
;
;
;
		putcr
		putcr
;
;***************************************************************************
;
; Test IsAlNum, IsDigit, IsAlpha, IsLower, IsUpper, and IsxDigit here:
;
		print
		db	"Testing IsAlNum, IsDigit, IsAlpha, IsLower, "
		db	"IsUpper, and IsXDigit",cr,lf,0
;
		mov	cx, 26
		mov	al, 'Z'
		mov	ah, 'z'
TstAlphaLp:	IsAlNum
		jne	yALNumFail
		IsAlpha
		jne	ALFail
		IsUpper
		jne	UprFail
		cmp	al, 'F'
		ja	NotHex
		IsXDigit
		jne	XFail
;
NotHex:		xchg	al, ah
		IsAlNum
yALNumFail:	jne	AlNumFail
		IsAlpha
		jne	ALFail
		IsLower
		jne	LwrFail
		cmp	al, 'f'
		ja	NotHex2
		IsXDigit
		jne	XFail
;
NotHex2:	xchg	al, ah
		dec	al
		dec	ah
		loop	TstAlphaLp
;
		mov	cx, 10
		mov	al, '9'
TstDigLp:	IsDigit
		jne	DigitFail
		IsAlNum
		jne	AlNumFail
		IsXDigit
		jne	XFail
		dec	al
		loop	TstDigLp
		jmp	short TestBad
;
ALNumFail:	jmp	short xALNumFail
ALFail:		jmp	short xALFail
UprFail:	jmp	xUprFail
LwrFail:	jmp	xLwrFail
XFail:		jmp	xXFail
DigitFail:	jmp	xDigitFail
;
TestBad:	mov	al, '1'
		IsAlpha
		je	ALFail
		IsLower
		je	LwrFail
		IsUpper
		je	UprFail
		mov	al, '!'
		IsDigit
		je	DigitFail
		IsAlNum
		je	AlNumFail
		IsXDigit
		je	XFail
		jmp	TestSPrintf
;
xALNumFail:	print
		db	"IsALNum has failed",cr,lf,0
		jmp	TestSPrintf
;
xALFail:	print
		db	"IsAlpha has failed",cr,lf,0
		jmp	short TestSPrintf
;
xUprFail:	print
		db	"IsUpper has failed",cr,lf,0
		jmp	short TestSPrintf
;
xLwrFail:	print
		db	"IsLower has failed",cr,lf,0
		jmp	short TestSPrintf
;
xXFail:		print
		db	"IsXDigit has failed",cr,lf,0
		jmp	short TestSPrintf
;
xDigitFail:	print
		db	"IsDigit has failed",cr,lf,0
;
;***************************************************************************
;
; Testing sprintf and sprintfm here.
;
TestSPrintf:	sprintfm
		db	"I= %i, I='%10i', I=%^i",cr,lf
		db	"U= %u",cr,lf,0
		dd	i,i,pi,u
		puts
		free
;
		lesi	Buffer
		sprintf
		db	"I= %i, I='%10i', I=%^i",cr,lf
		db	"U= %u",cr,lf,0
		dd	i,i,pi,u
		puts
;
;***************************************************************************
;
; Testing various ITOxx routines here.
;
		mov	ax, -1234
		itoam
		print
		db	"ITOAM: -1234 is ",0
		puts
		putcr
		free			;Free allocated storage.
;
;-----
;
		lesi	buffer
		itoa
		print
		db	"ITOA: -1234 is ",0
		puts
		putcr
;
;-----
;
		lesi	buffer
		itoa2
		itoa2
		lesi	buffer
		printf
		db	"ITOA2: -1234-1234 is %s\n",0
		dd	buffer
;
;-----
;
		mov	ax, 43210
		utoam
		print
		db	"UTOAM: 43210 is ",0
		puts
		putcr
		free			;Free allocated storage.
;
;-----
;
		lesi	buffer
		mov	ax, 43210
		utoa
		print
		db	"UTOA: 43210 is ",0
		puts
		putcr
;
;-----
;
		lesi	buffer
		utoa2
		utoa2
		printf
		db	"UTOA2: 4321043210 is %s\n",0
		dd	buffer
;
;-----
;
		lesi	buffer
		mov	ax, 0ABCDh
		htoa
		print
		db	"HTOA: 0cdh is ",0
		puts
		putcr
		mov	ax, 0ABCDh
		htoam
		print
		db	"HTOAM: 0cdh is ",0
		puts
		putcr
		free			;Free allocated storage.
;
;-----
;
		lesi	buffer
		mov	ax, 0ABCDh
		wtoa
		print
		db	"WTOA: 0abcdh is ",0
		puts
		putcr
		mov	ax, 0ABCDh
		wtoam
		print
		db	"WTOAM: 0abcdh is ",0
		puts
		putcr
		free			;Free allocated storage.
;
;-----
;
		mov	ax, -1234
		mov	dx, 0ffffh
		ltoam
		print
		db	"LTOAM: -1234 is ",0
		puts
		putcr
		free
;
;-----
;
		mov	ax, 1234
		mov	dx, 0
		ultoam
		print
		db	"ULTOAM: 1234 is ",0
		puts
		putcr
		free
;
;
;***************************************************************************
;
; Testing memory management routines here:
;
		mov	cx, 256
		malloc
		IsPtr
		jnc	ValidPtr
		print
		db	"This is not a valid ptr (1)",cr,lf,0
		jmp	short x1
;
ValidPtr:	print
		db	"Malloc returned a valid ptr",cr,lf,0
;
x1:		inc	di
		IsPtr
		jc	InvalidPtr
		print
		db	"Incrementing a pointer didn't make it invalid",cr,lf,0
		jmp	short x2
;
InvalidPtr:	print
		db	"Incrementing a pointer makes it invalid",cr,lf,0
;
x2:		IsInHeap
		jc	BadIsIn
		print
		db	"Although incrementing it leaves it in the heap",cr,lf,0
		jmp	short x3
;
BadIsIn:	print
		db	"Incrementing the pointer moved it out of the heap"
		db	cr,lf,0
;
x3:		dec	di
		free
		jnc	GoodFree
		print
		db	"Free returned an error",cr,lf,0
		jmp	short x4
;
GoodFree:	print
		db	"FREE did its job.",cr,lf,0
;
x4:		mov	cx, 512
		malloc
		mov	cx, 256
		realloc
		jnc	GoodRealloc
		print
		db	"Realloc screwed up!",cr,lf,0
		jmp	x5
;
GoodRealloc:	DupPtr
		free
		jnc	GF1
		print
		db	"Free choked after DupPtr",cr,lf,0
		jmp	short x5
;
GF1:		free
		jnc	GF2
		print
		db	"Free choked after second call.",cr,lf,0
		jmp	short x5
;
GF2:		free
		jc	x5
		print
		db	"Free DIDN'T return an error when it was "
		db	"supposed to.",cr,lf,0
;
x5:
;
;
;****************************************************************************
;
; Testing the ISIZE and LSIZE routines here:
;
		mov	ax, -12345
		isize
		print
		db	"Size of -12345 (isize) is ",0
		puti
		mov	ax, 1234
		usize
		print
		db	cr,lf,"Size of 1234 (usize) is ",0
		puti
;
		mov	dx, 0ffffh
		mov	ax, -12345
		lsize
		print
		db	cr,lf,"Size of -12345 (lsize) is ",0
		puti
		mov	ax, 1234
		xor	dx, dx
		ulsize
		print
		db	cr,lf,"Size of 1234 (ulsize) is ",0
		puti
		putcr
;
;****************************************************************************
;
; Test the "ATOxx" routines here.
;
		print
		db	"Testing ATOH: ",0
		lesi	hex1
		atoh
		putw
		mov	al, ' '
		putc
;
		atoh2
		putw
		putcr
;
		print
		db	"Testing ATOI: ",0
		lesi	int1
		atoi
		puti
		mov	al, ' '
		putc
		atoi2
		puti
		putcr
;
		print
		db	"Testing ATOU: ",0
		lesi	int2
		atou
		putu
		mov	al, ' '
		putc
		atou2
		putu
		putcr
;
		print
		db	"Testing ATOL: ",0
		lesi	lint1
		atol
		putl
		mov	al, ' '
		putc
		atol2
		putl
		putcr
;
		print
		db	"Testing ATOUL: ",0
		lesi	lint2
		atoul
		putul
		mov	al, ' '
		putc
		atoul2
		putul
		putcr
;
;
;****************************************************************************
;
; Test SCANF here:
;
		printf
		db	"Enter some text: ",0
		scanf
		db	"%s",0
		dd	buffer
		print
		db	"You entered: ",0
		lesi	buffer
		puts
		putcr
;
; Test SSCANF here:
;
		printf
		db	"Before, c1=%c, c2=%c\n",0
		dd	c1,c2
;
		lesi	sfstr1
		sscanf
		db	"%i %d %u %u %ld %li %lu %lu %x %c",0
		dd	i1,i2,u1,u2,l1,l2,ul1,ul2,h1,c1
;
		printf
		db	"Values input by sscanf:\n"
		db	"i1=%d, i2=%d\n"
		db	"u1=%u, u2=%u\n"
		db	"l1=%ld, l2=%ld\n"
		db	"ul1=%lu, ul2=%lu\n"
		db	"h1=%x\n"
		db	"c1=%c,  c2=%c\n"
		db	0
		dd	i1,i2,u1,u2,l1,l2,ul1,ul2,h1,c1,c2
;
;
		print
		db	"Testing scanf character skipping:",cr,lf,0
		lesi	sfstr2
		sscanf
		db	"%i, %i",0
		dd	i1,i2
		printf
		db	"i1=%i, i2=%i\n",0
		dd	i1, i2
;
;
;****************************************************************************
;
;
;
; Testing the PUTC routines here.
;
; The following code should print:
;
; aaa
; aaa
; aaa
; aaaaaaaa
;
; aaaa
; aaaaaaaa
; 
; aaaa
;
;
		mov	al, 'a'
		putc
		putc
		putc
;
		putcr
;
		putcstdout
		putcstdout
		putcstdout
		putcr
;
		putcbios
		putcbios
		putcbios
		putcr
;
		mov	di, cs
		mov	es, di
		lea	di, dblchars
		setoutadrs
;
		putc
		putc
		putc
		putc
		putcr
;
		getoutadrs
		cmp	di, offset dblchars
		jne	badtest
		mov	di, es
		cmp	di, seg dblchars
		jne	badtest
;
		mov	di, seg sl_putcstdout
		mov	es, di
		lea	di, sl_putcstdout
		pushoutadrs
		putc
		putc
		putc
		putc
		putcr
;
		popoutadrs
		putc
		putc
		putc
		putc
		putcr
		popoutadrs
		cmp	di, offset dblchars
		jne	badtest
		mov	di, es
		cmp	di, seg dblchars
		jne	badtest
;
		putc
		putc
		putc
		putc
		putcr
		jmp	short goodtest
;
badtest:	print
		db	"GetOutAdrs or PopOutAdrs did not return "
		db	"the proper address",cr,lf,0
;
GoodTest:
;
;
;****************************************************************************
;
; Test the remaining print routines here
;
		print
		db	"This is a test of the print routine",cr,lf,0
;
		print
		db	0
;
		print
		db	"So is this!",cr,lf,0
;
		lesi	TestString0
		puts
;
		print
		db	"Hex value 0xfa output by PutH: ",0
		mov	al, 0fah
		puth
;
		print
		db	cr,lf,"Hex value 0xfa12 output by PutW: ",0
		mov	ax, 0fa12h
		putw
;
		print
		db	cr,lf,"Decimal value 0xffff output by puti: ",0
		mov	ax, 0ffffh
		puti
		print	
		db	cr,lf,"Decimal value 1 output by puti: ",0
		mov	ax, 1
		puti
;
		print
		db	cr,lf,"Unsigned value 0ffffh output by putu: ",0
		mov	ax, 0ffffh
		putu
		print
		db	cr,lf,"Unsigned value 1 output by putu: ",0
		mov	ax, 1
		putu
;
		print
		db	cr,lf,"Long value 0ffff1234 output by putL: ",0
		mov	ax, 1234h
		mov	dx, 0ffffh
		putl
		print	
		db	cr,lf,"Long value 01234ffff output by putL: ",0
		mov	dx, 1234h
		mov	ax, 0ffffh
		putl
;
		print
		db	cr,lf,"Unsigned long value 1234ffff output by "
		db	"putUL: ",0
		putul
		print
		db	cr,lf,"Unsigned long value 0ffff1234 output by "
		db	"putUL: ",0
		mov	dx, 0ffffh
		mov	ax, 1234h
		putUL
		putcr
;
		mov	cx, 10
islp1:		print
		db	"Outputting -2567 using a field width of ",0
		mov	ax, cx
		puti
		print
		db	" **",0
		mov	ax, -2567
		putisize
		print
		db	"** w/PutISize",cr,lf,0
		loop	islp1
;
		mov	cx, 10
islp2:		print
		db	"Outputting -2567 using a field width of ",0
		mov	ax, cx
		puti
		print
		db	" **",0
		mov	ax, -2567
		putusize
		print
		db	"** w/PutUSize",cr,lf,0
		loop	islp2
;
		mov	cx, 10
islp3:		print
		db	"Outputting -2567 using a field width of ",0
		mov	ax, cx
		puti
		print
		db	" **",0
		mov	ax, -2567
		mov	dx, 0ffffh
		putlsize
		print
		db	"** w/PutLSize",cr,lf,0
		loop	islp3
		print
		db	"Outputting 0ff001234h using PutLSize: ",0
		mov	dx, 0ff00h
		mov	ax, 1234h
		mov	cx, 10
		PutLSize
		putcr
;
		mov	cx, 10
islp4:		print
		db	"Outputting -2567 using a field width of ",0
		mov	ax, cx
		puti
		print
		db	" **",0
		mov	ax, -2567
		mov	dx, 0ffffh
		putulsize
		print
		db	"** w/PutULSize",cr,lf,0
		loop	islp4
		print
		db	"Outputting 0ff001234h using PutULSize: ",0
		mov	dx, 0ff00h
		mov	ax, 1234h
		mov	cx, 10
		PutULSize
		putcr
;
;****************************************************************************
;
; Testing the PRINTF routine:
;
		printf
		db	"This is a test of the printf routine w/o any "
		db	"operands.\n"
		db	"It tests the esc characters \\n, \\r, \\b, \\t, "
		db	"\0x0d, and \\\\.\n"
		db	"Test of \\r:\n"
		db	"Old line.\rNew line.\n"
		db	"Test of \t\ttab.\n"
		db	"Test of backspace\b\b\b\b\bs p a c e\n"
		db	"Test of return using \\0x0d:\n"
		db	"Old line.\0x0dNew line.\n\n",0
;
		printf
		db	cr,lf
		db	"Test of integer output formats (using I):\n"
		db	"\%d\t\t-\t*%d*\n"
		db	"\%10d\t\t-\t*%10d*\n"
		db	"\%-10d\t\t-\t*%-10d*\n"
		db	"\%\\*10d\t\t-\t*%\*10d*\n"
		db	"\%\-\\*10d\t\t-\t*%-\*10d*\n"
		db	"\%^d\t\t-\t*%^d*\n"
		db	"\%10^d\t\t-\t*%10^d*\n"
		db	"\%-10^d\t\t-\t*%-10^d*\n"
		db	"\%\\*10^d\t\t-\t*%\*10^d*\n"
		db	"\%\-\\*10^d\t-\t*%-\*10^d*\n"
		db	0
		dd	i,i,i,i,i,pi,pi,pi,pi,pi
;
		printf
		db	cr,lf
		db	"Test of unsigned integer output formats (using U):\n"
		db	"\%u\t\t-\t*%u*\n"
		db	"\%10u\t\t-\t*%10u*\n"
		db	"\%-10u\t\t-\t*%-10u*\n"
		db	"\%\\*10u\t\t-\t*%\*10u*\n"
		db	"\%\-\\*10u\t\t-\t*%-\*10u*\n"
		db	"\%^u\t\t-\t*%^u*\n"
		db	"\%10^u\t\t-\t*%10^u*\n"
		db	"\%-10^u\t\t-\t*%-10^u*\n"
		db	"\%\\*10^u\t\t-\t*%\*10^u*\n"
		db	"\%\-\\*10^u\t-\t*%-\*10^u*\n"
		db	0
		dd	u,u,u,u,u,pu,pu,pu,pu,pu
;
		printf
		db	cr,lf
		db	"Test of unsigned long output formats (using UL):\n"
		db	"\%ul\t\t-\t*%lu*\n"
		db	"\%15lu\t\t-\t*%15lu*\n"
		db	"\%-15lu\t\t-\t*%-15lu*\n"
		db	"\%\\*15lu\t\t-\t*%\*15lu*\n"
		db	"\%\-\\*15lu\t-\t*%-\*15lu*\n"
		db	"\%^lu\t\t-\t*%^lu*\n"
		db	"\%15^lu\t\t-\t*%15^lu*\n"
		db	"\%-15^lu\t\t-\t*%-15^lu*\n"
		db	"\%\\*15^lu\t-\t*%\*15^lu*\n"
		db	"\%\-\\*15^lu\t-\t*%-\*15^lu*\n"
		db	0
		dd	ul,ul,ul,ul,ul,pul,pul,pul,pul,pul
;
		printf
		db	cr,lf
		db	"Test of long output formats (using L):\n"
		db	"\%ld\t\t-\t*%ld*\n"
		db	"\%15ld\t\t-\t*%15ld*\n"
		db	"\%-15ld\t\t-\t*%-15ld*\n"
		db	"\%\\*15ld\t\t-\t*%\*15ld*\n"
		db	"\%\-\\*15ld\t-\t*%-\*1ld*\n"
		db	"\%^ld\t\t-\t*%^ld*\n"
		db	"\%15^ld\t\t-\t*%15^ld*\n"
		db	"\%-15^ld\t\t-\t*%-15^ld*\n"
		db	"\%\\*15^ld\t-\t*%\*15^ld*\n"
		db	"\%\-\\*15^ld\t-\t*%-\*15^ld*\n"
		db	0
		dd	l,l,l,l,l,pl,pl,pl,pl,pl
;
		printf
		db	cr,lf
		db	"Test of hexadecimal output (byte) using I:\n"
		db	"\%h\t\t-\t*%h*\n"
		db	"\%5h\t\t-\t*%5h*\n"
		db	"\%-5h\t\t-\t*%-5h*\n"
		db	"\%\\*5h\t\t-\t*%\*5h*\n"
		db	"\%\-\\*5h\t\t-\t*%-\*5h*\n"
		db	"\%^h\t\t-\t*%^h*\n"
		db	"\%5^h\t\t-\t*%5^h*\n"
		db	"\%-5^h\t\t-\t*%-5^h*\n"
		db	"\%\\*5^h\t\t-\t*%\*5^h*\n"
		db	"\%\-\\*5^h\t\t-\t*%-\*5^h*\n"
		db	0
		dd	i,i,i,i,i,pi,pi,pi,pi,pi
;
		printf
		db	cr,lf
		db	"Test of hexadecimal output (word) using I:\n"
		db	"\%x\t\t-\t*%x*\n"
		db	"\%5x\t\t-\t*%5x*\n"
		db	"\%-5x\t\t-\t*%-5x*\n"
		db	"\%\\*5x\t\t-\t*%\*5x*\n"
		db	"\%\-\\*5x\t\t-\t*%-\*5x*\n"
		db	"\%^x\t\t-\t*%^x*\n"
		db	"\%5^x\t\t-\t*%5^x*\n"
		db	"\%-5^x\t\t-\t*%-5^x*\n"
		db	"\%\\*5^x\t\t-\t*%\*5^x*\n"
		db	"\%\-\\*5^x\t\t-\t*%-\*5^x*\n"
		db	0
		dd	i,i,i,i,i,pi,pi,pi,pi,pi
;
		printf
		db	cr,lf
		db	"Test of hexadecimal output (long) using UL:\n"
		db	"\%lx\t\t-\t*%lx*\n"
		db	"\%15lx\t\t-\t*%15lx*\n"
		db	"\%-15lx\t\t-\t*%-15lx*\n"
		db	"\%\\*15lx\t\t-\t*%\*15lx*\n"
		db	"\%\-\\*15lx\t-\t*%-\*15lx*\n"
		db	"\%^lx\t\t-\t*%^lx*\n"
		db	"\%15^lx\t\t-\t*%15^lx*\n"
		db	"\%-15^lx\t\t-\t*%-15^lx*\n"
		db	"\%\\*15^lx\t-\t*%\*15^lx*\n"
		db	"\%\-\\*15^lx\t-\t*%-\*15^lx*\n"
		db	0
		dd	ul,ul,ul,ul,ul,pul,pul,pul,pul,pul
;
		printf
		db	cr,lf
		db	"Test of character output using S:\n"
		db	"\%c\t\t-\t*%c*\n"
		db	"\%5c\t\t-\t*%5c*\n"
		db	"\%-5c\t\t-\t*%-5c*\n"
		db	"\%\\*5c\t\t-\t*%\*5c*\n"
		db	"\%\-\\*5c\t\t-\t*%-\*5c*\n"
		db	"\%^c\t\t-\t*%^c*\n"
		db	"\%5^c\t\t-\t*%5^c*\n"
		db	"\%-5^c\t\t-\t*%-5^c*\n"
		db	"\%\\*5^c\t\t-\t*%\*5^c*\n"
		db	"\%\-\\*5^c\t\t-\t*%-\*5^c*\n"
		db	0
		dd	s,s,s,s,s,ps,ps,ps,ps,ps
;
		printf
		db	cr,lf
		db	"Test of string output using s:\n"
		db	"\%s\t\t-\t*%s*\n"
		db	"\%15s\t\t-\t*%15s*\n"
		db	"\%-15s\t\t-\t*%-15s*\n"
		db	"\%\\*15s\t\t-\t*%\*15s*\n"
		db	"\%\-\\*15s\t\t-\t*%-\*15s*\n"
		db	"\%^s\t\t-\t*%^s*\n"
		db	"\%15^s\t\t-\t*%15^s*\n"
		db	"\%-15^s\t\t-\t*%-15^s*\n"
		db	"\%\\*15^s\t\t-\t*%\*15^s*\n"
		db	"\%\-\\*15^s\t-\t*%-\*15^s*\n"
		db	0
		dd	s,s,s,s,s,ps,ps,ps,ps,ps
;
;****************************************************************************
;
; Test the input routines here.
;
		print
		db	"Testing GETC- Press any key: ",0
		getc
		print
		db	cr,lf,"You pressed: '",0
		putc
		print
		db	"' : ",0
		putw
		print
		db	cr,lf,"Testing GetcStdIn- Press any key:",0
		GetcStdIn
		print
		db	cr,lf,"You pressed: '",0
		putc
		print
		db	"' : ",0
		putw
		print
		db	cr,lf,"Testing GetcBIOS- Press any key:",0
		getcBIOS
		print
		db	cr,lf,"You pressed: '",0
		putc
		print
		db	"' : ",0
		putw
;
		print
		db	cr,lf,"Redirecting input, reading: ",0
		lesi	ReturnA
		SetInAdrs
		getc
		print
		db	cr,lf,"Getc returned: '",0
		putc
		print
		db	"' : ",0
		putw
		print
		db	cr,lf,"Pushing address, changing to 'B': ",0
		lesi	ReturnB
		PushInAdrs
		getc
		print
		db	cr,lf,"Getc returned: '",0
		putc
		print
		db	"' : ",0
		putw
		print
		db	cr,lf,"Popping address: ",0
		PopInAdrs
		cmp	di, offset ReturnB
		jne	BadPopIn
		mov	di, es
		cmp	di, seg ReturnB
		je	GoodPopIn
BadPopIn:	print
		db	cr,lf,"Did not return the proper address",cr,lf,0
GoodPopIn:	print
		db	cr,lf,"Popping address again, should read from kbd: "
		db	0
		PopInAdrs
		getc
		print
		db	cr,lf,"Getc returned: '",0
		putc
		print
		db	"' : ",0
		putw
		putcr
;
;****************************************************************************
;
; Test GETS here:
;
		print
		db	"Testing GETS, enter a line of text: ",0
		gets
		jnc	goodgets
		print
		db	"Bad gets call",cr,lf,0
;
goodgets:	print
		db	"You entered: ",0
		puts
		putcr
;
;
;***************************************************************************
;
;
;
Quit:		mov     ah, 4ch
		int     21h
;
;
Main		endp
;
;
dblchars	proc	far
		putcstdout
		putcstdout
		ret
dblchars	endp
;
;
ReturnA		proc	far
		mov	ax, "A"
		ret
ReturnA		endp
;
ReturnB		proc	far
		mov	ax, "B"
		ret
ReturnB		endp
;
;
; Printset- Prints the characters in the set passed in es:di
;
PrintSet	proc
		push	es
		push	ds
		push	di
		push	si
		push	dx
		push	ax
;
		mov	dx, es		;dx:si := es:di
		mov	si, di
;
		createsets
		copyset
PrLoop:		rmvitem
		cmp	al, 0
		jz	PrDone
		putc
		jmp	PrLoop
;
PrDone:		free
		pop	ax
		pop	dx
		pop	si
		pop	di
		pop	ds
		pop	es
		ret
PrintSet	endp
;
;
; Putfpacc- Prints the floating point accumulator:
;
Putfpacc	proc	near
		assume	ds:StdGrp
		push	ds
		push	ax
		mov	ax, StdGrp
		mov	ds, ax
		call	Putspace
		call	Putspace
		mov	al, StdGrp:fpacc
		puth
		call	Putspace
		mov	al, StdGrp:fpacc
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+1
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+2
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+3
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+4
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+5
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+6
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+7
		puth
		call	Putspace
		call	Putspace
		mov	al, StdGrp:fpacc+8
		puth
		call	Putspace
		mov	al, StdGrp:fpacc+9
		puth
		call	Putspace
		call	Putspace
		mov	al, StdGrp:fpacc+10
		puth
;
		pop	ax
		pop	ds
		ret
PutFpacc	endp
		assume	ds:dseg
;
PutSpace	proc	near
		push	ax
		mov	al, " "
		putc
		pop	ax
		ret
PutSpace	endp
;
cseg            ends
;
;
; Allocate a reasonable amount of space for the stack (2k).
;
sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends
;
;
;
; zzzzzzseg must be the last segment that gets loaded into memory!
;
zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
heap		db	1024 dup (?)
zzzzzzseg	ends
		end	Main
