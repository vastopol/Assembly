; GETARRAY.ASM
;
; This module contains the GetArray input routine.  This routine reads a
; set of values for a row of some array.

		.386
		option	segment:use16

		.nolist
		include	stdlib.a
		.list

		include	matrix.a



; Some local variables for this module:

localdseg	segment	para public 'LclData'

NumElements	word	?
ArrayPtr	dword	?

Localdseg	ends




InpSeg		segment	para public 'input'
		assume	ds:Localdseg

; GetArray-	Read a set of numbers and store them into an array.
;
;		On Entry:
;
;			es:di points at the base address of the array.
;			ax contains the number of elements in the array.
;
;		This routine reads the specified number of array elements
;		from the user and stores them into the array.  If there
;		is an input error of some sort, then this routine makes
;		the user reenter the data.

GetArray	proc	far
		pusha				;Preserve all the registers
		push	ds			; that this code modifies
		push	es
		push	fs

		ifdef	debug
		print
		char	"Inside GetArray, # of input values =",0
		puti
		putcr
		endif

		mov	cx, Localdseg		;Point ds at our local
		mov	ds, cx			; data segment.

		mov	wp ArrayPtr, di		;Save in case we have an
		mov	wp ArrayPtr+2, es	; error during input.
		mov	NumElements, ax

; The following loop reads a line of text from the user containing some
; number of integer values.  This loop repeats if the user enters an illegal
; value on the input line.
;
; Note: LESI is a macro from the stdlib.a include file.  It loads ES:DI
; with the address of its operand (as opposed to les di, InputLine that would
; load ES:DI with the dword value at address InputLine).

RetryLp:	lesi	InputLine		;Read input line from user.
		gets
		mov	cx, NumElements		;# of values to read.
		lfs	si, ArrayPtr		;Store input values here.

; This inner loop reads "ax" integers from the input line.  If there is
; an error, it transfers control to RetryLp above.

ReadEachItem:	call	geti			;Read next available value.
		jc	BadGA
		mov	fs:[si], ax		;Save away in array.
		add	si, 2			;Move on to next element.
		loop	ReadEachItem		;Repeat for each element.

		pop	fs			;Restore the saved registers
		pop	es			; from the stack before
		pop	ds			; returning.
		popa
		ret

; If an error occurs, make the user re-enter the data for the entire
; row:

BadGA:		print
		char	"Illegal integer value(s).",cr,lf
		char	"Re-enter data:",0
		jmp	RetryLp
getArray	endp

InpSeg		ends
		end
