; INT17.ASM
;
; A short passive TSR that replaces the BIOS' int 17h handler.
; This routine demonstrates the function of each of the int 17h
; functions that a standard BIOS would provide.
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

OldInt17	dword	?


; BIOS variables:

PrtrBase	equ	8
PrtrTimeOut	equ	78h




; This code handles the INT 17H operation.  INT 17H is the BIOS routine
; to send data to the printer and report on the printer's status.  There
; are three different calls to this routine, depending on the contents
; of the AH register.  The DX register contains the printer port number.
;
; DX=0 -- Use LPT1:
; DX=1 -- Use LPT2:
; DX=2 -- Use LPT3:
; DX=3 -- Use LPT4:
;
; AH=0 -- Print the character in AL to the printer.  Printer status is
;	  returned in AH.  If bit #0 = 1 then a timeout error occurred.
;
; AH=1 -- Initialize printer.  Status is returned in AH.
;
; AH=2 -- Return printer status in AH.
;
;
; The status bits returned in AH are as follows:
;
;  Bit    Function			Non-error values
;  ---   --------------------------     ----------------
;   0     1=time out error			0
;   1       unused				x
;   2       unused				x
;   3     1=I/O error				0
;   4     1=selected, 0=deselected.		1
;   5     1=out of paper			0
;   6     1=acknowledge				x
;   7     1=not busy				x
;
; Note that the hardware returns bit 3 with zero if an error has occurred,
; with one if there is no error.  The software normally inverts this bit
; before returning it to the caller.
;
;
; Printer port hardware locations:
;
; There are three ports used by the printer hardware:
;
; PrtrPortAdrs   ---  Output port where data is sent to printer (8 bits).
; PrtrPortAdrs+1 ---  Input port where printer status can be read (8 bits).
; PrtrPortAdrs+2 ---  Output port where control information is sent to the
;		      printer.
;
; Data output port- 8-bit data is transmitted to the printer via this port.
;
; Input status port:
;			bit 0: unused.
;			bit 1: unused.
;			bit 2: unused.
;
;			bit 3: -Error, normally this bit means that the
;				printer has encountered an error.  However,
;				with the P101 installed this is a data
;				return line for the keyboard scan.
;
;			bit 4: +SLCT, normally this bit is used to determine
;				if the printer is selected or not.  With the
;				P101 installed this is a data return
;				line for the keyboard scan.
;
;			bit 5: +PE, a 1 in this bit location means that the
;				printer has detected the end of paper.  On
;				many printer ports, this bit has been found
;				to be inoperative.
;
;			bit 6: -ACK, A zero in this bit position means that
;				the printer has accepted the last character
;				and is ready to accept another.  This bit
;				is not normally used by the BIOS as bit 7
;				also provides this function (and more).
;
;			bit 7: -Busy, When this signal is active (0) the
;				printer is busy and cannot accept data.
;				When this bit is set to one, the printer
;				can accept another character.
;
;
;
; Output control port:
;
; 			Bit 0: +Strobe, A 0.5 us (minimum) active high pulse
;				on this bit clocks the data latched into the
;				printer data output port to the printer.
;
;			Bit 1: +Auto FD XT - A 1 stored at this bit causes
;				the printer to line feed after a line is
;				printed.  On some printer interfaces (e.g.,
;				the Hercules Graphics Card) this bit is
;				inoperative.
;
;			Bit 2: -INIT, a zero on this bit (for a minimum of
;				50 us) will cause the printer to (re)init-
;				ialize itself.
;
;			Bit 3: +SLCT IN, a one in this bit selects the
;				printer.  A zero will cause the printer to
;				go off-line.
;
;			Bit 4: +IRQ ENABLE, a one in this bit position
;				allows an interrupt to occur when -ACK
;				changes from one to zero.
;
;			Bit 5: Direction control on BI-DIR port. 0=output,
;			       1=input.
;			Bit 6: reserved, must be zero.
;			Bit 7: reserved, must be zero.

MyInt17		proc	far
		assume	ds:nothing

		push	ds
		push	bx
		push	cx
		push	dx

		mov	bx, 40h			;Point DS at BIOS vars.
		mov	ds, bx

		cmp	dx, 3			;Must be LPT1..LPT4.
		ja	InvalidPrtr

		cmp	ah, 0		;Branch to the appropriate code for
		jz	PrtChar		; the printer function
		cmp	ah, 2
		jb	PrtrInit
		je	PrtrStatus

; If they passed us an opcode we don't know about, just return.

InvalidPrtr:	jmp	ISR17Done



; Initialize the printer by pulsing the init line for at least 50 us.
; The delay loop below will delay well beyond 50 usec even on the fastest
; machines.

PrtrInit:	mov	bx, dx			;Get printer port value.
		shl	bx, 1			;Convert to byte index.
		mov	dx, PrtrBase[bx]	;Get printer base address.
		test	dx, dx			;Does this printer exist?
		je	InvalidPrtr		;Quit if no such printer.
		add	dx, 2			;Point dx at control reg.
		in	al, dx			;Read current status.
		and	al, 11011011b		;Clear INIT/BIDIR bits.
		out	dx, al			;Reset printer.
		mov	cx, 0			;This will produce at least
PIDelay:	loop	PIDelay			; a 50 usec delay.
		or	al, 100b		;Stop resetting printer.
		out	dx, al
		jmp	ISR17Done


; Return the current printer status.  This code reads the printer status
; port and formats the bits for return to the calling code.

PrtrStatus:	mov	bx, dx			;Get printer port value.
		shl	bx, 1			;Convert to byte index.
		mov	dx, PrtrBase[bx]	;Base address of printer port.
		mov	al, 00101001b		;Dflt: every possible error.
		test	dx, dx			;Does this printer exist?
		je	InvalidPrtr		;Quit if no such printer.
		inc	dx			;Point at status port.
		in	al, dx			;Read status port.
		and	al, 11111000b		;Clear unused/timeout bits.
		jmp	ISR17Done



; Print the character in the accumulator!

PrtChar:        mov	bx, dx
		mov	cl, PrtrTimeOut[bx]	;Get time out value.
		shl	bx, 1			;Convert to byte index.
		mov	dx, PrtrBase[bx]	;Get Printer port address
		or	dx, dx			;Non-nil pointer?
		jz	NoPrtr2			; Branch if a nil ptr

; The following code checks to see if an acknowlege was received from
; the printer.  If this code waits too long, a time-out error is returned.
; Acknowlege is supplied in bit #7 of the printer status port (which is
; the next address after the printer data port).

		push	ax
		inc	dx			;Point at status port
		mov	bl, cl			;Put timeout value in bl
		mov	bh, cl			; and bh.
WaitLp1:	xor	cx, cx			;Init count to 65536.
WaitLp2:	in	al, dx			;Read status port
		mov	ah, al			;Save status for now.
		test	al, 80h			;Printer acknowledge?
		jnz	GotAck			;Branch if acknowledge.
		loop	WaitLp2			;Repeat 65536 times.
		dec	bl			;Decrement time out value.
		jnz	WaitLp1			;Repeat 65536*TimeOut times.

; See if the user has selected no timeout:

		cmp     bh, 0
		je	WaitLp1

; TIMEOUT ERROR HAS OCCURRED!
;
; A timeout - I/O error is returned to the system at this point.
; Either we fall through to this point from above (time out error) or
; the referenced printer port doesn't exist.  In any case, return an error.

NoPrtr2:	or	ah, 9			;Set timeout-I/O error flags
		and	ah, 0F9h		;Turn off unused flags.
		xor	ah, 40h			;Flip busy bit.

; Okay, restore registers and return to caller.

		pop	cx			;Remove old ax.
		mov	al, cl			;Restore old al.
		jmp	ISR17Done


; If the printer port exists and we've received an acknowlege, then it's
; okay to transmit data to the printer.  That job is handled down here.

GotAck:		mov	cx, 16			;Short delay if crazy prtr
GALp:		loop	GALp			; needs hold time after ack.
		pop	ax			;Get char to output and
		push	ax			; save again.
		dec	dx			;Point DX at printer port.
		pushf				;Turn off interrupts for now.
		cli
		out	dx, al			;Output data to the printer.

; The following short delay gives the data time to travel through the
; parallel lines.  This makes sure the data arrives at the printer before
; the strobe (the times can vary depending upon the capacitance of the
; parallel cable's lines).

		mov	cx, 16			;Give data time to settle
DataSettleLp:	loop	DataSettleLp		; before sending strobe.

; Now that the data has been latched on the printer data output port, a
; strobe must be sent to the printer.  The strobe line is connected to
; bit zero of the printer port.  Also note that this clears bit 5 of the
; control port.  This ensures that the port continues to operate as an
; output port if it is a bidirectional device.  This code also clears bits
; six and seven which IBM claims should be left zero.

		inc	dx			;Point DX at the printer
		inc	dx			; control output port.
		in	al, dx			;Get current control bits.
		and	al, 01eh		;Force strobe line to zero and
		out	dx, al			; make sure it's an output port.


		mov	cx, 16			;Short delay to allow data
Delay0:		loop	Delay0			; to become good.

		or	al, 1			;Send out the (+) strobe.
		out	dx, al			;Output (+) strobe to bit 0

		mov	cx, 16			;Short delay to lengthen strobe
StrobeDelay:	loop	StrobeDelay

		and	al, 0FEh		;Clear the strobe bit.
		out	dx, al			;Output to control port.
		popf				;Restore interrupts.

		pop	dx			;Get old AX value
		mov	al, dl			;Restore old AL value

ISR17Done:	pop	dx
		pop	cx
		pop	bx
		pop	ds
		iret
MyInt17		endp





Main		proc

		mov	ax, cseg
		mov	ds, ax

		print
		byte	"INT 17h Replacement",cr,lf
		byte	"Installing....",cr,lf,0

; Patch into the INT 17 interrupt vector.  Note that the
; statements above have made cseg the current data segment,
; so we can store the old INT 17 value directly into
; the OldInt17 variable.

		cli				;Turn off interrupts!
		mov	ax, 0
		mov	es, ax
		mov	ax, es:[17h*4]
		mov	word ptr OldInt17, ax
		mov	ax, es:[17h*4 + 2]
		mov	word ptr OldInt17+2, ax
		mov	es:[17h*4], offset MyInt17
		mov	es:[17h*4+2], cs
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
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
