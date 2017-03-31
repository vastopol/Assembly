include stdlib.a
includelib stdlib.lib
include exo.a
include exo.aa
include endo.a
include endo.aa

;****************************************************************************
;
; SHELL.ASM-
;
; 	This is a "typical" piece of starting code for the stdlib package.
;	Whenever you begin a new assembly language program you should start
;	with this code (or something similar to it).
;
;
; Global variables go here:
;
dseg		segment	para public 'data'
;
; Insert your global variables in here.
;
exoobj		exo <>
endoobj		endo <>
endoobj2	endo <>
endoobj3	endo <>
base		baseobj <>
dseg		ends
;
;
;
;
cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg
;
;
; lesi- macro to do a "les di, constant"
;
lesi		macro	adrs
		mov     di, seg adrs
		mov	es, di
		lea	di, adrs
		endm

;
; ldsi- macro to do a "lds si, constant" operation.
;

ldsi		macro 	adrs
		mov	si, seg adrs
		mov	ds, si
		lea	si, adrs
		endm


;
; ldxi- macro to do a "ldx si, constant" operation.
;

ldxi		macro	adrs
		mov	dx, seg adrs
		lea	si, adrs
		endm
;
; Variables that wind up being used by the standard library routines.
; The MemInit routine uses "PSP" and "zzzzzzseg" labels.  They must be
; present if you intend to use getenv, MemInit, malloc, and free.
;
;
		public	PSP
PSP		dw	?			;Must be in CODE segment!
;
;
; Some useful constants:
;
cr		equ	13
lf		equ	10
eos		equ	0
;
true		equ	1
false		equ	0
;
;
; Main is the main program.  Program execution always begins here.
;
Main		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
		mov	dx, 0			;Allocate all available RAM.
                MemInit

;
		lesi	exoobj
		call	es:[di].exo.methods.constructor
		call	es:[di].exo.methods.clear
		ldsi	endoobj
		call	es:[di].exo.methods.createwin
		ldsi	endoobj2
		mov	ds:[si].endo.data.pxo, 15
		mov	ds:[si].endo.data.pyo, 10
		call	es:[di].exo.methods.createwin
		ldsi	endoobj3
		mov	ds:[si].endo.data.pxo, 35
		mov	ds:[si].endo.data.pyo, 8
		call	es:[di].exo.methods.createwin
		push	cx
		push	es
		push	di
		mov	cx, 16200d		;90x90 times 2 (in words)
		malloc
		mov	WORD PTR ds:[si].endo.data.logical, di
		mov	WORD PTR ds:[si].endo.data.logical[2], es
		mov	bx, di
		mov	cx, es
		lesi	endoobj
		mov	WORD PTR es:[di].endo.data.logical, bx
		mov	WORD PTR es:[di].endo.data.logical[2], cx
		lesi	endoobj2
		mov	WORD PTR es:[di].endo.data.logical, bx
		mov	WORD PTR es:[di].endo.data.logical[2], cx
		pop	di
		pop	es
		pop	cx
		mov	ds:[si].endo.data.lxs, 90
		mov	ds:[si].endo.data.lys, 90

		push	bx
		push	cx
		mov	bx, 0
		push	es
		push	di
		mov	cx, 90d
		les	di, ds:[si].endo.data.logical
reset:		mov	al, 30h
		mov	ah, ds:[si].endo.data.attr
lp:
		push	cx
		mov	cx, 90d
inner:		mov	es:[di][bx], ax
		inc	bx
		inc	bx
		inc	al
		loop	inner
		cmp	al, 3Bh
		jne	skip
		mov	al, 30h
skip:
		pop	cx
		loop	lp
		pop	di
		pop	es
		pop	cx
		pop	bx

		call    es:[di].exo.methods.engine
		call	es:[di].exo.methods.update

get:
		Getc
		cmp	al, 'w'
		je	scrup
		cmp	al, 's'
		je	scrdown
		cmp	al, 'a'
		je	scrleft
		cmp	al, 'd'
		je	scrright
		cmp	al, 'q'
		je	done

		cmp	al, 'i'
		je	movup
		cmp	al, 'k'
		je	movdown
		cmp	al, 'j'
		je	movleft
		cmp	al, 'l'
		je	movright
		cmp	al, '>'
		je	enlarge
		cmp	al, '<'
		je	shrink
		cmp	al, '^'
		je	float
		cmp	al, 'v'
		je	sink
		cmp	al, '1'
		jne	next2
		ldsi	endoobj
		jmp	get
next2:		cmp	al, '2'
		jne	next3
		ldsi	endoobj2
		jmp	get
next3:		cmp	al, '3'
		ldsi	endoobj3
		jmp	get
scrup:		call	ds:[si].endo.methods.scrup
		jmp	update
scrdown:	call	ds:[si].endo.methods.scrdown
		jmp	update
scrleft:	call	ds:[si].endo.methods.scrleft
		jmp	update
scrright:	call	ds:[si].endo.methods.scrright
		jmp	update
float:
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		call	es:[di].exo.methods.floatwin
		pop	bx
		jmp	update
sink:
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		call	es:[di].exo.methods.sinkwin
		pop	bx
		jmp	update

enlarge:
		push	ax
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		mov	al, ds:[si].endo.data.pxs
		mov	ah, ds:[si].endo.data.pys
		inc	ah
		inc	al
		call	es:[di].exo.methods.resizewin
		pop	bx
		pop	ax
		jmp	update
shrink:
		push	ax
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		mov	al, ds:[si].endo.data.pxs
		mov	ah, ds:[si].endo.data.pys
		dec	ah
		dec	al
		call	es:[di].exo.methods.resizewin
		pop	bx
		pop	ax
		jmp	update
movup:
		push	ax
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		mov	al, ds:[si].endo.data.pxo
		mov	ah, ds:[si].endo.data.pyo
		dec	ah
		call	es:[di].exo.methods.movewin
		pop	bx
		pop	ax
		jmp	update
movdown:
		push	ax
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		mov	al, ds:[si].endo.data.pxo
		mov	ah, ds:[si].endo.data.pyo
		inc	ah
		call	es:[di].exo.methods.movewin
		pop	bx
		pop	ax
		jmp	update
movleft:
		push	ax
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		mov	al, ds:[si].endo.data.pxo
		mov	ah, ds:[si].endo.data.pyo
		dec	al
		call	es:[di].exo.methods.movewin
		pop	bx
		pop	ax
		jmp	update
movright:
		push	ax
		push	bx
		xor	bh, bh
		mov	bl, ds:[si].endo.data.id
		mov	al, ds:[si].endo.data.pxo
		mov	ah, ds:[si].endo.data.pyo
		inc	al
		call	es:[di].exo.methods.movewin
		pop	bx
		pop	ax
update:
		; Put the typed char from Getc in the window.
		call	ds:[si].endo.methods.putchar
		putc
		; And update
		call	es:[di].exo.methods.update
		jmp	get

done:		call	es:[di].exo.methods.destructor


;

Quit:		mov     ah, 4ch
		xor	al, al
		int     21h
;
Main		endp
;
;
;
; Insert other procedures and functions down here.
;
;
;
cseg            ends
;
;
; Allocate a reasonable amount of space for the stack (2k).
;
sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends
;
;
;
; zzzzzzseg must be the last segment that gets loaded into memory!
; WARNING! Do not insert any segments (or other code/data) after
; this segment.
;
zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
heap		db	1024 dup (?)	;Gets grabbed by Mem Mgr anyway!
zzzzzzseg	ends
		end	Main
