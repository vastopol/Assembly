; Pgm11_1.asm
;
; Screen Aids.
;
; This program provides some useful screen manipulation routines
; that let you do things like position the cursor, save and restore
; the contents of the display screen, clear the screen, etc.
;
; This program is not very efficient.  It was written to demonstrate
; parameter passing, use of local variables, and direct conversion of
; loops to assembly language.  There are far better ways of doing
; what this program does (running about 5-10x faster) using the 80x86
; string instructions.



		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386			;Comment out these two statements
		option	segment:use16	; if you are not using an 80386.


; ScrSeg- This is the video screen's segment address.  It should be
;		B000 for mono screens and B800 for color screens.

ScrSeg		=	0B800h






dseg		segment	para public 'data'

XPosn		word	?		;Cursor X-Coordinate (0..79)
YPosn		word	?		;Cursor Y-Coordinate (0..24)

; The following array holds a copy of the initial screen data.

SaveScr		word	25 dup (80 dup (?))

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Capture-	Copies the data on the screen to the array passed
;		by reference as a parameter.
;
; procedure Capture(var ScrCopy:array[0..24,0..79] of word);
; var x,y:integer;
; begin
;
;	for y := 0 to 24 do
;	    for x := 0 to 79 do
;		SCREEN[y,x] := ScrCopy[y,x];
; end;
;
;
; Activation record for Capture:
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;	|  ScrCopy Seg Adrs	|
;	--		       --
;	| ScrCopy offset Adrs	|
;	-------------------------
;	| Return Adrs (near)	|
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	|  X coordinate value	|
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Registers, etc.	|
;	------------------------- <- SP



ScrCopy_cap	textequ	<dword ptr [bp+4]>
X_cap		textequ	<word ptr [bp-2]>
Y_cap		textequ	<word ptr [bp-4]>

Capture		proc
		push	bp
		mov	bp, sp
		sub	sp, 4			;Allocate room for locals.

		push	es
		push	ds
		push	ax
		push	bx
		push	di

		mov	bx, ScrSeg		;Set up pointer to SCREEN
		mov	es, bx			; memory (ScrSeg:0).

		lds	di, ScrCopy_cap		;Get ptr to capture array.

		mov	Y_cap, 0
YLoop:		mov	X_cap, 0
XLoop:		mov	bx, Y_cap
		imul	bx, 80			;Screen memory is a 25x80 array
		add	bx, X_cap		; stored in row major order
		add	bx, bx			; with two bytes per element.

		mov	ax, es:[bx]		;Read character code from screen.
		mov	ds:[di][bx], ax		;Store away into capture array.

		inc	X_Cap			;Repeat for each character on this
		cmp	X_Cap, 80		; row of characters (each character
		jb	XLoop			; in the row is two bytes).

		inc	Y_Cap			;Repeat for each row on the screen.
		cmp	Y_Cap, 25
		jb	YLoop

		pop	di
		pop	bx
		pop	ax
		pop	ds
		pop	es
		mov	sp, bp
		pop	bp
		ret	4
Capture		endp





; Fill-		Copies array passed by reference onto the screen.
;
; procedure Fill(var ScrCopy:array[0..24,0..79] of word);
; var x,y:integer;
; begin
;
;	for y := 0 to 24 do
;	    for x := 0 to 79 do
;		ScrCopy[y,x] := SCREEN[y,x];
; end;
;
;
; Activation record for Fill:
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;	|  ScrCopy Seg Adrs	|
;	--		       --
;	| ScrCopy offset Adrs	|
;	-------------------------
;	| Return Adrs (near)	|
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	|  X coordinate value	|
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Registers, etc.	|
;	------------------------- <- SP



ScrCopy_fill	textequ	<dword ptr [bp+4]>
X_fill		textequ	<word ptr [bp-2]>
Y_fill		textequ	<word ptr [bp-4]>

Fill		proc
		push	bp
		mov	bp, sp
		sub	sp, 4

		push	es
		push	ds
		push	ax
		push	bx
		push	di

		mov	bx, ScrSeg		;Set up pointer to SCREEN
		mov	es, bx			; memory (ScrSeg:0).

		lds	di, ScrCopy_fill	;Get ptr to data array.

		mov	Y_Fill, 0
YLoop:		mov	X_Fill, 0
XLoop:		mov	bx, Y_Fill
		imul	bx, 80			;Screen memory is a 25x80 array
		add	bx, X_Fill		; stored in row major order
		add	bx, bx			; with two bytes per element.

		mov	ax, ds:[di][bx]		;Store away into capture array.
		mov	es:[bx], ax		;Read character code from screen.

		inc	X_Fill			;Repeat for each character on this
		cmp	X_Fill, 80		; row of characters (each character
		jb	XLoop			; in the row is two bytes).

		inc	Y_Fill			;Repeat for each row on the screen.
		cmp	Y_Fill, 25
		jb	YLoop

		pop	di
		pop	bx
		pop	ax
		pop	ds
		pop	es
		mov	sp, bp
		pop	bp
		ret	4
Fill		endp





; Scroll_up-	Scrolls the screen up on line.  It does this by copying the second line
;		to the first, the third line to the second, the fourth line to the third,
;		etc.
;
; procedure Scroll_up;
; var x,y:integer;
; begin
;	for y := 1 to 24 do
;	    for x := 0 to 79 do
;		SCREEN[Y-1,X] := SCREEN[Y,X];
; end;
;
; Activation record for Scroll_up:
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;	| Return Adrs (near)	|
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	|  X coordinate value	|
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Registers, etc.	|
;	------------------------- <- SP



X_su		textequ	<word ptr [bp-2]>
Y_su		textequ	<word ptr [bp-4]>

Scroll_up	proc
		push	bp
		mov	bp, sp
		sub	sp, 4			;Make room for X, Y.

		push	ds
		push	ax
		push	bx

		mov	ax, ScrSeg
		mov	ds, ax
		mov	Y_su, 0
su_Loop1:	mov	X_su, 0

su_Loop2:	mov	bx, Y_su		;Compute index into screen
		imul	bx, 80			; array.
		add	bx, X_su
		add	bx, bx			;Remember, this is a word array.
	
		mov	ax, ds:[bx+160]		;Fetch word from source line.
		mov	ds:[bx], ax		;Store into dest line.

		inc	X_su
		cmp	X_su, 80
		jb	su_Loop2

		inc	Y_su
		cmp	Y_su, 80
		jb	su_Loop1

		pop	bx
		pop	ax
		pop	ds
		mov	sp, bp
		pop	bp
		ret
Scroll_up	endp






; Scroll_dn-	Scrolls the screen down one line.  It does this by copying the 24th line
;		to the 25th, the 23rd line to the 24th, the 22nd line to the 23rd,
;		etc.
;
; procedure Scroll_dn;
; var x,y:integer;
; begin
;	for y := 23 downto 0 do
;	    for x := 0 to 79 do
;		SCREEN[Y+1,X] := SCREEN[Y,X];
; end;
;
; Activation record for Scroll_dn:
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;	| Return Adrs (near)	|
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	|  X coordinate value	|
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Registers, etc.	|
;	------------------------- <- SP


X_sd		textequ	<word ptr [bp-2]>
Y_sd		textequ	<word ptr [bp-4]>

Scroll_dn	proc
		push	bp
		mov	bp, sp
		sub	sp, 4			;Make room for X, Y.

		push	ds
		push	ax
		push	bx

		mov	ax, ScrSeg
		mov	ds, ax
		mov	Y_sd, 23
sd_Loop1:	mov	X_sd, 0

sd_Loop2:	mov	bx, Y_sd		;Compute index into screen
		imul	bx, 80			; array.
		add	bx, X_sd
		add	bx, bx			;Remember, this is a word array.
	
		mov	ax, ds:[bx]		;Fetch word from source line.
		mov	ds:[bx+160], ax		;Store into dest line.

		inc	X_sd
		cmp	X_sd, 80
		jb	sd_Loop2

		dec	Y_sd
		cmp	Y_sd, 0
		jge	sd_Loop1

		pop	bx
		pop	ax
		pop	ds
		mov	sp, bp
		pop	bp
		ret
Scroll_dn	endp




; GotoXY-	Positions the cursor at the specified X, Y coordinate.
;
; procedure gotoxy(x,y:integer);
; begin
;	BIOS(posnCursor,x,y);
; end;
;
; Activation record for GotoXY
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;	|  X coordinate value	|
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Return Adrs (near)	|
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	| Registers, etc.	|
;	------------------------- <- SP


X_gxy		textequ	<byte ptr [bp+6]>
Y_gxy		textequ	<byte ptr [bp+4]>

GotoXY		proc
		push	bp
		mov	bp, sp
		push	ax
		push	bx
		push	dx

		mov	ah, 2			;Magic BIOS value for gotoxy.
		mov	bh, 0			;Display page zero.
		mov	dh, Y_gxy		;Set up BIOS (X,Y) parameters.
		mov	dl, X_gxy
		int	10h			;Make the BIOS call.

		pop	dx
		pop	bx
		pop	ax
		mov	sp, bp
		pop	bp
		ret	4
GotoXY		endp



; GetX-		Returns cursor X-Coordinate in the AX register.

GetX		proc
		push	bx
		push	cx
		push	dx

		mov	ah, 3		;Read X, Y coordinates from
		mov	bh, 0		; BIOS
		int	10h

		mov	al, dl		;Return X coordinate in AX.
		mov	ah, 0

		pop	dx
		pop	cx
		pop	bx
		ret
GetX		endp



; GetY-		Returns cursor Y-Coordinate in the AX register.

GetY		proc
		push	bx
		push	cx
		push	dx

		mov	ah, 3
		mov	bh, 0
		int	10h

		mov	al, dh		;Return Y Coordinate in AX.
		mov	ah, 0

		pop	dx
		pop	cx
		pop	bx
		ret
GetY		endp



; ClearScrn-	Clears the screen and positions the cursor at (0,0).
;
; procedure ClearScrn;
; begin
;	BIOS(Initialize)
; end;

ClearScrn	proc
		push	ax
		push	bx
		push	cx
		push	dx

		mov	ah, 6		;Magic BIOS number.
		mov	al, 0		;Clear entire screen.
		mov	bh, 07		;Clear with black spaces.
		mov	cx, 0000	;Upper left corner is (0,0)
		mov	dl, 79		;Lower X-coordinate
		mov	dh, 24		;Lower Y-coordinate
		int	10h		;Make the BIOS call.

		push	0		;Position the cursor to (0,0)
		push	0		; after the call.
		call	GotoXY

		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
ClearScrn	endp




; A short main program to test out the above:

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; Save the screen as it looks when this program is run.

		push	seg SaveScr
		push	offset SaveScr
		call	Capture

		call	GetX
		mov	XPosn, ax

		call	GetY
		mov	YPosn, ax


; Clear the screen to prepare for our stuff.

		call	ClearScrn

; Position the cursor in the middle of the screen and print some stuff.

		push	30		;X value
		push	10		;Y value
		call	GotoXY

		print
		byte	"Screen Manipulatation Demo",0

		push	30
		push	11
		call	GotoXY

		print
		byte	"Press any key to continue",0

		getc


; Scroll the screen up two lines

		call	Scroll_up
		call	Scroll_up
		getc

;Scroll the screen down four lines:

		call	Scroll_dn
		call	Scroll_dn
		call	Scroll_dn
		call	Scroll_dn
		getc




; Restore the screen to what it looked like prior to this call.

		push	seg SaveScr
		push	offset SaveScr
		call	Fill

		push	XPosn
		push	YPosn
		call	GotoXY



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
