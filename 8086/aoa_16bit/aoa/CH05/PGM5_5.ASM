; Sample Structure Definitions and Accesses.
;
; Randall Hyde


dseg		segment	para public 'data'


; The following structure holds the bit values for an 80x86 mod-reg-r/m byte.

mode		struct
modbits		byte	?
reg		byte	?
rm		byte	?
mode		ends


Instr1Adrs	mode	{}	;All fields uninitialized.
Instr2Adrs	mode	{}


; Some structures with initialized fields.

axbx		mode	{11b, 000b, 000b}	;"ax, ax" adrs mode.
axdisp		mode	{00b, 000b, 110b}	;"ax, disp" adrs mode.
cxdispbxsi	mode	{01b, 001b, 000b}	;"cx, disp8[bx][si]" mode.


; Near pointers to some structures:

sPtr1		word	axdisp
sPtr2		word	Instr2Adrs

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.


; To access fields of a structure variable directly, just use the "."
; operator like you would in Pascal or C:

		mov	al, axbx.modbits
		mov	Instr1Adrs.modbits, al

		mov	al, axbx.reg
		mov	Instr1Adrs.reg, al

		mov	al, axbx.rm
		mov	Instr1Adrs.rm, al


; When accessing elements of a structure indirectly (that is, using a
; pointer) you must specify the structure type name as the first
; "field" so MASM doesn't get confused:

		mov	si, sPtr1
		mov	di, sPtr2

		mov	al, ds:[si].mode.modbits
		mov	ds:[di].mode.modbits, al

		mov	al, ds:[si].mode.reg
		mov	ds:[di].mode.reg, al

		mov	al, ds:[si].mode.rm
		mov	ds:[di].mode.rm, al


Quit:		mov	ah, 4ch		;Magic number for DOS
		int	21h		; to tell this program to quit.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
