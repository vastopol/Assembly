; SHARDMEM.ASM
;
; This TSR sets aside a 64K shared memory region for other processes to use.
;
; Usage:
;
;	SHARDMEM		- Loads resident portion and activates
;				  shared memory capabilities.
;
;	SHARDMEM REMOVE		- Removes shared memory TSR from memory.
;
; This TSR checks to make sure there isn't a copy already active in
; memory.  When removing itself from memory, it makes sure there are
; no other interrupts chained into INT 2Fh before doing the remove.
;
;
;
; The following segments must appear in this order and before the
; Standard Library includes.

ResidentSeg	segment	para public 'Resident'
ResidentSeg	ends

SharedMemory	segment	para public 'Shared'
SharedMemory	ends

EndResident	segment	para public 'EndRes'
EndResident	ends

		.xlist
		.286
		include 	stdlib.a
		includelib	stdlib.lib
		.list


; Resident segment that holds the TSR code:

ResidentSeg	segment	para public 'Resident'
		assume	cs:ResidentSeg, ds:nothing

; Int 2Fh ID number for this TSR:

MyTSRID		byte	0
		byte	0		;Padding so we can print it.

; PSP is the psp address for this program.

PSP		word	0

OldInt2F	dword	?


; MyInt2F-	Provides int 2Fh (multiplex interrupt) support for this
;		TSR.  The multiplex interrupt recognizes the following
;		subfunctions (passed in AL):
;
;		00h- Verify presence.  	Returns 0FFh in AL and a pointer
;					to an ID string in es:di if the
;					TSR ID (in AH) matches this
;					particular TSR.
;
;		01h- Remove.		Removes the TSR from memory.
;					Returns 0 in AL if successful,
;					1 in AL if failure.
;
;		10h- Return Seg Adrs.	Returns the segment address of the
;					shared segment in ES.

MyInt2F		proc	far
		assume	ds:nothing

		cmp	ah, MyTSRID	;Match our TSR identifier?
		je	YepItsOurs
		jmp	OldInt2F

; Okay, we know this is our ID, now check for a verify, remove, or
; return segment call.

YepItsOurs:	cmp	al, 0		;Verify Call
		jne	TryRmv
		mov	al, 0ffh	;Return success.
		lesi	IDString
		iret			;Return back to caller.

IDString	byte	"Static Shared Memory TSR",0

TryRmv:		cmp	al, 1		;Remove call.
		jne	TryRetSeg

; See if we can remove this TSR:

		push	es
		mov	ax, 0
		mov	es, ax
		cmp	word ptr es:[2Fh*4], offset MyInt2F
		jne	TRDone
		cmp	word ptr es:[2Fh*4 + 2], seg MyInt2F
		je	CanRemove	;Branch if we can.
TRDone:		mov	ax, 1		;Return failure for now.
		pop	es
		iret

; Okay, they want to remove this guy *and* we can remove it from memory.
; Take care of all that here.

		assume	ds:ResidentSeg

CanRemove:	push	ds
		pusha
		cli			;Turn off the interrupts while
		mov	ax, 0		; we mess with the interrupt
		mov	es, ax		; vectors.
		mov	ax, cs
		mov	ds, ax

		mov	ax, word ptr OldInt2F
		mov	es:[2Fh*4], ax
		mov	ax, word ptr OldInt2F+2
		mov	es:[2Fh*4 + 2], ax


; Okay, one last thing before we quit- Let's give the memory allocated
; to this TSR back to DOS.

		mov	ds, PSP
		mov	es, ds:[2Ch]		;Ptr to environment block.
		mov	ah, 49h			;DOS release memory call.
		int	21h

		mov	ax, ds			;Release program code space.
		mov	es, ax
		mov	ah, 49h
		int	21h

		popa
		pop	ds
		pop	es
		mov	ax, 0			;Return Success.
		iret

; See if they want us to return the segment address of our shared segment
; here.

TryRetSeg:	cmp	al, 10h			;Return Segment Opcode
		jne     IllegalOp
		mov	ax, SharedMemory
		mov	es, ax
		mov	ax, 0			;Return success
		clc
		iret

; They called us with an illegal subfunction value.  Try to do as little
; damage as possible.

IllegalOp:	mov	ax, 0		;Who knows what they were thinking?
		iret
MyInt2F		endp
		assume	ds:nothing
ResidentSeg	ends


; Here's the segment that will actually hold the shared data.

SharedMemory	segment	para public 'Shared'
		db	0FFFFh dup (?)
SharedMemory	ends






cseg		segment	para public 'code'
		assume	cs:cseg, ds:ResidentSeg

; SeeIfPresent-	Checks to see if our TSR is already present in memory.
;		Sets the zero flag if it is, clears the zero flag if
;		it is not.

SeeIfPresent	proc	near
		push	es
		push	ds
		push	di
		mov	cx, 0ffh		;Start with ID 0FFh.
IDLoop:		mov	ah, cl
		push	cx
		mov	al, 0			;Verify presence call.
		int	2Fh
		pop	cx
		cmp	al, 0			;Present in memory?
		je	TryNext
		strcmpl
		byte	"Static Shared Memory TSR",0
		je	Success

TryNext:	dec	cl			;Test USER IDs of 80h..FFh
		js	IDLoop
		cmp	cx, 0			;Clear zero flag.
Success:	pop	di
		pop	ds
		pop	es
		ret
SeeIfPresent	endp



; FindID-	Determines the first (well, last actually) TSR ID available
;		in the multiplex interrupt chain.  Returns this value in
;		the CL register.
;
;		Returns the zero flag set if it locates an empty slot.
;		Returns the zero flag clear if failure.

FindID		proc	near
		push	es
		push	ds
		push	di

		mov	cx, 0ffh		;Start with ID 0FFh.
IDLoop:		mov	ah, cl
		push	cx
		mov	al, 0			;Verify presence call.
		int	2Fh
		pop	cx
		cmp	al, 0			;Present in memory?
		je	Success
		dec	cl			;Test USER IDs of 80h..FFh
		js	IDLoop
		xor	cx, cx
		cmp	cx, 1			;Clear zero flag
Success:	pop	di
		pop	ds
		pop	es
		ret
FindID		endp



Main		proc
		meminit

		mov	ax, ResidentSeg
		mov	ds, ax

		mov	ah, 62h			;Get this program's PSP
		int	21h			; value.
		mov	PSP, bx

; Before we do anything else, we need to check the command line
; parameters.  If there is one, and it is the word "REMOVE", then remove
; the resident copy from memory using the multiplex (2Fh) interrupt.

		argc
		cmp	cx, 1			;Must have 0 or 1 parms.
		jb	TstPresent
		je	DoRemove
Usage:		print
		byte	"Usage:",cr,lf
		byte	"       shardmem",cr,lf
		byte	"or     shardmem REMOVE",cr,lf,0
		ExitPgm


; Check for the REMOVE command.

DoRemove:	mov	ax, 1
		argv
		stricmpl
		byte	"REMOVE",0
		jne	Usage

		call	SeeIfPresent
		je	RemoveIt
		print
		byte	"TSR is not present in memory, cannot remove"
		byte	cr,lf,0
		ExitPgm

RemoveIt:	mov	MyTSRID, cl
		printf
		byte	"Removing TSR (ID #%d) from memory...",0
		dword	MyTSRID

		mov	ah, cl
		mov	al, 1			;Remove cmd, ah contains ID
		int	2Fh
		cmp	al, 1			;Succeed?
		je	RmvFailure
		print
		byte	"removed.",cr,lf,0
		ExitPgm

RmvFailure:	print
		byte	cr,lf
		byte	"Could not remove TSR from memory.",cr,lf
		byte	"Try removing other TSRs in the reverse order "
		byte	"you installed them.",cr,lf,0
		ExitPgm



; Okay, see if the TSR is already in memory.  If so, abort the
; installation process.

TstPresent:     call	SeeIfPresent
		jne	GetTSRID
		print
		byte	"TSR is already present in memory.",cr,lf
		byte	"Aborting installation process",cr,lf,0
		ExitPgm


; Get an ID for our TSR and save it away.

GetTSRID:	call	FindID
		je	GetFileName
		print
		byte	"Too many resident TSRs, cannot install",cr,lf,0
		ExitPgm


; Things look cool so far, so install the interrupts

GetFileName:	mov	MyTSRID, cl
		print
		byte	"Installing interrupts...",0


; Patch into the INT 2Fh interrupt chain.

		cli				;Turn off interrupts!
		mov	ax, 0
		mov	es, ax
		mov	ax, es:[2Fh*4]
		mov	word ptr OldInt2F, ax
		mov     ax, es:[2Fh*4 + 2]
		mov	word ptr OldInt2F+2, ax
		mov	es:[2Fh*4], offset MyInt2F
		mov	es:[2Fh*4+2], seg ResidentSeg
		sti				;Okay, ints back on.

; We're hooked up, the only thing that remains is to zero out the shared
; memory segment and then terminate and stay resident.

		printf
		byte	"Installed, TSR ID #%d.",cr,lf,0
		dword	MyTSRID

		mov	ax, SharedMemory	;Zero out the shared
		mov	es, ax			; memory segment.
		mov	cx, 32768
		xor	ax, ax
		mov	di, ax
	rep	stosw


		mov	dx, EndResident		;Compute size of program.
		sub	dx, PSP
		mov	ax, 3100h		;DOS TSR command.
		int	21h
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	256 dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
