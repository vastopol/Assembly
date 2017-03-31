
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

; sl_Insert -	DX:SI points at a list node.
;		ES:DI points at a list.
;		CX contains a node number.
;		Insert the new node before the specified node (CX) in the
;		list.
;
; Randall Hyde  3/13/92
;

		public	sl_Insert
sl_Insert	proc	far
		push	ax
		push	bx
		push	cx
		push	ds
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

; First, locate the CXth node in the list:

		mov	ds, dx
		xor	dx, dx
		cmp	wp es:[di].List.Head+2, dx	;Empty list?
		jne	GetTheNode

; If we get down here, the list is empty!

		mov	wp es:[di].List.Head, si
		mov	wp es:[di].List.Head+2, ds
		mov	wp es:[di].List.Tail, si
		mov	wp es:[di].List.Tail+2, ds
		mov	wp es:[di].List.CurrentNode, si
		mov	wp es:[di].List.CurrentNode+2, ds

		mov	wp ds:[si].Node.Next, 0        	;Set all the links
		mov	wp ds:[si].Node.Next+2, 0	; in the first node
		mov	wp ds:[si].Node.Prev, 0		; to NIL.
		mov	wp ds:[si].Node.Prev+2, 0
		pop	di
		pop	es
		jmp	InsertDone


; Okay, we have at least one node in the list, get the pointer to this node
; into ES:DI.

GetTheNode:	les	di, es:[di].List.Head		;Get ptr to first node
		jmp	short IntoLoop

; The following loop repeats until we reach the end of the list or we count
; off CX nodes in the list.

FindNode:	les	di, es:[di].Node.Next
IntoLoop:	cmp	dx, wp es:[di].Node.Next+2	;NIL ptr?
		loopne	FindNode

		mov	ax, wp es:[di].Node.Prev	;Get previous ptr.
		mov	bx, wp es:[di].Node.Prev+2

		mov	wp es:[di].Node.Prev, si	;Insert the new node
		mov	wp es:[di].Node.Prev+2, ds	; before the current

		mov	wp ds:[si].Node.Next, di	;Link in back ptr.
		mov	wp ds:[si].Node.Next+2, es	; to "current" node.

		mov	wp ds:[si].Node.Prev, ax	;Store away ptr to
		mov	wp ds:[si].Node.Prev+2, bx	; previous node.

		mov	di, ax				;Get ptr to prev
		mov	es, bx				; node.
		mov	wp es:[di].Node.Next, si	;Store away link to
		mov	wp es:[di].Node.Next+2, ds	; new node.

		pop	di				;Retrieve pointer to
		pop	es				; list variable.
		mov	wp es:[di].List.CurrentNode, si	;Store ptr to new
		mov	wp es:[di].List.CurrentNode+2, ds ; current node.




		else

; This code is for the other assemblers.


; First, locate the CXth node in the list:

		mov	ds, dx
		xor	dx, dx
		cmp	wp es:[di].Head+2, dx	;Empty list?
		je	EmptyList

; Okay, we have at least one node in the list, get the pointer to this node
; into ES:DI.

		les	di, es:[di].Head		;Get ptr to first node
		jmp	short IntoLoop

; The following loop repeats until we reach the end of the list or we count
; off CX nodes in the list.

FindNode:	les	di, es:[di].Next
IntoLoop:	cmp	dx, wp es:[di+2].Next
		loopne	FindNode
		jmp	short HasAList


; If we get down here, the list is empty!

EmptyList:	mov	wp es:[di].Head, si
		mov	wp es:[di].Head+2, ds
		mov	wp es:[di].Tail, si
		mov	wp es:[di].Tail+2, ds
		mov	wp es:[di].CurrentNode, si
		mov	wp es:[di].CurrentNode+2, ds

		mov	wp ds:[si].Next, 0        	;Set all the links
		mov	wp ds:[si].Next+2, 0	; in the first node
		mov	wp ds:[si].Prev, 0		; to NIL.
		mov	wp ds:[si].Prev+2, 0
		pop	di
		pop	es
		jmp	InsertDone

; If the HEAD pointer is non-NIL, insert the new node before the CXth node in
; the list down here.

HasAList:       mov	ax, wp es:[di].Prev	;Get previous ptr.
		mov	bx, wp es:[di].Prev+2

		mov	wp es:[di].Prev, si	;Insert the new node
		mov	wp es:[di].Prev+2, ds	; before the current

		mov	wp ds:[si].Next, di	;Link in back ptr.
		mov	wp ds:[si].Next+2, es	; to "current" node.

		mov	wp ds:[si].Prev, ax	;Store away ptr to
		mov	wp ds:[si].Prev+2, bx	; previous node.

		mov	di, ax				;Get ptr to prev
		mov	es, bx				; node.
		mov	wp es:[di].Next, si	;Store away link to
		mov	wp es:[di].Next+2, ds	; new node.

		pop	di				;Retrieve pointer to
		pop	es				; list variable.
		mov	wp es:[di].CurrentNode, si	;Store ptr to new
		mov	wp es:[di].CurrentNode+2, ds ; current node.



		endif

InsertDone:	pop	ds
		pop	cx
		pop	bx
		pop	ax
		ret

sl_Insert	endp

stdlib		ends
		end
