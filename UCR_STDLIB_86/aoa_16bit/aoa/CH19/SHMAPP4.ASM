; SHMAPP4.ASM
;
; This is a shared memory application that uses the dynamic shared memory
; TSR (SHMALLOC.ASM).  This program assumes the user has already run the
; SHMAPP3 program to insert a string into shared memory.  This program
; simply prints that string from shared memory.
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
		byte	"Shared memory application #4",cr,lf,0

; See if the shared memory TSR is around:

		call	SeeIfPresent
		je	ItsThere
		print
		byte	"Shared Memory TSR (SHMALLOC) is not loaded.",cr,lf
		byte	"This program cannot continue execution.",cr,lf,0
		ExitPgm

; If the shared memory TSR is present, get the address of the shared segment
; into the ES register:

ItsThere:	mov	ah, cl		;ID of our TSR.
		mov	al, 14h		;Attach call
		mov	dx, 1234h	;Our "key" value
		int	2Fh

; Print the string input in SHMAPP3:

		print
		byte	"String from SHMAPP3 is '",0

		puts

		print
		byte	"' from shared memory.",cr,lf,0


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
