; SHMALLOC.ASM
;
; This TSR sets up a dynamic shared memory system.
;
; This TSR checks to make sure there isn't a copy already active in
; memory.  When removing itself from memory, it makes sure there are
; no other interrupts chained into INT 2Fh before doing the remove.
;
;
;
; The following segments must appear in this order and before the
; Standard Library includes.

ResidentSeg	segment	para public 'Resident'
ResidentSeg	ends

SharedMemory	segment	para public 'Shared'
SharedMemory	ends

EndResident	segment	para public 'EndRes'
EndResident	ends

		.xlist
		.286
		include 	stdlib.a
		includelib	stdlib.lib
		.list


; Resident segment that holds the TSR code:

ResidentSeg	segment	para public 'Resident'
		assume	cs:ResidentSeg, ds:nothing


NULL		equ	0


; Data structure for an allocated data region.
;
; Key-	user supplied ID to associate this region with a particular set
;	of processes.
;
; Next-	Points at the next allocated block.
; Prev- Points at the previous allocated block.
; Size- Size (in bytes) of allocated block, not including header structure.

Region		struct
key		word	?
next		word	?
prev		word	?
blksize		word	?
Region		ends

Startmem	equ	Region ptr [0]

AllocatedList	word	0		;Points at chain of alloc'd blocks.
FreeList	word	0		;Points at chain of free blocks.

; Int 2Fh ID number for this TSR:

MyTSRID		byte	0
		byte	0		;Padding so we can print it.

; PSP is the psp address for this program.

PSP		word	0

OldInt2F	dword	?


; MyInt2F-	Provides int 2Fh (multiplex interrupt) support for this
;		TSR.  The multiplex interrupt recognizes the following
;		subfunctions (passed in AL):
;
;		00h- Verify presence.  	Returns 0FFh in AL and a pointer
;					to an ID string in es:di if the
;					TSR ID (in AH) matches this
;					particular TSR.
;
;		01h- Remove.		Removes the TSR from memory.
;					Returns 0 in AL if successful,
;					1 in AL if failure.
;
;		11h- shmalloc		CX contains the size of the block
;					   to allocate.
;					DX contains the key for this block.
;					Returns a pointer to block in ES:DI
;					 and size of allocated block in CX.
;					Returns an error code in AX.  Zero
;					 is no error, one is "key already
;					 exists,"  two is "insufficient
;					 memory for request."
;
;		12h- shmfree		DX contains the key for this block.
;					This call frees the specified block
;					 from memory.
;
;		13h- shminit		Initializes the shared memory system
;					 freeing all blocks currently in
;					 use.
;
;		14h- shmattach		DX contains the key for a block.
;					 Search for that block and return
;					 its address in ES:DI.  AX contains
;					 zero if successful, three if it
;					 cannot locate a block with the
;					 specified key.

MyInt2F		proc	far
		assume	ds:nothing

		cmp	ah, MyTSRID	;Match our TSR identifier?
		je	YepItsOurs
		jmp	OldInt2F

; Okay, we know this is our ID, now check for a verify, remove, or
; return segment call.

YepItsOurs:	cmp	al, 0		;Verify Call
		jne	TryRmv
		mov	al, 0ffh	;Return success.
		lesi	IDString
		iret			;Return back to caller.

IDString	byte	"Dynamic Shared Memory TSR",0

TryRmv:		cmp	al, 1		;Remove call.
		jne	Tryshmalloc

; See if we can remove this TSR:

		push	es
		mov	ax, 0
		mov	es, ax
		cmp	word ptr es:[2Fh*4], offset MyInt2F
		jne	TRDone
		cmp	word ptr es:[2Fh*4 + 2], seg MyInt2F
		je	CanRemove	;Branch if we can.
TRDone:		mov	ax, 1		;Return failure for now.
		pop	es
		iret

; Okay, they want to remove this guy *and* we can remove it from memory.
; Take care of all that here.

		assume	ds:ResidentSeg

CanRemove:	push	ds
		pusha
		cli			;Turn off the interrupts while
		mov	ax, 0		; we mess with the interrupt
		mov	es, ax		; vectors.
		mov	ax, cs
		mov	ds, ax

		mov	ax, word ptr OldInt2F
		mov	es:[2Fh*4], ax
		mov	ax, word ptr OldInt2F+2
		mov	es:[2Fh*4 + 2], ax


; Okay, one last thing before we quit- Let's give the memory allocated
; to this TSR back to DOS.

		mov	ds, PSP
		mov	es, ds:[2Ch]		;Ptr to environment block.
		mov	ah, 49h			;DOS release memory call.
		int	21h

		mov	ax, ds			;Release program code space.
		mov	es, ax
		mov	ah, 49h
		int	21h

		popa
		pop	ds
		pop	es
		mov	ax, 0			;Return Success.
		iret



; Stick BadKey here so that it is close to its associated branch (from below).
;
; If come here, we've discovered an allocated block with the
; specified key.  Return an error code (AX=1) and the size of that
; allocated block (in CX).

BadKey:		mov	cx, [bx].Region.BlkSize
		mov	ax, 1			;Already allocated error.
		pop	bx
		pop	ds
		iret


; See if this is a shmalloc call.
; If so, on entry -
; DX contains the key.
; CX contains the number of bytes to allocate.
;
; On exit:
;
; ES:DI points at the allocated block (if successful).
; CX contains the actual size of the allocated block (>=CX on entry).
; AX contains error code, 0 if no error.

Tryshmalloc:	cmp	al, 11h			;shmalloc function code.
		jne     Tryshmfree

; First, search through the allocated list to see if a block with the
; current key number already exists.  DX contains the requested key.

		assume	ds:SharedMemory
		assume	bx:ptr Region
		assume	di:ptr Region

		push	ds
		push	bx
		mov	bx, SharedMemory
		mov	ds, bx

		mov	bx, ResidentSeg:AllocatedList
		test	bx, bx			;Anything on this list?
		je	SrchFreeList

SearchLoop:	cmp	dx, [bx].Key		;Key exist already?
		je	BadKey
		mov	bx, [bx].Next		;Get next region.
		test	bx, bx			;NULL?, if not, try another
		jne	SearchLoop		; entry in the list.

; If an allocated block with the specified key does not already exist,
; then try to allocate one from the free memory list.

SrchFreeList:	mov	bx, ResidentSeg:FreeList
		test	bx, bx			;Empty free list?
		je	OutaMemory

FirstFitLp:	cmp	cx, [bx].BlkSize	;Is this block big enough?
		jbe	GotBlock
		mov	bx, [bx].Next		;If not, on to the next one.
		test	bx, bx			;Anything on this list?
		jne	FirstFitLp

; If we drop down here, we were unable to find a block that was large
; enough to satisfy the request.  Return an appropriate error

OutaMemory:	mov	cx, 0			;Nothing available.
		mov	ax, 2			;Insufficient memory error.
		pop	bx
		pop	ds
		iret

; If we find a large enough block, we've got to carve the new block
; out of it and return the rest of the storage to the free list.  If the
; free block is at least 32 bytes larger than the requested size, we will
; do this.  If the free block is less than 32 bytes larger, we will simply
; give this free block to the requesting process.  The reason for the
; 32 bytes is simple:  We need eight bytes for the new block's header
; (the free block already has one) and it doesn't make sense to fragment
; blocks to sizes below 24 bytes.  That would only increase processing time
; when processes free up blocks by requiring more work coalescing blocks.

GotBlock:	mov	ax, [bx].BlkSize	;Compute difference in size.
		sub	ax, cx
		cmp	ax, 32			;At least 32 bytes left?
		jbe	GrabWholeBlk		;If not, take this block.

; Okay, the free block is larger than the requested size by more than 32
; bytes.  Carve the new block from the end of the free block  (that way
; we do not have to change the free block's pointers, only the size.

		mov	di, bx
		add	di, [bx].BlkSize	;Scoot to end, minus 8
		sub	di, cx			;Point at new block.

		sub	[bx].BlkSize, cx	;Remove alloc'd block and
		sub	[bx].BlkSize, 8		; room for header.

		mov	[di].BlkSize, cx	;Save size of block.
		mov	[di].Key, dx		;Save key.

; Link the new block into the list of allocated blocks.

		mov	bx, ResidentSeg:AllocatedList
		mov	[di].Next, bx
		mov	[di].Prev, NULL		;NULL previous pointer.
		test	bx, bx			;See if it was an empty list.
		je	NoPrev
		mov	[bx].Prev, di		;Set prev ptr for old guy.

NoPrev:		mov	ResidentSeg:AllocatedList, di
RmvDone:	add	di, 8			;Point at actual data area.
		mov	ax, ds			;Return ptr in es:di.
		mov	es, ax
		mov	ax, 0			;Return success.
		pop	bx
		pop	ds
		iret


; If the current free block is larger than the request, but not by more
; that 32 bytes, just give the whole block to the user.

GrabWholeBlk:   mov	di, bx
		mov	cx, [bx].BlkSize	;Return actual size.
		cmp	[bx].Prev, NULL		;First guy in list?
		je	Rmv1st
		cmp	[bx].Next, NULL		;Last guy in list?
		je	RmvLast

; Okay, this record is sandwiched between two other in the free list.
; Cut it out from among the two.

		mov	ax, [bx].Next		;Save the ptr to the next
		mov	bx, [bx].Prev		; item in the prev item's
		mov	[bx].Next, ax		; next field.

		mov	ax, bx			;Save the ptr to the prev
		mov	bx, [di].Next		; item in the next item's
		mov	[bx].Prev, bx		; prev field.
		jmp	RmvDone



; The block we want to remove is at the beginning of the free list.
; It could also be the only item on the free list!

Rmv1st:         mov	ax, [bx].Next
		mov	FreeList, ax		;Remove from free list.
		jmp	RmvDone

; If the block we want to remove is at the end of the list, handle that
; down here.

RmvLast:	mov	bx, [bx].Prev
		mov	[bx].Next, NULL
		jmp	RmvDone

		assume	ds:nothing, bx:nothing, di:nothing




; This code handles the SHMFREE function.
; On entry, DX contains the key for the block to free.  We need to
; search through the allocated block list and find the block with that
; key.  If we do not find such a block, this code returns without doing
; anything.  If we find the block, we need to add its memory to the
; free pool.  However, we cannot simply insert this block on the front
; of the free list (as we did for the allocated blocks).  It might
; turn out that this block we're freeing is adjacent to one or two
; other free blocks.  This code has to coalesce such blocks into
; a single free block.

Tryshmfree:	cmp	al, 12h
		jne	Tryshminit


; First, search the allocated block list to see if we can find the
; block to remove.  If we don't find it in the list anywhere, just return.

		assume	ds:SharedMemory
		assume	bx:ptr Region
		assume	di:ptr Region

		push	ds
		push	di
		push	bx

		mov	bx, SharedMemory
		mov	ds, bx
		mov	bx, ResidentSeg:AllocatedList

		test	bx, bx			;Empty allocated list?
		je	FreeDone
SrchList:	cmp	dx, [bx].Key		;Search for key in DX.
		je	FoundIt
		mov	bx, [bx].Next
		test	bx, bx			;At end of list?
		jne	SrchList
FreeDone:	pop	bx
		pop	di			;Nothing allocated, just
		pop	ds			; return to caller.
		iret


; Okay, we found the block the user wants to delete.  Remove it from
; the allocated list.  There are three cases to consider:
; (1) it is at the front of the allocated list, (2) it is at the end of
; the allocated list, and (3) it is in the middle of the allocated list.

FoundIt:	cmp	[bx].Prev, NULL		;1st item in list?
		je	Free1st
		cmp	[bx].Next, NULL		;Last item in list?
		je	FreeLast

; Okay, we're removing an allocated item from the middle of the allocated
; list.

		mov	di, [bx].Next		;[next].prev := [cur].prev
		mov	ax, [bx].Prev
		mov	[di].Prev, ax
		xchg	ax, di
		mov	[di].Next, ax		;[prev].next := [cur].next
		jmp	AddFree

; Handle the case where we are removing the first item from the allocation
; list.  It is possible that this is the only item on the list (i.e., it
; is the first and last item), but this code handles that case without any
; problems.

Free1st:	mov	ax, [bx].Next
		mov	ResidentSeg:AllocatedList, ax
		jmp	AddFree

; If we're removing the last guy in the chain, simply set the next field
; of the previous node in the list to NULL.

FreeLast:	mov	di, [bx].Prev
		mov	[di].Next, NULL

; Okay, now we've got to put the freed block onto the free block list.
; The free block list is sorted according to address.  We have to search
; for the first free block whose address is greater than the block we've
; just freed and insert the new free block before that one.  If the two
; blocks are adjacent, then we've got to merge them into a single free
; block.  Also, if the block before is adjacent, we must merge it as
; well.  This will coalesce all free blocks on the free list so there
; are as few free blocks as possible and those blocks are as large as
; possible.

AddFree:	mov	ax, ResidentSeg:FreeList
		test	ax, ax			;Empty list?
		jne	SrchPosn

; If the list is empty, stick this guy on as the only entry.

		mov	ResidentSeg:FreeList, bx
		mov	[bx].Next, NULL
		mov	[bx].Prev, NULL
		jmp	FreeDone

; If the free list is not empty, search for the position of this block
; in the free list:

SrchPosn:	mov	di, ax
		cmp	bx, di
		jb	FoundPosn
		mov	ax, [di].Next
		test	ax, ax			;At end of list?
		jne	SrchPosn

; If we fall down here, the free block belongs at the end of the list.
; See if we need to merge the new block with the old one.

		mov	ax, di
		add	ax, [di].BlkSize	;Compute address of 1st byte
		add	ax, 8			; after this block.
		cmp	ax, bx
		je	MergeLast

; Okay, just add the free block to the end of the list.

		mov	[di].Next, bx
		mov	[bx].Prev, di
		mov	[bx].Next, NULL
		jmp	FreeDone

; Merge the freed block with the block DI points at.

MergeLast:	mov	ax, [di].BlkSize
		add	ax, [bx].BlkSize
		add	ax, 8
		mov	[di].BlkSize, ax
		jmp	FreeDone

; If we found a free block before which we are supposed to insert
; the current free block, drop down here and handle it.

FoundPosn:      mov	ax, bx			;Compute the address of the
		add	ax, [bx].BlkSize	; next block in memory.
		add	ax, 8
		cmp	ax, di			;Equal to this block?
		jne	DontMerge

; The next free block is adjacent to the one we're freeing, so just
; merge the two.

		mov	ax, [di].BlkSize	;Merge the sizes together.
		add	ax, 8
		add	[bx].BlkSize, ax
		mov	ax, [di].Next		;Tweak the links.
		mov	[bx].Next, ax
		mov	ax, [di].Prev
		mov	[bx].Prev, ax
		jmp	TryMergeB4

; If the blocks are not adjacent, just link them together here.

DontMerge:	mov	ax, [di].Prev
		mov	[di].Prev, bx
		mov	[bx].Prev, ax
		mov	[bx].Next, di

; Now, see if we can merge the current free block with the previous free blk.

TryMergeB4:	mov	di, [bx].Prev
		mov	ax, di
		add	ax, [di].BlkSize
		add	ax, 8
		cmp	ax, bx
		je	CanMerge
		pop	bx
		pop	di			;Nothing allocated, just
		pop	ds			; return to caller.
		iret

; If we can merge the previous and current free blocks, do that here:

CanMerge:	mov	ax, [bx].Next
		mov	[di].Next, ax
		mov	ax, [bx].BlkSize
		add	ax, 8
		add	[di].BlkSize, ax
		pop	bx
		pop	di
		pop	ds
		iret

		assume	ds:nothing
		assume	bx:nothing
		assume	di:nothing

; Here's where we handle the shared memory initializatin (SHMINIT) function.
; All we got to do is create a single block on the free list (which is all
; available memory), empty out the allocated list, and then zero out all
; shared memory.

Tryshminit:	cmp	al, 13h
		jne	TryShmAttach

; Reset the memory allocation area to contain a single, free, block of
; memory whose size is 0FFF8h (need to reserve eight bytes for the block's
; data structure).

		push	es
		push	di
		push	cx

		mov	ax, SharedMemory	;Zero out the shared
		mov	es, ax			; memory segment.
		mov	cx, 32768
		xor	ax, ax
		mov	di, ax
	rep	stosw


; Note: the commented out lines below are unnecessary since the code above
; has already zeroed out the entire shared memory segment.
; Note: we cannot put the first record at offset zero because offset zero
; is the special value for the NULL pointer.  We'll use 4 instead.

		mov	di, 4
;		mov	es:[di].Region.Key, 0		;Key is arbitrary.
;		mov	es:[di].Region.Next, 0		;No other entries.
;		mov	es:[di].Region.Prev, 0		; Ditto.
		mov	es:[di].Region.BlkSize, 0FFF8h	;Rest of segment.
		mov	ResidentSeg:FreeList, di

		pop	cx
		pop	di
		pop	es
		mov	ax, 0				;Return no error.
		iret


; Handle the SHMATTACH function here.  On entry, DX contains a key number.
; Search for an allocated block with that key number and return a pointer
; to that block (if found) in ES:DI.  Return an error code (AX=3) if we
; cannot find the block.

TryShmAttach:	cmp	al, 14h			;Attach opcode.
		jne	IllegalOp
		mov	ax, SharedMemory
		mov	es, ax

		mov	di, ResidentSeg:AllocatedList
FindOurs:	cmp	dx, es:[di].Region.Key
		je	FoundOurs
		mov	di, es:[di].Region.Next
		test	di, di
		jne	FoundOurs
		mov	ax, 3			;Can't find the key.
		iret

FoundOurs:	add	di, 8			;Point at actual data.
		mov	ax, 0			;No error.
		iret


; They called us with an illegal subfunction value.  Try to do as little
; damage as possible.

IllegalOp:	mov	ax, 0		;Who knows what they were thinking?
		iret
MyInt2F		endp
		assume	ds:nothing
ResidentSeg	ends


; Here's the segment that will actually hold the shared data.

SharedMemory	segment	para public 'Shared'
		db	0FFFFh dup (?)
SharedMemory	ends






cseg		segment	para public 'code'
		assume	cs:cseg, ds:ResidentSeg

; SeeIfPresent-	Checks to see if our TSR is already present in memory.
;		Sets the zero flag if it is, clears the zero flag if
;		it is not.

SeeIfPresent	proc	near
		push	es
		push	ds
		push	di
		mov	cx, 0ffh		;Start with ID 0FFh.
IDLoop:		mov	ah, cl
		push	cx
		mov	al, 0			;Verify presence call.
		int	2Fh
		pop	cx
		cmp	al, 0			;Present in memory?
		je	TryNext
		strcmpl
		byte	"Dynamic Shared Memory TSR",0
		je	Success

TryNext:	dec	cl			;Test USER IDs of 80h..FFh
		js	IDLoop
		cmp	cx, 0			;Clear zero flag.
Success:	pop	di
		pop	ds
		pop	es
		ret
SeeIfPresent	endp



; FindID-	Determines the first (well, last actually) TSR ID available
;		in the multiplex interrupt chain.  Returns this value in
;		the CL register.
;
;		Returns the zero flag set if it locates an empty slot.
;		Returns the zero flag clear if failure.

FindID		proc	near
		push	es
		push	ds
		push	di

		mov	cx, 0ffh		;Start with ID 0FFh.
IDLoop:		mov	ah, cl
		push	cx
		mov	al, 0			;Verify presence call.
		int	2Fh
		pop	cx
		cmp	al, 0			;Present in memory?
		je	Success
		dec	cl			;Test USER IDs of 80h..FFh
		js	IDLoop
		xor	cx, cx
		cmp	cx, 1			;Clear zero flag
Success:	pop	di
		pop	ds
		pop	es
		ret
FindID		endp



Main		proc
		meminit

		mov	ax, ResidentSeg
		mov	ds, ax

		mov	ah, 62h			;Get this program's PSP
		int	21h			; value.
		mov	PSP, bx

; Before we do anything else, we need to check the command line
; parameters.  If there is one, and it is the word "REMOVE", then remove
; the resident copy from memory using the multiplex (2Fh) interrupt.

		argc
		cmp	cx, 1			;Must have 0 or 1 parms.
		jb	TstPresent
		je	DoRemove
Usage:		print
		byte	"Usage:",cr,lf
		byte	"       shmalloc",cr,lf
		byte	"or     shmalloc REMOVE",cr,lf,0
		ExitPgm


; Check for the REMOVE command.

DoRemove:	mov	ax, 1
		argv
		stricmpl
		byte	"REMOVE",0
		jne	Usage

		call	SeeIfPresent
		je	RemoveIt
		print
		byte	"TSR is not present in memory, cannot remove"
		byte	cr,lf,0
		ExitPgm

RemoveIt:	mov	MyTSRID, cl
		printf
		byte	"Removing TSR (ID #%d) from memory...",0
		dword	MyTSRID

		mov	ah, cl
		mov	al, 1			;Remove cmd, ah contains ID
		int	2Fh
		cmp	al, 1			;Succeed?
		je	RmvFailure
		print
		byte	"removed.",cr,lf,0
		ExitPgm

RmvFailure:	print
		byte	cr,lf
		byte	"Could not remove TSR from memory.",cr,lf
		byte	"Try removing other TSRs in the reverse order "
		byte	"you installed them.",cr,lf,0
		ExitPgm



; Okay, see if the TSR is already in memory.  If so, abort the
; installation process.

TstPresent:     call	SeeIfPresent
		jne	GetTSRID
		print
		byte	"TSR is already present in memory.",cr,lf
		byte	"Aborting installation process",cr,lf,0
		ExitPgm


; Get an ID for our TSR and save it away.

GetTSRID:	call	FindID
		je	GetFileName
		print
		byte	"Too many resident TSRs, cannot install",cr,lf,0
		ExitPgm


; Things look cool so far, so install the interrupts

GetFileName:	mov	MyTSRID, cl
		print
		byte	"Installing interrupts...",0


; Patch into the INT 2Fh interrupt chain.

		cli				;Turn off interrupts!
		mov	ax, 0
		mov	es, ax
		mov	ax, es:[2Fh*4]
		mov	word ptr OldInt2F, ax
		mov     ax, es:[2Fh*4 + 2]
		mov	word ptr OldInt2F+2, ax
		mov	es:[2Fh*4], offset MyInt2F
		mov	es:[2Fh*4+2], seg ResidentSeg
		sti				;Okay, ints back on.

; We're hooked up, the only thing that remains is to initialize the shared
; memory segment and then terminate and stay resident.

		printf
		byte	"Installed, TSR ID #%d.",cr,lf,0
		dword	MyTSRID

		mov	ah, MyTSRID		;Initialization call.
		mov	al, 13h
		int	2Fh

		mov	dx, EndResident		;Compute size of program.
		sub	dx, PSP
		mov	ax, 3100h		;DOS TSR command.
		int	21h
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	256 dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
