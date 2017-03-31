		option		segment:use16
		.386

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		include		tree.a
		.list



dseg		segment	para public 'data'

IntTreeNode	struct
		TreeNode	{}
Integer		word		0
IntTreeNode	ends

MyTreePtr	dword		MyIntTree
MyIntTree	tree		{0,CmpInts}

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; CmpInts-	This function compares the integer pointed at by es:si to
;		the value in the node ds:bx.  It returns -1, 0, or 1 in
;		the AX register if (es:[si] < ds:[bx].Integer),
;		(es:[si] = ds:[bx].Integer), or (es:[si] > ds:[bx].Integer),
;		respectively.  This routine overrides the compare method
;		in the tree ADT/class for integer trees.

CmpInts		proc
		mov	ax, es:[si]
		sub	ax, ds:[bx].IntTreeNode.Integer
		jl	SetM1
		jg	Set1
		ret

SetM1:		mov	ax, -1
		ret

Set1:		mov	ax, 1
		ret
CmpInts		endp



; MakeIntNode-	AX contains an integer value.  This procedure creates a
;		new node and stores AX into it.  ES:SI contains a pointer
;		to the new node upon return.

MakeIntNode	proc
		push	cx
		push	di

		mov	cx, sizeof IntTreeNode
		malloc
		jc	BadMIN
		mov     es:[di].IntTreeNode.Integer, ax
BadMIN:		mov	si, di
		pop	di
		pop	cx
		ret
MakeIntNode	endp

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; Okay, build a tree with 31 nodes in it.  Pick the integer data for
; the nodes at random.

		randomize
		mov	cx, 31
BuildTree:	random
		and	ax, 3ffh		;Clip to range 0..1023.
		call	MakeIntNode
		jc	BadTree
		lfs	di, MyTreePtr
		call	MyIntTree.insertNode
		loop	BuildTree

; Okay, traverse the tree:

		print
		byte	"Preorder traversal: ",cr,lf,0

		push	offset QuitPre
		lfs	di, MyIntTree.RootNode
		call	MyIntTree.preorder
		mov	ax, es:[si].IntTreeNode.Integer
		mov	cx, 4
		putisize
		mov	al, ' '
		putc
		ret

QuitPre:

		print
		byte	cr,lf,lf
		byte	"Postorder traversal: ",cr,lf,0

		push	offset QuitPost
		lfs	di, MyIntTree.RootNode
		call	MyIntTree.postorder
		mov	ax, es:[si].IntTreeNode.Integer
		mov	cx, 4
		putisize
		mov	al, ' '
		putc
		ret

QuitPost:

		print
		byte	cr,lf,lf
		byte	"Inorder traversal: ",cr,lf,0

		push	offset QuitIn
		lfs	di, MyIntTree.RootNode
		call	MyIntTree.inorder
		mov	ax, es:[si].IntTreeNode.Integer
		mov	cx, 4
		putisize
		mov	al, ' '
		putc
		ret

QuitIn:

		jmp	Quit

BadTree:	print
		byte	"Memory management error building tree",cr,lf,0

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp
cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
