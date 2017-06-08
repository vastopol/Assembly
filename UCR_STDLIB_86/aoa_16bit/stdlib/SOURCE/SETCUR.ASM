
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

; sl_SetCur -	ES:DI points at a list.
;		CX contains a node number.
;
;		Locates node CX and makes this the new current node.
;		Also returns a pointer to this node in dx:si.
;
; Randall Hyde  3/24/94
;

		public	sl_SetCur
sl_SetCur	proc	far
		push	ax
		push	bx
		push	cx
		push	es
		push	di

		if	@version ge 600

; MASM 6.0 version goes here

; First, locate the CXth node in the list:

		xor	dx, dx
		cmp	wp es:[di].List.Head+2, dx	;Empty list?
		jne	GetTheNode

; If we get down here, the list is empty!

		mov	si, dx				;DX:SI = NIL.
		pop	di
		pop	es
		jmp	SetCurDone


; Okay, we have at least one node in the list, get the pointer to this node
; into ES:DI.

GetTheNode:	les	di, es:[di].List.Head		;Get ptr to first node
		jmp	short IntoLoop

; The following loop repeats until we reach the end of the list or we count
; off CX nodes in the list.

FindNode:	les	di, es:[di].Node.Next
IntoLoop:	cmp	dx, wp es:[di+2].Node.Next	;NIL ptr?
		loopne	FindNode

FoundNode:	mov	dx, es
		mov	si, di

		pop	di				;Retrieve pointer to
		pop	es				; list variable.
		mov	wp es:[di].List.CurrentNode, si	;Store ptr to new
		mov	wp es:[di].List.CurrentNode+2, dx ; current node.




		else

; This code is for the other assemblers.

; First, locate the CXth node in the list:

		xor	dx, dx
		cmp	wp es:[di].Head+2, dx		;Empty list?
		jne	GetTheNode

; If we get down here, the list is empty!

		mov	si, dx				;DX:SI = NIL.
		pop	di
		pop	es
		jmp	SetCurDone


; Okay, we have at least one node in the list, get the pointer to this node
; into ES:DI.

GetTheNode:	les	di, es:[di].Head		;Get ptr to first node
		jmp	short IntoLoop

; The following loop repeats until we reach the end of the list or we count
; off CX nodes in the list.

FindNode:	les	di, es:[di].Next
IntoLoop:	cmp	dx, wp es:[di+2].Next		;NIL ptr?
		loopne	FindNode

FoundNode:	mov	dx, es
		mov	si, di

		pop	di				;Retrieve pointer to
		pop	es				; list variable.
		mov	wp es:[di].CurrentNode, si	;Store ptr to new
		mov	wp es:[di].CurrentNode+2, dx	; current node.




		endif

SetCurDone:	pop	cx
		pop	bx
		pop	ax
		ret

sl_SetCur	endp




; NextNode-	Sets the current pointer to the next node in the list.
;		Returns ptr to new node in dx:si.
;		If current node is last node in list, does not change
;		the current node pointer, but sets the carry flag.
;		Otherwise, returns with carry flag clear.

		public	sl_NextNode
sl_NextNode	proc	far
		push	es
		push	di

		if	@version ge 600

		cmp	wp es:[di+2].List.CurrentNode, 0 ;See if empty list.
		je	NextNotThere
		les	di, es:[di].List.CurrentNode	;Get ptr to current
		mov	dx, wp es:[di+2].Node.Next	;See if last node.
		test	dx, dx
		je	NextNotThere
		mov	si, wp es:[di].Node.Next
		pop	di
		pop	es
		mov	wp es:[di].List.CurrentNode, si	  ;Store ptr to new
		mov	wp es:[di].List.CurrentNode+2, dx ; current node.
		clc
		ret

NextNotThere:	pop	di
		pop	es
		mov	dx, wp es:[di+2].List.CurrentNode ;If the current is
		mov	si, wp es:[di].List.CurrentNode	  ; really last, quit.
		stc
		ret


		else

; Code for other assemblers:

		cmp	wp es:[di+2].CurrentNode, 0 	;See if empty list.
		je	NextNotThere
		les	di, es:[di].CurrentNode		;Get ptr to current
		mov	dx, wp es:[di+2].Next		;See if last node.
		test	dx, dx
		je	NextNotThere
		mov	si, wp es:[di].Next
		pop	di
		pop	es
		mov	wp es:[di].CurrentNode, si	;Store ptr to new
		mov	wp es:[di].CurrentNode+2, dx	; current node.
		clc
		ret

NextNotThere:	pop	di
		pop	es
		mov	dx, wp es:[di+2].List.CurrentNode ;If the current is
		mov	si, wp es:[di].List.CurrentNode	; really last, quit.
		stc
		ret

		endif
sl_NextNode	endp




; PrevNode-	Sets the current pointer to the previous node in the list.
;		Returns ptr to new node in dx:si.
;		If current node is first node in list, does not change
;		the current node pointer and returns the carry flag set.
;		Otherwise it returns the carry flag clear.

		public	sl_PrevNode
sl_PrevNode	proc	far
		push	es
		push	di

		if	@version ge 600

		cmp	wp es:[di+2].List.CurrentNode, 0 ;See if empty list.
		je	PrevNotThere
		les	di, es:[di].List.CurrentNode	;Get ptr to current
		mov	dx, wp es:[di+2].Node.Prev	;See if 1st node.
		test	dx, dx
		je	PrevNotThere
		mov	si, wp es:[di].Node.Prev
		pop	di
		pop	es
		mov	wp es:[di].List.CurrentNode, si	  ;Store ptr to new
		mov	wp es:[di].List.CurrentNode+2, dx ; current node.
		clc
		ret

PrevNotThere:	pop	di
		pop	es
		mov	dx, wp es:[di+2].List.CurrentNode ;If the current is
		mov	si, wp es:[di].List.CurrentNode	; really 1st, quit.
		stc
		ret


		else

; Code for other assemblers:

		cmp	wp es:[di+2].CurrentNode, 0 	;See if empty list.
		je	PrevNotThere
		les	di, es:[di].CurrentNode		;Get ptr to current
		mov	dx, wp es:[di+2].Prev		;See if 1st node.
		test	dx, dx
		je	PrevNotThere
		mov	si, wp es:[di].Prev
		pop	di
		pop	es
		mov	wp es:[di].CurrentNode, si	;Store ptr to new
		mov	wp es:[di].CurrentNode+2, dx	; current node.
		clc
		ret

PrevNotThere:	pop	di
		pop	es
		mov	dx, wp es:[di+2].CurrentNode	 ;If the current is
		mov	si, wp es:[di].CurrentNode	; really 1st, quit.
		stc
		ret


		endif
sl_PrevNode	endp



stdlib		ends
		end
