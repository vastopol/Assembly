
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

; sl_PeekCur -	ES:DI points at a list.
;		Returns a pointer to the CurrentNode in the list in DX:SI.
;		Returns the carry flag set if the list was empty.
;
; Randall Hyde  3/13/92
;

		public	sl_PeekCur
sl_PeekCur	proc	far

		if	@version ge 600

; MASM 6.0 version goes here

		cmp	wp es:[di].List.CurrentNode+2, 0	;Empty list?
		jne	HasAList

; At this point, the CurrentNode pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		stc
		jmp	PeekDone

; Return a pointer to the CurrentNode:

HasAList:	mov	si, wp es:[di].List.CurrentNode	;Get ptr to first
		mov	dx, wp es:[di].List.CurrentNode+2 ; item


		else

; All other assemblers come down here:

		cmp	wp es:[di].CurrentNode+2, 0		;Empty list?
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

; Return a pointer to the first node.

HasAList:	mov	si, wp es:[di].CurrentNode  	;Get ptr to first
		mov	dx, wp es:[di].CurrentNode+2	; item


		endif

		clc
PeekDone:	ret

sl_PeekCur	endp

stdlib		ends
		end
