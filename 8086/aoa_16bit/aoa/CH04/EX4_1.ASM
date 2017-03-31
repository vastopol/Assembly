; X86.ASM
;
; This is a special version of SHELL.ASM that includes macros for the x86 GET and PUT
; instructions.  It allows you to write x86 style programs for the 80x86.
;
; There are a few caveats.  
;
; First, you cannot use the HALT, BRK, or IRET instructions.
; BRK does not exist, HALT and IRET do not work the same way as they do on the x86
; hypothetical processors.
;
; Second, the memory-mapped I/O devices are not present (no switches, no LEDs).
;
; Third, use operands of the form "DS:[xxxx]" for the direct addressing mode.
; Without the "DS:" prefix, the instruction will not work the same way as the
; x86 instruction.
;
; Fourth, unlike the x86, this program uses separate segments for the code and
; data.  You cannot do self-modifying code like you did on the x86 assignments.
;
; Fifth, MASM lets you use labels that are just like the x86 labels with one exception:
; "C" is a reserved word in MASM so you cannot create a program label named "C".  MASM
; returns some bizarre error if you do.
;
; Sixth, you can use the x86 registers and addressing modes as well as the 80x86
; registers and addressing modes (8086 only). 


		include 	stdlib.a
		includelib	stdlib.lib

sseg		segment	para stack 'stack'
stk		byte	128 dup ("stack   ")
sseg		ends

dseg		segment para public 'data'
DataMemory	byte	65520 dup (?)
dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:cseg


; The following assembly language procedure simulates the x86 GET instruction.

get		textequ	<call Gethex>
GetHex		proc	near
		push	es
		push	bx
		push	di

GHLoop:		print
		byte	"Enter a hexadecimal number:",0
		getsm
		mov	bx, di
TestHex:	mov	al, es:[bx]
		inc	bx
		cmp	al, 0
		je	GoodHex
		IsXDigit
		je	TestHex
		print
		byte	"Illegal hexadecimal value, re-enter",cr,lf,0
		jmp	GHLoop

GoodHex:	AtoH
		free
		pop	di
		pop	bx
		pop	es
		ret
GetHex		endp

	

; The following assembly language procedure simulates the x86 PUT instruction.

put		textequ	<call PutHex>
PutHex		proc	near
		putw
		putcr
		ret
PutHex		endp



; This is where the main program goes.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


;*****************************************************************************************
;
; Insert your program between the two pair of asterisks below.
;
;*****************************************************************************************
;
;
; Note: "PRINT" is a standard library routine I've taken the liberty of using here.

		print
		byte	"Example Program #1",cr,lf,lf,0

		get
		mov	bx, ax
		get
		mov	cx, ax

		print
		byte	"Sum (in hex): ",0
		add	ax, bx
		put

		print
		byte	"Logical OR (in hex): ",0
		mov	ax, bx
		or	ax, cx
		put

		print
		byte	"Logical AND (in hex): ",0
		mov	ax, bx
		and	ax, cx
		put

		








;*****************************************************************************************


		ExitPgm
Main		endp

cseg		ends


zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
