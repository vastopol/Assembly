; Concat-		Copies the string pointed at by SI to the string 
; 			rointed at by DI and then concatenates the string;
;			pointed at by BX to the destination string.
;
; On entry-
;
; DS:SI-		Points at the first source string
; DS:BX-		Points at the second source string
; ES:DI-		Points at the destination string.
;
; Error condition-
;
; The sum of the lengths of the two strings is greater than 255.
; In this event, the second string will be truncated so that the
; entire string is less than 256 characters in length.

CONCAT		proc	near
		push	si
		push	di
		push	cx
		push	ax
		pushf

; Copy the first string to the destination string:

		mov	al, [si]
		mov	cl, al
		mov	ch, 0
		mov	ah, ch
		add	al, [bx]	;Compute the sum of the string’s
		adc	ah, 0		; lengths.
		cmp	ax, 256
		jb	SetNewLength
		mov	ah, [si]	;Save original string length.
		mov	al, 255		;Fix string length at 255.
SetNewLength:	mov	es:[di], al	;Save new string length.
		inc	di		;Skip over length bytes.
		inc	si
	rep	movsb			;Copy source1 to dest string.

; If the sum of the two strings is too long, the second string
; must be truncated.

		mov	cl, [bx]	;Get length of second string.
		cmp	ax, 256
		jb	LengthsAreOK
		mov	cl, ah		;Compute truncated length.
		neg	cl		;CL := 256-Length(Str1).

LengthsAreOK:	lea	si, 1[bx]	;Point at second string and
;					; skip the string length.
		cld
		rep	movsb		;Perform the concatenation.

		popf
		pop	ax
		pop	cx
		pop	di
		pop	si
		ret
CONCAT		endp
