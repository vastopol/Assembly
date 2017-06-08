; XWPATCH.ASM
;
;	Usage:
;		XWPATCH	- must be in same directory as XWING.EXE
;
; This program executes the XWING.EXE program and patches it to avoid
; having to enter the password every time you run it.
;
; This program is intended for educational purposes only.
; It is a demonstration of how to write a semiresident program.
; It is not intended as a device to allow the piracy of commercial software.
; Such use is illegal and is punishable by law.
;
; This software is offered without warranty or any expectation of
; correctness.  Due to the dynamic nature of software design, programs
; that patch other programs may not work with slight changes in the
; patched program (XWING.EXE).  USE THIS CODE AT YOUR OWN RISK.
;
;----------------------------------------------------------------------------


byp		textequ	<byte ptr>
wp		textequ	<word ptr>

; Put these segment definitions here so the UCR Standard Library will
; load after zzzzzzseg (in the transient section).

cseg		segment para public 'CODE'
cseg		ends

sseg		segment	para stack 'STACK'
sseg		ends

zzzzzzseg	segment	para public 'zzzzzzseg'
zzzzzzseg	ends

		.286
		include		stdlib.a
		includelib	stdlib.lib
		matchfuncs


CSEG		segment	para public 'CODE'
		assume	cs:cseg, ds:nothing


; CountJSCalls-	Number of times xwing calls the Joystick code before
; we patch out the password call.

CountJSCalls	dw	250


; PSP-	Program Segment Prefix.  Needed to free up memory before running
;	the real application program.

PSP		dw	0



; Program Loading data structures (for DOS).

ExecStruct	dw	0			;Use parent's Environment blk.
		dd	CmdLine			;For the cmd ln parms.
		dd	DfltFCB
		dd	DfltFCB
LoadSSSP	dd	?
LoadCSIP	dd	?
PgmName		dd	Pgm

DfltFCB		db	3,"           ",0,0,0,0,0
CmdLine		db	2, "  ", 0dh, 16 dup (" ")	;Cmd line for program
Pgm		db	"XWING.EXE",0







;****************************************************************************
; XWPATCH begins here.  This is the memory resident part.  Only put code
; which which has to be present at run-time or needs to be resident after
; freeing up memory.
;****************************************************************************

Main		proc
		mov	cs:PSP, ds
		mov	ax, cseg		;Get ptr to vars segment
		mov	ds, ax

		mov	ax, zzzzzzseg
		mov	es, ax
		mov	cx, 1024/16
		meminit2


; Now, free up memory from ZZZZZZSEG on to make room for XWING.
; Note: Absolutely no calls to UCR Standard Library routines from
; this point forward! (ExitPgm is okay, it's just a macro which calls DOS.)
; Note that after the execution of this code, none of the code & data
; from zzzzzzseg on is valid.

		mov	bx, zzzzzzseg
		sub	bx, PSP
		inc	bx
		mov	es, PSP
		mov	ah, 4ah
		int	21h
		jnc	GoodRealloc

; Okay, I lied.  Here's a StdLib call, but it's okay because we failed
; to load the application over the top of the standard library code.
; But from this point on, absolutely no more calls!

		print
		byte	"Memory allocation error."
		byte	cr,lf,0
		jmp	Quit

GoodRealloc:

; Now load the XWING program into memory:

		mov	bx, seg ExecStruct
		mov	es, bx
		mov	bx, offset ExecStruct	;Ptr to program record.
		lds	dx, PgmName
		mov	ax, 4b01h		;Load, do not exec, pgm
		int	21h
		jc	Quit			;If error loading file.

; Unfortunately, the password code gets loaded dynamically later on.
; So it's not anywhere in memory where we can search for it.  But we
; do know that the joystick code is in memory, so we'll search for
; that code.  Once we find it, we'll patch it so it calls our SearchPW
; routine.  Note that you must use a joystick (and have one installed)
; for this patch to work properly.

		mov	si, zzzzzzseg
		mov	ds, si
		xor	si, si

		mov	di, cs
		mov	es, di
		mov	di, offset JoyStickCode
		mov	cx, JoyLength
		call	FindCode
		jc	Quit			;If didn't find joystick code.


; Patch the XWING joystick code here

		mov	byp ds:[si], 09ah	;Far call
		mov	wp ds:[si+1], offset SearchPW
		mov	wp ds:[si+3], cs

; Okay, start the XWING.EXE program running

		mov	ah, 62h			;Get PSP
		int	21h
		mov	ds, bx
		mov	es, bx
		mov	wp ds:[10], offset Quit
		mov	wp ds:[12], cs
		mov	ss, wp cseg:LoadSSSP+2
		mov	sp, wp cseg:LoadSSSP
		jmp	dword ptr cseg:LoadCSIP


Quit:		ExitPgm

Main		endp


; SearchPW gets call from XWING when it attempts to calibrate the joystick.
; We'll let XWING call the joystick several hundred times before we
; actually search for the password code.  The reason we do this is because
; XWING calls the joystick code early on to test for the presence of a
; joystick.  Once we get into the calibration code, however, it calls
; the joystick code repetitively, so a few hundred calls doesn't take
; very long to expire.  Once we're in the calibration code, the password
; code has been loaded into memory, so we can search for it then.

SearchPW	proc	far
		cmp	cs:CountJSCalls, 0
		je	DoSearch
		dec	cs:CountJSCalls
		sti			;Code we stole from xwing for
		neg	bx		; the patch.
		neg	di
		ret

; Okay, search for the password code.

DoSearch:	push	bp
		mov	bp, sp
		push	ds
		push	es
		pusha

; Search for the password code in memory:

		mov	si, zzzzzzseg
		mov	ds, si
		xor	si, si

		mov	di, cs
		mov	es, di
		mov	di, offset PasswordCode
		mov	cx, PWLength
		call	FindCode
		jc	NotThere		;If didn't find pw code.


; Patch the XWING password code here.  Just store NOPs over the five
; bytes of the far call to the password routine.

		mov	byp ds:[si+11], 090h	;NOP out a far call
		mov	byp ds:[si+12], 090h
		mov	byp ds:[si+13], 090h
		mov	byp ds:[si+14], 090h
		mov	byp ds:[si+15], 090h

; Adjust the return address and restore the patched joystick code so
; that it doesn't bother jumping to us anymore.

NotThere:	sub	word ptr [bp+2], 5	;Back up return address.
		les	bx, [bp+2]		;Fetch return address.

; Store the original joystick code over the call we patched to this
; routine.

		mov	ax, word ptr JoyStickCode
		mov	es:[bx], ax
		mov	ax, word ptr JoyStickCode+2
		mov	es:[bx+2], ax
		mov	al, byte ptr JoyStickCode+4
		mov	es:[bx+4], al

		popa
		pop	es
		pop	ds
		pop	bp
		ret
SearchPW	endp

;****************************************************************************
;
; FindCode: On entry, ES:DI points at some code in *this* program which
;	    appears in the XWING game.  DS:SI points at a block of memory
;	    in the XWING game.  FindCode searches through memory to find the
;	    suspect piece of code and returns DS:SI pointing at the start of
;	    that code.  This code assumes that it *will* find the code!
;	    It returns the carry clear if it finds it, set if it doesn't.

FindCode	proc	near
		push	ax
		push	bx
		push	dx

DoCmp:		mov	dx, 1000h		;Search in 4K blocks.
CmpLoop:  	push	di			;Save ptr to compare code.
		push	si			;Save ptr to start of string.
		push	cx			;Save count.
	repe	cmpsb
		pop	cx
		pop	si
		pop	di
		je	FoundCode
		inc	si
		dec	dx
		jne	CmpLoop
		sub	si, 1000h
		mov	ax, ds
		inc	ah
		mov	ds, ax
		cmp	ax, 9000h		;Stop at address 9000:0
		jb	DoCmp			; and fail if not found.

		pop	dx
		pop	bx
		pop	ax
		stc
		ret

FoundCode:	pop	dx
		pop	bx
		pop	ax
		clc
		ret
FindCode	endp


;****************************************************************************
;
; Call to password code that appears in the XWING game.  This is actually
; data that we're going to search for in the XWING object code.

PasswordCode	proc	near
		call	$+47h
		mov	[bp-4], ax
		mov	[bp-2], dx
		push	dx
		push	ax
		byte	9ah, 04h, 00
PasswordCode	endp
EndPW:

PWLength	=	EndPW-PasswordCode


; The following is the joystick code we're going to search for.

JoyStickCode	proc	near
		sti
		neg	bx
		neg	di
		pop	bp
		pop	dx
		pop	cx
		ret
		mov	bp, bx
		in	al, dx
		mov	bl, al
		not	al
		and	al, ah
		jnz	$+11h
		in	al, dx
JoyStickCode	endp
EndJSC:

JoyLength	=	EndJSC-JoyStickCode
cseg		ends

sseg		segment	para stack 'STACK'
		dw	256 dup (0)
endstk		dw	?
sseg		ends

zzzzzzseg	segment	para public 'zzzzzzseg'
Heap		db	1024 dup (0)
zzzzzzseg	ends

		end	Main
