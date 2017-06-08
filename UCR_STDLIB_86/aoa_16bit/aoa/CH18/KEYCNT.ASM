; This is an example of an active TSR that counts keyboard interrupts
; once activated.

; The resident segment definitions must come before everything else.

ResidentSeg	segment	para public 'Resident'
ResidentSeg	ends

EndResident	segment	para public 'EndRes'
EndResident	ends

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


; Resident segment that holds the TSR code:

ResidentSeg	segment	para public 'Resident'
		assume	cs:ResidentSeg, ds:nothing

; The following variable counts the number of keyboard interrupts

KeyIntCnt	word	0

; These two variables contain the original INT 9 and INT 16h
; interrupt vector values:

OldInt9		dword	?
OldInt16	dword	?


; MyInt9-	The system calls this routine every time a keyboard
;		interrupt occus.  This routine increments the
;		KeyIntCnt variable and then passes control on to the
;		original Int9 handler.

MyInt9		proc	far
		inc	ResidentSeg:KeyIntCnt
		jmp	ResidentSeg:OldInt9
MyInt9		endp




; MyInt16-	This is the passive component of this TSR.  An
;		application explicitly calls this routine with an
;		INT 16h instruction.  If AH contains 0FFh, this
;		routine returns the number of keyboard interrupts
;		in the AX register.  If AH contains any other value,
;		this routine passes control to the original INT 16h
;		(keyboard trap) handler.

MyInt16		proc	far
		cmp	ah, 0FFh
		je	ReturnCnt
		jmp	ResidentSeg:OldInt16	;Call original handler.

; If AH=0FFh, return the keyboard interrupt count

ReturnCnt:	mov	ax, ResidentSeg:KeyIntCnt
		iret
MyInt16		endp


ResidentSeg	ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:ResidentSeg

Main		proc
		meminit

		mov	ax, ResidentSeg
		mov	ds, ax
		mov	ax, 0
		mov	es, ax

		print
		byte	"Keyboard interrupt counter TSR program",cr,lf
		byte	"Installing....",cr,lf,0

; Patch into the INT 9 and INT 16 interrupt vectors.  Note that the
; statements above have made ResidentSeg the current data segment,
; so we can store the old INT 9 and INT 16 values directly into
; the OldInt9 and OldInt16 variables.

		cli				;Turn off interrupts!
		mov	ax, es:[9*4]
		mov	word ptr OldInt9, ax
		mov     ax, es:[9*4 + 2]
		mov	word ptr OldInt9+2, ax
		mov	es:[9*4], offset MyInt9
		mov	es:[9*4+2], seg ResidentSeg

		mov	ax, es:[16h*4]
		mov	word ptr OldInt16, ax
		mov     ax, es:[16h*4 + 2]
		mov	word ptr OldInt16+2, ax
		mov	es:[16h*4], offset MyInt16
		mov	es:[16h*4+2], seg ResidentSeg
		sti				;Okay, ints back on.

; We're hooked up, the only thing that remains is to terminate and
; stay resident.

		print
		byte	"Installed.",cr,lf,0

		mov	ah, 62h			;Get this program's PSP
		int	21h			; value.

		mov	dx, EndResident		;Compute size of program.
		sub	dx, bx
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
