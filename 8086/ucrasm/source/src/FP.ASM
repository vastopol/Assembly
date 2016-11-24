;
StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
;
; Floating point package.
;
;
; Released to the public domain
; Created by: Randall Hyde
; Date: 8/13/90
;	8/28/91
;
;
; FP format:
;
; 80 bits:
; bit 79            bit 63                           bit 0
; |                 |                                    |
; seeeeeee eeeeeeee mmmmmmmm m...m m...m m...m m...m m...m
;
; e = bias 16384 exponent
; m = 64 bit mantissa with NO implied bit!
; s = sign (for mantissa)
;
;
; 64 bits:
; bit 63       bit 51                                               bit 0
; |            |                                                        |
; seeeeeee eeeemmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm mmmmmmmm
;
; e = bias 1023 exponent.
; s = sign bit.
; m = mantissa bits.  Bit 52 is an implied one bit.
;
; 32 bits:
; Bit 31    Bit 22              Bit 0
; |         |                       |
; seeeeeee emmmmmmm mmmmmmmm mmmmmmmm
;
; e = bias 127 exponent
; s = sign bit
; m = mantissa bits, bit 23 is an implied one bit.
;
;
;
; WARNING: Although this package uses IEEE format floating point numbers,
;	   it is by no means IEEE compliant.  In particular, it does not
;	   support denormalized numbers, special rounding options, and
;	   so on.  Why not?  Two reasons:  I'm lazy and I'm ignorant.
;	   I do not know all the little details surround the IEEE
;	   implementation and I'm not willing to spend more of my life
;	   (than I already have) figuring it out.  There are more
;	   important things to do in life.  Yep, numerical analysts can
;	   rip this stuff to shreads and come up with all kinds of degenerate
;	   cases where this package fails and the IEEE algorithms succeed,
;	   however, such cases are very rare.  One should not get the idea
;	   that IEEE is perfect.  It blows up with lots of degenerate cases
;	   too.  They just designed it so that it handles a few additional
;	   cases that mediocre packages (like this one) do not.  For most
;	   normal computations this package works just fine (what it lacks
;	   it good algorithms it more than makes up for by using an 88-bit
;	   internal format during internal computations).
;
;	   Moral of the story: If you need highly accurate routines which
;          produce okay results in the worst of cases, look elsewhere please.
;	   I don't want to be responsible for your blowups.  OTOH, if you need
;	   a fast floating point package which is reasonably accurate and
;	   you're not a statistician, astronomer, or other type for whom
;	   features like denormalized numbers are important, this package
;	   may work out just fine for you.
;
;						Randy Hyde
;						August 1990
;						(Hard to believe I started this
;						 a year ago and I'm just coming
;						 back to it now!)
;
;						UC Riverside &
;						Cal Poly Pomona.
;
; FPACC- Floating point accumuator.
; FPOP-  Floating point operand.
;
; These variables use the following format:
;
; 88 bits:
; sxxxxxxx eeeeeeee eeeeeeee m..m m..m m..m m..m m..m m..m m..m m..m
; Sign          exponent                   mantissa (64 bits)
;
; Only H.O. bit of Sign byte is significant.  The rest is garbage.
; Exponent is bias 32767 exponent.
; Mantissa does NOT have an implied one bit.
;
; This format was picked for convenience (it is easy to work with) and it
; exceeds the 80-bit format used by Intel on the 80x87 chips.
;
fptype		struc
Mantissa	dw	4 dup (?)
Exponent	dw	?
Sign		db	?
		db	?		;Padding
fptype		ends
;
;
;
;
		public	fpacc
fpacc		fptype	<>
;
		public	fpop
fpop		fptype  <>
;
;
; FProd- Holds 144-bit result obtained by multiplying fpacc.mant x fpop.mant
;
Quotient	equ	this word
fprod		dw	9 dup (?)
;
;
; Variables used by the floating point I/O routines:
;
TempExp		dw	?
ExpSign		db	?
DecExponent	dw	?
DecSign		db	0
DecDigits	db	31 dup (?)
;
;
;
StdData		ends
;
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp, ds:nothing, es:nothing, ss:nothing
;
;
;
;
;
;
;
;
;
;
;---------------------------------------------------------------------------
;		Floating Point Load/Store Routines
;---------------------------------------------------------------------------
;
; sl_AccOp	Copies the floating point accumulator to the floating point
;		operand.
;
		public	sl_AccOp
sl_AccOp	proc	far
		assume	ds:StdGrp
		push	ax
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
;
		mov	ax, FPacc.Exponent
		mov	FPop.Exponent, ax
		mov	ax, FPacc.Mantissa
		mov	FPop.Mantissa, ax
		mov	ax, FPacc.Mantissa+2
		mov	FPop.Mantissa+2, ax
		mov	ax, FPacc.Mantissa+4
		mov	FPop.Mantissa+4, ax
		mov	ax, FPacc.Mantissa+6
		mov	FPop.Mantissa+6, ax
		mov	al, Fpacc.Sign
		mov	FPop.Sign, al
;
		pop	ds
		pop	ax
		ret
sl_AccOp	endp
		assume	ds:nothing
;
;
; sl_XAccOp-	Exchanges the values in the floating point accumulator
;		and floating point operand.
;
		public	sl_XAccOp
sl_XAccOp	proc	far
		assume	ds:StdGrp
		push	ax
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
;
		mov	ax, FPacc.Exponent
		xchg	ax, FPop.Exponent
		mov	FPacc.Exponent, ax
;
		mov	ax, FPacc.Mantissa
		xchg	ax, FPop.Mantissa
		mov	FPacc.Mantissa, ax
;
		mov	ax, FPacc.Mantissa+2
		xchg	ax, FPop.Mantissa+2
		mov	FPacc.Mantissa+2, ax
;
		mov	ax, FPacc.Mantissa+4
		xchg	ax, FPop.Mantissa+4
		mov	FPacc.Mantissa+4, ax
;
		mov	ax, FPacc.Mantissa+6
		xchg	ax, FPop.Mantissa+6
		mov	FPacc.Mantissa+6, ax
;
		mov	al, FPacc.Sign
		xchg	al, FPop.Sign
		mov	FPacc.Sign, al
;
		pop	ds
		pop	ax
		ret
sl_XAccOp	endp
		assume	ds:nothing
;
;
;
; sl_LSFPA- 	Loads a single precision (32-bit) IEEE format number into
;		the floating point accumulator.  ES:DI points at the # to
;		load into FPACC.
;
		public	sl_LSFPA
sl_LSFPA	proc	far
		push	ax
		push	bx
		mov	ax, es:[di]
		mov	word ptr StdGrp:fpacc.mantissa[5], ax
		mov	ax, es:2[di]
		mov	bx, ax
		shl	ax, 1
		mov	al, ah
		mov	ah, 0
		add	ax, 32767-127		;Adjust exponent bias.
		mov	word ptr StdGrp:fpacc.exponent, ax
		mov	StdGrp:fpacc.sign, bh	;Save sign away.
		mov	al, es:2[di]
		and	al, 7fh			;Strip out L.O. exp bit.
		or	al, 80h			;Add in implied bit.
		mov	byte ptr StdGrp:fpacc.mantissa[7], al ;Save H.O. mant byte.
		xor	ax, ax
		mov	word ptr StdGrp:fpacc.mantissa, ax
		mov	word ptr StdGrp:fpacc.mantissa[2], ax
		mov	byte ptr StdGrp:fpacc.mantissa[4], al
		pop	bx
		pop	ax
		ret
sl_LSFPA	endp
;
;
;
;
; sl_SSFPA-	Stores FPACC into the single precision variable pointed at by
;		ES:DI.  Performs appropriate rounding.  Returns carry clear
;		if the operation is successful, returns carry set if FPACC
;		cannot fit into a single precision variable.
;
		public	sl_SSFPA
sl_SSFPA	proc	far
		assume	ds:stdgrp
		push	ds
		push	ax
		push	bx
		mov	ax, StdGrp
		mov	ds, ax
		push	fpacc.Exponent
		push	fpacc.Mantissa   	;Save the stuff we tweak
		push	fpacc.Mantissa[2]	; so that this operation
		push	fpacc.Mantissa[4]	; will be non-destructive.
		push	fpacc.Mantissa[6]
;
; First, round FPACC:
;
		add	fpacc.Mantissa [4], 80h
		adc	fpacc.Mantissa [6], 0
		jnc	StoreAway
		rcl	fpacc.Mantissa [6], 1
		rcl	fpacc.Mantissa [4], 1
		inc	fpacc.Exponent
		jz	BadSSFPA		;If exp overflows.
;
; Store the value away:
;
StoreAway:	mov	ax, fpacc.Exponent
		sub	ax, 32767-127		;Convert to bias 127
		cmp	ah, 0
		jne	BadSSFPA
		mov	bl, fpacc.Sign
		shl	bl, 1			;Merge in the sign bit.
		rcr	al, 1
		mov	es:[di] + 3, al		;Save away exponent/sign
		pushf				;Save bit shifted out.
		mov	ax, fpacc.Mantissa [6]
		shl	ax, 1			;Get rid of implied bit and
		popf				; shift in the L.O. exponent
		rcr	ax, 1			; bit.
		mov	es:[di] + 1, ax
		mov	al, byte ptr fpacc.Mantissa [5]
		mov	es:[di], al
		clc
		jmp	SSFPADone
;
BadSSFPA:	stc
SSFPADone:	pop	fpacc.Mantissa[6]
		pop	fpacc.Mantissa[4]
		pop	fpacc.Mantissa[2]
		pop	fpacc.Mantissa
		pop	fpacc.Exponent
		pop	bx
		pop	ax
		pop	ds
		ret
		assume	ds:nothing
sl_SSFPA	endp
;
;
; sl_LDFPA-	Loads the double precision (64-bit) IEEE format number pointed
;		at by ES:DI into FPACC.
;
		public	sl_LDFPA
sl_LDFPA	proc	far
		push	ax
		push	bx
		push	cx
		mov	ax, es:6[di]
		mov	StdGrp:fpacc.sign, ah	;Save sign bit.
		mov	cl, 4
		shr	ax, cl			;Align exponent field.
		and	ah, 111b		;Strip the sign bit.
		add	ax, 32767-1023		;Adjust bias
		mov	StdGrp:fpacc.exponent, ax
;
; Get the mantissa bits and left justify them in the FPACC.
;
		mov	ax, es:5[di]
		and	ax, 0fffh		;Strip exponent bits.
		or	ah, 10h			;Add in implied bit.
		mov	cl, 3
		shl	ax, cl
		mov	bx, es:3[di]
		rol	bx, cl
		mov	ch, bl
		and	ch, 7
		or	al, ch
		mov	StdGrp:fpacc.mantissa[6], ax
;
		and	bl, 0f8h
		mov	ax, es:1[di]
		rol	ax, cl
		mov	ch, al
		and	ch, 7
		or	bl, ch
		mov	StdGrp:fpacc.mantissa[4], bx
;
		and	al, 0f8h
		mov	bh, es:[di]
		rol	bh, cl
		mov	ch, bh
		and	ch, 7
		or	al, ch
		mov	StdGrp:fpacc.mantissa[2], ax
		and	bh, 0f8h
		mov	bl, 0
		mov	StdGrp:fpacc.Mantissa[0], bx
;
		pop	cx
		pop	bx
		pop	ax
		ret
sl_LDFPA	endp
;
;
;
;
; sl_SDFPA-	Stores FPACC into the double precision variable pointed
;		at by ES:DI.
;
		public	sl_sdfpa
sl_SDFPA	proc	far
		assume	ds:stdgrp
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
;
		mov	bx, StdGrp
		mov	ds, bx
;
		push	fpacc.Mantissa [0]
		push	fpacc.Mantissa [2]
		push	fpacc.Mantissa [4]
		push	fpacc.Mantissa [6]
		push	fpacc.Exponent
;
; First, round this guy to 52 bits:
;
		add	byte ptr fpacc.Mantissa [1], 8
		jnc	SkipRndUp
		inc	fpacc.Mantissa [2]
		jnz	SkipRndUp
		inc	fpacc.Mantissa [4]
		jnz	SkipRndUp
		inc	fpacc.Mantissa [6]
		jnz	SkipRndUp
;
; Whoops!  Got an overflow, fix that here:
;
		stc
		rcr	fpacc.Mantissa [6], 1
		rcr	fpacc.Mantissa [4], 1
		rcr	fpacc.Mantissa [2], 1
		rcr	byte ptr fpacc.Mantissa [1], 1
		inc	fpacc.Exponent
		jz	BadSDFPA		;In case exp was really big.
;
; Okay, adjust and store the exponent-
;
SkipRndUp:	mov	ax, fpacc.Exponent
		sub	ax, 32767-1023		;Adjust bias
		cmp	ax, 2048		;Make sure the value will still
		jae	BadSDFPA		; fit in an 8-byte real.
		mov	cl, 5
		shl	ax, cl			;Move exponent into place.
		mov	bl, fpacc.Sign
		shl	bl, 1
		rcr	ax, 1			;Merge in sign bit.
;
; Merge in the upper four bits of the Mantissa (don't forget that the H.O.
; Mantissa bit is lost due to the implied one bit).
;
		mov	bl, byte ptr fpacc.Mantissa [7]
		shr	bl, 1
		shr	bl, 1
		shr	bl, 1
		and	bl, 0fh			;Strip away H.O. mant bit.
		or	al, bl
		mov	es:[di]+6, ax		;Store away H.O. word.
;
; Okay, now adjust and store away the rest of the mantissa:
;
		mov	ax, fpacc.Mantissa [0]
		mov	bx, fpacc.Mantissa [2]
		mov	cx, fpacc.Mantissa [4]
		mov	dx, fpacc.Mantissa [6]
;
; Shift the bits to their appropriate places (to the left five bits):
;
		shl	ax, 1
		rcl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
;
		shl	ax, 1
		rcl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
;
		shl	ax, 1
		rcl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
;
		shl	ax, 1
		rcl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
;
		shl	ax, 1
		rcl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
;
; Store away the results:
;
		mov	es:[di], bx
		mov	es:[di] + 2, cx
		mov	es: [di] + 4, dx
;
; Okay, we're done.  Return carry clear to denote success.
;
		clc
		jmp	short QuitSDFPA
;
BadSDFPA:	stc				;If an error occurred.
QuitSDFPA:	pop	fpacc.Exponent
		pop	fpacc.Mantissa [6]
		pop	fpacc.Mantissa [4]
		pop	fpacc.Mantissa [2]
		pop	fpacc.Mantissa [0]
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
;
		assume	ds:nothing
sl_SDFPA	endp
;
;
;
;
; sl_LEFPA-	Loads an extended precision (80-bit) IEEE format number
;		into the floating point accumulator.  ES:DI points at the
;		number to load into FPACC.
;
		public	sl_LEFPA
sl_LEFPA	proc	far
		push	ax
		mov	ax, es:8[di]
		mov	StdGrp:fpacc.Sign, ah
		and 	ah, 7fh
		add	ax, 4000h
		mov	StdGrp:fpacc.Exponent, ax
		mov	ax, es:[di]
		mov	StdGrp:fpacc.Mantissa, ax
		mov	ax, es:2[di]
		mov	StdGrp:fpacc.Mantissa[2], ax
		mov	ax, es:4[di]
		mov	StdGrp:fpacc.Mantissa[4], ax
		mov	ax, es:6[di]
		mov	StdGrp:fpacc.Mantissa[6], ax
		pop	ax
		ret
sl_LEFPA	endp
;
;
; sl_LEFPAL-	Loads an extended precision (80-bit) IEEE format number
;		into the floating point accumulator.  The number to load
;		into FPACC follows the call in the code stream.
;
		public	sl_LEFPAL
sl_LEFPAL	proc	far
		push	bp
		mov	bp, sp
		push	es
		push	di
		push	ax
		les	di, 2[bp]
;
		mov	ax, es:8[di]
		mov	StdGrp:fpacc.Sign, ah
		and 	ah, 7fh
		add	ax, 4000h
		mov	StdGrp:fpacc.Exponent, ax
		mov	ax, es:[di]
		mov	StdGrp:fpacc.Mantissa, ax
		mov	ax, es:2[di]
		mov	StdGrp:fpacc.Mantissa[2], ax
		mov	ax, es:4[di]
		mov	StdGrp:fpacc.Mantissa[4], ax
		mov	ax, es:6[di]
		mov	StdGrp:fpacc.Mantissa[6], ax
;
; Adjust the return address to point past the floating point number we
; just loaded.
;
		add	word ptr 2[bp], 10
;
		pop	ax
		pop	di
		pop	es
		pop	bp
		ret
sl_LEFPAL	endp
;
;
; sl_SEFPA-	Stores FPACC into in the extended precision variable
;		pointed at by ES:DI.
;
sl_SEFPA	proc	far
		assume	ds:stdgrp
		push	ds
		push	ax
		mov	ax, StdGrp
		mov	ds, ax
		push	fpacc.Mantissa [0]
		push	fpacc.Mantissa [2]
		push	fpacc.Mantissa [4]
		push	fpacc.Mantissa [6]
		push	fpacc.Exponent
;
		mov	ax, fpacc.Exponent
		sub	ax, 4000h
		cmp	ax, 8000h
		jae	BadSEFPA
		test	fpacc.Sign, 80h
		jz	StoreSEFPA
		or	ah, 80h
StoreSEFPA:	mov	es:[di]+8, ax
		mov	ax, fpacc.Mantissa [0]
		mov	es:[di], ax
		mov	ax, fpacc.Mantissa [2]
		mov	es:[di] + 2, ax
		mov	ax, fpacc.Mantissa [4]
		mov	es:[di] + 4, ax
		mov	ax, fpacc.Mantissa [6]
		mov	es:[di] + 6, ax
		clc
		jmp	SEFPADone
;
BadSEFPA:	stc
SEFPADone:	pop	fpacc.Exponent
		pop	fpacc.Mantissa[6]
		pop	fpacc.Mantissa[4]
		pop	fpacc.Mantissa[2]
		pop	fpacc.Mantissa[0]
		pop	ax
		pop	ds
		ret
		assume	ds:nothing
sl_SEFPA        endp
;
;
;
; sl_LSFPO- 	Loads a single precision (32-bit) IEEE format number into
;		the floating point operand.  ES:DI points at the # to
;		load into FPOP.
;
		public	sl_LSFPO
sl_LSFPO	proc	far
		push	ax
		push	bx
		mov	ax, es:[di]
		mov	word ptr StdGrp:fpop.mantissa[5], ax
		mov	ax, es:2[di]
		mov	bx, ax
		shl	ax, 1
		mov	al, ah
		mov	ah, 0
		add	ax, 32767-127		;Adjust exponent bias.
		mov	word ptr StdGrp:fpop.exponent, ax
		mov	StdGrp:fpop.sign, bh	;Save sign away.
		mov	al, ds:2[di]
		and	al, 7fh			;Strip out L.O. exp bit.
		or	al, 80h			;Add in implied bit.
		mov	byte ptr StdGrp:fpop.mantissa[7], al
		xor	ax, ax
		mov	word ptr StdGrp:fpop.mantissa, ax
		mov	word ptr StdGrp:fpop.mantissa[2], ax
		mov	byte ptr StdGrp:fpop.mantissa[4], al
		pop	bx
		pop	ax
		ret
sl_LSFPO	endp
;
;
;
;
;
; sl_LDFPO-	Loads the double precision (64-bit) IEEE format number pointed
;		at by ES:DI into FPOP.
;
		public	sl_LDFPO
sl_LDFPO	proc	far
		push	ax
		push	bx
		push	cx
		mov	ax, es:6[di]
		mov	StdGrp:fpop.sign, ah	;Save sign bit.
		mov	cl, 4
		shr	ax, cl			;Align exponent field.
		and	ah, 111b		;Strip the sign bit.
		add	ax, 32767-1023		;Adjust bias
		mov	word ptr StdGrp:fpop.exponent, ax
;
; Get the mantissa bits and left justify them in the FPOP.
;
		mov	ax, es:5[di]
		and	ax, 0fffh		;Strip exponent bits.
		or	ah, 10h			;Add in implied bit.
		mov	cl, 3
		shl	ax, cl
		mov	bx, es:3[di]
		rol	bx, cl
		mov	ch, bl
		and	ch, 7
		or	al, ch
		mov	word ptr StdGrp:fpop.mantissa[6], ax
;
		and	bl, 0f8h
		mov	ax, es:1[di]
		rol	ax, cl
		mov	ch, al
		and	ch, 7
		or	bl, ch
		mov	word ptr StdGrp:fpop.mantissa[4], bx
;
		and	al, 0f8h
		mov	bh, es:[di]
		rol	bh, cl
		mov	ch, bh
		and	ch, 7
		or	al, ch
		mov	word ptr StdGrp:fpop.mantissa[2], ax
		and	bh, 0f8h
		mov	bl, 0
		mov	word ptr StdGrp:fpop.Mantissa[0], bx
;
		pop	cx
		pop	bx
		pop	ax
		ret
sl_LDFPO	endp
;
;
;
;
;
; sl_LEFPO-	Loads an extended precision (80-bit) IEEE format number
;		into the floating point operand.  ES:DI points at the
;		number to load into FPACC.
;
		public	sl_LEFPO
sl_LEFPO	proc	far
		push	ax
		mov	ax, es:8[di]
		mov	StdGrp:fpop.Sign, ah
		and 	ah, 7fh
		add	ax, 4000h
		mov	StdGrp:fpop.Exponent, ax
		mov	ax, es:[di]
		mov	StdGrp:fpop.Mantissa, ax
		mov	ax, es:2[di]
		mov	StdGrp:fpop.Mantissa[2], ax
		mov	ax, es:4[di]
		mov	StdGrp:fpop.Mantissa[4], ax
		mov	ax, es:6[di]
		mov	StdGrp:fpop.Mantissa[6], ax
		pop	ax
		ret
sl_LEFPO	endp
;
;
;
;
; sl_LEFPOL-	Loads an extended precision (80-bit) IEEE format number
;		into the floating point operand.  The number to load
;		follows the call instruction in the code stream.
;
		public	sl_LEFPOL
sl_LEFPOL	proc	far
		push	bp
		mov	bp, sp
		push	es
		push	di
		push	ax
		les	di, 2[bp]
;
		mov	ax, es:8[di]
		mov	StdGrp:fpop.Sign, ah
		and 	ah, 7fh
		add	ax, 4000h
		mov	StdGrp:fpop.Exponent, ax
		mov	ax, es:[di]
		mov	StdGrp:fpop.Mantissa, ax
		mov	ax, es:2[di]
		mov	StdGrp:fpop.Mantissa[2], ax
		mov	ax, es:4[di]
		mov	StdGrp:fpop.Mantissa[4], ax
		mov	ax, es:6[di]
		mov	StdGrp:fpop.Mantissa[6], ax
;
		add	word ptr 2[bp], 10	;Skip rtn adrs past #.
;
		pop	ax
		pop	di
		pop	es
		pop	bp
		ret
sl_LEFPOL	endp
;
;
;
;
;
;
;
;--------------------------------------------------------------------------
; 		Integer <=> FP Conversions
;--------------------------------------------------------------------------
;
;
;
; ITOF-		Converts 16-bit signed value in AX to a floating point value
;		in FPACC.
;
		public	sl_itof
sl_itof		proc	far
		assume	ds:stdgrp
		push	ds
		push	ax
		push	cx
		mov	cx, StdGrp
		mov	ds, cx
;
		mov	cx, 800Fh		;Magic exponent value (65536).
;
; Set the sign of the result:
;
		mov	fpacc.Sign, 0		;Assume a positive value.
		or	ax, ax			;Special case for zero!
		jz	SetFPACC0
		jns	DoUTOF			;Take care of neg values.
		mov	fpacc.sign, 80h		;This guy is negative!
		neg	ax			;Work with abs(AX).
		jmp	DoUTOF
sl_ITOF		endp
;
;
; UTOF-		Like ITOF above except this guy works for unsigned 16-bit
;		integer values.
;
		public	sl_utof
sl_UTOF		proc	far
		push	ds
		push	ax
		push	cx
;
;
		mov	cx, StdGrp
		mov	ds, cx
		mov	cx, 800Fh		;Magic exponent value (65536).
		or	ax, ax
		jz	SetFPACC0
		mov	fpacc.Sign, 0
;
sl_UTOF		endp
;
;
; Okay, convert the number to a floating point value:
; Remember, we need to end up with a normalized number (one where the H.O.
; bit of the mantissa contains a one).  The largest possible value (65535 or
; 0FFFFh) is equal to 800E FFFF 0000 0000 0000.  All other values have an
; exponent less than or equal to 800Eh.  If the H.O. bit of the value is
; not one, we must shift it to the left and dec the exp by 1.  E.g., if AX
; contains 1, then we will need to shift it 15 times to normalize the value,
; decrementing the exponent each time produces 7fffh which is the proper
; exponent for "1".
;
; Note: this is not a proc!  Making it a proc makes it incompatible with
; one or more different assemblers (TASM, OPTASM, MASM6).
; Besides, this has to be a near label with a far return!
;
DoUTOF:
UTOFWhlPos:	dec	cx
		shl	ax, 1
		jnc	UTOFWhlPos
		rcr	ax, 1			;Put bit back.
		mov	fpacc.Exponent, cx	;Save exponent value.
		mov	fpacc.Mantissa [6], ax	;Save Mantissa value.
		xor	ax, ax
		mov	fpacc.Mantissa [4], ax	;Zero out the rest of the
		mov	fpacc.Mantissa [2], ax	; mantissa.
		mov	fpacc.Mantissa [0], ax
		jmp     UTOFDone
;
; Special case for zero, must zero all bytes in FPACC.  Note that AX already
; contains zero.
;
SetFPACC0:	mov	fpacc.Exponent, ax
		mov	fpacc.Mantissa [6], ax
		mov	fpacc.Mantissa [4], ax
		mov	fpacc.Mantissa [2], ax
		mov	fpacc.Mantissa [0], ax
		mov	fpacc.Sign, al
;
UTOFDone:	pop	cx
		pop	ax
		pop	ds
		retf
;
;
;
;
;
;
; LTOF-		Converts 32-bit signed value in DX:AX to a floating point
;		value in FPACC.
;
		public	sl_ltof
sl_ltof		proc	far
		assume	ds:stdgrp
		push	ds
		push	ax
		push	cx
		push	dx
		mov	cx, StdGrp
		mov	ds, cx
;
; Set the sign of the result:
;
		mov	fpacc.Sign, 0		;Assumed a positive value.
		mov	cx, dx
		or	cx, ax
		jz	SetUL0
		or	dx, dx			;Special case for zero!
		jns	DoULTOF			;Take care of neg values.
		mov	fpacc.sign, 80h		;This guy is negative!
		neg	dx			;Do a 32-bit NEG operation
		neg	ax			; (yes, this really does
		sbb	dx, 0			;  work!).
		jmp	DoULTOF
sl_LTOF		endp
;
;
; ULTOF-	Like LTOF above except this guy works for unsigned 32-bit
;		integer values.
;
		public	sl_ultof
sl_ULTOF	proc	far
		push	ds
		push	ax
		push	cx
		push	dx
;
		mov	cx, StdGrp
		mov	ds, cx
;
		mov	cx, dx
		or	cx, ax
		jz	SetUL0
		mov	fpacc.Sign, 0
;
sl_ULTOF		endp
;
;
;
DoULTOF:
		mov	cx, 801Fh		;Magic exponent value (65536).
ULTOFWhlPos:	dec	cx
		shl	ax, 1
		rcl	dx, 1
		jnc	ULTOFWhlPos
		rcr	dx, 1			;Put bit back.
		rcr	ax, 1
		mov	fpacc.Exponent, cx	;Save exponent value.
		mov	fpacc.Mantissa [6], dx	;Save Mantissa value.
		mov	fpacc.Mantissa [4], ax
		xor	ax, ax			;Zero out the rest of the
		mov	fpacc.Mantissa [2], ax	; mantissa.
		mov	fpacc.Mantissa [0], ax
		jmp     ULTOFDone
;
; Special case for zero, must zero all bytes in FPACC.  Note that AX already
; contains zero.
;
SetUL0:		mov	fpacc.Exponent, ax
		mov	fpacc.Mantissa [6], ax
		mov	fpacc.Mantissa [4], ax
		mov	fpacc.Mantissa [2], ax
		mov	fpacc.Mantissa [0], ax
		mov	fpacc.Sign, al
;
ULTOFDone:	pop	dx
		pop	cx
		pop	ax
		pop	ds
		retf
;
;
;
;
; FTOI- Converts the floating point value in FPACC to a signed 16-bit
;	integer and returns this integer in AX.
;	Returns carry set if the number is too big to fit into AX.
;
		public	sl_FTOI
sl_FTOI		proc	far
		assume	ds:stdgrp
		push	ds
		push	cx
		mov	cx, StdGrp
		mov	ds, cx
;
		mov	cx, fpacc.Exponent
		cmp	cx, 800eh
		jb	FTOIok
;
; Handle special case of -32768:
;
		call	DoFToU
		cmp	ax, 8000h
		je	FtoiOk2
		stc
		jmp	TooBig
;
FTOIok:		call	DoFTOU
FtoiOk2:	cmp	fpacc.Sign, 0
		jns	FTOIJustRight
		neg	ax
FTOIJustRight:	clc
TooBig:		pop	cx
		pop	ds
		ret
sl_FTOI		endp
;
;
;
;
; FTOU- Like FTOI above, except this guy converts a floating point value
; 	to an unsigned integer in AX.
;	Returns carry set if out of range (including negative numbers).
;
		public	sl_FTOU
sl_FTOU		proc	far
		assume	ds:stdgrp
		push	ds
		push	cx
		mov	cx, StdGrp
		mov	ds, cx
;
		mov	cx, fpacc.Exponent
		cmp	cx, 800fh
		jb	FTOUok
BadU:		stc
		jmp	UTooBig
;
FTOUok:		call	DoFTOU
		cmp	fpacc.Sign, 0
		js	BadU
;
FTOUJustRight:	clc
UTooBig:	pop	cx
		pop	ds
		ret
sl_FTOU		endp
;
;
; DoFTOU- This code does the actual conversion!
;
DoFTOU		proc	near
		mov	ax, fpacc.Mantissa [6]
		cmp	cx, 7fffh
		jb	SetFTOU0
		sub	cx, 800eh
		neg	cx
		shr	ax, cl
		ret
;
SetFTOU0:	xor	ax, ax
		ret
DoFTOU		endp
;
;
;
;
;
; FTOL- Converts the floating point value in FPACC to a signed 32-bit
;	integer and returns this integer in DX:AX.
;	Returns carry set if the number is too big to fit into DX:AX.
;
		public	sl_FTOL
sl_FTOL		proc	far
		assume	ds:StdGrp
		push	ds
		push	cx
		mov	cx, StdGrp
		mov	ds, cx
;
		mov	cx, fpacc.Exponent
		cmp	cx, 801eh
		jb	FTOLok
		stc
		jmp	LTooBig
;
FTOLok:		call	DoFTOUL
		cmp	fpacc.Sign, 0
		jns	FTOLJustRight
		neg	dx    		;32-bit negate operation.
		neg	ax
		sbb	dx, 0
FTOLJustRight:	clc
LTooBig:	pop	cx
		pop	ds
		ret
sl_FTOL		endp
;
;
;
;
; FTOUL-Like FTOL above, except this guy converts a floating point value
; 	to a 32-bit unsigned integer in DX:AX.
;	Returns carry set if out of range (including negative numbers).
;
		public	sl_FTOUL
sl_FTOUL	proc	far
		assume	ds:StdGrp
		push	ds
		push	cx
		mov	cx, StdGrp
		mov	ds, cx
;
		mov	cx, fpacc.Exponent
		cmp	cx, 801fh
		jb	FTOULok
BadUL:		stc
		jmp	ULTooBig
;
FTOULok:	call	DoFTOUL
		cmp	fpacc.Sign, 0
		js	BadUL
;
		clc				;If the # is okay.
ULTooBig:	pop	cx
		pop	ds
		ret
sl_FTOUL	endp
;
;
; DoFTOUL- This code does the actual conversion!
;
DoFTOUL		proc	near
		mov	dx, fpacc.Mantissa [6]
		mov	ax, fpacc.Mantissa [4]
		cmp	cx, 7fffh
		jb	SetFTOUL0
		sub	cx, 801eh
		neg	cx
		jcxz	SetFTOULDone
FTOULLp:	shr	dx, 1
		rcr	ax, 1
		loop	FTOULLp
SetFToULDone:	ret
;
SetFTOUL0:	xor	ax, ax
		xor	dx, dx
		ret
DoFTOUL		endp
;
;
;
;
;
;
;
;
;
;
;
;
;
;---------------------------------------------------------------------------
;		Floating Point Addition & Subtraction
;---------------------------------------------------------------------------
;
;
;
;
; FADD- Adds FOP to FACC
; FSUB- Subtracts FOP from FACC
;	These routines destroy the value in FPOP!
;
		public	sl_fsub
		public	sl_fadd
;
		assume	ds:nothing
sl_fsub		proc	far
		xor	StdGrp:fpop.sign, 80h
sl_fsub		endp
;
		assume	ds:StdGrp
sl_fadd		proc	far
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
;
; Use the current CS as the data segment to get direct access to
; the floating point accumulator and operands.
;
		mov	ax, StdGrp
		mov	ds, ax
;
; Adjust the smaller of the two operands so that the exponents of the two
; objects are the same:
;
		mov	cx, fpacc.exponent
		sub	cx, fpop.exponent
		js	gotoAdjustFPA
		jnz	AdjustFPOP
		jmp	Adjusted		;Only if exponents are equal.
gotoAdjustFPA:	jmp	AdjustFPACC
;
; Since the difference of the exponents is negative, the magnitude of FPOP
; is smaller than the magnitude of fpacc.  Adjust FPOP here.
;
AdjustFPOP:	cmp	cx, 64			;If greater than 64, forget
		jb	short By16LoopTest	; it.  Sum is equal to FPACC.
		jmp	Done
;
; If the difference is greater than 16 bits, adjust FPOP a word at a time.
; Note that there may be multiple words adjusted in this fashion.
;
By16Loop:	mov	ax, fpop.mantissa[2]
		mov	fpop.mantissa[0], ax
		mov	ax, fpop.mantissa[4]
		mov	fpop.mantissa[2], ax
		mov	ax, fpop.mantissa[6]
		mov	fpop.mantissa[4], ax
		mov	fpop.mantissa[6], 0
		sub	cx, 16
By16LoopTest:	cmp	cx, 16
		jae	By16Loop
;
; After adjusting sixteen bits at a time, see if there are at least eight
; bits.  Note that this can only occur once, for if you could adjust by
; eight bits twice, you could have adjusted by 16 above.
;
		cmp	cx, 8
		jb	NotBy8
		mov	ax, fpop.mantissa[1]
		mov	fpop.mantissa[0], ax
		mov	ax, fpop.mantissa[3]
		mov	fpop.mantissa[2], ax
		mov	ax, fpop.mantissa[5]
		mov	fpop.mantissa[4], ax
		mov	al, byte ptr fpop.mantissa [7]
		mov	byte ptr fpop.mantissa [6], al
		mov	byte ptr fpop.mantissa[7], 0
		sub	cx, 8
;
; Well, now we're down to a bit at a time.
;
NotBy8:		jcxz	AdjFPOPDone
;
; Load the mantissa into registers to save processing time.
;
		mov	ax, fpop.mantissa[6]
		mov	bx, fpop.mantissa[4]
		mov	dx, fpop.mantissa[2]
		mov	si, fpop.mantissa[0]
By1Loop:	shr	ax, 1
		rcr	bx, 1
		rcr	dx, 1
		rcr	si, 1
		loop	By1Loop
		mov	fpop.mantissa[6], ax	;Save result back into
		mov	fpop.mantissa[4], bx	; fpop.
		mov	fpop.mantissa[2], dx
		mov	fpop.mantissa[0], si
AdjFPOPDone:	jmp     Adjusted
;
;
;
; AdjustFPACC- FPACC was smaller than FPOP, so adjust its bits down here.
;	       This code is pretty much identical to the above, the same
;	       comments apply.
;
AdjustFPACC:	neg	cx			;Take ABS(cx)
		cmp	cx, 64			;If greater than 64, forget
		jb	By16LpTest		; it.
		jmp	SetFPACC2Zero
;
By16Lp:		mov	ax, fpacc.mantissa[2]
		mov	fpacc.mantissa[0], ax
		mov	ax, fpacc.mantissa[4]
		mov	fpacc.mantissa[2], ax
		mov	ax, fpacc.mantissa[6]
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], 0
		sub	cx, 16
By16LpTest:	cmp	cx, 16
		jae	By16Lp
;
		cmp	cx, 8
		jb	NotBy8a
		mov	ax, fpacc.mantissa[1]
		mov	fpacc.mantissa[0], ax
		mov	ax, fpacc.mantissa[3]
		mov	fpacc.mantissa[2], ax
		mov	ax, fpacc.mantissa[5]
		mov	fpacc.mantissa[4], ax
		mov	al, byte ptr fpacc.mantissa [7]
		mov	byte ptr fpacc.mantissa [6], al
		mov	byte ptr fpacc.mantissa[7], 0
		sub	cx, 8
;
NotBy8a:	jcxz	Adjusted
		mov	ax, fpacc.mantissa[6]
		mov	bx, fpacc.mantissa[4]
		mov	dx, fpacc.mantissa[2]
		mov	si, fpacc.mantissa[0]
By1Lp:		shr	ax, 1
		rcr	bx, 1
		rcr	dx, 1
		rcr	si, 1
		loop	By1Lp
		mov	fpacc.mantissa[6], ax
		mov	fpacc.mantissa[4], bx
		mov	fpacc.mantissa[2], dx
		mov	fpacc.mantissa[0], si
		mov	ax, fpop.Exponent	;FPACC assumes the same
		mov	fpacc.Exponent, ax	; exponent as FPOP.
AdjFPACCDone:	jmp     Adjusted
;
; If FPACC is so much smaller than FPOP that it is insignificant, set
; it to zero.
;
SetFPACC2Zero:	xor	ax, ax
		mov	fpacc.mantissa[0], ax
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], ax
		mov	fpacc.exponent, ax
		mov	fpacc.sign, al
;
; Now that the mantissas are aligned, let's add (or subtract) them.
;
Adjusted:	mov	al, fpacc.sign
		xor	al, fpop.sign
		js	SubEm
;
; If the signs are the same, simply add the mantissas together here.
;
		mov	ax, fpop.mantissa[0]
		add	fpacc.mantissa[0], ax
		mov	ax, fpop.mantissa[2]
		adc	fpacc.mantissa[2], ax
		mov	ax, fpop.mantissa[4]
		adc	fpacc.mantissa[4], ax
		mov	ax, fpop.mantissa[6]
		adc	fpacc.mantissa[6], ax
		jnc	Normalize
;
; If there was a carry out of the addition (quite possible since most
; fp values are normalized) then we need to shove the bit back into
; the number.
;
		rcr	fpacc.mantissa[6], 1
		rcr	fpacc.mantissa[4], 1
		rcr	fpacc.mantissa[2], 1
		rcr	fpacc.mantissa[0], 1
		inc	fpacc.exponent
;
; If there was a carry out of the bottom, add it back in (this rounds the
; result).  No need to worry about a carry out of the H.O. bit this time--
; there is no way to add together two numbers to get a carry *and* all
; one bits in the result.  Therefore, rounding at this point will not
; propagate all the way through.
;
		adc	fpacc.Mantissa [0], 0
		jnc	Normalize
		inc	fpacc.Mantissa [2]
		jnz	Normalize
		inc	fpacc.Mantissa [4]
		jnz	Normalize
		inc	fpacc.Mantissa [6]
		jmp	Normalize
;
;
;
; If the signs are different, we've got to deal with four possibilities:
;
; 1) fpacc is negative and its magnitude is greater than fpop's.
;	Result is negative, fpacc.mant := fpacc.mant - fpop.mant.
;
; 2) fpacc is positive and its magnitude is greater than fpop's.
;	Result is positive, fpacc.mant := fpacc.mant - fpop.mant.
;
; 3) fpacc is negative and its magnitude is less than fpop's.
;	Result is positive, fpacc.mant := fpop.mant - fpacc.mant.
;
; 4) fpacc is positive and its magnitude is less than fpop's.
;	Result is negative, fpacc.mant := fpop.mant - fpacc.mant.
;
SubEm:		mov	ax, fpacc.mantissa[0]
		mov	bx, fpacc.mantissa[2]
		mov	dx, fpacc.mantissa[4]
		mov	si, fpacc.mantissa[6]
		sub	ax, fpop.mantissa[0]
		sbb	bx, fpop.mantissa[2]
		sbb	dx, fpop.mantissa[4]
		sbb     si, fpop.mantissa[6]
		jnc	StoreFPACC
;
; Whoops!  FPOP > FPACC, fix that down here.
;
		not	ax
		not	bx
		not	dx
		not	si
		inc 	ax
		jnz	StoreFPACCSign
		inc	bx
		jnz	StoreFPAccSign
		inc	dx
		jnz	StoreFPAccSign
		inc	si
;
StoreFPAccSign:	xor	fpacc.sign, 80h			;Flip sign if case 3/4.
;
StoreFPAcc:	mov	fpacc.mantissa[0], ax
		mov	fpacc.mantissa[2], bx
		mov	fpacc.mantissa[4], dx
		mov	fpacc.mantissa[6], si
;
;
; Normalize the result down here.  Start by shifting 16 bits at a time,
; then eight bits, then one bit at a time.
;
Normalize:	mov	ax, fpacc.mantissa[6]
		or	ax, ax		      	;See if zero (which means we
		jnz	Try8Bits		; can shift 16 bits).
		mov	ax, fpacc.mantissa[4]
		mov	fpacc.mantissa[6], ax
		mov	ax, fpacc.mantissa[2]
		mov	fpacc.mantissa[4], ax
		mov	ax, fpacc.mantissa[0]
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[0],0
		sub	fpacc.exponent, 16
		jmp	Normalize
;
; Okay, see if we can normalize eight bits at a shot.
;
Try8Bits:	mov	al, byte ptr fpacc.mantissa[7]
		cmp	al, 0
		jnz	Try1Bit
		mov	ax, fpacc.mantissa[5]
		mov	fpacc.mantissa[6], ax
		mov	ax, fpacc.mantissa[3]
		mov	fpacc.mantissa[4], ax
		mov	ax, fpacc.mantissa[1]
		mov	fpacc.mantissa[3], ax
		mov	al, byte ptr fpacc.mantissa[0]
		mov	byte ptr fpacc.mantissa[1], al
		mov	byte ptr fpacc.mantissa[0], 0
		sub	fpacc.exponent, 8
;
Try1Bit:	mov	ax, fpacc.mantissa[6]
		test	ah, 80h
		jnz	Done
		mov	bx, fpacc.mantissa[4]
		mov	dx, fpacc.mantissa[2]
		mov	si, fpacc.mantissa[0]
OneBitLp:	dec	fpacc.exponent
		shl	si, 1
		rcl	dx, 1
		rcl	bx, 1
		rcl	ax, 1
		or	ax, ax			;See if bit 15 is set.
		jns	OneBitLp
		mov	fpacc.mantissa[6], ax
		mov	fpacc.mantissa[4], bx
		mov	fpacc.mantissa[2], dx
		mov	fpacc.mantissa[0], si
;
Done:		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
sl_fadd		endp
;
;
;
;
;
;
;
;
;
;
;---------------------------------------------------------------------------
; Floating point comparison.
;---------------------------------------------------------------------------
;
;
; FCMP
; Compares value in FPACC to value in FPOP.
; Returns -1 in AX if FPACC is less than FPOP,
; Returns 0  in AX if FPACC is equal to FPOP,
; Returns 1  in AX if FPACC is greater than FPOP.
;
; Also returns this status in the flags (by comparing AX against zero
; before returning) so you can use JE, JNE, JG, JGE, JL, or JLE after this
; routine to test the comparison.
;
		public	sl_fcmp
sl_fcmp		proc	far
		assume	ds:StdGrp
		push	ds
		mov	ax, StdGrp
		mov	ds, ax
;
; First compare the signs of the mantissas.  If they are different, the
; negative one is smaller.
;
		mov	al, byte ptr FPACC+10	;Get sign bit
		xor	al, byte ptr FPOP+10	;See if the signs are different
		jns	SameSign
;
; If the signs are different, then the sign of FPACC determines the result
;
		test	byte ptr FPACC+10, 80h
		jnz	IsLT
		jmp	short IsGT
;
; Down here the signs are the same.  First order of business is to compare
; the exponents.  The one with the larger exponent wins.  If the exponents
; are equal, then we need to compare the mantissas.  If the mantissas are
; the same then the two numbers are equal.  If the mantissas are different
; then the larger one wins.  Note that this discussion is for positive values
; only, if the numbers are negative, then we must reverse the win/loss value
; (win=GT).
;
SameSign:	mov	ax, FPACC.exponent	;One thing cool about bias-
		cmp	ax, FPOP.exponent	; 1023 exponents is that we
		ja	MayBeGT			; can use an unsigned compare
		jb	MayBeLT
;
; If the exponents are equal, we need to start comparing the mantissas.
; This straight line code turns out to be about the fastest way to do it.
;
		mov	ax, word ptr FPACC.mantissa+6
		cmp	ax, word ptr FPOP.mantissa+6
		ja	MayBeGT
		jb	MayBeLT
		mov	ax, word ptr FPACC.mantissa+4
		cmp	ax, word ptr FPOP.mantissa+4
		ja	MayBeGT
		jb	MayBeLT
		mov	ax, word ptr FPACC.mantissa+2
		cmp	ax, word ptr FPOP.mantissa+2
		ja	MayBeGT
		jb	MayBeLT
		mov	ax, word ptr FPACC.mantissa
		cmp	ax, word ptr FPOP.mantissa
		ja	MayBeGT
		je	IsEq			;They're equal at this point.
;
; MayBeLT- Looks like less than so far, but we need to check the sign of the
; numbers, if they are negative then FPACC is really GT FPOP.  Remember, the
; sign is not part of the mantissa!
;
MayBeLT:	test	FPACC.sign, 80h
		js	IsGT
;
IsLT:		mov	ax, -1
		jmp	short cmpRtn
;
; Same story here for MayBeGT
;
MayBeGT:	test	FPACC.sign, 80h
		js	IsLT
;
IsGT:		mov	ax, 1
		jmp	short cmpRtn
;
IsEq:		xor	ax, ax
cmpRtn:		pop	ds
		cmp	ax, 0			;Set the flags as appropriate
		ret
sl_fcmp		endp
		assume	ds:nothing
;
;
;
;
;
;
;
;
;
;
;
;
;
;---------------------------------------------------------------------------
;		Floating Point Multiplication
;---------------------------------------------------------------------------
;
;
;
;
; sl_fmul- Multiplies facc by fop and leaves the result in facc.
;
		public	sl_fmul
sl_fmul		proc	far
		assume	ds:StdGrp
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
;
		mov	ax, StdGrp
		mov	ds, ax
;
; See if either operand is zero:
;
		mov	ax, fpacc.mantissa[0]	;No need to check exponent!
		or	ax, fpacc.mantissa[2]
		or	ax, fpacc.mantissa[4]
		or	ax, fpacc.mantissa[6]
		jz	ProdIsZero
;
		mov	ax, fpop.mantissa[0]
		or	ax, fpop.mantissa[2]
		or	ax, fpop.mantissa[4]
		or	ax, fpop.mantissa[6]
		jnz	ProdNotZero
;
ProdIsZero:	xor	ax, ax			;Need this!
		mov	fpacc.sign, al
		mov	fpacc.exponent, ax
		mov	fpacc.mantissa[0], ax
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], ax
		jmp	FMulDone
;
; If both operands are non-zero, compute the true product down here.
;
ProdNotZero:	mov	al, fpop.sign		;Compute the new sign.
		xor	fpacc.sign, al
;
; Eliminate bias in the exponents, add them, and check for 16-bit signed
; overflow.
;
		mov	ax, fpop.exponent	;Compute new exponent.
		sub	ax, 7fffh		;Subtract BIAS and adjust
		mov	bx, fpacc.Exponent
		sub	bx, 7fffh
		add	ax, bx			; for fractional multiply.
		jno	GoodExponent
;
; If the exponent overflowed, set up the overflow value here.
;
		mov	ax, 0ffffh
		mov	fpacc.exponent, ax	;Largest exponent value
		mov	fpacc.mantissa[0], ax	; and largest mantissa, too!
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], ax
		jmp	FMulDone
;
GoodExponent:	add	ax, 8000h		;Add the bias back in (note
		mov	fpacc.Exponent, ax	; Mul64 below causes shift
;						; to force bias of 7fffh.
; Okay, compute the product of the mantissas down here.
;
		call	Mul64
;
; Normalize the product.  Note: we know the product is non-zero because
; both of the original operands were non-zero.
;
		mov	cx, fpacc.exponent
		jmp	short TestNrmMul
NrmMul1:	sub	cx, 16
		mov	ax, fprod[12]
		mov	fprod[14], ax
		mov	ax, fprod[10]
		mov	fprod[12], ax
		mov	ax, fprod[8]
		mov	fprod[10], ax
		mov	ax, fprod[6]
		mov	fprod[8], ax
		mov	ax, fprod[4]
		mov	fprod[6], ax
		mov	ax, fprod[2]
		mov	fprod[4], ax
		mov	ax, fprod[0]
		mov	fprod[2], ax
		mov	fprod[0], 0
TestNrmMul:     cmp	cx, 16
		jb	DoNrmMul8
		mov  	ax, fprod[14]
		or	ax, ax
		jz	NrmMul1
;
; See if we can shift the product a whole byte
;
DoNrmMul8:	cmp	ah, 0			;Contains fprod[15] from above.
		jnz	DoOneBits
		cmp	cx, 8
		jb	DoOneBits
		mov	ax, fprod[13]
		mov	fprod[14], ax
		mov	ax, fprod[11]
		mov	fprod[12], ax
		mov	ax, fprod[9]
		mov	fprod[10], ax
		mov	ax, fprod[7]
		mov	fprod[8], ax
		mov	ax, fprod[5]
		mov	fprod[6], ax
		mov	ax, fprod[3]
		mov	fprod[4], ax
		mov	ax, fprod[1]
		mov	fprod[2], ax
		mov	al, byte ptr fprod[0]
		mov	byte ptr fprod[1], al
		mov	byte ptr fprod[0], 0
		sub	cx, 8
;
DoOneBits:	mov	ax, fprod[14]
		mov	bx, fprod[12]
		mov	dx, fprod[10]
		mov	si, fprod[8]
		mov	di, fprod[6]
		jmp	short TestOneBits
;
OneBitLoop:	shl	fprod[0], 1
		rcl	fprod[2], 1
		rcl	fprod[4], 1
		rcl	di, 1
		rcl	si, 1
		rcl	dx, 1
		rcl	bx, 1
		rcl	ax, 1
		dec	cx
TestOneBits:	jcxz	StoreProd
		test	ah, 80h
		jz	OneBitLoop
;
StoreProd:	mov	fpacc.mantissa[6], ax
		mov	fpacc.mantissa[4], bx
		mov	fpacc.mantissa[2], dx
		mov	fpacc.mantissa[0], si
		mov	fpacc.exponent, cx
		or	ax, bx
		or	ax, dx
		or	ax, si
		jnz	FMulDone
;
; If underflow occurs, set the result to zero.
;
		mov	fpacc.exponent, ax
		mov	fpacc.sign, al
;
FMulDone:	pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
sl_fmul		endp
		assume	ds:nothing
;
;
;
;
; Mul64- Multiplies the 8 bytes in fpacc.mant by the 8 bytes in fpop.mant
;	 and leaves the result in fprod.
;
Mul64		proc	near
		assume	ds:StdGrp
		xor	ax, ax
		mov	fprod[0], ax
		mov	fprod[2], ax
		mov	fprod[4], ax
		mov	fprod[6], ax
		mov	fprod[8], ax
		mov	fprod[10], ax
		mov	fprod[12], ax
		mov	fprod[14], ax
;
; Computing the following (each character represents 16-bits):
;
;	A B C D
;    x  E F G H
;    -------
;
; Product is computed by:
;
;	A B C D
;    x  E F G H
;    ----------
;            HD
;	    HC0
;          HB00
;	  HA000
;	    GD0
;          GC00
;         GB000
;        GA0000
;          FD00
;	  FC000
;        FB0000
;       FA00000
;         ED000
;        EC0000
;       EB00000
;    + EA000000
;    ----------
;      xxxxxxxx
;
; In the loop below, si indexes through A, B, C, and D above (or E, F, G,
; and H since multiplication is commutative).
;
		mov	si, ax			;Set Index to zero.
flp1:		mov	ax, fpacc.mantissa[si]	;Multiply A, B, C, or D
		mul	fpop.mantissa[0]	; by H.
		add	fprod [si], ax		;Add it into the partial
		adc	fprod+2 [si], dx	; product computed so far.
		jnc	NoCarry0
		inc	fprod+4 [si]
		jnz	NoCarry0
		inc	fprod+6 [si]
		jnz	NoCarry0
		inc	fprod+8 [si]
		jnz	NoCarry0
		inc	fprod+10 [si]
		jnz	NoCarry0
		inc	fprod+12 [si]
		jnz	NoCarry0
		inc	fprod+14 [si]
;
NoCarry0:
		mov	ax, fpacc.mantissa[si]	;Multiply A, B, C, or D
		mul	fpop.mantissa[2]	; (selected by SI) by G
		add	fprod+2 [si], ax	; and add it into the
		adc	fprod+4 [si], dx	; partial product.
		jnc	NoCarry1
		inc	fprod+6 [si]
		jnz	NoCarry1
		inc	fprod+8 [si]
		jnz	NoCarry1
		inc	fprod+10 [si]
		jnz	NoCarry1
		inc	fprod+12 [si]
		jnz	NoCarry1
		inc	fprod [14]
;
NoCarry1:
		mov	ax, fpacc.mantissa [si]	;Multiply A, B, C, or D
		mul	fpop.mantissa [4]	; (SI selects) by F and add
		add	fprod+4 [si], ax	; it into the partial prod.
		adc	fprod+6 [si], dx
		jnc	NoCarry2
		inc	fprod+8 [si]
		jnz	NoCarry2
		inc	fprod+10 [si]
		jnz	NoCarry2
		inc	fprod+12 [si]
		jnz	NoCarry2
		inc	fprod+14 [si]
;
NoCarry2:
		mov	ax, fpacc.mantissa [si]	;Multiply A/B/C/D (selected
		mul	fpop.mantissa [6]	; by SI) by E and add it
		add	fprod+6 [si], ax	; into the partial product.
		adc	fprod+8 [si], dx
		jnc	NoCarry3
		inc	fprod+10 [si]
		jnz	NoCarry3
		inc	fprod+12 [si]
		jnz	NoCarry3
		inc	fprod+14 [si]
;
NoCarry3:
		inc	si			;Select next multiplier
		inc	si			; (B, C, or D above).
		cmp	si, 8			;Repeat for 64 bit x 64 bit
		jnb	QuitMul64		; multiply.
		jmp	flp1
QuitMul64:	ret
		assume	ds:nothing
Mul64		endp
;
;
;
;
;
;
;
;
;---------------------------------------------------------------------------
;		Floating Point Division
;---------------------------------------------------------------------------
;
;
;
;
; Floating point division: Divides fpacc by fpop.
;
		public	sl_fdiv
sl_fdiv		proc	far
		assume	ds:StdGrp
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
;
		mov	ax, StdGrp
		mov	ds, ax
;
; See if either operand is zero:
;
		mov	ax, fpacc.mantissa[0]	;No need to check exponent!
		or	ax, fpacc.mantissa[2]
		or	ax, fpacc.mantissa[4]
		or	ax, fpacc.mantissa[6]
		jz	QuoIsZero
;
		mov	ax, fpop.mantissa[0]
		or	ax, fpop.mantissa[2]
		or	ax, fpop.mantissa[4]
		or	ax, fpop.mantissa[6]
		jnz	DenomNotZero
;
; Whoops! Division by zero!  Set to largest possible value (+inf) and leave.
;
DivOvfl:	mov	ax, 0ffffh
		mov	fpacc.exponent, ax
		mov	fpacc.mantissa[0], ax
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], ax
		mov	al, fpop.sign
		xor	fpacc.sign, al
;
; Note: we could also do an INT 0 (div by zero) or floating point exception
; here, if necessary.
;
		jmp	FDivDone
;
;
; If the numerator is zero, the quotient is zero.  Handle that here.
;
QuoIsZero:	xor	ax, ax			;Need this!
		mov	fpacc.sign, al
		mov	fpacc.exponent, ax
		mov	fpacc.mantissa[0], ax
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], ax
		jmp	FDivDone
;
;
;
; If both operands are non-zero, compute the quotient down here.
;
DenomNotZero:	mov	al, fpop.sign		;Compute the new sign.
		xor	fpacc.sign, al
;
		mov	ax, fpop.exponent	;Compute new exponent.
		sub	ax, 7fffh		;Subtract BIAS.
		mov	bx, fpacc.exponent
		sub	bx, 7fffh
		sub	bx, ax			;Compute new exponent
		jo	DivOvfl
		add	bx, 7fffh		;Add in BIAS
		mov	fpacc.exponent, bx	;Save as new exponent.
;
; Okay, compute the quotient of the mantissas down here.
;
		call	Div64
;
; Normalize the Quotient.
;
		mov	cx, fpacc.exponent
		jmp	short TestNrmDiv
;
; Normalize by shifting 16 bits at a time here.
;
NrmDiv1:	sub	cx, 16
		mov	ax, fpacc.mantissa[4]
		mov	fpacc.mantissa[6], ax
		mov	ax, fpacc.mantissa[2]
		mov	fpacc.mantissa[4], ax
		mov	ax, fpacc.mantissa[0]
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[0], 0
TestNrmDiv:     cmp	cx, 16
		jb	DoNrmDiv8
		mov  	ax, fpacc.mantissa[6]
		or	ax, ax
		jz	NrmDiv1
;
; Normalize by shifting eight bits at a time here.
;
; See if we can shift the product a whole byte
;
DoNrmDiv8:	cmp	byte ptr fpacc.mantissa[7], 0
		jnz	DoOneBitsDiv
		cmp	cx, 8
		jb	DoOneBitsDiv
		mov	ax, fpacc.mantissa[5]
		mov	fpacc.mantissa[6], ax
		mov	ax, fpacc.mantissa[3]
		mov	fpacc.mantissa[4], ax
		mov	ax, fpacc.mantissa[1]
		mov	fpacc.mantissa[2], ax
		mov	al, byte ptr fpacc.mantissa[0]
		mov	byte ptr fpacc.mantissa[1], al
		mov	byte ptr fpacc.mantissa[0], 0
		sub	cx, 8
;
DoOneBitsDiv:	mov	ax, fpacc.mantissa[6]
		mov	bx, fpacc.mantissa[4]
		mov	dx, fpacc.mantissa[2]
		mov	si, fpacc.mantissa[0]
		jmp	short TestOneBitsDiv
;
; One bit at a time normalization here.
;
OneBitLoopDiv:	shl	si, 1
		rcl	dx, 1
		rcl	bx, 1
		rcl	ax, 1
		dec	cx
TestOneBitsDiv:	jcxz	StoreQuo
		test	ah, 80h
		jz	OneBitLoopDiv
;
StoreQuo:	mov	fpacc.mantissa[6], ax
		mov	fpacc.mantissa[4], bx
		mov	fpacc.mantissa[2], dx
		mov	fpacc.mantissa[0], si
		mov	fpacc.exponent, cx
		or	ax, bx
		or	ax, dx
		or	ax, si
		jnz	FDivDone
;
; If underflow occurs, set the result to zero.
;
		mov	fpacc.exponent, ax
		mov	fpacc.sign, al
;
FDivDone:	pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
sl_fdiv		endp
		assume	ds:nothing
;
;
;
;
; Div64- Divides the 64-bit fpacc.mantissa by the 64-bit fpop.mantissa.
;
div64		proc	near
		assume	ds:StdGrp
;
;
; First, normalize fpop if necessary and possible:
;
		mov	ax, fpop.mantissa[6]
		mov	bx, fpop.mantissa[4]
		mov	cx, fpop.mantissa[2]
		mov	dx, fpop.mantissa[0]
		mov	si, fpacc.exponent
		jmp	short Div16NrmTest
;
; The following loop normalizes fpop 16 bits at a time.
;
Div16NrmLp:	mov	ax, bx
		mov	bx, dx
		mov	cx, dx
		xor	dx, dx
		add	si, 16
Div16NrmTest:	cmp	si, -16
		ja	Div16Nrm8		;Must be unsigned because this
		or	ax, ax			; is bias arithmetic, not
		jz	Div16NrmLp		; two's complement!
;
;
; The following code checks to see if it can normalize by eight bits at
; a time.
;
Div16Nrm8:	cmp	si, -8
		ja	Div1NrmTest		;Must be unsigned!
		cmp	ah, 0
		jnz	Div1NrmTest
		mov	ah, al
		mov	al, bh
		mov	bh, bl
		mov	bl, ch
		mov	ch, cl
		mov	cl, dh
		mov	dh, dl
		mov	dl, 0
		add	si, 8
		jmp	short Div1NrmTest
;
; Down here we're stuck with the slow task of normalizing by a bit
; at a time.
;
Div1NrmLp:	shl	dx, 1
		rcl	cx, 1
		rcl	bx, 1
		rcl	ax, 1
		inc	si
Div1NrmTest:	cmp	si, -1
		je	DivOvfl2		;Can't do it!
		test	ah, 80h
		jz	Div1NrmLp
		jmp	short DoSlowDiv
;
; If overflow occurs, set FPACC to the maximum possible value and quit.
;
DivOvfl2:	mov	ax, 0ffffh
		mov	fpacc.exponent, ax
		mov	fpacc.mantissa[0], ax
		mov	fpacc.mantissa[2], ax
		mov	fpacc.mantissa[4], ax
		mov	fpacc.mantissa[6], ax
		jmp	QuitDiv
;
; Oh No! A GawdAwful bit-by-bit division routine.  Terribly slow!
; Actually, it was sped up a little by checking to see if it could
; shift eight or sixteen bits at a time (because it encounters eight
; or sixteen zeros during the division).
;
; Could possibly speed this up some more by checking for the special
; case of n/16 bits.  Haven't tried this idea out though.
;
DoSlowDiv:	mov	fpacc.exponent, si
		mov	si, ax
		mov	di, bx
		mov	fpop.mantissa[2], cx
		mov	fpop.mantissa[0], dx
		mov	ax, fpacc.mantissa[6]
		mov	bx, fpacc.mantissa[4]
		mov	cx, fpacc.mantissa[2]
		mov	dx, fpacc.mantissa[0]
		mov	bp, 64
DivideLoop:	cmp	bp, 16
		jb      Test8
		or	ax, ax
		jnz	Test8
;
; Do a shift by 16 bits here:
;
		mov	ax, Quotient[4]
		mov	Quotient[6], ax
		mov	ax, Quotient[2]
		mov	Quotient[4], ax
		mov	ax, Quotient[0]
		mov	Quotient[2], ax
		mov	Quotient[0], 0
		mov	ax, bx
		mov	bx, cx
		mov	cx, dx
		xor	dx, dx
		sub	bp, 16
		jz	FinishDivide
		jmp	DivideLoop
;
Test8:		cmp	bp, 8
		jb      Do1
		cmp	ah, 0
		jnz	Do1
;
; Do a shift by 8 bits here:
;
		push	ax
		mov	ax, Quotient[5]
		mov	Quotient[6], ax
		mov	ax, Quotient[3]
		mov	Quotient[4], ax
		mov	ax, Quotient[1]
		mov	Quotient[2], ax
		mov	al, byte ptr Quotient [0]
		mov	byte ptr Quotient [1], al
		mov	byte ptr Quotient[0], 0
		pop	ax
		mov	ah, al
		mov	al, bh
		mov	bh, bl
		mov	bl, ch
		mov	ch, cl
		mov	cl, dh
		mov	dh, dl
		mov	dl, 0
		sub	bp, 8
		jz	FinishDivide
		jmp	DivideLoop
;
Do1:		cmp	ax, si
		jb	shift0
		ja	Shift1
		cmp	bx, di
		jb	shift0
		ja	Shift1
		cmp	cx, fpop.mantissa[2]
		jb	shift0
		ja	shift1
		cmp	dx, fpop.mantissa[0]
		jb	shift0
;
; fpacc.mantiss IS greater than fpop.mantissa, shift a one bit into
; the result here:
;
Shift1:		stc
		rcl	Quotient[0], 1
		rcl	Quotient[2], 1
		rcl	Quotient[4], 1
		rcl	Quotient[6], 1
		sub	dx, fpop.mantissa[0]
		sbb	cx, fpop.mantissa[2]
		sbb	bx, di
		sbb	ax, si
		shl	dx, 1
		rcl	cx, 1
		rcl	bx, 1
		rcl	ax, 1			;Never a carry out.
		dec	bp
		jnz	jDivideLoop
		jmp	FinishDivide
;
; If fpacc.mantissa was less than fpop.mantissa, shift a zero bit into
; the quotient.
;
Shift0:		shl	Quotient[0], 1
		rcl	Quotient[2], 1
		rcl	Quotient[4], 1
		rcl	Quotient[6], 1
		shl	dx, 1
		rcl	cx, 1
		rcl	bx, 1
		rcl	ax, 1
		jc	Greater
		dec	bp
		jnz	jDivideLoop
		jmp	FinishDivide
jDivideLoop:	jmp	DivideLoop
;
; If there was a carry out of the shift, we KNOW that fpacc must be
; greater than fpop.  Handle that case down here.
;
Greater:	dec	bp
		jz	FinishDivide
		stc
		rcl	Quotient[0], 1
		rcl	Quotient[2], 1
		rcl	Quotient[4], 1
		rcl	Quotient[6], 1
		sub	dx, fpop.mantissa[0]
		sbb	cx, fpop.mantissa[2]
		sbb	bx, di
		sbb	ax, si
		shl	dx, 1
		rcl	cx, 1
		rcl	bx, 1
		rcl	ax, 1
		jc	Greater
		dec	bp
		jz	FinishDivide
		jmp	DivideLoop
;
; Okay, clean everything up down here:
;
FinishDivide:	mov	ax, Quotient[0]
		mov	fpacc.mantissa[0], ax
		mov	ax, Quotient[2]
		mov	fpacc.mantissa[2], ax
		mov	ax, Quotient[4]
		mov	fpacc.mantissa[4], ax
		mov	ax, Quotient[6]
		mov	fpacc.mantissa[6], ax
;
QuitDiv:	ret
		assume	ds:nothing
div64		endp
;
;
;
;
;
;---------------------------------------------------------------------------
;		Floating Point => TEXT (Output) conversion routines.
;---------------------------------------------------------------------------
;
;
;
;
; Power of ten tables used by the floating point I/O routines.
;
; Format for each entry (13 bytes):
;
; 1st through
; 11th bytes	Internal FP format for this particular number.
;
; 12th &
; 13th bytes:	Decimal exponent for this value.
;
;
; This first table contains the negative powers of ten as follows:
;
;   for n:= 0 to 12 do
;	entry [12-n] := 10 ** (-2 ** n)
;   entry [13] := 1.0
;
PotTbln         dw	9fdeh, 0d2ceh, 4c8h, 0a6ddh, 4ad8h	; 1e-4096
		db	0					; Sign
		dw	-4096					; Dec Exponent
;
		dw	2de4h, 3436h, 534fh, 0ceaeh, 656bh	; 1e-2048
		db	0
		dw	-2048
;
		dw	0c0beh, 0da57h, 82a5h, 0a2a6h, 72b5h	; 1e-1024
		db	0
		dw	-1024
;
		dw	0d21ch, 0db23h, 0ee32h, 9049h, 795ah	; 1e-512
		db	0
		dw	-512
;
		dw	193ah, 637ah, 4325h, 0c031h, 7cach	; 1e-256
		db	0
		dw	-256
;
		dw	0e4a1h, 64bch, 467ch, 0ddd0h, 7e55h	; 1e-128
		db	0
		dw	-128
;
		dw	0e9a5h, 0a539h, 0ea27h, 0a87fh, 7f2ah	; 1e-64
		db	0
		dw	-64
;
		dw	94bah, 4539h, 1eadh, 0cfb1h, 7f94h	; 1e-32
		db	0
		dw	-32
;
		dw	0e15bh, 0c44dh, 94beh, 0e695h, 7fc9h	; 1e-16
		db	0
		dw	-16
;
		dw	0cefdh, 8461h, 7711h, 0abcch, 7fe4h	; 1e-8
		db	0
		dw	-8
;
		dw	652ch, 0e219h, 1758h, 0d1b7h, 7ff1h	; 1e-4
		db	0
		dw	-4
;
		dw	0d70ah, 70a3h, 0a3dh, 0a3d7h, 7ff8h	; 1e-2
		db	0
		dw	-2
;
Div10Value	dw	0cccdh, 0cccch, 0cccch, 0cccch, 7ffbh	; 1e-1
		db	0
		dw	-1
;
		dw	0, 0, 0, 8000h, 7fffh			; 1e0
		db	0
		dw	0
;
;
; PotTblP- Power of ten table.  Holds powers of ten raised to positive
;	   powers of two;
;
;		i.e., x(12-n) = 10 ** (2 ** n) for 0 <= n <= 12.
;		      x(13) = 1.0
;		      x(-1) = 10 ** (2 ** -4096)
;
; There is a -1 entry since it is possible for the algorithm to back up
; before the table.
;
		dw	979bh, 8a20h, 5202h, 0c460h, 0b525h	; 1e+4096
		db	0
		dw	4096
;
PotTblP		dw	979bh, 8a20h, 5202h, 0c460h, 0b525h	; 1e+4096
		db	0
		dw	4096
;
		dw	5de5h, 0c53dh, 3b5dh, 9e8bh, 09a92h	; 1e+2048
		db	0
		dw	2048
;
		dw	0c17h, 8175h, 7586h, 0c976h, 08d48h	; 1e+1024
		db	0
		dw	1024
;
		dw	91c7h, 0a60eh, 0a0aeh, 0e319h, 086a3h	; 1e+512
		db	0
		dw	512
;
		dw	0de8eh, 9df9h, 0ebfbh, 0aa7eh, 08351h	; 1e+256
		db	0
		dw	256
;
		dw	8ce0h, 80e9h, 47c9h, 93bah, 081a8h	; 1e+128
		db	0
		dw	128
;
		dw	0a6d5h, 0ffcfh, 1f49h, 0c278h, 080d3h	; 1e+64
		db	0
		dw	64
;
		dw	0b59eh, 2b70h, 0ada8h, 9dc5h, 08069h	; 1e+32
		db	0
		dw	32
;
		dw	0, 400h, 0c9bfh, 8e1bh, 08034h		; 1e+16
		db	0
		dw	16
;
		dw	0, 0, 2000h, 0bebch, 08019h		; 1e+8
		db	0
		dw	8
;
		dw	0, 0, 0, 9c40h, 0800ch			; 1e+4
		db	0
		dw	4
;
		dw	0, 0, 0, 0c800h, 08005h			; 1e+2
		db	0
		dw	2
;
		dw	0, 0, 0, 0a000h, 08002h			; 1e+1
		db	0
		dw	1
;
		dw	0, 0, 0, 8000h, 7fffh			; 1e0
		db	0
		dw	0
;
;
;
;
;
;
;
; SL_FTOA-	Converts extended precision value in FPACC to a decimal
;		string.  AL contains the field width, AH contains the
;		number of positions after the decimal point.  The format
;		of the converted string is:
;
;			sd.e
;
;		where "s" is a single character which is either a space
;		or "=", "e" is some number of digits which is equal to
;		the value passed in AL, and "d" is the number of digits
;		given by  (AL-AH-2).  If the field width is too small,
;		this routine creates a string of "#" characters AH long.
;
;		ES:DI contains the address where we're supposed to put
;		the resulting string.  This code assumes that there is
;		sufficient memory to hold (AL+1) characters at this address.
;
;
;
		public	sl_ftoa
sl_ftoa		proc	far
		push	di
		call	far ptr sl_ftoa2
		pop	di
		ret
sl_ftoa		endp
;
		public	sl_ftoa2
sl_ftoa2	proc	far
		assume	ds:StdGrp
;
		pushf
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
;
		cld
		mov	bx, StdGrp
		mov	ds, bx
;
; Save fpacc 'cause it gets munged.
;
		push	fpacc.Mantissa [0]
		push	fpacc.Mantissa [2]
		push	fpacc.Mantissa [4]
		push	fpacc.Mantissa [6]
		push	fpacc.Exponent
		push	word ptr fpacc.Sign
;
		mov	cx, ax		;Save field width/dec pts here.
;
		call	fpdigits	;Convert fpacc to digit string.
;
; Round the string of digits to the number of significant digits we want to
; display for this number:
;
		mov	bx, DecExponent
		cmp	bx, 18
		jb	PosRS
		xor	bx, bx		;Force to zero if negative or too big.
;
PosRS:		add	bl, ch	       	;Compute position where we should start
		adc	bh, 0		; the rounding.
		inc	bx		;Tweak next digit.
		cmp	bx, 18		;Don't bother rounding if we have
		jae	RoundDone	; more than 18 digits here.
;
; Add 5 to the digit after the last digit we want to print.  Then propogate
; any overflow through the remaining digits.
;
		mov	al, DecDigits [bx]
		add	al, 5
		mov	DecDigits [bx], al
		cmp	al, "9"
		jbe     RoundDone
		sub	DecDigits [bx], 10
RoundLoop:	dec	bx
		js	FirstDigit
		inc	DecDigits[bx]
		cmp	DecDigits[bx], "9"
		jbe	RoundDone
		sub	DecDigits[bx], 10
		jmp	RoundLoop
;
; If we hit the first digit in the string, we've got to shift all the
; characters down one position and put a "1" in the first character
; position.
;
FirstDigit:     mov	bx, DecExponent
		cmp	bx, 18
		jb	FDOkay
		xor	bx, bx
;
FDOkay:		mov	bl, ch
		mov	bh, 0
		inc	bx
FDLp:		mov	al, byte ptr DecDigits[bx-1]
		mov	DecDigits [bx], al
		dec	bx
		jnz	FDLp
		mov	DecDigits, "1"
		inc	DecExponent	;Cause we just added a digit.
;
RoundDone:
;
; See if we're dealing with values greater than one (abs) or between 0 & 1.
;
		cmp	DecExponent, 0	;Handle positive/negative exponents
		jge	PositiveExp	; separately.
;
; Handle values between 0 & 1 here (negative powers of ten).
;
		mov	dl, ch		;Compute #'s width = DecPlaces+3
		add   	dl, 3		;Make room for "-0."
		jc	BadFieldWidth
		cmp	dl, 4
		jae	LengthOk
		mov	dl, 4		;Minimum string is "-0.0"
LengthOK:	mov	al, ' '
PutSpcs2:       cmp	dl, cl
		jae	PS2Done
		stosb
		inc	dl
		jmp	PutSpcs2
;
PS2Done:       	mov	al, DecSign
		stosb
		mov	al, "0"		;Output "0." before the number.
		stosb
		mov	al, "."
		stosb
		mov	ah, 0		;Used to count output digits
		lea	bx, stdGrp:DecDigits ;Pointer to number string.
PutDigits2:	inc	DecExponent
		jns	PutTheDigit
;
; If the exponent value is still negative, output zeros because we've yet
; to reach the beginning of the number.
;
PutZero2:	mov	al, '0'
		stosb
		jmp	TestDone2
;
PutTheDigit:	cmp	ah, 18		;If more than 18 digits so far, just
		jae	PutZero2	; output zeros.
;
		mov	al, [bx]
		inc	bx
		stosb
;
TestDone2:	inc	ah
		dec	ch
		jnz     PutDigits2
		mov	byte ptr es:[di], 0
		jmp	ftoaDone
;
;
; Okay, we've got a positive exponent here.  First, let's adjust the field
; width value (in CH) so that it includes the sign and possible decimal point.
;
PositiveExp:	mov	dx, DecExponent	;Get actual # of digits to left of "."
		inc	dx		;Allow for sign and the fact that there
		inc	dx		; is always one digit to left of ".".
		cmp	ch, 0		;# of chars after "." = 0?
		je	NoDecPt
		add	dl, ch		;Add in number of chars after "."
		adc	dh, 0
		inc	dx		;Make room for "."
NoDecPt:
;
;
; Make sure the field width is bigger than the number of decimal places to
; print.
;
		cmp	cl, ch
		jb	BadFieldWidth
;
;
; Okay, now see if the user is trying to print a value which is too large
; to fit in the given field width:
;
		cmp	dh, 0
		jne	BadFieldWidth	;Sorry, no output >= 256 chars.
		cmp	dl, cl		;Need field width > specified FW?
		jbe	GoodFieldWidth
;
; If we get down here, then we've got a number which will not fit in the
; specified field width.  Fill the string with #'s (sorta like FORTRAN).
;
BadFieldWidth:	mov	ch, 0		;Set CX=field width.
		mov	al, "#"
	rep	stosb
		mov	byte ptr es:[di], 0
		jmp	ftoaDone
;
;
; Print any necessary spaces in front of the number.
;
GoodFieldWidth:	call	PutSpaces
;
; Output the sign character (" " or "-"):
;
		mov	al, DecSign
		stosb
;
; Okay, output the digits for this number here.
;
		mov	ah, 0		;Counts off output characters.
		lea	bx, stdgrp:DecDigits ;Pointer to digit string.
		mov	cl, ch		;CX := # of chars after "."
		mov	ch, 0	       	; plus number of characters before
		add	cx, DecExponent	; the ".".
		inc	cx		;Always at least one digit before "."
OutputLp:	cmp	ah, 18		;Exceeded 18 digits?
		jae	PutZeros
		mov	al, [bx]
		inc	bx
		jmp	PutChar
;
PutZeros:	mov	al, '0'
PutChar:	stosb
		cmp	DecExponent, 0
		jne	DontPutPoint
		mov	al, '.'
		stosb
;
DontPutPoint:	dec	DecExponent
		inc	ah
		loop	OutputLp
		mov	byte ptr es:[di], 0 	;Output the zero byte.
;
ftoaDone:	pop	word ptr fpacc.Sign
		pop	fpacc.Exponent
		pop	fpacc.Mantissa [6]
		pop	fpacc.Mantissa [4]
		pop	fpacc.Mantissa [2]
		pop	fpacc.Mantissa [0]
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		popf
		ret
sl_ftoa2	endp
;
;
;
;
; Okay, now we need to insert any necessary leading spaces.  We need to
; put (FieldWidth - ActualWidth) spaces before the string of digits.
;
PutSpaces	proc	near
		cmp	dl, cl		;See if print width >= field width
		jae	NoSpaces
		mov	ah, cl
		sub	ah, dl		;Compute # of spaces to print.
		mov	al, ' '
PSLp:		stosb
		dec	ah
		jnz	PSLp
NoSpaces:	ret
PutSpaces	endp
;
;
;
;
;
;
;
;
;
;
;
;
;
;
; SL_ETOA-	Converts value in FPACC to exponential form.  AL contains
;		the number of print positions.  ES:DI points to the array
;		which will hold this string (it must be at least AL+1 chars
;		long).
;
;		The output string takes the format:
;
;		{" "|-} [0-9] "." [0-9]* "E" [+|-] [0-9]{2,4}
;
;		(The term "[0-9]{2,4}" means either two or four digits)
;
;		AL must be at least eight or this code outputs #s.
;
		public	sl_etoa
sl_etoa		proc	far
		push	di
		call	far ptr sl_etoa2
		pop	di
		ret
sl_etoa		endp
;
;
		public	sl_etoa2
sl_etoa2	proc	far
		assume	ds:StdGrp
;
		pushf
		push	ds
		push	ax
		push	bx
		push	cx
		push	si
;
		cld
		mov	bx, StdGrp
		mov	ds, bx
;
		push	fpacc.Mantissa [0]
		push	fpacc.Mantissa [2]
		push	fpacc.Mantissa [4]
		push	fpacc.Mantissa [6]
		push	fpacc.Exponent
		push	word ptr fpacc.Sign
;
		call	fpdigits
;
; See if we have sufficient room for the number-
;
		mov	ah, 0
		mov	cx, ax
;
; Okay, take out spots for sign, ".", "E", sign, and at least four exponent
; digits and the exponent's sign:
;
Subtract2:	sub	ax, 8
		jc	BadEWidth
		jnz	DoTheRound	;Make sure at least 1 digit left!
;
BadEWidth:	mov	ch, 0
		mov	al, "#"
	rep	stosb
		mov	al, 0
		stosb
		jmp	etoaDone
;
; Round the number to the specified number of places.
;
DoTheRound:	mov	ch, al		;# of decimal places is # of posns.
		mov	bl, ch	       	;Compute position where we should start
		mov	bh, 0		; the rounding.
		cmp	bx, 18		;Don't bother rounding if we have
		jae	eRoundDone	; more than 18 digits here.
;
; Add 5 to the digit after the last digit we want to print.  Then propogate
; any overflow through the remaining digits.
;
		mov	al, DecDigits [bx]
		add	al, 5
		mov	DecDigits [bx], al
		cmp	al, "9"
		jbe     eRoundDone
		sub	DecDigits [bx], 10
eRoundLoop:	dec	bx
		js	eFirstDigit
		inc	DecDigits[bx]
		cmp	DecDigits[bx], "9"
		jbe	eRoundDone
		sub	DecDigits[bx], 10
		jmp	eRoundLoop
;
; If we hit the first digit in the string, we've got to shift all the
; characters down one position and put a "1" in the first character
; position.
;
eFirstDigit:    mov	bl, ch
		mov	bh, 0
		inc	bx
eFDLp:		mov	al, byte ptr DecDigits[bx-1]
		mov	DecDigits [bx], al
		dec	bx
		jnz	eFDLp
		mov	DecDigits, "1"
		inc	DecExponent	;Cause we just added a digit.
;
eRoundDone:
;
; Okay, output the value here.
;
		mov	cl, ch		;Set CX=Number of output chars
		mov	ch, 0
		mov	al, DecSign
		stosb
		lea	si, stdgrp:DecDigits
		movsb			;Output first char.
		dec	cx		;See if we're done!
		jz	PutExponent
;
; Output the fractional part here
;
		mov	al, "."
		stosb
		mov	ah, 17		;Max # of chars to output.
PutFractional:	cmp	ah, 0
		jz	NoMoreDigs
		movsb
		dec	ah
		jmp	NextFraction
;
; If we've output more than 18 digits, just output zeros.
;
NoMoreDigs:	mov	al, "0"
		stosb
;
NextFraction:	loop	PutFractional
PutExponent:	mov	al, "E"
		stosb
		mov	al, "+"
		cmp	DecExponent, 0
		jge	NoNegExp
		mov	al, "-"
		neg	DecExponent
;
NoNegExp:	stosb
		mov	ax, DecExponent
		cwd			;Sets DX := 0.
		mov	cx, 1000
		div	cx
		or	al, "0"
		stosb			;Output 1000's digit
		xchg	ax, dx
		cwd
		mov	cx, 100
		div	cx
		or	al, "0"		;Output 100's digit
		stosb
		xchg	ax, dx
		cwd
		mov	cx, 10
		div	cx
		or	al, "0"		;Output 10's digit
		stosb
		xchg	ax, dx
		or	al, "0"		;Output 1's digit
		stosb
		mov	byte ptr es:[di], 0	;Output zero byte.
;
etoaDone:	pop	word ptr fpacc.Sign
		pop	fpacc.Exponent
		pop	fpacc.Mantissa [6]
		pop	fpacc.Mantissa [4]
		pop	fpacc.Mantissa [2]
		pop	fpacc.Mantissa [0]
		pop	si
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		popf
		ret
sl_etoa2	endp
;
;
;
;
;
; FPDigits- Converts the floating point number in FPACC to a string of
;	    digits (in DecDigits), an integer exponent value (DecExp),
;	    and a sign character (DecSign).  The decimal point is assumed
;	    to be between the first and second characters in the string.
;
FPDigits	proc	near
		assume	ds:StdGrp
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	si
;
		mov	ax, seg StdGrp
		mov	ds, ax
;
; First things first, see if this value is zero:
;
		mov	ax, fpacc.exponent
		or	ax, fpacc.Mantissa [0]
		or	ax, fpacc.Mantissa [2]
		or	ax, fpacc.Mantissa [4]
		or	ax, fpacc.Mantissa [6]
		jnz	fpdNotZero
;
; Well, it's zero.  Handle this as a special case:
;
		mov	ax, 3030h		;"00"
		mov	word ptr DecDigits[0], ax
		mov	word ptr DecDigits[2], ax
		mov	word ptr DecDigits[4], ax
		mov	word ptr DecDigits[6], ax
		mov	word ptr DecDigits[8], ax
		mov	word ptr DecDigits[10], ax
		mov	word ptr DecDigits[12], ax
		mov	word ptr DecDigits[14], ax
		mov	word ptr DecDigits[16], ax
		mov	word ptr DecDigits[18], ax
		mov	word ptr DecDigits[20], ax
		mov	word ptr DecDigits[22], ax
		mov	DecExponent, 0
		mov	DecSign, ' '
		jmp	fpdDone
;
; If the number is not zero, first fix up the sign:
;
fpdNotZero:	mov	DecSign, ' '		;Assume it's postive
		cmp	fpacc.Sign, 0
		jns	WasPositive
		mov	DecSign, '-'
		mov	fpacc.Sign, 0		;Take ABS(fpacc).
;
; This conversion routine is fairly standard.  See Neil Graham's
; "Microprocessor Programming for Computer Hobbyists" for the gruesome
; details.  Basically, it first gets the number between 1 & 10 by successively
; multiplying (or dividing) by ten.  For each multiply by 10 this code
; decrements DecExponent by one.  For each division by ten this code
; increments DecExponent by one.  Upon getting the value between 1 & 10
; DecExponent contains the integer equivalent of the exponent.  The
; following code does this.
;
; Note: if the value falls between 1 & 10, then the exponent portion of
;	fpacc will lie between 7fffh and 8002h.
;
WasPositive:	mov	DecExponent, 0		;Initialize exponent.
;
; Quick test to see if we're already less than 10.
;
WhlBgrThan10:	cmp	fpacc.Exponent, 8002h	;See if fpacc > 10
		jb	WhlLessThan1
		ja	IsGtrThan10
;
; If the exponent is equal to 8002h, then we could have a number in the
; range 8 <= n < 16.  Let's ignore values less than 10.
;
		cmp	byte ptr fpacc.Mantissa [7], 0a0h
		jb	WhlLessThan1
;
; If it's bigger than ten we could perform successive divisions by ten.
; This, however, would be slow, inaccurate, and disgusting.  The following
; loop skips through the positive powers of ten (PotTblP) until it finds
; someone with an exponent *less* than fpacc.  Upon finding such a value,
; this code divides fpacc by the corresponding entry in PotTblN.  This is
; equivalent to *dividing* by the entry in PotTblP.  Note: this code only
; compares exponents.  Therefore, it is quite possible that we will divide
; by a number slightly larger than fpacc (since the mantissa of the table
; entry could be larger than the mantissa of fpacc while their exponents
; are equal).  This will produce a result slightly less than one.  This is
; okay in this case because the code which handles values between 0 & 1
; follows and will correct this oversight.
;
IsGtrThan10:	mov	bx, -13			;Index into PotTblP
		mov	ax, fpacc.Exponent
WhlBgrLp1:	add	bx, 13
		cmp	ax, PotTblP [bx] + 8	;Compare exponent values.
		jb	WhlBgrLp1		;Go to next entry if less.
;
; Okay, we found the first table entry whose exponent is less than or
; equal to the fpacc exponent.  Multiply by the corresonding PotTblN
; value here (which simulates a divide).
;
		call	nTbl2FPOP
		mov	ax, PotTblP [bx] + 11	;Adjust DecExponent
		add	DecExponent, ax
		call	sl_fMUL			;Divide by appropriate power.
		mov	ax, fpacc.Exponent
		cmp	ax, 8002h		;See if fpacc > 10
		jae	WhlBgrLp1
;
;
; Once we get the number below 10 (or if it was below 10 to begin with,
; drop down here and boost it up to the point where it is >= 1.
;
; This code is similar to the above-  It successively multiplies by 10
; (actually, powers of ten) until the number is in the range 1..10.
; This code is not as sloppy as the code above because we don't have any
; code below this to clean up the sloppiness.  Indeed, this code has to
; be careful because it is cleaning up the sloppiness of the code above.
;
;
WhlLessThan1:	cmp	fpacc.Exponent, 7fffh	;See if fpacc < 1
		jae	NotLessThan1
;
		mov	bx, -13			;Index into PotTblN
WhlLessLp2:	mov	ax, fpacc.Exponent
WhlLessLp1:	add	bx, 13
		cmp	ax, PotTblN [bx] + 8	;Compare exponent values.
		ja	WhlLessLp1		;Go to next entry if less.
;
; Okay, we found the first table entry whose exponent is greater than or
; equal to the fpacc exponent.  Unlike the code above, we cannot simply
; multiply by the corresponding entry in PotTblP at this point.  If the
; exponents were equal, we need to compare the mantissas and make sure we're
; not multiplying by a table entry which is too large.
;
		jne	OkayToMultiply
;
; If the exponents are the same, we need to compare the mantissas.  The
; table entry cannot be larger than fpacc;  if it is, we'll wind up with
; an endless loop oscillating between a couple of values.
;
		mov	ax, fpacc.Mantissa [6]
		cmp	ax, PotTblN [bx] + 6
		ja      WhlLessLp2
		jb	OkayToMultiply
		mov	ax, fpacc.Mantissa [4]
		cmp	ax, PotTblN [bx] + 4
		ja	WhlLessLp2
		jb	OkayToMultiply
		mov	ax, fpacc.Mantissa [2]
		cmp	ax, PotTblN [bx] + 2
		ja	WhlLessLp2
		jb	OkayToMultiply
		mov	ax, fpacc.Mantissa [0]
		cmp	ax, PotTblN [bx]
		ja	WhlLessLp2
;
;
OkayToMultiply:	call	pTbl2FPOP
		mov	ax, PotTblN [bx] + 11	;Adjust DecExponent
		add	DecExponent, ax
		call	sl_fMUL			;Multiply by appropriate power.
		jmp	WhlLessThan1		;Repeat till in range 1..10.
;
;
; The above code tries to get fpacc in the range 1 <= n < 10.
; However, it doesn't quite accomplish this.  In fact, it gets the value
; into the range 1 <= n < 16.  This next section checks to see if the value
; is greater than ten.  If it is, it does one more division by ten.
;
NotLessThan1:	cmp	fpacc.Exponent, 8002h	;10..15 only if exp = 8002h.
		jb	Not10_15
;
; For fpacc to be in the range 10..15 the mantissa must be greater than or
; equal to 0A000 0000 0000 0000.
;
		cmp	byte ptr fpacc.Mantissa [7], 0a0h
		jb	Not10_15
;
; Okay, the mantissa is greater than or equal to ten.  Divide by ten once
; more to fix this up.
;
		lea	bx, stdgrp:Div10Value
		sub	bx, offset stdgrp:PotTblN
		call	pTbl2FPOP
		call	sl_fMUL			;Multiply by appropriate power.
		inc	DecExponent
;
; Well, we've managed to compute the decimal exponent value and normalize
; the number to the range 1 <= n < 10.
;
; Make sure the upper four bits contain a BCD value.  This may entail
; shifting data to the right.
;
Not10_15:	mov	si, fpacc.Mantissa [0]	;We'll use these a lot, so
		mov	di, fpacc.Mantissa [2]	; put them into registers.
		mov	cx, fpacc.Mantissa [4]
		mov	dx, fpacc.Mantissa [6]
SHRLp:		cmp	fpacc.Exponent, 8002h
		jae	PossiblyRound
		shr	dx, 1
		rcr	cx, 1
		rcr	di, 1
		rcr	si, 1
		inc	fpacc.Exponent
		jmp     SHRLp
;
; May have to round the number if we wound up with a value between 10..15.
;
; Note: 0.5 e -18 is 7fc5 b8xxxxxxxx...   If we adjust this value so that
;	the exponent is 7fffh, we keep only the top five bits (10111).  The
;	following code adds this value (17h) to the mantiss to round as
;	appropriate.
;
PossiblyRound:	add	si, 2h
		jnc	ChkTooBig
		inc	di
		jnz	ChkTooBig
		inc	cx
		jnz	ChkTooBig
		inc	dx
;
; If we fall through to this point, it's quite possible that we will produce
; a value greater than or equal to ten.  Handle that possibility here.
;
ChkTooBig:	cmp	dh, 0a0h
		jb	NoOvrflw
;
; Well, overflow occurred, clean it up.
;
		xor	ax, ax
		mov	si, ax
		mov	di, ax
		mov	cx, ax
		mov	dx, 1000h
		inc	DecExponent
;
; Finally!  We're at the point where we can start stripping off the
; digits from the number
;
NoOvrflw:	lea	bx, stdgrp:DecDigits
		xor	ax, ax
;
StripDigits:	mov	al, dh
		shr	ax, 1
		shr	ax, 1
		shr     ax, 1
		shr	ax, 1
		or	al, '0'
		mov	[bx], al
		inc	bx
		cmp	bx, offset stdgrp:DecDigits+18
		jae	fpdDone
;
; Remove the digit we just stripped:
;
		and	dh, 0fh
;
; Multiply the mantissa by ten (using shifts and adds):
;
		shl	si, 1
		rcl	di, 1
		rcl	cx, 1
		rcl	dx, 1
		mov	fpacc.Mantissa [0], si	;Save *2
		mov	fpacc.Mantissa [2], di
		mov	fpacc.Mantissa [4], cx
		mov	fpacc.Mantissa [6], dx
;
		shl	si, 1			;*4
		rcl	di, 1
		rcl	cx, 1
		rcl	dx, 1
;
		shl	si, 1			;*8
		rcl	di, 1
		rcl	cx, 1
		rcl	dx, 1
;
		add	si, fpacc.Mantissa [0]	;*10
		adc	di, fpacc.Mantissa [2]
		adc	cx, fpacc.Mantissa [4]
		adc	dx, fpacc.Mantissa [6]
		jmp     StripDigits
;
fpdDone:        pop	si
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
FPDigits	endp
;
;
;
; nTbl2FPOP- BX is an index into PotTbln.  This routine fetches the entry
;	     at that index and copies it into FPOP.
;
nTbl2FPOP	proc	near
		mov	ax, PotTbln [bx] + 8
		mov	fpop.Exponent, ax
		mov	ax, PotTbln [bx]
		mov	fpop.Mantissa [0], ax
		mov	ax, PotTbln [bx] + 2
		mov	fpop.Mantissa [2], ax
		mov	ax, PotTbln [bx] + 4
		mov	fpop.Mantissa [4], ax
		mov	ax, PotTbln [bx] + 6
		mov	fpop.Mantissa [6], ax
		mov	fpop.Sign, 0		;All entries are positive.
		ret
nTbl2FPOP	endp
;
; pTbl2FPOP- Same as above except the data comes from PotTblP.
;
pTbl2FPOP	proc	near
		mov	ax, PotTblp [bx] + 8
		cmp	ax, 7fffh
		jne	DoPTFPOP
		sub	bx, 13			;Special case if we hit 1.0
		mov	ax, PotTblp [bx] + 8
;
DoPTFPOP:	mov	fpop.Exponent, ax
		mov	ax, PotTblp [bx]
		mov	fpop.Mantissa [0], ax
		mov	ax, PotTblp [bx] + 2
		mov	fpop.Mantissa [2], ax
		mov	ax, PotTblp [bx] + 4
		mov	fpop.Mantissa [4], ax
		mov	ax, PotTblp [bx] + 6
		mov	fpop.Mantissa [6], ax
		mov	fpop.Sign, 0		;All entries are positive.
		ret
pTbl2FPOP	endp
;
;
;
;
;
;----------------------------------------------------------------------------
;	       Text => Floating Point (Input) Conversion Routines
;----------------------------------------------------------------------------
;
;
; ATOF-		ES:DI points at a string containing (hopefully) a numeric
;		value in floating point format.  This routine converts that
;		value to a number and puts the result in fpacc.  Allowable
;		strings are described by the following regular expression:
;
;		{" "}* {+ | -} ( ([0-9]+ {"." [0-9]*}) | ("." [0-9]+)}
;				{(e | E) {+ | -} [0-9] {[0-9]*}}
;
; "{}" denote optional items.
; "|"  denotes OR.
; "()" groups items together.
;
;
shl64		macro
		shl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
		rcl	si, 1
		endm
;
		public	sl_ATOF
sl_ATOF		proc	far
		assume	ds:StdGrp, es:nothing
;
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
;
		mov	ax, StdGrp
		mov	ds, ax
;
;
; First, skip any leading spaces:
;
		mov	ah, " "
SkipBlanks:	mov	al, es:[di]
		inc	di
		cmp	al, ah
		je	SkipBlanks
;
; Check for + or -.
;
		cmp	al, "-"
		jne	TryPlusSign
		mov	fpacc.Sign, 80h
		jmp	EatSignChar
;
TryPlusSign:	mov	fpacc.Sign, 0		;If not "-", then positive.
		cmp	al, "+"
		jne	NotASign
EatSignChar:	mov	al, es:[di]		;Get char beyond sign
		inc	di
;
; Init some important local vars:
; Note: BP contains the number of significant digits processed thus far.
;
NotASign:	mov	DecExponent, 0
		xor	bx, bx			;Init 64 bit result.
		mov	cx, bx
		mov	dx, bx
		mov	si, bx
		mov	bp, bx
		mov	ah, bh
;
; First, eliminate any leading zeros (which do not count as significant
; digits):
;
Eliminate0s:	cmp	al, "0"
		jne	EndOfZeros
		mov	al, es:[di]
		inc	di
		jmp	Eliminate0s
;
; When we reach the end of the leading zeros, first check for a decimal
; point.  If the number is of the form "0---0.0000" we need to get rid
; of the zeros after the decimal point and not count them as significant
; digits.
;
EndOfZeros:	cmp	al, "."
		jne	WhileDigits
;
; Okay, the number is of the form ".xxxxx".  Strip all zeros immediately
; after the decimal point.
;
Right0s:	mov	al, es:[di]
		inc	di
		cmp	al, "0"
		jne	FractionPart
		dec	DecExponent		;Not significant digit, but
		jmp	Right0s			; affects exponent.
;
;
; If the number is of the form "yyy.xxxx" (where y <> 0) then process it
; down here.
;
WhileDigits:	sub	al, "0"
		cmp	al, 10
		jae	NotADigit
;
; See if we've processed more than 19 sigificant digits:
;
		cmp	bp, 19			;Too many significant digits?
		jae	DontMergeDig
;
; Multiply value in (si, dx, cx, bx) by ten:
;
		shl64
		mov	fpacc.Mantissa [0], bx
		mov	fpacc.Mantissa [2], cx
		mov	fpacc.Mantissa [4], dx
		mov	fpacc.Mantissa [6], si
		shl64
		shl64
		add	bx, fpacc.Mantissa [0]
		adc	cx, fpacc.Mantissa [2]
		adc	dx, fpacc.Mantissa [4]
		adc	si, fpacc.Mantissa [6]
;
; Add in current digit:
;
		add	bx, ax
		jnc     GetNextDig
		inc	cx
		jne	GetNextDig
		inc	dx
		jne	GetNextDig
		inc	si
		jmp	GetNextDig
;
DontMergeDig:	inc	DecExponent
GetNextDig:	inc	bp			;Yet another significant dig.
		mov	al, es:[di]
		inc	di
		jmp	WhileDigits
;
;
; Check to see if there is a decimal point here:
;
NotADigit:	cmp	al, "."-"0"
		jne	NotADecPt
		mov	al, es:[di]
		inc	di
;
; Okay, process the digits to the right of the decimal point here.
;
FractionPart:	sub	al, "0"
		cmp	al, 10
		jae	NotADecPt
;
; See if we've processed more than 19 sigificant digits:
;
		cmp	bp, 19			;Too many significant digits?
		jae	DontMergeDig2
;
; Multiply value in (si, dx, cx, bx) by ten:
;
		dec	DecExponent		;Raise by a power of ten.
		shl64
		mov	fpacc.Mantissa [0], bx
		mov	fpacc.Mantissa [2], cx
		mov	fpacc.Mantissa [4], dx
		mov	fpacc.Mantissa [6], si
		shl64
		shl64
		add	bx, fpacc.Mantissa [0]
		adc	cx, fpacc.Mantissa [2]
		adc	dx, fpacc.Mantissa [4]
		adc	si, fpacc.Mantissa [6]
;
; Add in current digit:
;
		add	bx, ax
		jnc     DontMergeDig2
		inc	cx
		jne	DontMergeDig2
		inc	dx
		jne	DontMergeDig2
		inc	si
;
DontMergeDig2:	inc	bp			;Yet another significant dig.
		mov	al, es:[di]
		inc	di
		jmp	FractionPart
;
; Process the exponent down here
;
NotADecPt:	cmp	al, "e"-"0"
		je	IsExponent
		cmp	al, "E"-"0"
		jne	NormalizeInput
;
; Okay, we just saw the "E" character, now read in the exponent value
; and add it into DecExponent.
;
IsExponent:	mov	ExpSign, 0		;Assume positive exponent.
		mov	al, es:[di]
		inc	di
		cmp	al, "+"
		je	EatExpSign
		cmp	al, "-"
		jne	ExpNotNeg
		mov	ExpSign, 1		;Exponent is negative.
EatExpSign:	mov	al, es:[di]
		inc	di
ExpNotNeg:	xor	bp, bp
ExpDigits:      sub	al, '0'
		cmp	al, 10
		jae	EndOfExponent
		shl	bp, 1
		mov	TempExp, bp
		shl	bp, 1
		shl	bp, 1
		add	bp, TempExp
		add	bp, ax
		mov	al, es:[di]
		inc	di
		jmp	ExpDigits
;
EndOfExponent:	cmp	ExpSign, 0
		je	PosExp
		neg	bp
PosExp:		add	DecExponent, bp
;
; Normalize the number here:
;
NormalizeInput:	mov	ax, si			;See if they entered zero.
		or	ax, bx
		or	ax, cx
		or	ax, dx
		jnz	ItsNotZero
		jmp	ItsZero
;
ItsNotZero:	mov	ax, si
		mov	si, 7fffh+63		;Exponent if already nrm'd.
NrmInp16:	or	ax, ax			;See if we can shift 16 bits.
		jnz	NrmInp8
		mov	ax, dx
		mov	dx, cx
		mov	cx, bx
		xor	bx, bx
		sub	si, 16
		jmp	NrmInp16
;
NrmInp8:	cmp	ah, 0
		jne	NrmInp1
		mov	ah, al
		mov	al, dh
		mov	dh, dl
		mov	dl, ch
		mov	ch, cl
		mov	cl, bh
		mov	bh, bl
		mov	bl, 0
		sub	si, 8
;
NrmInp1:	cmp	ah, 80h
		jae	NrmDone
		shl	bx, 1
		rcl	cx, 1
		rcl	dx, 1
		rcl	ax, 1
		dec	si
		jmp	NrmInp1
;
; Okay, the number is normalized.  Now multiply by 10 the number of times
; specified in DecExponent.  Obviously, this uses the power of ten tables
; to speed up this operation (and make it more accurate).
;
NrmDone:	mov	fpacc.Exponent, si	;Save away the value so far.
		mov	fpacc.Mantissa [0], bx
		mov	fpacc.Mantissa [2], cx
		mov	fpacc.Mantissa [4], dx
		mov	fpacc.Mantissa [6], ax
;
		mov	bx, -13			;Index into POT table.
		mov	si, DecExponent
		or	si, si			;See if negative
		js	NegExpLp
;
; Okay, the exponent is positive, handle that down here.
;
PosExpLp:	add	bx, 13			;Find the 1st power of ten
		cmp	si, PotTblP [bx] + 11	; in the table which is
		jb	PosExpLp		; just less than this guy.
		cmp	PotTblP [bx] + 8, 7fffh	;Hit 1.0 yet?
		je	MulExpDone
;
		sub	si, PotTblP [bx] + 11	;Fix for the next time through.
		call	PTbl2FPOP		;Load up current power of ten.
		call	sl_FMUL			;Multiply by this guy.
		jmp	PosExpLp
;
;
; Okay, the exponent is negative, handle that down here.
;
NegExpLp:	add	bx, 13			;Find the 1st power of ten
		cmp	si, PotTblN [bx] + 11	; in the table which is
		jg	NegExpLp		; just less than this guy.
		cmp	PotTblN [bx] + 8, 7fffh	;Hit 1.0 yet?
		je	MulExpDone
;
		sub	si, PotTblN [bx] + 11	;Fix for the next time through.
		call	NTbl2FPOP		;Load up current power of ten.
		call	sl_FMUL			;Multiply by this guy.
		jmp	NegExpLp
;
; If the user entered zero, drop down here and zero out fpacc.
;
ItsZero:	xor	ax, ax
		mov	fpacc.Exponent, ax
		mov	fpacc.Sign, al
		mov	fpacc.Mantissa [0], ax
		mov	fpacc.Mantissa [2], ax
		mov	fpacc.Mantissa [4], ax
		mov	fpacc.Mantissa [6], ax
;
; Round the result to produce a *halfway* decent number
;
MulExpDone:     cmp	fpacc.Exponent, 0ffffh		;Don't round if too big.
		je	atofDone
		shl	byte ptr fpacc.Mantissa, 1	;Use L.O. bits as guard
		adc	byte ptr fpacc.Mantissa [1], 0	; bits.
		jnc	atofDone
		inc	fpacc.Mantissa[2]
		jne	atofDone
		inc	fpacc.Mantissa[4]
		jne	atofDone
		inc	fpacc.Mantissa[6]
		jne	atofDone
		inc	fpacc.Exponent
;
atofDone:	mov	byte ptr fpacc.Mantissa, 0
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
sl_ATOF		endp
;
;
stdlib		ends
		end
