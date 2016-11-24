		include		stdlib.a
		includelib 	stdlib.lib
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
;****************************************************************************
;
; T  E  S  T       S  U  I  T  E      F  O  R
;
;	Floating Point Routines in
;
; T H E   U C R     S  T  A  N  D  A  R  D
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
;
MemAvail	dw	?
;
Roundatof	dt	5.0e-19
;
; Floating point values:
;
SPConst1	dd	1.0
SPConst10	dd	-10.25
SPConst100	dd	100.50
SPConst1000	dd	-1000.75
SPConst10000	dd	10000.22
SPConst100000	dd	-100000.44
SPConst1000000	dd	1000000.66
SPConst123456	dd	-123456.88
SPConst65432	dd	65432.11
SPConst9876	dd	-9876.33
SPConst192	dd	192.55
SPConst38	dd	-38.77
SPConst9	dd	9.99
;
DPConst1	dq	1.0
DPConst10	dq	-10.25
DPConst100	dq	100.50
DPConst1000	dq	-1000.75
DPConst10000	dq	10000.22
DPConst100000	dq	-100000.44
DPConst1000000	dq	123456789012345678.66
DPConst123456	dq	-123456.88
DPConst65432	dq	65432.11
DPConst9876	dq	-9876.33
DPConst192	dq	192.55
DPConst38	dq	-38.77
DPConst9	dq	9.99
;
EPConst1	dt	1.0
EPConst10	dt	-10.25
EPConst100	dt	100.50
EPConst1000	dt	-1000.75
EPConst10000	dt	10000.22
EPConst100000	dt	-100000.44
EPConst1000000	dt	123456789012345678901.66
EPConst123456	dt	-123456.88
EPConst65432	dt	65432.11
EPConst9876	dt	-9876.33
EPConst192	dt	192.55
EPConst38	dt	-38.77
EPConst9	dt	9.99
;
Temp		dt	?
Output		db      128 dup (0)		;Tests ftoa/2
;
Testatof1	db	"1.2345678901234567890",0
Testatof2	db	"1.23456789",0
Testatof3	db	"123456789",0
Testatof4	db	"-1.0",0
Testatof5	db	"1.0e10",0
Testatof6	db	"-1.0e10",0
Testatof7	db	"1.0e-10",0
Testatof8	db	"-1.0e-10",0
Testatof9	db	"1234567890e-9",0
Testatof10	db	"1.0e0",0
Testatof11	db	"1.0e1",0
Testatof12	db	"1.0e2",0
Testatof13	db	"1.0e3",0
Testatof14	db	"1.0e4",0
Testatof15	db	"1.0e5",0
Testatof16	db	"1.0e7",0
Testatof17	db	"1.0e8",0
Testatof18	db	"1.0e9",0
Testatof19	db	"1.0e15",0
Testatof20	db	"1.0e16",0
Testatof21	db	"1.0e17",0
Testatof22	db	"1.0e31",0
Testatof23	db	"1.0e32",0
Testatof24	db	"1.0e33",0
Testatof25	db	"1.0e63",0
Testatof26	db	"1.0e64",0
Testatof27	db	"1.0e65",0
Testatof28	db	"1.0e127",0
Testatof29	db	"1.0e128",0
Testatof30	db	"1.0e129",0
Testatof31	db	"1.0e255",0
Testatof32	db	"1.0e256",0
Testatof33	db	"1.0e257",0
Testatof34	db	"1.0e511",0
Testatof35	db	"1.0e512",0
Testatof36	db	"1.0e513",0
Testatof37	db	"1.0e1023",0
Testatof38	db	"1.0e1024",0
Testatof39	db	"1.0e1025",0
Testatof40	db	"1.0e2048",0
;
Testatof41	db	"9.999999999999999e0",0
Testatof42	db	"9.999999999999999e1",0
Testatof43	db	"9.999999999999999e3",0
Testatof44	db	"9.999999999999999e7",0
Testatof45	db	"9.999999999999999e15",0
Testatof46	db	"9.999999999999999e31",0
Testatof47	db	"9.999999999999999e63",0
Testatof48	db	"9.999999999999999e127",0
Testatof49	db	"9.999999999999999e255",0
Testatof50	db	"9.999999999999999e511",0
Testatof51	db	"9.999999999999999e1023",0
Testatof52	db	"9.999999999999999e2047",0
;
mTestatof11	db	"1.0e-1",0
mTestatof12	db	"1.0e-2",0
mTestatof13	db	"1.0e-3",0
mTestatof14	db	"1.0e-4",0
mTestatof15	db	"1.0e-5",0
mTestatof16	db	"1.0e-7",0
mTestatof17	db	"1.0e-8",0
mTestatof18	db	"1.0e-9",0
mTestatof19	db	"1.0e-15",0
mTestatof20	db	"1.0e-16",0
mTestatof21	db	"1.0e-17",0
mTestatof22	db	"1.0e-31",0
mTestatof23	db	"1.0e-32",0
mTestatof24	db	"1.0e-33",0
mTestatof25	db	"1.0e-63",0
mTestatof26	db	"1.0e-64",0
mTestatof27	db	"1.0e-65",0
mTestatof28	db	"1.0e-127",0
mTestatof29	db	"1.0e-128",0
mTestatof30	db	"1.0e-129",0
mTestatof31	db	"1.0e-255",0
mTestatof32	db	"1.0e-256",0
mTestatof33	db	"1.0e-257",0
mTestatof34	db	"1.0e-511",0
mTestatof35	db	"1.0e-512",0
mTestatof36	db	"1.0e-513",0
mTestatof37	db	"1.0e-1023",0
mTestatof38	db	"1.0e-1024",0
mTestatof39	db	"1.0e-1025",0
mTestatof40	db	"1.0e-2048",0
;
mTestatof41	db	"9.999999999999999e-1",0
mTestatof42	db	"9.999999999999999e-2",0
mTestatof43	db	"9.999999999999999e-3",0
mTestatof44	db	"9.999999999999999e-5",0
mTestatof45	db	"9.999999999999999e-9",0
mTestatof46	db	"9.999999999999999e-17",0
mTestatof47	db	"9.999999999999999e-33",0
mTestatof48	db	"9.999999999999999e-65",0
mTestatof49	db	"9.999999999999999e-129",0
mTestatof50	db	"9.999999999999999e-257",0
mTestatof51	db	"9.999999999999999e-513",0
mTestatof52	db	"9.999999999999999e-1025",0
mTestatof53	db	"9.999999999999999e-2049",0
;
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
;
;***************************************************************************
;
; Test the floating point routines.
;
;
;
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
		db	"    -10.25 =",0
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
		db	"  -1000.75 =",0
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
		db	" -10000.44 =",0
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
		db	"-123456.88 =",0
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
		db	"  -9876.33 =",0
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
		db	"    -38.77 =",0
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
		db	"Testing SSFPA:",cr,lf,0
;
		lesi	SPConst1
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
		lsfpa
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst100
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
		lsfpa
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst10000
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
		lsfpa
		print
		db	" -10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst1000000
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
		lsfpa
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst65432
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
		lsfpa
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst192
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
		lsfpa
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst9
		lsfpa
		lesi	Temp
		ssfpa
		lefpal
		dt	0.0
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
		db	"    -10.25 =",0
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
		db	"  -1000.75 =",0
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
		db	" -10000.44 =",0
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
		db	"-123456.88 =",0
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
		db	"  -9876.33 =",0
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
		db	"    -38.77 =",0
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
;----
;
		print
		db	"Testing SDFPA:",cr,lf,0
;
		lesi	DPConst1
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
		ldfpa
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst100
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
		ldfpa
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst10000
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
		ldfpa
		print
		db	" -10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst1000000
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
		ldfpa
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst65432
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
		ldfpa
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst192
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
		ldfpa
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst9
		ldfpa
		lesi	Temp
		sdfpa
		lefpal
		dt	0.0
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
;------
;
		print
		db	"Testing lefpa:",cr,lf,0
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
		db	"    -10.25 =",0
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
		db	"  -1000.75 =",0
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
		db	" -10000.44 =",0
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
		db	"-123456.88 =",0
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
		db	"  -9876.33 =",0
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
		db	"    -38.77 =",0
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
;------
;
		print
		db	"Testing sefap:",cr,lf,0
;
		lesi	EPConst1
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
		lefpa
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst100
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
		lefpa
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst10000
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
		lefpa
		print
		db	" -10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst1000000
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
		lefpa
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst65432
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
		lefpa
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst192
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
		lefpa
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst9
		lefpa
		lesi	Temp
		sefpa
		lefpal
		dt	0.0
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
;-----
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
		dt	-10.25
		print
		db	"    -10.25 =",0
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
		dt	-1000.75
		print
		db	"  -1000.75 =",0
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
		dt	-100000.44
		print
		db	" -100000.44 =",0
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
		dt	-123456.88
		print
		db	"-123456.88 =",0
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
		dt	-9876.33
		print
		db	"  -9876.33 =",0
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
		dt	-38.77
		print
		db	"    -38.77 =",0
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
;
; Test loading the floating point operand register-
;
		print
		db	"Testing LSFPO (and XAccOp)",cr,lf,0
;
		lesi	SPConst1
		lsfpo
		XAccOp
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst10
		lsfpo
		XAccOp
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst100
		lsfpo
		XAccOp
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst1000
		lsfpo
		XAccOp
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst10000
		lsfpo
		XAccOp
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst100000
		lsfpo
		XAccOp
		print
		db	" -10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst1000000
		lsfpo
		XAccOp
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
		lsfpo
		XAccOp
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst65432
		lsfpo
		XAccOp
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst9876
		lsfpo
		XAccOp
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst192
		lsfpo
		XAccOp
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst38
		lsfpo
		XAccOp
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	SPConst9
		lsfpo
		XAccOp
		print
		db	"      9.99 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		putcr
		free
;
;----
;
		print
		db	"Testing LDFPO:",cr,lf,0
;
		lesi	DPConst1
		ldfpo
		XAccOp
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst10
		ldfpo
		XAccOp
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst100
		ldfpo
		XAccOp
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst1000
		ldfpo
		XAccOp
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst10000
		ldfpo
		XAccOp
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst100000
		ldfpo
		XAccOp
		print
		db	" -10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst1000000
		ldfpo
		XAccOp
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
		ldfpo
		XAccOp
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst65432
		ldfpo
		XAccOp
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst9876
		ldfpo
		XAccOp
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst192
		ldfpo
		XAccOp
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst38
		ldfpo
		XAccOp
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	DPConst9
		ldfpo
		XAccOp
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
;------
;
		print
		db	"Testing LEFPO:",cr,lf,0
;
		lesi	EPConst1
		lefpo
		XAccOp
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst10
		lefpo
		XAccOp
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst100
		lefpo
		XAccOp
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst1000
		lefpo
		XAccOp
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst10000
		lefpo
		XAccOp
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst100000
		lefpo
		XAccOp
		print
		db	" -10000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst1000000
		lefpo
		XAccOp
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
		lefpo
		XAccOp
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst65432
		lefpo
		XAccOp
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst9876
		lefpo
		XAccOp
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst192
		lefpo
		XAccOp
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst38
		lefpo
		XAccOp
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lesi	EPConst9
		lefpo
		XAccOp
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
;-----
;
		print
		db	"Testing LEFPOL:",cr,lf,0
;
		lefpol
		dt	1.0
		XAccOp
		print
		db	"       1.0 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	-10.25
		XAccOp
		print
		db	"    -10.25 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	100.50
		XAccOp
		print
		db	"    100.50 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	-1000.75
		XAccOp
		print
		db	"  -1000.75 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	10000.22
		XAccOp
		print
		db	"  10000.22 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	-100000.44
		XAccOp
		print
		db	" -100000.44 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	123456789012345678901.66
		XAccOp
		print
		db	"123456789012345678901.66 =",0
		mov	ax, 219h
		ftoam
		puts
		print
		db	"  Note: only 17 sig. digits.",cr,lf,0
		free
;
		lefpol
		dt	-123456.88
		XAccOp
		print
		db	"-123456.88 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	65432.11
		XAccOp
		print
		db	"  65432.11 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	-9876.33
		XAccOp
		print
		db	"  -9876.33 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	192.55
		XAccOp
		print
		db	"    192.55 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	-38.77
		XAccOp
		print
		db	"    -38.77 =",0
		mov	ax, 20bh
		ftoam
		puts
		putcr
		free
;
		lefpol
		dt	9.99
		XAccOp
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
;-----
;
;
;
;
;
; Test the arithmetic operations:
;
		print
		db	"Testing addition",cr,lf,0
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9999999999999999999
		lefpol
		dt	0.0000000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.999999999999999999
		lefpol
		dt	0.000000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.99999999999999999
		lefpol
		dt	0.00000000000000001
		fpadd
		mov	ax, 20bh
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9999999999999999
		lefpol
		dt	0.0000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.999999999999999
		lefpol
		dt	0.000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.99999999999999
		lefpol
		dt	0.00000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9999999999999
		lefpol
		dt	0.0000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.999999999999
		lefpol
		dt	0.000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.99999999999
		lefpol
		dt	0.00000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9999999999
		lefpol
		dt	0.0000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.999999999
		lefpol
		dt	0.000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.99999999
		lefpol
		dt	0.00000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9999999
		lefpol
		dt	0.0000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.999999
		lefpol
		dt	0.000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.99999
		lefpol
		dt	0.00001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9999
		lefpol
		dt	0.0001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.999
		lefpol
		dt	0.001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.99
		lefpol
		dt	0.01
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	1.9
		lefpol
		dt	0.1
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
		putcr
;
;---------
;
		print
		db	"More addition:",cr,lf,lf,0
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9999999999999999999
		lefpol
		dt	-0.0000000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.999999999999999999
		lefpol
		dt	-0.000000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.99999999999999999
		lefpol
		dt	-0.00000000000000001
		fpadd
		mov	ax, 20bh
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9999999999999999
		lefpol
		dt	-0.0000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.999999999999999
		lefpol
		dt	-0.000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.99999999999999
		lefpol
		dt	-0.00000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9999999999999
		lefpol
		dt	-0.0000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.999999999999
		lefpol
		dt	-0.000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.99999999999
		lefpol
		dt	-0.00000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9999999999
		lefpol
		dt	-0.0000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.999999999
		lefpol
		dt	-0.000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.99999999
		lefpol
		dt	-0.00000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9999999
		lefpol
		dt	-0.0000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.999999
		lefpol
		dt	-0.000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.99999
		lefpol
		dt	-0.00001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9999
		lefpol
		dt	-0.0001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.999
		lefpol
		dt	-0.001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.99
		lefpol
		dt	-0.01
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"-2.0 = ",0
		lefpal
		dt	-1.9
		lefpol
		dt	-0.1
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
		putcr
;
;----
;
		print
		db	"Yet more addition:",cr,lf,lf,0
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.0000000000000000001
		lefpol
		dt	-0.0000000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.000000000000000001
		lefpol
		dt	-0.000000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.00000000000000001
		lefpol
		dt	-0.00000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.0000000000000001
		lefpol
		dt	-0.0000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.000000000000001
		lefpol
		dt	-0.000000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.00000000000001
		lefpol
		dt	-0.00000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.0000000000001
		lefpol
		dt	-0.0000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.000000000001
		lefpol
		dt	-0.000000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.00000000001
		lefpol
		dt	-0.00000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt       2.0000000001
		lefpol
		dt	-0.0000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.000000001
		lefpol
		dt	-0.000000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.00000001
		lefpol
		dt	-0.00000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.0000001
		lefpol
		dt	-0.0000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.000001
		lefpol
		dt	-0.000001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.00001
		lefpol
		dt	-0.00001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.0001
		lefpol
		dt	-0.0001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.001
		lefpol
		dt	-0.001
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.01
		lefpol
		dt	-0.01
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
;
		print
		db	"2.0 = ",0
		lefpal
		dt	 2.1
		lefpol
		dt	-0.1
		fpadd
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
		putcr
;
;-----
;
		print
		db	"Simple subtraction test (sub is same as add)"
		db	cr,lf,lf,0
;
		print
		db	"2.9.. - 1.9.. = ",0
		lefpal
		dt	2.99999999999999999
		lefpol
		dt	1.99999999999999999
		fpsub
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
		print
		db	"1.9.. - 2.9.. = ",0
		lefpal
		dt	1.99999999999999999
		lefpol
		dt	2.99999999999999999
		fpsub
		mov	ax, 1418h
		ftoam
		puts
		free
		call	PutFPAcc
		putcr
		putcr
;
;----
;
		print
		db	"Testing Multiply...",cr,lf,lf,0
;
		mov	cx, 20
		lefpal
		dt	1.0
MultLoop:	lefpol
		dt	-10.0
		fpmul
		mov	ax, 24h
		etoam
		puts
		free
		call	PutFPAcc
		putcr
		loop	MultLoop
		putcr
;
;---
;
		print
		db	"More multiply tests...",cr,lf,lf,0
;
		lefpal
		dt	0.0000000000000000001
		mov	cx, 20
MultLoop2:	lefpol
		dt	-10.0
		fpmul
		mov	ax, 24h
		etoam
		puts
		free
		call	PutFPAcc
		putcr
		loop	MultLoop2
		putcr
;
;
;-----
;
		print
		db	"Some Division Tests:",cr,lf,lf,0
;
		mov	cx, 20
		lefpal
		dt	1.0e+15
DivLoop:	lefpol
		dt	-10.0
		fpdiv
		mov	ax, 24
		etoam
		puts
		free
		call	PutFPAcc
		putcr
		loop	DivLoop
		putcr
;
;
;---
;
		print
		db	"More Division Tests...",cr,lf,lf,0
;
		lefpal
		dt	1.0e-15
		mov	cx, 20
DivLoop2:	lefpol
		dt	-1.0e-1
		fpdiv
		mov	ax, 24
		etoam
		puts
		free
		call	PutFPAcc
		putcr
		loop	DivLoop2
		putcr
;
;
;------
;
		print
		db	"Testing FPCMP...",cr,lf,0
;
		lefpal
		dt	0.0
		lefpol
		dt	0.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql0
		print
		db	" 0.0 <> 0.0",cr,lf,0
		jmp	EndTest0
;
TheyreEql0:	print
		db	" 0.0 = 0.0",cr,lf,0
EndTest0:
;
		lefpal
		dt	1.0
		lefpol
		dt	0.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql1
		print
		db	" 1.0 <> 0.0",cr,lf,0
		jmp	EndTest1
;
TheyreEql1:	print
		db	" 1.0 = 0.0",cr,lf,0
EndTest1:
;
		lefpal
		dt	0.0
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql2
		print
		db	" 0.0 <> 1.0",cr,lf,0
		jmp	EndTest2
;
TheyreEql2:	print
		db	" 0.0 = 1.0",cr,lf,0
EndTest2:
;
		lefpal
		dt	-1.0
		lefpol
		dt	0.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql3
		print
		db	" -1.0 <> 0.0",cr,lf,0
		jmp	EndTest3
;
TheyreEql3:	print
		db	" -1.0 = 1.0",cr,lf,0
EndTest3:
;
		lefpal
		dt	0.0
		lefpol
		dt	-1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql4
		print
		db	" 0.0 <> -1.0",cr,lf,0
		jmp	EndTest4
;
TheyreEql4:	print
		db	" 0.0 = -1.0",cr,lf,0
EndTest4:
;
		lefpal
		dt	1.0
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql5
		print
		db	" 1.0 <> 1.0",cr,lf,0
		jmp	EndTest5
;
TheyreEql5:	print
		db	" 1.0 = 1.0",cr,lf,0
EndTest5:
;
		lefpal
		dt	-1.0
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql6
		print
		db	" -1.0 <> 1.0",cr,lf,0
		jmp	EndTest6
;
TheyreEql6:	print
		db	" -1.0 = 1.0",cr,lf,0
EndTest6:
;
		lefpal
		dt	-1.0
		lefpol
		dt	-1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql7
		print
		db	" -1.0 <> -1.0",cr,lf,0
		jmp	EndTest7
;
TheyreEql7:	print
		db	" -1.0 = -1.0",cr,lf,0
EndTest7:
;
		lefpal
		dt	0.5
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql8
		print
		db	" 0.5 <> 1.0",cr,lf,0
		jmp	EndTest8
;
TheyreEql8:	print
		db	" 0.5 = 1.0",cr,lf,0
EndTest8:
;
		lefpal
		dt	1.0
		lefpol
		dt	0.5
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEql9
		print
		db	" 1.0 <> 0.5",cr,lf,0
		jmp	EndTest9
;
TheyreEql9:	print
		db	" 1.0 = 0.5",cr,lf,0
EndTest9:
;
		lefpal
		dt	1.0
		lefpol
		dt	1.5
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEqla
		print
		db	" 1.0 <> 1.5",cr,lf,0
		jmp	EndTesta
;
TheyreEqla:	print
		db	" 1.0 = 1.5",cr,lf,0
EndTesta:
;
		lefpal
		dt	1.5
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(17) AX = ",0
		puti
		popf
		je	TheyreEqlb
		print
		db	" 1.5 <> 1.0",cr,lf,0
		jmp	EndTestb
;
TheyreEqlb:	print
		db	" 1.5 = 1.0",cr,lf,0
EndTestb:
;
		lefpal
		dt	1.00000000000000005
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(18) AX = ",0
		puti
		popf
		je	TheyreEqlc
		print
		db	" 1.00000000000000005 <> 1.0",cr,lf,0
		jmp	EndTestc
;
TheyreEqlc:	print
		db	" 1.00000000000000005 = 1.0",cr,lf,0
EndTestc:
;
		lefpal
		dt	1.000000000000000005
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(19) AX = ",0
		puti
		popf
		je	TheyreEqld
		print
		db	" 1.000000000000000005 <> 1.0",cr,lf,0
		jmp	EndTestd
;
TheyreEqld:	print
		db	" 1.000000000000000005 = 1.0",cr,lf,0
EndTestd:
;
		lefpal
		dt	1.0000000000000000005
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(20) AX = ",0
		puti
		popf
		je	TheyreEqle
		print
		db	" 1.0000000000000000005 <> 1.0",cr,lf,0
		jmp	EndTeste
;
TheyreEqle:	print
		db	" 1.0000000000000000005 = 1.0",cr,lf,0
EndTeste:
;
		lefpal
		dt	1.00000000000000000005
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(21) AX = ",0
		puti
		popf
		je	TheyreEqlf
		print
		db	" 1.00000000000000000005 <> 1.0",cr,lf,0
		jmp	EndTestf
;
TheyreEqlf:	print
		db	" 1.00000000000000000005 = 1.0",cr,lf,0
EndTestf:
;
		lefpal
		dt	1.000000000000000000005
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(22) AX = ",0
		puti
		popf
		je	TheyreEqlg
		print
		db	" 1.000000000000000000005 <> 1.0",cr,lf,0
		jmp	EndTestg
;
TheyreEqlg:	print
		db	" 1.000000000000000000005 = 1.0",cr,lf,0
EndTestg:
;
		lefpal
		dt	1.0000000000000000000005
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"(23) AX = ",0
		puti
		popf
		je	TheyreEqlh
		print
		db	" 1.0000000000000000000005 <> 1.0",cr,lf,0
		jmp	EndTesth
;
TheyreEqlh:	print
		db	" 1.0000000000000000000005 = 1.0",cr,lf,0
EndTesth:
;
		lefpal
		dt	1.0e10
		lefpol
		dt	1.0e100
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEqli
		print
		db	" 1.0e10 <> 1.0e100",cr,lf,0
		jmp	EndTesti
;
TheyreEqli:	print
		db	" 1.0e10 = 1.0e100",cr,lf,0
EndTesti:
;
		lefpal
		dt	1.0e100
		lefpol
		dt	1.0e10
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEqlj
		print
		db	" 1.0e100 <> 1.0e10",cr,lf,0
		jmp	EndTestj
;
TheyreEqlj:	print
		db	" 1.0e100 = 1.0e10",cr,lf,0
EndTestj:
;
;
		lefpal
		dt	1.0e-100
		lefpol
		dt	1.0e-10
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEqlk
		print
		db	" 1.0e-100 <> 1.0e-10",cr,lf,0
		jmp	EndTestk
;
TheyreEqlk:	print
		db	" 1.0e-100 = 1.0e-10",cr,lf,0
EndTestk:
;
		lefpal
		dt	1.0e-100
		lefpol
		dt	1.0e-100
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		je	TheyreEqll
		print
		db	" 1.0e-100 <> 1.0e-100",cr,lf,0
		jmp	EndTestl
;
TheyreEqll:	print
		db	" 1.0e-100 = 1.0e-100",cr,lf,0
EndTestl:
;
		lefpal
		dt	1.0
		lefpol
		dt	2.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		jge	TheyreEqlm
		print
		db	" 1.0 < 2.0",cr,lf,0
		jmp	EndTestm
;
TheyreEqlm:	print
		db	" 1.0 >= 2.0",cr,lf,0
EndTestm:
;
		lefpal
		dt	1.0
		lefpol
		dt	2.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		jg	TheyreEqln
		print
		db	" 1.0 <= 2.0",cr,lf,0
		jmp	EndTestn
;
TheyreEqln:	print
		db	" 1.0 > 2.0",cr,lf,0
EndTestn:
;
		lefpal
		dt	1.0
		lefpol
		dt	2.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		jle	TheyreEqlo
		print
		db	" 1.0 > 2.0",cr,lf,0
		jmp	EndTesto
;
TheyreEqlo:	print
		db	" 1.0 <= 2.0",cr,lf,0
EndTesto:
;
		lefpal
		dt	2.0
		lefpol
		dt	1.0
		fpcmp
		pushf
		print
		db	"AX = ",0
		puti
		popf
		jle	TheyreEqlp
		print
		db	" 2.0 > 1.0",cr,lf,0
		jmp	EndTestp
;
TheyreEqlp:	print
		db	" 2.0 <= 1.0",cr,lf,0
EndTestp:
		putcr
		putcr
;
;
;
;
;
;
;
;----------
;
		print
		db	"Testing FTOAM...",cr,lf,0
;
		print
		db	"Printing various forms of 1.12345678901234567890"
		db	cr,lf,"Remember only 17 significant digits get printed"
		db	cr,lf,0
		lefpal
		dt	1.12345678901234567890
		mov	cx, 20
DigitsLoop:	mov	ah, cl
		mov	al, 24
		ftoam
		puts
		free
		putcr
		loop	DigitsLoop
;
		print
		db	cr,lf,"Testing FTOA...",cr,lf,0
		mov	cx, 20
DigitsLoop2:	mov	ah, cl
		mov	al, 24
		lesi	Output
		ftoa
		puts
		putcr
		loop	DigitsLoop2
;
		print
		db	cr,lf,"Testing FTOA2 (  1.00  1.00)",cr,lf,'"',0
		lefpal
		dt	1.0
		lesi	Output
		mov	ax,206h
		ftoa2
		ftoa2
		lesi	Output
		puts
		mov	al, '"'
		putc
		putcr
;
;
;
;----------
;
		print
		db	cr,lf
		db	"Testing ETOAM...",cr,lf,0
;
		print
		db	"Printing various forms of 1.12345678901234567890"
		db	cr,lf,"Remember only 17 significant digits get printed"
		db	cr,lf,0
		lefpal
		dt	1.12345678901234567890
		mov	cx, 20
DigitsLoop3:	mov	al, cl
		add	al, 8
		etoam
		puts
		free
		putcr
		loop	DigitsLoop3
;
		print
		db	cr,lf,"Testing ETOA...",cr,lf,0
		mov	cx, 20
DigitsLoop4:	mov	al, cl
		add	al, 8
		puth
		print
		db	": ",0
		lesi	Output
		etoa
		puts
		putcr
		loop	DigitsLoop4
;
		print
		db	cr,lf,"Testing ETOA2",cr,lf,'"',0
		lefpal
		dt	1.0
		lesi	Output
		mov	ax,20ah
		etoa2
		etoa2
		lesi	Output
		puts
		mov	al, '"'
		putc
		putcr
;
;
;------
;
Testatof	macro	op
		lesi	op
		puts
		print
		db	" = ",0
		atof
		ftoam
		mov	al, 32
		etoam
		puts
		putcr
		endm
;
;
		print
		db	cr,lf,"Testing ATOF...",cr,lf,lf,0
;
		Testatof	Testatof1
		Testatof	Testatof2
		Testatof	Testatof3
		Testatof	Testatof4
		Testatof	Testatof5
		Testatof	Testatof6
		Testatof	Testatof7
		Testatof	Testatof8
		Testatof	Testatof9
		Testatof	Testatof10
		Testatof	Testatof11
		Testatof	Testatof12
		Testatof	Testatof13
		Testatof	Testatof14
		Testatof	Testatof15
		Testatof	Testatof16
		Testatof	Testatof17
		Testatof	Testatof18
		Testatof	Testatof19
		Testatof	Testatof20
		Testatof	Testatof21
		Testatof	Testatof22
		Testatof	Testatof23
		Testatof	Testatof24
		Testatof	Testatof25
		Testatof	Testatof26
		Testatof	Testatof27
		Testatof	Testatof28
		Testatof	Testatof29
		Testatof	Testatof30
		Testatof	Testatof31
		Testatof	Testatof32
		Testatof	Testatof33
		Testatof	Testatof34
		Testatof	Testatof35
		Testatof	Testatof36
		Testatof	Testatof37
		Testatof	Testatof38
		Testatof	Testatof39
		Testatof	Testatof40
		Testatof	Testatof41
		Testatof	Testatof42
		Testatof	Testatof43
		Testatof	Testatof44
		Testatof	Testatof45
		Testatof	Testatof46
		Testatof	Testatof47
		Testatof	Testatof48
		Testatof	Testatof49
		Testatof	Testatof50
		Testatof	Testatof51
		Testatof	Testatof52
;
		putcr
;
		Testatof	mTestatof11
		Testatof	mTestatof12
		Testatof	mTestatof13
		Testatof	mTestatof14
		Testatof	mTestatof15
		Testatof	mTestatof16
		Testatof	mTestatof17
		Testatof	mTestatof18
		Testatof	mTestatof19
		Testatof	mTestatof20
		Testatof	mTestatof21
		Testatof	mTestatof22
		Testatof	mTestatof23
		Testatof	mTestatof24
		Testatof	mTestatof25
		Testatof	mTestatof26
		Testatof	mTestatof27
		Testatof	mTestatof28
		Testatof	mTestatof29
		Testatof	mTestatof30
		Testatof	mTestatof31
		Testatof	mTestatof32
		Testatof	mTestatof33
		Testatof	mTestatof34
		Testatof	mTestatof35
		Testatof	mTestatof36
		Testatof	mTestatof37
		Testatof	mTestatof38
		Testatof	mTestatof39
		Testatof	mTestatof40
		Testatof	mTestatof41
		Testatof	mTestatof42
		Testatof	mTestatof43
		Testatof	mTestatof44
		Testatof	mTestatof45
		Testatof	mTestatof46
		Testatof	mTestatof47
		Testatof	mTestatof48
		Testatof	mTestatof49
		Testatof	mTestatof50
		Testatof	mTestatof51
		Testatof	mTestatof52
		Testatof	mTestatof53
		putcr
		putcr
;
;
;
;---------
;
		print
		db	"Testing FTOI...",cr,lf,lf,0
;
		lefpal
		dt	1.0
		ftoi
		print
		db	"1.0 = ",0
		puti
;
		lefpal
		dt	10.0
		ftoi
		print
		db	cr,lf,"10.0 = ",0
		puti
;
		lefpal
		dt	100.0
		ftoi
		print
		db	cr,lf,"100.0 = ",0
		puti
;
		lefpal
		dt	1000.0
		ftoi
		print
		db	cr,lf,"1000.0 = ",0
		puti
;
		lefpal
		dt	10000.0
		ftoi
		print
		db	cr,lf,"10000.0 = ",0
		puti
;
		lefpal
		dt	32767.0
		ftoi
		print
		db	cr,lf,"32767.0 = ",0
		puti
;
		lefpal
		dt	0.0
		ftoi
		print
		db	cr,lf,"0.0 = ",0
		puti
;
		lefpal
		dt	-1.0
		ftoi
		print
		db	cr,lf,"-1.0 = ",0
		puti
;
		lefpal
		dt	-10.0
		ftoi
		print
		db	cr,lf,"-10.0 = ",0
		puti
;
		lefpal
		dt	-100.0
		ftoi
		print
		db	cr,lf,"-100.0 = ",0
		puti
;
		lefpal
		dt	-1000.0
		ftoi
		print
		db	cr,lf,"-1000.0 = ",0
		puti
;
		lefpal
		dt	-10000.0
		ftoi
		print
		db	cr,lf,"-10000.0 = ",0
		puti
;
		lefpal
		dt	-32768.0
		ftoi
		print
		db	cr,lf,"-32768.0 = ",0
		puti
;
;
;---------
;
		print
		db	cr,lf,lf,"Testing FTOU...",cr,lf,lf,0
;
		lefpal
		dt	1.0
		ftou
		print
		db	"1.0 = ",0
		putu
;
		lefpal
		dt	10.0
		ftou
		print
		db	cr,lf,"10.0 = ",0
		putu
;
		lefpal
		dt	100.0
		ftou
		print
		db	cr,lf,"100.0 = ",0
		putu
;
		lefpal
		dt	1000.0
		ftou
		print
		db	cr,lf,"1000.0 = ",0
		putu
;
		lefpal
		dt	10000.0
		ftou
		print
		db	cr,lf,"10000.0 = ",0
		putu
;
		lefpal
		dt	65535.0
		ftou
		print
		db	cr,lf,"65535.0 = ",0
		putu
;
		lefpal
		dt	0.0
		ftou
		print
		db	cr,lf,"0.0 = ",0
		putu
;
;
;---------
;
		print
		db	cr,lf,lf,"Testing FTOL...",cr,lf,lf,0
;
		lefpal
		dt	1.0
		ftol
		print
		db	"1.0 = ",0
		putl
		print
		db	"  ",0
		xchg	dx, ax
		putw
		xchg	dx, ax
		putw
;
		lefpal
		dt	10.0
		ftol
		print
		db	cr,lf,"10.0 = ",0
		putl
;
		lefpal
		dt	100.0
		ftol
		print
		db	cr,lf,"100.0 = ",0
		putl
;
		lefpal
		dt	1000.0
		ftol
		print
		db	cr,lf,"1000.0 = ",0
		putl
;
		lefpal
		dt	10000.0
		ftol
		print
		db	cr,lf,"10000.0 = ",0
		putl
;
		lefpal
		dt	32767.0
		ftol
		print
		db	cr,lf,"32767.0 = ",0
		putl
;
		lefpal
		dt	32768.0
		ftol
		print
		db	cr,lf,"32768.0 = ",0
		putl
;
		lefpal
		dt	65535.0
		ftol
		print
		db	cr,lf,"65535.0 = ",0
		putl
;
		lefpal
		dt	65536.0
		ftol
		print
		db	cr,lf,"65536.0 = ",0
		putl
;
		lefpal
		dt	100000.0
		ftol
		print
		db	cr,lf,"100000.0 = ",0
		putl
;
		lefpal
		dt	1000000.0
		ftol
		print
		db	cr,lf,"1000000.0 = ",0
		putl
;
		lefpal
		dt	2.0e9
		ftol
		print
		db	cr,lf,"2e9 = ",0
		putl
;
		lefpal
		dt	0.0
		ftol
		print
		db	cr,lf,"0.0 = ",0
		putl
;
		lefpal
		dt	-1.0
		ftol
		print
		db	cr,lf,"-1.0 = ",0
		putl
;
		lefpal
		dt	-10.0
		ftol
		print
		db	cr,lf,"-10.0 = ",0
		putl
;
		lefpal
		dt	-100.0
		ftol
		print
		db	cr,lf,"-100.0 = ",0
		putl
;
		lefpal
		dt	-1000.0
		ftol
		print
		db	cr,lf,"-1000.0 = ",0
		putl
;
		lefpal
		dt	-10000.0
		ftol
		print
		db	cr,lf,"-10000.0 = ",0
		putl
;
		lefpal
		dt	-32768.0
		ftol
		print
		db	cr,lf,"-32768.0 = ",0
		putl
;
;
;
;---------
;
		print
		db	cr,lf,lf,"Testing FTOUL...",cr,lf,lf,0
;
		lefpal
		dt	1.0
		ftoul
		print
		db	"1.0 = ",0
		putul
;
		lefpal
		dt	10.0
		ftoul
		print
		db	cr,lf,"10.0 = ",0
		putul
;
		lefpal
		dt	100.0
		ftoul
		print
		db	cr,lf,"100.0 = ",0
		putul
;
		lefpal
		dt	1000.0
		ftoul
		print
		db	cr,lf,"1000.0 = ",0
		putul
;
		lefpal
		dt	10000.0
		ftoul
		print
		db	cr,lf,"10000.0 = ",0
		putul
;
		lefpal
		dt	32767.0
		ftoul
		print
		db	cr,lf,"32767.0 = ",0
		putul
;
		lefpal
		dt	32768.0
		ftoul
		print
		db	cr,lf,"32768.0 = ",0
		putul
;
		lefpal
		dt	65535.0
		ftoul
		print
		db	cr,lf,"65535.0 = ",0
		putul
;
		lefpal
		dt	65536.0
		ftoul
		print
		db	cr,lf,"65536.0 = ",0
		putul
;
		lefpal
		dt	100000.0
		ftoul
		print
		db	cr,lf,"100000.0 = ",0
		putul
;
		lefpal
		dt	1000000.0
		ftoul
		print
		db	cr,lf,"1000000.0 = ",0
		putul
;
		mov	ax, 0ffffh
		mov	dx, 07fffh
		ultof
		ftoul
		print
		db	cr,lf,"2^31-1 = ",0
		putul
;
;
		mov	ax, 0ffffh
		mov	dx, ax
		ultof
		ftoul
		print
		db	cr,lf,"2^32-1 = ",0
		putul
;
		lefpal
		dt	0.0
		ftoul
		print
		db	cr,lf,"0.0 = ",0
		putul
;
;
;
;
;
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
