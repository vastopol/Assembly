; EX8_1.asm (Laboratory Exercise 8.1)


dseg		segment	para public 'data'
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



Procedure1	proc	near

; MASM will emit a *far* call to procedure2
; since it is a far procedure.

		call	Procedure2

; Since this return instruction is inside
; a near procedure, MASM will emit a near
; return.

		ret
Procedure1	endp






Procedure2	proc	far

; MASM will emit a *near* call to procedure1
; since it is a near procedure.

		call	Procedure1

; Since this return instruction is inside
; a far procedure, MASM will emit a far
; return.

		ret
Procedure2	endp






Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax


; MASM emits the appropriate call instructions
; to the following procedures.

		call	Procedure1
		call	Procedure2


Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
