StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far
		extrn	sl_DTOA:far

; DTOAm-	(Date to ASCII) Converts an MS-DOS format date to an ASCII
;    		string.  This routine allocates storage for the string on
;		the heap.
;
; xDTOAm-	Reads the system date and converts it to a string as per
;		DTOA.  This routine allocates storage for the string on
;		the heap.
;
; inputs:
;
;		CX-	Year (1980..2099)	(DTOAm only)
;	        DH-	Month (1..12)		(DTOAm only)
;		DL-	Day (1..31)     	(DTOAm only)
;
;		Note: xDTOAm reads the date from the system clock.
;
; outputs:	es:di-	Points at start of date string.
;		carry-	Set if memory allocation error.


		public	sl_xDTOAm
sl_xDTOAm	proc	far
		push	ax
		push	cx
		push	dx

		mov	cx, 9		;Need 9 bytes for the string.
		call	sl_Malloc
		jc	NoDate
		mov	ah, 2ah		;MS-DOS Get Date opcode
		int	21h		;Go get the system date
		call	sl_DTOA		;Convert it to a string.

NoDate:		pop	dx
		pop	cx
		pop	ax
		ret
sl_xDTOAm	endp


		public	sl_DTOAm
sl_DTOAm	proc	far
		push	ax
		push	cx
		mov	cx, 9
		call	sl_Malloc
		jc	NoDate2
		pop	cx
		push	cx
		call	sl_DTOA
		clc
NoDate2:	pop	cx
		pop	ax
		ret
sl_DTOAm		endp

stdlib		ends
		end
