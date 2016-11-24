;
;
;
StdGrp		group	stdlib, stdData
;
StdData		segment	para public 'sldata'
;
; InpVector- Points at the current keyboard input routine.
;
GetcAdrs	dd	sl_GetcStdIn
GetcStkIndx	dw	0
GetcStk		dd	16 dup (sl_GetcStdIn)
GSIsize		=	$-GetcStk
;
; CharBuf- Used to hold character when reading from standard input device.
;
CharBuf		db	?
;
;
; LastChar- Used by BIOS keyboard routine to split non-ASCII keypresses
; into two separate calls.
;
LastChar	dw	101h
;
; LastWasCR gets set to 1 when we read a CR.  If the char read when LastWasCR
; is one is a LF, this code eats the CR.
;
LastWasCR	db	1		;Assume at start last char was CR.
;
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp,ds:nothing
;
; Keyboard input routines
;
; Released to the public domain
; Created by: Randall Hyde
; Date: 7/90
; Updates:
;
;	8/11/90-	Modifications to use DOS 3fh call and handle eof
;	2/20/91-	Modified routines to eat LFs following CRs after
;			call to DOS getc routine.
;	3/6/91-		Modified code to use DOS raw mode for standard
;			input rather than cooked mode.  Added SetInBIOS,
;			SetInStd, and SetInRaw routines.
;
;
cr		equ	0dh
lf		equ	0ah
CtrlZ		equ	1ah
;
;
;
;
		public	sl_Getc
sl_Getc		proc	far
		jmp	dword ptr StdGrp:GetcAdrs
sl_Getc		endp
;
;
; SetInAdrs- Stores ES:DI into InpVector which sets the new keyboard vector.
;
		public	sl_SetInAdrs
sl_SetInAdrs	proc	far
		mov	word ptr stdgrp:GetcAdrs, di
		mov	word ptr stdgrp:GetcAdrs+2, es
		ret
sl_SetInAdrs	endp
;
;
; GetInAdrs-	Returns the address of the current output routine in ES:DI.
;
		public	sl_GetInAdrs
sl_GetInAdrs	proc	far
		les	di, dword ptr stdgrp:GetcAdrs
		ret
sl_GetInAdrs	endp
;
;
;
; PushInAdrs-	Pushes the current input address onto the input stack
;		and then stores the address in es:di into the input address
;		pointer.  Returns carry clear if no problems.  Returns carry
;		set if there is an address stack overflow.  Does NOT modify
;		anything if the stack is full.
;
		public	sl_PushInAdrs
sl_PushInAdrs	proc	far
		push	ax
		push	di
		cmp	stdgrp:GetcStkIndx, GSIsize
		jae	BadPush
		mov	di, stdgrp:GetcStkIndx
		add	stdgrp:GetcStkIndx, 4
		mov	ax, word ptr stdgrp:GetcAdrs
		mov	word ptr stdgrp:GetcStk[di], ax
		mov	ax, word ptr stdgrp:GetcAdrs+2
		mov	word ptr stdgrp:GetcStk+2[di], ax
		pop	di
		mov	word ptr stdgrp:GetcAdrs, di
		mov	word ptr stdgrp:GetcAdrs+2, es
		pop	ax
		clc
		ret
;
BadPush:	pop	di
		pop	ax
		stc
		ret
sl_PushInAdrs	endp
;
;
; PopInAdrs-	Pops an input address off of the stack and stores it into
;		the GetcAdrs variable.
;
		public	sl_PopInAdrs
sl_PopInAdrs	proc	far
		push	ax
		mov	di, stdgrp:GetcStkIndx
		sub	di, 4
		jns	GoodPop
;
; If this guy just went negative, set it to zero and push the address
; of the stdout routine onto the stack.
;
		xor	di, di
		mov	word ptr stdgrp:GetcStk, offset stdgrp:sl_GetcStdIn
		mov	word ptr stdgrp:GetcStk+2, seg stdgrp:sl_GetcStdIn
;
GoodPop:	mov	stdgrp:GetcStkIndx, di
		mov	es, word ptr GetcAdrs+2
		mov	ax, word ptr stdgrp:GetcStk+2[di]
		mov	word ptr stdgrp:GetcAdrs+2, ax
		mov	ax, word ptr stdgrp:GetcStk[di]
		xchg	word ptr stdgrp:GetcAdrs, ax
		mov	di, ax
		pop	ax
		ret
sl_PopInAdrs	endp
;
;
;
; SetInBIOS- Points the input pointer at the GetcBIOS routine.
;
		public	sl_SetInBIOS
sl_SetInBIOS	proc	far
		mov	word ptr StdGrp:GetcAdrs, offset stdgrp:sl_GetcBIOS
		mov	word ptr StdGrp:GetcAdrs+2, stdgrp
		ret
sl_SetInBIOS	endp
;
;
;
; SetInStd- Points the input pointer at the GetcStdIn routine.
;
		public	sl_SetInStd
sl_SetInStd	proc	far
		mov	word ptr StdGrp:GetcAdrs, offset stdgrp:sl_GetcStdIn
		mov	word ptr StdGrp:GetcAdrs+2, stdgrp
		ret
sl_SetInStd	endp
;
;
;
;
;
;
;
; GetcBIOS- 	Reads a character from the keyboard using the BIOS routines.
;		Behaves just like DOS call insofar as it returns a zero if
;		the user presses a non-ASCII key and then returns the scan
;		code as the next keypress.  Returns 1 in AH signifying that
;		we haven't reached EOF.
;
		public	sl_GetcBIOS
sl_GetcBIOS	proc	far
		cmp	byte ptr stdgrp:LastChar, 0
		jnz	GetNewChar
		mov	ah, 1
		mov	al, byte ptr stdgrp:LastChar+1
		mov	byte ptr stdgrp:LastChar, al
		mov	stdgrp:LastWasCR, 0			;BIOS doesn't convert
		ret					; CR-> CR/LF.
;
GetNewChar:	mov	ah, 0
		int	16h
		mov	stdgrp:LastChar, ax
		mov	ah, 1			;Never EOF.
		mov	stdgrp:LastWasCR, 0
		ret
sl_GetcBIOS	endp
;
;
;
; GetcStdIn- 	Reads a character from DOS' standard input.
;
; On return: ah=0 if eof, 1 if not eof.  AL=character.
;
; Modification 2/20/91:
;
;	Modified this code to eat any line feeds which immediately follow a
;	CR on the standard input.
;
;		3/8/91:
;
;	Modified this code to treat reading data from a file and from a
;	device as two different operations.  This removed some performance
;	problems and helped make the code a little "safer".
;
		public	sl_GetcStdIn
		assume	ds:StdGrp
sl_GetcStdIn	proc	far
		push	bx
		push	cx
		push	dx
		push	ds
;
		mov	ax, 4400h		;IOCTL read call
		xor	bx, bx			;Use std in handle.
		int	21h
		test	dl, 80h			;See if file (0) or device (1).
		jz	GetcAgain
;
		test	dl, 40h			;Check for EOF on device.
		jz	DeviceEOF
;
; At this point we're reading a character from a device.  Simply call the
; DOS character input routine so we can avoid buffering and other nasty
; problems.  Note we have to handle EOF ourselves here.  DOS, however,
; handles ctrl-C.
;
		mov	ah, 8
		int	21h
		mov	ah, 1
		cmp	al, CtrlZ
		jne	GoodRead
DeviceEOF:	mov	ah, 0
		jmp	Short GoodRead
;
;
; If we're reading from a file (rather than a device like the keyboard),
; drop down here to read the character using standard buffered I/O.
; Make sure to strip off LFs following CRs (since LFs typically follow CRs
; in a file).
;
GetcAgain:	mov	ah, 3fh
		mov	dx, cs
		mov	ds, dx
		mov	CharBuf, 0		;Don't let LF trip us up.
		lea	dx, stdgrp:CharBuf	;Put char into CharBuf.
		mov	cx, 1			;Read one character.
		mov	bx, 0			;StdIn file handle
		int	21h
		jc	BadRead
		mov	ah, al			;ah=0 if eof, 1 if not eof.
		mov	al, CharBuf		;Get char if not eof.
		cmp	al, LF			;Was last char a line feed?
		jne	NotLF
		cmp	LastWasCR, 0
		mov	LastWasCR, 0
		jne	GetcAgain
;
NotLF:		mov	LastWasCR, 0
		cmp	al, CR
		jne	GoodRead
		mov	LastWasCR,1
;
GoodRead:	clc
BadRead:	pop	ds
		pop	dx
		pop	cx
		pop	bx
		ret
sl_GetcStdIn	endp
;
;
stdlib		ends
		end
