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
;
; PRINTFF Routine
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
s		db	"printff string",0
MemAvail	dw	?
;
;
;
;
; Floating point values:
;
SPConst1	dd	1.0
SPConst10	dd	10.25
SPConst100	dd	100.50
SPConst1000	dd	1000.75
;
DPConst1	dq	1.0
DPConst10	dq	10.25
DPConst100	dq	100.50
DPConst1000	dq	1000.75
;
EPConst1	dt	1.0
EPConst10	dt	10.25
EPConst100	dt	100.50
EPConst1000	dt	1000.75
;
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
		printff
		db	"There are %x paragraphs of memory available."
		db	cr,lf,lf,0
		dd	MemAvail
;
;
;****************************************************************************
;
; Testing the printffF routine:
;
		printff
		db	"This is a test of the printff routine w/o any "
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
		printff
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
		printff
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
		printff
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
		printff
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
		printff
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
		printff
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
		printff
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
		printff
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
		printff
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
		printff
		db	"Testing printff floating point output",cr,lf
		db	"SP:    1.00 = %7.2f  %12e",cr,lf
		db	"SP:   10.25 = %7.2f  %12e",cr,lf
		db	"SP:  100.50 = %7.2f  %12e",cr,lf
		db	"SP: 1000.75 = %7.2f  %12e",cr,lf
		db	"DP:    1.00 = %7.2gf  %12ge",cr,lf
		db	"DP:   10.25 = %7.2gf  %12ge",cr,lf
		db	"DP:  100.50 = %7.2gf  %12ge",cr,lf
		db	"DP: 1000.75 = %7.2gf  %12ge",cr,lf
		db	"EP:    1.00 = %7.2lf  %13le",cr,lf
		db	"EP:   10.25 = %9.3lf  %14le",cr,lf
		db	"EP:  100.50 = %11.4lf  %15le",cr,lf
		db	"EP: 1000.75 = %13.5lf  %16le",cr,lf
		db	0
		dd      SPConst1, SPConst1, SPConst10, SPConst10
		dd	SPConst100, SPConst100, SPConst1000, SPConst1000
		dd      DPConst1, DPConst1, DPConst10, DPConst10
		dd	DPConst100, DPConst100, DPConst1000, DPConst1000
		dd      EPConst1, EPConst1, EPConst10, EPConst10
		dd	EPConst100, EPConst100, EPConst1000, EPConst1000
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
