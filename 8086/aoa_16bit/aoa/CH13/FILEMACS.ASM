; FileMacs.asm
;
; This program presents a set of macros that make file I/O with the 
; Standard Library even easier to do.
;
; The main program writes a multiplication table to the file "MyFile.txt".

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

CurOutput	dword	?

Filename	byte	"MyFile.txt",0

i		word	?
j		word	?

TheFile		filevar	{}

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; For-Next macros from Chapter Eight.
; See Chapter Eight for details on how this works.

ForLp		macro	LCV, Start, Stop
		local	ForLoop

		ifndef	$$For&LCV&
$$For&LCV&	=	0
		else
$$For&LCV&	=	$$For&LCV& + 1
		endif

		mov	ax, Start
		mov	LCV, ax

ForLoop		textequ	@catstr($$For&LCV&, %$$For&LCV&)
&ForLoop&:
		mov	ax, LCV
		cmp	ax, Stop
		jg	@catstr($$Next&LCV&, %$$For&LCV&)
		endm



Next		macro	LCV
		local	NextLbl
		inc	LCV
		jmp	@catstr($$For&LCV&, %$$For&LCV&)
NextLbl		textequ	@catstr($$Next&LCV&, %$$For&LCV&)
&NextLbl&:
		endm


; File I/O macros:
;
;
; SetPtr sets up the CurOutput pointer variable.  This macro is called
; by the other macros, it's not something you would normally call directly.
; Its whole purpose in life is to shorten the other macros and save a little
; typing.

SetPtr		macro	fvar
		push	es
		push	di

		mov	di, offset fvar
		mov	word ptr CurOutput, di
		mov	di, seg fvar
		mov	word ptr CurOutput+2, di

		PushOutAdrs
		lesi	FileOutput
		SetOutAdrs
		pop	di
		pop	es
		endm
;
;
;
; fprint-	Prints a string to the display.
;
; Usage:
;		fprint	filevar,"String or bytes to print"
;
; Note: you can supply optional byte or string data after the string above by
;	enclosing the data in angle brackets, e.g., 
;
;		fprint	filevar,<"string to print",cr,lf>
;
; Do *NOT* put a zero terminating byte at the end of the string, the fprint macro
; will do that for you automatically.

fprint		macro	fvar:req, string:req
		SetPtr	fvar

		print
		byte	string
		byte	0

		PopOutAdrs
		endm

; fprintf-	Prints a formatted string to the display.
; fprintff-	Like fprintf, but handles floats as well as other items.
;
; Usage:
;		fprintf	 filevar,"format string", optional data values
;		fprintff filevar,"format string", optional data values
; Examples:
;
;	fprintf	 FileVariable,"i=%d, j=%d\n", i, j
;	fprintff FileVariable,"f=%8.2f, i=%d\n", f, i
;
; Note: if you want to specify a list of strings and bytes for the format string,
;       just surround the items with an angle bracket, e.g.,
;
;	fprintf FileVariable, <"i=%d, j=%d",cr,lf>, i, j
;
;

fprintf		macro	fvar:req, FmtStr:req, Operands:vararg
		setptr	fvar

		printf
		byte	FmtStr
		byte	0

		for	ThisVal, <Operands>
		dword	ThisVal
		endm

		PopOutAdrs
		endm

fprintff	macro	fvar:req, FmtStr:req, Operands:vararg
		setptr	fvar

		printff
		byte	FmtStr
		byte	0

		for	ThisVal, <Operands>
		dword	ThisVal
		endm

		PopOutAdrs
		endm


; F-	This is a generic macro that converts stand-alone (no code stream parameters)
;	stdlib functions into file output routines.  Use it with putc, puts, puti,
;	putu, putl, putisize, putusize, putlsize, putcr, etc.
;
; Usage:
;
;	F	StdLibFunction, FileVariable
;
; Examples:
;
;	mov	al, 'A'
;	F	putc, TheFile
;	mov	ax, I
;	mov	cx, 4
;	F	putisize, TheFile


F		macro	func:req, fvar:req
		setptr	fvar
		func
		PopOutAdrs
		endm		

; WriteLn- Quick macro to handle the putcr operation (since this code calls putcr
; so often).

WriteLn		macro	fvar:req
		F	putcr, fvar
		endm


; FileOutput- Writes the single character in AL to an output file.
; The macros above redirect the standard output to this routine
; to print data to a file.

FileOutput	proc	far
		push	es
		push	di
		push	ds
		mov	di, dseg
		mov	ds, di

		les	di, CurOutput
		fputc

		pop	ds
		pop	di
		pop	es
		ret
FileOutput	endp


; A simple main program that tests the code above.
; This program writes a multiplication table to the file "MyFile.txt"

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

; Rewrite(TheFile, FileName);

		ldxi	FileName
		lesi	TheFile
		fcreate

; writeln(TheFile);
; writeln(TheFile,'    ');
; for i := 0 to 5 do write(TheFile,'|',i:4,' ');
; writeln(TheFile);

		WriteLn	TheFile
		fprint	TheFile,"    "

		forlp	i,0,5
		fprintf	TheFile, "|%4d ", i
		next	i
		WriteLn	TheFile

; for j := -5 to 5 do begin
;
;	write(TheFile,'----');
;	for i := 0 to 5 do write(TheFile, '+-----');
;	writeln(TheFile);
;
;	write(j:3, ' |');
;	for i := 0 to 5 do write(i*j:4, ' |);
;	writeln(TheFile);
;
; end;

		forlp	j,-5,5

		fprint	TheFile,"----"
		forlp	i,0,5
		fprintf	TheFile,"+-----"
		next	i
		fprint	TheFile,<"+",cr,lf>

		fprintf	TheFile, "%3d |", j

		forlp	i,0,5

		mov	ax, i
		imul	j
		mov	cx, 4
		F	putisize, TheFile
		fprint	TheFile, " |"

		next	i
		Writeln	TheFile

		next	j
		WriteLn	TheFile

; Close(TheFile);

		lesi	TheFile
		fclose


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
