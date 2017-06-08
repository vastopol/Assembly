		page	58, 132
		name	RUN
		title	RUN (Executes a program specified on the cmd line).
		subttl	Copyright (C) 1992 Randall Hyde.

; RUN.EXE
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
; Modification history:
;
;	Date		Programmer
;		Changes made
;
;	8/21/92		R. Hyde
;
;      		This program began life as a Genovation keyboard/Windows
;		support tool.
;
;----------------------------------------------------------------------------
;
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


; Variables used by this program.  Okay, so I'm lazy and should have put
; them into their own segment.  However, you will not that I do not assume
; that these variables are in the code segment.

		public	PSP			;Needed by memory manager.
PSP		dw	?

ExecStruct	dw	0			;Use parent's Environment blk.
		dd	CmdLine			;For the cmd ln parms.
		dd	DfltFCB
		dd	DfltFCB

DfltFCB		db	3,"           ",0,0,0,0,0
CmdLine		db	0, 0dh, 126 dup (" ")	;Cmd line for program.
PgmName		dd	?			;Points at pgm name.


Main		proc
		mov	ax, cseg		;Get ptr to vars segment
		mov	es, ax
		mov	es:PSP, ds		;Save PSP value away
		mov	ds, ax

		mov	dx, 1			;Specify location and
		mov	cx, zzzzzzseg		; size of the heap.
		mov	es, cx
		mov	cx, 20h			;512 byte heap.
		MemInit				;Start the memory mgr.
		jnc	GoodMemInit
		print
		db	"Memory allocation error.",cr,lf,0
		jmp	Quit

GoodMemInit:

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

		mov	si, offset CmdLine+1	;Index into cmdline.
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

ExecutePgm:	mov	bx, seg ExecStruct
		mov	es, bx
		mov	bx, offset ExecStruct	;Ptr to program record.
		lds	dx,PgmName
		mov	ax, 4b00h		;Exec pgm
		int	21h

; When we get back, we can't count on *anything* being correct.  First, fix
; the stack pointer (for DOS 2.x, etc.) and then we can finish up the deed
; here.

		mov	ax, sseg
		mov	ss, ax
		mov	sp, offset EndStk
		mov	ax, seg cseg
		mov	ds, ax

; Okay, if you have any great deeds to do after the program, this is a
; good place to put such stuff.




; Return control to MS-DOS

Quit:		ExitPgm

Main		endp


cseg		ends



sseg		segment	para stack 'stack'
		dw	1024 dup (0)
endstk		dw	?
sseg		ends

; Seg aside some room for the heap.

zzzzzzseg	segment	para public 'zzzzzzseg'
		public	Heap
Heap		db	200h dup (?)
zzzzzzseg	ends

		end	Main
