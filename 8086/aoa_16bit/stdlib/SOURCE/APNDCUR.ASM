
; Need to include "lists.a" in order to get list structure definition.

		include	lists.a
		extrn	sl_malloc:far


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

; sl_AppendCur -	DX:SI points at a list node.
;			ES:DI points at a list.
;			Insert the new node after "CurrentNode" in the
;			list.
;
; Randall Hyde  3/13/92
;

		public	sl_AppendCur
sl_AppendCur	proc	far
		push	ax
		push	bx
		push	ds
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

		mov	ds, dx
		cmp	wp es:[di].List.Head+2, 0	;Empty list?
		jne	HasAList

; At this point, the HEAD pointer is zero.  This only occurs if the
; list is empty.  So point the Head, CurrentNode, and Tail pointers to
; the new node.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		mov	wp es:[di].List.Head, si
		mov	wp es:[di].List.Head+2, dx
		mov	wp es:[di].List.Tail, si
		mov	wp es:[di].List.Tail+2, dx
		mov	wp es:[di].List.CurrentNode, si
		mov	wp es:[di].List.CurrentNode+2, dx

		mov	wp ds:[si].Node.Next, 0        	;Set all the links
		mov	wp ds:[si].Node.Next+2, 0	; in the first node
		mov	wp ds:[si].Node.Prev, 0		; to NIL.
		mov	wp ds:[si].Node.Prev+2, 0
		pop	di
		pop	es
		jmp	AppendDone

; If the HEAD pointer is non-NIL, insert the new node after CurrentNode in
; the list down here.

HasAList:       les	di, es:[di].List.CurrentNode	;Get ptr to current.

		mov	ax, wp es:[di].Node.Next	;Get Next ptr.
		mov	bx, wp es:[di].Node.Next+2


		mov	wp es:[di].Node.Next, si	;Insert the new node
		mov	wp es:[di].Node.Next+2, dx	; after the current

		mov	wp ds:[si].Node.Prev, di	;Link in ptr
		mov	wp ds:[si].Node.Prev+2, es	; to "current" node.

		mov	wp ds:[si].Node.Next, ax	;Store away ptr to
		mov	wp ds:[si].Node.Next+2, bx	; previous node.

		mov	di, ax				;Get ptr to NEXT
		mov	es, bx				; node.
		mov	wp es:[di].Node.Prev, si	;Store away link to
		mov	wp es:[di].Node.Prev+2, dx	; new node.

		pop	di				;Retrieve pointer to
		pop	es				; list variable.
		mov	wp es:[di].List.CurrentNode, si	;Store ptr to new
		mov	wp es:[di].List.CurrentNode+2, ds ; current node.




		else

; This code is for the other assemblers.

		mov	ds, dx
		cmp	wp es:[di].Head+2, 0		;Empty list?
		jne	HasAList

; At this point, the HEAD pointer is zero.  This only occurs if the
; list is empty.  So point the Head, CurrentNode, and Tail pointers to
; the new node.
;
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		mov	wp es:[di].Head, si
		mov	wp es:[di].Head+2, dx
		mov	wp es:[di].Tail, si
		mov	wp es:[di].Tail+2, dx
		mov	wp es:[di].CurrentNode, si
		mov	wp es:[di].CurrentNode+2, dx

		mov	wp ds:[si].Next, 0        	;Set all the links
		mov	wp ds:[si].Next+2, 0		; in the first node
		mov	wp ds:[si].Prev, 0		; to NIL.
		mov	wp ds:[si].Prev+2, 0
		pop	di
		pop	es
		jmp	AppendDone

; If the HEAD pointer is non-NIL, insert the new node after CurrentNode in
; the list down here.

HasAList:       les	di, es:[di].CurrentNode		;Get ptr to current.

		mov	ax, wp es:[di].Next		;Get Next ptr.
		mov	bx, wp es:[di].Next+2


		mov	wp es:[di].Next, si		;Insert the new node
		mov	wp es:[di].Next+2, dx		; after the current

		mov	wp ds:[si].Prev, di		;Link in ptr
		mov	wp ds:[si].Prev+2, es		; to "current" node.

		mov	wp ds:[si].Next, ax		;Store away ptr to
		mov	wp ds:[si].Next+2, bx		; previous node.

		mov	di, ax				;Get ptr to NEXT
		mov	es, bx				; node.
		mov	wp es:[di].Prev, si		;Store away link to
		mov	wp es:[di].Prev+2, dx		; new node.

		pop	di				;Retrieve pointer to
		pop	es				; list variable.
		mov	wp es:[di].CurrentNode, si	;Store ptr to new
		mov	wp es:[di].CurrentNode+2, ds 	; current node.




		endif

AppendDone:	pop	ds
		pop	bx
		pop	ax
		ret

sl_AppendCur	endp

stdlib		ends
		end
