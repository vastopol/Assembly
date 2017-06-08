		.286		;For PUSH imm instr.
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; Some "cute" equates:

Iterator	textequ	<proc>
endi		textequ	<endp>
wp		textequ	<word ptr>


; Yield is a macro which emits the necessary code for the YIELD operation.

Yield		macro
		mov	dx, [bp+2]		;Place to yield back to.
		push	bp			;Save Iterator link
		mov	bp, [bp]		;Get ptr to caller's A.R.
		call	dx			;Push resume address and rtn.
		pop	bp			;Restore ptr to our A. R.
		endm

; Necessary global variables:

dseg		segment	para public 'data'

; As per UCR StdLib instructions, InputStr must hold
; at least 128 characters.

InputStr	byte	128 dup (?)

; Note that the following statement initializes the
; VowelCnt array to zeros, saving us from having to
; do this in the main program.

VowelCnt	word	256 dup (0)

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; GetVowel- 	This iterator searches for the next vowel in the
;		input string and returns the index to the value
;		as the iterator result.	On entry, ES:DI points
;		at the string to process.  On yield, AX returns
;		the zero-based index into the string of the
;		current vowel.
;
; GVYield-	Address to call when performing the yield.
; GVStrPtr-	A local variable which points at our string.

GVYield		textequ	<word ptr [bp+2]>
GVStrPtr	textequ	<dword ptr [bp-4]>

GetVowel	Iterator
		push	bp
		mov	bp, sp

; Create and initialize GVStrPtr.  This is a pointer to the
; next character to process in the input string.

		push	es
		push	di

; Save original ES:DI values so we can restore them on YIELD
; and on termination.

		push	es
		push	di

; Okay, here's the main body of the iterator.  Fetch each
; character until the end of the string and see if it is
; a vowel.  If it is a vowel, yield the index to it.  If
; it is not a vowel, move on to the next character.

GVLoop:		les	di, GVStrPtr	;Ptr to next char.
		mov	al, es:[di]	;Get this character.
		cmp	al, 0		;End of string?
		je	GVDone

; The following statement will convert all lower case
; characters to upper case.  It will also translate other
; characters to who knows what, but we don't care since
; we only look at A, E, I, O, U, W, and Y.

		and	al, 5fh

; See if this character is a vowel.  This is a disgusting
; set membership operation.  See Chapter Ten to learn how
; to do it right.

		cmp	al, 'A'
		je	IsAVowel
		cmp	al, 'E'
		je	IsAVowel
		cmp	al, 'I'
		je	IsAVowel
		cmp	al, 'O'
		je	IsAVowel
		cmp	al, 'U'
		je	IsAVowel
		cmp	al, 'W'
		je	IsAVowel
		cmp	al, 'Y'
		jne	NotAVowel

; If we've got a vowel we need to yield the index into
; the string to that vowel.  To compute the index, we
; restore the original ES:DI values (which pointer at
; the beginning of the string) and subtract the current
; position (now in AX) from the first position.  This
; produces a zero-based index into the string.
; This code must also increment the corresponding entry
; in the VowelCnt array so we can print the results
; later.  Unlike the Pascal code, we've converted lower
; case to upper case so the count for upper and lower
; case characters will appear in the upper case slot.

IsAVowel:       push	bx		;Bump the vowel
		mov	ah, 0		; count by one.
		mov	bx, ax
		shl	bx, 1
		inc	VowelCnt[bx]
		pop	bx

		mov	ax, di
		pop	di		;Restore original DI
		sub	ax, di		;Compute index.
		pop	es		;Restore original ES

		yield

		push	es		;Save ES:DI again
		push	di

; Whether it was a vowel or not, we've now got to move
; on to the next character in the string.  Increment
; our string pointer by one and repeat the process
; over again.

NotAVowel:	inc	wp GVStrPtr
		jmp     GVLoop

; If we've reached the end of the string, terminate
; the iterator here.  We need to restore the original
; ES:DI values, remove local variables, pop the YIELD
; address, and then return to the termination address.

GVDone:		pop	di		;Restore ES:DI
		pop	es
		mov	sp, bp		;Remove locals
		add	sp, 4		;Pop YIELD/S.L.
		pop	bp
		ret
GetVowel	endi



Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		print
		byte	"Enter a string: ",0
		lesi	InputStr
		gets			;Read input line.

; The following is the foreach loop.  Note that the label
; "FOREACH" is present for documentation purpose only.
; In fact, the foreach loop always begins with the first
; instruction after the call to GetVowel.
;
; One other note: this assembly language code uses
; zero-based indexes for the string.  The Pascal version
; uses one-based indexes for strings.  So the actual
; numbers printed will be different.  If you want the
; values printed by both programs to be identical,
; uncomment the INC instruction below.

		push	offset ForDone	;Termination address.
		push	bp		;Static link.
		call	GetVowel	;Start iterator
FOREACH:	mov	bx, ax
		print
		byte	"Vowel ",0
		mov	al, InputStr[bx]
		putc
		print
		byte	" at position ",0
		mov	ax, bx
;		inc	ax
		puti
		putcr
		ret			;Iterator resume.

ForDone:	printf
		byte	"# of A's: %d\n"
		byte	"# of E's: %d\n"
		byte	"# of I's: %d\n"
		byte	"# of O's: %d\n"
		byte	"# of U's: %d\n"
		byte	"# of W's: %d\n"
		byte	"# of Y's: %d\n",0
		dword	VowelCnt + ('A'*2)
		dword	VowelCnt + ('E'*2)
		dword	VowelCnt + ('I'*2)
		dword	VowelCnt + ('O'*2)
		dword	VowelCnt + ('U'*2)
		dword	VowelCnt + ('W'*2)
		dword	VowelCnt + ('Y'*2)


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
