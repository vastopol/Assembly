; ARITH.ASM
;
; A simple recursive descent parser for arithmetic strings.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

; Grammar for simple arithmetic grammar (supports +, -, *, /):
;
; E -> FE'
; E' -> + F E' | - F E' | <empty string>
; F -> TF'
; F' -> * T F' | / T F' | <empty string>
; T -> G | (E)
; G -> H | H G
; H -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
;


InputLine	byte	128 dup (0)

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Matching functions for the grammar.
; These functions return the carry flag set if they match their
; respective item.  They return the carry flag clear if they fail.
; If they fail, they preserve di.  If they succeed, di points to
; the first character after the match.


; E -> FE'

E		proc	near
		push	di
		call	F
		jnc	E_Failed
		call	EPrime
		jnc	E_Failed
		add	sp, 2		;Success, don't restore di.
		stc
		ret

E_Failed:	pop	di
		clc
		ret
E		endp



; E' -> + F E' | - F E' | <empty string>

EPrime		proc	near
		push	di
		cmp	byte ptr es:[di], '+'
		jne	TryMinus
		inc	di
		call	F
		jnc	EP_Failed
		call	EPrime
		jnc	EP_Failed
Success:	add	sp, 2
		stc
		ret

TryMinus:	cmp	byte ptr es:[di], '-'
		jne	Success
		inc	di
		call	F
		jnc	EP_Failed
		call	EPrime
		jnc	EP_Failed
		add	sp, 2
		stc
		ret

EP_Failed:	pop	di
		stc
		ret
EPrime		endp



; F -> TF'

F		proc	near
		push	di
		call	T
		jnc	F_Failed
		call	FPrime
		jnc	F_Failed
		add	sp, 2		;Success, don't restore di.
		stc
		ret

F_Failed:	pop	di
		clc
		ret
F		endp




; F -> * T F' | / T F' | <empty string>

FPrime		proc	near
		push	di
		cmp	byte ptr es:[di], '*'
		jne	TryDiv
		inc	di
		call	T
		jnc	FP_Failed
		call	FPrime
		jnc	FP_Failed
Success:	add	sp, 2
		stc
		ret

TryDiv:		cmp	byte ptr es:[di], '/'
		jne	Success
		inc	di
		call	T
		jnc	FP_Failed
		call	FPrime
		jnc	FP_Failed
		add	sp, 2
		stc
		ret

FP_Failed:	pop	di
		stc
		ret
FPrime		endp


; T -> G | (E)

T		proc	near
		call	G
		jnc	TryParens
		ret

TryParens:	push	di
		cmp	byte ptr es:[di], '('
		jne	T_Failed
		inc	di
		call	E
		jnc	T_Failed
		cmp	byte ptr es:[di], ')'
		jne	T_Failed
		inc	di
		add	sp, 2
		stc
		ret

T_Failed:	pop	di
		clc
		ret
T		endp


; The following is a free-form translation of
;
; G -> H | H G
; H -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

G		proc	near
		cmp	byte ptr es:[di], '0'
		jb	G_Failed
		cmp	byte ptr es:[di], '9'
		ja	G_Failed

DigitLoop:	inc	di
		cmp	byte ptr es:[di], '0'
		jb	G_Succeeds
		cmp	byte ptr es:[di], '9'
		jbe	DigitLoop
G_Succeeds:	stc
		ret

G_Failed:	clc
		ret
G		endp


Main		proc
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax

		printf
		byte	"Enter an arithmetic expression: ",0
		lesi	InputLine
		gets
		call	E
		jnc	BadExp

; Good so far, but are we at the end of the string?

		cmp	byte ptr es:[di], 0
		jne	BadExp

; Okay, it truly is a good expression at this point.

		printf
		byte  	"'%s' is a valid expression",cr,lf,0
		dword	InputLine
		jmp	Quit

BadExp:		printf
		byte	"'%s' is an invalid arithmetic expression",cr,lf,0
		dword	InputLine

Quit:		ExitPgm
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
