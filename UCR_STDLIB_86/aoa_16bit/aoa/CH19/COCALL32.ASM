
		.386
		option	segment:use16

dseg		segment	para public 'data'

wp		equ	<word ptr>

; 32-bit PCB.  Note we only keep the L.O. 16 bits of SP since we are
; operating in real mode.

pcb32		struc
regsp		word	?
regss		word	?
regip		word	?
regcs		word	?

regeax		dword	?
regebx		dword	?
regecx		dword	?
regedx		dword	?
regesi		dword	?
regedi		dword	?
regebp		dword	?

regds		word	?
reges		word	?
regflags	dword	?
pcb32		ends


DefaultPCB	pcb32	<>
DefaultCortn	pcb32	<>

CurCoroutine	dd	DefaultCortn	;Points at the currently executing
					; coroutine.
dseg		ends


cseg		segment	para public 'slcode'

;============================================================================
;
; Coroutine support.
;
; COINIT- ES:DI contains the address of the current (default) process.

CoInit32	proc	far
		assume	ds:dseg
		push	ax
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	wp dseg:CurCoroutine, di
		mov	wp dseg:CurCoroutine+2, es
		pop	ds
		pop	ax
		ret
CoInit32	endp


; COCALL32- transfers control to a coroutine.  ES:DI contains the address
; of the PCB.  This routine transfers control to that coroutine and then
; returns a pointer to the caller's PCB in ES:DI.

cocall32	proc	far
		assume	ds:dseg
		pushfd
		push	ds
		push	es			;Save these for later
		push	edi
		push	eax
		mov	ax, dseg
		mov	ds, ax
		cli				;Critical region ahead.


; Save the current process' state:

		les	di, dseg:CurCoroutine
		pop	es:[di].pcb32.regeax
		mov	es:[di].pcb32.regebx, ebx
		mov	es:[di].pcb32.regecx, ecx
		mov	es:[di].pcb32.regedx, edx
		mov	es:[di].pcb32.regesi, esi
		pop	es:[di].pcb32.regedi
		mov	es:[di].pcb32.regebp, ebp

		pop	es:[di].pcb32.reges
		pop	es:[di].pcb32.regds
		pop	es:[di].pcb32.regflags
		pop	es:[di].pcb32.regip
		pop	es:[di].pcb32.regcs
		mov	es:[di].pcb32.regsp, sp
		mov	es:[di].pcb32.regss, ss

		mov	bx, es			;Save so we can return in
		mov	ecx, edi		; ES:DI later.
		mov	edx, es:[di].pcb32.regedi
		mov	es, es:[di].pcb32.reges
		mov	di, dx			;Point es:di at new PCB

		mov	wp dseg:CurCoroutine, di
		mov	wp dseg:CurCoroutine+2, es

		mov	es:[di].pcb32.regedi, ecx ;The ES:DI return values.
		mov	es:[di].pcb32.reges, bx

; Okay, switch to the new process:

		mov	ss, es:[di].pcb32.regss
		mov	sp, es:[di].pcb32.regsp
		mov	eax, es:[di].pcb32.regeax
		mov	ebx, es:[di].pcb32.regebx
		mov	ecx, es:[di].pcb32.regecx
		mov	edx, es:[di].pcb32.regedx
		mov	esi, es:[di].pcb32.regesi
		mov	ebp, es:[di].pcb32.regebp
		mov	ds, es:[di].pcb32.regds

		push	es:[di].pcb32.regflags
		push	es:[di].pcb32.regcs
		push	es:[di].pcb32.regip
		push	es:[di].pcb32.regedi
		mov	es, es:[di].pcb32.reges
		pop	edi
		iret
cocall32	endp


; CoCall32l works just like cocall above, except the address of the pcb
; follows the call in the code stream rather than being passed in ES:DI.
; Note: this code does *not* return the caller's PCB address in ES:DI.
;

cocall32l	proc	far
		assume	ds:dseg
		push	ebp
		mov	bp, sp
		pushfd
		push	ds
		push	es
		push	edi
		push	eax
		mov	ax, dseg
		mov	ds, ax
		cli				;Critical region ahead.

; Save the current process' state:

		les	di, dseg:CurCoroutine
		pop	es:[di].pcb32.regeax
		mov	es:[di].pcb32.regebx, ebx
		mov	es:[di].pcb32.regecx, ecx
		mov	es:[di].pcb32.regedx, edx
		mov	es:[di].pcb32.regesi, esi
		pop	es:[di].pcb32.regedi
		pop	es:[di].pcb32.reges
		pop	es:[di].pcb32.regds
		pop	es:[di].pcb32.regflags
		pop	es:[di].pcb32.regebp
		pop	es:[di].pcb32.regip
		pop	es:[di].pcb32.regcs
		mov	es:[di].pcb32.regsp, sp
		mov	es:[di].pcb32.regss, ss

		mov	dx, es:[di].pcb32.regip	;Get return address (ptr to
		mov	cx, es:[di].pcb32.regcs	; PCB address.
		add	es:[di].pcb32.regip, 4	;Skip ptr on return.
		mov	es, cx			;Get the ptr to the new pcb
		mov	di, dx			; address, then fetch the
		les	di, es:[di]		; pcb val.
		mov	wp dseg:CurCoroutine, di
		mov	wp dseg:CurCoroutine+2, es

; Okay, switch to the new process:

		mov	ss, es:[di].pcb32.regss
		mov	sp, es:[di].pcb32.regsp
		mov	eax, es:[di].pcb32.regeax
		mov	ebx, es:[di].pcb32.regebx
		mov	ecx, es:[di].pcb32.regecx
		mov	edx, es:[di].pcb32.regedx
		mov	esi, es:[di].pcb32.regesi
		mov	ebp, es:[di].pcb32.regebp
		mov	ds, es:[di].pcb32.regds

		push	es:[di].pcb32.regflags
		push	es:[di].pcb32.regcs
		push	es:[di].pcb32.regip
		push	es:[di].pcb32.regedi
		mov	es, es:[di].pcb32.reges
		pop	edi
		iret


cocall32l	endp
cseg		ends
		end