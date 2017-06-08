; Conditional JMP Instructions, Part II

		.386
		option	segment:use16
dseg		segment	para public 'data'

Array1		word	1, 2, 3, 4, 5, 6, 7, 8
Array2		word	8 dup (?)

String1		byte	"This string contains lower case characters",0
String2		byte	128 dup (0)

j		sword	5
k		sword	6

Result		byte	?

dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; You can use the LOOP instruction to repeat a sequence of statements
; some specified number of times in an assembly language program.
; Consider the code taken from EX6_5.ASM that used the string
; instructions to produce a running product:
;
; The following code uses a loop instruction to compute:
;
;	Array2[0] := Array1[0]
;	Array2[1] := Array1[0] * Array1[1]
;	Array2[2] := Array1[0] * Array1[1] * Array1[2]
;	etc.

		cld
		lea	si, Array1
		lea	di, Array2
		mov	dx, 1			;Initialize for 1st time.
		mov	cx, 8			;Eight elements in the arrays.

LoopHere:	lodsw
		imul	ax, dx
		mov	dx, ax
		stosw
		loop	LoopHere


; The LOOPNE instruction is quite useful for controlling loops that
; stop on some condition or when the loop exceeds some number of
; iterations.  For example, suppose string1 contains a sequence of
; characters that end with a byte containing zero.  If you wanted to
; convert those characters to upper case and copy them to string2,
; you could use the following code.  Note how this code ensures that
; it does not copy more than 127 characters from string1 to string2
; since string2 only has enough storage for 127 characters (plus a
; zero terminating byte).

		lea	si, String1
		lea	di, String2
		mov	cx, 127			;Max 127 chars to string2.

CopyStrLoop:	lodsb				;Get char from string1.
		cmp	al, 'a'			;See if lower case
		jb	NotLower		;Characters are unsigned.
		cmp	al, 'z'
		ja	NotLower
		and	al, 5Fh			;Convert lower->upper case.
NotLower:
		stosb
		cmp	al, 0			;See if zero terminator.
		loopne	CopyStrLoop		;Quit if al or cx = 0.



; If you do not have an 80386 (or later) CPU and you would like the
; functionality of the SETcc instructions, you can easily achieve
; the same results using code like the following:
;
; Result := J <= K;

		mov	Result, 0		;Assume false.
		mov	ax, J
		cmp	ax, K
		jnle	Skip1
		mov	Result, 1		;Set to 1 if J <= K.
Skip1:


; Result := J = K;

		mov	Result, 0		;Assume false.
		mov	ax, J
		cmp	ax, K
		jne	Skip2
		mov	Result, 1
Skip2:





Quit:		mov	ah, 4ch			;DOS opcode to quit program.
		int	21h			;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
