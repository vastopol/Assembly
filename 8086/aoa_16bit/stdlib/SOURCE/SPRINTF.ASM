StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
;
cr		equ	0dh
ff		equ	0ch
lf		equ	0ah
tab		equ	09h
bs		equ	08h
;
RtnAdrs		equ	2[bp]
;
;
; sp_BufSize is a public variable so the user can adjust the size.
;
		public	sp_BufSize
sp_BufSize	dw	2048
;
;
;
aindex		dw	?
aptr		dd	?
;
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
		extrn	sl_ISize:far, sl_ULSize:far
		extrn	sl_LSize:far, sl_USize:far
		extrn	sl_itoam:far, sl_free:far
		extrn	sl_wtoam:far, sl_ltoam:far
		extrn	sl_ultoam:far, sl_htoam:far
		extrn	sl_utoam:far
		extrn	sl_malloc:far, sl_realloc:far
;
;
;
; Sprintfm- Like the "C" routine by the same name.  Calling sequence:
;
;               call    sprintfm
;               db      "format string",0
;               dd      item1, item2, ..., itemn
;
; Just like the PRINTF routine except it performs an in-memory format
; operation rather than printing the data to the current output device.
; Returns a pointer to the formatted string in ES:DI.
; See the PRINTF routine for more details about this guy.
;
;
;
		public	sl_sprintfm
sl_sprintfm	proc	far
		push	bp
		mov	bp, sp
		pushf
		push	ax
		push	cx
;
; Request some memory from the system.  If there isn't enough available,
; try half as much and repeat.  If there is no memory available, return
; with the carry set.
;
		mov	cx, sp_BufSize
TryAgain:	call	sl_malloc
		jnc	DoSPRINTF
		shr	cx, 1
		cmp	cx, 128			;Need at least 128 bytes.
		jae	TryAgain
		pop	cx
		pop	ax
		popf
		pop	bp
		stc
		ret
;
; The following code simulates a far call to sprintf.  We can't make the
; call because we need to skip the MOV BP, SP instruction which appears
; at the beginning of the code.
;
DoSPRINTF:     	push	cs			;Push fake return address
		mov	ax, offset stdgrp:RA
		push	ax
		push	bp			;Push stuff on stack
		pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		push	es
		push	ds
		jmp	sl_sbprintf2
;
; Return back to this point from sbprintf.
;
RA:		push	di
		mov	cx, 1
		mov	al, ch
FindLength:	cmp	al, es:[di]
		jz	AtEnd
		inc	cx
		inc	di
		jmp	FindLength
;
AtEnd:		pop	di
		call	sl_realloc
		pop	cx
		pop	ax
		popf
		pop	bp
		clc
		ret
sl_sprintfm	endp
;
;
;
;
; SPRINTF- Like sprintfm except it doesn't allocate storage for the
; formatted string.  Instead, you must pass it the address of a suitable
; buffer in es:di.
;
;
		public  sl_sprintf
sl_sprintf	proc    far
		push	bp
		mov	bp, sp
		pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
		push	es
		push	ds
;
; Save ptr to buffer area.
;
sl_sbprintf2	proc	near
sl_sbprintf2	endp
		mov	word ptr StdGrp:aptr, di
		mov	word ptr StdGrp:aptr+2, es
		mov	StdGrp:aindex, 0
;
; Get pointers to the return address (format string).
;
		cld
		les	di, RtnAdrs
		lds	si, RtnAdrs
;
; Okay, search for the end of the format string.  After these instructions,
; di points just beyond the zero byte at the end of the format string.  This,
; of course, points at the first address beyond the format string.
;
		mov	al, 0
		mov	cx, 65535
	repne	scasb
;
PrintItems:	lodsb			;Get char si points at.
		cmp	al, 0		;EOS?
		jz	PrintfDone
		cmp	al, "%"		;Start of a format string?
		jz	FmtItem
		cmp	al, "\"		;Escape character?
		jnz	PrintIt
		call	GetEscChar
PrintIt:	call	PutIt
		jmp	PrintItems
;
FmtItem:	call	GetFmtItem	;Process the format item here.
		jmp	PrintItems
;
PrintfDone:	mov	RtnAdrs, di	;Put out new return address.
		pop	ds
		pop	es
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	bp
		popf
		clc
		ret
sl_sprintf	endp
;
; GetEscChar- Handles items immediately following the escape character "\".
;
;	Special escape characters (upper/lower case is acceptable):
;
;		n	Newline (cr/lf)
;		t	tab
;		b	backspace
;		r	return
;		l	line feed
;		f	formfeed
;		\	\
;		%	&
;		0xhh	Char with hex character code hh.  Must have exactly
;			two hexadecimal digits.
;
GetEscChar	proc	near
		lodsb			;Get next character
		cmp	al, 'n'
		je	RtnNL
		cmp	al, 'N'
		je	RtnNL
		cmp	al, 't'
		je	RtnTab
		cmp	al, 'T'
		je	RtnTab
		cmp	al, 'b'
		je	RtnBS
		cmp	al, 'B'
		je	RtnBS
		cmp	al, 'r'
		je	RtnRtn
		cmp	al, 'R'
		je	RtnRtn
		cmp	al, 'l'
		je	RtnLF
		cmp	al, 'L'
		je	RtnLF
		cmp	al, 'f'
		je	RtnFF
		cmp	al, 'F'
		je	RtnFF
;
; Check for the presence of a 0xhh value here:
;
		cmp	al, '0'
		jne	RtnChar
		cmp	byte ptr [si], 'x'
		je	GetHex
		cmp	byte ptr [si], 'X'
		jne	RtnChar
;
; Okay, process the hex value here.  Note that exactly two hex digits must
; follow the 0x.
;
GetHex:		inc	si		;Point at first hex digit.
		lodsb			;Get first hex digit.
		and	al, 05fh	;l.c. -> u.c.
		cmp	al, 'A'
		jb	GotIt
		sub	al, '7'
GotIt:		shl	al, 1		;Put into H.O. nibble.
		shl	al, 1
		shl	al, 1
		shl	al, 1
		mov	ah, al		;Save for later
		lodsb			;Get next char.
		and	al, 05fh
		cmp	al, 'A'
		jb	GotIt2
		sub	al, '7'
GotIt2:		and	al, 0fh
		or	al, ah
		ret			;Return hex constant.
;
; RtnNL (return Newline) cheats.  It needs to return two characters.
; Since GetEscChar only returns a single character, this code goes ahead
; and calls putc to output the CR and the returns the LF.
;
RtnNL:		mov	al, cr
		call	PutIt
		mov	al, lf
		ret
;
RtnTab:		mov	al, tab
		ret
;
RtnBS:		mov	al, bs
		ret
;
RtnRtn:		mov	al, cr
		ret
;
RtnLF:		mov	al, lf
		ret
;
RtnFF:		mov	al, ff
RtnChar:	ret
;
GetEscChar	endp
;
;
;
GetFmtItem	proc	near
		lodsb				;Get char beyond "%"
;
		mov	cx, 1			;Default field width is 1.
		mov	dl, 0			;Default is right justified
		mov	dh, ' '			;Default fill char is space.
		mov	ah, ' '			;Assume straight ptr, not handle.
;
; See if the user wants the value left justified:
;
		cmp	al, '-'
		jne	NotLeftJust
		inc	dl			;Set to right justified
		lodsb				;Get next character.
;
; See if the user wants to change the padding character.
;
NotLeftJust:	cmp	al, '\'
		jne	NoPadChange
		lodsb				;Get Padding Character.
		mov	dh, al			;Save padding character.
		lodsb				;Get next character
;
; See if the user wants a different field width:
;
NoPadChange:	cmp	al, '0'
		jb	NoFldWidth
		cmp	al, '9'
		ja	NoFldWidth
		call	GetDecVal
;
; See if the user wants to specify a handle rather than a straight pointer
;
NoFldWidth:	cmp	al, '^'
		jne     ChkFmtChars
		mov	ah, al
		lodsb				;Skip "^" character
;
; Okay, process the format characters down here.
;
ChkFmtChars:	and	al, 05fh		;l.c. -> U.C.
		cmp	al, 'D'
		je	PrintDec
		cmp	al, 'I'
		je	PrintDec
		cmp	al, 'C'
		je	PrintChar
;
		cmp	al, 'X'
		jne	TryH
		jmp	PrintHexWord
;
TryH:		cmp	al, 'H'
		jne	TryU
		jmp	PrintHexByte
;
TryU:		cmp	al, 'U'
		jne	TryString
		jmp	PrintUDec
;
TryString:	cmp	al, 'S'
		jne	TryLong
		jmp	PrintString
;
TryLong:	cmp	al, 'L'
		jne	Default
;
; If we've got the "L" modifier, this is a long value to print, get the
; data type character as the next value:
;
		lodsb
		and	al, 05fh		;l.c. -> U.C.
		cmp	al, 'D'
		je	JmpDec
		cmp	al, 'I'
		jne	TryLU
JmpDec:		jmp	LongDec
;
TryLU:		cmp	al, 'U'
		jne	TryX
		jmp	LongU
;
TryX:		cmp	al, 'X'
		jne	Default
		jmp	LongX
;
;
;
; If none of the above, simply return without printing anything.
;
Default:		ret
;
;
;
;
;
; Print a signed decimal value here.
;
PrintDec:	call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		call	sl_ISize		;Get the size of this guy.
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadDec		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustDec
		call	PrintPad		;Print padding characters
		call	PutIti			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustDec:	call	PutIti
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadDec:	call	PutIti
		ret
;
;
;
; Print a character variable here.
;
PrintChar:	call	GetPtr			;Get next pointer into ES:BX
		mov	al, es:[bx]		;Retrieve value to print.
                dec	cx
		js	NoPadChar		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustChar
		call	PrintPad		;Print padding characters
		call	PutIt			;Print the character
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustChar:	call	PutIt
		call	PrintPad
		ret
;
; Print non-justified character here:
;
NoPadChar:	call	PutIt
		ret
;
;
;
;
; Print a hexadecimal word value here.
;
PrintHexWord:	call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		sub	cx, 4			;Compute padding
		js	NoPadHexW		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustHexW
		call	PrintPad		;Print padding characters
		call	PutItw			;Print the hex value
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustHexW:	call	PutItw
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadHexW:	call	PutItw
		ret
;
;
;
;
; Print hex bytes here.
;
;
PrintHexByte:	call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		sub	cx, 4			;Compute padding
		js	NoPadHexB		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustHexB
		call	PrintPad		;Print padding characters
		call	PutIth			;Print the hex value
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustHexB:	call	PutIth
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadHexB:	call	PutIth
		ret
;
;
;
; Output unsigned decimal numbers here:
;
PrintUDec:	call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		call	sl_USize		;Get the size of this guy.
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadUDec		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustUDec
		call	PrintPad		;Print padding characters
		call	PutItu			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustUDec:	call	PutItu
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadUDec:	call	PutItu
		ret
;
;
;
;
; Output a string here:
;
PrintString:	call	GetPtr			;Get next pointer into ES:BX
;
; Compute the length of the string:
;
		push	di
		push	cx
		mov	cx, -1
		mov	di, bx
		mov	al, 0
	repne	scasb
		mov	ax, cx
		neg	ax
		dec	ax
		dec	ax
		pop	cx
		pop	di
		sub	cx, ax			;Field width - String Length.
;
		js	NoPadStr		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustStr
		call	PrintPad		;Print padding characters
		call	Puts			;Print the string
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustStr:	call	Puts
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadStr:	call	Puts
		ret
GetFmtItem	endp
;
;
;
; Print a signed long decimal value here.
;
LongDec:	call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		push	dx
		mov	dx, es:2[bx]
		call	sl_LSize		;Get the size of this guy.
		pop	dx
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadLong		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustLong
		call	PrintPad		;Print padding characters
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutItL			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustLong:	push	dx
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutItL
		pop	dx
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadLong:	mov	dx, es:2[bx]		;Get H.O. word
		call	PutItl
		ret
;
;
; Print an unsigned long decimal value here.
;
LongU:		call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		push	dx
		mov	dx, es:[bx]
		call	sl_ULSize		;Get the size of this guy.
		pop	dx
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadULong		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustULong
		call	PrintPad		;Print padding characters
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutItUL			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustULong:	mov	dx, es:2[bx]		;Get H.O. word
		call	PutItUL
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadULong:	mov	dx, es:2[bx]		;Get H.O. word
		call	Putitul
		ret
;
;
; Print a long hexadecimal value here.
;
LongX:		call	GetPtr			;Get next pointer into ES:BX
		sub	cx, 8			;Compute padding
		js	NoPadXLong		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustXLong
		call	PrintPad		;Print padding characters
		mov	ax, es:2[bx]		;Get H.O. word
		call	PutItw
		mov	ax, es:[bx]
		call	PutItw
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustxLong:	mov	ax, es:2[bx]		;Get H.O. word
		call	PutItw
		mov	ax, es:[bx]		;Get L.O. word
		call	PutItw
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadxLong:	mov	ax, es:2[bx]		;Get H.O. word
		call	PutItw
		mov	ax, es:[bx]
		call	PutItw
		ret
;
;
;
;
; Puts- Outputs the zero terminated string pointed at by ES:BX.
;
Puts		proc	near
PutsLp:		mov	al, es:[bx]
		cmp	al, 0
		je	PutsDone
		call	putIt
		inc	bx
		jmp	PutsLp
;
PutsDone:	ret
Puts		endp
;
;
;
;
;
; PrintPad-	Prints padding characters.  Character to print is in DH.
;		We must print it CX times.  CX must be greater than zero.
;
PrintPad	proc	near
		push	ax
		mov	al, dh
		jcxz	NoPadding
PPLoop:		call	PutIt
		loop	PPLoop
NoPadding:	pop	ax
		ret
PrintPad	endp
;
;
;
;
;
; GetPtr- Grabs the next pointer which DS:DI points at and returns this
;	  far pointer in ES:BX.
;
GetPtr		proc	near
		les	bx, [di]
		add	di, 4
;
; See if this is a handle rather than a pointer.
;
		cmp	ah, '^'
		jne	NotHandle
		les	bx, es:[bx]
NotHandle:	ret
GetPtr		endp
;
;
;
;
;
; GetDecVal-	Converts the string of decimal digits in AL and [SI] into
;		an integer and returns this integer in CX.
;
GetDecVal	proc	near
		push	dx
		dec	si
		xor	cx, cx
DecLoop:	lodsb
		cmp	al, '0'
		jb	NoMore
		cmp	al, '9'
		ja	NoMore
		and	al, 0fh
		shl	cx, 1			;Compute CX := CX*10 + al
		mov	dx, cx
		shl	cx, 1
		shl	cx, 1
		add	cx, dx
		add	cl, al
		adc	ch, 0
		jmp	DecLoop
NoMore:		pop	dx
		ret
GetDecVal	endp
;
;
; PutItL - outputs the unsigned long value in AX to the string.
;
PutItL		proc
		push	bx
		push	cx
		push	es
		push	si
		push	ds
		push	di
		call	sl_ltoam
		call	ConCat
		pop	di
		pop	ds
		pop	si
		pop	es
		pop	cx
		pop	bx
		ret
PutItL		endp
;
;
; PutItUL - outputs the unsigned long value in AX to the string.
;
PutItUL		proc
		push	bx
		push	cx
		push	es
		push	si
		push	ds
		push	di
		call	sl_ultoam
		call	ConCat
		pop	di
		pop	ds
		pop	si
		pop	es
		pop	cx
		pop	bx
		ret
PutItUL		endp
;
;
;
; PutItw - outputs the hexadecimal value in AX to the string.
;
PutItw		proc
		push	bx
		push	cx
		push	es
		push	si
		push	ds
		push	di
		call	sl_wtoam
		call	ConCat
		pop	di
		pop	ds
		pop	si
		pop	es
		pop	cx
		pop	bx
		ret
PutItw		endp
;
;
; PutIth - outputs the hexadecimal value in AL to the string.
;
PutIth		proc
		push	bx
		push	cx
		push	es
		push	si
		push	ds
		push	di
		call	sl_htoam
		call	ConCat
		pop	di
		pop	ds
		pop	si
		pop	es
		pop	cx
		pop	bx
		ret
PutIth		endp
;
;
;
; PutIti - outputs the integer in AX to the string.
;
PutIti		proc
		push	bx
		push	cx
		push	es
		push	si
		push	ds
		push	di
		call	sl_itoam
		call	ConCat
		pop	di
		pop	ds
		pop	si
		pop	es
		pop	cx
		pop	bx
		ret
PutIti		endp
;
;
; PutItu - outputs the unsigned integer in AX to the string.
;
PutItu		proc
		push	bx
		push	cx
		push	es
		push	si
		push	ds
		push	di
		call	sl_utoam
		call	ConCat
		pop	di
		pop	ds
		pop	si
		pop	es
		pop	cx
		pop	bx
		ret
PutItu		endp
;
;
;
; ConCat- Concatenates the string pointed at by ES:DI to the end of our
;	  formatted string.
;
ConCat		proc	near
		push	di
		lds	si, StdGrp:aptr
		mov	bx, StdGrp:aindex
		sub	di, bx
PILp:		mov	al, es:[di][bx]
		mov	[si][bx], al
		inc	bx
		cmp	al, 0
		jne	PILp
		dec	bx
		mov	StdGrp:aindex, bx
		pop	di
		call	sl_free
		ret
ConCat		endp
;
; PutIt writes the character in AL to the string buffer area.
;
PutIt		proc
		push	es
		push	si
		push	bx
		mov	bx, StdGrp:aindex
		les	si, StdGrp:aptr
		mov	es:[si][bx], al
		mov	byte ptr es:1[si][bx], 0
		inc     StdGrp:aindex
		pop	bx
		pop	si
		pop	es
		ret
PutIt		endp
;
stdlib		ends
		end
