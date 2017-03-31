; RUN.ASM - The barebones semiresident program.
;
;	Usage:
;		RUN  <program.exe>  <program's command line>
;	  or	RUN  <program.com>  <program's command line>
;
; RUN executes the specified program with the supplied command line parameters.
; At first, this may seem like a stupid program.  After all, why not just run
; the program directly from DOS and skip the RUN altogether?  Actually, there
; is a good reason for RUN-- It lets you (by modifying the RUN source file)
; set up some environment prior to running the program and clean up that
; environment after the program terminates ("environment" in this sense does
; not necessarily refer to the MS-DOS ENVIRONMENT area).
;
; For example, I have used this program to switch the mode of a TSR prior to
; executing an EXE file and then I restored the operating mode of that TSR
; after the program terminated.
;
; In general, you should create a new version of RUN.EXE (and, presumbably,
; give it a unique name) for each application you want to use this program
; with.
;
;
;----------------------------------------------------------------------------
;
;
; Put these segment definitions 1st because we want the Standard Library
; routines to load last in memory, so they wind up in the transient portion.

CSEG		segment	para public 'CODE'
CSEG		ends
SSEG		segment	para stack 'stack'
SSEG		ends
ZZZZZZSEG	segment	para public 'zzzzzzseg'
ZZZZZZSEG	ends


; Includes for UCR Standard Library macros.

		include	consts.a
		include stdin.a
		include stdout.a
		include misc.a
		include memory.a
		include	strings.a

		includelib stdlib.lib


CSEG		segment	para public 'CODE'
		assume	cs:cseg, ds:cseg


; Variables used by this program.


; MS-DOS EXEC structure.

ExecStruct	dw	0			;Use parent's Environment blk.
		dd	CmdLine			;For the cmd ln parms.
		dd	DfltFCB
		dd	DfltFCB

DfltFCB		db	3,"           ",0,0,0,0,0
CmdLine		db	0, 0dh, 126 dup (" ")	;Cmd line for program.
PgmName		dd	?			;Points at pgm name.




Main		proc
		mov	ax, cseg		;Get ptr to vars segment
		mov	ds, ax

		MemInit				;Start the memory mgr.



; If you want to do something before the execution of the command-line
; specified program, here is a good place to do it:



;	-------------------------------------



; Now let's fetch the program name, etc., from the command line and execute
; it.

		argc				;See how many cmd ln parms
		or	cx, cx			; we have.
		jz	Quit			;Just quit if no parameters.

		mov	ax, 1			;Get the first parm (pgm name)
		argv
		mov	word ptr PgmName, di	;Save ptr to name
		mov	word ptr PgmName+2, es


; Okay, for each word on the command line after the filename, copy
; that word to CmdLine buffer and separate each word with a space,
; just like COMMAND.COM does with command line parameters it processes.

		lea	si, CmdLine+1		;Index into cmdline.
ParmLoop:	dec	cx
		jz	ExecutePgm

		inc	ax			;Point at next parm.
		argv				;Get the next parm.

		push	ax
		mov	byte ptr [si], ' '	;1st item and separator on ln.
		inc	CmdLine
		inc	si
CpyLp:		mov	al, es:[di]
		cmp	al, 0
		je	StrDone
		inc	CmdLine			;Increment byte cnt
		mov	ds:[si], al
		inc	si
		inc	di
		jmp	CpyLp

StrDone:	mov	byte ptr ds:[si], cr	;In case this is the end.
		pop	ax			;Get current parm #
		jmp	ParmLoop


; Okay, we've built the MS-DOS execute structure and the necessary
; command line, now let's see about running the program.
; The first step is to free up all the memory that this program
; isn't using.  That would be everything from zzzzzzseg on.

ExecutePgm:     mov	ah, 62h			;Get our PSP value
		int	21h
		mov	es, bx
		mov	ax, zzzzzzseg		;Compute size of
		sub	ax, bx			; resident run code.
		mov	bx, ax
		mov	ah, 4ah			;Release unused memory.
		int	21h

; Warning!  No Standard Library calls after this point.  We've just
; released the memory that they're sitting in.  So the program load
; we're about to do will wipe out the Standard Library code.

		mov	bx, seg ExecStruct
		mov	es, bx
		mov	bx, offset ExecStruct	;Ptr to program record.
		lds	dx, PgmName
		mov	ax, 4b00h		;Exec pgm
		int	21h

; When we get back, we can't count on *anything* being correct.  First, fix
; the stack pointer and then we can finish up anything else that needs to
; be done.

		mov	ax, sseg
		mov	ss, ax
		mov	sp, offset EndStk
		mov	ax, seg cseg
		mov	ds, ax

; Okay, if you have any great deeds to do after the program, this is a
; good place to put such stuff.

;	-------------------------------------

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
