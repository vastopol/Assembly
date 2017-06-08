		option		segment:use16
		.386

		.xlist
		include		consts.a
		include		memory.a	;Cannot use stdlib.a
		include		stdin.a		; because stdlib defines
		include		stdout.a	; a list data structure
		includelib	stdlib.lib	; already.
		.list


		include		MyList2.a

; Create a local version of a linked list node by inheriting the
; fields from the linked list node class.

MyNode		struct
		node	{}
StrPtr		dword	?
MyNode		ends

dseg		segment	para public 'data'

List1Adrs	dword	List1
List1		dword	0		;Initially empty list.


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

; Construct a new node to hold the character string pointer.

		push	cx
		push	es
		push	di
		mov	cx, sizeof MyNode
		malloc
		pop	word ptr es:[di].MyNode.StrPtr
		pop	word ptr es:[di+2].MyNode.StrPtr
		pop	cx

; Append this new node to the end of the list.

		mov	si, 0FFFFh		;Force append.
		lfs	bx, List1Adrs		;Append to List1.
		InsertItem
		loop	MakeList1

; Insert a new line before the fifth line in the list:

		print
		byte	"Line to insert: ",0
		getsm
		mov	ax, di
		mov	dx, es
		mov	cx, sizeof MyNode
		malloc
		mov	word ptr es:[di].MyNode.StrPtr, ax
		mov	word ptr es:[di+2].MyNode.StrPtr, dx
		mov	si, 4
		InsertItem

; The following code steps through each item in the list until it
; reaches the end of the list (when GetItem returns NIL).

		mov	cx, 0
PrintList1:	mov	di, cx
		GetItem
		cmp	di, 0				;At end of list?
		je	EndOfList
		les	di, es:[di].MyNode.StrPtr	;Get ptr to string.
		puts
		putcr
		inc	cx
		jmp	PrintList1

EndOfList:

; The following code removes several items from the list and then prints
; it again:

		mov	si, 3		;Removes fourth line.
		RemoveItem
		mov	si, 5		;Removes seventh line.
		RemoveItem
		mov	si, 7		;Removes tenth line.
		RemoveItem
		mov	si, 0		;Removes first line.
		RemoveItem

		mov	cx, 0
PrintList2:	mov	di, cx
		GetItem
		cmp	di, 0		;At end of list?
		je	EndOfList2
		les	di, es:[di].MyNode.StrPtr	;Get ptr to string.
		puts
		putcr
		inc	cx
		jmp	PrintList2

EndOfList2:


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
