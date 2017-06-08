; DELETE - removes some substring from a string.
;
; On entry:
;
; DS:SI			Points at the source string.
; DX			Index into the string of the start of the substring
;			to delete.
; CX			Length of the substring to be deleted.
;
; Error conditions-
;
; If DX is greater than the length of the string, then the
; operation is aborted.
;
; If DX+CX is greater than the length of the string, DELETE only
; deletes those characters from DX through the end of the string.

DELETE		proc	near
		push	es
		push	si
		push	di
		push	ax
		push	cx
		push	dx
		pushf			;Save direction flag.
		mov	ax, ds		;Source and destination strings
		mov	es, ax		; are the same.
		mov	ah, 0
		mov	dh, ah		;Just to be safe.
		mov	ch, ah

; See if any error conditions exist.

		mov	al, [si]	;Get the string length
		cmp	dl, al		;Is the index too big?
		ja	TooBig
		mov	al, dl		;Now see if INDEX+LENGTH
		add	al, cl		;is too large
		jc	Truncate
		cmp	al, [si]
		jbe	LengthIsOK

; If the substring is too big, truncate it to fit.

Truncate:	mov	cl, [si]		;Compute maximum length
		sub	cl, dl
		inc	cl

; Compute the length of the new string.

LengthIsOK:	mov	al, [si]
		sub	al, cl
		mov	[si], al

; Okay, now delete the specified substring.

		add	si, dx		;Compute address of the substring
		mov	di, si		; to be deleted, and the address of
		add	di, cx		; the first character following it.
		cld
	rep	movsb			;Delete the string.

TooBig:		popf
		pop	dx
		pop	cx
		pop	ax
		pop	di
		pop	si
		pop	es
		ret
DELETE		endp

