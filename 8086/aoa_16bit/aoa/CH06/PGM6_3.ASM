; Logical Operations
; This program demonstrates the AND, OR, XOR, and NOT instructions

		.386			;So we can use extended registers
		option	segment:use16	; and addressing modes.

dseg		segment	para public 'data'


; Some variables we can use:

j		word	0FF00h
k		word	0FFF0h
l		word	?

c1		byte	'A'
c2		byte	'a'

LowerMask	byte	20h

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Compute L := J and K (bitwise AND operation):

		mov	ax, J
		and	ax, K
		mov	L, ax

; Compute L := J or K (bitwise OR operation):

		mov	ax, J
		or	ax, K
		mov	L, ax

; Compute L := J xor K (bitwise XOR operation):

		mov	ax, J
		xor	ax, K
		mov	L, ax

; Compute L := not L (bitwise NOT operation):

		not	L

; Compute L := not J (bitwise NOT operation):

		mov	ax, J
		not	ax
		mov	L, ax

; Clear bits 0..3 in J:

		and	J, 0FFF0h

; Set bits 0..3 in K:

		or	K, 0Fh

; Invert bits 4..11 in L:

		xor	L, 0FF0h

; Convert the character in C1 to lower case:

		mov	al, c1
		or	al, LowerMask
		mov	c1, al

; Convert the character in C2 to upper case:

		mov	al, c2
		and	al, 5Fh		;Clears bit 5.
		mov	c2, al



Quit:		mov	ah, 4ch			;DOS opcode to quit program.
		int	21h			;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
