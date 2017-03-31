; Type coercion


		.386
		option	segment:use16

dseg		segment	para public 'data'


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


		mov	al, BVar
		mov	al, byte ptr WVar
		mov	al, byte ptr DWVar

		mov	ax, word ptr BVar
		mov	ax, WVar
		mov	ax, word ptr DWVar

		mov	eax, dword ptr BVar
		mov	eax, dword ptr WVar
		mov	eax, DWVar

; Note: Whenever you load a constant into an
; untyped memory location (i.e., memory
; indirect) you must specify an explicit
; type as follows:

; Erroneous->	mov	[bx], ' '

		mov	byte ptr [bx], 0
		mov	word ptr [bx], 0
		mov	dword ptr [bx], 0

Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
