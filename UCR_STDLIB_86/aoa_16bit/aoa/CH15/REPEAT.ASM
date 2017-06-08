; REPEAT-		Constructs a string of length CX where each element 
;			is initialized to the character passed in AL.
;
; On entry:
;
; ES:DI-		Points at the string to be constructed.
; CX-			Contains the length of the string.
; AL-			Contains the character with which each element of 
;			the string is to be initialized.

REPEAT		proc	near
		push	di
		push	ax
		push	cx
		pushf			;Save direction flag value.
		cld
		mov	es:[di], cl	;Save string length.
		mov	ch, 0		;Just in case.
		inc	di		;Start string at next location.
	rep	stosb
		popf
		pop	cx
		pop	ax
		pop	di
		ret
REPEAT		endp
