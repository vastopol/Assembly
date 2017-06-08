; Segments, Segment addresses, and Loading order.
;
; Since DSEG appears first in this program, DOS will load it into the
; lowest memory address.

dseg		segment	para public 'data'
dwordVar	dword	?
wordVar		word	?
byteVar		byte	?
dseg		ends

; A length computation that occurs in the main program requires that
; cseg immediately follow dseg in memory.  We don't want to put the
; actual code in the program yet, but we'll define cseg at this point
; so that the assembler and linker knows that cseg must immediately
; follow dseg in memory.

cseg		segment	para public 'code'
cseg		ends

; A second data segment.  Note that this segment is *not* combined with
; the segment above.

dseg2		segment	para public 'data2'
VarInDS2	word	?
Var2InDS2	word	24 dup (?)
dseg2		ends


; Yet another data segment:

eseg		segment	para public 'data3'
VarInES		word	?
Var2InES	word	30 dup (?)
eseg		ends


; The assembler and linker will automatically merge this copy of cseg
; with the previous one.

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc

; Whenever you reference a segment's name, the assembler, linker, and
; loader will substitute the absolute *paragraph* (16-byte) address of
; that segment for the segment's name.  For example, the following three
; statements initialize DS and ES with the segment address of DSEG.

		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; If you know the loading order of a segment, you can compute the size
; of a segment using statements like the following.  Note, though, that
; both cseg and dseg are paragraph aligned, so the value will always be
; some even multiple of 16 bytes.  DSEG is padded with extra bytes at the
; end to fill out the last paragraph if there is not an even multiple of
; 16 bytes in DSEG.

		mov	ax, cseg	;Compute the length of DSEG by
		sub	ax, dseg	; subtracting the start of CSEG
					; from the start of DSEG.

; Because of the assume directive above, the assembler assumes that
; the ES and DS registers both point at DSEG.  Therefore, the assembler
; will allow you to access variables in DSEG without any problem.
; However, if you attempt to access a variable in DSEG2 or in ESEG,
; the assembler will generate an error because it thinks that there is
; no segment register pointing at these segments.  Note that loading
; a segment register with an appropriate value and using the assume
; directive are independent operations.

		mov	ax, dseg2	;These statements tell the 80x86
		mov	es, ax		; that es points at DSEG2.

; The following statement would generate an error because the assembler
; doesn't yet realize that a segment register (ES) points at DSEG2.

;;;;		mov	ax, VarInDS2

; One way to overcome this problem is to put an explicit "segment override
; prefix" on the variable.  This tells the assembler to ignore all
; assumptions and access the data in the specified segment.  This technique
; is fine if you're only going to have a few references to variables in the
; given segment.

		mov	ax, es:VarInDS2

; If you want to switch to a different segment during program execution,
; it is better to use the assume directive to tell the assembler what is
; going on so you don't need explicit segment overrides:

		assume	ds:dseg2, es:eseg
		mov	ax, dseg2
		mov	ds, ax
		mov	ax, eseg
		mov	es, ax

		mov	ax, VarInDS2		;Uses DS: by default.
		mov	VarInES, ax		;Uses ES: by default.
Quit:		mov	ah, 4ch
		int	21h
Main		endp

cseg		ends


; If you have multiple segments in your program with the same name,
; MASM, the linker, and the loader combine them into a single segment.
; Even the length computation above takes this into consideration.
; MASM merges the following DSEG segment with the previous one.  Therefore,
; the length of DSEG computed above *includes* the following data.

dseg		segment	para public 'data'

BigArray	byte	41 dup (?)

dseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends
		end	Main
