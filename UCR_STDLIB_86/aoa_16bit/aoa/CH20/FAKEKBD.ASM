		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

cseg		segment	para public 'code'
		assume	ds:nothing

;****************************************************************************
;
; PutInATBuffer-
;
; The following code sticks the scan code into the AT-class keyboard
; microcontroller chip and asks it to send the scan code back to us
; (through the hardware port).
;
; The AT keyboard controller:
;
; Data port is at I/O address 60h
; Status port is at I/O address 64h (read only)
; Command port is at I/O address 64h (write only)
;
; The controller responds to the following values sent to the command port:
;
; 20h - Read Keyboard Controller's Command Byte (KCCB) and send the data to
;       the data port (I/O address 60h).
;
; 60h - Write KCCB.  The next byte written to I/O address 60h is placed in
;       the KCCB.  The bits of the KCCB are defined as follows:
;
;	bit 7- Reserved, should be a zero
;	bit 6- IBM industrial computer mode.
;	bit 5- IBM industrial computer mode.
;       bit 4- Disable keyboard.
;       bit 3- Inhibit override.
;       bit 2- System flag
;	bit 1- Reserved, should be a zero.
;	bit 0- Enable output buffer full interrupt.
;
; AAh -	Self test
; ABh -	Interface test
; ACh - Diagnostic dump
; ADh - Disable keyboard
; AEh - Enable keyboard
; C0h - Read Keyboard Controller input port (equip installed)
; D0h - Read Keyboard Controller output port
; D1h - Write Keyboard Controller output port
; E0h - Read test inputs
; F0h-FFh - Pulse Output port.
;
; The keyboard controller output port is defined as follows:
;
;	bit 7 -	Keyboard data (output)
;	bit 6 - Keyboard clock (output)
;	bit 5 - Input buffer empty
;	bit 4 - Output buffer full
;	bit 3 - undefined
;	bit 2 - undefined
;	bit 1 - Gate A20
;	bit 0 - System reset (0=reset)
;
; The keyboard controller input port is defined as follows:
;
;	bit 7 - Keyboard inhibit switch (0=inhibited)
;	bit 6 - Display switch (0=color, 1= mono)
;	bit 5 - Manufacturing jumper
;	bit 4 - System board RAM (0=disable 2nd 256K RAM on system board).
;	bits 0-3 - undefined.
;
; The keyboard controller status port (64h) is defined as follows:
;
;	bit 1-	Set if input data (60h) not available.
;	bit 0-  Set if output port (60h) cannot accept data.



PutInATBuffer	proc	near
		assume	ds:nothing
		pushf
		push	ax
		push	bx
		push	cx
		push	dx


		mov	dl, al			;Save char to output.

; Wait until the keyboard controller does not contain data before
; proceeding with shoving stuff down its throat.

		xor	cx, cx
WaitWhileFull:	in	al, 64h
		test	al, 1
		loopnz	WaitWhileFull


; First things first, let's mask the interrupt controller chip (8259) to
; tell it to ignore interrupts coming from the keyboard.  However, turn the
; interrupts on so we properly process interrupts from other sources (this
; is especially important because we're going to wind up sending a false
; EOI to the interrupt controller inside the INT 9 BIOS routine).

		cli
		in	al, 21h			;Get current mask
		push	ax			;Save intr mask
		or	al, 2			;Mask keyboard interrupt
		out	21h, al

; Transmit the desired scan code to the keyboard controller.  Call this
; byte the new keyboard controller command (we've turned off the keyboard,
; so this won't affect anything).
;
; The following code tells the keyboard controller to take the next byte
; sent to it and use this byte as the KCCB:


		call	WaitToXmit
		mov	al, 60h			;Write new KCCB command.
		out	64h, al

; Send the scan code as the new KCCB:

		call	WaitToXmit
		mov	al, dl
		out	60h, al

; The following code instructs the system to transmit the KCCB (i.e., the
; scan code) to the system:

		call	WaitToXmit
		mov	al, 20h		;"Send KCCB" command.
		out	64h, al

		xor	cx, cx
Wait4OutFull:	in	al, 64h
		test	al, 1
		loopz	Wait4OutFull

; Okay, Send a 45h back as the new KCCB to allow the normal keyboard to work
; properly.

		call	WaitToXmit
		mov	al, 60h
		out	64h, al

		call	WaitToXmit
		mov	al, 45h
		out	60h, al

; Okay, execute an INT 9 routine so the BIOS (or whoever) can read the key
; we just stuffed into the keyboard controller.  Since we've masked INT 9
; at the interrupt controller, there will be no interrupt coming along from
; the key we shoved in the buffer.

DoInt9:         in	al, 60h			;Prevents ints from some codes.
		int	9         		;Simulate hardware kbd int.


; Just to be safe, reenable the keyboard:

		call	WaitToXmit
		mov	al, 0aeh
		out	64h, al

; Okay, restore the interrupt mask for the keyboard in the 8259a.

		pop	ax
		out	21h, al

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
		ret
PutInATBuffer	endp



; WaitToXmit-	Wait until it's okay to send a command byte to the keyboard
;		controller port.

WaitToXmit	proc	near
		push	cx
		push	ax
		xor	cx, cx
TstCmdPortLp:	in	al, 64h
		test	al, 2		;Check cntrlr input buffer full flag.
		loopnz	TstCmdPortLp
		pop	ax
		pop	cx
		ret
WaitToXmit	endp



;****************************************************************************
;
; PutInPS2Buffer- Like PutInATBuffer, it uses the keyboard controller chip
;		  to return the keycode.  However, PS/2 compatible controllers
;		  have an actual command to return keycodes.

PutInPS2Buffer	proc	near
		pushf
		push	ax
		push	bx
		push	cx
		push	dx

		mov	dl, al			;Save char to output.

; Wait until the keyboard controller does not contain data before
; proceeding with shoving stuff down its throat.

		xor	cx, cx
WaitWhileFull:	in	al, 64h
		test	al, 1
		loopnz	WaitWhileFull


; The following code tells the keyboard controller to take the next byte
; sent to it and return it as a scan code.


		call	WaitToXmit
		mov	al, 0d2h		;Return scan code command.
		out	64h, al

; Send the scan code:

		call	WaitToXmit
		mov	al, dl
		out	60h, al

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
		ret
PutInPS2Buffer	endp


; Main program - Simulates some keystrokes to demo the above code.

Main		proc

		mov	ax, cseg
		mov	ds, ax

		print
		byte	"Simulating keystrokes via Trace Flag",cr,lf
		byte	"This program places 'DIR' in the keyboard buffer"
		byte	cr,lf,0

		mov	al, 20h			;"D" down scan code
		call	PutInATBuffer
		mov	al, 0a0h		;"D" up scan code
		call	PutInATBuffer

		mov	al, 17h			;"I" down scan code
		call	PutInATBuffer
		mov	al, 97h			;"I" up scan code
		call	PutInATBuffer

		mov	al, 13h			;"R" down scan code
		call	PutInATBuffer
		mov	al, 93h			;"R" up scan code
		call	PutInATBuffer

		mov	al, 1Ch			;Enter down scan code
		call	PutInATBuffer
		mov	al, 9Ch			;Enter up scan code
		call	PutInATBuffer



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

