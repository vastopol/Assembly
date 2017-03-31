; EX12_2.asm
;
; Program to demonstrate the ENTER and LEAVE instructions in Chapter 12.
;
; This program simulates the following Pascal code:
;
; program EnterLeave;
; var i:integer;
;
;    procedure Lex1;
;    var j:integer;
;
;	procedure Lex2;
;	var k:integer;
;
;	    procedure Lex3;
;	    var m:integer;
;
;		procedure Lex4;
;		var n:integer;
;		begin
;
;			writeln('Lex4');
;			for i:= 0 to 3 do
;			    for j:= 0 to 2 do
;				write('(',i,',',j,') ');
;			writeln;
;			for k:= 1 downto 0 do
;			  for m:= 1 downto 0 do
;			    for n := 0 to 1 do
;				write('(',m,',',k,',',n,') ');
;			writeln;
;		end;
;
;	    begin {Lex3}
;
;		writeln('Lex3');
;		for i := 0 to 1 do
;		    for j := 0 to 1 do
;			for k := 0 to 1 do
;			    for m := 0 to 1 do
;				writeln(i,j,k,m);
;
;		Lex4;
;
;	    end; {Lex3}
;
;	begin {Lex2}
;
;	    writeln('Lex2');
;	    for i := 1 downto 0 do
;		for j := 0 to 1 do
;		    for k := 1 downto 0 do
;			write(i,j,k,' ');
;	    writeln;
;
;	    Lex3;
;
;	end; {Lex2}
;
;    begin {Lex1}
;
;	writeln('Lex1');
;	Lex2;
;
;    end; {Lex1}
;
; begin {Main (lex0)}
;
;	writeln('Main Program');
;	Lex1;
;
; end.
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

		.286				;Allow ENTER & LEAVE.

; Common equates all the procedures use:

wp		textequ	<word ptr>
disp1		textequ	<word ptr [bp-2]>
disp2		textequ	<word ptr [bp-4]>
disp3		textequ	<word ptr [bp-6]>

; Note: the data segment and the stack segment are one and the same in this
; program.  This is done to allow the use of the [bx] addressing mode when
; referencing local and intermediate variables without having to use a
; stack segment prefix.

sseg		segment	para stack 'stack'

i		word	?			;Main program variable.

stk		word	2046 dup (0)

sseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:sseg, ss:sseg


; Main's activation record looks like this:
;
;	| return address |<- SP, BP
;	|----------------|


Main		proc
		mov	ax, ss		;Make SS=DS to simplify addressing (there
		mov	ds, ax		; will be no need to stick "SS:" in front
		mov	es, ax		; of addressing modes like "[bx]").

		print
		byte	"Main Program",cr,lf,0
		call	Lex1
Quit:		ExitPgm			;DOS macro to quit program.
Main		endp



; Lex1's activation record looks like this:
;
;	| return address |
;	|----------------|
;	| Dynamic Link   | <- BP
;	|----------------|
;	| Lex1's AR Ptr  |  | Display
;	|----------------|
;	| J Local var    | <- SP  (BP-4)
;	|----------------|

Lex1_J		textequ	<word ptr [bx-4]>

Lex1		proc	near
		enter	2, 1		;A 2 byte local variable at lex level 1.

		nop			;Spacer instruction for single stepping.

		print
		byte	"Lex1",cr,lf,0
		call	Lex2
		leave
		ret
Lex1		endp



; Lex2's activation record looks like this:
;
;	| return address |
;	|----------------|
;	| Dynamic Link   | <- BP
;	|----------------|
;	| Lex1's AR Ptr  |  |
;	|----------------|  | Display
;	| Lex2's AR Ptr  |  |
;	|----------------|
;	| K Local var    | <- SP (BP-6)
;	|----------------|
;
;	    writeln('Lex2');
;	    for i := 1 downto 0 do
;		for j := 0 to 1 do
;		    for k := 1 downto 0 do
;			write(i,j,k,' ');
;	    writeln;
;
;	    Lex3;

Lex2_k		textequ	<word ptr [bx-6]>
k		textequ	<word ptr [bp-6]>

Lex2		proc	near
		enter	2, 2		;A 2-byte local variable at lex level 2.

		nop			;Spacer instruction for single stepping.

		print
		byte	"Lex2",cr,lf,0

		mov	i, 1
ForLpI:		mov	bx, disp1	;"J" is at lex level one.
		mov	Lex1_J, 0
ForLpJ:		mov	k, 1		;"K" is local.

ForLpK:		mov	ax, i
		puti
		mov	bx, disp1
		mov	ax, Lex1_J
		puti
		mov	ax, k
		puti
		mov	al, ' '
		putc

		dec	k		;Decrement from 1->0 and quit
		jns	ForLpK		; if we hit -1.

		mov	bx, disp1
		inc	Lex1_J
		cmp	Lex1_J, 2
		jb	ForLpJ

		dec	i
		jns	ForLpI

		putcr
		call	Lex3

		leave
		ret
Lex2		endp

		

; Lex3's activation record looks like this:
;
;	| return address |
;	|----------------|
;	| Dynamic Link   | <- BP
;	|----------------|
;	| Lex1's AR Ptr  |  |
;	|----------------|  | 
;	| Lex2's AR Ptr  |  | Display
;	|----------------|  |
;	| Lex3's AR Ptr  |  |
;	|----------------|
;	| M Local var    | <- SP (BP-8)
;	|----------------|
;
;		writeln('Lex3');
;		for i := 0 to 1 do
;		    for j := 0 to 1 do
;			for k := 0 to 1 do
;			    for m := 0 to 1 do
;				writeln(i,j,k,m);
;
;		Lex4;
;

Lex3_M		textequ	<word ptr [bx-8]>
m		textequ	<word ptr [bp-8]>

Lex3		proc	near
		enter	2, 3		;2-byte variable at lex level 3.

		nop			;Spacer instruction for single stepping.

		print
		byte	"Lex3",cr,lf,0

		mov	i, 0
ForILp:		mov	bx, disp1
		mov	Lex1_J, 0
ForJlp:		mov	bx, disp2
		mov	Lex2_K, 0
ForKLp:		mov	m, 0
ForMLp:		mov	ax, i
		puti
		mov	bx, disp1
		mov	ax, Lex1_J
		puti
		mov	bx, disp2
		mov	ax, Lex2_k
		puti
		mov	ax, m
		puti
		putcr

		inc	m
		cmp	m, 2
		jb	ForMLp

		mov	bx, disp2
		inc	Lex2_K
		cmp	Lex2_K, 2
		jb	ForKLp

		mov	bx, disp1
		inc	Lex1_J
		cmp	Lex1_J, 2
		jb	ForJLp

		inc	i
		cmp	i, 2
		jb	ForILp

		call	Lex4

		leave
		ret
Lex3		endp


; Lex4's activation record looks like this:
;
;	| return address |
;	|----------------|
;	| Dynamic Link   | <- BP
;	|----------------|
;	| Lex1's AR Ptr  |  |
;	|----------------|  | 
;	| Lex2's AR Ptr  |  |
;	|----------------|  | Display
;	| Lex3's AR Ptr  |  |
;	|----------------|  |
;	| Lex4's AR Ptr  |  |
;	|----------------|
;	| N Local var    | <- SP (BP-10)
;	|----------------|
;
;
;			writeln('Lex4');
;			for i:= 0 to 3 do
;			    for j:= 0 to 2 do
;				write('(',i,',',j,') ');
;			writeln;
;			for k:= 1 downto 0 do
;			  for m:= 1 downto 0 do
;			    for n := 0 to 1 do
;				write('(',m,',',k,',',n,') ');
;			writeln;

n		textequ	<word ptr [bp-10]>

Lex4		proc	near
		enter	2, 4		;2-byte local variable at lex level 4.

		nop			;Spacer instruction for single stepping.

		print
		byte	"Lex4",cr,lf,0

		mov	i, 0
ForILp:		mov	bx, disp1
		mov	Lex1_J, 0
ForJLp:		mov	al, '('
		putc
		mov	ax, i
		puti
		mov	al, ','
		putc
		mov	ax, Lex1_J	;Note that BX still contains disp1.
		puti
		print
		byte	") ",0

		inc	Lex1_J		;BX still contains disp1.
		cmp	Lex1_J, 3
		jb	ForJLp

		inc	i
		cmp	i, 4
		jb	ForILp

		putcr

		mov	bx, disp2
		mov	Lex2_K, 1
ForKLp:		mov	bx, disp3
		mov	Lex3_M, 1
ForMLp:		mov	n, 0
ForNLp:		mov	al, '('
		putc

		mov	bx, disp3
		mov	ax, Lex3_M
		puti
		mov	al, ','
		putc
		mov	bx, disp2
		mov	ax, Lex2_K
		puti
		mov	al, ','
		putc
		mov	ax, n
		puti
		print
		byte	") ",0

		inc	n
		cmp	n, 2
		jb	ForNLp

		mov	bx, disp3
		dec	Lex3_M
		jns	ForMLp

		mov	bx, disp2
		dec	Lex2_K
		jns	ForKLp

		leave
		ret
Lex4		endp

cseg            ends


zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
