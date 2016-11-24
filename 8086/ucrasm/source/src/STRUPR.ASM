StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
		extrn	$uprtbl:byte
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
		extrn	sl_strdup:far
;
; strupr- Converts to upper case all lower case characters in the string
;	  pointed at by es:di.
;
; struprm- Same as above except it creates a new string then converts the
;	   characters in the new string.  The original string is unchanged.
;
; inputs:
;		es:di-  Buffer for destination string.
;
; outputs:
;		es:di-  Points at converted string (points at new string
;			for strupr2).
;
		public	sl_strupr
;
sl_strupr	proc	far
		push	es
		push	ds
		push	ax
		push	bx
		pushf
		push	si
		push	di
;
		mov	si, es
		mov	ds, si
		mov	si, di
		lea	bx, StdGrp:$uprtbl
ToUprLp:	lodsb
		xlat 	StdGrp:$uprtbl
		stosb
		cmp	al, 0
		jne	ToUprLp
;
		pop	di
		pop	si
		popf
		pop	bx
		pop	ax
		pop	ds
		pop	es
		ret
sl_strupr	endp
;
;
		public	sl_struprm
;
sl_struprm	proc	far
		call	sl_strdup
		jc	RetFar
		jmp	near ptr sl_strupr
RetFar:		ret
sl_struprm	endp
;
stdlib		ends
		end
