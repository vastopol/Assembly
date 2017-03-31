; Transcnd.asm
;
; Some transcendental functions for the 80x87 FPU

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386
		.387
		option	segment:use16

dseg		segment	para public 'data'

result		real8	?

; Some variables we use to test the routines in this package:

cotvar		real8	3.0
cotRes		real8	?
acotRes		real8	?

cscvar		real8	1.5
cscRes		real8	?
acscRes		real8	?

secvar		real8	0.5
secRes		real8	?
asecRes		real8	?

sinvar		real8	0.75
sinRes		real8	?
asinRes		real8	?

cosvar		real8	0.25
cosRes		real8	?
acosRes		real8	?

Two2xvar	real8	-2.5
Two2xRes	real8	?
lgxRes		real8	?

Ten2xVar	real8	3.75
Ten2xRes	real8	?
logRes		real8	?

expVar		real8	3.25
expRes		real8	?
lnRes		real8	?

Y2Xx		real8	3.0
Y2Xy		real8	3.0
Y2XRes		real8	?


dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; COT(x) - computes the cotangent of st(0) and leaves result in st(0).
;	   st(0) contains x (in radians) and must be between
;		-2**63 and +2**63
;	   There must be at least one free register on the stack for this
;	   routine to operate properly.
;
;	cot(x) = 1/tan(x)

cot		proc	near
		fsincos
		fdivr
		ret
cot		endp

; CSC(x) - computes the cosecant of st(0) and leaves result in st(0).
;	   st(0) contains x (in radians) and must be between
;		-2**63 and +2**63.
;	   The cosecant of x is undefined for any value of sin(x) that
;		produces zero (e.g., zero or pi radians).
;	   There must be at least one free register on the stack for this
;	   routine to operate properly.
;
;	csc(x) = 1/sin(x)

csc		proc	near
		fsin
		fld1
		fdivr
		ret
csc		endp


; SEC(x) - computes the secant of st(0) and leaves result in st(0).
;	   st(0) contains x (in radians) and must be between
;		-2**63 and +2**63.
;	   The secant of x is undefined for any value of cos(x) that
;		produces zero (e.g., pi/2 radians).
;	   There must be at least one free register on the stack for this
;	   routine to operate properly.
;
;	sec(x) = 1/cos(x)

sec		proc	near
		fcos
		fld1
		fdivr
		ret
sec		endp


; ASIN(x)-	Computes the arcsine of st(0) and leaves the result in st(0).
;		Allowable range: -1<=x<=+1
;		There must be at least two free registers for this function
;		to operate properly.
;
;	asin(x) = atan(sqrt(x*x/(1-x*x)))

asin		proc	near
		fld	st(0)		;Duplicate X on tos.
		fmul			;Compute X**2.
		fld	st(0)		;Duplicate X**2 on tos.
		fld1			;Compute 1-X**2.
		fsubr
		fdiv			;Compute X**2/(1-X**2).
		fsqrt			;Compute sqrt(x**2/(1-X**2)).
		fld1			;To compute full arctangent.
		fpatan			;Compute atan of the above.
		ret
asin		endp


; ACOS(x)-	Computes the arccosine of st(0) and leaves the
;			result in st(0).
;		Allowable range: -1<=x<=+1
;		There must be at least two free registers for
;		this function to operate properly.
;
;	acos(x) = atan(sqrt((1-x*x)/(x*x)))

acos		proc	near
		fld	st(0)		;Duplicate X on tos.
		fmul			;Compute X**2.
		fld	st(0)		;Duplicate X**2 on tos.
		fld1			;Compute 1-X**2.
		fsubr
		fdivr			;Compute (1-x**2)/X**2.
		fsqrt			;Compute sqrt((1-X**2)/X**2).
		fld1			;To compute full arctangent.
		fpatan			;Compute atan of the above.
		ret
acos		endp


; ACOT(x)-	Computes the arccotangent of st(0) and leaves the
;			result in st(0).
;		X cannot equal zero.
;		There must be at least one free register for
;		this function to operate properly.
;
;	acot(x) = atan(1/x)

acot		proc	near
		fld1			;fpatan computes
		fxch			; atan(st(1)/st(0)).
		fpatan			; we want atan(st(0)/st(1)).
		ret
acot		endp


; ACSC(x)-	Computes the arccosecant of st(0) and leaves the
;			result in st(0).
;		abs(X) must be greater than one.
;		There must be at least two free registers for
;		this function to operate properly.
;
;	acsc(x) = atan(sqrt(1/(x*x-1)))

acsc		proc	near
		fld	st(0)		;Compute x*x
		fmul
		fld1			;Compute x*x-1
		fsub
		fld1			;Compute 1/(x*x-1)
		fdivr
		fsqrt			;Compute sqrt(1/(x*x-1))
		fld1
		fpatan			;Compute atan of above.
		ret
acsc		endp


; ASEC(x)-	Computes the arcsecant of st(0) and leaves the
;			result in st(0).
;		abs(X) must be greater than one.
;		There must be at least two free registers for
;		this function to operate properly.
;
;	asec(x) = atan(sqrt(x*x-1))

asec		proc	near
		fld	st(0)		;Compute x*x
		fmul
		fld1			;Compute x*x-1
		fsub
		fsqrt			;Compute sqrt(x*x-1)
		fld1
		fpatan			;Compute atan of above.
		ret
asec		endp


; TwoToX(x)-	Computes 2**x.
;		It does this by using the algebraic identity:
;
;		2**x = 2**int(x) * 2**frac(x).
;		We can easily compute 2**int(x) with fscale and
;		2**frac(x) using f2xm1.
;
;		This routine requires three free registers.

SaveCW		word	?
MaskedCW	word	?

TwoToX		proc	near
		fstcw	cseg:SaveCW

; Modify the control word to truncate when rounding.

		fstcw	cseg:MaskedCW
		or	byte ptr cseg:MaskedCW+1, 1100b
		fldcw	cseg:MaskedCW

		fld	st(0)		;Duplicate tos.
		fld	st(0)
		frndint			;Compute integer portion.

		fxch			;Swap whole and int values.
		fsub	st(0), st(1)	;Compute fractional part.

		f2xm1			;Compute 2**frac(x)-1.
		fld1
		fadd			;Compute 2**frac(x).

		fxch			;Get integer portion.
		fld1			;Compute 1*2**int(x).
		fscale
		fstp	st(1)		;Remove st(1) (which is 1).

		fmul			;Compute 2**int(x) * 2**frac(x).

		fldcw	cseg:SaveCW	;Restore rounding mode.
		ret
TwoToX		endp




; TenToX(x)-	Computes 10**x.
;
;		This routine requires three free registers.
;
; 	TenToX(x) = 2**(x * lg(10))


TenToX		proc	near
		fldl2t		;Put lg(10) onto the stack
		fmul		;Compute x*lg(10)
		call	TwoToX	;Compute 2**(x * lg(10)).
		ret
TenToX		endp



; exp(x)-	Computes e**x.
;		This routine requires three free registers.
;
;	exp(x) = 2**(x * lg(e))

exp		proc	near
		fldl2e		;Put lg(e) onto the stack.
		fmul		;Compute x*lg(e).
		call	TwoToX	;Compute 2**(x * lg(e))
		ret
exp		endp



; YtoX(y,x)-	Computes y**x (y=st(1), x=st(0)).
;		This routine requires three free registers.
;
;		Y must be greater than zero.
;
;	YtoX(y,x) = 2 ** (x * lg(y))

YtoX		proc	near
		fxch 		;Compute lg(y).
		fld1
		fxch
		fyl2x

		fmul		;Compute x*lg(y).
		call	TwoToX	;Compute 2**(x*lg(y)).
		ret
YtoX		endp




; LOG(x)-	Computes the base 10 logarithm of x.
;		Usual range for x (>0).
;
;	LOG(x) = lg(x)/lg(10).

log		proc	near
		fld1
		fxch
		fyl2x		;Compute 1*lg(x).
		fldl2t		;Load lg(10).
		fdiv		;Compute lg(x)/lg(10).
		ret
log		endp


; LN(x)-	Computes the base e logarithm of x.
;		X must be greater than zero.
;
;	ln(x) = lg(x)/lg(e).

ln		proc	near
		fld1
		fxch
		fyl2x		;Compute 1*lg(x).
		fldl2e		;Load lg(e).
		fdiv		;Compute lg(x)/lg(10).
		ret
ln		endp




; This main program tests the various functions in this package.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		finit


; Check to see if cot and acot are working properly.

		fld	cotVar
		call	cot
		fst	cotRes
		call	acot
		fstp	acotRes

		printff
		byte	"x=%8.5gf, cot(x)=%8.5gf, acot(cot(x)) = %8.5gf\n",0
		dword	cotVar, cotRes, acotRes


; Check to see if csc and acsc are working properly.

		fld	cscVar
		call	csc
		fst	cscRes
		call	acsc
		fstp	acscRes

		printff
		byte	"x=%8.5gf, csc(x)=%8.5gf, acsc(csc(x)) = %8.5gf\n",0
		dword	cscVar, cscRes, acscRes


; Check to see if sec and asec are working properly.

		fld	secVar
		call	sec
		fst	secRes
		call	asec
		fstp	asecRes

		printff
		byte	"x=%8.5gf, sec(x)=%8.5gf, asec(sec(x)) = %8.5gf\n",0
		dword	secVar, secRes, asecRes


; Check to see if sin and asin are working properly.

		fld	sinVar
		fsin
		fst	sinRes
		call	asin
		fstp	asinRes

		printff
		byte	"x=%8.5gf, sin(x)=%8.5gf, asin(sin(x)) = %8.5gf\n",0
		dword	sinVar, sinRes, asinRes


; Check to see if cos and acos are working properly.

		fld	cosVar
		fcos
		fst	cosRes
		call	acos
		fstp	acosRes

		printff
		byte	"x=%8.5gf, cos(x)=%8.5gf, acos(cos(x)) = %8.5gf\n",0
		dword	cosVar, cosRes, acosRes


; Check to see if 2**x and lg(x) are working properly.

		fld	Two2xVar
		call	TwoToX
		fst	Two2xRes
		fld1
		fxch
		fyl2x
		fstp	lgxRes

		printff
		byte	"x=%8.5gf, 2**x  =%8.5gf, lg(2**x)     = %8.5gf\n",0
		dword	Two2xVar, Two2xRes, lgxRes


; Check to see if 10**x and l0g(x) are working properly.

		fld	Ten2xVar
		call	TenToX
		fst	Ten2xRes
		call	LOG
		fstp	logRes

		printff
		byte	"x=%8.5gf, 10**x =%8.2gf, log(10**x)   = %8.5gf\n",0
		dword	Ten2xVar, Ten2xRes, logRes


; Check to see if exp(x) and ln(x) are working properly.

		fld	expVar
		call	exp
		fst	expRes
		call	ln
		fstp	lnRes

		printff
		byte	"x=%8.5gf, e**x  =%8.2gf, ln(e**x)     = %8.5gf\n",0
		dword	expVar, expRes, lnRes

; Check to see if y**x is working properly.

		fld	Y2Xy
		fld	Y2Xx
		call	YtoX
		fstp	Y2XRes

		printff
		byte	"x=%8.5gf, y     =%8.5gf, y**x         = %8.4gf\n",0
		dword	Y2Xx, Y2Xy, Y2XRes


Quit:		ExitPgm
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
