
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


; sl_Insert1stm-	DX:SI points at a block of data bytes.
;			ES:DI points at a list.
;			This routine allocates storage for a new node on the
;			heap, copies the data from DX:SI to the new node,
;			and then links in the new node to the list.
;
;			Returns the carry set if memory allocation error
;			occurs.
;
; Randall Hyde  3/3/92
;

		public	sl_Insert1stm
sl_Insert1stm	proc	far
		pushf
		push	ds
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
		jc	BadInsert		;If malloc error
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

		mov	wp es:[di].List.CurrentNode, si
		mov	wp es:[di].List.CurrentNode+2, cx

; Get the pointer to the first item in the list and store its address into the
; PREV link field of the new node:

		cmp	wp es:[di].List.Head+2, 0	;See if empty list
		jne	ListHasNodes

; If this is an empty list (list is empty if HEAD is NIL), then add the
; first node to the list.

		mov	wp es:[di].List.Tail, si
		mov     wp es:[di].List.Head, si
		mov	wp es:[di].List.Tail+2, ds
		mov	wp es:[di].List.Head+2, ds
		mov	wp [si].Node.Next, 0
		mov	wp [si].Node.Prev, 0
		mov	wp [si].Node.Next+2, 0
		mov	wp [si].Node.Prev+2, 0
		pop	di
		pop	es
		jmp	GoodInsert

;If there were items in the list, perform the insert down here.

ListHasNodes:	les	di, es:[di].List.Head		;Get ptr to first item
		mov	wp ds:[si].Node.Next, di 	;Patch in link
		mov	wp ds:[si].Node.Next+2, es

; Okay, store the new node's address into the PREV field of the first node
; currently in the list:

		mov	wp es:[di].Node.Prev, si	;Patch in fwd ptr
		mov	wp es:[di].Node.Prev+2, ds

; Set the PREV field of the new node to NIL:

		mov	wp ds:[si].Node.Prev, 0		;Set new node's link
		mov	wp ds:[si].Node.Prev+2, 0	; to NIL.

; Set the HEAD ptr to the new node

		pop	di			;Retrive ptr to list var.
		pop	es
		mov	wp es:[di].List.Head, si
		mov	wp es:[di].List.Head+2, ds





		else

; All other assemblers come down here:


; First, allocate storage for the new node:

		mov	cx, es:[di].ListSize
		push	cx			;Save for later
		add	cx, size NODE		;Add in overhead
		call	sl_malloc		;Go get the memory
		pop	cx			;Get real length back.
		jc	BadInsert		;If malloc error
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

		mov	wp es:[di].CurrentNode, si
		mov	wp es:[di+2].CurrentNode, cx

; Get the pointer to the first item in the list and store its address into the
; PREV link field of the new node:

		cmp	wp es:[di].Head+2, 0		;See if empty list
		jne	ListHasNodes

; If this is an empty list (list is empty if HEAD is NIL), then add the
; first node to the list.

		mov	wp es:[di].Tail, si
		mov     wp es:[di].Head, si
		mov	wp es:[di].Tail+2, ds
		mov	wp es:[di].Head+2, ds
		mov	wp [si].Next, 0
		mov	wp [si].Prev, 0
		mov	wp [si].Next+2, 0
		mov	wp [si].Prev+2, 0
		pop	di
		pop	es
		jmp	GoodInsert

;If there were items in the list, perform the insert down here.

ListHasNodes:	les	di, es:[di].Head		;Get ptr to first item
		mov	wp ds:[si].Next, di	 	;Patch in link
		mov	wp ds:[si].Next+2, es

; Okay, store the new node's address into the PREV field of the first node
; currently in the list:

		mov	wp es:[di].Prev, si		;Patch in fwd ptr
		mov	wp es:[di].Prev+2, ds

; Set the PREV field of the new node to NIL:

		mov	wp ds:[si].Prev, 0		;Set new node's link
		mov	wp ds:[si].Prev+2, 0		; to NIL.

; Set the HEAD ptr to the new node

		pop	di			;Retrive ptr to list var.
		pop	es
		mov	wp es:[di].Head, si
		mov	wp es:[di].Head+2, ds



		endif

; DANGER WILL ROBINSON! Multiple exit points.  Be wary of these if you
; change the way things are pushed on the stack.

GoodInsert:	pop	cx
		pop	ds
		popf
		clc
		ret

BadInsert:	pop	di
		pop	es
		pop	cx
		pop	ds
		popf
		stc
		ret
sl_Insert1stm	endp

stdlib		ends
		end
