;
; Routines to handle COM1 data transmission.
;
; COM1 refers to HARDWARE COM1 port which is located beginning at port
; address 3f8h and causes INT 0Ch.
;
;
; Released to the public domain.
; Created by Randall Hyde.
; Date: 8/11/90
;
;
; Useful equates:
;
BIOSvars	=	40h
Com1Adrs	=	0
Com2Adrs	=	2
;
BufSize		=	256			;# of bytes in buffer.
;
;
; Serial port equates:
;
Com1Port	=	3F8h
Com1IER		=	3F9h
Com1IIR		=	3FAh
Com1LCR		=	3FBh
Com1MCR		=	3FCh
Com1LSR		=	3FDh
Com1MSR		=	3FEh
;
;
; Register assignments:
;
; Interupt enable register (IER):
;
;		If one:
; bit 0-	Enables received data available interrupt.
; bit 1-	Enables transmitter holding register empty interrupt.
; bit 2-	Enables receiver line status interrupt.
; bit 3-	Enables the modem status interrupt.
; bits 4-7-	Always set to zero.
;
; Interrupt ID Register (IIR):
;
; bit 0-	No interrupt is pending (interrupt pending if zero).
; bits 1,2-	Binary value denoting source of interrupt:
;			00-Modem status
;			01-Transmitter Hold Register Empty
;			10-Received Data Available
;			11-Receiver line status
; bits 3-7	Always zero.
;
;
; Line Control Register (LCR):
;
; bits 0,1-	Word length (00=5, 01=6, 10=7, 11=8 bits).
; bit 2-	Stop bits (0=1, 1=2 stop bits [1-1/2 if 5 data bits]).
; bit 3-	Parity enabled if one.
; bit 4-	0 for odd parity, 1 for even parity (assuming bit 3 = 1).
; bit 5-	1 for stuck parity.
; bit 6-	1=force break.
; bit 7-	1=Divisor latch access bit.  0=rcv/xmit access bit.
;
; Modem Control Register (MCR):
;
; bit 0-	Data Terminal Ready (DTR)
; bit 1-	Request to send (RTS)
; bit 2-	OUT 1
; bit 3-	OUT 2
; bit 4-	Loop back control.
; bits 5-7-	Always zero.
;
; Line Status Register (LSR):
;
; bit 0-	Data Ready
; bit 1-	Overrun error
; bit 2-	Parity error
; bit 3-	Framing error
; bit 4-	Break Interrupt
; bit 5-	Transmitter holding register is empty.
; bit 6-	Transmit shift register is empty.
; bit 7-	Always zero.
;
; Modem Status Register (MSR):
;
; bit 0-	Delta CTS
; bit 1-	Delta DSR
; bit 2-	Trailing edge ring indicator
; bit 3-	Delta carrier detect
; bit 4-	Clear to send
; bit 5-	Data Set Ready
; bit 6-	Ring indicator
; bit 7-	Data carrier detect
;
;
;
;
;
;
;
StdGrp		group	StdLib, StdData
;
;
;
;
StdData		segment	para public 'sldata'
;
int0Cofs	equ	es:[30h]
int0Cseg	equ	es:[32h]
int0cVec	dd	?		;Holds old int 0ch vector.
InHead		dw	InpBuf
InTail		dw	InpBuf
InpBuf		db	Bufsize dup (?)
InpBufEnd	equ	this byte
;
OutHead		dw	OutBuf
OutTail		dw	OutBuf
OutBuf		db	BufSize dup (?)
OutBufEnd	equ	this byte
;
i8259a		db	0		;8259a interrupt enable register.
TestBuffer	db	0		;1 means we are transmitting out of
;					; the transmit buffer.  0 means the
;					; transmitter register is empty and
;					; we can store data directly to it.
StdData		ends
;
;
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
;
;
; sl_Com1Baud: Set the COM1 port baud rate
; AX = baud rate (110, 150, 300, 600, 1200, 2400, 4800, 9600, 19200)
;
		public	sl_Com1Baud
sl_Com1Baud	proc	far
		push	ax
		push	dx
		cmp	ax, 9600
		ja	Set19200
		je	Set9600
		cmp	ax, 2400
		ja	Set4800
		je	Set2400
		cmp	ax, 600
		ja	Set1200
		je	Set600
		cmp	ax, 150
		ja	Set300
		je	Set150
		mov	ax, 1047		;Default to 110 baud
		jmp	short SetPort
;
Set150:		mov	ax, 768
		jmp	short SetPort
;
Set300:		mov	ax, 384
		jmp	short SetPort
;
Set600:		mov	ax, 192
		jmp	short SetPort
;
Set1200:	mov	ax, 96
		jmp	short SetPort
;
Set2400:	mov	ax, 48
		jmp	short SetPort
;
Set4800:	mov	ax, 24
		jmp	short SetPort
;
Set9600:	mov	ax, 12
		jmp	short SetPort
;
Set19200:	mov	ax, 6
SetPort:	mov	dx, ax			;Save baud value.
		call	far ptr sl_GetLCRCom1
		push	ax			;Save old divisor bit value.
		or	al, 80h			;Set divisor select bit.
		call	far ptr sl_SetLCRCom1
		mov	ax, dx			;Get baud rate divisor value.
		mov	dx, Com1Port
		out	dx, al
		inc 	dx
		mov	al, ah
		out	dx, al
		mov	dx, Com1LCR
		pop	ax
		call	far ptr sl_SetLCRCom1	;Restore divisor bit value.
		pop	dx
		pop	ax
		ret
sl_Com1Baud	endp
;
;
; sl_Com1Stop:
; Set the number of stop bits.
;
; AL=1 for one stop bit, 2 for two stop bits.
;
		public	sl_com1Stop
sl_com1Stop	proc	far
		push	ax
		push	dx
		dec	ax
		shl	ax, 1			;position into bit #2
		shl	ax, 1
		mov	ah, al
		mov	dx, Com1LCR
		in	al, dx
		and 	al, 11111011b		;Mask out Stop Bits bit
		or	al, ah			;Mask in new # of stop bits.
		out	dx, al
		pop	dx
		pop	ax
		ret
sl_com1Stop	endp
;
;
; sl_com1size: Sets word size on the com1 port.
; AX = 5, 6, 7, or 8 which is the number of bits to set.
;
		public	sl_com1size
sl_com1size	proc	far
		push	ax
		push	dx
		sub	al, 5
		cmp	al, 3
		jbe	Okay
		mov	al, 3			;Default to eight bits.
Okay:		mov	ah, al
		mov	dx, com1LCR
		in	al, dx
		and	al, 11111100b		;Mask out old word size
		or	al, ah			;Mask in new word size
		out	dx, al
		pop	dx
		pop	ax
		ret
sl_com1size	endp
;
;
; sl_com1parity: Turns parity on/off, selects even/odd parity, or stuck parity.
; ax contains the following:
;
; bit 0-	1 to enable parity, 0 to disable.
; bit 1-	0 for odd parity, 1 for even (only valid if bit 0 is 1).
; bit 2-	Stuck parity bit.  If 1 and bit 0 is 1, then the parity bit
;		is always set to the inverse of bit 1.
;
		public	sl_com1parity
sl_com1parity	proc	far
		push	ax
		push	dx
;
		shl	ax, 1
		shl	ax, 1
		shl	ax, 1
		and	ax, 00111000b		;Mask out other data.
		mov	ah, al
		mov	dx, com1LCR
		in	al, dx
		and	al, 11000111b
		or	al, ah
		out	dx, al
		pop	dx
		pop	ax
		ret
sl_com1parity	endp
;
;
;****************************************************************************
;
; Polled I/O:
;
;
; sl_ReadCom1-	Reads a character from COM1 and returns that character in
;		the AL register.  Synchronous call, meaning it will not
;		return until a character is available.
;
		public	sl_ReadCom1
sl_ReadCom1	proc	far
		push	dx
		call	far ptr sl_GetLCRCom1
		push	ax			;Save divisor latch access bit.
		and	al, 7fh			;Select normal port.
		call	far ptr sl_SetLCRCom1
		mov	dx, com1LSR
WaitForChar:	call	far ptr sl_GetLSRCom1
		test	al, 1			;Data Available?
		jz	WaitForChar
		mov	dx, com1Port
		in	al, dx
		mov	dl, al			;Save character
		pop	ax			;Restore divisor access bit.
		call	far ptr sl_SetLCRCom1
		mov	al, dl			;Restore output character.
		pop	dx
		ret
sl_ReadCom1	endp
;
;
;
; sl_WriteCom1-	Writes the character in AL to the com1 port.
;
		public	sl_WriteCom1
sl_WriteCom1	proc	far
		push	dx
		push	ax
		mov	dl, al			;Save character to output
		call	far ptr sl_GetLCRCom1
		push	ax			;Save divisor latch access bit.
		and	al, 7fh			;Select normal port.
		call	far ptr sl_SetLCRCom1
WaitForXmtr:	call	far ptr sl_GetLSRCom1
		test	al, 00100000b		;Xmtr buffer empty?
		jz	WaitForXmtr
		mov	al, dl			;Get output character.
		mov	dx, Com1Port
		out	dx, al
		pop	ax			;Restore divisor access bit.
		call	far ptr sl_SetLCRCom1
		pop	ax
		pop	dx
		ret
sl_WriteCom1	endp
;
;
;
; sl_TstInpCom1-Returns AL=0 if a character is not available at the com1 port.
;		Returns AL=1 if a character is available.
;
		public	sl_TstInpCom1
sl_TstInpCom1	proc	far
		push	dx
		mov	dx, com1LSR
		in	al, dx
		and 	al, 1
		pop	dx
		ret
sl_TstInpCom1	endp
;
;
; sl_TstOutCom1-Returns AL=1 when it's okay to send another character to
;		the transmitter.  Returns zero if the transmitter is full.
;
		public	sl_TstOutCom1
sl_TstOutCom1	proc	far
		push	dx
		mov	dx, com1LSR
		in	al, dx
		test	al, 00100000b
		mov	al, 0
		jz	toc1
		inc	ax
toc1:		pop	dx
		ret
sl_TstOutCom1	endp
;
;
; sl_GetLSRCom1-Returns the LSR in al:
;
; AL:
;	bit 0-	Data Ready
;	bit 1-	Overrun error
;	bit 2-	Parity error
;	bit 3-	Framing error
;	bit 4-	Break interrupt
;	bit 5-	Xmtr holding register is empty.
;	bit 6-	Xmtr shift register is empty.
;	bit 7-	Always zero.
;
		public	sl_GetLSRCom1
sl_GetLSRCom1	proc	far
		push	dx
		mov	dx, com1LSR
		in	al, dx
		pop	dx
		ret
sl_GetLSRCom1	endp
;
;
; sl_GetMSRCom1-Returns the modem status register in AL
;
; AL:
;	bit 0-	Delta clear to send
;	bit 1-	Delta data set ready
;	bit 2-	Trailing edge ring indicator
;	bit 3-	Delta data carrier detect
;	bit 4-	Clear to send (CTS)
;	bit 5-	Data set ready (DSR)
;	bit 6-	Ring indicator (RI)
;	bit 7-	Data carrier detect (DCD)
;
		public	sl_GetMSRCom1
sl_GetMSRCom1	proc	far
		push	dx
		mov	dx, com1MSR
		in	al, dx
		pop	dx
		ret
sl_GetMSRCom1	endp
;
;
; sl_SetMCRCom1-Writes the data in AL to the modem control register.
; sl_GetMCRCom1-Reads the data from the modem control register into AL.
;
; AL:
;	bit 0-	Data terminal ready (DTR)
;	bit 1-	Request to send (RTS)
;	bit 2-	Out 1
;	bit 3-	Out 2
;	bit 4-	Loop
;	bits 5-7 (must be zero)
;
		public	sl_SetMCRCom1
sl_SetMCRCom1	proc	far
		push	dx
		mov	dx, com1MCR
		out	dx, al
		pop	dx
		ret
sl_SetMCRCom1	endp
;
		public	sl_GetMCRCom1
sl_GetMCRCom1	proc	far
		push	dx
		mov	dx, com1MCR
		in	al, dx
		pop	dx
		ret
sl_GetMCRCom1	endp
;
;
;
; sl_GetLCRCom1- Reads the value from the line control register into AL.
; sl_SetLCRCom1- Writes the value in AL to the line control register.
;
; AL:
;	bits 0,1-	Word length selection
;	bit 2-		Number of stop bits
;	bit 3-		Parity Enable
;	bit 4-		Even parity select
;	bit 5-		Stuck parity
;	bit 6-		Set Break
;	bit 7-		Divisor latch access bit
;
		public	sl_GetLCRCom1
sl_GetLCRCom1	proc	far
		push	dx
		mov	dx, com1LCR
		in	al, dx
		pop	dx
		ret
sl_GetLCRCom1	endp
;
		public	sl_SetLCRCom1
sl_SetLCRCom1	proc	far
		push	dx
		mov	dx, com1LCR
		out	dx, al
		pop	dx
		ret
sl_SetLCRCom1	endp
;
;
; sl_GetIIRCom1-Reads the interrupt indentification register and returns its
;		value in AL.
;
; AL:
;	bit 0-		0 if interrupt pending, 1 if no interrupt.
;	bits 1,2-	Interrupt ID (highest priority).
;	bits 3-7-	Always zero.
;
; Interrupt ID
; bit 2  1	Source				Reset by
;     ----	-----------------------------	------------------------------
;     0  0	CTS, DSR, RI			Reading the MSR
;     0  1	Xmtr holding register empty	Reading IIR or writing to xmtr
;     1  0	Receiver data available		Reading rcvr buffer
;     1  1	Overrun, parity, framing, or	Reading the LSR.
;		break
;
;
		public	sl_GetIIRCom1
sl_GetIIRCom1	proc	far
		push	dx
		mov	dx, com1IIR
		in	al, dx
		pop	dx
		ret
sl_GetIIRCom1	endp
;
;
; sl_GetIERCom1-Reads the IER and returns it in AL.
; sl_SetIERCom1-Stores the value in AL into the IER.
;
; AL:
;	bit 0-	Enable data available interrupt.
;	bit 1-	Enable xmtr holding register empty interrupt.
;	bit 2-	Enable receive line status interrupt.
;	bit 3-	Enable modem status interrupt
;	bits 4-7  Always zero.
;
		public	sl_GetIERCom1
sl_GetIERCom1	proc	far
		push	dx
		call	sl_GetLCRCom1
		push	ax			;Save divisor access bit.
		and	al, 7fh			;Address the IER.
		call	sl_SetLCRCom1
		mov	dx, com1IER
		in	al, dx
		mov	dl, al			;Save for now
		pop	ax
		call	sl_SetLCRCom1		;Restore divisor latch
		mov	al, dl			;Restore IER value
		pop	dx
		ret
sl_GetIERCom1	endp
;
;
		public	sl_SetIERCom1
sl_SetIERCom1	proc	far
		push	dx
		push	ax
		mov	ah, al			;Save value to output
		call	sl_GetLCRCom1		;Get and save divsor access
		push	ax			;bit.
		and	al, 7fh			;Address the IER.
		call	sl_SetLCRCom1
		mov	al, ah
		mov	dx, com1IER
		out	dx, al
		pop	ax			;Restore divisor latch bit.
		call	sl_SetLCRCom1
		pop	ax
		pop	dx
		ret
sl_SetIERCom1	endp
;
;
;****************************************************************************
;
; Interrupt-driven Serial I/O
;
;
; sl_InitCom1Int-	Initializes the hardware to use interrupt-driven I/O
;			for COM1:
;
		public	sl_InitCom1Int
sl_InitCom1Int	proc	far
		pushf			;Save interrupt disable flag.
		push	es
		push	ax
		push	dx
;
; Turn off the interrupts while we're screwing around here.
;
		cli
;
; Save old interrupt vector.
;
		xor	ax, ax		;Point at interrupt vectors
		mov	es, ax
		mov	ax, Int0Cofs	;Get ofs int 0ch vector.
		mov	word ptr StdGrp:int0cVec, ax
		mov	ax, Int0Cseg	;Get seg int 0ch vector.
		mov	word ptr StdGrp:int0cVec+2, ax
;
; Point int 0ch vector at our interrupt service routine:
;
		mov	ax, cs
		mov	Int0Cseg, ax
		mov	ax, offset stdgrp:Com1IntISR
		mov	Int0Cofs, ax
;
; Clear any pending interrupts:
;
		call	far ptr sl_GetLSRCom1	;Clear Receiver line status
		call	far ptr sl_GetMSRCom1	;Clear CTS/DSR/RI Interrupts
		call	far ptr sl_GetIIRCom1	;Clear xmtr empty interrupt
		mov	dx, Com1Port
		in	al, dx			;Clear data available intr.
;
; Clear divisor latch access bit.  WHILE OPERATING IN INTERRUPT MODE, THE
; DIVISOR ACCESS LATCH BIT MUST ALWAYS BE ZERO.  If for some horrible reason
; you need to change the baud rate in the middle of a transmission (or while
; the interrupts are enabled) clear the interrupt flag, do your dirty work,
; clear the divisor latch bit, and finally restore interrupts.
;
		call	far ptr sl_getLCRCom1
		and	al, 7fh
		call	far ptr sl_SetLCRCom1
;
;
; Enable the receiver and transmitter interrupts
;
		mov	al, 3		;Enable rcv/xmit interrupts
		call	far ptr sl_SetIERCom1
;
; Must set the OUT2 line for interrupts to work.
; Also sets DTR and RTS active.
;
		mov	al, 00001011b
		call	far ptr sl_SetMCRCom1
;
; Activate the COM1 (int 0ch) bit in the 8259A interrupt controller chip.
;
		in	al, 21h
		mov	StdGrp:i8259a, al	;Save interrupt enable bit.
		and	al, 0efh	;Bit 4=IRQ 4 = INT 0Ch
		out	21h, al
;
		pop	dx
		pop	ax
		pop	es
		popf			;Restore interrupt disable flag.
		ret
sl_InitCom1Int	endp
;
;
; sl_IntsOffCom1- Disconnects the interrupt system and shuts off interrupt
;		  activity at the COM1: port.
;
;	Warning!  This routine assumes that interrupts are currently active
;		  due to a call to sl_InitCom1Int.  If you call this guy
;		  w/o first calling sl_InitCom1Int you will probably crash
;		  the system.  Furthermore, this routine makes the (rather
;		  presumptuous) assumption that no one else has patched into
;		  the INT 0Ch vector since SL_InitCom1Int was called.
;
		public	sl_IntsOffCom1
sl_IntsOffCom1	proc	far
		pushf
		push	es
		push	dx
		push	ax
;
		cli			;Don't allow interrupts while messing
		xor	ax, ax		; with the interrupt vectors.
		mov	es, ax		;Point at interrupt vectors.
;
; First, turn off the interrupt source:
;
		call	far ptr sl_GetMCRCom1
		and	al, 3			;Mask out OUT 2 bit (masks ints)
		call	far ptr sl_SetMCRCom1
;
		in	al, 21h			;Get 8259a ier
		and	al, 0efh		;Clear IRQ 4 bit.
		mov	ah, StdGrp:i8259a		;Get our saved value
		and	ah, 1000b		;Mask out com1: bit (IRQ 4).
		or	al, ah			;Put bit back in.
		out	21h, al
;
; Restore the interrupt vector:
;
		mov	ax, word ptr StdGrp:Int0cVec
		mov	Int0Cofs, ax
		mov	ax, word ptr StdGrp:Int0cVec+2
		mov	Int0Cseg, ax
;
		pop	ax
		pop	dx
		pop	es
		popf
		ret
sl_IntsOffCom1	endp
;
;----------------------------------------------------------------------------
;
; Com1IntISR- Interrupt service routine for COM1:
;
Com1IntISR	proc	far
		push	ax
		push	bx
		push	dx
TryAnother:	mov	dx, Com1IIR
		in	al, dx			;Get id
		test	al, 1			;Any interrupts left?
		jnz     IntRtn
		test	al, 100b
		jnz	ReadCom1
		test	al, 10b
		jnz	WriteCom1
;
; Bogus interrupt?
;
		call	sl_GetLSRCom1		;Clear receiver line status
		call	sl_GetMSRCom1		;Clear modem status.
		jmp	TryAnother
;
IntRtn:		mov	al, 20h			;Acknowledge interrupt to the
		out	20h, al			; 8259A interrupt controller.
		pop	dx
		pop	bx
		pop	ax
		iret
;
; Handle incoming data here:
; (Warning: This is a critical region.  Interrupts MUST BE OFF while executing
;  this code.  By default, interrupts are off in an ISR.  DO NOT TURN THEM ON
;  if you modify this code).
;
ReadCom1:	mov	dx, Com1Port
		in	al, dx			;Get the input char
		mov	bx, StdGrp:InHead
		mov	StdGrp:[bx], al
		inc	bx
		cmp	bx, offset stdgrp:InpBufEnd
		jb	NoInpWrap
		mov	bx, offset stdgrp:InpBuf
NoInpWrap:	cmp	bx, StdGrp:InTail
		je	TryAnother
		mov	StdGrp:InHead, bx
		jmp	TryAnother
;
;
; Handle outgoing data here (This is also a critical region):
;
WriteCom1:      mov	bx, StdGrp:OutTail
		cmp	bx, StdGrp:OutHead
		jne	OutputChar
;
; If head and tail are equal, simply set the TestBuffer variable to zero
; and quit.  If they are not equal, then there is data in the buffer and
; we should output the next character.
;
		mov	StdGrp:TestBuffer, 0
		jmp	TryAnother
;
; The buffer pointers are not equal, output the next character down here.
;
OutputChar:     mov	al, StdGrp:[bx]
		mov	dx, Com1Port
		out	dx, al
		inc	bx
		cmp	bx, offset stdgrp:OutBufEnd
		jb      NoOutWrap
		mov	bx, offset stdgrp:OutBuf
NoOutWrap:	mov	StdGrp:OutTail, bx
		jmp	TryAnother
Com1IntISR	endp
;
;
;----------------------------------------------------------------------------
;
; Routines to read/write characters in serial buffers.
;
		public	sl_InCom1
sl_InCom1	proc	far
		pushf				;Save interrupt flag
		push	bx
		sti				;Make sure interrupts are on.
TstInLoop:	mov	bx, StdGrp:InTail
		cmp	bx, StdGrp:InHead
		je	TstInLoop
		mov	al, StdGrp:[bx]		;Get next char.
		cli				;Turn off ints while adjusting
		inc	bx			; buffer pointers.
		cmp	bx, offset stdgrp:InpBufEnd
		jne	NoWrap2
		mov	bx, offset stdgrp:InpBuf
NoWrap2:	mov	StdGrp:InTail, bx
		pop	bx
		popf				;Restore interrupt flag.
		ret
sl_InCom1	endp
;
;
		public	sl_OutCom1
sl_OutCom1	proc	far
		pushf
		cli				;No interrupts now!
		cmp	StdGrp:TestBuffer, 0	;Write directly to serial chip?
		jnz	BufferItUp
		call	far ptr sl_WriteCom1	;Output to port
		mov	StdGrp:TestBuffer, 1	;Must buffer up next char.
		popf
		ret
;
BufferItUp:	push	bx
		mov	bx, StdGrp:OutHead
		mov	StdGrp:[bx], al
		inc	bx
		cmp	bx, offset stdgrp:OutBufEnd
		jne	NoWrap3
		mov	bx, offset stdgrp:OutBuf
NoWrap3:	cmp	bx, StdGrp:OutTail
		je	NoSetTail
		mov	StdGrp:OutHead, bx
NoSetTail:	pop	bx
		popf
		ret
sl_OutCom1	endp
;
stdlib		ends
		end
