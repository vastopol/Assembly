		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


cseg		segment	para public 'code'
		assume	cs:cseg, ds:nothing

MinVal0		word	?
MinVal1		word	?
MaxVal0		word	?
MaxVal1		word	?



Wait4Button	proc	near
		push	ax
		push	dx
		push	cx

W4BLp:		mov	ah, 84h
		mov	dx, 900h
		int	15h
		cmp	ax, 0
		je	W4BLp

		xor	cx, cx
Delay:		loop	Delay

W4nBLp:		mov	ah, 84h
		mov	dx, 900h
		int	15h
		cmp	ax, 0
		jne	W4nBLp

Delay2:		loop	Delay2

		pop	cx
		pop	dx
		pop	ax
		ret
Wait4Button	endp

Main		proc

		print
		byte	"SGDI Test Program.",cr,lf
		byte	"Written by Randall Hyde",cr,lf,lf
		byte	"Press any key to continue",cr,lf,0

		getc

		mov	ah, 84h
		mov	dh, 4			;Test presence call.
		int	15h
		cmp	ax, 0			;See if there
		je	MainLoop0
		print
		byte	"No SGDI driver present in memory.",cr,lf,0
		jmp	Quit

MainLoop0:	print
		byte	"BIOS: ",0

; Okay, read the switches and raw pot values using the BIOS compatible calls.

		mov	ah, 84h
		mov	dx, 0			;BIOS compat. read switches.
		int	15h
		puth				;Output switch values.
		mov	al, ' '
		putc

		mov	ah, 84h			;BIOS compat. read pots.
		mov	dx, 1
		int	15h
		putw
		mov	al, ' '
		putc
		mov	ax, bx
		putw
		mov	al, ' '
		putc
		mov	ax, cx
		putw
		mov	al, ' '
		putc
		mov	ax, dx
		putw

		putcr
		mov	ah, 1		;Repeat until key press.
		int	16h
		je	MainLoop0
		getc


; Read the minimum and maximum values for each pot from the user so we
; can calibrate the pots.

		print
		byte	cr,lf,lf,lf
		byte	"Move joystick to upper left corner and press "
		byte	"any button.",cr,lf,0

		call	Wait4Button
		mov	ah, 84h
		mov	dx, 1		;Read Raw Values
		int	15h
		mov	MinVal0, ax
		mov	MinVal1, bx

		print
		byte	cr,lf
		byte	"Move the joystick to the lower right corner "
		byte	"and press any button",cr,lf,0

		call	Wait4Button
		mov	ah, 84h
		mov	dx, 1		;Read Raw Values
		int	15h
		mov	MaxVal0, ax
		mov	MaxVal1, bx

; Calibrate the pots.

		mov	ax, MinVal0	;Will be eight bits or less.
		mov	bx, MaxVal0
		mov	cx, bx		;Compute centered value as the
		add	cx, ax	 	; average of these two (this is
		shr	cx, 1		; dangerous, but usually works!)
		mov	ah, 84h
		mov	dx, 300h	;Calibrate pot 0
		int	15h

		mov	ax, MinVal1	;Will be eight bits or less.
		mov	bx, MaxVal1
		mov	cx, bx		;Compute centered value as the
		add	cx, ax		; average of these two (this is
		shr	cx, 1		; dangerous, but usually works!)
		mov	ah, 84h
		mov	dx, 301h	;Calibrate pot 1
		int	15h

MainLoop1:	print
		byte	"ReadSw: ",0

; Okay, read the switches and raw pot values using the BIOS compatible calls.

		mov	ah, 84h
		mov	dx, 800h		;Read switch zero.
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 801h		;Read switch one.
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 802h		;Read switch two.
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 803h		;Read switch three.
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 804h		;Read switch four
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 805h		;Read switch five.
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 806h		;Read switch six.
		int	15h
		or	al, '0'
		putc

		mov	ah, 84h
		mov	dx, 807h		;Read switch seven.
		int	15h			;We won't bother with
		or	al, '0'			; any more switches.
		putc
		mov	al, ' '
		putc

		mov	ah, 84h
		mov	dh, 9			;Read all 16 switches.
		int	15h
		putw

		print
		byte	"  Pots: ",0
		mov	ax, 8403h		;Read joystick pots.
		mov	dx, 200h		;Read four pots.
		int	15h
		puth
		mov	al, ' '
		putc
		mov	al, ah
		puth
		mov	al, ' '
		putc

		mov	ah, 84h
		mov	dx, 503h		;Raw read, pot 3.
		int	15h
		putw

		putcr
		mov	ah, 1		;Repeat until key press.
		int	16h
		je	MainLoop1
		getc




Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
