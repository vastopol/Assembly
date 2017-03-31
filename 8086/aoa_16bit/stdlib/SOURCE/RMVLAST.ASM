
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

; sl_RemovelAst -	ES:DI points at a list.
;			Removes the last item in the list and returns a
;			pointer to this item in DX:SI.  Returns the carry
;			flag set if the list was empty.
;
; Randall Hyde  3/3/92
;

		public	sl_RemoveLast
sl_RemoveLast	proc	far
		push	ds
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

		cmp	wp es:[di].List.Tail+2, 0	;Empty list?
		jne	HasAList

; At this point, the Tail pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		stc
		jmp	RemoveDone

; If the HEAD pointer is NON-NIL, grab the guy off the front of the
; list down here.

HasAList:	lds	si, es:[di].List.Tail  		;Get ptr to last

; Remove the last node from the list by storing the address of the next to
; last node in TAIL and setting the NEXT field of that node to NIL.
; Check to see if the list becomes empty (because we'll need to adjust HEAD
; when that happens).

		mov	dx, wp ds:[si].Node.Prev
		mov	wp es:[di].List.Tail, dx
		mov	wp es:[di].List.CurrentNode, dx

		mov	dx, wp ds:[si].Node.Prev+2
		mov	wp es:[di].List.Tail+2, dx
		mov	wp es:[di].List.CurrentNode+2, dx

		or	dx, dx				;List empty?
		jz     	LastGuy

; If the list is not empty, we need to set the NEXT field of the new
; last node to NIL.

		les	di, es:[di].List.Tail
		mov	wp es:[di].Node.Next, 0
		mov	wp es:[di].Node.Next+2, 0
		jmp	GoodRemove

; If we just removed the last node from the list, set the head pointer
; to NIL (Tail is already NIL from above).


LastGuy:	mov	wp es:[di].List.Head, dx
		mov	wp es:[di].List.Head+2, dx





		else

; Handle other assemblers down here

		cmp	wp es:[di].Tail+2, 0		;Empty list?
		jne	HasAList

; At this point, the Tail pointer is zero.  This only occurs if the
; list is empty.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		xor	dx, dx				;Set DX:SI to NIL.
		mov	si, dx
		stc
		jmp	RemoveDone

; If the HEAD pointer is NON-NIL, grab the guy off the front of the
; list down here.

HasAList:	lds	si, es:[di].Tail  		;Get ptr to last

; Remove the last node from the list by storing the address of the next to
; last node in TAIL and setting the NEXT field of that node to NIL.
; Check to see if the list becomes empty (because we'll need to adjust HEAD
; when that happens).

		mov	dx, wp ds:[si].Prev
		mov	wp es:[di].Tail, dx
		mov	wp es:[di].CurrentNode, dx

		mov	dx, wp ds:[si].Prev+2
		mov	wp es:[di].Tail+2, dx
		mov	wp es:[di].CurrentNode+2, dx

		or	dx, dx				;List empty?
		jz     	LastGuy

; If the list is not empty, we need to set the NEXT field of the new
; last node to NIL.

		les	di, es:[di].Tail
		mov	wp es:[di].Next, 0
		mov	wp es:[di].Next+2, 0
		jmp	GoodRemove

; If we just removed the last node from the list, set the head pointer
; to NIL (Tail is already NIL from above).


LastGuy:	mov	wp es:[di].Head, dx
		mov	wp es:[di].Head+2, dx



		endif

GoodRemove:	clc
		mov	dx, ds

RemoveDone:	pop	di
		pop	es
		pop	ds
		ret

sl_RemoveLast	endp

stdlib		ends
		end
