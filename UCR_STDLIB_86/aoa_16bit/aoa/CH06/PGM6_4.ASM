; Shift and Rotate Instructions

		.386			;So we can use extended registers
		option	segment:use16	; and addressing modes.

dseg		segment	para public 'data'

; The following structure holds the bit values for an 80x86 mod-reg-r/m byte.

mode		struct
modbits		byte	?
reg		byte	?
rm		byte	?
mode		ends

Adrs1		mode	{11b, 100b, 111b}
modregrm	byte	?

var1		word	1
var2		word	8000h
var3		word	0FFFFh
var4		word	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Shifts and rotates directly on memory locations:
;
; var1 := var1 shl 1

		shl	var1, 1

; var1 := var1 shr 1

		shr	var1, 1

; On 80286 and later processors, you can shift by more than one bit at
; at time:

		shl	var1, 4
		shr	var1, 4

; The arithmetic shift right instruction retains the H.O. bit after each
; shift.  The following SAR instruction sets var2 to 0FFFFh

		sar	var2, 15

; On all processors, you can specify a shift count in the CL register.
; The following instruction restores var2 to 8000h:

		mov	cl, 15
		shl	var2, cl

; You can use the shift and rotate instructions, along with the logical
; instructions, to pack and unpack data.  For example, the following
; instruction sequence extracts bits 10..13 of var3 and leaves
; this value in var4:

		mov	ax, var3
		shr	ax, 10		;Move bits 10..13 to 0..3.
		and	ax, 0Fh		;Keep only bits 0..3.
		mov	var4, ax

; You can use the rotate instructions to compute this value somewhat faster
; on older processors like the 80286.

		mov	ax, var3
		rol	ax, 6		;Six rotates rather than 10 shifts.
		and	ax, 0Fh
		mov	var4, ax

; You can use the shift and OR instructions to easily merge separate fields
; into a single value.  For example, the following code merges the mod, reg,
; and r/m fields (maintained in separate bytes) into a single mod-reg-r/m
; byte:


		mov	al, Adrs1.modbits
		shl	al, 3
		or	al, Adrs1.reg
		shl	al, 3
		or	al, Adrs1.rm
		mov     modregrm, al

; If you've only got and 8086 or 8088 chip, you'd have to use code like the
; following:

		mov	al, Adrs1.modbits	;Get mod field
		shl	al, 1
		shl	al, 1
		or	al, Adrs1.reg		;Get reg field
		mov	cl, 3
		shl	al, cl			;Make room for r/m field.
		or	al, Adrs1.rm		;Merge in r/m field.
		mov	modregrm, al		;Save result away.

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
