;
; Simple "shell" file for the exercises in Chapter 4
;
; Make a copy of this file as specified in your lab manual (lab4_1.asm).
; Make your additions to this file.
; Assemble and link your modified file using the DOS command:
;
;		ml /Zi lab4_1.asm
;
; Load this file into CodeView using the DOS command:
;
;		cv lab4_1
;
;*****************************************************************************

dseg		segment	para public 'data'

; Put your variables and arrays after this comment:


dseg		ends

;*****************************************************************************





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Main is the main program.  Program execution always begins here.
;
Main		proc
		mov	ax, dseg		;These instructions set
		mov	ds, ax			; up the ES and DS segment
		mov	es, ax			; registers.


;***************************************************************************
;
; Put your main program here.
;
;***************************************************************************





; The following instruction will halt your program *BUT ONLY FROM INSIDE
; THE CODEVIEW DEBUGGER*  Do not use this statement to halt a program
; executed from DOS.

		int	3

Main		endp

cseg            ends



; Allocate a reasonable amount of space for the stack (1k).

sseg		segment	para stack 'stack'
stk		db	1024 dup (?)
sseg		ends
		end	Main
