StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
		extrn	$lwrtbl:byte
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
		extrn	sl_strdup:far
;
; strlwr- Converts to lower case all upper case characters in the string
;	  pointed at by es:di.
;
; strlwrm- Same as above except it creates a new string then converts the
;	   characters in the new string.  The original string is unchanged.
;
; inputs:
;		es:di-  Buffer for destination string.
;
; outputs:
;		es:di-  Points at converted string (points at new string
;			for strupr2).
;
		public	sl_strlwr
;
sl_strlwr	proc	far
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
		lea	bx, StdGrp:$lwrtbl
ToUprLp:	lodsb
		xlat 	StdGrp:$lwrtbl
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
sl_strlwr	endp
;
;
		public	sl_strlwrm
;
sl_strlwrm	proc	far
		call	sl_strdup
		jc	RetFar			;Return if error.
		jmp	near ptr sl_strlwr
RetFar:		ret
sl_strlwrm	endp
;
stdlib		ends
		end
