		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list

		include	fpgm.a

; DESCRIBE.ASM-	This file contains the routines which print room and
;		inventory descriptions.

cseg		segment	para public 'code'
		assume	ds:dseg

; LongDesc- Long description of an item.
; DI points at an item- Give the long description of it.

LongDesc	proc
		push	di
		test	di, di
		jz	NoDescription
		mov	di, [di].item.LongDesc
		puts
		putcr
NoDescription:	pop	di
		ret
LongDesc	endp


; ShortDesc- Print the short description of an object.
; DI points at an item (possibly NULL).  Print the short description for it.

ShortDesc	proc
		push	di
		test	di, di
		jz	NoDescription
		mov	di, [di].item.ShortDesc
		puts
		putcr
NoDescription:	pop	di
		ret
ShortDesc	endp




; Describe: 	"CurRoom" points at the current room.  Describe it and its
;		contents.

Describe	proc
		push	es
		push	bx
		push	di
		mov	di, ds
		mov	es, di

		mov	bx, CurRoom
		mov	di, [bx].room.Description
		print
		byte	"You are currently ",0
		puts
		putcr
		print
		byte	"Here you find the following:",cr,lf,0

ItemCnt		=	0
		repeat	MaxWeight
		mov	di, [bx].room.ItemList[ItemCnt]
		call	LongDesc

ItemCnt		=	ItemCnt+2
		endm


		pop	di
		pop	bx
		pop	es
		ret
Describe	endp

cseg		ends
		end

