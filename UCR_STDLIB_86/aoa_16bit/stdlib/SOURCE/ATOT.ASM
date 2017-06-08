StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		extrn	sl_atoi2:far

;	ATOT-	Converts a string of the form HH:MM:SS{.xxx} to the standard
;		DOS time format.  The seconds value (.xxx) is optional and
;		presumed to be zero if absent.
;
;
; inputs:
;		ES:DI-	Points at the string to convert.
;
; Outputs:
;
;		CH-	Hours
;		CL-	Minutes
;		DH-	Seconds
;		DL-	Seconds/100
;		carry-	Set if error occurs during conversion, clear if
;			conversion proceeded okay.

		public	sl_ATOT
sl_ATOT		proc	far
		push	di
		call	far ptr sl_ATOT
		pop	di
sl_ATOT		endp



		public	sl_ATOT2
sl_ATOT2	proc	far
		assume	cs:stdgrp, ds:nothing
		pushf
		push	ax
		push	bx

		cld
		call	GetNum		;Get the hours value
		jc	BadATOT
		cmp	ax, 23
		ja	BadATOT
		mov	ch, al

		call	GetNum		;Get the minutes value.
		jc	BadATOT
		cmp	ax, 59
		ja	BadATOT
		mov	cl, al

		mov	dl, 0		;Assume 1/100 seconds = 0.
		call	sl_ATOI2	;Get the Seconds.
		jc	BadATOT
		cmp	ax, 59
		ja	BadATOT
		mov	dh, al
		cmp	byte ptr es:[di], '.'
		jne     GoodTime
		inc 	di
		call	sl_ATOI2	;Get the seconds
		jc	BadATOT
		cmp	ax, 100
		jae	BadATOT
		mov	dl, al

GoodTime:	pop	bx
		pop	ax
		popf
		clc
		ret

BadATOT:	pop	di
		pop	bx
		pop	ax
		popf
		stc
		ret
sl_ATOT2	endp



GetNum		proc	near
		call	sl_ATOI2
		jc	BadGN
		cmp	byte ptr es:[di], ':'
		je	GoodGN
BadGN:		stc
		ret

GoodGN:		inc	di
		clc
		ret
GetNum		endp

stdlib		ends
		end
