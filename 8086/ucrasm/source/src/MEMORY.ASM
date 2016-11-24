		extrn	PSP:word
;
StdGrp		group	StdData, StdLib
;
StdData		segment	para public 'sldata'
;
; Memory allocation routines: MemInit, malloc, and free.
;
;
; Local variables:
;
StartOfHeap	dw	?
SizeOfHeap	dw	?
FreeSpace	dw	?
;
; Memory manager data structure:
;
;		option	oldstructs
mmstruct	struc
blksize		dw	?
bwdptr		dw	?
fwdptr		dw	?
refcnt		dw	?
freebwdptr	dw	?		;Only if in the free list.
freefwdptr	dw	?		;Only if in the free list.
mmstruct	ends
;
; When using es and ds as pointers into the heap, the following equates
; come in handy.
;
esptr		equ	word ptr es:[0]
dsptr		equ	word ptr ds:[0]
;
NIL		equ	0
StdData		ends
;
;
;
;
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp, ds:nothing
;
;
; MemInit- Initializes the memory manager.
;
;	On entry- DX contains the number of paragraphs of memory to reserve
;		  for other programs.  The default (in shell.asm) is 0.  If
;		  you intend to execute other programs from the program you're
;		  writing, you will have to reserve an appropriate amount of
;		  space for that program.  If you attempt to reserve too
;		  much space, then this code splits the available free memory
;		  in half and gives half to the heap and reserves half for
;		  other programs.  If this is desirable, simply set DX to
;		  0ffffh before calling MemInit.
;
;	On Exit-  No error if carry is clear.  In such a case, CX contains
;		  the number of paragraphs of memory actually allocated.
;		  AX contains the starting segment address of the free
;		  memory block.
;
;		  If carry is set, then an error occurred, AX contains the
;		  error code (DOS).
;
; WARNING: for this routine to work properly, the calling program has to
; declare (and initialize) a word variable by the name PSP which contains
; the program's program segment prefix value.  Furthermore, the last segment
; in the program must be "zzzzzzseg" and this guy should NOT contain any
; valid data.
;
		public	sl_MemInit
sl_MemInit	proc	far
		push	bx
		push	dx
		push	es
;
; Compute program size, in paragraphs:
;
		mov	ax, seg PSP
		mov	es, ax
		mov	bx, es:PSP
		mov	es, bx
		mov	ax, seg zzzzzzseg
		sub	ax, bx
		inc	bx			;Safety margin
		inc	bx
		mov	ah, 4ah			;Memory block resize opcode
		int	21h
;
; Now ask for a ridiculous amount of memory so we can find out how much is
; available.
;
		mov	bx, 0ffffh
		mov	ah, 48h			;Alloc block opcode
		int	21h
;
;
; Allocate storage for the heap.
;
		cmp	bx, dx			;See if DX is too large.
		ja	GoodHeap
		shr	bx, 1			;Use half remaining space.
		jmp	short SetNewAlloc
;
GoodHeap:	sub	bx, dx			;Make room for other apps.
SetNewAlloc:	cmp	bx, 10h			;Make sure there is some room.
		jbe	ErrorAlloc2
		mov	ah, 48h			;Alloc block opcode
		int	21h
		jc	ErrorAlloc		;Shouldn't happen, but...
;
; Okay, we've just allocated the block, now set up our own local variables
; so we can keep track of the data.
;
		mov	StdGrp:StartOfHeap, ax	;Save pointer to memory.
		mov	StdGrp:FreeSpace, ax	;Save pointer to 1st free blk.
		mov	StdGrp:SizeOfHeap, bx	;Size of heap in paragraphs.
		mov	es, ax			;Init pointer to heap.
                xor	ax, ax
		mov	esptr.blksize, bx	;Size of this block (paras).
		mov	esptr.bwdptr, ax  	;Back pointer is NIL.
		mov	esptr.fwdptr, ax  	;Fwd pointer is NIL.
		mov	esptr.refcnt, ax  	;Reference Count is zero.
		mov	esptr.freebwdptr, ax 	;Free list bwd ptr is NIL.
		mov	esptr.freefwdptr, ax 	;Free list fwd ptr is NIL.
		mov	cx, bx			;Return size in CX
		mov	ax, StdGrp:StartOfHeap
		clc
		jmp	MemInitDone
;
ErrorAlloc2:	mov	ax, 8			;Insufficient memory error.
ErrorAlloc:	stc
MemInitDone:	pop     es
		pop	dx
		pop	bx
		ret
sl_MemInit	endp
;
;
;
;
;============================================================================
;
;    *     *      *      *        *         *****       *****
;    **   **     * *     *        *        *     *     *     *
;    * * * *    *   *    *        *        *     *     *
;    *  *  *    *****    *        *        *     *     *
;    *     *    *   *    *	  *        *     *     *
;    *     *    *   *    *        *        *     *     *     *
;    *     *    *   *    *****    *****     *****       *****
;
;============================================================================
;
;
; malloc-  On entry, CX contains a byte count.  Malloc allocates a block
;	   of storage of the given size and returns a pointer to this block
;	   in ES:DI.  The value in ES:DI is always normalized, so you can
;	   compare pointers allocated via malloc as 32-bit values.  Note
;	   that malloc always allocates memory in paragraph chunks.
;	   Therefore, this routine returns the actual number of bytes of
;	   memory allocated in the CX register (this may be as much as 15
;	   greater than the actual number asked for).
;
;	   Malloc returns carry clear if it allocated the storage without
;	   error.  It returns carry set if it could not find a block large
;	   enough to satisfy the request.
;
;
; Data structure for memory allocation blocks:
;
; offset:
;
;   0	Size of Blk
;   2   Back link
;   4   Fwd Link
;   6   Reference Count
;   8   Data, if this block is allocated, prev link if on free list.
;  10	Data, if this block is allocated, next link if on free list.
;
;
;
		public	sl_malloc
sl_malloc	proc	far
		push	ax
		push	si
		push	ds
;
; Convert byte count to paragraph count, since we always allocate whole
; paragraphs.
;
		add	cx, 8			;We have six bytes of overhead!
		rcr	cx, 1			;Use rcr because of add above.
		adc	cx, 0
		shr	cx, 1
		adc	cx, 0
		shr	cx, 1
		adc	cx, 0
		shr	cx, 1
		adc	cx, 0
;
; Go find a block in the free list which is large enough.
;
; Uses the following algorithm:
;
;
		cmp	StdGrp:FreeSpace, 0		;See if no free space.
		jz	MemoryFull
		mov	ds, StdGrp:FreeSpace
		mov	ax, ds			;In case first block is it.
FindBlk:	cmp	cx, dsptr.blksize	;See if blk is large enuf.
		jbe	FoundBlk		;Go for it!
		mov 	ax, dsptr.freefwdptr	;Get ptr to next free block.
		mov	ds, ax			;Set up pointer.
		or	ax, ax			;See if NIL
                jnz	FindBlk			;Repeat until NIL.
;
; If we drop down here, we've got some big problems.
;
MemoryFull:	stc
		pop	ds
		pop	si
		pop	ax
		mov	es, StdGrp:StartOfHeap	;In case they use this ptr
		mov	di, 8			; anyway.
		ret
;
; When we come down here, we've found a block large enough to satisfy the
; current memory request.  If necessary, split the block up into two
; pieces and return the unused half back to the free pool.
;
FoundBlk:       jne	SplitBlock
;
;
;
;***************************************************************************
; Exact fit, remove this guy from the free list and go for it!
;***************************************************************************
;
; There are four cases to deal with if this is an exact fit:
;
;	1) The block we're allocating is the first block in the free list.
;	   In this case, FreeSpace points at this block and the freebwdptr
;	   entry is NIL.
;
;	2) The block we're allocating is neither the first or last in the
;	   free list.
;
;	3) The block we're allocating is the last block in the free list.
;	   In this case, the freefwdptr will be NIL.
;
;	4) The block is both the first and last (i.e., only) block in the
;	   the free list.
;
; At this point, DS points at the block we're going to allocate.
;
		mov	ax, dsptr.freefwdptr	;Pointer to next free block.
		cmp	dsptr.freebwdptr, NIL	;First item in list?
		jnz	NotFirst
;
; Case (1) and (4) drop down here.
;
; If this is the first free block in the free link list, point FreeSpace
; beyond this guy rather than going through the usual linked list stuff.
;
; AX contains a pointer to the next free block (after this one) if it exists.
; DS points at the current free block.
;
; Since we are removing the first free block, we need to update the FreeSpace
; pointer so that it points at the next free block in the free block list.
;
		mov	StdGrp:FreeSpace, ax	;Note: AX may be NIL if case (4).
;
; See if there is another block after this one.  If not (case 4) then jump
; off to FixThisBlk.
;
		or	ax, ax			;Is there another free blk?
		jz	FixThisBlk		;If not, don't patch next adrs.
;
; Case (1), only, down here.  The current block is the one we want and
; there is another free block after this one.  AX Points at the next free
; block.  DS points at the current block.
;
		mov	es, ax           	;Point ES at next free block.
		mov	esptr.freebwdptr, NIL	;Set next guy's back link to NIL.
		jmp	short FixThisBlk
;
; If the current block is not the first free block in the free block list
; handle it down here. This corresponds to cases 2 or 3.  On entry, DS
; points at the current block, AX points at the next free block (if present).
;
NotFirst:	mov	es, dsptr.freebwdptr	;Get ptr to prev blk.
		mov	esptr.freefwdptr, ax	;Skip over current blk.
		mov	ax, es			;Load AX with prev blk adrs.
;
; Now we need to figure out if there is a next free block (is this case 2?).
;
		cmp	dsptr.freefwdptr, NIL
		jz	FixThisBlk
;
; Definitely Case (2) here.  Patch the next free block's prev field with
; the address of the previous block.
;
		mov	es, dsptr.freefwdptr	;Point ES at next block.
		mov	esptr.freebwdptr, ax	;Save link to prior block.
;
; All four cases converge down here to clean up things and store the
; overhead info for the newly allocated block.
;
FixThisBlk:	mov	dsptr.blksize, cx	;Save its size.
		mov	dsptr.refcnt, 1		;Reference count = 1.
		mov	di, 8			;Pointer to data area.
		mov	ax, ds
		mov	es, ax
		shl	cx, 1			;Convert paragraph size to
		shl	cx, 1			; bytes.
		shl	cx, 1
		shl	cx, 1
		pop	ds
		pop	si
		pop	ax
		clc
		ret
;
;****************************************************************************
; The current free block is bigger than we need, SPLIT it in half down here.
;****************************************************************************
;
;
; If allocating this block splits a free block in half, we handle that
; down here.
;
SplitBlock:     mov	ax, ds			;Get start of block.
		add	ax, dsptr.blksize	;Add in size of block.
		sub	ax, cx			;Subtract part we're keeping.
		mov	es, ax			;Point at data block.
		mov	esptr.blksize, cx	;Save size of block
		mov	esptr.bwdptr, ds	;Save back pointer.
		mov	esptr.refcnt, 1		;Init reference count.
		mov	ax, dsptr.fwdptr	;Get prev fwd ptr.
		mov	dsptr.fwdptr, es	;Save new fwd point in free blk.
		mov	esptr.fwdptr, ax	;New forward pointer for us.
		mov	si, es			;Save ptr to this blk.
		mov	es, ax			;Point es at last blk.
		mov	esptr.bwdptr, si	;Chain it in properly.
		mov	es, si			;Restore so we can return it.
		mov	ax, dsptr.blksize	;Compute new size of free blk.
		sub	ax, cx
		mov	dsptr.blksize, ax
		mov	di, 8			;Init pointer to data.
		shl	cx, 1			;Convert paragraph size to
		shl	cx, 1			; bytes.
		shl	cx, 1
		shl	cx, 1
		pop	ds
		pop	si
		pop	ax
		clc
		ret
;
sl_malloc	endp
;
;
;
;===========================================================================
;
;  ******     *****       ******     ******
;  *          *    *      *          *
;  *          *    *      *          *
;  ****       * ***       ****       ****
;  *          *  *        *          *
;  *          *   *       *          *
;  *          *    *      ******     ******
;
;===========================================================================
;
; Free-	Returns a block of storage to the free list.
;
; On Entry-	ES:DI points at the block to free.
; On Exit-	Carry is clear if free was okay, set if invalid pointer.
;
;
		public	sl_free
sl_free		proc	far
		push	ax
		push	si
		push	ds
		push	es
		mov	si, di
;
; See if this is a valid pointer:
;
		cmp	si, 8
		jne	BadPointer
		mov	si, es			;Make seg ptr convenient.
		mov	ds, StdGrp:StartOfHeap
		cmp	si, StdGrp:StartOfHeap	;Special case if first block.
		jne	Not1stBlock
;
; The block the user wants to free up is the very first block.  Handle that
; right here.
;
		cmp	dsptr.refcnt, 0
		je	BadPointer
		dec	dsptr.refcnt		;Decrement reference count.
		jnz	QuitFree		;Done if other references.
;
; Call coalesce to possibly join this block with the next block.  We do not
; have to check to see if this call joins the current block with the prev
; block because the current block is the very first block in the memory
; space.
;
		call	Coalesce
;
; Adjust all the pointers as appropriate:
;
		mov	dsptr.freebwdptr, NIL
		mov	ax, StdGrp:FreeSpace	;Get and set up the fwd ptr.
		mov	dsptr.freefwdptr, ax
		mov	es, StdGrp:FreeSpace
		mov	esptr.freebwdptr, ds	;Set up other back pointer.
		mov	StdGrp:FreeSpace, ds	;Fix FreeSpace.
		jmp	short QuitFree
;
;
BadPointer:	stc
		jmp	short Quit2
;
QuitFree:	clc
Quit2:		pop	es
		pop	ds
		pop	si
		pop	ax
		ret
;
; If this is not the first block in the list, see if we can coalesce any
; free blocks immediately around this guy.
;
Not1stBlock:    cmp	esptr.refcnt, 0
		je	BadPointer
		dec	esptr.refcnt		;Decrement reference count.
		jnz	QuitFree		;Done if other references.
;
		call	Coalesce
		jc	QuitFree
;
; Okay, let's put this free block back into the free list.
;
		mov	ax, StdGrp:FreeSpace
		mov	esptr.freefwdptr, ax	;Set as pointer to next item.
		mov	esptr.freebwdptr, NIL	;NIL back pointer.
		mov	StdGrp:FreeSpace, es
		jmp	QuitFree
;
sl_free		endp
;
;
; Coalesce routine: On entry, ES points at the block we're going to free.
; This routine coalesces the current block with any free blocks immediately
; around it and then returns ES pointing at the new free block.
; This routine returns the carry flag set if it was able to coalesce the
; current free block with a block immediately in front of it.
; It returns the carry clear if this was not the case.
;
;
Coalesce	proc	near
		push	ds
		push	es
;
		mov	ds, esptr.fwdptr		;Get next contiguous block.
		cmp	dsptr.refcnt, 0		;Is that block free?
		jnz	NextBlkNotFree
;
; If the next block is free, merge it into the current block here.
;
; Memory arrangement is currently something like this:
;
;        +------------------------+      +---------+   <-These are dbl links.
;        |                        |      |         |
;   |prevfree|     |CurFreeBlk| |FollowingBlk|   |NextFreeBlk|
;
; We want to wind up with:
;
;
;        +------------------------------------------+   <-These are dbl links.
;        |                                          |
;   |prevfree|     |CurFreeBlk| |FollowingBlk|   |NextFreeBlk|
;
;
; First, merge the current free block and the following block together.
;
		mov	ax, dsptr.blksize		;Get size of next block.
		add	esptr.blksize, ax		; Join the blocks together.
		mov	ax, dsptr.fwdptr
		mov	esptr.fwdptr, ax
		or	ax, ax
		jz	DontSetBwd
		push	ds
		mov	ds, ax
		mov	dsptr.bwdptr, es
		pop	ds
;
; Make sure that there is a |prevfree| block.
;
DontSetBwd:	mov	ax, dsptr.freebwdptr
		or	ax, ax
		jz	SetFreeSpcPtr
;
; prevfree.fwd := following.fwd;
;
		mov	es, dsptr.freebwdptr	;Point ES at previous guy.
		mov	ax, dsptr.freefwdptr
		mov	esptr.freefwdptr, ax	;Skip over current guy.
;
; If the fwd pointer is NIL, no need to continue.
;
		or	ax, ax			;See if end of list.
		jz	NextBlkNotFree
;
; nextfree.bwd := following.bwd (prevfree).
;
		mov	ax, es			;Save ptr to this guy.
		mov	es, dsptr.freefwdptr
		mov	esptr.freebwdptr, ax
		jmp	short NextBlkNotFree
;
; If FollowingBlk is the first free block in the free list, we have to
; execute the following code.
;
SetFreeSpcPtr:  mov	es, dsptr.freefwdptr
		mov	esptr.freebwdptr, NIL
		mov	StdGrp:FreeSpace, es
;
;
;
; After processing the block following this block, or if the next block
; was not free, come down here and check to see if the previous block
; was free.
;
NextBlkNotFree:	pop	es		;Restore pointer to current block.
		push	es
		mov	ax, esptr.bwdptr
		or	ax, ax		;Is it a NIL pointer
		jz	NoPrevBlock
		mov	ds, ax
		cmp     dsptr.refcnt, 0	;Is that block free?
		jnz	NoPrevBlock
;
; Okay, the block in front is free.  Merge the current block into that one.
;
		mov	ax, esptr.blksize
		add	dsptr.blksize, ax
		mov	ax, esptr.fwdptr
		mov	dsptr.fwdptr, ax
		or	ax, ax			;See if there is a next blk.
		jz	NoNextBlk
		mov	es, ax
		mov	esptr.bwdptr, ds
NoNextBlk:	stc
		pop	es
		pop	ds
		ret
;
NoPrevBlock:	clc
		pop	es
		pop	ds
		ret
Coalesce	endp
;
;
;============================================================================
;
; *****      *******       *      *        *         *****       *****
; *    *     *            * *     *        *        *     *     *     *
; *    *     *           *   *    *        *        *     *     *
; *****      *****       *****    *        *        *     *     *
; *  *       *           *   *    *	   *        *     *     *
; *   *      *           *   *    *        *        *     *     *     *
; *    *     *******     *   *    *****    *****     *****       *****
;
;============================================================================
;
;
; REALLOC - This routine expects a pointer in ES:DI and a new size in CX.
;	    If the specified block is larger than the value in CX then
;	    realloc shrinks the size of the block and returns the left over
;	    information to the system heap.  If CX is larger than the speci-
;	    fied block then realloc allocates a new block and copies the
;	    data from the old block to the new block and then frees the
;	    old block.  In any case, realloc returns a pointer to the
;	    (possibly new) block in ES:DI.  Carry=0 on return if no error,
;	    carry=1 on return if there wasn't enough room on the heap to
;	    reallocate a larger block.
;
		public	sl_realloc
sl_realloc	proc	far
		cmp	di, 8			;Is this a realistic pointer?
		jz	DoREALLOC
		stc				;Return with error, if not.
		ret
;
DoREALLOC:	push	ax 
		push	cx
		push	ds
		push	si
;
;
; Convert byte count to paragraph count, since we always allocate whole
; paragraphs.
;
		add	cx, 8			;We have eight bytes of overhead!
		rcr	cx, 1			;Use rcr because of add above.
		adc	cx, 0
		shr	cx, 1
		adc	cx, 0
		shr	cx, 1
		adc	cx, 0
		shr	cx, 1
		adc	cx, 0
;
; See if the new block size is larger or smaller than the old block size.
;
		cmp	cx, esptr.BlkSize
		ja	MakeBigger
;
; New desired size is less than or equal to the current size.  If no more
; than 32 bytes larger, don't even bother with the operation.
;
		inc	cx
		inc	cx
		cmp	cx, esptr.BlkSize
		jae	ReallocDone
		dec	cx
		dec	cx
;
; Okay, the new block size is seriously smaller here.  Turn the last group
; of bytes into a free block.
;
		mov	ax, es			;Get ptr to block
		add	ax, cx			;Add in new length
		mov	ds, ax			;Point at new block.
		mov	ax, esptr.BlkSize	;Compute the size of the
		sub	ax, cx			; new block.
		mov	dsptr.BlkSize, ax	;Save away the link.
		mov	dsptr.bwdptr, es	;Set up back pointer.
		mov	ax, esptr.fwdptr	;Copy old fwd ptr to new
		mov	dsptr.fwdptr, ax	; fwd ptr.
		mov	dsptr.refcnt, 1		;Init reference count to 1.
		mov	esptr.fwdptr, ds	;Set up new fwd ptr.
		mov	esptr.BlkSize, cx	;Set up new length.
		push	es 
		mov	di, 8
		mov	ax, ds
		mov	es, ax
		call	sl_free			;Free the new block.
		mov	di, 8
		pop	es			;Get pointer to original blk
;
ReAllocDone:	pop	si 
		pop	ds 
		pop	cx
		pop	ax
		clc
		ret
;
;
;
; If they had the nerve to want this block larger, come down here and allocate
; a new block, copy the old data to the new block, and then free the old block.
;
;
MakeBigger:	mov	ax, es			;Preserve pointer to old blk.
		mov	ds, ax
		mov	si, di			;Contains "8".
		call	sl_malloc		;Allocate new block.
		jc	BadRealloc
;
; Okay, copy the old block to the new block.  Note that both SI and DI
; contain 8 at this point.  We can make this assumption here because,
; after all, this is the memory manager code and it knows the internal
; representation.
;
		mov	cx, dsptr.BlkSize	;Get original block size
		shl	cx, 1			;Convert from paragraphs
		shl	cx, 1			; to word count.
		shl	cx, 1
		pushf
		cld
	rep	movsw				;Note we're moving words!
		popf
;
; Okay, free up the old block and we're done.
;
		mov	di, 8
		push	es   			;Save ptr to new block.
		mov	ax, ds
		mov	es, ax
		call	sl_free
		clc
		mov	di, 8			;Restore new block ptr.
		pop	es 
		pop	si 
		pop	ds 
		pop	cx 
		pop	ax
		ret
;
BadRealloc:	stc
		pop	si 
		pop	ds 
		pop	cx 
		pop	ax
		ret
sl_realloc	endp
;
;
;
;
;============================================================================
;
;   ********      *        *     ********    ********    *******   *******
;   *       *     *        *     *       *   *       *      *      *      *
;   *       *     *        *     *       *   *       *      *      *      *
;   *       *     *        *     ********    ********       *      *******
;   *       *     *        *     *           *              *      *   *
;   *       *     *        *     *           *              *      *    *
;   *       *     *        *     *           *              *      *     *
;   ********       ********      *           *              *      *      *
;
;============================================================================
;
;
; Dupptr - Bumps up the reference count for a particular pointer by one.
;	   Returns carry = 1 if initial pointer is illegal, returns carry=0
;	   if no error.  Returns pointer in ES:DI.  You must pass the pointer
;	   to increment in ES:DI.
;
		public	sl_DupPtr
sl_DupPtr	proc	far
		cmp	di, 8			;See if this is a valid ptr.
		je	GoodPtr
		stc
		ret
;
GoodPtr:	inc	esptr.refcnt		;Bump up the reference cnt.
		clc
		ret
sl_DupPtr	endp
;
;
;============================================================================
;
; *****   *****   *****   *   *   *   *   *****     *     *****
;   *     *         *     **      *   *   *        * *    *    *
;   *      ***      *     * * *   *****   ***     *****   *    *
;   *         *     *     *  **   *   *   *       *   *   *****
;   *         *     *     *   *   *   *   *       *   *   *
; *****   *****   *****   *   *   *   *   *****   *   *   *
;
;============================================================================
;
; IsInHeap-	Returns carry clear if the pointer passed in es:di is within
;		the heap.  Returns carry set if this pointer is outside the
;		heap.
;
		public	sl_IsInHeap
sl_IsInHeap	proc	far
		push	ax
		push	bx
		mov	bx, es
		mov	ax, StdGrp:StartOfHeap
		cmp	bx, ax
		jb	Outside
		add	ax, StdGrp:SizeOfHeap
		mov	bx, es
		cmp	bx, ax
		ja	Outside
		clc
		pop	bx
		pop	ax
		ret
;
Outside:	stc
		pop	bx
		pop	ax
		ret
sl_IsInHeap	endp
;
;
;
;
;============================================================================
;
; *****   *****   *****	   *****   *****
;   *     *       *    *     *     *    *
;   *      ***    *****      *     *****
;   *         *   *          *     * *
;   *         *   *          *     *  *
; *****   *****   *          *     *   *
;
;============================================================================
;
; IsPtr-	Returns the carry flag clear if es:di points at the beginning
;		of an allocated block in the heap.  Returns with the carry
;		flag clear if es:di points at a deallocated block.
;
		public	sl_IsPtr
sl_IsPtr	proc	far
		cmp	di, 8 		;All of our ptrs have an offset of 8.
		jne	NotPtr2
		push	ax
		push	bx
		push	es
		mov	ax, es
;
		mov	bx, StdGrp:StartOfHeap
CmpLoop:	cmp	bx, ax
		je	MightBe
		ja	NotPtr
		mov	es, bx
		mov	bx, esptr.fwdptr
		or	bx, bx		;See if NIL link.
		jnz	CmpLoop
;
NotPtr:		pop	es
		pop	bx
		pop	ax
NotPtr2:	stc
		ret
;
; Might be the pointer, let's see if this guy's allocation count is greater
; than zero.
;
MightBe:	mov	es, bx
		cmp	esptr.blksize, 0
		je	NotPtr
		clc
		pop	es
		pop	bx
		pop	ax
		ret
sl_IsPtr	endp
;
;
;
stdlib		ends
;
;
zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end
