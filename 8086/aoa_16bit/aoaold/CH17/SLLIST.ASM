; SLLIST.ASM
;
; Implementation file for a list abstract data type.
; This particular implementation uses a singly linked list to
; implement the list.

		option	segment:use16
		.386			;To use extra seg registers.

		include	MyList2.a

Nod		typedef	$$$$_node	;To make typing easier.
wp		textequ	<word ptr>

cseg		segment	para public 'code'

; List_Count is an access method which returns the size of a list
;	     (that is, the number of items currently in the list).
;
;	On entry: 	fs:bx points at the pointer variable which
;			points at the first node in the list.
;	On exit:        ax contains the number of items in the list.

List_Count	proc
		push	bx
		push	fs
		sub	ax, ax		;Init count to zero.

; If the list pointer contains NIL, the list is empty.
; This code cheats a little bit and only looks at the segment
; portion of the link field.  The segment portion only contains
; zero if the link field contains NIL.
;
; At this point, fs:bx points at the list pointer variable, see
; if it is NIL.

		cmp	ax, word ptr fs:[bx+2]
		je	CountDone

; The following loop scans through the list to the end of the
; list, incrementing AX each time through the loop.

CountLp:	lfs	bx, fs:[bx].Nod.Link
		inc	ax
		cmp	word ptr fs:[bx+2].Nod.Link, 0
		jne	CountLp
CountDone:	pop	fs
		pop	bx
		ret
List_Count	endp



; List_GetItem-	Fetches an object from the list.
;
;	On Entry:	fs:bx points at the pointer to the list.
;			di contains an index into the list.
;
;	On Exit:	es:di points at the selected object in
;			the list.

List_GetItem	proc
		push	fs
		push	bx

; See if the list is empty:

		cmp	word ptr fs:[bx+2], 0	;See if empty list
		je	NoSuchNode

		lfs	bx, fs:[bx]		;Ptr to 1st node.
		inc	di			;For dec later.
		jmp	FindNode

; The following loop scans through the list looking for the
; desired node.  If it prematurely encounters the end of the
; list, it returns NIL in es:di, else it returns a pointer
; to the given data structure in es:di.

FNodeLp:	cmp	word ptr fs:[bx+2].Nod.Link, 0
		je	NoSuchNode
		lfs	bx, fs:[bx].Nod.Link
FindNode:       dec	di
		jne	FNodeLp

; Okay, we found the node, return a pointer to the node
; in es:di.

		mov	di, fs
		mov	es, di
		mov	di, bx
		pop	bx
		pop	fs
		ret

NoSuchNode:	sub	di, di
		mov	es, di
		pop	bx
		pop	fs
		ret
List_GetItem	endp




; List_Insert-	es:di points at a node to insert into the list.
;		fs:bx points at a list pointer.
;		si contains an index into the list.
;
;		This code inserts the specified object into the
;		list.  If the index is out of range, this code
;		appends the object to the end of the list.
;
; This routine always returns the carry clear because no error
; can occur (unlike the array implementation of lists).

List_Insert	proc
		push	fs
		push	bx
		push	si

; Since the offset of the link field is zero, the following code
; both dereferences the list pointer *and* accesses the link field

		inc	si		;Because we dec it next.
InsLoop:	dec	si              ;Dec desired index.
		je	GotNode

; See if we've run into the end of the list.  Do this by
; checking the H.O. word of the link field (the segment
; portion).  If it contains zero, we have a NIL link.

		cmp	word ptr fs:[bx+2].Nod.Link, 0
		je	GotNode
		lfs	bx, fs:[bx].Nod.Link
		jmp	InsLoop

; Okay, we've got a pointer to either a node (or the original
; list pointer) and we need to insert the new node (es:di) after
; that node.  The following code copies the link field into the
; new node's link field and then points the link field at the
; new node.

GotNode:        push	eax
		mov	eax, fs:[bx].Nod.Link
		mov	es:[di].Nod.Link, eax
		mov	word ptr fs:[bx].Nod.Link, di
		mov	word ptr fs:[bx+2].Nod.Link, es
		pop	eax

		pop	si
		pop	bx
		pop	fs
		clc
		ret
List_Insert	endp



; List_Remove-	fs:bx points at a list pointer.
;		si contains an index into the list.
;
;		This code deletes the specified object from the
;		list.

List_Remove	proc
		push	fs
		push	bx
		push	es
		push	si
		push	eax

; Scan through the linked list and find the node which we want
; to delete.  If no such node exists, just quit.

		inc	si
RmvLoop:	cmp	word ptr fs:[bx+2].Nod.Link, 0
		je	RmvDone
		dec	si
		je	FoundNode
		lfs	bx, fs:[bx].Nod.Link
		jmp	RmvLoop

; Okay, fs:bx now points at the node *before* the one we wish
; to delete.  Furthermore, we know that there is a node to
; delete.

FoundNode:	les	si, fs:[bx].Nod.Link	;Ptr to next node
		mov	eax, es:[si].Nod.Link	;Get it's link.
		mov	fs:[bx].Nod.Link, eax	;Delete the node.
RmvDone:	pop	eax
		pop	si
		pop	es
		pop	bx
		pop	fs
		ret
List_Remove	endp

cseg		ends
		end