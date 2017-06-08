; Iterator example.
;
; Roughly corresponds to the example in Ghezzi & Jazayeri's
; "Programming Language Concepts" text.
;
; Randall Hyde
;
;
; This program demonstrates an implementation of:
;
;  l := 0;
;  foreach i in range(1,3) do
;	foreach j in iter2() do
;		writeln(i, ',', j, ',', l):
;
;
;  iterator range(start,stop):integer;
;  begin
;
;	while start <= stop do begin
;
;		yield start;
;		start := start+1;
;	end;
;  end;
;
;  iterator iter2:integer;
;  var k:integer;
;  begin
;
;	foreach k in iter3 do
;		yield k;
;  end;
;
;  iterator iter3:integer;
;  begin
;
;	l := l + 1;
;	yield 1;
;	l := l + 1;
;	yield 2;
;	l := l + 1;
;	yield 0;
;  end;
;
;
; This code will print:
;
;	1, 1, 1
;	1, 2, 2
;	1, 0, 3
;	2, 1, 4
;	2, 2, 5
;	2, 0, 6
;	3, 1, 7
;	3, 2, 8
;	3, 0, 9




		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.286				;Allow extra adrs modes.



dseg		segment	para stack 'data'



; Put the stack in the data segment so we can use the small memory model
; to simplify addressing:

stk		byte	1024 dup ('stack')
EndStk		word	0

dseg		ends





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg, ss:dseg




; Here's the structure of a resume frame.  Note that this structure isn't
; actually used in this code.  It is only provided to show you what data
; is sitting on the stack when Yield builds a resume frame.

RsmFrm		struct
ResumeAdrs	word	?
IteratorLink	word	?
RsmFrm		ends




; The following macro builds a resume frame and the returns to the caller
; of an iterator.  It assumes that the iterator and whoever called the
; iterator have the standard activation record defined above and that we
; are building the standard resume frame described above.
;
; This code wipes out the DX register.  Whoever calls the iterator cannot
; count on DX being preserved, likewise, the iterator cannot count on DX
; being preserved across a yield.  Presumably, the iterator returns its
; value in AX.

ActRec		struct
DynamicLink	word	?		;Saved BP value.
YieldAdrs	word	?		;Return Adrs for proc.
StaticLink	word	?		;Static link for proc.
ActRec		ends

AR		equ	[bp].ActRec

Yield		macro
		mov	dx, AR.YieldAdrs	;Place to yield back to.
		push	bp			;Save Iterator link
		mov	bp, AR.DynamicLink	;Get ptr to caller's A.R.
		call	dx			;Push resume address and rtn.
		pop	bp			;Restore ptr to our A. R.
		endm






; Range(start, stop) - Yields start..stop and then fails.

; The following structure defines the activation record for Range:

rngAR		struct
DynamicLink	word	?		;Saved BP value.
YieldAdrs	word	?		;Return Adrs for proc.
StaticLink	word	?		;Static link for proc.
FailAdrs	word	?		;Go here when we fail
Stop		word	?		;Stop parameter
Start		word	?		;Start parameter

rngAR		ends


rAR		equ	[bp].rngAR


Range		proc
		push	bp
		mov	bp, sp

; While start <= stop, yield start:

WhlStartLEStop:	mov	ax, rAR.Start		;Also puts return value
		cmp	ax, rAR.Stop		; in AX.
		jnle	RangeFail

		yield

		inc	rAR.Start
		jmp	WhlStartLEStop

RangeFail:      pop	bp			;Restore Dynamic Link.
		add	sp, 4			;Skip ret adrs and S.L.
		ret     4			;Return through fail address.
Range		endp




; Iter2- Just calls iter3() and returns whatever value it generates.
;
; Note: Since iter2 and iter3 are at the same lex level, the static link
; passed to iter3 must be the same as the static link passed to iter2.
; This is why the "push [bp]" instruction appears below (as opposed to the
; "push bp" instruction which appears in the calls to Range and iter2).
; Keep in mind, Range and iter2 are only called from main and bp contains
; the static link at that point.  This is not true when iter2 calls iter3.

iter2		proc
		push	bp
		mov	bp, sp

		push	offset i3Fail		;Failure address.
		push	[bp]			;Static link is link to main.
		call	iter3
		yield				;Return value returned by iter3
		ret				;Resume Iter3.

i3Fail:		pop	bp			;Restore Dynamic Link.
		add	sp, 4			;Skip return address & S.L.
		ret     			;Return through fail address.
iter2		endp



; Iter3() simply yields the values 1, 2, and 0:

iter3		proc
		push	bp
		mov	bp, sp

		mov	bx, AR.StaticLink	;Point BX at main's AR.
		inc	word ptr [bx-6]		;Increment L in main.
		mov	ax, 1
		yield

		mov	bx, AR.StaticLink
		inc	word ptr [bx-6]
		mov	ax, 2
		yield
		mov	bx, AR.StaticLink
		inc	word ptr [bx-6]
		mov	ax, 0
		yield

		pop	bp			;Restore Dynamic Link.
		add	sp, 4			;Skip return address & S.L.
		ret     			;Return through fail address.
iter3		endp






; Main's local variables are allocated on the stack in order to justify
; the use of static links.

i		equ	[bp-2]
j		equ	[bp-4]
l		equ	[bp-6]


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		mov	ss, ax
		mov	sp, offset EndStk

; Allocate storage for i, j, and l on the stack:

		mov	bp, sp
		sub	sp, 6

		meminit

		mov	word ptr l, 0		;Initialize l.

; foreach i in range(1,3) do:

		push	1			;Parameters.
		push	3
		push	offset iFail		;Failure address.
		push	bp			;Static link points at our AR.
		call	Range

; Yield from range comes here.  The label is for your benefit.

RangeYield:	mov	i, ax			;Save away loop control value.

; foreach j in iter2 do:

		push	offset jfail		;Failure address.
		push	bp			;Static link points at our AR.
		call	iter2


; Yield from iter2 comes here:

iter2Yield:	mov	j, ax

		mov	ax, i
		puti
		print
		byte	", ",0
		mov	ax, j
		puti
		print
		byte	", ",0
		mov	ax, l
		puti
		putcr

; Restart iter2:

		ret				;Resume iterator.


; Restart Range down here:

jFail:		ret				;Resume iterator.

; All Done!

iFail:		print
		byte	cr,lf,"All Done!",cr,lf,0




Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends



; zzzzzzseg must be the last segment that gets loaded into memory!
; This is where the heap begins.

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
