StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		extrn	sl_atoi2:far

;	ATOD-	Converts a string of the form MM/DD/YY to the standard
;		DOS date format.  If YY is less than 1900, it is assumed to
;		be 19YY.
;
;
; inputs:
;		ES:DI-	Points at the string to convert.
;
; Outputs:
;
;		CX-	Year (1980..2099)
;	        DH-	Month (1..12)
;		DL-	Day (1..31)
;		carry-	Set if error occurs during conversion, clear if
;			conversion proceeded okay.

MonthDays	db 	0,31,28,31,30,31,30,31,31,30,31,30,31

		public	sl_ATOD
sl_ATOD		proc	far
		push	di
		call	far ptr sl_ATOD2
		pop	di
		ret
sl_ATOD		endp


		public	sl_ATOD2
sl_ATOD2	proc	far
		assume	cs:stdgrp, ds:nothing
		pushf
		push	ax
		push	bx

		cld
		call	GetNum		;Get the month value
		jc	BadATOD
		cmp	ax, 0
		je	BadATOD
		cmp	ax, 12
		ja	BadATOD
		mov	dh, al

		call	GetNum		;Get the day value.
		jc	BadATOD
		cmp	ax, 0
		je	BadATOD
		cmp	ax, 31
		ja	BadATOD
		mov	dl, al

		call	sl_ATOI2	;Get the year.
		jc	BadATOD
		cmp	ax, 100
		jae	GotFullDate
		add	ax, 1900

GotFullDate:	cmp	ax, 1980
		jb	BadATOD
		cmp	ax, 2099
		ja	BadATOD
		mov	cx, ax

; Okay, now we've got to do a sanity check on the date to make sure it's okay.

		mov	bl, dh
		mov	bh, 0
		cmp	dl, cs:MonthDays[bx]
		jbe	GoodDate
		cmp	dh, 2		;Special kludge for Feb
		jne	BadATOD
		cmp	dl, 29
		jne	BadATOD
		test	al, 11b		;See if a leap year
		jne	BadATOD

GoodDate:	pop	bx
		pop	ax
		popf
		clc
		ret

BadATOD:	pop	di
		pop	bx
		pop	ax
		popf
		stc
		ret
sl_ATOD2	endp



GetNum		proc	near
		call	sl_ATOI2
		jc	BadGN
		cmp	byte ptr es:[di], '/'
		je	GoodGN
		cmp	byte ptr es:[di], '-'
		je	GoodGN
BadGN:		stc
		ret

GoodGN:		inc	di
		clc
		ret
GetNum		endp

stdlib		ends
		end
