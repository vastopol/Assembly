StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far
		extrn	sl_TTOA:far

; TTOAm-	(Time to ASCII) Converts an MS-DOS format time to an ASCII
;    		string.  This routine allocates storage for the string on
;		the heap.
;
; xTTOAm-	Reads the system time and converts it to a string as per
;		TTOA.  This routine allocates storage for the string on
;		the heap.
;
; inputs:
;
;		CH-	Hours (0..23)
;		CL-	Minutes (0..59)
;		DH-	Seconds (0..59)
;		DL-	Seconds/100 (not really used.
;
;		Note: xTTOAm reads the date from the system clock.
;
; outputs:	es:di-	Points at start of date string.
;		carry-	Set if memory allocation error.


		public	sl_xTTOAm
sl_xTTOAm	proc	far
		push	ax
		push	cx
		push	dx

		mov	cx, 9		;Need 9 bytes for the string.
		call	sl_Malloc
		jc	NoTime
		mov	ah, 2ch		;MS-DOS Get Time opcode
		int	21h		;Go get the system date
		call	sl_TTOA		;Convert it to a string.

NoTime:		pop	dx
		pop	cx
		pop	ax
		ret
sl_xTTOAm	endp


		public	sl_TTOAm
sl_TTOAm	proc	far
		push	ax
		push	cx
		mov	cx, 9
		call	sl_Malloc
		jc	NoTime2
		pop	cx
		push	cx
		call	sl_TTOA
		clc
NoTime2:	pop	cx
		pop	ax
		ret
sl_TTOAm	endp

stdlib		ends
		end
