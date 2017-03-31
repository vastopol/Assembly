; Symbol Types II.
; Demonstration of different symbol types
; in a program.

		.386
		option	segment:use16

SampleMacro	macro
		nop
		endm

dseg		segment	para public 'data'

Constant	equ	0
Constant2	=	1
TextConst	textequ	<[bp+5]>
StrConst	equ	"Hello there"


BVar		byte	?
BArray		byte	31 dup (?)

WVar		word	?
WArray		word	31 dup (?)

DWVar		dword	?
DWArray		dword	31 dup (?)

RVar		real8	?
RArray		real8	31 dup (?)

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

FarProc		proc	far
		ret
FarProc		endp

NearProc	proc	near
		ret
NearProc	endp

Main		proc	near
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Note that "Quit" is a near statement label:

Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
