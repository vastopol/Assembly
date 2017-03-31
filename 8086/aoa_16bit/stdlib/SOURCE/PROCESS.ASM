		include	process.a

StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'

wp		equ	<word ptr>

DefaultPCB	pcb	<>
DefaultCortn	pcb	<>

ProcessID	dw	0
ReadyQ		dd	DefaultPCB
LastRdyQ	dd	DefaultPCB

CurCoroutine	dd	DefaultCortn	;Points at the currently executing
					; coroutine.

TimerIntVect	dd	?

SaveSP		dw	?		;Temp holding location for fork.
SaveSS		dw	?		;Temp holding location for fork.

stddata		ends



stdlib		segment	para public 'slcode'
		assume	cs:stdgrp

; Special case to handle MASM 6.0 vs. all other assemblers:
; If not MASM 5.1 or MASM 6.0, set the version to 5.00:

		ifndef	@version
@version	equ	500
		endif
;
;
;
;============================================================================
; Process package.
; These routines handle multitasking/multiprogramming in the standard
; library.
;============================================================================
;
;
; sl_prcsinit-	Initializes the process manager.  By default, this guy
;		assumes the use of the 1/18 second timer.  At some future
;		date I may add support for the AT msec timer.
;
;		Warning: This code patches into several interrupts.  If
;		you call this routine in your program, you must call the
;		sl_prcsquit routine before your program terminates.  Other-
;		wise the system will crash shortly thereafter.

		public	sl_prcsinit
;
sl_prcsinit	proc	far
		assume	ds:stdgrp
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx

		mov	ax, StdGrp
		mov	ds, ax

; Okay, set up this code as the first (and only) process currently in the
; ready queue:

		mov	ax, offset StdGrp:DefaultPCB
		mov	wp StdGrp:ReadyQ, ax
		mov	wp StdGrp:LastRdyQ, ax
		mov	ax, ds
		mov	wp StdGrp:ReadyQ+2, ax
		mov	wp StdGrp:LastRdyQ+2, ax

		xor	ax, ax
		mov	ProcessID, ax			;Start process IDs at 0

		mov	wp StdGrp:DefaultPCB.NextProc, ax
		mov	wp StdGrp:DefaultPCB.NextProc[2], ax
		mov	wp StdGrp:DefaultPCB.CPUTime+2, ax
		mov	wp StdGrp:DefaultPCB.CPUTime+2, 1

		mov	ah, 2ah				;Get the date.
		int	21h
		mov	wp StdGrp:DefaultPCB.StartingDate, cx
		mov	wp StdGrp:DefaultPCB.StartingDate+2, dx

		mov	ah, 2ch				;Get the time.
		int	21h
		mov	wp StdGrp:DefaultPCB.StartingTime, cx
		mov	wp StdGrp:DefaultPCB.StartingTime+2, dx


		mov	ax, 3508h		;Timer interrupt vector.
		int	21h
		mov	wp StdGrp:TimerIntVect, bx
		mov	wp StdGrp:TimerIntVect+2, es

		mov	ax, 2508h		;Patch the dispatcher into the
		mov	dx, seg StdGrp:TimerISR	; timer interrupt.
		mov	ds, dx
		mov	dx, offset StdGrp:TimerISR
		int	21h


		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		ret
sl_prcsinit	endp
		assume	ds:nothing


; sl_prcsquit-	This code restores the interrupt vectors patched by the
;		sl_prcsinit routine.  This routine *must* be called before
;		you exit your program or the system will crash shortly
;		thereafter.

		public	sl_prcsquit
sl_prcsquit	proc	far
		assume	ds:StdGrp

		push	ds
		push	es
		push	ax
		mov	ax, StdGrp
		mov	ds, ax

		mov	ax, 0
		mov	es, ax

; Cannot call DOS to restore this vector because this call might
; occur in a critical error or break handler routine.

		pushf
		cli
		mov	ax, word ptr StdGrp:TimerIntVect
		mov	es:[8*4], ax
		mov	ax, word ptr StdGrp:TimerIntVect+2
		mov	es:[8*4 + 2], ax
		popf

		pop	ax
		pop	es
		pop	ds
		ret
sl_prcsquit	endp
		assume	ds:nothing



; sl_fork-	Starts a new process.  On entry, ES:DI points at a PCB.
;		This routine initializes that process and adds it to the
;		ready queue.
;
;		WARNING: This routine assumes that the only information to
;		copy off the stack is a far return address (to FORK). When
;		fork returns there will be nothing sitting on the stack of
;		the new process.  Therefore, you should not call fork from
;		inside a procedure if you expect the child process to return
;		to the called procedure.
;
;		This code assumes that you've initialized the ssSave and
;		spSave fields of the new PCB with the address of a stack
;		for that new process.
;
;		This guy returns with AX=0 and BX=<ChildProcessID> to the
;		parent process.  It returns AX=<ChildProcessID> and BX=0
;		to the child process.

		public	sl_fork
sl_fork		proc	far
		assume	ds:stdgrp

		push	bp
		mov	bp, sp
		pushf
		push	ds
		push	cx
		push	dx

		mov	ax, stdgrp
		mov	ds, ax

		if	@version ge 600

; Initialize various fields in the new PCB:
; Start with the register.  Remember, AX contains the process ID for the
; child process, BX contains zero for the child process.  AX contains zero
; for the parent process, and BX contains the child process ID for the
; parent process.
;
; SS:SP should already be set up on entry (by the caller).

		inc	StdGrp:ProcessID	;Grab a new process ID.
		mov	ax, StdGrp:ProcessID
		mov	es:[di].pcb.regax, ax
		mov	es:[di].pcb.PrcsID, ax
		mov	wp es:[di].pcb.regbx, 0
		mov	es:[di].pcb.regcx, cx
		mov	es:[di].pcb.regdx, dx
		mov	ax, 0[bp]		;Get bp value off stack.
		mov	es:[di].pcb.regbp, ax
		mov	es:[di].pcb.regsi, si
		mov	es:[di].pcb.regdi, di
		mov	ax, [bp-4]		;Get ds value off stack.
		mov	es:[di].pcb.regds, ax
		mov	es:[di].pcb.reges, es
		sti				;Must have interrupts on!
		pushf
		cli				;But the rest is a critical
		pop	ax			; section.
		mov	es:[di].pcb.regflags, ax

; The return address should be the return address for fork:

		mov	ax, 2[bp]		;Get return offset
		mov	es:[di].pcb.regip, ax
		mov	ax, 4[bp]		;Get return segment
		mov	es:[di].pcb.regcs, ax


; Set up accounting information (CPU time):

		mov	wp es:[di].pcb.CPUTime, 0
		mov	wp es:[di+2].pcb.CPUTime, 0

		mov	ah, 2ah				;Get the date.
		int	21h
		mov	wp es:[di].pcb.StartingDate, cx
		mov	wp es:[di].pcb.StartingDate+2, dx

		mov	ah, 2ch				;Get the time.
		int	21h
		mov	wp es:[di].pcb.StartingTime, cx
		mov	wp es:[di].pcb.StartingTime+2, dx


; Okay, now move the new PCB onto the ready queue (interrupts must be off
; while we're doing this!).  Place this guy in the ready queue after the
; current process so it gets a time slice real soon.

		cli
		push	es
		push	di
		les	di, StdGrp:ReadyQ
		mov	cx, wp es:[di].pcb.NextProc
		mov	dx, wp es:[di+2].pcb.NextProc
		pop	ax
		mov	wp es:[di].pcb.NextProc, ax
		pop	ax
		mov	wp es:[di+2].pcb.NextProc, ax
		les	di, es:[di].pcb.NextProc	;Pt ES:DI @ new prcs.
		mov	wp es:[di].pcb.NextProc, cx	;Link in prev 2nd
		mov	wp es:[di+2].pcb.NextProc, dx	; process.

; If there was only one process on the ready queue prior to adding this
; process, point the LastRdyQ pointer at the new process.

		mov	ax, wp StdGrp:ReadyQ
		cmp	ax, wp StdGrp:LastRdyQ
		jne	RdyNELast
		mov	ax, wp StdGrp:ReadyQ+2
		cmp	ax, wp StdGrp:LastRdyQ+2
		jne	RdyNELast
		mov	wp StdGrp:LastRdyQ, di
		mov	wp StdGrp:LastRdyQ+2, es

; Okay, return back to the calling code with AX=0 to denote that this is
; the parent routine returning.  It also returns the child process ID in
; the BX register.

RdyNELast:	xor	ax, ax
		mov	bx, StdGrp:ProcessID

		else				;TASM or MASM pre-6.0

		inc	StdGrp:ProcessID
		mov	ax, StdGrp:ProcessID
		mov	es:[di].regax, ax
		mov	es:[di].PrcsID, ax
		mov	wp es:[di].regbx, 0
		mov	es:[di].regcx, cx
		mov	es:[di].regdx, dx
		mov	ax, 0[bp]
		mov	es:[di].regbp, ax
		mov	es:[di].regsi, si
		mov	es:[di].regdi, di
		mov	ax, [bp-4]
		mov	es:[di].regds, ax
		mov	es:[di].reges, es
		sti
		pushf
		cli
		pop	ax
		mov	es:[di].regflags, ax
		mov	ax, 2[bp]
		mov	es:[di].regip, ax
		mov	ax, 4[bp]
		mov	es:[di].regcs, ax
		mov	wp es:[di].CPUTime, 0
		mov	wp es:[di+2].CPUTime, 0
		mov	ah, 2ah
		int	21h
		mov	wp es:[di].StartingDate, cx
		mov	wp es:[di].StartingDate+2, dx
		mov	ah, 2ch
		int	21h
		mov	wp es:[di].StartingTime, cx
		mov	wp es:[di].StartingTime+2, dx
		cli
		push	es
		push	di
		les	di, StdGrp:ReadyQ
		mov	cx, wp es:[di].NextProc
		mov	dx, wp es:[di+2].NextProc
		pop	ax
		mov	wp es:[di].NextProc, ax
		pop	ax
		mov	wp es:[di+2].NextProc, ax
		les	di, es:[di].NextProc
		mov	wp es:[di].NextProc, cx
		mov	wp es:[di+2].NextProc, dx
		mov	ax, wp StdGrp:ReadyQ
		cmp	ax, wp StdGrp:LastRdyQ
		jne	RdyNELast
		mov	ax, wp StdGrp:ReadyQ+2
		cmp	ax, wp StdGrp:LastRdyQ+2
		jne	RdyNELast
		mov	wp StdGrp:LastRdyQ, di
		mov	wp StdGrp:LastRdyQ+2, es
RdyNELast:	xor	ax, ax
		mov	bx, StdGrp:ProcessID

		endif



		pop	dx
		pop	cx
		pop	ds
		popf
		pop	bp
		ret
sl_fork		endp
		assume	ds:nothing



; sl_Die-	Terminate the current process.  If this is not the only
;		process in the ready queue, then this code removes the current
;		process from the ready queue and transfers control to the
;		next process in the Ready Queue.  Since the current process
;		is not the the ready queue, this action effectively kills
;		the current process.
;
;		This routine will *not* delete the current process from the
;		ready queue if it is the *only* process in the ready queue.
;		In such an event, this code returns to the caller with the
;		carry flag set (it returns this way because sl_Kill can call
;		this routine and sl_Kill requires the carry set if an error
;		occurs).

		public	sl_Die
sl_Die		proc	far
		assume	ds:StdGrp

		pushf			;Push registers onto the stack just
		push	ds		; in case there is an error return.
		push	di

		mov	di, StdGrp
		mov	ds, di
		cli				;Critical region ahead!

		if	@version ge 600

		les	di, StdGrp:ReadyQ
		cmp	wp es:[di].pcb.NextProc+2, 0
		jne	GoodDIE

; YIKES! The caller is trying to delete the only process in the ReadyQ.
; We can't let that happen, so return an error down here.

		pop	di
		pop	ds
		stc
		ret

; Okay, this DIE operation can proceed.  Handle that down here.

GoodDIE:	mov	ax, wp es:[di].pcb.NextProc
		mov	wp StdGrp:ReadyQ, ax
		mov	ax, wp es:[di].pcb.NextProc+2
		mov	wp StdGrp:ReadyQ+2, ax

; The following code, which passes control to the new "current process"
; must look exactly like the code at the tail end of the dispatcher!
; In particular, the values pushed at the beginning of this routine are
; history.  They are on a different stack, which will not be accessed again,
; so we do not need to worry about them.

		les	di, StdGrp:ReadyQ
		inc	wp es:[di].pcb.CPUTime
		jne	NoHOIncCPU
		inc	wp es:[di+2].pcb.CPUTime

NoHOIncCPU:	mov	ss, es:[di].pcb.regss
		mov	sp, es:[di].pcb.regsp
		push	es:[di].pcb.regflags
		push	es:[di].pcb.regcs
		push	es:[di].pcb.regip
		mov	ax, es:[di].pcb.regax
		mov	bx, es:[di].pcb.regbx
		mov	cx, es:[di].pcb.regcx
		mov	dx, es:[di].pcb.regdx
		mov	bp, es:[di].pcb.regbp
		mov	si, es:[di].pcb.regsi
		mov	ds, es:[di].pcb.regds
		push	es:[di].pcb.regdi
		mov	es, es:[di].pcb.reges
		pop	di
		iret


		else

		les	di, StdGrp:ReadyQ
		cmp	wp es:[di].NextProc+2, 0
		jne	GoodDIE
		pop	di
		pop	ds
		stc
		ret

GoodDIE:	mov	ax, wp es:[di].NextProc
		mov	wp StdGrp:ReadyQ, ax
		mov	ax, wp es:[di].NextProc+2
		mov	wp StdGrp:ReadyQ+2, ax
		les	di, StdGrp:ReadyQ
		inc	wp es:[di].CPUTime
		jne	NoHOIncCPU
		inc	wp es:[di+2].CPUTime
NoHOIncCPU:	mov	ss, es:[di].regss
		mov	sp, es:[di].regsp
		push	es:[di].regflags
		push	es:[di].regcs
		push	es:[di].regip
		mov	ax, es:[di].regax
		mov	bx, es:[di].regbx
		mov	cx, es:[di].regcx
		mov	dx, es:[di].regdx
		mov	bp, es:[di].regbp
		mov	si, es:[di].regsi
		mov	ds, es:[di].regds
		push	es:[di].regdi
		mov	es, es:[di].reges
		pop	di
		iret

		endif

sl_DIE		endp






; sl_kill-	Terminates some other process.  If this call kills the current
;		process, it effectively becomes a "die" call.  On entry, AX
;		must contain the process ID of the process to kill.
;		Returns carry set if no such process exists.  Returns carry
;		clear if it killed the process.  It is your responsibility
;		to ensure all resources in use by the killed process are
;		freed.
;
;		Note that this routine may  *not*  return if it kills
;		itself (see sl_Die for more details).

		public	sl_kill
sl_kill		proc	far
		assume	ds:StdGrp

		pushf
		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	di

		mov	di, StdGrp
		mov	ds, di
		cli				;Critical region ahead!

		if	@version ge 600

		les	di, StdGrp:ReadyQ	;See if this is a die oper-
		cmp	ax, es:[di].pcb.PrcsID	; ation.
		jne	DoKill
		pop	di
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		popf
		jmp	sl_Die

; If it's not the current process, search for the process in the ready queue.

DoKill:		cmp	wp es:[di].pcb.NextProc+2, 0 ;Error if not
		je	BadKill				   ; present in rdy Q.
		mov	bx, di
		mov	cx, es
		les	di, es:[di].pcb.NextProc
		cmp	ax, es:[di].pcb.PrcsID
		jne	DoKill

; Okay, remove the PCB pointed at by ES:DI from the ready queue.  Note that
; CX:BX points at the previous entry in the queue.

StopHere:
		mov	ax, wp es:[di].pcb.NextProc+2
		mov	di, wp es:[di].pcb.NextProc
		xchg	di, bx
		mov	es, cx
		mov	wp es:[di].pcb.NextProc, bx
		mov	wp es:[di].pcb.NextProc+2, ax


		else

		les	di, StdGrp:ReadyQ
		cmp	ax, es:[di].PrcsID
		jne	DoKill
		pop	di
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		popf
		jmp	sl_Die

DoKill:		cmp	wp es:[di].NextProc+2, 0
		je	BadKill
		mov	bx, di
		mov	cx, es
		les	di, es:[di].NextProc
		cmp	ax, es:[di].PrcsID
		jne	DoKill
StopHere:
		mov	ax, wp es:[di].NextProc+2
		mov	di, wp es:[di].NextProc
		xchg	di, bx
		mov	es, cx
		mov	wp es:[di].NextProc, bx
		mov	wp es:[di].NextProc+2, ax

		endif

		pop	di
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		popf
		clc
		ret

BadKill:        pop	di
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
		popf
		stc
		ret
sl_Kill		endp


;============================================================================
;
; sl_Yield-	Cause the current process to give up the remainder of its
;		time slice.
;
; *** This is the Dispatcher ***
;
;   This guy is also responsible for switching to a new process whenever a
; timer interrupt comes along.


		public	sl_Yield
sl_Yield	proc	far
		assume	ds:StdGrp, es:StdGrp

		pushf
		cli
		push	ds
		push	di

; Save the state of the current process.

		if	@version ge 600

		mov	di, StdGrp
		mov	ds, di
		lds	di, StdGrp:ReadyQ	;Get ptr to current PCB.
		mov	[di].pcb.regax, ax
		mov	[di].pcb.regbx, bx
		mov	[di].pcb.regcx, cx
		mov	[di].pcb.regdx, dx
		mov	[di].pcb.regbp, bp
		mov	[di].pcb.regsi, si
		mov	[di].pcb.reges, es
		pop	[di].pcb.regdi
		pop	[di].pcb.regds
		pop	[di].pcb.regflags
		pop	[di].pcb.regip
		pop	[di].pcb.regcs
		mov	[di].pcb.regsp, sp
		mov	[di].pcb.regss, ss

; Adjust the CPU time for the process we've just stopped.

		inc	wp [di].pcb.CPUTime
		jne	NoHOCPUTime
		inc	wp [di+2].pcb.CPUTime

NoHOCPUTime:

; The following kludge takes care of the case where there is only one process
; active in the ready queue:

		cmp	wp [di].pcb.NextProc+2, 0
		je	RequeueDone

; If not the only entry, move it to the end of the ready queue here.
; Begin by storing a pointer to the current process in the NextProc field
; of the last process in the queue:

		mov	di, StdGrp
		mov	ds, di

		les	di, StdGrp:LastRdyQ
		mov	ax, wp StdGrp:ReadyQ
		mov	wp StdGrp:LastRdyQ, ax
		mov	wp es:[di].pcb.NextProc, ax
		mov	ax, wp StdGrp:ReadyQ+2
		mov	wp StdGrp:LastRdyQ+2, ax
		mov	wp es:[di].pcb.NextProc+2, ax

; Now get the next process in the chain after the current process and make
; it the new process to execute by placing it at the front of the ready queue:

		les	di, StdGrp:ReadyQ
		mov	ax, wp es:[di].pcb.NextProc
		mov	wp StdGrp:ReadyQ, ax
		mov	ax, wp es:[di].pcb.NextProc+2
		mov	wp StdGrp:ReadyQ+2, ax
		xor	ax, ax
		mov     wp es:[di].pcb.NextProc, ax
		mov	wp es:[di].pcb.NextProc+2, ax

RequeueDone:

; Okay, transfer control to the (possibly new) procedure at the front of the
; ready queue:

		mov	di, StdGrp
		mov	ds, di
		lds	di, StdGrp:ReadyQ
		mov	ss, [di].pcb.regss
		mov	sp, [di].pcb.regsp
		push	[di].pcb.regflags
		push	[di].pcb.regcs
		push	[di].pcb.regip
		push	[di].pcb.regdi
		mov	ax, [di].pcb.regax
		mov	bx, [di].pcb.regbx
		mov	cx, [di].pcb.regcx
		mov	dx, [di].pcb.regdx
		mov	bp, [di].pcb.regbp
		mov	si, [di].pcb.regsi
		mov	es, [di].pcb.reges
		mov	ds, [di].pcb.regds
		pop	di
		iret

		else

		mov	di, StdGrp
		mov	ds, di
		lds	di, StdGrp:ReadyQ
		mov	[di].regax, ax
		mov	[di].regbx, bx
		mov	[di].regcx, cx
		mov	[di].regdx, dx
		mov	[di].regbp, bp
		mov	[di].regsi, si
		mov	[di].reges, es
		pop	[di].regdi
		pop	[di].regds
		pop	[di].regflags
		pop	[di].regip
		pop	[di].regcs
		mov	[di].regsp, sp
		mov	[di].regss, ss
		inc	wp [di].CPUTime
		jne	NoHOCPUTime
		inc	wp [di+2].CPUTime

NoHOCPUTime:
		cmp	wp [di].NextProc+2, 0
		je	RequeueDone

		mov	di, StdGrp
		mov	ds, di

		les	di, StdGrp:LastRdyQ
		mov	ax, wp StdGrp:ReadyQ
		mov	wp StdGrp:LastRdyQ, ax
		mov	wp es:[di].NextProc, ax
		mov	ax, wp StdGrp:ReadyQ+2
		mov	wp StdGrp:LastRdyQ+2, ax
		mov	wp es:[di].NextProc+2, ax
		les	di, StdGrp:ReadyQ
		mov	ax, wp es:[di].NextProc
		mov	wp StdGrp:ReadyQ, ax
		mov	ax, wp es:[di].NextProc+2
		mov	wp StdGrp:ReadyQ+2, ax
		xor	ax, ax
		mov     wp es:[di].NextProc, ax
		mov	wp es:[di].NextProc+2, ax
RequeueDone:
		mov	di, StdGrp
		mov	ds, di
		lds	di, StdGrp:ReadyQ
		mov	ss, [di].regss
		mov	sp, [di].regsp
		push	[di].regflags
		push	[di].regcs
		push	[di].regip
		push	[di].regdi
		mov	ax, [di].regax
		mov	bx, [di].regbx
		mov	cx, [di].regcx
		mov	dx, [di].regdx
		mov	bp, [di].regbp
		mov	si, [di].regsi
		mov	es, [di].reges
		mov	ds, [di].regds
		pop	di
		iret

		endif

sl_Yield	endp
		assume	ds:nothing, es:nothing





;============================================================================
;
; Coroutine support.
;
; COINIT- ES:DI contains the address of the current (default) process.
; COINIT will store away this address into the local CurCoroutine variable.
; Strictly speaking, you do not need to call this code as the system will
; use the "DefaultCortn" if you do not supply a PCB for the 1st process.
; However, this variable is not visible outside this file so all future
; references would have to be through the ES:DI value returned by COCALL.

		public	sl_coinit
sl_CoInit	proc	far
		assume	ds:StdGrp
		push	ax
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
		mov	wp StdGrp:CurCoroutine, di
		mov	wp StdGrp:CurCoroutine+2, es
		pop	ds
		pop	ax
		ret
sl_CoInit	endp


; COCALL- transfers control to a coroutine.  ES:DI contains the address
; of the PCB.  This routine transfers control to that coroutine and then
; returns a pointer to the caller's PCB in ES:DI.

		public	sl_cocall
sl_cocall	proc	far
		assume	ds:StdGrp
		pushf
		push	ds
		push	es			;Save these for later
		push	di
		push	ax
		mov	ax, StdGrp
		mov	ds, ax
		cli				;Critical region ahead.

		if	@version ge 600

; Save the current process' state:

		les	di, StdGrp:CurCoroutine
		pop	es:[di].pcb.regax
		mov	es:[di].pcb.regbx, bx
		mov	es:[di].pcb.regcx, cx
		mov	es:[di].pcb.regdx, dx
		mov	es:[di].pcb.regsi, si
		pop	es:[di].pcb.regdi
		mov	es:[di].pcb.regbp, bp
		pop	es:[di].pcb.reges
		pop	es:[di].pcb.regds
		pop	es:[di].pcb.regflags
		pop	es:[di].pcb.regip
		pop	es:[di].pcb.regcs
		mov	es:[di].pcb.regsp, sp
		mov	es:[di].pcb.regss, ss

		mov	bx, es			;Save so we can return in
		mov	cx, di			; ES:DI later.
		mov	dx, es:[di].pcb.regdi
		mov	es, es:[di].pcb.reges
		mov	di, dx			;Point es:di at new PCB

		mov	wp StdGrp:CurCoroutine, di
		mov	wp StdGrp:CurCoroutine+2, es

		mov	es:[di].pcb.regdi, cx	;The ES:DI return values.
		mov	es:[di].pcb.reges, bx

; Okay, switch to the new process:

		mov	ss, es:[di].pcb.regss
		mov	sp, es:[di].pcb.regsp
		mov	ax, es:[di].pcb.regax
		mov	bx, es:[di].pcb.regbx
		mov	cx, es:[di].pcb.regcx
		mov	dx, es:[di].pcb.regdx
		mov	si, es:[di].pcb.regsi
		mov	bp, es:[di].pcb.regbp
		mov	ds, es:[di].pcb.regds

		push	es:[di].pcb.regflags
		push	es:[di].pcb.regcs
		push	es:[di].pcb.regip
		push	es:[di].pcb.regdi
		mov	es, es:[di].pcb.reges
		pop	di
		iret



		else

		les	di, StdGrp:CurCoroutine
		pop	es:[di].regax
		mov	es:[di].regbx, bx
		mov	es:[di].regcx, cx
		mov	es:[di].regdx, dx
		mov	es:[di].regsi, si
		pop	es:[di].regdi
		mov	es:[di].regbp, bp
		pop	es:[di].reges
		pop	es:[di].regds
		pop	es:[di].regflags
		pop	es:[di].regip
		pop	es:[di].regcs
		mov	es:[di].regsp, sp
		mov	es:[di].regss, ss
		mov	bx, es
		mov	cx, di
		mov	dx, es:[di].regdi
		mov	es, es:[di].reges
		mov	di, dx
		mov	wp StdGrp:CurCoroutine, di
		mov	wp StdGrp:CurCoroutine+2, es
		mov	es:[di].regdi, cx
		mov	es:[di].reges, bx
		mov	ss, es:[di].regss
		mov	sp, es:[di].regsp
		mov	ax, es:[di].regax
		mov	bx, es:[di].regbx
		mov	cx, es:[di].regcx
		mov	dx, es:[di].regdx
		mov	si, es:[di].regsi
		mov	bp, es:[di].regbp
		mov	ds, es:[di].regds
		push	es:[di].regflags
		push	es:[di].regcs
		push	es:[di].regip
		push	es:[di].regdi
		mov	es, es:[di].reges
		pop	di
		iret

		endif

sl_cocall	endp


; CoCalll works just like cocall above, except the address of the pcb
; follows the call in the code stream rather than being passed in ES:DI.
; Note: this code does *not* return the caller's PCB address in ES:DI.
;

		public	sl_cocalll
sl_cocalll	proc	far
		assume	ds:StdGrp
		push	bp
		mov	bp, sp
		pushf
		push	ds
		push	es
		push	di
		push	ax
		mov	ax, StdGrp
		mov	ds, ax
		cli				;Critical region ahead.

		if	@version ge 600

; Save the current process' state:

		les	di, StdGrp:CurCoroutine
		pop	es:[di].pcb.regax
		mov	es:[di].pcb.regbx, bx
		mov	es:[di].pcb.regcx, cx
		mov	es:[di].pcb.regdx, dx
		mov	es:[di].pcb.regsi, si
		pop	es:[di].pcb.regdi
		pop	es:[di].pcb.reges
		pop	es:[di].pcb.regds
		pop	es:[di].pcb.regflags
		pop	es:[di].pcb.regbp
		pop	es:[di].pcb.regip
		pop	es:[di].pcb.regcs
		mov	es:[di].pcb.regsp, sp
		mov	es:[di].pcb.regss, ss

		mov	dx, es:[di].pcb.regip	;Get return address (ptr to
		mov	cx, es:[di].pcb.regcs	; PCB address.
		add	es:[di].pcb.regip, 4	;Skip ptr on return.
		mov	es, cx			;Get the ptr to the new pcb
		mov	di, dx			; address, then fetch the
		les	di, es:[di]		; pcb val.
		mov	wp StdGrp:CurCoroutine, di
		mov	wp StdGrp:CurCoroutine+2, es

; Okay, switch to the new process:

		mov	ss, es:[di].pcb.regss
		mov	sp, es:[di].pcb.regsp
		mov	ax, es:[di].pcb.regax
		mov	bx, es:[di].pcb.regbx
		mov	cx, es:[di].pcb.regcx
		mov	dx, es:[di].pcb.regdx
		mov	si, es:[di].pcb.regsi
		mov	bp, es:[di].pcb.regbp
		mov	ds, es:[di].pcb.regds

		push	es:[di].pcb.regflags
		push	es:[di].pcb.regcs
		push	es:[di].pcb.regip
		push	es:[di].pcb.regdi
		mov	es, es:[di].pcb.reges
		pop	di
		iret


		else

		les	di, StdGrp:CurCoroutine
		pop	es:[di].regax
		mov	es:[di].regbx, bx
		mov	es:[di].regcx, cx
		mov	es:[di].regdx, dx
		mov	es:[di].regsi, si
		pop	es:[di].regdi
		pop	es:[di].reges
		pop	es:[di].regds
		pop	es:[di].regflags
		pop	es:[di].regbp
		pop	es:[di].regip
		pop	es:[di].regcs
		mov	es:[di].regsp, sp
		mov	es:[di].regss, ss
		mov	dx, es:[di].regip
		mov	cx, es:[di].regcs
		add	es:[di].regip, 4
		mov	es, cx
		mov	di, dx
		les	di, es:[di]
		mov	wp StdGrp:CurCoroutine, di
		mov	wp StdGrp:CurCoroutine+2, es
		mov	ss, es:[di].regss
		mov	sp, es:[di].regsp
		mov	ax, es:[di].regax
		mov	bx, es:[di].regbx
		mov	cx, es:[di].regcx
		mov	dx, es:[di].regdx
		mov	si, es:[di].regsi
		mov	bp, es:[di].regbp
		mov	ds, es:[di].regds
		push	es:[di].regflags
		push	es:[di].regcs
		push	es:[di].regip
		push	es:[di].regdi
		mov	es, es:[di].reges
		pop	di
		iret

		endif

sl_cocalll	endp




;****************************************************************************
;
; WaitSemaph- Waits on a given semaphore.  If there is only one process in
;	      the ready queue, this will cause a deadlock!  But that's the
;	      programmer's fault, not ours.
;
; sl_WaitSemaph- ES:DI points at the semaphore.

		public	sl_WaitSemaph
sl_WaitSemaph	proc	far
		assume	ds:StdGrp

		if	@version ge 600

		dec	es:[di].semaphore.SemaCnt
		jns	NoWait



		pushf
		push	ds
		push	si
		cli

; Save the state of the current process so we can remove it from the
; Ready Queue:

		mov	si, StdGrp
		mov	ds, si
		lds	si, StdGrp:ReadyQ	;Get ptr to current PCB.
		mov	[si].pcb.regax, ax
		mov	[si].pcb.regbx, bx
		mov	[si].pcb.regcx, cx
		mov	[si].pcb.regdx, dx
		mov	[si].pcb.regbp, bp
		mov	[si].pcb.regdi, di
		mov	[si].pcb.reges, es
		pop	[si].pcb.regsi
		pop	[si].pcb.regds
		pop	[si].pcb.regflags
		pop	[si].pcb.regip
		pop	[si].pcb.regcs
		mov	[si].pcb.regsp, sp
		mov	[si].pcb.regss, ss

; Adjust the CPU time for the process we've just stopped.

		inc	wp [si].pcb.CPUTime
		jne	NoHOTime
		inc	wp [si+2].pcb.CPUTime

NoHOTime:

; Okay, now that we've saved away the info for this process, let's move
; it off the ready queue and onto the semaphore queue.  Start by checking
; to see if there is anything currently on the semaphore queue:

		mov	ax, StdGrp
		mov	ds, ax
		cmp	wp es:[di+2].semaphore.smaphrlst, 0	;Empty list?
		jne	JustSetEnd

; If the semaphore list is empty, move the current process from the ready
; queue to the semaphore list and make it the beginning and ending entry.

		mov	ax, wp StdGrp:ReadyQ			;Point both
		mov	wp es:[di].semaphore.smaphrlst, ax	; the head
		mov	wp es:[di].semaphore.endsmaphrlst, ax	; and tail
		mov	ax, wp StdGrp:ReadyQ+2			; pointers at
		mov	wp es:[di+2].semaphore.smaphrlst, ax	; this PCB.
		mov	wp es:[di+2].semaphore.endsmaphrlst, ax
		jmp	RmvFromRdy


; If there are other items in this semaphore list, just place the current
; process at the end of the queue.

JustSetEnd:	push	es
		push	di
		les	di, es:[di].semaphore.endsmaphrlst	;Link in the
		mov	ax, wp StdGrp:ReadyQ			; current
		mov	wp es:[di].pcb.NextProc, ax		; process to
		mov	ax, wp StdGrp:ReadyQ+2			; the sema-
		mov	wp es:[di+2].pcb.NextProc, ax		; phore chain.
		pop	di
		pop	es
		mov	ax, wp StdGrp:ReadyQ			;Point sema-
		mov	wp es:[di].semaphore.endsmaphrlst, ax	; phore end
		mov	ax, wp StdGrp:ReadyQ+2			; ptr to cur
		mov	wp es:[di+2].semaphore.endsmaphrlst, ax	; process.

; Now, remove this process from the ready queue.  Note there is no test to
; see if this is the last item on the ready queue.  It is the programmer's
; responsibility to prevent this (It could only happen if the programmer is
; playing with the private fields of the semaphore data structure or if
; s/he makes two successive calls to WaitSemaph).

RmvFromRdy:	les	di, StdGrp:ReadyQ
		mov	ax, wp es:[di+2].pcb.NextProc
		mov	wp StdGrp:ReadyQ+2, ax
		mov	ax, wp es:[di].pcb.NextProc
		mov	wp StdGrp:ReadyQ, ax
		xor	ax, ax				;Store NULL into the
		mov	wp es:[di].pcb.NextProc, ax	; link address to end
		mov	wp es:[di+2].pcb.NextProc, ax	; the semaphore list.


; Okay, transfer control to the (possibly new) procedure at the front of the
; ready queue:

		lds	si, StdGrp:ReadyQ
		mov	ss, [si].pcb.regss
		mov	sp, [si].pcb.regsp
		push	[si].pcb.regflags
		push	[si].pcb.regcs
		push	[si].pcb.regip
		push	[si].pcb.regsi
		mov	ax, [si].pcb.regax
		mov	bx, [si].pcb.regbx
		mov	cx, [si].pcb.regcx
		mov	dx, [si].pcb.regdx
		mov	bp, [si].pcb.regbp
		mov	di, [si].pcb.regdi
		mov	es, [si].pcb.reges
		mov	ds, [si].pcb.regds
		pop	si
		iret





		else




		dec	es:[di].SemaCnt
		js	DoWait
		jmp	NoWait
DoWait:		pushf
		push	ds
		push	si
		cli
		mov	si, StdGrp
		mov	ds, si
		lds	si, StdGrp:ReadyQ
		mov	[si].regax, ax
		mov	[si].regbx, bx
		mov	[si].regcx, cx
		mov	[si].regdx, dx
		mov	[si].regbp, bp
		mov	[si].regdi, di
		mov	[si].reges, es
		pop	[si].regsi
		pop	[si].regds
		pop	[si].regflags
		pop	[si].regip
		pop	[si].regcs
		mov	[si].regsp, sp
		mov	[si].regss, ss
		inc	wp [si].CPUTime
		jne	NoHOTime
		inc	wp [si+2].CPUTime
NoHOTime:
		mov	ax, StdGrp
		mov	ds, ax
		cmp	wp es:[di+2].smaphrlst, 0
		jne	JustSetEnd
		mov	ax, wp StdGrp:ReadyQ
		mov	wp es:[di].smaphrlst, ax
		mov	wp es:[di].endsmaphrlst, ax
		mov	ax, wp StdGrp:ReadyQ+2
		mov	wp es:[di+2].smaphrlst, ax
		mov	wp es:[di+2].endsmaphrlst, ax
		jmp	RmvFromRdy
JustSetEnd:	push	es
		push	di
		les	di, es:[di].endsmaphrlst
		mov	ax, wp StdGrp:ReadyQ
		mov	wp es:[di].NextProc, ax
		mov	ax, wp StdGrp:ReadyQ+2
		mov	wp es:[di+2].NextProc, ax
		pop	di
		pop	es
		mov	ax, wp StdGrp:ReadyQ
		mov	wp es:[di].endsmaphrlst, ax
		mov	ax, wp StdGrp:ReadyQ+2
		mov	wp es:[di+2].endsmaphrlst, ax
RmvFromRdy:	les	di, StdGrp:ReadyQ
		mov	ax, wp es:[di+2].NextProc
		mov	wp StdGrp:ReadyQ+2, ax
		mov	ax, wp es:[di].NextProc
		mov	wp StdGrp:ReadyQ, ax
		xor	ax, ax
		mov	wp es:[di].NextProc, ax
		mov	wp es:[di+2].NextProc, ax
		lds	si, StdGrp:ReadyQ
		mov	ss, [si].regss
		mov	sp, [si].regsp
		push	[si].regflags
		push	[si].regcs
		push	[si].regip
		push	[si].regsi
		mov	ax, [si].regax
		mov	bx, [si].regbx
		mov	cx, [si].regcx
		mov	dx, [si].regdx
		mov	bp, [si].regbp
		mov	di, [si].regdi
		mov	es, [si].reges
		mov	ds, [si].regds
		pop	si
		iret

		endif					;Version 6.00

NoWait:		ret
sl_WaitSemaph	endp




; sl_RlsSemaph-	Releases a semaphore.  If there are any items on the semaphore
;		list waiting for the semaphore, this guy moves the first such
;		item to the ready queue, immediately behind the current
;		process so that it will run next.
;
; sl_RlsSemaph-	Address of semaphore to release is passed in ES:DI

		public	sl_RlsSemaph
sl_RlsSemaph	proc	far

		if	@version ge 600

		inc	es:[di].semaphore.SemaCnt
		cmp	es:[di].semaphore.SemaCnt, 0
		jg	SmphIsFree

; If the semaphore count is less than or equal to zero, then there are some
; processes still on this semaphore queue.  Move the first one onto the
; ready queue.

		pushf
		push	ds
		push	es
		push	ax
		push	bx
		push	di
		cli

; First, remove this guy from the semaphore list.

		lds	bx, es:[di].semaphore.smaphrlst
		mov	ax, wp ds:[bx].pcb.NextProc
		mov	wp es:[di].semaphore.smaphrlst, ax
		mov	ax, wp ds:[bx+2].pcb.NextProc
		mov	wp es:[di+2].semaphore.smaphrlst, ax

; If last item in semaphore list, clear the end pointer.

		or	ax, ax
		jnz	NotAtEnd
		mov	wp es:[di].semaphore.endsmaphrlst, ax
		mov	wp es:[di+2].semaphore.endsmaphrlst, ax
NotAtEnd:

; Now add it to the ready queue

		mov	ax, ds		;Point ES:BX at current PCB
		mov	es, ax

		assume	ds:StdGrp
		mov	ax, StdGrp
		mov	ds, ax
		lds	di, StdGrp:LastRdyQ
		assume	ds:nothing

; Point the new pcb's NextProc field to the same place the current pcb's
; next field points:

		mov	wp es:[bx].pcb.NextProc, 0
		mov	wp es:[bx+2].pcb.NextProc, 0

; Point the last PCB's NextProc field at the new process.

		mov	wp ds:[di].pcb.NextProc, bx
		mov	wp ds:[di+2].pcb.NextProc, es

; Point LastRdyQ at the process we just added to the ready queue:

		mov	ax, StdGrp
		mov	ds, ax
		assume	ds:StdGrp
		mov	wp StdGrp:LastRdyQ, bx
		mov	wp StdGrp:LastRdyQ+2, es
QuitRls:
		pop	di
		pop	bx
		pop	ax
		pop	es
		pop	ds
		popf

SmphIsFree:	ret

		else

		inc	es:[di].SemaCnt
		cmp	es:[di].SemaCnt, 0
		jg	SmphIsFree
		pushf
		push	ds
		push	es
		push	ax
		push	bx
		push	di
		cli
		lds	bx, es:[di].smaphrlst
		mov	ax, wp ds:[bx].NextProc
		mov	wp es:[di].smaphrlst, ax
		mov	ax, wp ds:[bx+2].NextProc
		mov	wp es:[di+2].smaphrlst, ax
		or	ax, ax
		jnz	NotAtEnd
		mov	wp es:[di].endsmaphrlst, ax
		mov	wp es:[di+2].endsmaphrlst, ax
NotAtEnd:
		mov	ax, ds
		mov	es, ax
		assume	ds:StdGrp
		mov	ax, StdGrp
		mov	ds, ax
		lds	di, StdGrp:LastRdyQ
		assume	ds:nothing
		mov	wp es:[bx].NextProc, 0
		mov	wp es:[bx+2].NextProc, 0
		mov	wp ds:[di].NextProc, bx
		mov	wp ds:[di+2].NextProc, es
		mov	ax, StdGrp
		mov	ds, ax
		assume	ds:StdGrp
		mov	wp StdGrp:LastRdyQ, bx
		mov	wp StdGrp:LastRdyQ+2, es
QuitRls:
		pop	di
		pop	bx
		pop	ax
		pop	es
		pop	ds
		popf

SmphIsFree:	ret

		endif

sl_RlsSemaph	endp


;============================================================================


; ISRs for interrupts that the process manager patches into:

TimerISR	proc
		assume	ds:nothing
		pushf 				;Call the previous timer ISR
		call	stdgrp:TimerIntVect
		call	far ptr sl_Yield
		iret
TimerISR	endp



stdlib		ends
		end
