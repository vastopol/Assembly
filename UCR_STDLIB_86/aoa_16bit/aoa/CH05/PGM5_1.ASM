; Sample variable declarations
; This sample file demonstrates how to declare and access some simple
; variables in an assembly language program.
;
; Randall Hyde
;
;
; Note: global variable declarations should go in the "dseg" segment:

dseg		segment	para public 'data'

; Some simple variable declarations:

character	byte	?		;"?" means uninitialized.
UnsignedIntVar	word	?
DblUnsignedVar	dword	?

;You can use the typedef statement to declare more meaningful type names:

integer		typedef	sword
char		typedef	byte
FarPtr		typedef	dword

; Sample variable declarations using the above types:

J		integer	?
c1		char	?
PtrVar		FarPtr	?


; You can tell MASM & DOS to initialize a variable when DOS loads the
; program into memory by specifying the initial value in the operand
; field of the variable's declaration:

K		integer	4
c2		char	'A'
PtrVar2		FarPtr	L		;Initializes PtrVar2 with the
					; address of L.


; You can also set aside more than one byte, word, or double word of
; storage using these directives.  If you place several values in the
; operand field, separated by commas, the assembler will emit one byte,
; word, or dword for each operand:

L		integer	0, 1, 2, 3
c3		char	'A', 0dh, 0ah, 0
PtrTbl		FarPtr	J, K, L

; The BYTE directive lets you specify a string of characters byte enclosing
; the string in quotes or apostrophes.  The directive emits one byte of data
; for every character in the string (not including the quotes or apostrophes
; that delimit the string):

string		byte	"Hello world",0dh,0ah,0


dseg		ends





; The following program demonstrates how to access each of the above
; variables.

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.


; Some simple instructions that demonstrate how to access memory:

		lea	bx, L		;Point bx at first word in L.
		mov	ax, [bx]	;Fetch word at L.
		add	ax, 2[bx]	;Add in word at L+2 (the "1").
		add	ax, 4[bx]	;Add in word at L+4 (the "2").
		add	ax, 6[bx]	;Add in word at L+6 (the "3").
		mul	K		;Compute (0+1+2+3)*123.
		mov	J, ax		;Save away result in J.

		les	bx, PtrVar2	;Loads es:di with address of L.
		mov	di, K		;Loads 4 into di
		mov	ax, es:[bx][di]	;Fetch value of L+4.


; Examples of some byte accesses:

		mov	c1, ' '		;Put a space into the c1 var.
		mov	al, c2		;c3 := c2
		mov	c3, al

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
