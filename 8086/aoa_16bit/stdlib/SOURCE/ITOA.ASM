StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
; Modifications for Release 2.0:
;
; Created separate routines for malloc'd and non-malloc'd versions.  The
; malloc'd versions appear in a separate file.
;
; Added ITOA2/UTOA2 which do not preserve DI for use when building strings
; of data from various calls.
;
; 9/22/91.  Randy Hyde
;
;----------------------------------------------------------------------------
;
; ITOA-	Converts the signed integer value in AX to a string of characters.
;	ES:DI must point at an array big enough to hold the result (7 chars
;	max.).
;
; ITOA2-Does not preserve DI.  Returns with DI pointing at the zero
;	terminating byte.
;
;
;
;
		public	sl_itoa
sl_itoa		proc	far
		push	di
		call	far ptr sl_itoa2
		pop	di
		ret
sl_itoa		endp
;
		public	sl_itoa2
sl_itoa2	proc	far
		push	ax
		push	bx
		push	dx
;
; If it's negative, output the sign.
;
		cmp	ax, 0
		jge	Doit
		mov	byte ptr es:[di], '-'
		inc	di
		neg	ax
;
; Output the number:
;
DoIt:		call	puti2
		mov	byte ptr es:[di], 0
		clc				;Needed by sl_itoam
		pop	dx
		pop	bx
		pop	ax
		ret
sl_itoa2	endp
;
;
; UTOA- Converts unsigned value in AX to a string of digits and stores
;	this string starting at the location pointed at by ES:DI.  Since
;	the maximum 16-bit unsigned value is 65535, this routine may store
;	up to six bytes at ES:DI (5 digits plus a zero byte).
;
; UTOA2-Like the routine above, except this one does not preserve the DI
;	register.  It returns DI pointing at the zero byte.
;
;
		public	sl_utoa
sl_utoa		proc	far
		push	di
		call	far ptr sl_utoa2
		pop	di
		ret
sl_utoa		endp
;
		public	sl_utoa2
sl_utoa2	proc	far
		push	ax
		push	bx
		push	dx
		call	PutI2
		mov	byte ptr es:[di], 0
		clc				;Needed by sl_utoam
		pop	dx
		pop	bx
		pop	ax
		ret
sl_utoa2	endp
;
;
;
; PutI2- Recursive routine to actually print the value in AX as an integer.
;
		public	Puti2
Puti2		proc	near
		mov	bx, 10
		xor	dx, dx
		div	bx
		or	ax, ax		;See if ax=0
		jz	Done
		push	dx
		call	Puti2
		pop	dx
Done:		mov	al, dl
		or	al, '0'
		mov	es:[di], al
		inc	di
		ret
PutI2		endp
;
stdlib		ends
		end
