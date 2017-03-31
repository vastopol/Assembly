		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

wp		textequ	<word ptr>

ListSz		macro	TheNode
		exitm	<sizeof TheNode - sizeof Node>
		endm


dseg		segment	para public 'data'

StrNode		struct
		node	{}
StrPtr		dword	?
StrNode		ends


TempStrPtr	dword	?

StrListPtr	dword	StrList
StrList		list	{ListSz(StrNode)}

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; The following code reads ten lines of text from the keyboard
; and appends each line to the end of list1.  This code doesn't
; bother checking for any insertion errors.

		mov	cx, 10
MakeList1:	print
		byte	"Enter line ",0
		mov	ax, cx
		puti
		mov	al, ':'
		putc
		getsm


; Append this new node to the end of the list.

		mov	wp TempStrPtr, di	;Save node data in a
		mov	wp TempStrPtr+2, es	; temp spot.
		ldxi	TempStrPtr
		les	di, StrListPtr		;Ptr to list var.
		AppendLastm

		loop	MakeList1

; Insert a new line before the fifth line in the list:

		print
		byte	"Line to insert: ",0
		getsm
		mov	wp TempStrPtr, di
		mov	wp TempStrPtr+2, es
		ldxi	TempStrPtr
		les	di, StrListPtr
		mov	cx, 4
		Insertm

; The following code steps through each item in the list until it
; reaches the end of the list (when GetItem returns NIL).

		mov	cx, 1
		SetCur
PrintList1:	push	es
		push	di
		mov	es, dx
		les	di, es:[si].StrNode.StrPtr
		puts
		putcr
		pop	di
		pop	es
		NextNode
		jnc	PrintList1

; The following code removes several items from the list and then prints
; it again:

		mov	cx, 4		;Removes fourth line.
		Remove
		mov	cx, 6		;Removes seventh line.
		Remove
		mov	cx, 8		;Removes tenth line.
		Remove
		mov	cx, 1		;Removes first line.
		Remove


		mov	cx, 1
		SetCur
PrintList2:	push	es
		push	di
		mov	es, dx
		les	di, es:[si].StrNode.StrPtr
		puts
		putcr
		pop	di
		pop	es
		NextNode
		jnc	PrintList2

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends



; Allocate a reasonable amount of space for the stack (8k).
; Note: if you use the pattern matching package you should set up a
;	somewhat larger stack.

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


; zzzzzzseg must be the last segment that gets loaded into memory!
; This is where the heap begins.

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
