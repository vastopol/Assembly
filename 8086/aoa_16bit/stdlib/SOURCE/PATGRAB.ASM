		include	pattern.a

StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
ZeroByte	db	0
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp

		extrn	sl_malloc:far

		ifndef	@version
@version	equ	500
		endif

; sl_grab-	ES:DI points at a pattern structure on entry.  This guy
;		allocates storage for the string matched by that pattern
;		copies that string onto the heap.  This routine returns
;		a pointer to this new string on the heap in ES:DI.  Returns
;		with the carry flag set if there was a memory allocation
;		error, returns with the carry flag clear if no error occurs.

		if	@version ge 600

		public	sl_grab
sl_grab		proc	far
		pushf
		push	cx
		push	ds
		push	si
		cld

		mov	si, es
		mov	ds, si
		mov	si, di
		mov	cx, [si].Pattern.EndPattern
		sub	cx, [si].Pattern.StartPattern
		jz	NoString
		inc	cx			;Make room for zero byte.
		push	cx
		call	sl_malloc
		jc	BadGrab

		pop	cx
		push	es
		push	di
		lds	si, dword ptr [si].Pattern.StartPattern
	rep	movsb
		mov	byte ptr es:[di-1], 0	;Output zero byte.

		pop	di
		pop	es
		pop	si
		pop	ds
		pop	cx
		popf
		clc
		ret

NoString:       mov	di, seg ZeroByte
		mov	es, di
		mov	di, offset ZeroByte	;Return ptr to empty string.
		pop	si
		pop	ds
		pop	cx
		popf
		clc
		ret

BadGrab:	pop	cx
		pop	si
		pop	ds
		pop	cx
		popf
		stc
		ret
sl_grab		endp

		else			;If MASM 5.1 or TASM

		public	sl_grab
sl_grab		proc	far
		pushf
		push	cx
		push	ds
		push	si
		cld

		mov	si, es
		mov	ds, si
		mov	si, di
		mov	cx, [si].EndPattern
		sub	cx, [si].StartPattern
		jz	NoString
		inc	cx			;Make room for zero byte.
		push	cx
		call	sl_malloc
		jc	BadGrab

		pop	cx
		push	es
		push	di
		lds	si, dword ptr [si].StartPattern
	rep	movsb
		mov	byte ptr es:[di-1], 0	;Output zero byte.

		pop	di
		pop	es
		pop	si
		pop	ds
		pop	cx
		popf
		clc
		ret

NoString:       mov	di, seg ZeroByte
		mov	es, di
		mov	di, offset ZeroByte	;Return ptr to empty string.
		pop	si
		pop	ds
		pop	cx
		popf
		clc
		ret

BadGrab:	pop	cx
		pop	si
		pop	ds
		pop	cx
		popf
		stc
		ret
sl_grab		endp


		endif

stdlib		ends
		end
