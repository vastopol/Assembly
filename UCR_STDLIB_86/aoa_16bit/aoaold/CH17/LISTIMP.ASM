; LISTARY.ASM
;
; Implementation file for a list abstract data type.
; This particular implementation uses an array of pointers
; to implement the list.

		option	segment:use16
		.386			;To use extra seg registers.

		include	MyList.a

Lst		typedef	$$$$_list	;To make typing easier.
wp		textequ	<word ptr>

cseg		segment	para public 'code'

; List_Count is an access method which returns the size of a list
;	     (that is, the number of items currently in the list).
;
;	On entry: 	fs:bx points at the list object.
;	On exit:        ax contains the number of items in the list.

List_Count	proc
		mov	ax, fs:[bx].Lst.count
		ret
List_Count	endp



; List_GetItem-	Fetches an object from the list.
;
;	On Entry:	fs:bx points at a list object.
;			di contains an index into the list.
;
;	On Exit:	es:di points at the selected object in
;			the list.

List_GetItem	proc

; Check to see if the value in di is too big.  If so, return the
; value NIL (zero) in es:di.  Otherwise compute an appropriate
; index into the array of pointers.

		cmp	di, fs:[bx].Lst.count
		ja	ReturnNIL

; Multiply di by four to index into an array of dwords:

		shl	di, 2

; Return a pointer to the desired item:

		les	di, fs:[bx].Lst.ptrs[di]
		ret

; If the original index was beyond the end of the list, just return
; the NIL pointer.

ReturnNIL:	sub	di, di		;di := 0;
		mov	es, di
		ret
List_GetItem	endp




; List_Insert-	es:di points at an object.
;		fs:bx points at a list variable.
;		si contains an index into the list.
;
;		This code inserts the specified object into the
;		list.  If the index is out of range, this code
;		appends the object to the end of the list.
;
;		If the list is full, this routine ignores the
;		insertion request and returns the carry flag
;		set (carry is clear if no error).

List_Insert	proc
		push	ax
		push	ecx
		mov	ax, fs:[bx].Lst.count

; First, see if the supplied index is to big. If so, just append
; the data to the end of the list.

		cmp	si, ax
		jb	NoAppend
		mov	si, ax
NoAppend:

; Now check to see if the list is full.  If so, return an error.
; If not, add our item to the list and bump up the list count.

		inc	ax		;We're adding an item.
		cmp	ax, $$$$_MaxLstSz
		jae	ListIsFull
		mov	fs:[bx].Lst.count, ax

; Insert the item pointed at by es:di into the list:

		shl	si, 2
		shl	ax, 2
		mov	ecx, fs:[bx].Lst.Ptrs[si]
		mov	wp fs:[bx].Lst.ptrs[si], di
		mov	wp fs:[bx].Lst.ptrs[si+2], es

; The following loop moves the remaining pointers down one spot
; in the list.

MoveLp:		add	si, 4
		xchg	ecx, fs:[bx].Lst.ptrs[si]
		cmp	si, ax
		jb	MoveLp

		pop	ecx
		pop	ax
		clc
		ret

ListIsFull:	pop	ecx
		pop	ax
		stc
		ret
List_Insert	endp



; List_Remove-	fs:bx points at a list variable.
;		si contains an index into the list.
;
;		This code deletes the specified object from the list.

List_Remove	proc
		push	si
		push	cx
		push	eax

; First, check to see if there are any items in the list and make
; sure we're deleting an object which is actually there.

		mov	cx, fs:[bx].Lst.count
		cmp	si, cx
		jae	RmvDone

; Drop the count by one, since we're deleting a list element.

		dec	fs:[bx].Lst.count

; Compute how many objects we have to move over the top of the deleted
; item.

		sub	cx, si

; Move the remaining objects

		shl	si, 2			;Index into dword array.
RmvLoop:	mov	eax, fs:[bx].Lst.ptrs[si+4]
		mov	fs:[bx].Lst.ptrs[si], eax
		add	si, 4
		loop	RmvLoop

RmvDone:	pop	eax
		pop	cx
		pop	si
		ret
List_Remove	endp

cseg		ends
		end