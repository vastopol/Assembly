StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
;
fp_status	dw	?
present		dw	0
FPU		dw	0
;
StdData		ends
;
;
;
;
StdLib		segment	para public 'slcode'
		assume	cs:StdGrp, ds:StdGrp
;
;	The purpose of this code is to allow the user the ability to identify
;	the processor and coprocessor that is currently in the system.  The
;	algorithm of the program is to first determine the processor id.
;	When that is accomplished, the program continues to then identify
;	whether a coprocessor exists in the system.  If a coprocessor or
;	integrated coprocessor exists, the program will identify the
;	coprocessor id.  If one does not exist, the program then terminates.
;
;	Returns in AX one of the following values:
;
;       	86	if 8088 or 8086 microprocessor
;		286	if 80286 microprocessor
;		386	if 80386 microprocessor
;		486	if 80486 microprocessor (or 486sx w/487 coprocessor)
;
;	Returns in BX one of the following values:
;
;		0	if no numeric coprocessor
;		87	if 8087 math coprocessor available
;		287	if 80287 math coprocessor available
;		387	if 80387 math coprocessor available
;		487	if 80486dx cpu or 486sx + 487 coprocessor
;
;	Originally created by the nice folks at Intel.  Modified for
;	inclusion in the standard library by rhyde 10/24/91.
;
;
;
		public	sl_cpuid
sl_cpuid	proc	far
		push	ds
		push	cx
;
		mov	ax, StdGrp
		mov	ds,ax		   ; set segment register
;
		mov	FPU, 0
;
;	8086 CPU check
;	Bits 12-15 are always set on the 8086 processor.
;
		pushf			; save EFLAGS
		pop	bx		; store EFLAGS in BX
		mov	ax,0fffh	;  clear bits 12-15
		and	ax,bx		;  in EFLAGS
		push	ax		; store new EFLAGS value on stack
		popf			; replace current EFLAGS value
		pushf			; set new EFLAGS
		pop	ax		; store new EFLAGS in AX
		and	ax,0f000h	; if bits 12-15 are set, then CPU
		cmp	ax,0f000h	; 	is an 8086/8088
		mov 	present, 86	; turn on 8086/8088 flag
		je	check_fpu	; if CPU is 8086/8088, check for 8087

;
;	80286 CPU check
;	Bits 12-15 are always clear on the 80286 processor.
;

		or	bx,0f000h	; try to set bits 12-15
		push 	bx
		popf
		pushf
		pop	ax
		and	ax,0f000h	; if bits 12-15 are cleared, then CPU
		mov 	present, 286    ; turn on 80286 flag
		jz	check_fpu	; if CPU is 80286, check for 80287

;
;	i386 CPU check
;	The AC bit, bit #18, is a new bit introduced in the EFLAGS register
;	on the i486 DX CPU to generate alignment faults.  This bit can be
;	set on the i486 DX CPU, but not on the i386 CPU.
;

		mov	bx,sp		; save current stack pointer to align it
		and	sp,not 3	; align stack to avoid AC fault
		db	66h
		pushf			; push original EFLAGS
		db	66h
		pop	ax		; get original EFLAGS
		db	66h
		mov	cx,ax		; save original EFLAGS
		db	66h		; xor EAX,40000h
		xor	ax,0		; flip AC bit in EFLAGS
		dw	4		; upper 16-bits of xor constant
		db	66h
		push	ax		; save for EFLAGS
		db	66h
		popf			; copy to EFLAGS
		db	66h
		pushf			; push EFLAGS
		db	66h
		pop	ax		; get new EFLAGS value
		db	66h
		xor	ax,cx		; if AC bit cannot be changed, is 386
		mov 	present, 386	; turn on i386 flag
		je	check_fpu   	; if CPU is i386, now check for 								;	80287/80387 MCP

;
;	i486 DX CPU / i487 SX MCP and i486 SX CPU checking
;
		mov 	present, 486	  ; turn on i486 flag

;
;	Co-processor checking begins here for the 8086/80286/i386 CPUs.
;	The algorithm is to determine whether or not the floating-point
;	status and control words can be written to.  If they are not, no
;	coprocessor exists.  If the status and control words can be written
;	to, the correct coprocessor is then determined depending on the
;	processor id.  Coprocessor checks are first performed for an 8086,
;	80286 and a i486 DX CPU.  If the coprocessor id is still
;	undetermined, the system must contain a i386 CPU.  The i386 CPU may
;	work with either an 80287 or an 80387.  The infinity of the
;	coprocessor must be checked to determine the correct coprocessor id.
;

check_fpu:	    			 ; check for 8087/80287/80387
		fninit			 ; reset FP status word
		mov 	fp_status,5a5ah	 ; init temp word to non-zero value
		fnstsw 	fp_status	 ; save FP status word
		mov	ax,fp_status	 ; check FP status word
		cmp 	al,0		 ; see if correct status with written
		jne 	exit		 ; jump if not Valid, no NPX installed

		fnstcw 	fp_status	 ; save FP control word
		mov 	ax,fp_status	 ; check FP control word
		and 	ax,103fh 	 ; see if selected parts looks OK
		cmp 	ax,3fh		 ; check that 1s & 0s correctly read
		jne 	exit	 ; jump if not Valid, no NPX installed

		cmp	present, 486	 ; check if i486 flag is on
		je 	is_486		 ; if so, jump to set 487
		jmp 	not_486		 ; else continue with 386 checking

is_486:
		mov	FPU, 487
		jmp 	exit

not_486:
		cmp 	present, 386	 ; check if i386 flag is on
		jne 	print_87_287	 ; if i386 flag not on, check NPX for
					 ; 8086/8088/80286
;
;   80287/80387 check for the i386 CPU
;
		fld1			 ; use dflt control from FNINIT
		fldz			 ; form infinity
		fdiv			 ; 8087/80287 says +inf = -inf
		fld	st		 ; form negative infinity
		fchs			 ; 80387 says +inf <> -inf
		fcompp			 ; see if the same and remove them
		fstsw 	fp_status	 ; look at status from FCOMPP
		mov	ax,fp_status
		mov 	FPU, 287
		sahf			   ; see if infinities matched
		jz 	restore_EFLAGS	   ; jump if 8087/80287 is present
		mov 	FPU, 387 	   ; set 80387 mode

restore_EFLAGS:
		db	66h
		push	cx		   ; push ECX
		db	66h
		popf			   ; restore original EFLAGS register
		mov	sp,bx		   ; restore original stack pointer
		jmp 	exit


print_87_287:
		cmp 	present, 86	   ; if 8086/8088 flag is on
		mov 	FPU, 87  	   ; set 8087 mode
		je 	exit
		mov 	FPU, 287 	   ; else CPU=80286, store 80287 flag
;
; Okay, return values to the calling program:
;
exit:		mov	ax, present
		mov	bx, FPU
		pop	cx
		pop	ds
		ret
sl_cpuid	endp
;
StdLib		ends
		end
