StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_Putc:far, sl_Puti:far, sl_ISize:far
		extrn	sl_Putw:far, sl_Puth:far
		extrn	sl_Putu:far, sl_PutUL:far, sl_ULSize:far
		extrn	sl_LSize:far, sl_USize:far, sl_PutL:far
;
putc		equ	sl_putc
puti		equ	sl_puti
ISize		equ	sl_ISize
putw		equ	sl_putw
puth		equ	sl_puth
putu		equ	sl_putu
putul		equ	sl_putul
ulsize		equ	sl_ulsize
lsize		equ	sl_lsize
usize		equ	sl_usize
putl		equ	sl_putl
;
;
; Printf- Like the "C" routine by the same name.  Calling sequence:
;
;               call    printf
;               db      "format string",0
;               dd      item1, item2, ..., itemn
;
; The format string is identical to "C".  Item1..Itemn are pointers to
; values to print for this string.  Each item must be matched by the
; corresponding "%xxx" item in the format string.
;
; Format string format:
;
; 1)    All characters, except the following, are printed to the standard
;       output as-is.
;
; 2)    "\" is the escape character.  Anything following it is printed
;       as-is except standard "C" values like \r, \n, \b, \t, etc.  If
;       a decimal digit follows the back-slash, printf assumes that this
;       is a hexadecimal number and converts following three digits to
;       an ASCII character and prints it.  Other back-slash operators are
;       just like those for "C".
;
; 3)	Format Control Strings:
;
;	General format:  "%s\cn^f" where:
;				s = -
;				n = a decimal integer
;				c = a fill character
;				^ = ^
;				f = a format character
;
;			All fields except "%" and "f" are optional.
;
;	s = -   	Left justify value and use fill character.
;	\c present	Use "c" as fill character.
;	n present	Use "n" as the minimum field width.
;	^ present	The address associated with f is the address of a
;				pointer to the object, not the address of
;				the object itself.  The pointer is a far ptr.
;
;	f is one of the following
;
;		d -	Print signed integer in decimal notation.
;		i -	Print signed integer in decimal notation.
;		x -	Print word value in hexadecimal notation.
;		h -	Print byte value in hexadecimal notation.
;		u -	Print unsigned integer in decimal notation.
;		c -	Print character.
;		s -	Print string.
;
;		ld-	Print long signed integer.
;		li-	Print long unsigned integer.
;		lx-	Print long hexadecimal number.
;		lu-	Print long unsigned number.
;
;
;	Calling Sequence:
;
;		call	Printf
;		db	"Format String",0
;		dd	adrs1, adrs2, ..., adrsn
;
;	Where the format string is ala "C" (and the descriptions above)
;	and adrs1..adrsn are addresses (far ptr) to the items to print.
;	Unless the "^" modifier is present, these addresses are the actual
;	addresses of the objects to print.
;
;
;
cr		equ	0dh
ff		equ	0ch
lf		equ	0ah
tab		equ	09h
bs		equ	08h
;
RtnAdrs		equ	2[bp]
;
		public  sl_printf
sl_printf	proc    far
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
; Get pointers to the return address (format string).
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
PrintIt:	call	Putc
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
		ret
sl_printf       endp
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
		call	Putc
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
TryLong:		cmp	al, 'L'
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
		call	ISize			;Get the size of this guy.
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadDec		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustDec
		call	PrintPad		;Print padding characters
		call	Puti			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustDec:	call	Puti
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadDec:	call	Puti
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
		call	Putc			;Print the character
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustChar:	call	Putc
		call	PrintPad
		ret
;
; Print non-justified character here:
;
NoPadChar:	call	Putc
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
		call	Putw			;Print the hex value
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustHexW:	call	Putw
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadHexW:	call	Putw
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
		sub	cx, 2			;Compute padding
		js	NoPadHexB		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustHexB
		call	PrintPad		;Print padding characters
		call	Puth			;Print the hex value
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustHexB:	call	Puth
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadHexB:	call	Puth
		ret
;
;
;
; Output unsigned decimal numbers here:
;
PrintUDec:	call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		call	USize			;Get the size of this guy.
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadUDec		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustUDec
		call	PrintPad		;Print padding characters
		call	Putu			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustUDec:	call	Putu
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadUDec:	call	Putu
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
		call	LSize			;Get the size of this guy.
		pop	dx
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadLong		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustLong
		call	PrintPad		;Print padding characters
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutL			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustLong:	push	dx
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutL
		pop	dx
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadLong:	mov	dx, es:2[bx]		;Get H.O. word
		call	Putl
		ret
;
;
; Print an unsigned long decimal value here.
;
LongU:		call	GetPtr			;Get next pointer into ES:BX
		mov	ax, es:[bx]		;Get value to print.
		push	dx
		mov	dx, es:[bx]
		call	ULSize			;Get the size of this guy.
		pop	dx
		sub	cx, ax		     	;Compute padding
		mov	ax, es:[bx]		;Retrieve value to print.
		js	NoPadULong		;Is CX negative?
		cmp	dl, 0			;Right justified?
		jne	LeftJustULong
		call	PrintPad		;Print padding characters
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutUL			;Print the integer
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustULong:	push	dx
		mov	dx, es:2[bx]		;Get H.O. word
		call	PutUL
		pop	dx
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadULong:	mov	dx, es:2[bx]		;Get H.O. word
		call	Putul
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
		call	Putw
		mov	ax, es:[bx]
		call	Putw
		ret				;We're done!
;
; Print left justified value here.
;
LeftJustxLong:	mov	ax, es:2[bx]		;Get H.O. word
		call	Putw
		mov	ax, es:[bx]		;Get L.O. word
		call	Putw
		call	PrintPad
		ret
;
; Print non-justified value here:
;
NoPadxLong:	mov	ax, es:2[bx]		;Get H.O. word
		call	Putw
		mov	ax, es:[bx]
		call	Putw
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
		call	putc
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
PPLoop:		call	Putc
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
stdlib		ends
		end
