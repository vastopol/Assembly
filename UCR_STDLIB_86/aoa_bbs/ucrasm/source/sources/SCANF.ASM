StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn sl_print:far,sl_putw:far, sl_putcr:far
print	macro
 call sl_print
  endm
;
		extrn	sl_getsm:far, sl_free:far, sl_atoi2:far
		extrn	sl_atou2:far, sl_atol2:far, sl_atoul2:far
		extrn	sl_atoh2:far
;
;
; Scanf- Like the "C" routine by the same name.  Calling sequence:
;
;               call    scanf
;               db      "format string",0
;               dd      item1, item2, ..., itemn
;
; The format string is identical to "C".  Item1..Itemn are pointers to
; values to print for this string.  Each item must be matched by the
; corresponding "%xxx" item in the format string.
;
; Format string format:
;
; 1)    If a non-whitespace character in the format string matches the next
;	input character, scanf eats that input character;  otherwise scanf
;	ignores the character in the format string.  If any whitespace char-
;	acter appears, scanf ignores all leading whitespace characters (new-
;	line not included) before an item.  If there is no whitespace on the
;	input, scanf ignores the whitespace characters in the input stream.
;
; 2)	Format Control Strings:
;
;	General format:  "%^f" where:
;
;				^ = ^
;				f = a format character
;
;			The "^" is optional.
;
;	^ present	The address associated with f is the address of a
;				pointer to the object, not the address of
;				the object itself.  The pointer is a far ptr.
;
;	f is one of the following
;
;		d -	Read a signed integer in decimal notation.
;		i -	Read a signed integer in decimal notation.
;		x -	Read a word value in hexadecimal notation.
;		h -	Read a byte value in hexadecimal notation.
;		u -	Read an unsigned integer in decimal notation.
;		c -	Read a character.
;		s -	Read a string.
;
;		ld-	Read a long signed integer.
;		li-	Read a long signed integer.
;		lx-	Read a long hexadecimal number.
;		lu-	Read a long unsigned number.
;
;
;	Calling Sequence:
;
;		call	Scanf
;		db	"Format String",0
;		dd	adrs1, adrs2, ..., adrsn
;
;	Where the format string is ala "C" (and the descriptions above)
;	and adrs1..adrsn are addresses (far ptr) to the items to print.
;	Unless the "^" modifier is present, these addresses are the actual
;	addresses of the objects to print.
;
; Note: Scanf always calls GETS to read a new string from the standard
;	input device.  Reading a string variable always reads all input
;	from the current position to the end of the current line.
;
;
cr		equ	0dh
ff		equ	0ch
lf		equ	0ah
tab		equ	09h
bs		equ	08h
;
RtnAdrs		equ	<2[bp]>
OprndPtr	equ	<(0-4)[bp]>
InputPtr	equ	<(0-8)[bp]>
InpIndex	equ	<(0-10)[bp]>
;
		public  sl_scanf
sl_scanf	proc	far
;
; Read a line from the standard input and save away a pointer to it.
;
		push	bp
		mov	bp, sp
		sub	sp, 10			;Save ptr to operands here.
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
		call	sl_getsm
		call	scanf
		les	di, InputPtr
		call	sl_free
		mov	di, OprndPtr
		mov	RtnAdrs, di	;Put out new return address.
;
		pop	ds
		pop	es
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
		mov	sp, bp		;Remove local variables.
		pop	bp
		ret
;
sl_scanf	endp
;
;
; SSCANF-	Just like SCANF except you pass a pointer to the data
;		string in es:di rather than having scanf read it from
;		the keyboard.
;
		public	sl_sscanf
sl_sscanf	proc    far
		push	bp
		mov	bp, sp
		sub	sp, 10			;Save ptr to operands here.
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
		call	scanf
		mov	di, OprndPtr
		mov	RtnAdrs, di	;Put out new return address.
;
		pop	ds
		pop	es
		pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
		mov	sp, bp		;Remove local variables.
		pop	bp
		ret
sl_sscanf	endp
;
;
; "Guts" of the scanf routines.
;
scanf		proc	near
		mov	InputPtr+2, es		;Sock away ptr to string.
		mov	InputPtr, di
		mov	word ptr InpIndex, 0
;
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
		mov     OprndPtr, di
		mov	OprndPtr+2, es
;
ScanItems:      lodsb			;Get char si points at.
ScanItems2:	cmp	al, 0		;EOS?
		jz	ScanfDone
		cmp	al, "%"		;Start of a format string?
		jz	FmtItem
SkipIt:		cmp	al, " "
		jz	SkipWS
		les	di, InputPtr
		mov	bx, InpIndex
		cmp	al, es:[di][bx]
		jnz	ScanItems
		inc	word ptr InpIndex
		jmp	ScanItems
;
SkipWS:		les	di, InputPtr
		mov	bx, InpIndex
SkipWSLp:	cmp	byte ptr es:[di][bx], ' '
		jnz	DoneSkip
		inc	bx
		jmp	SkipWSLp
;
DoneSkip:	mov	InpIndex, bx
Skip2:		lodsb
		cmp	al, ' '			;Skip additional whitespace
		jz	Skip2			; in the format string.
		dec	si
		jmp	ScanItems
;
;
FmtItem:	call	GetFmtItem	;Process the format item here.
		jmp	ScanItems
;
;
ScanfDone:    	ret
scanf		endp
;
;
;
; If we just saw a "%", come down here to handle the format item.
;
GetFmtItem	proc	near
;
		lodsb				;Get char beyond "%"
;
; See if the user wants to specify a handle rather than a straight pointer
;
		cmp	al, '^'
		jne     ChkFmtChars
		mov	ah, al
		lodsb				;Skip "^" character
;
; Okay, process the format characters down here.
;
ChkFmtChars:	and	al, 05fh		;l.c. -> U.C.
		cmp	al, 'D'
		je	GetDec
		cmp	al, 'I'
		je	GetDec
		cmp	al, 'C'
		je	GetChar
;
		cmp	al, 'X'
		jne	TryH
		jmp	GetHexWord
;
TryH:		cmp	al, 'H'
		jne	TryU
		jmp	GetHexByte
;
TryU:		cmp	al, 'U'
		jne	TryString
		jmp	GetUDec
;
TryString:	cmp	al, 'S'
		jne	TryLong
		jmp	GetString
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
		jne	Default
		jmp	LongU
;
;
;
; If none of the above, simply return without printing anything.
;
Default:	ret
;
;
;
;
;
; Get a signed decimal value here.
;
GetDec:		call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at integer.
		cmp	byte ptr es:[di], 0	;At end of string?
		jz	QuitGetDec
		call	sl_atoi2		;Convert to integer in AX.
		sub	di, InputPtr
		mov	InpIndex, di
		pop	es         		; Ignore overflow or error.
		mov	es:[bx], ax
;
		pop	ax
		ret
;
QuitGetDec:	pop	es
		pop	ax
		ret				;We're done!
;
;
;
; Print a character variable here.
;
GetChar:	call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at char.
		mov	al, es:[di]		;Get char
		cmp	al, 0			;See if at EOS.
		jz	QuitGetChar
		inc	word ptr InpIndex	;Bump up index.
		pop	es         	
		mov	es:[bx], al
;
		pop	ax
		ret
;
QuitGetChar:	pop	es
		pop	ax
		ret				;We're done!
;
;
;
; Print a hexadecimal word value here.
;
GetHexWord:	call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at integer.
		cmp	byte ptr es:[di], 0	;Check for EOS
		jz	QuitGetHexWord
		call	sl_atoh2		;Convert to integer in AX.
		sub	di, InputPtr
		mov	InpIndex, di
		pop	es         		; Ignore overflow or error.
		mov	es:[bx], ax
;
		pop	ax
		ret
;
QuitGetHexWord:	pop	es
		pop	ax
		ret				;We're done!
;
;
;
;
; Print hex bytes here.
;
;
GetHexByte:	call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at integer.
		cmp	byte ptr es:[di], 0	;Check for EOS.
		jz	QuitGetHexByte
		call	sl_atoh2		;Convert to integer in AX.
		sub	di, InputPtr
		mov	InpIndex, di
		pop	es         		; Ignore overflow or error.
		mov	es:[bx], al
;
		pop	ax
		ret
;
QuitGetHexByte:	pop	es
		pop	ax
		ret				;We're done!
;
;
;
; Output unsigned decimal numbers here:
;
GetUDec:	call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at integer.
		cmp	byte ptr es:[di], 0	;Check for EOS.
		jz	QuitGetUDec
		call	sl_atou2		;Convert to integer in AX.
		sub	di, InputPtr
		mov	InpIndex, di
		pop	es         		; Ignore overflow or error.
		mov	es:[bx], ax
;
		pop	ax
		ret
;
QuitGetUDec:	pop	es
		pop	ax
		ret				;We're done!
;
;
; Output a string here:
;
GetString:	push	ax
		push	si
		push	es
		push	ds
;
		call	GetPtr
		mov	di, bx
		lds	si, InputPtr
		add	si, InpIndex
GetStrLp:	lodsb			;Get next char
		stosb
		cmp	al, 0
		jnz	GetStrLp
		sub	si, InputPtr
		dec	si
		mov	InpIndex, si
;
		pop	ds
		pop	es
		pop	si
		pop	ax
		ret				;We're done!
;
;
;
; Print a signed long decimal value here.
;
LongDec:	push	dx
		call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at integer.
		cmp	byte ptr es:[di], 0	;Check for EOS.
		jz	QuitLongDec
		call	sl_atol2		;Convert to integer in AX.
		sub	di, InputPtr
		mov	InpIndex, di
		pop	es         		; Ignore overflow or error.
		mov	es:[bx], ax
		mov	es:2[bx], dx
;
		pop	ax
		pop	dx
		ret				;We're done!
;
QuitLongDec:	pop	es
		pop	ax
		pop	dx
		ret
;
;
;
; Print an unsigned long decimal value here.
;
LongU:		push	dx
		call	GetPtr			;Get next pointer into ES:BX
		push	ax			;Save possible "^" char in ah
		push	es
		les	di, InputPtr
		add	di, InpIndex		;Point SI at integer.
		cmp	byte ptr es:[di], 0
		je	QuitLongU
		call	sl_atoul2		;Convert to integer in AX.
		sub	di, InputPtr
		mov	InpIndex, di
		pop	es         		; Ignore overflow or error.
		mov	es:[bx], ax
		mov	es:2[bx], dx
;
		pop	ax
		pop	dx
		ret				;We're done!
;
QuitLongU:	pop	es
		pop	ax
		pop	dx
		ret
;
GetFmtItem	endp
;
;
;
;
;
;
; GetPtr- Grabs the next pointer which OprndPtr points at and returns this
;	  far pointer in ES:BX.
;
GetPtr		proc	near
		les	di, OprndPtr
		les	bx, es:[di]
		add	word ptr OprndPtr, 4
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
stdlib		ends
		end
