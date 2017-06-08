; GRABSCRN.ASM
;
; A short TSR to capture the current display screen and display it later.
;
; Note that this code does not patch into int 2Fh (multiplex interrupt)
; nor can you remove this code from memory except by rebooting.
; If you want to be able to do these two things (as well as check for
; a previous installation), see the chapter on resident programs.  Such
; code was omitted from this program because of length constraints.
;
;
; cseg and EndResident must occur before the standard library segments!

cseg		segment	para public 'code'
OldInt9		dword	?
ScreenSave	byte	4096 dup (?)
cseg		ends

; Marker segment, to find the end of the resident section.

EndResident	segment	para public 'Resident'
EndResident	ends

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


RShiftScan	equ	36h
LShiftScan	equ	2ah

; Bits for the shift/modifier keys

RShfBit		equ	1
LShfBit		equ	2

KbdFlags	equ	<byte ptr ds:[17h]>

byp		equ	<byte ptr>


; Screen segment address.  This value is for color displays only.
; Change to B000h if you want to use this program on a mono display.

ScreenSeg	equ	0B800h

cseg		segment	para public 'code'
		assume	ds:nothing



; MyInt9-	INT 9 ISR.  This routine reads the keyboard port to see
;		if a shift key scan code just came along.  If the right
;		shift bit is set in KbdFlags the a left shift key scan
;		code comes along, we want to copy the data from our
;		internal buffer to the screen's memory.  If the left shift
;		bit is set and a right shift key scan code comes along,
;		we want to copy the screen memory into our local array.
;		In any case (including none of the above), we always transfer
;		control to the original INT 9 handler.

MyInt9		proc	far
		push	ds
		push	ax

		mov	ax, 40h
		mov	ds, ax

		in	al, 60h			;Read the keyboard port.
		cmp	al, RShiftScan		;Right shift just go down?
		je	DoRight
		cmp	al, LShiftScan		;How about the left shift?
		jne	QuitMyInt9

; If this is the left scan code, see if the right shift key is already
; down.

		test	KbdFlags, RShfBit
		je	QuitMyInt9		;Branch if no

; Okay, right shift was down and we just saw left shift, copy our local
; data back to screen memory:

		pushf
		push	es
		push	cx
		push	di
		push	si
		mov	cx, 2048
		mov	si, cs
		mov	ds, si
		lea	si, ScreenSave
		mov	di, ScreenSeg
		mov	es, di
		xor	di, di
		jmp	DoMove

; Okay, we just saw the right shift key scan code, see if the left shift
; key is already down.  If so, save the current screen data to our local
; array.

DoRight:	test	KbdFlags, LShfBit
		je	QuitMyInt9

		pushf
		push	es
		push	cx
		push	di
		push	si
		mov	cx, 2048
		mov	ax, cs
		mov	es, ax
		lea	di, ScreenSave
		mov	si, ScreenSeg
		mov	ds, si
		xor	si, si

DoMove: 	cld
	rep	movsw
		pop	si
		pop	di
		pop	cx
		pop	es
		popf
QuitMyInt9:
		pop	ax
		pop	ds
		jmp	OldInt9
MyInt9		endp



Main		proc
		assume	ds:cseg

		mov	ax, cseg
		mov	ds, ax

		print
		byte	"Screen capture TSR",cr,lf
		byte	"Pressing left shift, then right shift, captures "
		byte	"the current screen.",cr,lf
		byte	"Pressing right shift, then left shift, displays "
		byte	"the last captured screen.",cr,lf
		byte	0

; Patch into the INT 9 interrupt vector.  Note that the
; statements above have made cseg the current data segment,
; so we can store the old INT 9 value directly into
; the OldInt9 variable.

		cli				;Turn off interrupts!
		mov	ax, 0
		mov	es, ax
		mov	ax, es:[9*4]
		mov	word ptr OldInt9, ax
		mov     ax, es:[9*4 + 2]
		mov	word ptr OldInt9+2, ax
		mov	es:[9*4], offset MyInt9
		mov	es:[9*4+2], cs
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



