
MatchPre	proc	far		;Must be far!
		push	bp
		mov	bp, sp
		push	ax
		push	ds
		push	si
		push	di

		lds	si, 2[bp]	;Get the return address.
CmpLoop:	mov	al, ds:[si]	;Get string to match.
		cmp	al, 0		;If at end of prefix,
		je	Success		; we succeed.
		cmp	al, es:[di]	;See if it matches prefix,
		jne	Failure		; if not, immediately fail.
		inc	si
		inc	di
		jmp	CmpLoop

Success:	add	sp, 2		;Don't restore di.
		inc	si		;Skip zero terminating byte.
		mov	2[bp], si	;Save as return address.
		pop	si
		pop	ds
		pop	ax
		pop	bp
		stc			;Return success.
		ret

Failure:        inc	si		;Need to skip to zero byte.
		cmp	byte ptr ds:[si], 0
		jne	Failure
		inc	si
		pop	di
		mov	2[bp], si	;Save as return address.
		pop	si
		pop	ds
		pop	ax
		pop	bp
		clc			;Return failure.
		ret
MatchPre	endp
		end
