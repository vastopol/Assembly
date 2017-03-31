		option		segment:use16
		.386

		.xlist
		include		consts.a
		include		memory.a	;Cannot use stdlib.a
		include		stdin.a		; because stdlib defines
		include		stdout.a	; a list data structure
		includelib	stdlib.lib	; already.
		.list


		include		MyList.a


dseg		segment	para public 'data'

List1Adrs	dword	List1
List1		list	{}


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
		byte	"Enter line: ",0
		getsm
		mov	si, 0FFFFh		;Force append.
		lfs	bx, List1Adrs		;Append to List1.
		InsertItem
		loop	MakeList1

; Insert a new line before the fifth line in the list:

		print
		byte	"Line to insert: ",0
		getsm
		mov	si, 4
		InsertItem

; The following code steps through each item in the list until it
; reaches the end of the list (when GetItem returns NIL).

		mov	cx, 0
PrintList1:	mov	di, cx
		GetItem
		cmp	di, 0		;At end of list?
		je	EndOfList
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
