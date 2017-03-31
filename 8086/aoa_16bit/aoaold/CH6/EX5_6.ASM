; More Equates.


CharEqu		equ	'a'
StrEqu		equ	'Hello World'
FloatEqu	equ	3.14159
Text		textequ	<ax, 0>
MOVE		textequ	<mov>


dseg		segment	para public 'data'

CharVar		byte	CharEqu
StrVar		byte	StrEqu, 0
FloatVar	real8	FloatEqu

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax


		MOVE	Text

Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
