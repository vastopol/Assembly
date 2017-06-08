
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

; sl_Insert1st -	DX:SI points at a list node.
;			ES:DI points at a list.
;			Insert the node at the beginning of the list
;
; Randall Hyde  3/4/92
;

		public	sl_Insert1st
sl_Insert1st	proc	far
		push	ds
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

		mov	word ptr es:[di].List.CurrentNode, si
		mov	word ptr es:[di+2].List.CurrentNode, dx

		mov	ds, dx
		cmp	wp es:[di].List.Head+2, 0	;Empty list?
		jne	HasAList

; At this point, the HEAD pointer is zero.  This only occurs if the
; list is empty.  So point the Head and Tail pointers to the new node.
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		mov	wp es:[di].List.Head, si
		mov	wp es:[di].List.Head+2, dx
		mov	wp es:[di].List.Tail, si
		mov	wp es:[di].List.Tail+2, dx
		mov	wp ds:[si].Node.Next, 0        	;Set all the links
		mov	wp ds:[si].Node.Next+2, 0	; in the first node
		mov	wp ds:[si].Node.Prev, 0		; to NIL.
		mov	wp ds:[si].Node.Prev+2, 0
		pop     di
		pop	es
		pop	ds
		jmp	InsertDone

; If the HEAD pointer is non-NIL, insert the new node at the start of the
; list down here.

HasAList:	les	di, es:[di].List.Head		;Get ptr to beginning
		mov	wp es:[di].Node.Prev, si	;Insert current node
		mov	wp es:[di].Node.Prev+2, dx	; at start of list.
		mov	wp ds:[si].Node.Next, di	;Link in back ptr.
		mov	wp ds:[si].Node.Next+2, es
		mov	wp ds:[si].Node.Prev, 0		;Set PREV field of
		mov	wp ds:[si].Node.Prev+2, 0	; to NIL.
		pop	di				;Return ptr to list
		pop	es				; variable.
		mov	wp es:[di].List.Head, si	;Update last ptr.
		mov	wp es:[di].List.Head+2, dx
		pop	ds






		else

; All other assemblers come down here:

		mov	word ptr es:[di].CurrentNode, si
		mov	word ptr es:[di+2].CurrentNode, dx

		mov	ds, dx
		cmp	wp es:[di].Head+2, 0		;Empty list?
		jne	HasAList

; At this point, the HEAD pointer is zero.  This only occurs if the
; list is empty.  So point the Head and Tail pointers to the new node.
; Note: Technically, the NIL pointer is 32-bits of zero. However, this
; package assumes that if the segment is zero, the whole thing is zero.
; So don't put any nodes into segment zero!

		mov	wp es:[di].Head, si
		mov	wp es:[di].Head+2, dx
		mov	wp es:[di].Tail, si
		mov	wp es:[di].Tail+2, dx
		mov	wp ds:[si].Next, 0        	;Set all the links
		mov	wp ds:[si].Next+2, 0		; in the first node
		mov	wp ds:[si].Prev, 0		; to NIL.
		mov	wp ds:[si].Prev+2, 0
		pop     di
		pop	es
		pop	ds
		jmp	InsertDone

; If the HEAD pointer is non-NIL, insert the new node at the beginning of the
; list down here.

HasAList:	les	di, es:[di].Head		;Get ptr to beginning
		mov	wp es:[di].Prev, si		;Insert current node
		mov	wp es:[di].Prev+2, dx		; at start of list.
		mov	wp ds:[si].Next, di		;Link in back ptr.
		mov	wp ds:[si].Next+2, es
		mov	wp ds:[si].Prev, 0		;Set PREV field of
		mov	wp ds:[si].Prev+2, 0		; to NIL.
		pop	di				;Return ptr to list
		pop	es				; variable.
		mov	wp es:[di].Head, si		;Update last ptr.
		mov	wp es:[di].Head+2, dx
		pop	ds

		endif

InsertDone:
		ret

sl_Insert1st	endp

stdlib		ends
		end
