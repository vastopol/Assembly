; MULTIDOS.ASM
;
; This program demonstrates how to use semaphores to protect DOS calls.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

DOSsmaph	semaphore	{}

; Macros to wait and release the DOS semaphore:

DOSWait		macro
		push	es
		push	di
		lesi	DOSsmaph
		WaitSemaph
		pop	di
		pop	es
		endm

DOSRls		macro
		push	es
		push	di
		lesi	DOSsmaph
		RlsSemaph
		pop	di
		pop	es
		endm




; PCB for our background process:

BkgndPCB	pcb	{0,offset EndStk2, seg EndStk2}

; Data the foreground and background processes print:

StrPtrs1	dword	str1_a, str1_b, str1_c, str1_d, str1_e, str1_f
		dword	str1_g, str1_h, str1_i, str1_j, str1_k, str1_l
		dword	0

str1_a		byte	"Foreground: string 'a'",cr,lf,0
str1_b		byte	"Foreground: string 'b'",cr,lf,0
str1_c		byte	"Foreground: string 'c'",cr,lf,0
str1_d		byte	"Foreground: string 'd'",cr,lf,0
str1_e		byte	"Foreground: string 'e'",cr,lf,0
str1_f		byte	"Foreground: string 'f'",cr,lf,0
str1_g		byte	"Foreground: string 'g'",cr,lf,0
str1_h		byte	"Foreground: string 'h'",cr,lf,0
str1_i		byte	"Foreground: string 'i'",cr,lf,0
str1_j		byte	"Foreground: string 'j'",cr,lf,0
str1_k		byte	"Foreground: string 'k'",cr,lf,0
str1_l		byte	"Foreground: string 'l'",cr,lf,0

StrPtrs2	dword	str2_a, str2_b, str2_c, str2_d, str2_e, str2_f
		dword	str2_g, str2_h, str2_i
		dword	0

str2_a		byte	"Background: string 'a'",cr,lf,0
str2_b		byte	"Background: string 'b'",cr,lf,0
str2_c		byte	"Background: string 'c'",cr,lf,0
str2_d		byte	"Background: string 'd'",cr,lf,0
str2_e		byte	"Background: string 'e'",cr,lf,0
str2_f		byte	"Background: string 'f'",cr,lf,0
str2_g		byte	"Background: string 'g'",cr,lf,0
str2_h		byte	"Background: string 'h'",cr,lf,0
str2_i		byte	"Background: string 'i'",cr,lf,0

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; A replacement critical error handler.  This routine calls prcsquit
; if the user decides to abort the program.


CritErrMsg	byte	cr,lf
		byte	"DOS Critical Error!",cr,lf
		byte	"A)bort, R)etry, I)gnore, F)ail? $"

MyInt24		proc	far
		push	dx
		push	ds
		push	ax

		push	cs
		pop	ds
Int24Lp:	lea	dx, CritErrMsg
		mov	ah, 9			;DOS print string call.
		int	21h

		mov	ah, 1			;DOS read character call.
		int	21h
		and	al, 5Fh			;Convert l.c. -> u.c.

		cmp	al, 'I'			;Ignore?
		jne	NotIgnore
		pop	ax
		mov	al, 0
		jmp	Quit24

NotIgnore:	cmp	al, 'r'			;Retry?
		jne	NotRetry
		pop	ax
		mov	al, 1
		jmp	Quit24

NotRetry:	cmp	al, 'A'			;Abort?
		jne	NotAbort
		prcsquit			;If quitting, fix INT 8.
		pop	ax
		mov	al, 2
		jmp	Quit24

NotAbort:	cmp	al, 'F'
		jne	BadChar
		pop	ax
		mov	al, 3
Quit24:		pop	ds
		pop	dx
		iret

BadChar:	mov	ah, 2
		mov	dl, 7			;Bell character
		jmp	Int24Lp
MyInt24		endp



; We will simply disable INT 23h (the break exception).

MyInt23		proc	far
		iret
MyInt23         endp



; This background process calls DOS to print several strings to the
; screen.  In the meantime, the foreground process is also printing
; strings to the screen.  To prevent reentry, or at least a jumble of
; characters on the screen, this code uses semaphores to protect the
; DOS calls.  Therefore, each process will print one complete line
; then release the semaphore.  If the other process is waiting it will
; print its line.

BackGround	proc
		mov	ax, dseg
		mov	ds, ax
		lea	bx, StrPtrs2		;Array of str ptrs.
PrintLoop:	cmp	word ptr [bx+2], 0	;At end of pointers?
		je	BkGndDone
		les	di, [bx]		;Get string to print.
		DOSWait
		puts				;Calls DOS to print string.
		DOSRls
		add	bx, 4			;Point at next str ptr.
		jmp	PrintLoop

BkGndDone:	die
BackGround	endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


; Initialize the INT 23h and INT 24h exception handler vectors.

		mov	ax, 0
		mov	es, ax
		mov	word ptr es:[24h*4], offset MyInt24
		mov	es:[24h*4 + 2], cs
		mov	word ptr es:[23h*4], offset MyInt23
		mov	es:[23h*4 + 2], cs

		prcsinit		;Start multitasking system.

		lesi	BkgndPCB	;Fire up a new process
		fork
		test	ax, ax		;Parent's return?
		je	ParentPrcs
		jmp	BackGround	;Go do backgroun stuff.

; The parent process will print a bunch of strings at the same time
; the background process is doing this.  We'll use the DOS semaphore
; to protect the call to DOS that PUTS makes.

ParentPrcs:     DOSWait				;Force the other process
		mov	cx, 0			; to wind up waiting in
DlyLp0:		loop	DlyLp0			; the semaphore queue by
DlyLp1:		loop	DlyLp1			; delay for at least one
DlyLp2:		loop	DlyLp2			; clock tick.
		DOSRls

		lea	bx, StrPtrs1		;Array of str ptrs.
PrintLoop:	cmp	word ptr [bx+2], 0	;At end of pointers?
		je	ForeGndDone
		les	di, [bx]		;Get string to print.
		DOSWait
		puts				;Calls DOS to print string.
		DOSRls
		add	bx, 4			;Point at next str ptr.
		jmp	PrintLoop

ForeGndDone:	prcsquit

Quit:		ExitPgm				;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'

; Here is the stack for the background process we start

stk2		byte	1024 dup (?)
EndStk2		word	?

;Here's the stack for the main program/foreground process.

stk		byte	1024 dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
