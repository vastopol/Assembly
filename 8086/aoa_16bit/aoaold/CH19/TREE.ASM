; TREE.ASM -	Implementation module for the tree data
;		structure/class.

		option		segment:use16
		.386

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		include		tree.a
		.list

LLink		equ	<$$$$_LLink>
RLink		equ	<$$$$_RLink>

wp		equ	<word ptr>


cseg		segment	para public 'code'
		assume	cs:cseg

; Note: The programmer using the tree class must supply the Compare
;	method for the tree class.  This is a generic class, it does
;	not know how to compare specific values.
;
;	The real compare method should expect two far pointers in
;	ds:bx (the current node) and es:si (the node under consid-
;	eration).  It should compare the data pointed at by es:si
;	against the data value in the node at ds:bx and it should
;	return AX = -1, 0, or 1, for less than, equal, or greater
;	than.

$$$$_CompareError proc	near
		print
		byte	"Error- Programmer must overload compare "
		byte	"method for TREE ADT.",cr,lf,0
		xor	ax, ax			;Return equal!
		ret	8
$$$$_CompareError endp


; $$$$_pInsert- This is the method which the class will actually
;		call to insert a node.
;
;		This code stacks up registers which do not need to
;		be preserved across recursive calls and then calls
;		the Insert routine to do the actual work.  On entry,
;		ES:SI points at the node to insert, FS:DI points at
;		the tree variable.

$$$$_pInsert	proc	near
		push	ds
		push	es
		push	si
		push	fs
		push	di
		push	ax

; Init the new node's link fields, just in case.

		mov	dword ptr es:[si].TreeNode.RLink, 0
		mov	dword ptr es:[si].TreeNode.LLink, 0

		push	fs		;Pass ptr to tree here.
		push	di
		call	treeInsert

		pop	ax
		pop	di
		pop	fs
		pop	si
		pop	es
		pop	ds
		ret
$$$$_pInsert	endp


; treeInsert-   ES:SI points at the node to insert, the single
;		far ptr passed on the stack contains the address
;		of the pointer to the tree into which we want to
;		insert the node.  This routine can scramble
;		fs, di, ds, and ax

TreePtrParm	textequ	<dword ptr [bp+4]>

treeInsert	proc
		push	bp
		mov	bp, sp
		lds	bx, TreePtrParm
		cmp	dword ptr ds:[bx], 0	;NIL Ptr?
		jne	NotEmptyTree

; If the tree pointer is NIL, add the new node at this point
; and then return to the caller:

		mov	ds:[bx], si
		mov	ds:[bx+2], es
		pop	bp
		ret	4

; If the tree pointer is not NIL, then search for the appropriate
; place to insert the node.

NotEmptyTree:	lds	bx, ds:[bx]	;Dereference for compare.
		push	es
		push	si
		add	si, sizeof TreeNode	;Skip to data.
		call    fs:[di].tree.compare
		pop	si
                pop	es
		cmp	ax, 0
		jl	InsertAtLeft
		jg	InsertAtRight

; Since we're only allowing one copy of a node in the tree, ignore
; all duplicates.

		pop	bp
		ret	4

; If the node to insert's value is less than the current node's
; value, insert the node off the LLink.  There are two cases-
; LLink is currently NIL, in which case we just tag the new
; node on there, or LLink is non-nil, in which case we call
; Insert recursively to manage the task.

InsertAtLeft:	cmp     dword ptr ds:[bx].treenode.LLink, 0
		je	InsertLeftHere
		push	ds
		lea	bx, dword ptr ds:[bx].treenode.LLink
		push	bx
		call	treeInsert
		pop	bp
		ret	4

InsertLeftHere:	mov	wp ds:[bx].treenode.LLink, si
		mov	wp ds:[bx].treenode.LLink+2, es
		pop	bp
		ret	4

; Okay, same story as above, except this is off the right side.

InsertAtRight:	cmp	dword ptr ds:[bx].treenode.RLink, 0
		je	InsertRtHere
		push	ds
		lea	bx, dword ptr ds:[bx].treenode.RLink
		push	bx
		call	treeInsert
		pop	bp
		ret	4

InsertRtHere:	mov	wp ds:[bx].treenode.RLink, si
		mov	wp ds:[bx].treenode.RLink+2, es
		pop	bp
		ret	4

treeInsert	endp





; GrabSub(var TreePtr:PtrToNode):PtrToNode;
;
; Finds the maximum value in the left subtree of TreePtr.
; Removes that node from the tree and returns a pointer to
; that node in DS:BX.
;
; TreePtr is passed on the stack.

GSTreePtr	equ	<dword ptr [bp+4]>

GrabSub		proc
		push	bp
		mov	bp, sp

		lds	bx, GSTreePtr
		cmp	dword ptr ds:[bx].TreeNode.RLink, 0
		je	GrabThisGuy

; If the RLink is not NIL, we haven't found the largest guy
; on the left hand side of some subtree.  Recursively continue
; the search here.

		push	dword ptr ds:[bx].TreeNode.RLink
		call	Grabsub
		pop	bp
		ret	4

; If the RLink is nil, then the current node is the one we want
; to delete.

GrabThisGuy:	pop	bp
		ret	4
GrabSub		endp



; $$$$_pDelete-	This routine deletes a node from the tree.
;		On entry, fs:di points at a tree variable
;		and es:si points at the node to delete.

$$$$_pDelete	proc	near
		push	ds
		push	bx
		push	eax

		cmp	dword ptr fs:[di], 0	;Empty (sub)tree?
		je	DeleteIsDone

		lds	bx, fs:[di]		;Get ptr to tree.

; If either (or both) links are NIL, this is an easy case:

		cmp	dword ptr ds:[bx].TreeNode.LLink, 0
		jne	LeftNotNIL
		mov	eax, ds:[bx].TreeNode.RLink
		mov	dword ptr fs:[di], eax
		jmp	DeleteIsDone

LeftNotNIL:	cmp	dword ptr ds:[bx].TreeNode.RLink, 0
		jne	NeitherIsNIL
		mov	eax, ds:[bx].TreeNode.LLink
		mov	dword ptr fs:[di], eax
		jmp	DeleteIsDone

; If neither link is nil, we've got to go find some other node
; to link in over the top of the current node.

NeitherIsNIL:   push	fs
		push	di
		call	GrabSub
		mov	wp fs:[di], bx
		mov	wp fs:[di+2], ds

DeleteIsDone:	pop	eax
		pop	bx
		pop	ds
		ret	4
$$$$_pDelete	endp




; Search-	FS:DI points at a tree variable.
;		ES:SI points at the data to search for.
;		Returns a pointer to the specified node in
;		ES:SI.

$$$$_pSearch	proc	near
		push	ds
		push	ax
		push	bx

		lds	bx, fs:[di]	;Ptr to root node.
		call	Search

		pop	bx
		pop	ax
		pop	ds
		ret
$$$$_pSearch	endp


Search		proc	near
		mov	ax, ds		;See if current node is
		test	ax, ax		; NIL.
		jne	TheresATree
		sub	si, si		;Return NIL for not found.
		mov	es, si
		ret

TheresATree:	call	fs:[di].Tree.compare
		cmp	ax, 0
		jl	TryLeft
		jg	TryRight

; If the data matched, return a pointer to the current node.

		mov	si, ds
		mov	es, si
		mov	si, bx
		ret

; If the data is less than the current node, search along the
; left link of the tree.  Note: since this is "tail recursion"
; there is no need to make a recursive call here.  We can
; trace through the tree iteratively rather than recursively.

TryLeft:	lds	bx, ds:[bx].TreeNode.LLink
		jmp	Search

; Ditto from above for data greater than the current node (search
; along the right link).

TryRight:	lds	bx, ds:[bx].TreeNode.RLink
		jmp	Search
Search		endp



; Iterators for the pre-order, in-order, and post-order
; traversals.  On entry to each of these guys, fs:di points at
; a root node.  They yield a pointer to each node in es:si.
; Note there are no static links manipulated here!


Yield		macro
		mov	dx, [bp+2]		;Place to yield back to.
		push	bp			;Save Iterator link
		mov	bp, [bp]		;Get caller's D.L.
		call	dx			;Push resume address and rtn.
		pop	bp			;Restore ptr to our A. R.
		endm



$$$$_pPreOrder	proc
		push	bp
		mov	bp, sp
		push	ax
		push	fs
		push	di

		mov	ax, fs			;If the tree ptr is
		test	ax, ax			; NIL, immediately
		je	POFail			; fail.

		lfs	di, fs:[di].TreeNode.LLink
		push	offset PreFail1
		call	$$$$_pPreOrder
		yield
		ret

PreFail1:	pop	si			;We need to yield
		pop	es			; the root node at
		push	es			; this point.
		push	si
		yield

		pop	di
		pop	fs
		push	fs
		push	di
		lfs	di, fs:[di].TreeNode.RLink
		push	offset	POFail
		call	$$$$_pPreOrder
		yield
		ret

POFail:		pop	di
		pop	fs
		pop	ax
		pop	bp
		add	sp, 2			;Skip return adrs.
		ret				;Ret to fail adrs.
$$$$_pPreOrder	endp




$$$$_pInOrder	proc
		push	bp
		mov	bp, sp
		push	ax
		push    fs
		push	di

		mov	ax, fs			;See if NIL ptr.
		test	ax, ax                  ;Immediately fail
		je	IOFail			; if NIL.


; First, yield the root node:

		mov	si, fs
		mov	es, si
		mov	si, di
		yield

; Now process the data along the left link:

		pop	di
		pop	fs
		push	fs
		push	di
		lfs	di, fs:[di].TreeNode.LLink
		push	offset IOFail1
		call	$$$$_pInOrder
		yield
		ret

IOFail1:
		pop	di
		pop	fs
		push	fs
		push	di
		lfs	di, fs:[di].TreeNode.RLink
		push	offset	IOFail
		call	$$$$_pInOrder
		yield
		ret

IOFail:		pop	di
		pop	fs
		pop	ax
		pop	bp
		add	sp, 2			;Skip return adrs.
		ret				;Ret to fail adrs.
$$$$_pInOrder	endp



$$$$_pPostOrder	proc
		push	bp
		mov	bp, sp
		push	ax
		push	fs
		push	di

		mov	ax, fs			;If the tree ptr is
		test	ax, ax			; NIL, immediately
		je	PostFail		; fail.

		lfs	di, fs:[di].TreeNode.RLink
		push	offset PostFail1
		call	$$$$_pPostOrder
		yield
		ret

PostFail1:	pop	si			;We need to yield
		pop	es			; the root node at
		push	es			; this point.
		push	si
		yield

		pop	di
		pop	fs
		push	fs
		push	di
		lfs	di, fs:[di].TreeNode.LLink
		push	offset	PostFail
		call	$$$$_pPostOrder
		yield
		ret


PostFail:	pop	di
		pop	fs
		pop	ax
		pop	bp
		add	sp, 2			;Skip return adrs.
		ret				;Ret to fail adrs.
$$$$_pPostOrder	endp



$$$$_pBreadth1st	proc
;
;	This routine is left as an exercise.
;	See the exercises at the end of the chapter for more details.
;
		add	sp, 2			;Skip Return Adrs.
		ret
$$$$_pBreadth1st	endp



cseg            ends
		end
