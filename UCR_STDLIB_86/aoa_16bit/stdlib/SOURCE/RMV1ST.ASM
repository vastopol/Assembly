
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

; sl_Remove1st -	ES:DI points at a list.
;			Removes the first item in the list and returns a
;			pointer to this item in DX:SI.  Returns the carry
;			flag set if the list was empty.
;
; Randall Hyde  3/3/92
;

		public	sl_Remove1st
sl_Remove1st	proc	far
		push	ds
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

		cmp	wp es:[di].List.Head+2, 0	;Empty list?
		jne	HasAList

; At this point, the Head pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		mov	wp es:[di].List.CurrentNode, dx	;Set current node to
		mov	wp es:[di].List.CurrentNode+2, dx  ; NIL.
		stc
		jmp	RemoveDone

; If the HEAD pointer is NON-NIL, grab the guy off the front of the
; list down here.

HasAList:	mov	si, wp es:[di].List.Head  	;Get ptr to first
		mov	ds, wp es:[di].List.Head+2	; item

; Remove the first node from the list by storing the first node's NEXT pointer
; into the list's HEAD pointer.  Check to see if the list becomes empty
; (because we'll need to adjust TAIL when that happens).

		mov	dx, wp ds:[si].Node.Next
		mov	wp es:[di].List.Head, dx
		mov	wp es:[di].List.CurrentNode, dx

		mov	dx, wp ds:[si].Node.Next+2
		mov	wp es:[di].List.Head+2, dx
		mov	wp es:[di].List.CurrentNode+2, dx

		or	dx, dx				;List empty?
		jnz     GoodRemove
		mov	wp es:[di].List.Tail, dx
		mov	wp es:[di].List.Tail+2, dx






		else

; All other assemblers come down here:

		cmp	wp es:[di].Head+2, 0		;Empty list?
		jne	HasAList

; At this point, the Head pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		mov	wp es:[di].CurrentNode, dx
		mov	wp es:[di].CurrentNode+2, dx
		stc
		jmp	RemoveDone

; If the Tail pointer is non-NIL, append the new node to the end of the
; list down here.

HasAList:	mov	si, wp es:[di].Head	  	;Get ptr to first
		mov	ds, wp es:[di].Head+2		; item

; Remove the first node from the list by storing the first node's NEXT pointer
; into the list's HEAD pointer.  Check to see if the list becomes empty
; (because we'll need to adjust TAIL with that happens).

		mov	dx, wp ds:[si].Next
		mov	wp es:[di].Head, dx
		mov	wp es:[di].CurrentNode, dx

		mov	dx, wp ds:[si].Next+2
		mov	wp es:[di].Head+2, dx
		mov	wp es:[di].CurrentNode, dx

		or	dx, dx				;List empty?
		jnz     GoodRemove
		mov	wp es:[di].Tail, dx
		mov	wp es:[di].Tail+2, dx


		endif

GoodRemove:	clc
		mov	dx, ds

RemoveDone:	pop	di
		pop	es
		pop	ds
		ret

sl_Remove1st	endp

stdlib		ends
		end
