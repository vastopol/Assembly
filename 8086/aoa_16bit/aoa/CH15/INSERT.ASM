; INSERT- Inserts one string into another.
;
; On entry:
;
; DS:SI Points at the source string to be inserted
;
; ES:DI Points at the destination string into which the source
; string will be inserted.
;
; DX Contains the offset into the destination string where the
; source string is to be inserted.
;
;
; All registers are preserved.
;
; Error condition-
;
; If the length of the newly created string is greater than 255,
; the insert operation will not be performed and the carry flag
; will be returned set.
;
; If the index is greater than the length of the destination
; string,
; then the source string will be appended to the end of the destin- ; ation string.

INSERT		proc	near
		push	si
		push	di
		push	dx
		push	cx
		push	bx
		push	ax
		clc			;Assume no error.
		pushf
		mov	dh, 0		;Just to be safe.

; First, see if the new string will be too long.

		mov	ch, 0
		mov	ah, ch
		mov	bh, ch
		mov	al, es:[di]	;AX = length of dest string.
		mov	cl, [si]	;CX = length of source string.
		mov	bl, al		;BX = length of new string.
		add	bl, cl
		jc	TooLong		;Abort if too long.
		mov	es:[di], bl	;Update length.

; See if the index value is too large:

		cmp	dl, al
		jbe	IndexIsOK
		mov	dl, al
IndexIsOK:

; Now, make room for the string that’s about to be inserted.

		push	si		;Save for later.
		push	cx

		mov	si, di		;Point SI at the end of current
		add	si, ax		; destination string.
		add	di, bx		;Point DI at the end of new str.
		std
	rep	movsb			;Open up space for new string.

; Now, copy the source string into the space opened up.

		pop	cx
		pop	si
		add	si, cx		;Point at end of source string.
	rep	movsb
		jmp	INSERTDone 

TooLong:		popf
		stc
		pushf

INSERTDone:		popf
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	di
		pop	si
		ret
INSERT		endp
