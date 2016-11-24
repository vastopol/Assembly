StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; strchr- Returns the position of a single character in a string.
;
; inputs:
;
;	al- character to search for.
;	es:di- address of string.
;
; returns: 
;
;	cx- position of character in string (if present).
;	carry=0 if character found.
;	carry=1 if character is not present in string.
;
		public	sl_strchr
;
sl_strchr	proc	far
		pushf
		push	ds
		push	si
		push	ax
		cld
;
		mov	si, es		;Setup ds:si to use LODSB
		mov	ds, si
		mov	si, di
;
		mov	ah, al		;ah=char to search for.
strchrlp:	lodsb
		cmp	al, ah
		jz	FndChr
		cmp	al, 0
		jne	strchrlp
;
		xor	cx, cx
		pop	ax
		pop	si
		pop	ds
		popf
		stc
		ret
;
FndChr:		pop	ax
		mov	cx, si
		sub	cx, di
		dec	cx
		pop	si
		pop	ds
		popf
		clc
		ret
sl_strchr	endp
;
;
stdlib		ends
		end
