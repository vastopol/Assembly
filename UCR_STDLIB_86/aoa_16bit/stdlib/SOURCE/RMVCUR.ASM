
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

; sl_RemoveCur -	ES:DI points at a list.
;			Removes the CurrentNode from the list and returns a
;			pointer to this item in DX:SI.  Returns the carry
;			flag set if the list was empty.
;
; Randall Hyde  3/12/92
;

		public	sl_RemoveCur
sl_RemoveCur	proc	far
		push	ds
		push	ax
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
		pop	di
		pop	es
		stc
		jmp	RemoveDone

; If the HEAD pointer is NON-NIL, remove the CurrentNode here.

HasAList:	lds	si, es:[di].List.CurrentNode	;Get node to delete.

; Remove this guy by doing the following:
;
; +----------+       +----------+       +----------+
; |          | -->   |          | -->   |          |
; +----------+       +----------+       +----------+
;
; First, set the next field of the previous node to point at the next field
; of the current node:
;
; +----------+       +----------+       +----------+
; |          | -+    |          |   +-> |          |
; +----------+  |    +----------+   |   +----------+
;               +-------------------+

		cmp	wp ds:[si].Node.Prev+2, 0	;No previous node?
		je	CurrentIs1st
		les	di, ds:[si].Node.Prev
		mov	dx, wp ds:[si].Node.Next
		mov	wp es:[di].Node.Next, dx
		mov	dx, wp ds:[si].Node.Next+2
		mov	wp es:[di].Node.Next+2, dx
		jmp	short FixNextNode

; If there was no first node, then the current node is the first node in
; the list.  We need to patch the HEAD pointer in this case.

CurrentIs1st:	pop	di				;Get ptr to list
		pop	es
		push	es
		push	di
		mov	dx, wp ds:[si].Node.Next
		mov	wp es:[di].List.Head, dx
		mov	dx, wp ds:[si].Node.Next+2
		mov	wp es:[di].List.Head+2, dx

; Next, set the previous field of the next node to point at the previous
; node:
;
; +----------+       +----------+       +----------+
; |          | <--   |          | <--   |          |
; +----------+       +----------+       +----------+
;
; +----------+       +----------+       +----------+
; |          | <-+   |          |    +- |          |
; +----------+   |   +----------+    |  +----------+
;                +-------------------+

FixNextNode:	cmp	wp ds:[si].Node.Next+2, 0	;No next node?
		je	CurrentIsLast
		les	di, ds:[si].Node.Next
		mov	dx, wp ds:[si].Node.Prev
		mov	wp es:[di].Node.Prev, dx
		mov	ax, wp ds:[si].Node.Prev+2
		mov	wp es:[di].Node.Prev+2, dx

		mov	dx, es				;Save ptr to new
		mov	ax, di				; current node
		pop	di
		pop	es
		mov     wp es:[di].List.CurrentNode, ax
		mov	wp es:[di].List.CurrentNode+2, dx
		jmp	GoodRemove

; If the current node was the last node in the list, we've got to patch the
; TAIL pointer in the list structure.

CurrentIsLast:	cmp	wp ds:[si].Node.Prev+2, 0	;Was this the only
		je	OnlyNodeInList			; node?

		pop	di
		pop	es

		mov	dx, wp ds:[si].Node.Prev
		mov	wp es:[di].List.Tail, dx
		mov	wp es:[di].List.CurrentNode, dx
		mov	dx, wp ds:[si].Node.Prev+2
		mov	wp es:[di].List.Tail+2, dx
		mov	wp es:[di].List.CurrentNode+2, dx
		jmp	GoodRemove


; If the current node was the only node in the list, set the TAIL and
; CurrentNode fields to NIL.  Note that HEAD was already set to NIL.

OnlyNodeInList:	pop	di
		pop	es
		xor	dx, dx
		mov	wp es:[di].List.Tail, dx
		mov	wp es:[di].List.Tail+2, dx
		mov	wp es:[di].List.CurrentNode, dx
		mov	wp es:[di].List.CurrentNode+2, dx


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
		pop	di
		pop	es
		stc
		jmp	RemoveDone

; If the HEAD pointer is NON-NIL, remove the CurrentNode here.

HasAList:	lds	si, es:[di].CurrentNode		;Get node to delete.

		cmp	wp ds:[si].Prev+2, 0		;No previous node?
		je	CurrentIs1st
		les	di, ds:[si].Prev
		mov	dx, wp ds:[si].Next
		mov	wp es:[di].Next, dx
		mov	dx, wp ds:[si].Next+2
		mov	wp es:[di].Next+2, dx
		jmp	short FixNextNode


CurrentIs1st:	pop	di				;Get ptr to list
		pop	es
		push	es
		push	di
		mov	dx, wp ds:[si].Next
		mov	wp es:[di].Head, dx
		mov	dx, wp ds:[si].Next+2
		mov	wp es:[di].Head+2, dx

FixNextNode:	cmp	wp ds:[si].Next+2, 0		;No next node?
		je	CurrentIsLast
		les	di, ds:[si].Next
		mov	dx, wp ds:[si].Prev
		mov	wp es:[di].Prev, dx
		mov	ax, wp ds:[si].Prev+2
		mov	wp es:[di].Prev+2, dx

		mov	dx, es				;Save ptr to new
		mov	ax, di				; current node
		pop	di
		pop	es
		mov     wp es:[di].CurrentNode, ax
		mov	wp es:[di].CurrentNode+2, dx
		jmp	GoodRemove

CurrentIsLast:	cmp	wp ds:[si].Prev+2, 0		;Was this the only
		je	OnlyNodeInList			; node?

		pop	di
		pop	es

		mov	dx, wp ds:[si].Prev
		mov	wp es:[di].Tail, dx
		mov	wp es:[di].CurrentNode, dx
		mov	dx, wp ds:[si].Prev+2
		mov	wp es:[di].Tail+2, dx
		mov	wp es:[di].CurrentNode+2, dx
		jmp	GoodRemove


OnlyNodeInList:	pop	di
		pop	es
		xor	dx, dx
		mov	wp es:[di].Tail, dx
		mov	wp es:[di].Tail+2, dx
		mov	wp es:[di].CurrentNode, dx
		mov	wp es:[di].CurrentNode+2, dx



		endif

GoodRemove:	clc
		mov	dx, ds			;Return ptr to node we've
;						; removed in DX:SI.

RemoveDone:	pop	ax
		pop	ds
		ret

sl_RemoveCur	endp

stdlib		ends
		end
