; This is an example of an active TSR that counts keyboard interrupts
; once activated.  Every minute it writes the number of keyboard
; interrupts that occurred in the previous minute to an output file.
; This continues until the user removes the program from memory.
;
;
; Usage:
;	KEYEVAL  filename	- Begins logging keystroke data  to
;				  this file.
;
;	KEYEVAL  REMOVE		- Removes the resident program from
;				  memory.
;
;
; This TSR checks to make sure there isn't a copy already active in
; memory.  When doing disk I/O from the interrupts, it checks to make
; sure DOS isn't busy and it preserves application globals (PSP, DTA,
; and extended error info).  When removing itself from memory, it
; makes sure there are no other interrupts chained into any of its
; interrupts before doing the remove.
;
; The resident segment definitions must come before everything else.

ResidentSeg	segment	para public 'Resident'
ResidentSeg	ends

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

; The following variable counts the number of keyboard interrupts

KeyIntCnt	word	0

; Counter counts off the number of milliseconds that pass, SecCounter
; counts off the number of seconds (up to 60).

Counter		word	0
SecCounter	word	0

; FileHandle is the handle for the log file:

FileHandle	word	0

; NeedIO determines if we have a pending I/O opearation.

NeedIO		word	0

; PSP is the psp address for this program.

PSP		word	0

; Variables to tell us if DOS, INT 13h, or INT 16h are busy:

InInt13		byte	0
InInt16		byte	0
InDOSFlag	dword	?

; These variables contain the original values in the interrupt vectors
; we've patched.

OldInt9		dword	?
OldInt13	dword	?
OldInt16	dword	?
OldInt1C	dword	?
OldInt28	dword	?
OldInt2F	dword	?


; DOS data structures:

ExtErr		struct
eeAX		word	?
eeBX		word	?
eeCX		word	?
eeDX		word	?
eeSI		word	?
eeDI		word	?
eeDS		word	?
eeES		word	?
		word	3 dup (0)
ExtErr		ends



XErr		ExtErr	{}		;Extended Error Status.
AppPSP		word	?		;Application PSP value.
AppDTA		dword	?		;Application DTA address.


; The following data is the output record.  After storing this data
; to these variables, the TSR writes this data to disk.

month		byte	0
day		byte	0
year		word	0
hour		byte	0
minute		byte	0
second		byte	0
Keystrokes	word	0
RecSize		=	$-month







; MyInt9-	The system calls this routine every time a keyboard
;		interrupt occus.  This routine increments the
;		KeyIntCnt variable and then passes control on to the
;		original Int9 handler.

MyInt9		proc	far
		inc	ResidentSeg:KeyIntCnt
		jmp	ResidentSeg:OldInt9
MyInt9		endp





; MyInt1C-	Timer interrupt.  This guy counts off 60 seconds and then
;		attempts to write a record to the output file.  Of course,
;		this call has to jump through all sorts of hoops to keep
;		from reentering DOS and other problematic code.

MyInt1C		proc	far
		assume	ds:ResidentSeg

		push	ds
		push	es
		pusha				;Save all the registers.
		mov	ax, ResidentSeg
		mov	ds, ax

		pushf
		call	OldInt1C

; First things first, let's bump our interrupt counter so we can count
; off a minute.  Since we're getting interrupted about every 54.92549
; milliseconds, let's shoot for a little more accuracy than 18 times
; per second so the timings don't drift too much.

		add	Counter, 549		;54.9 msec per int 1C.
		cmp	Counter, 10000		;1 second.
		jb	NotSecYet
		sub	Counter, 10000
		inc	SecCounter
NotSecYet:


; If NEEDIO is not zero, then there is an I/O operation in progress.
; Do not disturb the output values if this is the case.

		cli				;This is a critical region.
		cmp	NeedIO, 0
		jne	SkipSetNIO

; Okay, no I/O in progress, see if a minute has passed since the last
; time we logged the keystrokes to the file.  If so, it's time to start
; another I/O operation.

		cmp	SecCounter, 60		;One minute passed yet?
		jb	Int1CDone
		mov	NeedIO, 1		;Flag need for I/O.
		mov	ax, KeyIntCnt		;Copy this to the output
		shr	ax, 1			; buffer after computing
		mov     KeyStrokes, ax		; # of keystrokes.
		mov	KeyIntCnt, 0		;Reset for next minute.
		mov	SecCounter, 0

SkipSetNIO:     cmp	NeedIO, 1		;Is the I/O already in
		jne	Int1CDone		; progress?  Or done?

		call	ChkDOSStatus		;See if DOS/BIOS are free.
		jnc	Int1CDone		;Branch if busy.

		call	DoIO			;Do I/O if DOS is free.

Int1CDone:	popa
		pop	es
		pop	ds
		iret
MyInt1C		endp
		assume	ds:nothing


; MyInt28-	Idle interrupt.  If DOS is in a busy-wait loop waiting for
;		I/O to complete, it executes an int 28h instruction each
;		time through the loop.  We can ignore the InDOS and CritErr
;		flags at that time, and do the I/O if the other interrupts
;		are free.

MyInt28		proc	far
		assume	ds:ResidentSeg

		push	ds
		push	es
		pusha				;Save all the registers.
		mov	ax, ResidentSeg
		mov	ds, ax

		pushf				;Call the next INT 28h
		call	OldInt28		; ISR in the chain.

		cmp	NeedIO, 1		;Do we have a pending I/O?
		jne	Int28Done

		mov	al, InInt13		;See if BIOS is busy.
		or	al, InInt16
		jne	Int28Done

		call	DoIO			;Go do I/O if BIOS is free.

Int28Done:	popa
		pop	es
		pop	ds
		iret
MyInt28		endp
		assume	ds:nothing


; MyInt16-	This is just a wrapper for the INT 16h (keyboard trap)
;		handler.

MyInt16		proc	far
		inc	ResidentSeg:InInt16
		pushf
		call	ResidentSeg:OldInt16	;Call original handler.
		pushf				;Must preserve flags
		dec	ResidentSeg:InInt16	; for caller.
		popf
		retf	2			;Fake IRET to keep flags.
MyInt16		endp


; MyInt13-	This is just a wrapper for the INT 13h (disk I/O trap)
;		handler.

MyInt13		proc	far
		inc	ResidentSeg:InInt13
		pushf
		call	ResidentSeg:OldInt13	;Call original handler.
		pushf				;Must preserve flags
		dec	ResidentSeg:InInt13	; for caller.
		popf
		retf	2			;Fake iret to keep flags.
MyInt13		endp


; ChkDOSStatus-	Returns with the carry clear if DOS or a BIOS routine
;		is busy and we can't interrupt them.

ChkDOSStatus	proc	near
		assume	ds:ResidentSeg
		les	bx, InDOSFlag
		mov	al, es:[bx]		;Get InDOS flag.
		or	al, es:[bx-1]		;OR with CritErr flag.
		or	al, InInt16		;OR with our wrapper
		or	al, InInt13		; values.
		je	Okay2Call
		clc
		ret

Okay2Call:	clc
		ret
ChkDOSStatus	endp
		assume	ds:nothing


; PreserveDOS-	Gets a copy's of DOS' current PSP, DTA, and extended
;		error information and saves this stuff.  Then it sets
;		the PSP to our local PSP and the DTA to PSP:80h.

PreserveDOS	proc	near
		assume	ds:ResidentSeg

		mov	ah, 51h			;Get app's PSP.
		int	21h
		mov	AppPSP, bx		;Save for later

		mov	ah, 2Fh			;Get app's DTA.
		int	21h
		mov	word ptr AppDTA, bx  	;Save for later.
		mov	word ptr AppDTA+2, es

		push	ds
		mov	ah, 59h			;Get extended err info.
		xor	bx, bx
		int	21h

		mov	cs:XErr.eeDS, ds
		pop	ds
		mov	XErr.eeAX, ax
		mov	XErr.eeBX, bx
		mov	XErr.eeCX, cx
		mov	XErr.eeDX, dx
		mov	XErr.eeSI, si
		mov	XErr.eeDI, di
		mov	XErr.eeES, es

; Okay, point DOS's pointers at us:

		mov	bx, PSP
		mov	ah, 50h			;Set PSP.
		int	21h

		push	ds			;Set the DTA to
		mov	ds, PSP			; address PSP:80h
		mov	dx, 80h
		mov	ah, 1Ah			;Set DTA call.
		int	21h
		pop	ds

		ret
PreserveDOS	endp
		assume	ds:nothing



; RestoreDOS-	Restores DOS' important global data values back to the
;		application's values.

RestoreDOS	proc	near
		assume	ds:ResidentSeg

		mov	bx, AppPSP
		mov	ah, 50h			;Set PSP
		int	21h

		push	ds
		lds	dx, AppDTA
		mov	ah, 1Ah			;Set DTA
		int	21h
		pop	ds
		push	ds

		mov	si, offset XErr		;Saved extended error stuff.
		mov	ax, 5D0Ah		;Restore XErr call.
		int	21h
		pop	ds
		ret
RestoreDOS	endp
		assume	ds:nothing


; DoIO-		This routine processes each of the I/O operations
;		required to write data to the file.

DoIO		proc	near
		assume	ds:ResidentSeg

		mov	NeedIO, 0FFh		;A busy flag for us.

; The following Get Date DOS call may take a while, so turn the
; interrupts back on (we're clear of the critical section once we
; write 0FFh to NeedIO).

		sti
		call	PreserveDOS		;Save DOS data.

		mov	ah, 2Ah			;Get Date DOS call
		int	21h
		mov	month, dh
		mov	day, dl
		mov	year, cx

		mov	ah, 2Ch			;Get Time DOS call
		int	21h
		mov	hour, ch
		mov	minute, cl
		mov	second, dh

		mov	ah, 40h			;DOS Write call
		mov	bx, FileHandle		;Write data to this file.
		mov	cx, RecSize		;This many bytes.
		mov	dx, offset month	;Starting at this address.
		int	21h			;Ignore return errors (!).
		mov	ah, 68h			;DOS Commit call
		mov	bx, FileHandle		;Write data to this file.
		int	21h			;Ignore return errors (!).

		mov	NeedIO, 0		;Ready to start over.
		call	RestoreDOS

PhasesDone:	ret
DoIO		endp
		assume	ds:nothing



; MyInt2F-	Provides int 2Fh (multiplex interrupt) support for this
;		TSR.  The multiplex interrupt recognizes the following
;		subfunctions (passed in AL):
;
;		00- Verify presence.  	Returns 0FFh in AL and a pointer
;					to an ID string in es:di if the
;					TSR ID (in AH) matches this
;					particular TSR.
;
;		01- Remove.		Removes the TSR from memory.
;					Returns 0 in AL if successful,
;					1 in AL if failure.

MyInt2F		proc	far
		assume	ds:nothing

		cmp	ah, MyTSRID	;Match our TSR identifier?
		je	YepItsOurs
		jmp	OldInt2F

; Okay, we know this is our ID, now check for a verify vs. remove call.

YepItsOurs:	cmp	al, 0		;Verify Call
		jne	TryRmv
		mov	al, 0ffh	;Return success.
		lesi	IDString
		iret			;Return back to caller.

IDString	byte	"Keypress Logger TSR",0

TryRmv:		cmp	al, 1		;Remove call.
		jne	IllegalOp

		call	TstRmvable	;See if we can remove this guy.
		je	CanRemove	;Branch if we can.
		mov	ax, 1		;Return failure for now.
		iret

; Okay, they want to remove this guy *and* we can remove it from memory.
; Take care of all that here.

		assume	ds:ResidentSeg

CanRemove:	push	ds
		push	es
		pusha
		cli			;Turn off the interrupts while
		mov	ax, 0		; we mess with the interrupt
		mov	es, ax		; vectors.
		mov	ax, cs
		mov	ds, ax

		mov	ax, word ptr OldInt9
		mov	es:[9*4], ax
		mov	ax, word ptr OldInt9+2
		mov	es:[9*4 + 2], ax

		mov	ax, word ptr OldInt13
		mov	es:[13h*4], ax
		mov	ax, word ptr OldInt13+2
		mov	es:[13h*4 + 2], ax

		mov	ax, word ptr OldInt16
		mov	es:[16h*4], ax
		mov	ax, word ptr OldInt16+2
		mov	es:[16h*4 + 2], ax

		mov	ax, word ptr OldInt1C
		mov	es:[1Ch*4], ax
		mov	ax, word ptr OldInt1C+2
		mov	es:[1Ch*4 + 2], ax

		mov	ax, word ptr OldInt28
		mov	es:[28h*4], ax
		mov	ax, word ptr OldInt28+2
		mov	es:[28h*4 + 2], ax

		mov	ax, word ptr OldInt2F
		mov	es:[2Fh*4], ax
		mov	ax, word ptr OldInt2F+2
		mov	es:[2Fh*4 + 2], ax


; Okay, with that out of the way, let's close the file.
; Note: INT 2F shouldn't have to deal with DOS busy because it's
; a passive TSR call.

		mov	ah, 3Eh			;Close file command
		mov	bx, FileHandle
		int	21h

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
		pop	es
		pop	ds
		mov	ax, 0			;Return Success.
		iret


; They called us with an illegal subfunction value.  Try to do as little
; damage as possible.

IllegalOp:	mov	ax, 0		;Who knows what they were thinking?
		iret
MyInt2F		endp
		assume	ds:nothing





; TstRmvable-	Checks to see if we can remove this TSR from memory.
;		Returns the zero flag set if we can remove it, clear
;		otherwise.

TstRmvable	proc	near
		cli
		push	ds
		mov	ax, 0
		mov	ds, ax

		cmp	word ptr ds:[9*4], offset MyInt9
		jne	TRDone
		cmp	word ptr ds:[9*4 + 2], seg MyInt9
		jne	TRDone

		cmp	word ptr ds:[13h*4], offset MyInt13
		jne	TRDone
		cmp	word ptr ds:[13h*4 + 2], seg MyInt13
		jne	TRDone

		cmp	word ptr ds:[16h*4], offset MyInt16
		jne	TRDone
		cmp	word ptr ds:[16h*4 + 2], seg MyInt16
		jne	TRDone

		cmp	word ptr ds:[1Ch*4], offset MyInt1C
		jne	TRDone
		cmp	word ptr ds:[1Ch*4 + 2], seg MyInt1C
		jne	TRDone

		cmp	word ptr ds:[28h*4], offset MyInt28
		jne	TRDone
		cmp	word ptr ds:[28h*4 + 2], seg MyInt28
		jne	TRDone

		cmp	word ptr ds:[2Fh*4], offset MyInt2F
		jne	TRDone
		cmp	word ptr ds:[2Fh*4 + 2], seg MyInt2F
TRDone:         pop	ds
		sti
		ret
TstRmvable	endp
ResidentSeg	ends






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
		byte	"Keypress Logger TSR",0
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
; parameters.  We must have either a valid filename or the
; command "remove".  If remove appears on the command line, then remove
; the resident copy from memory using the multiplex (2Fh) interrupt.
; If remove is not on the command line, we'd better have a filename and
; there had better not be a copy already loaded into memory.

		argc
		cmp	cx, 1			;Must have exactly 1 parm.
		je	GoodParmCnt
		print
		byte	"Usage:",cr,lf
		byte	"       KeyEval filename",cr,lf
		byte	"or     KeyEval REMOVE",cr,lf,0
		ExitPgm


; Check for the REMOVE command.

GoodParmCnt:	mov	ax, 1
		argv
		stricmpl
		byte	"REMOVE",0
		jne	TstPresent

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


; Things look cool so far, check the filename and open the file.

GetFileName:	mov	MyTSRID, cl
		printf
		byte	"Keypress logger TSR program",cr,lf
		byte	"TSR ID = %d",cr,lf
		byte	"Processing file:",0
		dword	MyTSRID

		puts
		putcr

		mov	ah, 3Ch			;Create file command.
		mov	cx, 0			;Normal file.
		push	ds
		push	es    			;Point ds:dx at name
		pop	ds
		mov	dx, di
		int	21h			;Open the file
		jnc	GoodOpen
		print
		byte	"DOS error #",0
		puti
		print
		byte	" opening file.",cr,lf,0
		ExitPgm

GoodOpen:	pop	ds
		mov	FileHandle, ax		;Save file handle.


InstallInts:	print
		byte	"Installing interrupts...",0


; Patch into the INT 9, 13h, 16h, 1Ch, 28h, and 2Fh interrupt vectors.
; Note that the statements above have made ResidentSeg the current data
; segment, so we can store the old values directly into
; the OldIntxx variables.

		cli				;Turn off interrupts!
		mov	ax, 0
		mov	es, ax
		mov	ax, es:[9*4]
		mov	word ptr OldInt9, ax
		mov     ax, es:[9*4 + 2]
		mov	word ptr OldInt9+2, ax
		mov	es:[9*4], offset MyInt9
		mov	es:[9*4+2], seg ResidentSeg

		mov	ax, es:[13h*4]
		mov	word ptr OldInt13, ax
		mov     ax, es:[13h*4 + 2]
		mov	word ptr OldInt13+2, ax
		mov	es:[13h*4], offset MyInt13
		mov	es:[13h*4+2], seg ResidentSeg

		mov	ax, es:[16h*4]
		mov	word ptr OldInt16, ax
		mov     ax, es:[16h*4 + 2]
		mov	word ptr OldInt16+2, ax
		mov	es:[16h*4], offset MyInt16
		mov	es:[16h*4+2], seg ResidentSeg

		mov	ax, es:[1Ch*4]
		mov	word ptr OldInt1C, ax
		mov     ax, es:[1Ch*4 + 2]
		mov	word ptr OldInt1C+2, ax
		mov	es:[1Ch*4], offset MyInt1C
		mov	es:[1Ch*4+2], seg ResidentSeg

		mov	ax, es:[28h*4]
		mov	word ptr OldInt28, ax
		mov     ax, es:[28h*4 + 2]
		mov	word ptr OldInt28+2, ax
		mov	es:[28h*4], offset MyInt28
		mov	es:[28h*4+2], seg ResidentSeg

		mov	ax, es:[2Fh*4]
		mov	word ptr OldInt2F, ax
		mov     ax, es:[2Fh*4 + 2]
		mov	word ptr OldInt2F+2, ax
		mov	es:[2Fh*4], offset MyInt2F
		mov	es:[2Fh*4+2], seg ResidentSeg
		sti				;Okay, ints back on.

; We're hooked up, the only thing that remains is to terminate and
; stay resident.

		print
		byte	"Installed.",cr,lf,0


		mov	dx, EndResident		;Compute size of program.
		sub	dx, PSP
		mov	ax, 3100h		;DOS TSR command.
		int	21h
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
