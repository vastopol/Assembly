; Substring function.
;
; HLL form:
;
;procedure substring(var Src:string;
; 			Index, Length:integer;
; 			var Dest:string);
;
; Src- Address of a source string.
; Index- Index into the source string.
; Length- Length of the substring to extract.
; Dest- Address of a destination string.
;
; Copies the source string from address [Src+index] of length
; Length to the destination string.
;
; If an error occurs, the carry flag is returned set, otherwise
; clear.
;
; Parameters are passed as follows:
;
; DS:SI- Source string address.
; ES:DI- Destination string address.
; CH- Index into source string.
; CL- Length of source string.
;
; Note: the strings pointed at by the SI and DI registers are
; length-prefixed strings. That is, the first byte of each 
; string contains the length of that string.

Substring	proc	near
		push	ax
		push	cx
		push	di
		push	si
		clc			;Assume no error.
		pushf			;Save direction flag status.

; Check the validity of the parameters.	

		cmp	ch, [si]	;Is index beyond the length of
		ja	ReturnEmpty	; the source string?
		mov	al, ch		;See if the sum of index and
		dec	al		; length is beyond the end of the
		add	al, cl		; string.
		jc	TooLong		;Error if > 255.
		cmp	al, [si]	;Beyond the length of the source?
		jbe	OkaySoFar

; If the substring isn’t completely contained within the source 
; string, truncate it:

TooLong:	popf
		stc			;Return an error flag.
		pushf
		mov	al, [si]		;Get maximum length.
		sub	al, ch		;Subtract index value.
		inc	al		;Adjust as appropriate.
		mov	cl, al		;Save as new length.

OkaySoFar:	mov	es:[di], cl		;Save destination string length.
		inc	di
		mov	al, ch		;Get index into source.
		mov	ch, 0		;Zero extend length value into CX.
		mov	ah, 0		;Zero extend index into AX.
		add	si, ax		;Compute address of substring.
		cld
	rep	movsb			;Copy the substring.

		popf
SubStrDone:	pop	si
		pop	di
		pop	cx
		pop	ax
		ret

; Return an empty string here:

ReturnEmpty:	mov	byte ptr es:[di], 0
		popf
		stc
		jmp	SubStrDone
SubString	endp
