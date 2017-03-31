; RUNDOS.ASM -	Demonstrates how to invoke a copy of the COMMAND.COM
;               DOS command line interpreter from your programs.

		include	stdlib.a
		includelib	stdlib.lib

dseg		segment	para public 'data'

; Variables used by this program.


; MS-DOS EXEC structure.

ExecStruct	dw	0			;Use parent's Environment blk.
		dd	CmdLine			;For the cmd ln parms.
		dd	DfltFCB
		dd	DfltFCB

DfltFCB		db	3,"           ",0,0,0,0,0
CmdLine		db	0, 0dh			;Cmd line for program.
PgmName		dd	filename		;Points at pgm name.
filename	byte	"c:\command.com",0

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


Main		proc
		mov	ax, dseg		;Get ptr to vars segment
		mov	ds, ax

		MemInit				;Start the memory mgr.




; Okay, we've built the MS-DOS execute structure and the necessary
; command line, now let's see about running the program.
; The first step is to free up all the memory that this program
; isn't using.  That would be everything from zzzzzzseg on.
;
; Note: unlike some previous examples in other chapters, it is okay
; to call Standard Library routines in this program after freeing
; up memory.  The difference here is that the Standard Library
; routines are loaded early in memory and we haven't free up the
; storage they are sitting in.

		mov	ah, 62h			;Get our PSP value
		int	21h
		mov	es, bx
		mov	ax, zzzzzzseg		;Compute size of
		sub	ax, bx			; resident run code.
		mov	bx, ax
		mov	ah, 4ah			;Release unused memory.
		int	21h


; Tell the user what is going on:

		print
		byte	cr,lf
		byte	"RUNDOS- Executing a copy of command.com",cr,lf
		byte	"Type 'EXIT' to return control to RUN.ASM",cr,lf
		byte	0

; Warning!  No Standard Library calls after this point.  We've just
; released the memory that they're sitting in.  So the program load
; we're about to do will wipe out the Standard Library code.

		mov	bx, seg ExecStruct
		mov	es, bx
		mov	bx, offset ExecStruct	;Ptr to program record.
		lds	dx, PgmName
		mov	ax, 4b00h		;Exec pgm
		int	21h

; In MS-DOS 6.0 the following code isn't required.  But in various older
; versions of MS-DOS, the stack is messed up at this point.  Just to be
; safe, let's reset the stack pointer to a decent place in memory.
;
; Note that this code preserves the carry flag and the value in the
; AX register so we can test for a DOS error condition when we are done
; fixing the stack.

		mov	bx, sseg
		mov	ss, ax
		mov	sp, offset EndStk
		mov	bx, seg dseg
		mov	ds, bx

; Test for a DOS error:

		jnc	GoodCommand
		print
		byte	"DOS error #",0
		puti
		print
		byte	" while attempting to run COMMAND.COM",cr,lf
		byte	0
		jmp	Quit


; Print a welcome back message.

GoodCommand:	print
		byte	"Welcome back to RUNDOS.  Hope you had fun.",cr,lf
		byte	"Now returning to MS-DOS' version of COMMAND.COM."
		byte	cr,lf,lf,0

; Return control to MS-DOS

Quit:		ExitPgm
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
		dw	128 dup (0)
endstk		dw	?
sseg		ends

; Set aside some room for the heap.

zzzzzzseg	segment	para public 'zzzzzzseg'
Heap		db	200h dup (?)
zzzzzzseg	ends
		end	Main
