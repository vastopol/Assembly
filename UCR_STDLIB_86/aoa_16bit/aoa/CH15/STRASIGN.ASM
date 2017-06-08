; StrAssign.asm
;
; Demonstration of a string assignment routine.

		include		stdlib.a
		includelib	stdlib.lib

cseg		segment	para public ‘code’
		assume	cs:cseg, ds:dseg, es:dseg, ss:sseg

; String assignment procedure

MainPgm		proc	far
		mov	ax, seg dseg
		mov	ds, ax
		mov	es, ax

		lea	di, ToString
		call	StrAssign
		byte	“This is an example of how the “ 
		byte	“StrAssign routine is used”,0
		nop
		ExitPgm
MainPgm		endp

StrAssign	proc	near
		push	bp
		mov	bp, sp
		pushf
		push	ds
		push	si
		push	di
		push	cx
		push	ax
		push	di		;Save again for use later.
		push	es
		cld

; Get the address of the source string

		mov	ax, cs
		mov	es, ax
		mov	di, 2[bp]	;Get return address.
		mov	cx, 0ffffh	;Scan for as long as it takes.
		mov	al, 0		;Scan for a zero.
	repne	scasb			;Compute the length of string.
		neg	cx		;Convert length to a positive #.
		dec	cx		;Because we started with -1, not 0.
		dec	cx		;skip zero terminating byte.

; Now copy the strings

		pop	es		;Get destination segment.
		pop	di		;Get destination address.
		mov	al, cl		;Store length byte.
		stosb

; Now copy the source string.

		mov	ax, cs
		mov	ds, ax
		mov	si, 2[bp]
	rep	movsb

; Update the return address and leave:

		inc	si		;Skip over zero byte.
		mov	2[bp], si

		pop	ax
		pop	cx
		pop	di
		pop	si
		pop	ds
		popf
		pop	bp
		ret
StrAssign	endp

cseg		ends

dseg		segment para public ‘data’
ToString	byte	255 dup (0)
dseg		ends

sseg		segment para stack ‘stack’
		word	256 dup (?)
sseg		ends
		end	MainPgm

