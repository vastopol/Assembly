; LEDSHOW.ASM
;
; This short TSR creates a light show on the keyboard's LEDs.  For space
; reasons, this code does not implement a multiplex handler nor can you
; remove this TSR once installed.  See the chapter on resident programs
; for details on how to do this.
;
; cseg and EndResident must occur before the standard library segments!

cseg		segment	para public 'code'
cseg		ends

; Marker segment, to find the end of the resident section.

EndResident	segment	para public 'Resident'
EndResident	ends

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


byp		equ	<byte ptr>

cseg		segment	para public 'code'
		assume	cs:cseg, ds:cseg






; SetCmd-	Sends the command byte in the AL register to the 8042
;		keyboard microcontroller chip (command register at
;		port 64h).

SetCmd		proc	near
		push	cx
		push	ax		;Save command value.
		cli			;Critical region, no ints now.

; Wait until the 8042 is done processing the current command.

		xor	cx, cx		;Allow 65,536 times thru loop.
Wait4Empty:	in	al, 64h		;Read keyboard status register.
		test	al, 10b		;Input buffer full?
		loopnz	Wait4Empty	;If so, wait until empty.

; Okay, send the command to the 8042:

		pop	ax		;Retrieve command.
		out	64h, al
		sti			;Okay, ints can happen again.
		pop	cx
		ret
SetCmd		endp




; SendCmd-	The following routine sends a command or data byte to the
;		keyboard data port (port 60h).

SendCmd		proc	near
		push	ds
		push	bx
		push	cx
		mov	cx, 40h
		mov	ds, cx
		mov	bx, ax		;Save data byte

		mov	al, 0ADh		;Disable kbd for now.
		call	SetCmd

		cli			;Disable ints while accessing HW.

; Wait until the 8042 is done processing the current command.

		xor	cx, cx			;Allow 65,536 times thru loop.
Wait4Empty:	in	al, 64h			;Read keyboard status register.
		test	al, 10b			;Input buffer full?
		loopnz	Wait4Empty		;If so, wait until empty.

; Okay, send the data to port 60h

		mov	al, bl
		out	60h, al

		mov	al, 0AEh		;Reenable keyboard.
		call	SetCmd
		sti				;Allow interrupts now.

		pop	cx
		pop	bx
		pop	ds
		ret
SendCmd		endp


; SetLEDs-	Writes the value in AL to the LEDs on the keyboard.
;		Bits 0..2 correspond to scroll, num, and caps lock,
;		respectively.

SetLEDs		proc	near
		push	ax
		push	cx

		mov	ah, al			;Save LED bits.

		mov	al, 0EDh		;8042 set LEDs cmd.
		call    SendCmd			;Send the command to 8042.
		mov	al, ah			;Get parameter byte
		call	SendCmd			;Send parameter to the 8042.

		pop	cx
		pop	ax
		ret
SetLEDs		endp



; MyInt1C-	Every 1/4 seconds (every 4th call) this routine
;		rotates the LEDs to produce an interesting light show.

CallsPerIter	equ	4
CallCnt		byte	CallsPerIter
LEDIndex	word	LEDTable
LEDTable	byte	111b, 110b, 101b, 011b,111b, 110b, 101b, 011b
		byte	111b, 110b, 101b, 011b,111b, 110b, 101b, 011b
		byte	111b, 110b, 101b, 011b,111b, 110b, 101b, 011b
		byte	111b, 110b, 101b, 011b,111b, 110b, 101b, 011b

		byte	000b, 100b, 010b, 001b, 000b, 100b, 010b, 001b
		byte	000b, 100b, 010b, 001b, 000b, 100b, 010b, 001b
		byte	000b, 100b, 010b, 001b, 000b, 100b, 010b, 001b
		byte	000b, 100b, 010b, 001b, 000b, 100b, 010b, 001b

		byte	000b, 001b, 010b, 100b, 000b, 001b, 010b, 100b
		byte	000b, 001b, 010b, 100b, 000b, 001b, 010b, 100b
		byte	000b, 001b, 010b, 100b, 000b, 001b, 010b, 100b
		byte	000b, 001b, 010b, 100b, 000b, 001b, 010b, 100b

                byte	010b, 001b, 010b, 100b, 010b, 001b, 010b, 100b
		byte	010b, 001b, 010b, 100b, 010b, 001b, 010b, 100b
		byte	010b, 001b, 010b, 100b, 010b, 001b, 010b, 100b
		byte	010b, 001b, 010b, 100b, 010b, 001b, 010b, 100b

		byte	000b, 111b, 000b, 111b, 000b, 111b, 000b, 111b
		byte	000b, 111b, 000b, 111b, 000b, 111b, 000b, 111b
		byte	000b, 111b, 000b, 111b, 000b, 111b, 000b, 111b
		byte	000b, 111b, 000b, 111b, 000b, 111b, 000b, 111b
TableEnd	equ	this byte

OldInt1C	dword	?

MyInt1C		proc	far
		assume	ds:cseg

		push	ds
		push	ax
		push	bx

		mov	ax, cs
		mov	ds, ax

		dec	CallCnt
		jne	NotYet
		mov	CallCnt, CallsPerIter	;Reset call count.
		mov	bx, LEDIndex
		mov	al, [bx]
		call	SetLEDs
		inc	bx
		cmp	bx, offset TableEnd
		jne	SetTbl
		lea	bx, LEDTable
SetTbl:		mov	LEDIndex, bx
NotYet:		pop	bx
		pop	ax
		pop	ds
		jmp	cs:OldInt1C
MyInt1C		endp


Main		proc

		mov	ax, cseg
		mov	ds, ax

		print
		byte	"LED Light Show",cr,lf
		byte	"Installing....",cr,lf,0

; Patch into the INT 9 and INT 16 interrupt vectors.  Note that the
; statements above have made cseg the current data segment,
; so we can store the old INT 9 and INT 16 values directly into
; the OldInt9 and OldInt16 variables.

		cli				;Turn off interrupts!
		mov	ax, 0
		mov	es, ax
		mov	ax, es:[1Ch*4]
		mov	word ptr OldInt1C, ax
		mov     ax, es:[1Ch*4 + 2]
		mov	word ptr OldInt1C+2, ax
		mov	es:[1Ch*4], offset MyInt1C
		mov	es:[1Ch*4+2], cs
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
