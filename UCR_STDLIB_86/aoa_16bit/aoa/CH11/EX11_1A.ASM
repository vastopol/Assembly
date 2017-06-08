; Ex11_1a.asm
;
; Assembly code to link with a C/C++ program.
; This code directly manipulates the screen giving C++
; direct access control of the screen.
;
; Note: Like PGM11_1.ASM, this code is relatively inefficient.
; It could be sped up quite a bit using the 80x86 string instructions.
; However, its inefficiency is actually a plus here since we don't
; want the C/C++ program (Ex11_1.cpp) running too fast anyway.
;
;
; This code assumes that Ex11_1.cpp is compiled using the LARGE
; memory model (far procs and far pointers).


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386			;Comment out these two statements
                option  segment:use16   ; if you are not using an 80386.


; ScrSeg- This is the video screen's segment address.  It should be
;		B000 for mono screens and B800 for color screens.

ScrSeg		=	0B800h





_TEXT           segment para public 'CODE'
                assume  cs:_TEXT


; _Capture-      Copies the data on the screen to the array passed
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
;       | Return Adrs (offset)  |
;	-------------------------
;       |  X coordinate value   |
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Registers, etc.	|
;	------------------------- <- SP



ScrCopy_cap     textequ <dword ptr [bp+4]>
X_cap		textequ	<word ptr [bp-2]>
Y_cap		textequ	<word ptr [bp-4]>

                public  _Capture
_Capture        proc    near
		push	bp
		mov	bp, sp

		push	es
		push	ds
		push	si
		push	di
		pushf
		cld

		mov	si, ScrSeg		;Set up pointer to SCREEN
		mov	ds, si			; memory (ScrSeg:0).
		sub	si, si

		les	di, ScrCopy_cap		;Get ptr to capture array.

		mov	cx, 1000		;1000 double words on the screen
	rep	movsd

		popf
		pop	di
		pop	si
		pop	ds
		pop	es
		mov	sp, bp
		pop	bp
                ret     
_Capture        endp





; _PutScr-      Copies array passed by reference onto the screen.
;
; procedure PutScr(var ScrCopy:array[0..24,0..79] of word);
; var x,y:integer;
; begin
;
;	for y := 0 to 24 do
;	    for x := 0 to 79 do
;		ScrCopy[y,x] := SCREEN[y,x];
; end;
;
;
; Activation record for PutScr:
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;	|  ScrCopy Seg Adrs	|
;	--		       --
;	| ScrCopy offset Adrs	|
;	-------------------------
;       | Return Adrs (offset)  |
;	-------------------------
;       |     BP Value          | <- BP
;	-------------------------
;       |  X coordinate value   |
;	-------------------------
;	|  Y coordinate value	|
;	-------------------------
;	| Registers, etc.	|
;	------------------------- <- SP



ScrCopy_fill	textequ	<dword ptr [bp+4]>
X_fill		textequ	<word ptr [bp-2]>
Y_fill		textequ	<word ptr [bp-4]>

                public  _PutScr
_PutScr         proc    near
		push	bp
		mov	bp, sp

		push	es
		push	ds
		push	si
		push	di
		pushf
		cld

		mov	di, ScrSeg		;Set up pointer to SCREEN
		mov	es, di			; memory (ScrSeg:0).
		sub	di, di

		lds	si, ScrCopy_cap		;Get ptr to capture array.

		mov	cx, 1000		;1000 double words on the screen
	rep	movsd

		popf
		pop	di
		pop	si
		pop	ds
		pop	es
		mov	sp, bp
		pop	bp
                ret     
_PutScr         endp







; GotoXY-	Positions the cursor at the specified X, Y coordinate.
;
; procedure gotoxy(y,x:integer);
; begin
;	BIOS(posnCursor,x,y);
; end;
;
; Activation record for GotoXY
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;       |  X coordinate value   |
;	-------------------------
;       |  Y coordinate value   |
;	-------------------------
;       |  Return Adrs (offset) |
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	| Registers, etc.	|
;	------------------------- <- SP


X_gxy           textequ <byte ptr [bp+6]>
Y_gxy           textequ <byte ptr [bp+4]>

                public  _GotoXY
_GotoXY         proc    near
		push	bp
		mov	bp, sp

		mov	ah, 2			;Magic BIOS value for gotoxy.
		mov	bh, 0			;Display page zero.
		mov	dh, Y_gxy		;Set up BIOS (X,Y) parameters.
		mov	dl, X_gxy
		int	10h			;Make the BIOS call.

		mov	sp, bp
		pop	bp
                ret     
_GotoXY         endp



; ClrScrn-    Clears the screen and positions the cursor at (0,0).
;
; procedure ClrScrn;
; begin
;	BIOS(Initialize)
; end;
;
; Activation record for ClrScrn
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;       |  Return Adrs (offset) |
;	------------------------- <- SP



                public  _ClrScrn
_ClrScrn        proc    near

		mov	ah, 6		;Magic BIOS number.
		mov	al, 0		;Clear entire screen.
		mov	bh, 07		;Clear with black spaces.
		mov	cx, 0000	;Upper left corner is (0,0)
		mov	dl, 79		;Lower X-coordinate
		mov	dh, 24		;Lower Y-coordinate
		int	10h		;Make the BIOS call.

		push	0		;Position the cursor to (0,0)
		push	0		; after the call.
                call    _GotoXY
                add     sp, 4           ;Remove parameters from stack.

		ret
_ClrScrn        endp




; tstKbd-       Checks to see if a key is available at the keyboard.
;
; function tstKbd:boolean;
; begin
;       if BIOSKeyAvail then eat key and return true
;       else return false;
; end;
;
; Activation record for tstKbd
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;       |  Return Adrs (offset) |
;	------------------------- <- SP

                public  _tstKbd
_tstKbd         proc    near
                mov     ah, 1           ;Check to see if key avail.
                int     16h
                je      NoKey
                mov     ah, 0           ;Eat the key if there is one.
                int     16h
                mov     ax, 1           ;Return true.
                ret

NoKey:          mov     ax, 0           ;No key, so return false.
                ret
_tstKbd         endp



; GetXY- Returns the cursor's current X and Y coordinates.
;
; procedure GetXY(var x:integer; var y:integer);
;
; Activation record for GetXY
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;       |    Y Coordinate       |
;       ---    Address        ---
;       |                       |
;	-------------------------
;       |    X coordinate       |
;       ---    Address        ---
;       |                       |
;	-------------------------
;       |  Return Adrs (offset) |
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	| Registers, etc.	|
;	------------------------- <- SP


GXY_X           textequ <[bp+4]>
GXY_Y           textequ <[bp+8]>

                public  _GetXY
_GetXY          proc    near
                push    bp
                mov     bp, sp
                push    es

                mov     ah, 3           ;Read X, Y coordinates from
                mov     bh, 0           ; BIOS
                int     10h

                les     bx, GXY_X
                mov     es:[bx], dl
                mov     byte ptr es:[bx+1], 0

                les     bx, GXY_Y
                mov     es:[bx], dh
                mov     byte ptr es:[bx+1], 0

                pop     es
                pop     bp
                ret
_GetXY          endp



; PutChar- Outputs a single character to the screen at the current
;          cursor position.
;
; procedure PutChar(ch:char);
;
; Activation record for PutChar
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;       | char (in L.O. byte    |
;	-------------------------
;       |  Return Adrs (offset) |
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	| Registers, etc.	|
;	------------------------- <- SP


ch_pc           textequ <[bp+4]>

                public  _PutChar
_PutChar        proc    near
                push    bp
                mov     bp, sp

                mov     al, ch_pc
                mov     ah, 0eh
                int     10h

                pop     bp
                ret
_PutChar        endp



; PutStr-  Outputs a string to the display at the current cursor position.
;          Note that a string is a sequence of characters that ends with
;          a zero byte.
;
; procedure PutStr(var str:string);
;
; Activation record for PutStr
;
;	|			|
;	| Previous stk contents	|
;	-------------------------
;       |      String           |
;       ---    Address        ---
;       |                       |
;	-------------------------
;       |  Return Adrs (offset) |
;	-------------------------
;	|      Old BP		|
;	------------------------- <- BP
;	| Registers, etc.	|
;	------------------------- <- SP


Str_ps          textequ <[bp+4]>

                public  _PutStr
_PutStr         proc    near
                push    bp
                mov     bp, sp
                push    es

                les     bx, Str_ps
PS_Loop:        mov     al, es:[bx]
                cmp     al, 0
                je      PC_Done

                push    ax
                call    _PutChar
                pop     ax
                inc     bx
                jmp     PS_Loop

PC_Done:        pop     es
                pop     bp
                ret
_PutStr         endp







; StartPgm-     This is where DOS starts running the program.  This is
;               a substitute for the C0L.OBJ file normally linked in by
;               the Borland C++ compiler.  This code provides this
;               routine to avoid legal problems (i.e., distributing
;               unlinked Borland libraries).  You can safely ignore
;               this code.  Note that the C++ main program is a near
;               procedure, so this code needs to be in the _TEXT segment.

                extern  _main:near
StartPgm        proc    near

                mov     ax, _DATA
                mov     ds, ax
                mov     es, ax
                mov     ss, ax
                lea     sp, EndStk

                call    near ptr _main
                mov     ah, 4ch
                int     21h
StartPgm        endp


_TEXT           ends


_DATA           segment word public "DATA"
stack           word    1000h dup (?)
EndStk          word    ?

_DATA           ends

sseg            segment para stack 'STACK'
                word    1000h dup (?)
sseg            ends


                end     StartPgm
