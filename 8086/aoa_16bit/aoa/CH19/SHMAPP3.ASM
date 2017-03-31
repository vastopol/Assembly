; SHMAPP3.ASM
;
; This is a shared memory application that uses the dynamic shared memory
; TSR (SHMALLOC.ASM).  This program inputs a string from the user and
; passes that string to SHMAPP4.ASM through the shared memory area.
;
;
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'
ShmID		byte	0
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg, es:SharedMemory

; SeeIfPresent-	Checks to see if the shared memory TSR is present in memory.
;		Sets the zero flag if it is, clears the zero flag if
;		it is not.  This routine also returns the TSR ID in CL.

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



; The main program for application #1 links with the shared memory
; TSR and then reads a string from the user (storing the string into
; shared memory) and then terminates.

Main		proc
		assume	cs:cseg, ds:dseg, es:SharedMemory
		mov	ax, dseg
		mov	ds, ax
		meminit

		print
		byte	"Shared memory application #3",cr,lf,0

; See if the shared memory TSR is around:

		call	SeeIfPresent
		je	ItsThere
		print
		byte	"Shared Memory TSR (SHMALLOC) is not loaded.",cr,lf
		byte	"This program cannot continue execution.",cr,lf,0
		ExitPgm


; Get the input line from the user:

ItsThere:	mov	ShmID, cl
		print
		byte	"Enter a string: ",0

		lea	di, InputLine	;ES already points at proper seg.
		getsm

; The string is in our heap space.  Let's move it over to the shared
; memory segment.

		strlen
		inc 	cx			;Add one for zero byte.
		push	es
		push	di

		mov	dx, 1234h		;Our "key" value.
		mov	ah, ShmID
		mov	al, 11h			;Shmalloc call.
		int	2Fh

		mov	si, di			;Save as dest ptr.
		mov	dx, es

		pop	di			;Retrive source address.
		pop	es
		strcpy				;Copy from local to shared.

		print
		byte	"Entered '",0
		puts
		print
		byte	"' into shared memory.",cr,lf,0


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends


; The shared memory segment must appear after "zzzzzzseg".
; Note that this isn't the physical storage for the data in the
; shared segment.  It's really just a place holder so we can declare
; variables and generate their offsets appropriately.  The UCR Standard
; Library will reuse the memory associated with this segment for the
; heap.  To access data in the shared segment, this application calls
; the shared memory TSR to obtain the true segment address of the
; shared memory segment.  It can then access variables in the shared
; memory segment (where ever it happens to be) off the ES register.
;
; Note that all the variable declarations go into an include file.
; All applications that refer to the shared memory segment include
; this file in the SharedMemory segment.  This ensures that all
; shared segments have the exact same variable layout.

SharedMemory	segment	para public 'Shared'

		include	shmvars.asm

SharedMemory	ends
		end	Main
