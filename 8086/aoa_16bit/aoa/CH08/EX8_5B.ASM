; Ex8_5b.asm
;
; PrintVowels Module

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

; The following include directive brings in the
; EXTERNDEF directive for the PrintVowels routine
; so that this name will be global:

		include		Ex8_5.a


cseg		segment	para public 'code'



; PrintVowels-	On entry ES:DI points at a string
;		of characters.  This routine steps
;		through the string and prints each
;		character which is a vowel.
;
;		Note that the type of this procedure
;		(near or far) must exactly match
;		the type given in the EXTERNDEF
;		directive in the Lab8_10.a include
;		file.

PrintVowels	proc	near
		push	es	;Must preserve these
		push	di	; registers!
		push	ax

PVLoop:		mov	al, es:[di]	;Get next char
		cmp	al, 0		;End of str?
		jne	ProcessChar
		pop	ax
		pop	di
		pop	es
		ret


; The following four statements demonstrate how to use
; the FORC macro to generate a sequence of CMP instrs
; which varies depending on the number of characters
; in the second parameter.

ProcessChar:
		forc	char, <AaEeIiOoUuWwYy>
		cmp	al, '&char'
		je	IsAVowel
		endm

; If we get down here, the current character in AL is
; *not* a vowel

		inc	di	;Move on to next char
		jmp	PVLoop

; If we get down here, the character in AL is a
; vowel so print it to the display.

		.nolistmacro
IsAVowel:	putc
		inc	di	;Move on to next char
		jmp	PVLoop
PrintVowels	endp
cseg		ends


; Note that there is generally only one set of SSEG and
; ZZZZZZSEG segments in an entire project.  They should
; not appear in modules which do not contain your main
; program.

		end
