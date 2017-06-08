; XProduct.ASM-
;
;	This file contains the cross-product module.

		.386
		option	segment:use16

		.nolist
		include		stdlib.a
		includelib	stdlib.lib
		.list

		include	matrix.a

; Local variables for this module.

dseg		segment	para public 'data'
DV		dword	?
RowNdx		integer	?
ColNdx		integer	?
RowCntr		integer	?
ColCntr		integer	?
dseg		ends


cseg		segment	para public 'code'
		assume	ds:dseg

; CrossProduct- Computes the cartesian product of two vectors.
;		On entry:
;
;			FS:BP-	Points at the row matrix.
;			GS:BX-	Points at the column matrix.
;			DS:CX-	Points at the dope vector for the destination.
;
;		This code assume ds points at dseg.
;		This routine only preserves the segment registers.

RowMat		textequ	<fs:[bp]>
ColMat		textequ	<gs:[bx]>
DVP		textequ	<ds:[bx].DopeVec>

CrossProduct	proc	near

		ifdef	debug
		print
		char	"Entering CrossProduct routine",cr,lf,0
		endif

		xchg	bx, cx		;Get dope vector pointer
		mov	ax, DVP.Dim1	;Put Dim1 and Dim2 values
		mov	RowCntr, ax	; where they are easy to access.
		mov	ax, DVP.Dim2
		mov	ColCntr, ax
		xchg	bx, cx


; Okay, do the cross product operation.  This is defined as follows:
;
;	for RowNdx := 0 to NumRows-1 do
;	    for ColNdx := 0 to NumCols-1 do
;		Result[RowNdx, ColNdx] = Row[RowNdx] op Col[ColNdx];

		mov	RowNdx, -1	;Really starts at zero.
OutsideLp:	add	RowNdx, 1
		mov	ax, RowNdx
		cmp	ax, RowCntr
		jge	Done

		mov	ColNdx, -1	;Really starts at zero.
InsideLp:	add	ColNdx, 1
		mov	ax, ColNdx
		cmp	ax, ColCntr
		jge	OutSideLp

		mov	di, RowNdx
		add	di, di
		mov	ax, RowMat[di]

		mov	di, ColNdx
		add	di, di
		mov	dx, ColMat[di]

		push	bx		;Save pointer to column matrix.
		mov	bx, cx		;Put ptr to dope vector where we can
					; use it.

		call    DVP.Func	;Compute result for this guy.

		mov	di, RowNdx	;Index into array is
		imul	di, DVP.Dim2	; (RowNdx*Dim2 + ColNdx) * ElementSize
		add	di, ColNdx
		imul	di, DVP.ESize

		les	bx, DVP.Data	;Get base address of array.
		mov	es:[bx][di], ax	;Save away result.

		pop	bx		;Restore ptr to column array.
		jmp	InsideLp

Done:		ret
CrossProduct	endp
cseg		ends
		end
