
; Need to include "lists.a" in order to get list structure definition.

		include	lists.a


wp		equ	<word ptr>		;I'm a lazy typist


; Special case to handle MASM 6.0 vs. all other assemblers:
; If not MASM 5.1 or MASM 6.0, set the version to 5.00:

		ifndef	@version
@version	equ	500
		endif



StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends

stdlib		segment	para public 'slcode'
		assume	cs:stdgrp

; sl_PeekLast -	ES:DI points at a list.
;		Returns a pointer to the last item in the list in DX:SI.
;		Returns the carry flag set if the list was empty.
;
; Randall Hyde  3/3/92
;

		public	sl_PeekLast
sl_PeekLast	proc	far

		if	@version ge 600

; MASM 6.0 version goes here

		cmp	wp es:[di].List.Tail+2, 0	;Empty list?
		jne	HasAList

; At this point, the Head pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		stc
		jmp	PeekDone

; If the Tail pointer is non-NIL, return a pointer to the last node in the
; list.

HasAList:	mov	si, wp es:[di].List.Tail  	;Get ptr to first
		mov	dx, wp es:[di].List.Tail+2	; item


		else

; All other assemblers come down here:

		cmp	wp es:[di].Tail+2, 0		;Empty list?
		jne	HasAList

; At this point, the Head pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		stc
		jmp	PeekDone

; If the Tail pointer is non-NIL, return Tail down here.

HasAList:	mov	si, wp es:[di].Tail	  	;Get ptr to first
		mov	dx, wp es:[di].Tail+2		; item


		endif

		clc
PeekDone:	ret

sl_PeekLast	endp

stdlib		ends
		end
