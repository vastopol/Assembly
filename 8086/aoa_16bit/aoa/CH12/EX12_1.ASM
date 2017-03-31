; EX12_1.asm
;
; Program to support the laboratory exercise in Chapter 12.
;
; This program combines iterators, passing parameters as parameters,
; and procedural parameters all into the same program.
;
;
; This program implements the following iterators (examples written in panacea):
;
; program EX12_1;
;
; fib:iterator(n:integer):integer;
; var
;	CurIndex:integer;
;	Fn1:	 integer;
;	Fn2:	 integer;
; endvar;
; begin fib;
;
;	yield 1;	(* Always have at least n=0 *)
;	if (n <> 0) then
;
;		yield 1;	(* Have at least n=1 at this point *)
;
;		Fn1 := 1;
;		Fn2 := 1;
;		foreach CurIndex in 2..n do
;
;			yield Fn1+Fn2;
;			Fn2 = Fn1;
;			Fn1 = CurIndex;
;
;		endfor;
;	endif;
;
; end fib;
;
;
;
; UpDown:iterator(n:integer):integer;
; var
;	CurIndex:integer;
; endvar;
; begin UpDown;
;
;	foreach CurIndex in 0..n do
;
;		yield CurIndex;
;
;	endfor;
;	foreach CurIndex in n-1..0 do
;
;		yield CurIndex;
;
;	endfor;
; 
; end UpDown;
;
;
;
; SumToN:iterator(n:integer):integer;
; var
;	CurIndex:integer;
;	Sum:	 integer;
; endvar;
; begin SumToN;
;
;	Sum := 0;
;	foreach CurIndex in 0..n do
;
;		Sum := Sum + CurIndex;
;		yield Sum;
;
;	endfor;
;
; end SumToN;
;
;
; MultiIter returns a pointer to an iterator that accepts a single integer parameter.
;
; MultiIter: iterator: [iterator(n:integer)];
; begin MultiIter;
;
;	yield @Fib;	(* Return pointers to the three iterators above *)
;	yield @UpDown;	(* as the result of this iterator.		*)
;	yield @SumToN;
;
; end MultiIter;
;
;
; var
;	i:integer;
;	n:integer;
;	iter:[iterator(n:integer)];
; endvar;
;
; begin EX12_1;
;
;	(* The following for loop repeats six times, passing its loop index as	*)
;	(* the parameter to the Fib, UpDown, and SumToN parameters.		*)
;
;	foreach n in 0..5 do
;
;
;		(* The following (funny looking) iterator sequences through	*)
;		(* each of the three iterators: Fib, UpDown, and SumToN.  It	*)
;		(* returns a pointer as the iterator value.  The innermost	*)
;		(* foreach loop uses this pointer to call the appropriate	*)
;		(* iterator.							*)
;
;		foreach iter in MultiIter do
;
;			(* Okay, this for loop invokes whatever iterator was	*)
;			(* return by the MultiIter iterator above.		*)
;
;			foreach i in [MultiIter](n) do
;
;				write(i:3);
;
;			endfor;
;			writeln;
;
;		endfor;
;		writeln;
;
;	endfor;
;
; end EX12_1;

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.286				;Allow extra adrs modes.


wp		textequ	<word ptr>


dseg		segment	para public 'code'
dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ss:sseg




; The following macro builds a resume frame and the returns to the caller
; of an iterator.  It assumes that the iterator and whoever called the
; iterator have the standard activation record defined above and that we
; are building the standard resume frame described above.
;
; This code wipes out the DX register.  Whoever calls the iterator cannot
; count on DX being preserved, likewise, the iterator cannot count on DX
; being preserved across a yield.  Presumably, the iterator returns its
; value in AX.


Yield		macro
                mov     dx, [BP+2]              ;Place to yield back to.
		push	bp			;Save Iterator link
                mov     bp, [bp]                ;Get ptr to caller's A.R.
		call	dx			;Push resume address and rtn.
		pop	bp			;Restore ptr to our A. R.
		endm






; Fib(n) - Yields the sequence of fibonacci numbers from F(0)..F(n).
;	   The fibonacci sequence is defined as:
;
;		F(0) and F(1) = 1.
;		F(n) = F(n-1) + F(n-2) for n > 1.


; The following structure defines the activation record for Fib

CurIndex	textequ	<[bp-6]>	;Current sequence value.
Fn1		textequ	<[bp-4]>	;F(n-1) value.
Fn2		textequ	<[bp-2]>	;F(n-2) value.
DynamicLink	textequ	<[bp]>		;Saved BP value.
YieldAdrs	textequ	<[bp+2]>	;Return Adrs for proc.
FailAdrs        textequ <[bp+4]>        ;Go here when we fail
n               textequ <[bp+6]>        ;The initial parameter


Fib		proc
		push	bp
		mov	bp, sp
		sub	sp, 6		;Make room for local variables.

; We will also begin yielding values starting at F(0).
; Since F(0) and F(1) are special cases, yield their values here.

		mov	ax, 1		;Yield F(0) (we always return at least
		yield			; F(0)).

		cmp	wp n, 1		;See if user called this with n=0.
		jb	FailFib
                mov     ax, 1
                yield

; Okay, n >=1 so we need to go into a loop to handle the remaining values.
; First, begin by initializing Fn1 and Fn2 as appropriate.

                mov     wp Fn1, 1
                mov     wp Fn2, 1
                mov     wp CurIndex, 2

WhlLp:		mov     ax, CurIndex		;See if CurIndex > n.
                cmp     ax, n
                ja      FailFib

                push    Fn1
                mov     ax, Fn1
                add     ax, Fn2
                pop     Fn2			;Fn1 becomes the new Fn2 value.
                mov     Fn1, ax			;Current value becomes new Fn1 value.
                yield				;Yield the current value.

                inc     wp CurIndex
                jmp     WhlLp



FailFib:	mov     sp, bp			;Deallocate local vars.
                pop     bp			;Restore Dynamic Link.
                add     sp, 2			;Skip ret adrs.
                ret     2			;Return through fail address.
Fib		endp





; UpDown-       This function yields the sequence 0, 1, 2, ..., n, n-1,
;               n-2, ..., 1, 0.


i               textequ <[bp-2]>        ;F(n-2) value.

UpDown		proc
		push    bp
		mov	bp, sp
		sub	sp, 2		;Make room for i.

		mov	wp i, 0		;Initialize our index variable (i).
UptoN:		mov	ax, i
		cmp	ax, n
		jae	GoDown

		yield

		inc	wp i
		jmp	UpToN


GoDown:		mov	ax, i
		yield
		mov	ax, i
		cmp	ax, 0
		je	UpDownDone
		dec	wp i
		jmp	GoDown

UpDownDone:     mov     sp, bp                  ;Deallocate local vars.
                pop     bp                      ;Restore Dynamic Link.
                add     sp, 2                   ;Skip ret adrs.
                ret     2                       ;Return through fail address.
UpDown		endp





; SumToN(n)-	This iterator returns 1, 2, 3, 6, 10, ... sum(n) where
;		sum(n) = 1+2+3+4+...+n  (e.g., n(n+1)/2);

j               textequ <[bp-2]>        
k		textequ	<[bp-4]>

SumToN		proc
		push    bp
		mov	bp, sp
		sub	sp, 4		;Make room for j and k.

		mov	wp j, 0		;Initialize our index variable (j).
		mov	wp k, 0		;Initialize our sum (k).
SumLp:		mov	ax, j
		cmp	ax, n
		ja	SumDone

		add	ax, k
		mov	k, ax

		yield

		inc	wp j
		jmp	SumLp

SumDone:	mov     sp, bp                  ;Deallocate local vars.
                pop     bp                      ;Restore Dynamic Link.
                add     sp, 2                   ;Skip ret adrs.
                ret     2                       ;Return through fail address.
SumToN		endp





; MultiIter-	This iterator returns a pointer to each of the above iterators.

MultiIter	proc
		push	bp
		mov	bp, sp

		mov	ax, offset Fib
		yield
		mov	ax, offset UpDown
		yield
		mov	ax, offset SumToN
		yield

		pop	bp
		add	sp, 2
		ret
MultiIter	endp




Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax


		meminit

; foreach bx in 0..5 do

		mov	bx, 0		 ;Loop control variable for outer loop.
WhlBXle5:	

; foreach ax in MultiIter do

		push	offset MultiDone ;Failure address.
		call	MultiIter	 ;Get iterator to call.


; foreach i in [ax](bx) do

		push	bx		;Push "n" (bx) onto the stack.
		push	offset IterDone	;Failure Address
		call	ax		;Call the iterator pointed at by the
;					; return value from MultiIter.
;
; write(ax:3);

		mov	cx, 3
		putisize	
		ret

; endfor, writeln;

IterDone:	putcr			;Writeln;
		ret

; endfor, writeln;

MultiDone:	putcr
		inc	bx
		cmp	bx, 5
		jbe	WhlBXle5

; endfor

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends


sseg		segment	para stack 'stack'
stk		word	1024 dup (0)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
