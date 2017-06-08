;****************************************************************************
;
; SIM886- Simulator/interpreter for 886 processor.
;
; Author: Randall Hyde
; Date:	  7/20/92
;
; Note: This is a MASM 6.0 program.  Any attempt to assemble this with a
; 	different assembler may fail.  In particular, MASM 5.1 will
;	probably produce several "jump out of range" errors since MASM 6.0
;	handles this problem automatically and I've used this capability
;	throughout this program.
;
; Version 2.0 1/11/95
;
;	Added memory-mapped I/O to locations FFE0..FFEF and FFF8..FFFF
;	to support the circuitry in the new version of the lab manual.
;
;	Also added "I" command to allow input from a user specified
;	text file.
;
;	Also added "C" command to capture output to the display.  This
;	allows students to redirect output to a file if they don't have
;	a printer connected to their machine.
;
;	Added the "W" command to let the user specify the number of wait
;	states on each memory access.
;
;	Added the "Z" command to zero the global cycle counter.
;
;	Modified "R" command to let the user specify a register value.
;
;	Modified GOTO instruction to allow indirect gotos.


		.xlist
		include 	stdlib.a
		matchfuncs
		includelib	stdlib.lib
		.list




dseg		segment	para public 'data'


RegOp		dd	0		;Pts at 886 regs in 8086 memory space
EffectiveAdrs	dd	0		;Points at operand in 8086 mem space

OperandValue	dw	0		;Contains value of 886 instr operand.
Oprnd2Value	dw	0		;Contains value of 886 register.
Cycle		dw	0		;Counts cycles in an instruction.
GlobalCycles	dw	0		;Total number of cycles.
InstrOperand	dw	0		;16-bit const following instr.
Result		dw	0		;Holds sum/difference from Add/Sub


AdrsMode	db	0		;Decoded 886 addressing mode.
InstrCode	db	0		;Decoded 886 opcode.
Register	db	0		;Decode 886 register.
Opcode		db	0		;Hold undecoded instruction.


; "CPU" registers.  They *must* appear in this order.

regax		dw	0
regbx		dw	0
regcx		dw	0
regdx		dw	0
regip		dw	0

; Debugger/emulator variables

EditAdrs	dw	0		;Points at next address to modify.
AsmAdrs		dw	0		;Points at next location to assemble.
UnAsmAdrs	dw	0		;Points at next address to disassemble
DumpAdrs	dw	0		;Points at next address to dump.
InstrCnt	dw	0		;Number of instructions executed.
LastCmd		db	0		;Contains last command character.
AbortInstr	db	0

; Variables used by the assembler.

AsmConst	dw	0
AsmOpcode	db	0
AsmOprnd1	db	0
AsmOprnd2	db	0


; Note: InstrStrPtrs cannot appear at offset zero in this segment!
;	Each entry points to an appropriate string.  This gets used by
;	the disassembler.

		even
InstrStrPtrs	dd	LoadInstr
		dd	StoreInstr
		dd	AddInstr
		dd	SubInstr
		dd	IfeqInstr
		dd	IfltInstr
		dd	IfgtInstr
		dd	0

; Each of the following points to a string which corresponds to a register.
; The disassembler uses these strings.

RegisterStrs	dd	axreg
		dd	bxreg
		dd	cxreg
		dd	dxreg

axreg		db	"ax",0
bxreg		db	"bx",0
cxreg		db	"cx",0
dxreg		db	"dx",0


LoadInstr	db	"load   ",0
StoreInstr	db	"store  ",0
AddInstr	db	"add    ",0
SubInstr	db	"sub    ",0
IfeqInstr	db	"ifeq   ",0
IfltInstr	db	"iflt   ",0
IfgtInstr	db	"ifgt   ",0

HaltInstr	db	"halt   ",0
GotoInstr	db	"goto   ",0
GetInstr	db	"get    ",0
PutInstr	db	"put    ",0



; Hardware stuff:

OutPort		word	?		;Parallel port base address.
InPort		word	?		;Base address plus one.

WaitStates	word	0		;# of wait states on each mem access.


; The following are the bit patterns we get back from the parallel port
; if the switches are in the proper positions.

SwVals		byte	01110000b	;Bit value if sw A is closed
		byte	01101000b	;Bit value if sw B is closed
		byte	01011000b	;Bit value if sw C is closed
		byte	00111000b	;Bit value if sw D is closed



; File I/O Stuff:

InputFile	FileVar	{}
OutputFile	FileVar	{}
InputActive	byte	0
OutputActive	byte	0
FileName	byte	128 dup (0)

	     
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





; The memory segment represents the 64K available to the 886 processor.
; Initializing it to 0E0h sets each byte to the 886 HALT instruction.

Memory		segment	para public '886'
		db	0fffeh dup (0e0h)
Memory		ends





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg



		public	PSP
PSP		dw	?		;Required by MemInit.


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



;****************************************************************************

; Help- Displays some instructions which describe how to use this program.

Help		proc	near
		print
		db	"Available commands:",cr,lf

		db	"E <adrs>  Enter bytes.                 "
		db	"D <adrs>  Display bytes. "
		db	cr,lf

		db	"U <adrs>  Unassemble instructions.     "
		db	"A <adrs>  Assembles instructions."
		db	cr,lf

		db	"R         Displays CPU registers.      "
		db	"Rxx <val> Sets register xx to val."
		db	cr,lf

		db	"G <adrs>  Execute program.             "
		db	"T <adrs>  Traces instruction."
		db	cr,lf

		db	"I <file>  Input commands from file.    "
		db	"Z         Zeros global cycle counter."
		db	cr,lf

		db	"C <file>  Writes all output to file.   "
		db	"X         Turns off file capture."
		db	cr,lf

		db	"W <count> Number of wait states.       "
		db	cr,lf

		db	"?         Displays this help message",cr,lf
		db	"<enter>   Repeats last command",cr,lf
		db	"Q         Quits and returns to DOS",cr,lf
		db	cr,lf
		db	"All values are hexadecimal and optional.  Default "
		db	"value is last address."
		db	cr,lf,lf,0
		ret
Help		endp



; BlkDel-	Deletes blanks from an input string.  Assumes ES:[bx+di]
;		points at a string.  Increments BX past any spaces in the
;		string

BlkDel		proc	near
		cmp	byte ptr es:[di][bx], ' '
		jne	BDDone
		inc	bx
		jmp	BlkDel
BDDone:		ret
BlkDel		endp



; GetAdrs-	Assumes es:[di][bx] is pointing at an optional hexadecimal
;		value.  If this value is present, GetAdrs returns the
;		corresonding value in AX.  If not, GetAdrs returns the
;		value of AX unchanged (AX is supposed to contain the default
;		address upon entry).

GetAdrs		proc	near
		push	ax		;Save just in case.
		push	di
		call	blkDel
		add	di, bx		;ES:DI must point at value to use ATOH
		mov	al, es:[di]

		isxdigit		;Do we have a hex digit?
		jne	UseDefault	;If not, use the default value.

		atoh			;Convert, if possible.
		jc	UseDefault
		pop	di		;restore ptr to start of string.
		add	sp, 2		;Ignore default value on TOS.
		ret

UseDefault:	pop	di
		pop	ax		;Retrieves default value.
		ret
GetAdrs		endp



; PuthSpc-	Prints a byte as two hex digits followed by a space.

PuthSpc		proc	near
		push	ax
		puth
		mov	al, " "
		putc
		pop	ax
		ret
PuthSpc		endp





; DisasmCX-	Disassembles CX instructions at the current unassemble
;		address.

DisasmCX	proc	near
		inc	cx		;So loop instr counts off proper
DisLp:		loop	DoDisLp		; number of instructions.
		ret

; The following code segment disassembles exactly one instruction and then
; updates UnAsmAdrs as appropriate (by one or by three depending on the
; length of the instruction).

DoDisLp:	mov	ax, Memory	;Point ES at 886 memory space.
		mov	es, ax
		mov	bx, UnAsmAdrs	;Get address of opcode to disassemble.

		mov	ax, bx		;Print the address of the current
		putw			; instruction.
		print
		db	": ",0

		mov	al, es:[bx]	;Get opcode
		mov	ah, al		;Save opcode
		mov	Opcode, al	;Save again!
		call	PuthSpc		;Output opcode

; Decode the addressing mode to see if this is a one byte or three
; byte instruction.

		cmp	al, 80h		;Kludge for the IFxx instructions
		jb	TrySize		;	    .
		cmp	al, 0e0h	;	    .
		jb	ThreeBytes	;	    .

TrySize:	and	al, 111b
		cmp	al, 5		;three byte opcode
		jb	OneByteOpcode

ThreeBytes:	mov	al, es:[bx+1]	;We have a three byte instr,
		call	PuthSpc		; so we need to output the
		mov	al, es:[bx+2]	; 16-bit constant following the
		call	PuthSpc		; opcode here.
		jmp	PutInstruct

OneByteOpcode:	print			;If not a 3 byte instr, output spaces
		db	"      ",0	; rather than the 16-bit const here.


; Output the instruction mnemonic down here.

PutInstruct:	mov	al, ah		;Get opcode and use it as an index
		shr	al, 1		; into the InstrStrPtrs array to
		shr	al, 1		; fetch a pointer to the string for
		shr	al, 1		; this instruction.
		and	al, 11100b	;Instruction code * 4
		mov	bl, al
		mov	bh, 0
		les	di, InstrStrPtrs[bx] ;Ptr to instruction.
		cmp	di, 0		;Special instruction?
		je	OutputSpcl
		puts			;Output all but special instrs here.
		jmp	PutOperands

; If we have a special instruction (instruction code = 111b), print the
; appropriate string down here.

OutputSpcl:	mov	al, ah		;Retrieve opcode.
		and	al, 11000b	;Get special operation code
		cmp	al, 01000b
		jb	IsHalt
		je	IsGoto
		test	al, 01000b	;See if get or put
		jne	IsPut
		print
		db	"get    ",0
		jmp	PutOperand

IsPut:		print
		db	"put    ",0
		jmp	PutOperand

IsGoto:		print
		db	"goto   ",0
		jmp	PutOperand

; The following code outputs the constant immediately following an instruction
; with the immediate (constant) addressing mode.  This could be the GOTO
; instruction (which falls through from the above), IFEQ, IFLT, IFGT, LOAD,
; ADD, or SUB.  In each case, the addressing mode must be a constant.

OutputConst:	mov	bx, Memory		;Point ES back at 886 space.
		mov	es, bx

		mov	bx, UnAsmAdrs		;Fetch the constant from the
		mov	ax, es:[bx+1]		; instruction stream.
		putw				;Output the constant.
		putcr
		add	UnAsmAdrs, 3		;Instr is 3 bytes long, adjust
		jmp	DisLp			; for that and then quit.

; Handle the HALT instruction specially down here.

IsHalt:		print
		db	"halt   ",cr,lf,0
		inc	UnAsmAdrs
		jmp	DisLp


;PutOperands-	outputs the first operand, which is always a register value.

PutOperands:	mov	bl, ah			;Retrieve opcode.
		and	bl, 11000b		;Extract register field
		shr	bl, 1			;Convert to index into
		mov	bh, 0			; RegisterStrs.
		les	di, RegisterStrs[bx]	;Get register string ptr.
		puts				;Output register name.

		print
		db	", ",0

;PutOperand-	Outputs the second operand, which may be a register, memory,
;		or a constant.

PutOperand:	and	ah, 111b		;Strip out addressing mode
		mov	bl, ah			;Get addressing mode.
		mov	bh, 0
		cmp	ah, 4			;See if register or mem/imm
		jb	OneByteInstr		; addressing mode.
		je	IndBXInstr		;See if [bx] mode.
		cmp	ah, 5			;See if xxx[bx] mode.
		ja	NotIndexed		;If [xxx] or const.

; We have the "xxxx[bx]" addressing mode here.

		mov	bx, Memory
		mov	es, bx
		mov	bx, UnAsmAdrs
		mov	ax, es:[bx+1]
		putw
		print
		db	"[bx]",cr,lf,0
		add	UnAsmAdrs, 3
		jmp	DisLp

; We have the "[bx]" addressing mode here.

IndBXInstr:	print
		db	"[bx]",cr,lf,0
		inc	UnAsmAdrs
		jmp	DisLp


; See if [xxxx] mode here.


NotIndexed:	cmp	ah, 6
		jne	OutputConst		;Must be immediate mode.

; Okay, it's the absolute addressing mode.  Output the constant following
; the opcode surrounded by brackets.

		mov	al, "["
		putc
		mov	bx, Memory
		mov	es, bx
		mov	bx, UnAsmAdrs		;Fetch the absolute address
		mov	ax, es:[bx+1]		; to output
		putw

		print
		db	"]",cr,lf,0
		add	UnAsmAdrs, 3		;This is a 3 byte instr!
		jmp	DisLp


; One byte instructions have a register as their operand.  Output that
; register's name down here. Note the special kludge for the IFxx
; instructions.  Legal versions of these instructions look like one-byte
; (register-to-register) instructions, but they are really three bytes
; long.

OneByteInstr:	shl	bl, 1			;Use the register # as an
		shl	bl, 1			; index into RegisterStrs.
		mov	bh, 0
		les	di, RegisterStrs[bx]	;Get register string ptr.
		puts				;Output the register.
		mov	al, Opcode		;Fetch original opcode
		cmp	al, 80h			;See if an IFxx instruction.
		jb	JustOneByte
		cmp	al, 0e0h		;Shouldn't ever be greater
		jb	IFxxInstr		; than 0E0 here, just in case.

JustOneByte:	putcr
		inc	UnAsmAdrs		;This is a one byte instr!
		jmp	DisLp

IFxxInstr:	mov	bx, Memory
		mov	es, bx
		mov	bx, UnAsmAdrs
		print
		db	", ",0
		mov	ax, es:1[bx]
		putw
		putcr
		add	UnAsmAdrs, 3
		jmp	DisLp

DisasmCX	endp










; DoDispRegs- Displays registers and disassembles current instr.

DoDispRegs	proc	near
		push	ax
		push	bx
		push	cx
		push	di
		push	es

; Display the registers.

		printf
		db	"AX=%x BX=%xh CX=%xh DX=%xh IP=%xh WS=%d Cycles=%d\n", 0
		dd	RegAX, RegBX, RegCX, RegDX, RegIP
		dd	WaitStates, GlobalCycles

; Disassemble a single instruction at the current program counter (IP) loc:

		mov	bx, Memory
		mov	es, bx
		mov	ax, RegIP
		mov	UnAsmAdrs, ax
		mov	cx, 1
		call	DisasmCX
		mov	ax, RegIP
		mov	UnAsmAdrs, ax

		pop	es
		pop	di
		pop	cx
		pop	bx
		pop	ax
		ret
DoDispRegs	endp








; Main is the main program.  Program execution always begins here.

Main		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
;
		mov	dx, 0			;Init required by UCR Std Lib.
		meminit
		jnc	GoodMemInit

		print
		db	"Error initializing memory manager",cr,lf,0
		jmp	Quit
GoodMemInit:

; See if they've specified a different printer port for the
; electronic circuitry.

		mov	bx, 1		;Assume LPT1
		argc			;Get the number of parameters.
		cmp	cx, 1		;We allow zero or one parameters
		jb	LPT1		; to this command.
		ja	Usage		;Error if more than one.

		mov	ax, cx		;Fetch the only parameter (1).
		argv
		strupr
		strcmpl
		byte	"LPT1",0
		je	LPT1
		strcmpl
		byte	"LPT1:",0
		je	LPT1

		strcmpl
		byte	"LPT2",0
		je	LPT2
		strcmpl
		byte	"LPT2:",0
		je	LPT2

		strcmpl
		byte	"LPT3",0
		je	LPT3
		strcmpl
		byte	"LPT3:",0
		je	LPT3

Usage:		print
		byte	bell, "Usage: SIM886 lpt1:",cr,lf
		byte	      "       SIM886 lpt2:",cr,lf
		byte	      "    or SIM886 lpt3:",cr,lf
		byte	0
		jmp	Quit

LPT3:		inc	bx
LPT2:		inc	bx
LPT1:		free			;We're done with parameter string.
		mov	ax, 40h		;Point at BIOS variables
		mov	es, ax
		shl	bx, 1		;Index into word array.
		mov	ax, es:[bx+6]	;Fetch parallel port address.
		test	ax, ax		;If zero, no printer card installed
		jne	GotPort
		print
		byte	"There does not seem to be a parallel port adapter "
		byte	"card installed for",cr,lf
		byte	"the print port you've specified.  Please check your"
		byte	"hardware and try again.",cr,lf,0
		jmp	Quit

GotPort:      	mov	OutPort, ax	;Save away output port address.
		inc	ax		;Compute input port address.
		mov	InPort, ax	;Save away input port address.
		inc	ax		;Point at control port so we can
		mov	dx, ax		; write a zero to it.  This provides
		mov	al, 0		; power to the circuitry.
		out	dx, al


; Display the sign-on message.

		print
		db	cr,lf,lf,lf,lf,lf,lf,lf,lf
		db	"컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
		db	cr,lf
		db	"Sim886: A Debugger/Interpreter for the 886 Processor"
		db	cr,lf
		db	"컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
		db	cr,lf
		db	"Version 2.0",cr,lf
		db	"Copyright (c) 1995, by Randall Hyde",cr,lf
		db	cr,lf
		db	0

DoHelp:		call	Help





CmdLoop:

; Before pausing for user input, we need to copy the memory mapped values
; to the LEDs.

		mov	ax, memory
		mov	es, ax
		mov	ax, es:[0FFEEh]
		shl	ax, 1

		mov	bl, es:[0FFECh]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFEAh]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE8h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE6h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE4h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE2h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE0h]
		and	bl, 1
		or	al, bl

		mov	dx, OutPort
		out	dx, al



; Okay, read and execute the command.

		mov	ax, dseg
		mov	ds, ax
		print
		db	"Cmd>",0

		getsm				;Read a line of text from user.


; Before each command, read the switches from the input port and update the
; corresponding "memory mapped I/O" locations.  If the user dumps memory,
; s/he should see the current switch settings at the appropriate locations.

		push	es
		mov	ax, Memory
		mov	es, ax

		mov	dx, InPort
		in	al, dx
		xor	ax, 01111000b	;Sw on=1, off=0

		shr	al, 1
		shr	al, 1
		shr	al, 1
		mov	bx, ax
		and	bx, 1
		mov	es:[0FFF8h], bx

		shr	al, 1
		mov	bl, al
		and	bl, 1
		mov	es:[0FFFAh], bx

		shr	al, 1
		mov	bl, al
		and	bl, 1
		mov	es:[0FFFCh], bx

		shr	al, 1
		mov	bl, al
		and	bl, 1
		mov	es:[0FFFEh], bx
		pop	es


; Okay, now do the command.

		mov	bx, 0			;Index into user's string.
		call	BlkDel			;Skip any blanks
		mov	al, es:[di][bx]		;Get current char
		toupper				;Convert to upper case

		cmp	al, 0			;See if the user pressed
		jne	NewCmd			; <enter> by itself.
		mov	al, LastCmd		; If so, repeat last command.


; This section of code deciphers the command and jumps off to the code
; which processes it.

NewCmd:		mov	LastCmd, al		;Save as new "Last Command".
		cmp	al, "E"
		je	DoEnter
		cmp	al, "U"
		je	Disassemble
		cmp	al, "A"
		je	Assemble
		cmp	al, "D"
		je	Dump
		cmp	al, "T"
		je	Trace
		cmp	al, "G"
		je	GoCmd
		cmp	al, "R"
		je	DisplayRegs
		cmp	al, "Q"
		je	Quit
		cmp	al, "?"
		je	DoHelp
		cmp	al, "I"
		je	DoInput
		cmp	al, "C"
		je	DoCapture
		cmp	al, "X"
		je	CaptureOff
		cmp	al, "W"
		je	DoWaitStates
		cmp	al, "Z"
		je	ZeroCycles

		cmp	al, 0			;Special command value in
		je      CmdLoop			; LastCmd set by Input.

		free			;Reclaim storage lost by user string.
		print
		db	"Unknown command.  Please correct and try again."
		db	cr,lf
		db	0
		jmp	CmdLoop

;If the user pressed "E", come handle that down here.

DoEnter:	cmp	byte ptr es:[di][bx], 0
		je	SkipInc		;If user just pressed return.
		inc	bx		;Skip past the "E" character.
SkipInc:	mov	ax, EditAdrs	;Default value if nothing there.
		call	GetAdrs		;Get optional user-specified address.
		free			;Free space taken up by user input.
EditLoop:	mov	bx, Memory
		mov	ds, bx
		mov	bx, ax		;Okay, print out the current address
NextEntry:	putw			; and the value at that address.
		mov	al, "("
		putc
		mov	al, ds:[bx]
		puth
		print
		db	"): ",0
		getsm			;Get the value to insert into memory.
		push	es		;Save for free later on.
		push	di
		dec	di
BDLp0:		inc	di		;Skip leading blanks.
		cmp	byte ptr es:[di], ' '
		je	BDLp0

		cmp	byte ptr es:[di], 0	;If at EOLN, quit.
		je	EntryDone

		atoh			;Convert to a number and store.
		pop	di
		pop	es
		jc	BadEntry	;Error while converting to hex?
		cmp	ah, 0
		jne	BadEntry	;Value too big?
		free			;Free up string storage.
		mov	ds:[bx], al	;Store value away.
		inc	bx		;Off to the next address
		mov	ax, bx
		jmp	NextEntry

BadEntry:	print
		db	"Illegal hexadecimal (byte) value, reenter",cr,lf,0
		free
		mov	ax, bx
		jmp     NextEntry


EntryDone:	pop	di
		pop	es
		free
		mov	di, dseg
		mov	ds, di
		mov	EditAdrs, bx	;Save last address in case they
		jmp	CmdLoop		; repeat "E" command.





; Dump-		Displays up to 16 bytes of memory at the specified address.

Dump:           cmp	byte ptr es:[di][bx], 0
		je	SkipOverInc	;If user just pressed return.
		inc	bx		;Skip past the "D" character
SkipOverInc:	mov	ax, DumpAdrs	;Default value if nothing there.
		call	GetAdrs		;Get optional user-specified address.
		free			;Free space taken up by user input.

		mov	bx, Memory
		mov	ds, bx
		mov	bx, ax		;Okay, print out the current address

; Dump always prints out 1-16 bytes.  The following loop prints sufficient
; spaces to ensure that each byte within a paragraph gets printed in the
; same column on the screen:

		mov	si, ax
		and	si, 0fff0h	;Round down to prev multiple of 16.
		putw			;Print starting address
		print
		db	": ",0
PrtSpcLp:	cmp	si, bx		;Should we print #s yet?
		jae	PutNumbers
		print
		db	"   ",0
		inc	si
		test	si, 11b		;Is this an even multiple of four?
		jne	PrtSpcLp
		mov	al, " "		;Print an extra space if it is
		putc
		test	si, 111b	;Even multiple of eight?
		jne	PrtSpcLp
		mov	al, " "
		putc
		jmp	PrtSpcLp

; Drop down here when it's time to really print some numbers.

PutNumbers:	mov	si, bx
		and	si, 0fff0h
		add	si, 16		;Determine stopping address.
PutNLp:		mov	al, ds:[bx]
		puth
		mov	al, " "
		putc
		inc	bx
		cmp	bx, si		;Done yet?
		je	DumpDone
		test	bl, 11b		;Is this an even multiple of four?
		jne	PutNLp
		mov	al, " "		;Print an extra space if it is
		putc
		test	bl, 111b	;Even multiple of eight?
		jne	PutNLp
		mov	al, " "
		putc
		jmp	PutNLp

DumpDone:	mov	bx, dseg
		mov	ds, bx
		mov	DumpAdrs, si	;Save final address in the event
		putcr			; they repeat this command.
		jmp	CmdLoop



; Display the CPU registers and disassemble the current instruction here.

DisplayRegs:    inc	bx
		call	BlkDel
		mov	al, es:[di][bx]
		toupper
		cmp	al, 'A'
		jb	JustDisplay
		cmp	al, 'D'
		ja	JustDisplay
		inc	bx
		mov	cl, al			;Save register name.
		mov	al, es:[di][bx]
		toupper
		cmp	al, 'X'
		jne	JustDisplay
		inc	bx
		call	BlkDel
		call	GetAdrs
		mov	bl, cl
		sub	bl, 'A'
		mov	bh, 0
		shl	bx, 1
		mov	regax[bx], ax

JustDisplay:	free
		call	DoDispRegs
		jmp	CmdLoop








; ZeroCycles-	If the user pressed "Z", zero out the globalcycles variable.

ZeroCycles:	mov	GlobalCycles, 0
		free
		jmp	CmdLoop






; DoWaitStates-	Lets the user specify the number of wait states on each
;		memory access.

DoWaitStates:	cmp	byte ptr es:[di][bx], 0
		je	SkipIncWS	;If user just pressed return.
		inc	bx		;Skip past the "W" character.
		mov	ax, 0		;Default # of wait states.
		call	GetAdrs		;Get optional user-specified address.
		mov	WaitStates, ax	;Save wait state value.
SkipIncWS:	free			;Free space taken up by user input.
		jmp	CmdLoop








; DoInput- Redirects the standard input so the data comes from an input
; file rather than the keyboard.  This allows the user to create source
; files of x86 instructions and other commands.  Input is directed back
; to the keyboard upon encountering EOF.

DoInput:	cmp	InputActive, 0
		jne	CmdLoop		;Ignore if already redirected.

		mov	InputActive, 1	;Don't allow recursive activation.

		inc	bx		;Skip over "I"
		call	BlkDel
		lea	si, Filename
CopyName:	mov	al, es:[di][bx]
		cmp	al, 0
		je	FNDone
		cmp	al, ' '
		je	FNDone
		mov	[si], al
		inc	si
		inc	bx
		jmp	CopyName

FNDone:		free
		mov	byte ptr [si], 0
		ldxi	Filename
		mov	ax, 0
		lesi	InputFile
		fopen
		jnc	GoodOpen
		print
		byte	"DOS error code ",0
		puth
		print
		byte	"h while attempting to open file.",cr,lf,0
		jmp	CmdLoop

GoodOpen:	PushInAdrs			;Save STDIN Address
		lesi	MyInRoutine		;Switch stdin to the
		SetInAdrs			; routine that reads data
		jmp	CmdLoop			; from the file.


; DoCapture- 	Redirects the standard output so all data heading to the
;		screen goes to a file as well as the display.

DoCapture:	cmp	OutputActive, 0		;See if already active, don't
		jne	CmdLoop			; allow recursive activation.

		mov	OutputActive, 1

		inc	bx		;Skip over "C"
		call	BlkDel
		lea	si, Filename
CopyName2:	mov	al, es:[di][bx]
		cmp	al, 0
		je	FNDone2
		cmp	al, ' '
		je	FNDone2
		mov	[si], al
		inc	si
		inc	bx
		jmp	CopyName2

FNDone2:	free
		mov	byte ptr [si], 0
		ldxi	Filename
		lesi	OutputFile
		fcreate
		jnc	GoodOpen2
		print
		byte	"DOS error code ",0
		puth
		print
		byte	"h while attempting to open file.",cr,lf,0
		jmp	CmdLoop

GoodOpen2:	PushOutAdrs			;Save STDIN Address
		lesi	MyOutRoutine		;Switch stdin to the
		SetOutAdrs			; routine that reads data
		jmp	CmdLoop			; from the file.


; CaptureOff-	Turns off output to the capture file.

CaptureOff:	free
		cmp	OutputActive, 0		;Ignore if no file currently
		je	CmdLoop			; active.

		mov	OutputActive, 0
		PopOutAdrs
		lesi	OutputFile
		fclose
		jmp	CmdLoop



; Assemble a group of instructions here:

Assemble:	cmp	byte ptr es:[di][bx], 0
		je	SkipOverA	;If user just pressed return.
		inc	bx		;Skip past the "D" character
SkipOverA:	mov	ax, AsmAdrs	;Default value if nothing there.
		call	GetAdrs		;Get optional user-specified address.
		mov	AsmAdrs, ax
		free			;Free space taken up by user input.

NextInstr:	printf
		db	"%x:  ",0
		dd	AsmAdrs
		getsm
		strlen			;Need length for Match in CX anyway.
		or	cx, cx
		jne	AsmThisInstr
		free
		jmp	CmdLoop

AsmThisInstr:	strupr
		add	cx, di		;Adjust to turn into a pointer.
		ldxi	InstrPat
		match
		jnc	SyntaxError
		free

; Quick check for illegal instructions:

		cmp	AsmOpcode, 7		;Special/Get instr.
		jne	TryStoreInstr
		cmp	AsmOprnd1, 2		;GET opcode
		je	SeeIfImm
		cmp	AsmOprnd1, 1		;Goto opcode
		je	InstrOkay

TryStoreInstr:	cmp	AsmOpcode, 1		;Store Instruction
		jne	NotStoreInstr

SeeIfImm:	cmp	AsmOprnd2, 7		;Immediate Addressing Mode
		jne	NotStoreInstr
		print
		db	"Syntax error: store/get immediate not allowed."
		db	"  Try Again",cr,lf,0
		jmp	NextInstr


NotStoreInstr:

InstrOkay:	mov	al, AsmOpcode
		shl	al, 1
		shl	al, 1
		or	al, AsmOprnd1
		shl	al, 1
		shl	al, 1
		shl	al, 1
		or	al, AsmOprnd2
		mov	bx, Memory
		mov	es, bx
		mov	bx, AsmAdrs
		mov	es:[bx], al
		mov	ax, AsmAdrs
		mov	UnAsmAdrs, ax
		inc	AsmAdrs
		cmp	AsmOpcode, 4		;IFEQ instruction
		jb	SimpleInstr
		cmp	AsmOpcode, 6		;IFGT instruction
		jbe	PutConstant

SimpleInstr:	cmp	AsmOprnd2, 5
		jb      DisplayIt
PutConstant:	mov	ax, AsmConst
		mov	es:1[bx], ax
		add	AsmAdrs, 2
DisplayIt:      mov	cx, 1
		call    DisasmCX
		jmp	NextInstr


SyntaxError:	free
		print
		db	"Syntax error in instruction, please reenter."
		db	cr,lf,0
		jmp	NextInstr



; Disassemble 15 instructions here:

Disassemble:    cmp	byte ptr es:[di][bx], 0
		je	SkipOverRpt	;If user just pressed return.
		inc	bx		;Skip past the "D" character
SkipOverRpt:	mov	ax, UnAsmAdrs	;Default value if nothing there.
		call	GetAdrs		;Get optional user-specified address.
		free			;Free space taken up by user input.

		mov	bx, Memory
		mov	es, bx
		mov	UnAsmAdrs, ax
		mov	cx, 15		;Disassemble 15 instructions.
		call	DisasmCX
		jmp	CmdLoop




; Trace- Executes a single instruction at address specified (or REGIP).

Trace:		cmp	byte ptr es:[di][bx], 0
		je	SkipOver	;If user just pressed return.
		inc	bx		;Skip past the "D" character
SkipOver:	mov	ax, RegIP	;Default value if nothing there.
		call	GetAdrs		;Get optional user-specified address.
		free			;Free space taken up by user input.
		mov	bx, seg Memory
		mov	es, bx
		mov	RegIP, ax

		call	DoDispRegs	;Display instr and registers.

; Okay, let's go through the steps required to execute this instruction.

		mov	Cycle, 0
		call	DoInstruction
		jmp	ExecuteDone







; GoCmd- Starts the program running at "full" speed.

GoCmd:		cmp	byte ptr es:[di][bx], 0
		je	SkipG		;If user just pressed return.
		inc	bx		;Skip past the "D" character
SkipG:		mov	ax, RegIP	;Default value if nothing there.
		call	GetAdrs		;Get optional user-specified address.
		mov	RegIP, ax
		free			;Free space taken up by user input.
		mov	bx, seg Memory
		mov	es, bx

		call	DoDispRegs	;Display instr and registers.

; Okay, let's go through the steps required to execute this instruction.

		mov	AbortInstr, 0
		mov	InstrCnt, 0
RunLoop:	call	DoInstruction
		inc	InstrCnt
		cmp	AbortInstr, 0
		jne	GoDone
		mov	ah, 1		;See if a keypress.
		int	16h
		je	RunLoop
		mov	ah, 0		;Read the keypress.
		int	16h
		cmp	al, 3		;See if control-C
		jne	RunLoop

GoDone:		printf
		db	"Number of instructions executed: %d\n"
		db	"Number of cycles required: %d\n",0
		dd	InstrCnt, GlobalCycles

ExecuteDone:	call	DoDispRegs
		print
		db	"컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�"
		db	cr,lf,0
		jmp	CmdLoop


Quit:		ExitPgm
Main		endp



; MyInRoutine- 	Reads a character from the specified input file and
;		returns it in al.  Handles redirection of input from
;		a file.  On EOF, this routine resets the standard input
;		back to the keyboard (address pushed on stdlib stack).


MyInRoutine	proc	far
		push	es
		push	di

IgnoreLF:	lesi	InputFile
		fgetc
		jc	ErrorOnInput
		cmp	al, lf			;Ignore line feeds.
		je	IgnoreLF

		pop	di
		pop	es
		ret

ErrorOnInput:	PopInAdrs
		mov	ax, dseg
		mov	es, ax
		mov	es:LastCmd, 0		;So it will ignore this cmd.
		mov	es:InputActive, 0	;Allow "I" command again.
		pop	di
		pop	es
		mov	al, cr			;Return null cmd.
		ret
MyInRoutine	endp


; MyOutRoutine-	Sends the character in AL to the output file as well as to
;		the standard output.

MyOutRoutine	proc	far
		push	es
		push	di
		push	ax

		lesi	OutputFile
		fputc			;Print to file

		pop	ax
		putcbios		;Print to display.

		pop	di
		pop	es
		ret
MyOutRoutine	endp






; DoInstruction- executes or traces through a single instruction.

DoInstruction	proc	near

; Before executing each instruction, read the switches from the student's
; circuit attached to the printer port and copy that data to addresses
; 0FFFE/0FFFFh (Sw4), 0FFFC/0FFFDh (Sw3), 0FFFA/0FFFBh (Sw2),
; and 0FFF8/0FFF9h (Sw1).


		mov	ax, Memory
		mov	es, ax
		mov	dx, InPort
		in	al, dx
		xor	ax, 01111000b	;Sw on=1, off=0

		shr	al, 1
		shr	al, 1
		shr	al, 1
		mov	bx, ax
		and	bx, 1
		mov	es:[0FFF8h], bx

		shr	al, 1
		mov	bl, al
		and	bl, 1
		mov	es:[0FFFAh], bx

		shr	al, 1
		mov	bl, al
		and	bl, 1
		mov	es:[0FFFCh], bx

		shr	al, 1
		mov	bl, al
		and	bl, 1
		mov	es:[0FFFEh], bx


; Initialize the cycle count to zero for this specific instruction

		mov	Cycle, 0

; Fetch and decode the instruction.

		call	FetchDecode

; Let's handle the HALT instruction specially down here.

		cmp	InstrCode, 7
		jne	NotSpecial

		cmp	Register, 0
		jne	NotSpecial

		dec	RegIP		;Leave IP pointing at HALT instr.
		printf
		db	"HALT encountered.  Processing stopped at %x.",cr,lf,0
		dd	RegIP
		mov	AbortInstr, 1
		jmp	InstrDone



; Handle the normal instructions down here.
; Fetch optional two-byte constant following opcode in memory, if present.

NotSpecial:	cmp	InstrCode, 0
		je	DoLoad
		cmp	InstrCode, 1
		je	DoStore
		cmp	InstrCode, 2
		je	DoAdd
		cmp	InstrCode, 3
		je	DoSub
		cmp	InstrCode, 4
		je	DoIfeq
		cmp	InstrCode, 5
		je	DoIflt
		cmp	InstrCode, 6
		je	DoIfgt

; Special opcode, must be goto, get, or put (HALT was handled earlier)

		cmp	Register, 1
		je	DoGoto
		cmp	Register, 2
		je	DoGet

; Must be the Put instruction

		call	ComputeEA
		print
		db	"Output: ",0
		les	di, EffectiveAdrs
		mov	ax, es:[di]
		putw
		putcr
		jmp	InstrDone



; Handle the GET instruction here.

DoGet:		call	ComputeEA
		print
		db	"Input value: ",0
		getsm
		mov	bx, 0
		mov	ax, 0
		call	GetAdrs
		free
		les	di, EffectiveAdrs
		mov	es:[di], ax
		jmp	InstrDone



; Handle the GOTO instruction here.

DoGoto:		call	xGotoInstr
		jmp	InstrDone

DoLoad:		call	xLoadInstr
		jmp	InstrDone

DoStore:        call	xStoreInstr
		jmp	InstrDone

DoAdd:		call	xAddInstr
		jmp	InstrDone

DoSub:		call	xSubInstr
		jmp	InstrDone

DoIfeq:		call	xIfeqInstr
		jmp	InstrDone

DoIflt:		call	xIfltInstr
		jmp	InstrDone

DoIfgt:		call	xIfgtInstr



; After the completion of the instruction, write the values in locations
; 0FFE0h..0FFEFh to the LEDs (0FFE0/E1 to LED0, 0FFE2/0FFE3 to LED1, etc.)


InstrDone:      mov	ax, Memory
		mov	es, ax
		mov	ax, es:[0FFEEh]
		shl	ax, 1

		mov	bl, es:[0FFECh]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFEAh]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE8h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE6h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE4h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE2h]
		and	bl, 1
		or	al, bl
		shl	ax, 1

		mov	bl, es:[0FFE0h]
		and	bl, 1
		or	al, bl

		mov	dx, OutPort
		out	dx, al



; Bump the global cycle count by the number of cycles for this instruction.

		mov	ax, Cycle
		add	GlobalCycles, ax

		ret
DoInstruction	endp


; Computes the (8086) address of an instruction's register operand.
; This is the destination operand for all the instructions except store, it's
; the source operand for the store instruction.


DestReg		proc	near
		mov	al, register		;Get register number.
		mov	ah, 0			;Convert to index into
		shl	ax, 1                   ; register file (in 8086
		add	ax, offset RegAX	; space).
		mov	word ptr RegOp, ax	;Save in RegOp pointer.
		mov	word ptr RegOp+2, ds
		ret
DestReg		endp









; ComputeEA-	Assumes we've decoded the instruction.  Goes in and gets
;		the address of the second operand.  Also prints statistics
;		and handles cycle counts for this operand.

ComputeEA	proc	near

; Compute the (8086) memory address of the second operand here.  If it is
; an indexed or indirect addressing mode, bump up the cycle count by one.

		mov	al, AdrsMode
		cmp	al, 4		;Register vs. memory adrs mode.
		jae	NotAReg		;Branch if a memory mode.

; AX, BX, CX, or DX here.  So just store the address of RegAX..RegDX in
; the EffectiveAdrs variable.

		shl	al, 1
		mov	ah, 0
		add	ax, offset RegAX		;Compute 8086 adrs
		mov	word ptr EffectiveAdrs, ax	; of target location
		mov	word ptr EffectiveAdrs+2, ds	; (an 886 register).
		jmp	DidEA

; Fall down here if we've got an 886 memory addressing mode.

NotAReg:	je	BXIndirect
		cmp	al, 6
		jb	IndexedBX
		je	Direct

; Just a constant.  Store the address of InstrOperand in EffectiveAdrs
; Note that we've already paid the cycle count price for this access during
; the fetch and decode phase.

		mov	word ptr EffectiveAdrs, offset InstrOperand
		mov	word ptr EffectiveAdrs+2, seg InstrOperand
		jmp	DidEA


; If it's "[bx]", handle that down here.

BXIndirect:	mov	ax, RegBX
		mov	word ptr EffectiveAdrs, ax
		mov	word ptr EffectiveAdrs+2, seg Memory
		jmp	AddOneEA

; If its a direct memory operand, copy InstrOperand into EffectiveAdrs

Direct:		mov	ax, InstrOperand
		mov	word ptr EffectiveAdrs, ax
		mov	ax, Memory
		mov	word ptr EffectiveAdrs+2, ax
		jmp	DidEA

; If it's an indexed operand, we need to compute the effective address as
; the sum of RegBX and InstrOperand.  We also need to add another cycle
; to the execution time.

IndexedBX:	mov	ax, RegBX
		add	ax, InstrOperand
		mov	word ptr EffectiveAdrs, ax
		mov	ax, Memory
		mov	word ptr EffectiveAdrs+2, ax
		inc	Cycle			;To compute sum of BX+const

AddOneEA:	inc	Cycle			;To fetch value of BX.

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Computing effective (indexed "
		db	"or indirect) address",cr,lf,0
		dd	RegIP, Cycle
		.endif


; Okay, we got the address of the second operand into EffectiveAdrs.  Now
; let's determine the register operand.
; Note: the special instructions don't have a register operand (since the
;       register bits determine the instruction in this group).

DidEA:		cmp     InstrCode, 7
		je	NoRegOprnd
		call	DestReg

NoRegOprnd:	ret
ComputeEA	endp










; FetchDecode-	Fetches and decodes the next instruction:

FetchDecode	proc	near

; Fetch opcode:

		mov	bx, RegIP
		call	ReadByte	;Data to AL, Cycles to CX
		mov	Opcode, al
		add	Cycle, cx


		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %h       Fetch Opcode",cr,lf,0
		dd	RegIP, Cycle, Opcode
		.endif

; Update IP:

		inc	RegIP
		inc	Cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Update IP",cr,lf,0
		dd	RegIP, Cycle
		.endif

; Decode instruction:

		mov	al, Opcode
		mov	ah, al
		and	al, 111b
		mov	AdrsMode, al

		mov	al, ah
		shr	al, 1
		shr	al, 1
		shr	al, 1
		and	al, 11b
		mov	Register, al

		rol	ah, 1
		rol	ah, 1
		rol	ah, 1
		and	ah, 111b
		mov	InstrCode, ah

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %h %h %h Decode instruction "
		db	"(opcode, reg, adrsmode)",cr,lf,0
		dd	RegIP, Cycle, InstrCode, Register, AdrsMode
		.endif

; Determine if this instruction has an optional constant operand.
; If so, read it from the code stream and adjust the cycle count appropriately.

		mov	al, InstrCode		;First, see if we've got an
		cmp	al, 4			; IFEQ, IFLT, or IFGT instr.
		jb	TryAdrsMode		; These guys always have
		cmp	al, 7			; a constant operand.
		jb	HasConst

TryAdrsMode:	mov	al, AdrsMode
		cmp	al, 5		;Instrs with constant operands have
		jb	NoConstOprnd	; addressing modes greater than 5.

; Okay, fetch the constant operand from the code stream:

HasConst:       mov	bx, seg Memory
		mov	es, bx
		mov	bx, RegIP
		call	ReadWord
		mov	InstrOperand, ax
		add	Cycle, cx

		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching constant from code "
		db	"stream ",0
		dd	RegIP, Cycle, InstrOperand

		test	RegIP, 1	;See if it was an even or odd adrs.
		jz	EvenAdrs
		print
		byte	"(odd address).",cr,lf,0
		jmp	DidEO

EvenAdrs:	print
		byte	"(even address).",cr,lf,0
DidEO:
		.endif

		add	RegIP, 2
		inc	Cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Update IP by two.",cr,lf,0
		dd	RegIP, Cycle
		.endif

NoConstOprnd:	ret
FetchDecode	endp







; ReadByte-	Reads the byte from location MEMORY:[bx].  Returns the
;		value of this byte in AL and the number of cycles to
;		read this data in CX.

ReadByte	proc
		push	es
		mov	ax, seg Memory
		mov	es, ax

		mov	cx, WaitStates	;Time to access this memory location.
		inc	cx
		mov	al, es:[bx]
		mov	ah, 0
		pop	es
		ret
ReadByte	endp


; ReadWord-	Reads the word from location ES:[BX] and returns it
;		in the AX register.  Also returns the number of clock
;		cycles in CX.  Note: this routine checks the value in
;		ES to see if it points at the MEMORY segment.  If it
;		does not, then we are accessing a register.  If this is
;		the case, we do not add in any wait states.

ReadWord	proc

		mov	cx, es
		cmp	cx, seg MEMORY
		je	SetWS
		mov	cx, 1
		jmp	NoExtraCycle

SetWS:		mov	cx, WaitStates
		inc	cx

		test	bx, 1		;See if an odd address (extra cycle)
		jz	NoExtraCycle
		shl	cx, 1		;Double number of cycles.

NoExtraCycle:	mov	ax, es:[bx]
		ret
ReadWord	endp


; WriteWord-	Writes the value in AX to memory location ES:[BX].
;		Returns the number of clock cycles in CX as per READWORD.

WriteWord	proc

		mov	cx, es
		cmp	cx, seg MEMORY
		je	SetWS
		mov	cx, 1
		jmp	NoExtraCycle

SetWS:		mov	cx, WaitStates
		inc	cx

		test	bx, 1		;See if an odd address (extra cycle)
		jz	NoExtraCycle
		shl	cx, 1

NoExtraCycle:	mov	es:[bx], ax
		ret
WriteWord	endp







; Compute the amount of time necessary to fetch the operand from memory.
; Print out the operations step by step if this is the "T" (trace) command.

GetOprndTime	proc	near

; Well, see if fetching the operand takes one, two, or three cycles.

		cmp	AdrsMode, 4
		jb	NotMemoryOprnd
		cmp	AdrsMode, 7
		je	NotMemoryOprnd

; Well, we've got a memory operand.  Figure that one out down here.

		test	byte ptr EffectiveAdrs, 1	;See if odd address
		jz	NotOddEA
		mov	ax, 3
		add	ax, WaitStates			;Two memory accesses,
		add	ax, WaitStates			; so two wait states.
		add	Cycle, ax

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Fetching operand (%x) from odd "
		db	"address in memory (%x)",cr,lf,0
		dd	RegIP, Cycle, OperandValue, EffectiveAdrs
		.endif

		jmp	GOTDone

NotOddEA:	mov	ax, 2
		add	ax, WaitStates
		add	Cycle, ax

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Fetching operand (%x) from even "
		db	"address in memory (%x)",cr,lf,0
		dd	RegIP, Cycle, OperandValue, EffectiveAdrs
		.endif

		jmp	GOTDone

; If it's just a register operand, that one's easier.

NotMemoryOprnd:	inc	cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Fetching operand (%x)"
		db	cr,lf,0
		dd	RegIP, Cycle, OperandValue
		.endif

GOTDone:	ret
GetOprndTime	endp






; ReadOpCost-	Prints the cost of accessing an operand.
;		EffectiveAdrs points at the operand (register or
;		memory).

ReadOpCost	proc
		cmp	AdrsMode, 7	;Don't bother if this is the
		je	RegMemDone	; immediate addressing mode.

		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Reading value from "
		db	0
		dd	RegIP, Cycle, OperandValue
		cmp	word ptr EffectiveAdrs+2, seg Memory
		je	IsMemory
		print
		byte	"a register.",cr,lf,0
		jmp	RegMemDone

IsMemory:	test	byte ptr EffectiveAdrs, 1
		jz	EvenAdrs
		printf
		byte	"odd address (%x).",cr,lf,0
		dword	EffectiveAdrs
		jmp	DidEO

EvenAdrs:	printf
		byte	"even address (%x).",cr,lf,0
		dword	EffectiveAdrs
DidEO:
		.endif
RegMemDone:
		ret
ReadOpCost	endp






; Handle the load instruction down here.

xLoadInstr	proc	near
		call	ComputeEA
		cmp	AdrsMode, 7		;Already got immediate
		jne	MemReg			; operand.

		mov	ax, InstrOperand
		mov	OperandValue, ax
		jmp	SetReg

MemReg:		les	bx, EffectiveAdrs
		call	ReadWord
		mov	OperandValue, ax
		add	Cycle, cx

SetReg:		les	di, RegOp
		mov	es:[di], ax

		call	ReadOpCost


		inc	cycle	     	;Cost of register store.

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Storing result (%x) into reg."
		db	cr,lf,lf,0
		dd	RegIP, Cycle, OperandValue
		.endif

		ret
xLoadInstr	endp



; Do the Store instruction here.

xStoreInstr	proc	near

		cmp	AdrsMode, 7	;Cannot have immediate adrs mode.
		jne	StoreOkay
		print
		db	"*** Illegal instruction.  Immediate mode not allowed."
		db	cr,lf,lf,0
		mov	AbortInstr, 1
		jmp	StoreDone


StoreOkay:	call	ComputeEA	;Compute destination location adrs.

; Fetch the register value and bump the cycle time accordingly.

		les	bx, RegOp	;Get source location adrs.
		mov	ax, es:[bx]	;Fetch source address value
		mov	OperandValue, ax
		inc	cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Getting register value (%x) "
		db	"to store.",cr,lf,0
		dd	RegIP, Cycle, OperandValue
		.endif


; Store the operand and report on the amount of time that it takes.

		les	bx, EffectiveAdrs ;Get destination location adrs.
		call	WriteWord
		add	Cycle, cx

		cmp	AdrsMode, 4
		jb	sRegOprnd

; Well, we've got a memory operand.  Figure that one out down here.

		.if	LastCmd == "T"
		test	byte ptr EffectiveAdrs, 1	;See if odd address
		jz	sEvenEA

		printf
		db	"%x (%2d): %x     Storing operand to odd memory "
		db	"address (%x)",cr,lf,lf,0
		dd	RegIP, Cycle, OperandValue, EffectiveAdrs
		jmp	StoreDone

sEvenEA:	printf
		db	"%x (%2d):          Storing operand (%x) to even "
		db	"address in memory (%x)",cr,lf,lf,0
		dd	RegIP, Cycle, OperandValue, EffectiveAdrs
		.endif

		jmp	StoreDone



; If it's just a register operand, that one's easier.

sRegOprnd:	.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Storing into register operand."
		db	cr,lf,lf,0
		dd	RegIP, Cycle, OperandValue
		.endif


StoreDone:	ret
xStoreInstr	endp



; ReadRegCost-	Cost of accessing a register source operand.

ReadRegCost	proc
		inc	Cycle			;One cycle for this operation.
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Reading register operand."
		db	cr,lf,0
		dd	RegIP, Cycle, Oprnd2Value
		.endif
		ret
ReadRegCost	endp



WriteRegCost	proc
		inc	Cycle			;One cycle for this operation.
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Writing result to register."
		db	cr,lf,0
		dd	RegIP, Cycle, Result
		.endif
		ret
WriteRegCost	endp



;----------------------------------------------------------------------------
; Handle the Add instruction down here.
; If LastCmd is equal to "T" (for the TRACE command) then this code displays
; the status of each clock cycle.
;----------------------------------------------------------------------------

xAddInstr	proc	near

		call	ComputeEA

		cmp	AdrsMode, 7		;Check for immediate mode.
		jne	RegMem
		mov	ax, InstrOperand	;Already paid for immediate
		mov	OperandValue, ax	; addressing mode.
		jmp	DoAdd

RegMem:		les	bx, EffectiveAdrs	;Get the source operand.
		call	ReadWord
		mov	OperandValue, ax
		add	Cycle, cx

		call	ReadOpCost		;Cost of memory/reg access.


DoAdd:		les	bx, RegOp		;This code actually performs
		mov	ax, es:[bx]		; the addition operation.
		mov	Oprnd2Value, ax
		call	ReadRegCost		;Cost of register access.

		mov	ax, Oprnd2Value
		add	ax, OperandValue
		mov	Result, ax
		mov	es:[bx], ax

		inc	Cycle			;Cost of addition operation.
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Computing sum."
		db	cr,lf,0
		dd	RegIP, Cycle, Result
		.endif

		call	WriteRegCost
		ret
xAddInstr	endp





;----------------------------------------------------------------------------
; Handle the Sub instruction down here.
;----------------------------------------------------------------------------

xSubInstr	proc	near

		call	ComputeEA

		cmp	AdrsMode, 7		;Check for immediate mode.
		jne	RegMem
		mov	ax, InstrOperand	;Already paid for immediate
		mov	OperandValue, ax	; addressing mode.
		jmp	DoSub

RegMem:		les	bx, EffectiveAdrs	;Get the source operand.
		call	ReadWord
		mov	OperandValue, ax
		add	Cycle, cx

		call	ReadOpCost		;Cost of memory/reg access.


DoSub:		les	bx, RegOp		;This code actually performs
		mov	ax, es:[bx]		; the addition operation.
		mov	Oprnd2Value, ax
		call	ReadRegCost		;Cost of register access.

		mov	ax, Oprnd2Value
		sub	ax, OperandValue
		mov	Result, ax
		mov	es:[bx], ax

		inc	Cycle			;Cost of addition operation.
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Computing difference."
		db	cr,lf,0
		dd	RegIP, Cycle, Result
		.endif

		call	WriteRegCost
		ret
xSubInstr	endp



; Handle the GOTO instruction here.

xGotoInstr	proc	near
		call	ComputeEA

		cmp	AdrsMode, 7		;Check for immediate mode.
		jne	RegMem
		mov	ax, InstrOperand	;Already paid for immediate
		mov	OperandValue, ax	; addressing mode.
		jmp	DoGoto

RegMem:		les	bx, EffectiveAdrs	;Get the source operand.
		call	ReadWord
		mov	OperandValue, ax
		add	Cycle, cx

		call	ReadOpCost		;Cost of memory/reg access.

DoGoto:		mov	ax, OperandValue
		mov	RegIP, ax
		inc	Cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Copy address to IP",cr,lf,0
		dd	RegIP, Cycle
		.endif
		ret
xGotoInstr	endp







; Handle the IFEQ instruction here.

xIfeqInstr	proc	near

		call	ComputeEA		;Both operands better be regs.

		les	di, EffectiveAdrs
		mov	ax, es:[di]
		mov	Oprnd2Value, ax
		les	di, RegOp
		mov	ax, es:[di]
		mov	OperandValue, ax

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching register operand #1"
		db	cr,lf,0
		dd	InstrOperand, cycle, OperandValue
		.endif

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching register operand #2"
		db	cr,lf,0
		dd	InstrOperand, cycle, Oprnd2Value
		.endif


; Be sure the user didn't sneak in some addressing mode other than register.

		cmp	AdrsMode, 4
		jb	ieRegOprnd

; Well, we've got a memory operand or a constant.  Abort with an illegal
; instruction error.

		print
		db	"*** Illegal addressing mode on IFEQ instruction!"
		db	cr,lf
		db	"Execution halted.",cr,lf,0
		mov	AbortInstr, 1
		jmp	IFEQDone


; If it's just a register operand, we're okay.  Fetch the constant (target
; address) value down here.

ieRegOprnd:
		inc	cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Comparing operands (%x==%x)."
		db	cr,lf,0
		dd	InstrOperand, cycle, OperandValue, Oprnd2Value
		.endif


		mov	ax, OperandValue
		cmp	ax, Oprnd2Value
		jne	OpsNE

		inc	Cycle			;Cost of copying val to IP.
		mov	ax, InstrOperand
		mov	RegIP, ax
		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Values equal, copying %x to IP."
		db	cr,lf,0
		dd	InstrOperand, cycle, InstrOperand
		.endif
		jmp	ifeqDone

OpsNE:
		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Values not equal, no transfer."
		db	cr,lf,lf,0
		dd	RegIP, cycle
		.endif

ifeqDone:	ret
xIfeqInstr	endp




; Handle the IFLT instruction here.

xIfltInstr	proc	near

		call	ComputeEA		;Both operands better be regs.

		les	di, EffectiveAdrs
		mov	ax, es:[di]
		mov	Oprnd2Value, ax
		les	di, RegOp
		mov	ax, es:[di]
		mov	OperandValue, ax

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching register operand #1"
		db	cr,lf,0
		dd	InstrOperand, cycle, OperandValue
		.endif

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching register operand #2"
		db	cr,lf,0
		dd	InstrOperand, cycle, Oprnd2Value
		.endif


; Be sure the user didn't sneak in some addressing mode other than register.

		cmp	AdrsMode, 4
		jb	ilRegOprnd

; Well, we've got a memory operand or a constant.  Abort with an illegal
; instruction error.

		print
		db	"*** Illegal addressing mode on IFLT instruction!"
		db	cr,lf
		db	"Execution halted.",cr,lf,0
		mov	AbortInstr, 1
		jmp	IFLTDone


; If it's just a register operand, we're okay.  Fetch the constant (target
; address) value down here.

ilRegOprnd:
		inc	cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Comparing operands (%x < %x)."
		db	cr,lf,0
		dd	InstrOperand, cycle, OperandValue, Oprnd2Value
		.endif


		mov	ax, OperandValue
		cmp	ax, Oprnd2Value
		jae	OpsAE

		inc	Cycle			;Cost of copying val to IP.
		mov	ax, InstrOperand
		mov	RegIP, ax
		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          op1 < op2, copying %x to IP."
		db	cr,lf,0
		dd	InstrOperand, cycle, InstrOperand
		.endif
		jmp	ifltDone

OpsAE:
		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          op1 >= op2, no transfer."
		db	cr,lf,lf,0
		dd	RegIP, cycle
		.endif

ifltDone:	ret
xIfltInstr	endp


; Handle the IFGT instruction here.

xIfgtInstr	proc	near

		call	ComputeEA		;Both operands better be regs.

		les	di, EffectiveAdrs
		mov	ax, es:[di]
		mov	Oprnd2Value, ax
		les	di, RegOp
		mov	ax, es:[di]
		mov	OperandValue, ax

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching register operand #1"
		db	cr,lf,0
		dd	InstrOperand, cycle, OperandValue
		.endif

		inc	Cycle
		.if	LastCmd == "T"
		printf
		db	"%x (%2d): %x     Fetching register operand #2"
		db	cr,lf,0
		dd	InstrOperand, cycle, Oprnd2Value
		.endif


; Be sure the user didn't sneak in some addressing mode other than register.

		cmp	AdrsMode, 4
		jb	igRegOprnd

; Well, we've got a memory operand or a constant.  Abort with an illegal
; instruction error.

		print
		db	"*** Illegal addressing mode on IFGT instruction!"
		db	cr,lf
		db	"Execution halted.",cr,lf,0
		mov	AbortInstr, 1
		jmp	IFGTDone


; If it's just a register operand, we're okay.  Fetch the constant (target
; address) value down here.

igRegOprnd:
		inc	cycle

		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          Comparing operands (%x > %x)."
		db	cr,lf,0
		dd	InstrOperand, cycle, OperandValue, Oprnd2Value
		.endif


		mov	ax, OperandValue
		cmp	ax, Oprnd2Value
		jae	OpsBE

		inc	Cycle			;Cost of copying val to IP.
		mov	ax, InstrOperand
		mov	RegIP, ax
		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          op1 > op2, copying %x to IP."
		db	cr,lf,0
		dd	InstrOperand, cycle, InstrOperand
		.endif
		jmp	ifgtDone

OpsBE:
		.if	LastCmd == "T"
		printf
		db	"%x (%2d):          op1 <= op2, no transfer."
		db	cr,lf,lf,0
		dd	RegIP, cycle
		.endif

ifgtDone:	ret

xIfgtInstr	endp





cseg            ends





; Allocate a reasonable amount of space for the stack (2k).

sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends


; zzzzzzseg must be the last segment that gets loaded into memory!

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main


