; Symbol Types.
; Note: This code will generate errors when you
; attempt to assemble it.


		.386
		option	segment:use16

dseg		segment	para public 'data'

SmallConst	equ	255
LargerConst	equ	0FFFFh
BigConst	equ	123456789

BVar		byte	?
WVar		word	?
DWVar		dword	?
RVar		real4	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Attempt to move a large constant into a byte
; memory location or a byte-sized register:

		mov	BVar, LargerConst
		mov	BVar, BigConst

		mov	al, LargerConst
		mov	al, BigConst

; Ditto for word variables and registers:

		mov	WVar, BigConst
		mov	ax, BigConst


; However, it is perfectly reasonable to load
; word and dword variabless and registers with
; smaller constants

		mov	WVar, SmallConst
		mov	DWVar, SmallConst
		mov	DWVar, LargerConst

		mov	ax, SmallConst
		mov	eax, SmallConst
		mov	eax, LargerConst


; Most instructions' operands must be the same size
; or MASM will generate an error:

		mov	al, BVar	;Okay
		mov	al, WVar	;Error
		mov	al, DWVar	;Error

		mov	ax, BVar	;Error
		mov	ax, WVar	;Okay
		mov	ax, DWVar	;Error

		mov	eax, BVar	;Error
		mov	eax, WVar	;Error
		mov	eax, DWVar	;Okay

Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
