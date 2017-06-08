; CIRCQ.ASM-	Implementation of a circular queue in assembly language.
;
;	This code maintains a circular queue of integers


		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

; This queue's length must be an even power of two bytes long
; because the code uses and AND instruction to wrap around the
; indices on this array.

InsPtr		word	0
RmvPtr		word	0
Count		word	0

MaxQSize	equ	128
TheQueue	word	MaxQSize dup (0)

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; The circular queue routines:
;
; InitQ initializes the queue variables and empties the circular
; queue.

InitQ		proc
		mov	Count, 0
		mov	InsPtr, 0
		mov	RmvPtr, 0
		ret
InitQ		endp


; InsQ-		Inserts the integer in AX into the circular queue.
;		This routine returns the carry flag clear if it
;		successfully adds the item to the queue.  It comes
;		back with the carry set if the queue is full and
;		it could not insert the item into the queue.

InsQ		proc
		cmp	Count, MaxQSize
		jae	QueueIsFull

		push	bx
		mov	bx, InsPtr
		shl	bx, 1			;Word array index
		mov     TheQueue[bx], ax

; The following tricky code computes
;	InsPtr := (InsPtr+1) mod MaxQSize

		shr	bx, 1			;Because of SHL above
		inc	bx
		and	bx, MaxQSize-1
		mov	InsPtr, bx

		inc	count
		pop	bx
		clc				;No error!
		ret

; If the queue was full, return an error here.

QueueIsFull:	stc
		ret
InsQ		endp


; RmvQ-	This routine removes the item at the front of the queue
;	and returns its value in AX.  It returns with the carry
;	flag clear if there was no error.  It returns with the
;	carry flag set if the queue was empty.

RmvQ		proc
		cmp	count, 0
		je	QueueIsMT
		push	bx
		mov	bx, RmvPtr
		shl	bx, 1			;Index into word array
		mov	ax, TheQueue[bx]

; Once again, handle the wrap-around in the queue by using the
; AND instruction to compute the remainder.

		shr	bx, 1			;Restore BX's value
		inc	bx
		and	bx, MaxQSize-1
		mov	RmvPtr, bx
		dec	Count
		pop	bx
		clc
		ret

; If the queue is empty, return an error here:

QueueIsMT:	stc
		ret
RmvQ		endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


;Initialize the queue before we use it.

		call	InitQ

; Place a random number of objects in the queue

		randomize		;Scramble random's seed
		random			;Get random # into AX
		and	ax, 7fh		;Limit it to 128 values
		inc	ax		;At least one value!
		mov	cx, ax
FillQ:		random
		call	InsQ
		print
		byte	"Entering ",0
		puti
		putcr
		loop	FillQ

; Okay, now empty the queue and print the values.  Use the
; error return to determine when we've processed all the
; values.

MTQ:		call	RmvQ
		jc	Quit
		puti
		putcr
		jmp	MTQ



Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
