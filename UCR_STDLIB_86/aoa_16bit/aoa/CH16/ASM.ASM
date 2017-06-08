; ASM.ASM
;
; This is a simple, single line, mini-assembler for an earlier
; version of the x86 processor. It converts strings containing valid 
; (old) x86 assembly code into a sequence of hex values corresponding 
; to the opcode and operands for the given instruction.

		.xlist
		include 	stdlib.a
		matchfuncs
		includelib	stdlib.lib
		.list




dseg		segment	para public 'data'


; Some sample statements to assemble:

Str1		byte	"load ax, 0",0
Str2		byte	"load ax, bx",0
Str3		byte	"load ax, ax",0
Str4		byte	"add ax, 15",0
Str5		byte	"sub ax, [bx]",0
Str6		byte	"store bx, [1000]",0
Str7		byte	"load bx, 2000[bx]",0
Str8		byte	"goto 3000",0
Str9		byte	"iflt ax, bx, 100",0
Str10		byte	"halt",0
Str11		byte	"This is illegal",0
Str12		byte	"load ax, store",0
Str13		byte	"store ax, 1000",0
Str14		byte	"ifeq ax, 0, 0",0



; Variables used by the assembler.

AsmConst	dw	0
AsmOpcode	db	0
AsmOprnd1	db	0
AsmOprnd2	db	0



		include	stdsets.a	;Bring in the standard char sets.



; Patterns for the assembler:

; Pattern is (
;	       (load|store|add|sub) reg "," operand |
;	       (ifeq|iflt|ifgt) reg1 "," reg2 "," const |
;	       (get|put) operand |
;	       goto operand |
;	       halt
;	     )
;
; With a few semantic additions (e.g., cannot store to a const).

InstrPat	pattern	{spancset, WhiteSpace,Grp1,Grp1}

Grp1		pattern	{sl_Match2,Grp1Strs, Grp2 ,Grp1Oprnds}
Grp1Strs	pattern	{TryLoad,,Grp1Store}
Grp1Store	pattern	{TryStore,,Grp1Add}
Grp1Add		pattern	{TryAdd,,Grp1Sub}
Grp1Sub		pattern	{TrySub}

; Patterns for the LOAD, STORE, ADD, and SUB instructions.

LoadPat		pattern	{MatchStr,LoadInstr2}
LoadInstr2	byte	"LOAD",0

StorePat	pattern	{MatchStr,StoreInstr2}
StoreInstr2	byte	"STORE",0

AddPat		pattern	{MatchStr,AddInstr2}
AddInstr2	byte	"ADD",0

SubPat		pattern	{MatchStr,SubInstr2}
SubInstr2	byte	"SUB",0

; Patterns for the group one (LOAD/STORE/ADD/SUB) instruction operands:

Grp1Oprnds	pattern	{spancset,WhiteSpace,Grp1reg,Grp1reg}
Grp1Reg		pattern	{MatchReg,AsmOprnd1,,Grp1ws2}
Grp1ws2		pattern	{spancset,WhiteSpace,Grp1Comma,Grp1Comma}
Grp1Comma	pattern	{MatchChar,',',0,Grp1ws3}
Grp1ws3		pattern	{spancset,WhiteSpace,Grp1Op2,Grp1Op2}
Grp1Op2		pattern	{MatchGen,,,EndOfLine}
EndOfLine	pattern	{spancset,WhiteSpace,NullChar,NullChar}
NullChar	pattern	{EOS}

Grp1Op2Reg	pattern	{MatchReg,AsmOprnd2}



; Patterns for the group two instructions (IFEQ, IFLT, IFGT):

Grp2		pattern	{sl_Match2,Grp2Strs, Grp3 ,Grp2Oprnds}
Grp2Strs	pattern	{TryIFEQ,,Grp2IFLT}
Grp2IFLT	pattern	{TryIFLT,,Grp2IFGT}
Grp2IFGT	pattern	{TryIFGT}

Grp2Oprnds	pattern	{spancset,WhiteSpace,Grp2reg,Grp2reg}
Grp2Reg		pattern	{MatchReg,AsmOprnd1,,Grp2ws2}
Grp2ws2		pattern	{spancset,WhiteSpace,Grp2Comma,Grp2Comma}
Grp2Comma	pattern	{MatchChar,',',0,Grp2ws3}
Grp2ws3		pattern	{spancset,WhiteSpace,Grp2Reg2,Grp2Reg2}
Grp2Reg2	pattern	{MatchReg,AsmOprnd2,,Grp2ws4}
Grp2ws4		pattern	{spancset,WhiteSpace,Grp2Comma2,Grp2Comma2}
Grp2Comma2	pattern	{MatchChar,',',0,Grp2ws5}
Grp2ws5		pattern	{spancset,WhiteSpace,Grp2Op3,Grp2Op3}
Grp2Op3		pattern	{ConstPat,,,EndOfLine}


; Patterns for the IFEQ, IFLT, and IFGT instructions.

IFEQPat		pattern	{MatchStr,IFEQInstr2}
IFEQInstr2	byte	"IFEQ",0

IFLTPat		pattern	{MatchStr,IFLTInstr2}
IFLTInstr2	byte	"IFLT",0

IFGTPat		pattern	{MatchStr,IFGTInstr2}
IFGTInstr2	byte	"IFGT",0


; Grp3 Patterns:

Grp3		pattern	{sl_Match2,Grp3Strs, Grp4 ,Grp3Oprnds}
Grp3Strs	pattern	{TryGet,,Grp3Put}
Grp3Put		pattern	{TryPut,,Grp3GOTO}
Grp3Goto	pattern	{TryGOTO}


; Patterns for the GET and PUT instructions.

GetPat		pattern	{MatchStr,GetInstr2}
GetInstr2	byte	"GET",0

PutPat		pattern	{MatchStr,PutInstr2}
PutInstr2	byte	"PUT",0

GOTOPat		pattern	{MatchStr,GOTOInstr2}
GOTOInstr2	byte	"GOTO",0



; Patterns for the group three (PUT/GET/GOTO) instruction operands:

Grp3Oprnds	pattern	{spancset,WhiteSpace,Grp3Op,Grp3Op}
Grp3Op		pattern	{MatchGen,,,EndOfLine}


; Patterns for the group four instruction (HALT).

Grp4		pattern	{TryHalt,,,EndOfLine}

HaltPat		pattern	{MatchStr,HaltInstr2}
HaltInstr2	byte	"HALT",0




; Patterns to match the four non-register addressing modes:

BXIndrctPat	pattern	{MatchStr,BXIndrctStr}
BXIndrctStr	byte	"[BX]",0

BXIndexedPat	pattern	{ConstPat,,,BXIndrctPat}

DirectPat	pattern	{MatchChar,'[',,DP2}
DP2		pattern	{ConstPat,,,DP3}
DP3		pattern	{MatchChar,']'}

ImmediatePat	pattern	{ConstPat}

; Pattern to match a hex constant:

HexConstPat	pattern	{Spancset, xdigits}




dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

store		macro	Where, What
		push	ds
		push	ax
		mov	ax, seg Where
		mov	ds, ax
		mov	Where, What
		pop	ax
		pop	ds
		endm


; Pattern matching routines for the assembler.

; Compare against the "LOAD" string.

TryLoad		proc	far
		push	dx
		push	si
		ldxi    LoadPat
		match2
		jnc	NoTLMatch

		store	AsmOpcode, 0

NoTLMatch:	pop	si
		pop	dx
		ret
TryLoad		endp



; Compare against the "STORE" string.

TryStore	proc	far
		push	dx
		push	si
		ldxi    StorePat
		match2
		jnc	NoTSMatch
		store	AsmOpcode, 1

NoTSMatch:	pop	si
		pop	dx
		ret
TryStore	endp


; Compare against the "ADD" string.

TryAdd		proc	far
		push	dx
		push	si
		ldxi	AddPat
		match2
		jnc	NoTAMatch
		store	AsmOpcode, 2

NoTAMatch:	pop	si
		pop	dx
		ret
TryAdd		endp


; Compare against the "SUB" string.

TrySub		proc	far
		push	dx
		push	si
		ldxi	SubPat
		match2
		jnc	NoTMMatch
		store	AsmOpcode, 3

NoTMMatch:	pop	si
		pop	dx
		ret
TrySub		endp



; Compare against the "IFEQ" string.

TryIFEQ		proc	far
		push	dx
		push	si
		ldxi	IFEQPat
		match2
		jnc	NoIEMatch
		store	AsmOpcode, 4

NoIEMatch:	pop	si
		pop	dx
		ret
TryIFEQ		endp



; Compare against the "IFLT" string.

TryIFLT		proc	far
		push	dx
		push	si
		ldxi	IFLTPat
		match2
		jnc	NoILMatch
		store	AsmOpcode, 5

NoILMatch:	pop	si
		pop	dx
		ret
TryIFLT		endp


; Compare against the "IFGT" string.

TryIFGT		proc	far
		push	dx
		push	si
		ldxi	IFGTPat
		match2
		jnc	NoIGMatch
		store	AsmOpcode, 6

NoIGMatch:	pop	si
		pop	dx
		ret
TryIFGT		endp




; Compare against the "GET" string.

TryGET		proc	far
		push	dx
		push	si
		ldxi	GetPat
		match2
		jnc	NoGMatch
		store	AsmOpcode, 7
		store	AsmOprnd1, 2

NoGMatch:	pop	si
		pop	dx
		ret
TryGET		endp




; Compare against the "PUT" string.

TryPut		proc	far
		push	dx
		push	si
		ldxi	PutPat
		match2
		jnc	NoPMatch
		store	AsmOpcode, 7
		store	AsmOprnd1, 3

NoPMatch:	pop	si
		pop	dx
		ret
TryPUT		endp




; Compare against the "GOTO" string.

TryGOTO		proc	far
		push	dx
		push	si
		ldxi	GOTOPat
		match2
		jnc	NoGMatch
		store	AsmOpcode, 7
		store	AsmOprnd1, 1

NoGMatch:	pop	si
		pop	dx
		ret
TryGOTO		endp




; Compare against the "HALT" string.

TryHalt		proc	far
		push	dx
		push	si
		ldxi	HaltPat
		match2
		jnc	NoHMatch
		store	AsmOpcode, 7
		store	AsmOprnd1, 0
		store	AsmOprnd2, 0

NoHMatch:	pop	si
		pop	dx
		ret
TryHALT		endp




; MatchReg checks to see if we've got a valid register value.  On entry,
; DS:SI points at the location to store the byte opcode (0, 1, 2, or 3) for
; a reasonable register (AX, BX, CX, or DX);  ES:DI points at the string
; containing (hopefully) the register operand, and CX points at the last
; location plus one we can check in the string.
;
; On return, Carry=1 for success, 0 for failure.  ES:AX must point beyond
; the characters which make up the register if we have a match.

MatchReg	proc	far

; ES:DI Points at two characters which should be AX/BX/CX/DX.  Anything
; else is an error.

		cmp	byte ptr es:1[di], 'X'	;Everyone needs this
		jne	BadReg
		xor	ax, ax			;886 "AX" register code.
		cmp	byte ptr es:[di], 'A'	;AX?
		je	GoodReg
		inc	ax
		cmp	byte ptr es:[di], 'B'	;BX?
		je	GoodReg
		inc	ax
		cmp	byte ptr es:[di], 'C'	;CX?
		je	GoodReg
		inc	ax
		cmp	byte ptr es:[di], 'D'	;DX?
		je	GoodReg
BadReg:		clc
		mov	ax, di
		ret

GoodReg:
		mov	ds:[si], al		;Save register opcode.
		lea	ax, 2[di]		;Skip past register.
		cmp	ax, cx			;Be sure we didn't go
		ja	BadReg			; too far.
		stc
		ret
MatchReg	endp



; MatchGen-	Matches a general addressing mode.  Stuffs the appropriate
;		addressing mode code into AsmOprnd2.  If a 16-bit constant
;		is required by this addressing mode, this code shoves that
;		into the AsmConst variable.

MatchGen	proc	far
		push	dx
		push	si

		ldxi	Grp1Op2Reg
		match2
		jc	MGDone

		ldxi	BXIndrctPat
		match2
		jnc	TryBXIndexed
		store	AsmOprnd2, 4
		jmp	MGDone

TryBXIndexed:
		ldxi	BXIndexedPat
		match2
		jnc	TryDirect
		store	AsmOprnd2, 5
		jmp	MGDone

TryDirect:
		ldxi	DirectPat
		match2
		jnc	TryImmediate
		store	AsmOprnd2, 6
		jmp	MGDone

TryImmediate:
		ldxi	ImmediatePat
		match2
		jnc	MGDone
		store	AsmOprnd2, 7

MGDone:
		pop	si
		pop	dx
		ret
MatchGen	endp



; ConstPat-	Matches a 16-bit hex constant.  If it matches, it converts
;		the string to an integer and stores it into AsmConst.

ConstPat	proc	far
		push	dx
		push	si
		ldxi	HexConstPat
		match2
		jnc	CPDone

		push	ds
		push	ax
		mov	ax, seg AsmConst
		mov	ds, ax
		atoh
		mov	AsmConst, ax
		pop	ax
		pop	ds
		stc

CPDone:		pop	si
		pop	dx
		ret
ConstPat	endp



; Assemble-	This code assembles the instruction that ES:DI points
;		at and displays the hex opcode(s) for that instruction.

Assemble	proc	near
		print
		byte	"Assembling: ",0
		strupr
		puts
		putcr

		ldxi	InstrPat
		xor	cx, cx
		match
		jnc	SyntaxError

; Quick check for illegal instructions:

		cmp	AsmOpcode, 7		;Special/Get instr.
		jne	TryStoreInstr
		cmp	AsmOprnd1, 2		;GET opcode
		je	SeeIfImm
		cmp	AsmOprnd1, 1		;Goto opcode
		je	IsGOTO

TryStoreInstr:	cmp	AsmOpcode, 1		;Store Instruction
		jne	NotStoreInstr

SeeIfImm:	cmp	AsmOprnd2, 7		;Immediate Addressing Mode
		jne	NotStoreInstr
		print
		db	"Syntax error: store/get immediate not allowed."
		db	"  Try Again",cr,lf,0
		jmp	ASMDone

IsGOTO:		cmp	AsmOprnd2, 7		;Immediate mode for GOTO
		je	InstrOkay
		print
		db	"Syntax error: GOTO only allows immediate mode.",cr,lf
		db	0
		jmp	ASMDone

NotStoreInstr:

InstrOkay:	mov	al, AsmOpcode
		shl	al, 1
		shl	al, 1
		or	al, AsmOprnd1
		shl	al, 1
		shl	al, 1
		shl	al, 1
		or	al, AsmOprnd2
		puth
		cmp	AsmOpcode, 4		;IFEQ instruction
		jb	SimpleInstr
		cmp	AsmOpcode, 6		;IFGT instruction
		jbe	PutConstant

SimpleInstr:	cmp	AsmOprnd2, 5
		jb      ASMDone
PutConstant:	mov	al, ' '
		putc
		mov	ax, ASMConst
		puth
		mov	al, ' '
		putc
		xchg	al, ah
		puth
		jmp	ASMDone

SyntaxError:	print
		db	"Syntax error in instruction."
		db	cr,lf,0


ASMDone:	putcr
		ret
Assemble	endp





Main		proc
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
		meminit


		lesi	Str1
		call	Assemble
		lesi	Str2
		call	Assemble
		lesi	Str3
		call	Assemble
		lesi	Str4
		call	Assemble
		lesi	Str5
		call	Assemble
		lesi	Str6
		call	Assemble
		lesi	Str7
		call	Assemble
		lesi	Str8
		call	Assemble
		lesi	Str9
		call	Assemble
		lesi	Str10
		call	Assemble
		lesi	Str11
		call	Assemble
		lesi	Str12
		call	Assemble
		lesi	Str13
		call	Assemble
		lesi	Str14
		call	Assemble


Quit:		ExitPgm
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main


