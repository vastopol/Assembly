
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

; sl_AppendLast-	DX:SI points at a list node.
;			ES:DI points at a list.
;			Append the node to the end of the list
;
; Randall Hyde  3/3/92
;

		public	sl_AppendLast
sl_AppendLast	proc	far
		push	ds
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

		mov	wp es:[di].List.CurrentNode, si	;Set ptr to current
		mov	wp es:[di].List.CurrentNode+2, dx

		mov	ds, dx
		cmp	wp es:[di].List.Tail+2, 0	;Empty list?
		jne	HasAList

; At this point, the Tail pointer is zero.  This only occurs if the
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
		jmp	AppendDone

; If the Tail pointer is non-NIL, append the new node to the end of the
; list down here.

HasAList:	les	di, es:[di].List.Tail		;Get ptr to end
		mov	wp es:[di].Node.Next, si	;Append current node
		mov	wp es:[di].Node.Next+2, dx	; to end of list.
		mov	wp ds:[si].Node.Prev, di	;Link in back ptr.
		mov	wp ds:[si].Node.Prev+2, es
		mov	wp ds:[si].Node.Next, 0		;Set next field of
		mov	wp ds:[si].Node.Next+2, 0	; to NIL.
		pop	di				;Return ptr to list
		pop	es				; variable.
		mov	wp es:[di].List.Tail, si	;Update last ptr.
		mov	wp es:[di].List.Tail+2, dx
		pop	ds




		else

; All other assemblers come down here:

		mov	wp es:[di].CurrentNode, si	;Set ptr to current
		mov	wp es:[di].CurrentNode+2, dx	; node here.

		mov	ds, dx
		cmp	wp es:[di].Tail+2, 0	;Empty list?
		jne	HasAList

; At this point, the Tail pointer is zero.  This only occurs if the
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
		jmp	AppendDone

; If the Tail pointer is non-NIL, append the new node to the end of the
; list down here.

HasAList:	les	di, es:[di].Tail		;Get ptr to end
		mov	wp es:[di].Next, si		;Append current node
		mov	wp es:[di].Next+2, dx		; to end of list.
		mov	wp ds:[si].Prev, di		;Link in back ptr.
		mov	wp ds:[si].Prev+2, es
		mov	wp ds:[si].Next, 0		;Set next field of
		mov	wp ds:[si].Next+2, 0		; to NIL.
		pop	di				;Return ptr to list
		pop	es				; variable.
		mov	wp es:[di].Tail, si		;Update last ptr.
		mov	wp es:[di].Tail+2, dx
		pop	ds

		endif

AppendDone:
		ret

sl_AppendLast	endp

stdlib		ends
		end
