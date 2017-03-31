; ListStuf.asm-	This file contains all the routines which manipulate the
;		lists "Randy's Riverside Rally" uses.

		include	fpgm.a
cseg		segment	para public 'code'

; CheckPresence-
;		BX points at an item.  DI points at an item list.  This
;		routine checks to see if that item is present in the
;		item list.  Returns Carry set if item was found,
;		clear if not found.

CheckPresence	proc

ItemCnt		=	0
		repeat	MaxWeight
		cmp	bx, [di+ItemCnt]
		je	GotIt

ItemCnt		=	ItemCnt+2
		endm

		clc
		ret

GotIt:		stc
		ret
CheckPresence	endp


; RemoveItem-	BX contains a pointer to an item.  DI contains a pointer
;		to an item list which contains that item.  This routine
;		searches the item list and removes that item from the
;		list.

RemoveItem	proc

ItemCnt		=	0
		repeat	MaxWeight
		local	NotThisOne
		cmp	bx, [di+ItemCnt]
		jne	NotThisOne
		mov	word ptr [di], 0
		ret
NotThisOne:
ItemCnt		=	ItemCnt+2
		endm

		ret
RemoveItem	endp


; InsertItem-	BX contains a pointer to an item, DI contains a pointer to
;		and item list.  This routine searches through the list for
;		the first empty spot and copies the value in BX to that point.
;		It returns the carry set if it succeeds.  It returns the
;		carry clear if there are no empty spots available.

InsertItem	proc

ItemCnt		=	0
		repeat	MaxWeight
		local	NotThisOne
		cmp	word ptr [di+ItemCnt], 0
		jne	NotThisOne
		mov	[di], bx
		stc
		ret
NotThisOne:
ItemCnt		=	ItemCnt+2
		endm

		clc
		ret
InsertItem	endp
cseg		ends
		end



