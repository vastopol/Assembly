; EX12_3.asm
;
; Ex12_3.asm
;
; This program demonstrates different parameter passing methods.  
; It corresponds to the following (pseudo) Pascal code:
;
;
; program main;
; var	i:integer;
;	a:array[0..255] of integer;
;	b:array[0..255] of unsigned;
;
; function LTint(int1, int2:integer):boolean;
; begin
;	LTint := int1 < int2;
; end;
;
; procedure SwapInt(var int1, int2:integer);
; var temp:integer;
; begin
;	temp := int1;
;	int1 := int2;
;	int2 := temp;
; end;
;
; function LTunsigned(uns1, uns2:unsigned):boolean;
; begin
;	LTunsigned := uns1 < uns2;
; end;
;
; procedure SwapUnsigned(uns1, uns2:unsigned);
; var temp:unsigned;
; begin
;	temp := uns1;
;	uns1 := uns2;
;	uns2 := temp;
; end;
;
; (* The following is a simple Bubble sort that will sort arrays containing *)
; (* arbitrary data types.                                                  *)
;
; procedure sort(data:array; elements:integer; function LT:boolean; procedure swap);
; var i,j:integer;
; begin
;
;	for i := 0 to elements-1 do
;	    for j := i+1 to elements do
;		if (LT(data[j], data[i])) then swap(data[i], data[j]);
; end;
;
;
; begin
;
;	for i := 0 to 255 do A[i] := 128-i;
;	for i := 0 to 255 do B[i] := 33000-i;
;	sort(A, 256, LTint, SwapInt);
;	sort(B, 256, LTunsigned, SwapUnsigned);
;
;	for i := 0 to 255 do
;	begin
;		if (i mod 8) = 0 then writeln;
;		write(A[i]:7);
;	end;
;
;	for i := 0 to 255 do
;	begin
;		if (i mod 8) = 0 then writeln;
;		write(B[i]:7);
;	end;
;
; end;

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.386
		option		segment:use16

wp		textequ		<word ptr>


dseg		segment	para public 'data'
A		word	256 dup (?)
B		word	256 dup (?)
dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg, ss:sseg


; function LTint(int1, int2:integer):boolean;
; begin
;	LTint := int1 < int2;
; end;
;
; LTint's activation record looks like this:
;
;	|----------------|
;	|      int1      |
;	|----------------|
;	|      int2      |
;	|----------------|
;	| return address |
;	|----------------|
;	|    old BP      |<- SP, BP
;	|----------------|

int1		textequ	<word ptr [bp+6]>
int2		textequ	<word ptr [bp+4]>

LTint		proc	near
		push	bp
		mov	bp, sp
		
		mov	ax, int1	;Compare the two parameters
		cmp	ax, int2	; and return true if int1<int2.
		setl	al		;Signed comparison here.
		mov	ah, 0		;Be sure to clear H.O. byte.

		pop	bp
		ret	4
LTint		endp


; Swap's activation record looks like this:
;
;	|----------------|
;	|     Address    |
;	|---    of    ---|
;	|      int1      |
;	|----------------|
;	|     Address    |
;	|---    of    ---|
;	|      int2      |
;	|----------------|
;	| return address |
;	|----------------|
;	|    old BP      |<- SP, BP
;	|----------------|
;
; The temporary variable is kept in a register.
;
; Note that swapping integers or unsigned integers can be done
; with the same code since the operations are identical for
; either type.
;
; procedure SwapInt(var int1, int2:integer);
; var temp:integer;
; begin
;	temp := int1;
;	int1 := int2;
;	int2 := temp;
; end;
;
; procedure SwapUnsigned(uns1, uns2:unsigned);
; var temp:unsigned;
; begin
;	temp := uns1;
;	uns1 := uns2;
;	uns2 := temp;
; end;
;

int1		textequ	<dword ptr [bp+8]>
int2		textequ	<dword ptr [bp+4]>

SwapInt		proc	near
		push	bp
		mov	bp, sp
		push	es
		push	bx

		les	bx, int1		;Get address of int1 variable.
		mov	ax, es:[bx]		;Get int1's value.
		les	bx, int2		;Get address of int2 variable.
		xchg	ax, es:[bx]		;Swap int1's value with int2's

		les	bx, int1		;Get the address of int1 and
		mov	es:[bx], ax		; store int2's value there.

		pop	bx
		pop	es
		pop	bp
		ret	8
SwapInt		endp



; LTunsigned's activation record looks like this:
;
;	|----------------|
;	|      uns1      |
;	|----------------|
;	|      uns2      |
;	|----------------|
;	| return address |
;	|----------------|
;	|    old BP      |<- SP, BP
;	|----------------|
;
; function LTunsigned(uns1, uns2:unsigned):boolean;
; begin
;	LTunsigned := uns1 < uns2;
; end;

uns1		textequ	<word ptr [bp+6]>
uns2		textequ	<word ptr [bp+4]>

LTunsigned	proc	near
		push	bp
		mov	bp, sp
		
		mov	ax, uns1	;Compare uns1 with uns2 and
		cmp	ax, uns2	; return true if uns1<uns2.
		setb	al		;Unsigned comparison.
		mov	ah, 0		;Return 16-bit boolean.

		pop	bp
		ret	4
LTunsigned	endp



; Sort's activation record looks like this:
;
;	|----------------|
;	|     Data's     |
;	|---          ---|
;	|    Address     |
;	|----------------|
;	|   Elements     |
;	|----------------|
;	|      LT's      |
;	|---          ---|
;	|    Address     |
;	|----------------|
;	|     Swap's     |
;	|---          ---|
;	|    Address     |
;	|----------------|
;	| return address |
;	|----------------|
;	|    old BP      |<- SP, BP
;	|----------------|
;
; procedure sort(data:array; elements:integer; function LT:boolean; procedure swap);
; var i,j:integer;
; begin
;
;	for i := 0 to elements-1 do
;	    for j := i+1 to elements do
;		if (LT(data[j], data[i])) then swap(data[i], data[j]);
; end;


data		textequ	<dword ptr [bp+10]>
elements	textequ	<word ptr [bp+8]>
funcLT		textequ	<word ptr [bp+6]>
procSwap	textequ	<word ptr [bp+4]>

i		textequ	<word ptr [bp-2]>
j		textequ	<word ptr [bp-4]>

sort		proc	near
		push	bp
		mov	bp, sp
		sub	sp, 4
		push	es
		push	bx

		mov	i, 0
ForILp:		mov	ax, i			;Compare with elements-1.
		inc	ax			;Do this by incrementing I
		cmp	ax, Elements		; and comparing with Elements.
		jae	IDone

		mov	j, ax			;Put i+1 into J.
ForJLp:		mov	ax, j
		cmp	ax, Elements
		jae	JDone

		les	bx, data		;Push the value of
		mov	si, j			; data[j] onto the
		add	si, si			; stack.
		push	es:[bx+si]

		les	bx, data		;Push the value of
		mov	si, i			; data[i] onto the
		add	si, si			; stack.
		push	es:[bx+si]

		call	FuncLT			;See if data[i] < data[j]
		cmp	ax, 0			;Test boolean result.
		je	NextJ

		push	wp data+2		;Pass data[i] by reference.
		mov	ax, i
		add	ax, ax
		add	ax, wp data
		push	ax

		push	wp data+2		;Pass data[j] by reference.
		mov	ax, j
		add	ax, ax
		add	ax, wp data
		push	ax

		call	ProcSwap

NextJ:		inc	j
		jmp	ForJLp

JDone:		inc	i
		jmp	ForILp

IDone:		pop	bx
		pop	es
		mov	sp, bp
		pop	bp
		ret	10
sort		endp




		
; Main's activation record looks like this:
;
;	| return address |<- SP, BP
;	|----------------|
;
; begin
;
;	for i := 0 to 255 do A[i] := 128-i;
;	for i := 0 to 255 do B[i] := 33000-i;
;	sort(A, 256, LTint, SwapInt);
;	sort(B, 256, LTunsigned, SwapUnsigned);
;
;	for i := 0 to 255 do
;	begin
;		if (i mod 8) = 0 then writeln;
;		write(A[i]:7);
;	end;
;
;	for i := 0 to 255 do
;	begin
;		if (i mod 8) = 0 then writeln;
;		write(B[i]:7);
;	end;
;
; end;

Main		proc
		mov	ax, dseg	;Initialize the segment registers.
		mov	ds, ax
		mov	es, ax

; Note that the following code merges the two initialization for loops
; into a single loop.

		mov	ax, 128
		mov	bx, 0
		mov	cx, 33000
ForILp:		mov	A[bx], ax
		mov	B[bx], cx
		add	bx, 2
		dec	ax
		dec	cx
		cmp	bx, 256*2
		jb	ForILp

		push	ds			;Seg address of A
		push	offset A		;Offset of A
		push	256			;# of elements in A
		push	offset LTint		;Address of compare routine
		push	offset SwapInt		;Address of swap routine
		call	Sort


		push	ds			;Seg address of B
		push	offset B		;Offset of B
		push	256			;# of elements in A
		push	offset LTunsigned	;Address of compare routine
		push	offset SwapInt		;Address of swap routine
		call	Sort

; Print the values in A.

		mov	bx, 0
ForILp2:	test	bx, 0Fh			;See if (I mod 8) = 0
		jnz	NotMod			; note: BX mod 16 = I mod 8.
		putcr
NotMod:		mov	ax, A[bx]
		mov	cx, 7
		putisize
		add	bx, 2
		cmp	bx, 256*2
		jb	ForILp2

; Print the values in B.

		putcr

		mov	bx, 0
ForILp3:	test	bx, 0Fh			;See if (I mod 8) = 0
		jnz	NotMod2			; note: BX mod 16 = I mod 8.
		putcr
NotMod2:	mov	ax, B[bx]
		mov	cx, 7
		putusize
		add	bx, 2
		cmp	bx, 256*2
		jb	ForILp3

Quit:		ExitPgm			;DOS macro to quit program.
Main		endp



cseg            ends


sseg		segment	para stack 'stack'
stk		word	256 dup (0)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
