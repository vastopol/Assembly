; Bit Operations and SETcc Instructions

		.386			;So we can use extended registers
		option	segment:use16	; and addressing modes.

dseg		segment	para public 'data'

; Some type definitions for the variables we will declare:

uint		typedef	word		;Unsigned integers.
integer		typedef	sword		;Signed integers.


; Some variables we can use:

j		integer	?
k		integer	?
u1      	uint	2
u2		uint	2
Result		byte	?

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Initialize some variables

		mov	j, -2
		mov	k, 2

; The SETcc instructions store a one or zero into their operand if the
; specified condition is true or false, respectively.  The TEST instruction
; logically ANDs its operands and sets the flags accordingly (in particular,
; TEST sets/clears the zero flag if there is/isn't a zero result).  We can
; use these two facts to copy a single bit (zero extended) to a byte operand.

		test	j, 11000b	;Test bits 4 and 5.
		setne	Result		;Result=1 if bits 4 or 5 of J are 1.

		test	k, 10b		;Test bit #1.
		sete	Result		;Result=1 if bit #1 = 0.

; The SETcc instructions are particularly useful after a CMP instruction.
; You can set a boolean value according to the result of the comparison.
;
; Result := j <= k

		mov	ax, j
		cmp	ax, k
		setle	Result		;Note that "le" is for signed values.

; Result := u1 <= u2

		mov	ax, u1
		cmp	ax, u2
		setbe	Result		;Note that "be" is for unsigned values.

; One thing nice about the boolean results that the SETcc instructions
; produce is that we can AND, OR, and XOR them and get the same results
; one would expect in a HLL like C, Pascal, or BASIC.
;
; Result := (j < k) and (u1 > u2)

		mov	ax, j
		cmp	ax, k
		setl	bl		;Use "l" for signed comparisons.

		mov	ax, u1
		cmp	ax, u2
		seta	al		;Use "a" for unsigned comparisons.

		and	al, bl		;Logically AND the two boolean results
		mov	Result, al	; and store the result away.

; Sometimes you can use the shift and rotate instructions to test to see
; if a specific bit is set.  For example, SHR copies bit #0 into the carry
; flag and SHL copies the H.O. bit into the carry flag.  We can easily test
; these bits as follows:
;
; Result := bit #15 of J.

		mov	ax, j
		shl	ax, 1
		setc	Result

; Result := bit #0 of u1:

		mov	ax, u1
		shr	ax, 1
		setc	Result

; If you don't have an 80386 or later processor and cannot use the SETcc
; instructions, you can often simulate them.  Consider the above two
; sequences rewritten for the 8086:

;
; Result := bit #15 of J.

		mov	ax, j
		rol	ax, 1			;Copy bit #15 to bit #0.
		and	al, 1			;Strip other bits.
		mov	Result, al

; Result := bit #0 of u1:

		mov	ax, u1
		and	al, 1			;Strip unnecessary bits.
		mov	Result, al

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
