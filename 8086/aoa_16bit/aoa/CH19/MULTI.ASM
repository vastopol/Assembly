; Simple program to demonstrate the use of multitasking.


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

ChildPID	word	0
BackGndCnt	word	0

; PCB for our background process:

BkgndPCB	pcb	{0,offset EndStk2, seg EndStk2}

; Data buffer to hold an input string.

InputLine	byte	128 dup (0)

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



; Okay, this is a pretty weak background process, but it does demonstrate
; how to use the Standard Library calls.

BackGround	proc
		sti
		mov	ax, dseg
		mov	ds, ax
		inc	BackGndCnt		;Bump call Counter by one.
		yield				;Give CPU back to foregnd.
		jmp	BackGround
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

ParentPrcs:	mov	ChildPID, bx	;Save child process ID.

		print
		byte	"I am timing you while you enter a string. So type"
		byte	cr,lf
		byte	"quickly: ",0

		lesi	InputLine
		gets

		mov	ax, ChildPID	;Stop the child from running.
		kill

		printf
		byte	"While entering '%s' you took %d clock ticks"
		byte	cr,lf,0
		dword	InputLine, BackGndCnt

		prcsquit

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'

; Here is the stack for the background process we start

stk2		byte	256 dup (?)
EndStk2		word	?

;Here's the stack for the main program/foreground process.

stk		byte	1024 dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
