StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far
;
;
;
; HTOA- Converts value in AL to a string of length two containing two
;	hexadecimal characters.  Stores result into string at address
;	ES:DI.
;
; HTOA2-Just like HTOA except it does not preserve DI.
;
		public	sl_htoa
sl_htoa		proc	far
		push	di
		call	far ptr sl_htoa2
		pop	di
		ret
sl_htoa		endp
;
;
		public	sl_htoa2
sl_htoa2	proc	far
		push	ax
		call	hextoa
		mov	byte ptr es:[di], 0
		clc				;Needed by sl_htoam
		pop	ax
		ret
sl_htoa2	endp
;
;
; WTOA- Converts the binary value in AX to a string of four hexadecimal
;	characters.
;
; WTOA2-Like the above, except it does not preserve DI.
;
		public	sl_wtoa
sl_wtoa		proc	far
		push	di
		call	far ptr sl_wtoa2
		pop	di
		ret
sl_wtoa		endp
;
		public	sl_wtoa2
sl_wtoa2	proc	far
		push	ax
		xchg	al, ah
		call	hextoa
		xchg	al, ah
		call	hextoa
		mov	byte ptr es:[di], 0
		clc				;Needed by sl_wtoam
		pop	ax
		ret
sl_wtoa2	endp
;
;
;
hextoa		proc	near
		push	ax
		mov	ah, al
		shr	al, 1
		shr	al, 1
		shr	al, 1
		shr	al, 1
		add	al, 90h
		daa
		adc	al, 40h
		daa
		mov	es:[di], al
		inc	di
		mov	al, ah
		and	al, 0fh
		add	al, 90h
		daa
		adc	al, 40h
		daa
		mov	es:[di], al
		inc	di
		pop	ax
		ret
hextoa		endp
;
stdlib		ends
		end
