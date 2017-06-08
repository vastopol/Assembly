; EX14_1.asm
;
; This program runs some tests to determine how well the floating point
; arithmetic in the Standard Library compares with the floating point
; arithmetic on the 80x87.  It does this performing various operations
; using both methods and comparing the result.
;
; Of course, you must have an 80x87 FPU (or 80486 or later processor)
; in order to run this code.


		.386
		option		segment:use16

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

; Since this is an accuracy test, this code uses REAL8 values for
; all operations

slValue1	real8	1.0
slSmallVal	real8	1.0e-14
slResult	real8	?

Value1		real8	1.0
SmallVal	real8	1.0e-14
Result		real8	?

Buffer		byte	20 dup (0)

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		finit			;Initialize the FPU

; Do 10,000,000 floating point additions:


		printff
		byte	"Adding 10,000,000 FP values together with the FPU",cr,lf,0

		mov	ecx, 10000000
FPLoop:		fld	Value1
		fld	SmallVal
		fadd
		fstp	Value1
		dec	ecx
		jnz	FPLoop

		printff
		byte	"Result = %20GE\n",cr,lf,0
		dword	Value1	

; Do 10,000,000 floating point additions with the Standard Library fpadd routine:

		printff
		byte	cr,lf
		byte	"Adding 10,000,000 FP values together with the StdLib"
		byte	cr,lf
		byte	"Note: this may take a few minutes to run, don't get "
		byte	"too impatient"
		byte	cr,lf,0

		mov	ecx, 10000000
SLLoop:		lesi	slValue1
		ldfpa
		lesi	slSmallVal
		ldfpo
		fpadd
		lesi	slValue1
		sdfpa
		dec	ecx
		jnz	SLLoop

		printff
		byte	"Result = %20GE\n",cr,lf,0
		dword	slValue1	

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
