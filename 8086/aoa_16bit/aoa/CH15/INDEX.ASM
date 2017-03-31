; INDEX- computes the offset of one string within another.
;
; On entry:
;
; ES:DI-			Points at the test string that INDEX will search for
;			in the source string.
; DS:SI-			Points at the source string which (presumably) 
;			 contains the string INDEX is searching for.
;
; On exit:
;
; AX-			Contains the offset into the source string where the 
; 			test string was found.

INDEX		proc	near
		push	si
		push	di
		push	bx
		push	cx
		pushf			;Save direction flag value.
		cld 

		mov	al, es:[di]	;Get the length of the test string.
		cmp	al, [si]	;See if it is longer than the length
		ja	NotThere	; of the source string.

; Compute the index of the last character we need to compare the
; test string against in the source string.

		mov	al, es:[di]	;Length of test string.
		mov	cl, al		;Save for later.
		mov	ch, 0
		sub	al, [si]	;Length of source string.
		mov	bl, al		;# of times to repeat loop.
		inc	di		;Skip over length byte.
		xor	ax, ax		;Init index to zero.
CmpLoop:	inc	ax		;Bump index by one.
		inc	si		;Move on to the next char in source.
		push	si		;Save string pointers and the
		push	di		; length of the test string.
		push	cx
	rep	cmpsb			;Compare the strings.
		pop	cx		;Restore string pointers
		pop	di		; and length.
		pop	si
		je	Foundindex	;If we found the substring.
		dec	bl
		jnz	CmpLoop		;Try next entry in source string.

; If we fall down here, the test string doesn’t appear inside the
; source string.

NotThere:	xor	ax, ax		;Return INDEX = 0

; If the substring was found in the loop above, remove the
; garbage left on the stack

FoundIndex:		popf
		pop	cx
		pop	bx
		pop	di
		pop	si
		ret
INDEX		endp
