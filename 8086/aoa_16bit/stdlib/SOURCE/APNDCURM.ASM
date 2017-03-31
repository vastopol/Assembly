
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


; sl_AppendCurm-	DX:SI points at a block of data bytes.
;			ES:DI points at a list.
;			This routine allocates storage for a new node on the
;			heap, copies the data from DX:SI to the new node,
;			and then links in the new node to the list after
;			the current node.
;
;			Returns the carry set if memory allocation error
;			occurs.
;
; Randall Hyde  3/13/92
;

		public	sl_AppendCurm
sl_AppendCurm	proc	far
		pushf
		push	ds
		push	ax
		push	bx
		push	cx
		push	es
		push	di
		cld



		if	@version ge 600

; MASM 6.0 version goes here

; First, allocate storage for the new node:

		mov	cx, es:[di].List.ListSize
		push	cx			;Save for later
		add	cx, size NODE		;Add in overhead
		call	sl_malloc		;Go get the memory
		pop	cx			;Get real length back.
		jc	BadAppend		;If malloc error
		push	di			;Save ptr to new NODE.

; Compute offset to actual data area (skipping over list pointers, etc.)

		add	di, size Node


		mov	ds, dx
	rep	movsb				;Copy the node's data.
		pop	si			;Get ptr to original node
		mov	cx, es			;Make ds:si point at node.
		mov	ds, cx
		pop	di			;Get ptr to list var
		pop	es
		push	es
		push	di

; At this point, DS:SI points at the new node on the heap and ES:DI points
; at the list variable.

; See if the the list is empty:

		cmp	wp es:[di].List.Head+2, 0
		jne	ListHasNodes

; If this is an empty list (list is empty if HEAD is NIL), then build the
; list from this single node.

		mov	wp es:[di].List.Tail, si
		mov     wp es:[di].List.Head, si
		mov	wp es:[di].List.CurrentNode, si
		mov	wp es:[di].List.Tail+2, ds
		mov	wp es:[di].List.Head+2, ds
		mov	wp es:[di].List.CurrentNode+2, ds

; Set the link fields of this new node to NIL.

		mov	wp [si].Node.Next, 0
		mov	wp [si].Node.Prev, 0
		mov	wp [si].Node.Next+2, 0
		mov	wp [si].Node.Prev+2, 0

		pop	di
		pop	es
		jmp	GoodAppend


;If there were items in the list, perform the insert down here.

ListHasNodes:	les	di, es:[di].List.CurrentNode	;Get ptr to item
		mov	ax, wp es:[di].Node.Next	;Get ptr to next
		mov	bx, wp es:[di].Node.Next+2	; node and save.

; Use the address of CurrentNode as the previous ptr for the new node.

		mov	wp ds:[si].Node.Prev, di 	;Patch in link
		mov	wp ds:[si].Node.Prev+2, es

; Okay, store the new node's address into the NEXT field of the current node

		mov	wp es:[di].Node.Next, si	;Patch in fwd ptr
		mov	wp es:[di].Node.Next+2, ds

; Set the NEXT field of the new node to the original previous node.

		mov	wp ds:[si].Node.Next, ax
		mov	wp ds:[si].Node.Next+2, bx

; Patch in the Prev field of the original NEXT node:

		mov	es, bx
		mov	di, ax
		mov	wp es:[di].Node.Prev, si
		mov	wp es:[di].Node.Prev+2, ds

; Set the CurrentNode ptr to the new node

		pop	di			;Retrive ptr to list var.
		pop	es
		mov	wp es:[di].List.CurrentNode, si
		mov	wp es:[di].List.CurrentNode+2, ds





		else

; All other assemblers come down here:


; First, allocate storage for the new node:

		mov	cx, es:[di].ListSize
		push	cx			;Save for later
		add	cx, size NODE		;Add in overhead
		call	sl_malloc		;Go get the memory
		pop	cx			;Get real length back.
		jnc	GoodApnd
		jmp	BadAppend		;If malloc error

GoodApnd:	push	di			;Save ptr to new NODE.

; Compute offset to actual data area (skipping over list pointers, etc.)

		add	di, size Node


		mov	ds, dx
	rep	movsb				;Copy the node's data.
		pop	si			;Get ptr to original node
		mov	cx, es			;Make ds:si point at node.
		mov	ds, cx
		pop	di			;Get ptr to list var
		pop	es
		push	es
		push	di

; At this point, DS:SI points at the new node on the heap and ES:DI points
; at the list variable.

; See if the the list is empty:

		cmp	wp es:[di].Head+2, 0
		jne	ListHasNodes

; If this is an empty list (list is empty if HEAD is NIL), then build the
; list from this single node.

		mov	wp es:[di].Tail, si
		mov     wp es:[di].Head, si
		mov	wp es:[di].CurrentNode, si
		mov	wp es:[di].Tail+2, ds
		mov	wp es:[di].Head+2, ds
		mov	wp es:[di].CurrentNode+2, ds

; Set the link fields of this new node to NIL.

		mov	wp [si].Next, 0
		mov	wp [si].Prev, 0
		mov	wp [si].Next+2, 0
		mov	wp [si].Prev+2, 0

		pop	di
		pop	es
		jmp	GoodAppend


;If there were items in the list, perform the insert down here.

ListHasNodes:	les	di, es:[di].CurrentNode	;Get ptr to item
		mov	ax, wp es:[di].Next	;Get ptr to next
		mov	bx, wp es:[di].Next+2	; node and save.

; Use the address of CurrentNode as the previous ptr for the new node.

		mov	wp ds:[si].Prev, di 	;Patch in link
		mov	wp ds:[si].Prev+2, es

; Okay, store the new node's address into the NEXT field of the current node

		mov	wp es:[di].Next, si	;Patch in fwd ptr
		mov	wp es:[di].Next+2, ds

; Set the NEXT field of the new node to the original previous node.

		mov	wp ds:[si].Next, ax
		mov	wp ds:[si].Next+2, bx

; Patch in the Prev field of the original NEXT node:

		mov	es, bx
		mov	di, ax
		mov	wp es:[di].Prev, si
		mov	wp es:[di].Prev+2, ds

; Set the CurrentNode ptr to the new node

		pop	di			;Retrive ptr to list var.
		pop	es
		mov	wp es:[di].CurrentNode, si
		mov	wp es:[di].CurrentNode+2, ds





		endif

; DANGER WILL ROBINSON! Multiple exit points.  Be wary of these if you
; change the way things are pushed on the stack.

GoodAppend:	pop	cx
		pop	bx
		pop	ax
		pop	ds
		popf
		clc
		ret

BadAppend:	pop	di
		pop	es
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		popf
		stc
		ret
sl_AppendCurm	endp

stdlib		ends
		end
