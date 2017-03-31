		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

cseg		segment	para public 'code'
		assume	ds:nothing

; ScanCode must be in the Code segment.

ScanCode	db	0



;****************************************************************************
;
; KbdSim- Passes the scan code in AL through the keyboard controller
; using the trace flag.  The way this works is to turn on the
; trace bit in the flags register.  Each instruction then causes a trace
; trap.  The (installed) trace handler then looks at each instruction to
; handle IN, OUT, INT, and other special instructions.  Upon encountering
; an IN AL, 60 (or equivalent) this code simulates the instruction and
; returns the specified scan code rather than actually executing the IN
; instruction.  Other instructions need special treatment as well.  See
; the code for details.  This code is pretty good at simulating the hardware,
; but it runs fairly slow and has a few compatibility problems.


KbdSim		proc	near

		pushf
		push	es
		push	ax
		push	bx


		xor	bx, bx			;Point es at int vector tbl
		mov	es, bx			; (to simulate INT 9).
		cli				;No interrupts for now.
		mov	cs:ScanCode, al		;Save output scan code.

		push	es:[1*4]		;Save current INT 1 vector
		push	es:2[1*4]		; so we can restore it later.



; Point the INT 1 vector at our INT 1 handler:

		mov	word ptr es:[1*4], offset MyInt1
		mov	word ptr es:[1*4 + 2], cs



; Turn on the trace trap:

		pushf
		pop	ax
		or	ah, 1
		push	ax
		popf


; Simulate an INT 9 instruction.  Note: cannot actually execute INT 9 here
; since INT instructions turn off the trace operation.


		pushf
		call	dword ptr es:[9*4]


; Turn off the trace operation:


		pushf
		pop	ax
		and	ah, 0feh		;Clear trace bit.
		push	ax
		popf


; Disable trace operation.


		pop	es:[1*4 + 2]		;Restore previous INT 1
		pop	es:[1*4]		; handler.


; Okay, we're done.  Restore registers and return.

VMDone:		pop	bx
		pop	ax
		pop	es
		popf
		ret
KbdSim		endp



;----------------------------------------------------------------------------
;
; MyInt1- Handles the trace trap (INT 1).  This code looks at the next
; opcode to determine if it is one of the special opcodes we have to
; handle ourselves.


MyInt1		proc	far
		push	bp
		mov	bp, sp		;Gain access to return adrs via BP.
		push	bx
		push	ds

; If we get down here, it's because this trace trap is directly due to
; our having punched the trace bit.  Let's process the trace trap to
; simulate the 80x86 instruction set.
;
; Get the return address into DS:BX

NextInstr:	lds	bx, 2[bp]

; The following is a special case to quickly eliminate most opcodes and
; speed up this code by a tiny amount.

		cmp	byte ptr [bx], 0cdh	;Most opcodes are less than
		jnb	NotSimpleInstr		; 0cdh, hence we quickly
		pop	ds			; return back to the real
		pop	bx			; program.
		pop	bp
		iret

NotSimpleInstr:	je	IsIntInstr	;If it's an INT instruction.

		mov	bx, [bx]	;Get current instruction's opcode.
		cmp	bl, 0e8h	;CALL opcode
		je	ExecInstr
		jb	TryInOut0

		cmp	bl, 0ech	;IN al, dx instr.
		je	MayBeIn60
		cmp	bl, 0eeh	;OUT dx, al instr.
		je	MayBeOut20
		pop	ds		;A normal instruction if we get
		pop	bx		; down here.
		pop	bp
		iret

TryInOut0:	cmp	bx, 60e4h	;IN al, 60h instr.
		je	IsINAL60
		cmp	bx, 20e6h	;out 20, al instr.
		je	IsOut20

; If it wasn't one of our magic instructions, execute it and continue.

ExecInstr:	pop	ds
		pop	bx
		pop	bp
		iret

; If this instruction is IN AL, DX we have to look at the value in DX to
; determine if it's really an IN AL, 60h instruction.

MayBeIn60:	cmp	dx, 60h
		jne	ExecInstr
		inc	word ptr 2[bp]		;Skip over this 1 byte instr.
		mov	al, cs:ScanCode
		jmp	NextInstr

; If this is an IN AL, 60h instruction, simulate it by loading the current
; scan code into AL.

IsInAL60:	mov	al, cs:ScanCode
		add	word ptr 2[bp], 2	;Skip over this 2-byte instr.
		jmp     NextInstr


; If this instruction is OUT DX, AL we have to look at DX to see if we're
; outputting to location 20h (8259).

MayBeOut20:	cmp	dx, 20h
		jne	ExecInstr
		inc	word ptr 2[bp]		;Skip this 1 byte instruction.
		jmp	NextInstr

; If this is an OUT 20h, al instruction, simply skip over it.

IsOut20:	add	word ptr 2[bp], 2	;Skip instruction.
		jmp	NextInstr


; IsIntInstr- Execute this code if it's an INT instruction.
;
; The problem with the INT instructions is that they reset the trace bit
; upon execution.  For certain guys (see above) we can't have that.
;
; Note: at this point the stack looks like the following:
;
;	flags
;
;	rtn cs -+
;		|
;	rtn ip	+-- Points at next instr the CPU will execute.
;	bp
;	bx
;	ds
;
; We need to simulate the appropriate INT instruction by:
;
;	(1) adding two to the return address on the stack (so it returns
;	    beyond the INT instruction.
;	(2) pushing the flags onto the stack.
;	(3) pushing a phony return address onto the stack which simulates
;	    the INT 1 interrupt return address but which "returns" us to
;	    the specified interrupt vector handler.
;
; All this results in a stack which looks like the following:
;
;	flags
;
;	rtn cs -+
;		|
;	rtn ip	+-- Points at next instr beyond the INT instruction.
;
;	flags	--  Bogus flags to simulate those pushed by INT instr.
;
;	rtn cs -+
;		|
;	rtn ip  +-- "Return address" which points at the ISR for this INT instr.
;	bp
;	bx
;	ds


IsINTInstr:     add	word ptr 2[bp], 2	;Bump rtn adrs beyond INT instr.
		mov	bl, 1[bx]
		mov	bh, 0
		shl	bx, 1			;Multiply by 4 to get vector
		shl	bx, 1			; address.

		push	[bp-0]			;Get and save BP
		push	[bp-2]			;Get and save BX.
		push	[bp-4]			;Get and save DS.

		push	cx
		xor	cx, cx			;Point DS at interrupt
		mov	ds, cx			; vector table.

		mov	cx, [bp+6]		;Get original flags.
		mov	[bp-0], cx		;Save as pushed flags.

		mov	cx, ds:2[bx]		;Get vector and use it as
		mov	[bp-2], cx		; the return address.
		mov	cx, ds:[bx]
		mov	[bp-4], cx

		pop	cx
		pop	ds
		pop	bx
		pop	bp
		iret
;
MyInt1		endp




; Main program - Simulates some keystrokes to demo the above code.

Main		proc

		mov	ax, cseg
		mov	ds, ax

		print
		byte	"Simulating keystrokes via Trace Flag",cr,lf
		byte	"This program places 'DIR' in the keyboard buffer"
		byte	cr,lf,0

		mov	al, 20h			;"D" down scan code
		call	KbdSim
		mov	al, 0a0h		;"D" up scan code
		call	KbdSim

		mov	al, 17h			;"I" down scan code
		call	KbdSim
		mov	al, 97h			;"I" up scan code
		call	KbdSim

		mov	al, 13h			;"R" down scan code
		call	KbdSim
		mov	al, 93h			;"R" up scan code
		call	KbdSim

		mov	al, 1Ch			;Enter down scan code
		call	KbdSim
		mov	al, 9Ch			;Enter up scan code
		call	KbdSim



		ExitPgm
Main		endp


cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main

