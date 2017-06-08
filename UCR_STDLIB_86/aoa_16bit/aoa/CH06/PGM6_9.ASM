; Conditional JMP Instructions, Part I

		.386
		option	segment:use16
dseg		segment	para public 'data'
J		sword	?
K		sword	?
L		sword	?
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; 8086 conditional jumps are limited to
; +/- 128 bytes because they are only
; two bytes long (one byte opcode, one
; byte displacement).

		.8086
		ja	lbl
		nop
lbl:

; MASM 6.x will automatically extend out of
; range jumps.  The following are both
; equivalent:

		ja	lbl2
		byte	150 dup (0)
lbl2:
		jna	Temp
		jmp	lbl3
Temp:
		byte	150 dup (0)
lbl3:


; The 80386 and later processors support a
; special form of the conditional jump
; instructions that allow a two-byte displace-
; ment, so MASM 6.x will assemble the code
; to use this form if you've specified an
; 80386 processor.

		.386
		ja	lbl4
		byte	150 dup (0)
lbl4:

; The conditional jump instructions work
; well with the CMP instruction to let you
; execute certain instruction sequences
; only if a condition is true or false.
;
; if (J <= K) then
;	L := L + 1
; else  L := L - 1

		mov	ax, J
		cmp	ax, K
		jnle	DoElse
		inc	L
		jmp	ifDone

DoElse:		dec	L
ifDone:

; You can also use a conditional jump to
; create a loop in an assembly language
; program:
;
; while (j >= k) do begin
;
;	j := j - 1;
;	k := k + 1;
;	L := j * k;
; end;

WhlLoop:	mov	ax, j
		cmp	ax, k
		jnge	QuitLoop

		dec	j
		inc	k
		mov	ax, j
		imul	ax, k
		mov	L, ax
		jmp	WhlLoop

QuitLoop:

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
