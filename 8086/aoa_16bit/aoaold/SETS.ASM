		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386
		option	segment:use16

dseg		segment	para public 'data'

set1		dword	0
set2		dword	0
set3		dword	0


; Each entry in the following table contains a single bit.
; The index into the table selects which bit is set (e.g.,
; the value at index zero has bit zero set).

BitTbl		dword	1, 2, 4, 8
		dword	10h, 20h, 40h, 80h
		dword	100h, 200h, 400h, 800h
		dword	1000h, 2000h, 4000h, 8000h
		dword	10000h, 20000h, 40000h, 80000h
		dword	100000h, 200000h, 400000h, 800000h
		dword	1000000h, 2000000h, 4000000h, 8000000h
		dword	10000000h, 20000000h, 40000000h, 80000000h
dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

; Macros to perform common set operations:
;
; AddItem-	EBX contains a value in the range 0..31.
;		EAX contains a set.
;		AddItem adds the specified item to the set.
;		Note that this wipes out the high order bytes
;		of EBX.

AddItem		macro
		and	ebx, 1fh	;Truncate to range 0..31.
		or	eax, BitTbl[ebx*4]
		endm

; RemoveItem-	EBX contains a value in the range 0..31.
;		EAX contains a set.
;		RemoveItem removes the specified item from the
;		set.

RemoveItem	macro
		push	ebx
		and	ebx, 1fh	;Force to range 0..31.
		mov	ebx, BitTbl[ebx*4]
		not	ebx
		and	eax, ebx
		pop	ebx
		endm

; Member-	EBX contains a value in the range 0..31.
;		EAX contains a set.
;		Member clears the zero flag if EBX is an element
;		of the EAX set, it sets the zero flag otherwise.
;		This code clears bits 6..31 in EBX.

Member		macro
		and	ebx, 1fh
		test	eax, BitTbl[ebx*4]
		endm


; UnionSets-	EAX and EBX contain two sets.  Union computes
;		EAX := EAX union EBX.

UnionSets	macro
		or	eax, ebx
		endm

; Intersection-	EAX and EBX contain two sets.  Intersection
;		computes EAX := EAX intersect EBX.

Intersection	macro
		and	eax, ebx
		endm

; Difference-	EAX and EBX contain two sets.  Difference
;		computes EAX := EAX - EBX (set difference).

Difference	macro
		push	ebx
		not	ebx
		and	eax, ebx
		pop	ebx
		endm

; SetEqual-	EAX and EBX contain two sets.  This code sets the
;		zero flag if they are equal, it clears the zero
;		flag if they are not equal.

SetEqual	macro
		cmp	eax, ebx
		endm

; Subset-	EAX and EBX contain two sets.  This code sets the
;		zero flag if EBX is a subset of EAX (not a
;		proper subset, if you need a proper subset, check
;		for inequality after checking for subset).

Subset		macro
		push	eax
		and	eax, ebx
		cmp	eax, ebx
		pop	eax
		endm

; Extract-	EAX contains a set.  This routine scans through
;		EAX to find the first item in the set.  It returns
;		the bit number of that object in EBX.  It returns
;		with the zero flag clear if the set is empty.
;		This routine also clears the corresponding bit
;		in EAX, if not the empty set.

Extract		macro
		local	EmptySet
		bsf	ebx, eax
		je	EmptySet
		pushf
		push	ebx
		mov	ebx, BitTbl[ebx*4]
		not	ebx
		and	eax, ebx
		pop	ebx
		popf
EmptySet:
		endm




Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; Select ten random numbers in the range 0..31 for each set:

		randomize
		mov	cx, 10
SetLoop:	random
		mov	bx, ax
		mov	eax, Set1
		AddItem
		mov	Set1, eax

		random
		mov	bx, ax
		mov	eax, Set2
		AddItem
		mov	Set2, eax
		loop	SetLoop

; Okay, print the set values:

		printf
		byte	"Set1 = %lx\n"
		byte	"Set2 = %lx\n\n",0
		dword	Set1, Set2

; Compute the sets' union, intersection, and difference:

		mov	eax, Set1
		mov	ebx, Set2
		UnionSets
		mov	Set3, eax
		printf
		byte	"Set union = %lx\n",0
		dword	Set3

		mov	eax, Set1
		mov	ebx, Set2
		Intersection
		mov	Set3, eax
		printf
		byte	"Set intersection = %lx\n",0
		dword	Set3

		mov	eax, Set1
		mov	ebx, Set2
		Difference
		mov	Set3, eax
		printf
		byte	"Set1-Set2 = %lx\n",0
		dword	Set3

		mov	eax, Set2
		mov	ebx, Set1
		Difference
		mov	Set3, eax
		printf
		byte	"Set2-Set1 = %lx\n",0
		dword	Set3

; Extract all the members from the Set1 set:

		print
		byte	"Members of Set1:",0
		mov	eax, Set1
ExtractLp:	print
		byte	"  ",0
		Extract
		je	ExtractDone
		xchg	eax, ebx
		puti
		xchg	eax, ebx
		jmp	ExtractLp
ExtractDone:


Quit:		ExitPgm
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
