; Need to include "lists.a" in order to get list structure definition.

		include	lists.a
		extrn	sl_malloc:far


StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends

stdlib		segment	para public 'slcode'
		assume	cs:stdgrp

; sl_CreateList-	Allocates storage for a new list variable on the
;			heap.  Initializes appropriate fields.
;
; Randall Hyde  3/2/92
;
; On Entry:
;
;		CX contains the number of bytes of data for each node
;		in the list (does not include the size of the links, etc.)
;
; On Exit:	ES:DI points at list variable on the head.
;		Carry is set if malloc error.

		public	sl_CreateList
sl_CreateList	proc	far
		push	cx
		mov	cx, size List
		call	sl_malloc
		pop	cx
		jc	BadCreateList

; The following code varies depending upon whether this is MASM 6.0 or
; some other assembler:

		ifndef	@version
		mov	es:[di].ListSize, cx	;Not MASM 5.1 or MASM 6.0
		mov	word ptr es:[di].Head, 0
		mov	word ptr es:[di+2].Head, 0
		mov	word ptr es:[di].Tail, 0
		mov	word ptr es:[di+2].Tail, 0
		mov	word ptr es:[di].CurrentNode, 0
		mov	word ptr es:[di+2].CurrentNode, 0

		else
		if	@version ge 600
		mov	es:[di].list.ListSize, cx	;MASM 6.0 or later
		mov	word ptr es:[di].list.Head, 0
		mov	word ptr es:[di+2].list.Head, 0
		mov	word ptr es:[di].list.Tail, 0
		mov	word ptr es:[di+2].list.Tail, 0
		mov	word ptr es:[di].List.CurrentNode, 0
		mov	word ptr es:[di+2].List.CurrentNode, 0

		else
		mov	es:[di].ListSize, cx		;Probably MASM 5.1
		mov	word ptr es:[di].Head, 0
		mov	word ptr es:[di+2].Head, 0
		mov	word ptr es:[di].Tail, 0
		mov	word ptr es:[di+2].Tail, 0
		mov	word ptr es:[di].CurrentNode, 0
		mov	word ptr es:[di+2].CurrentNode, 0
		endif
		endif
		clc				;Not really needed, C=0 already
BadCreateList:	ret

sl_CreateList	endp

stdlib		ends
		end
