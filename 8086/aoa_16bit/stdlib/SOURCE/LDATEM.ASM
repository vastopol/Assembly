StdGrp		group	stdlib,stddata

stddata		segment	para public 'sldata'
		extrn	sld_Months:byte
stddata		ends



stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_malloc:far
		extrn	sl_LDTOA:far

; LDTOAm-	(Date to ASCII) Converts an MS-DOS format date to an ASCII
;    		string (format: MON day, year)
;
; LDTOA2m-      As above, but it does not preserve DI, it leaves DI pointing
;		at the zero terminating byte of the string.
;
; xLDTOAm-	Reads the system date and converts it to a string as per
;		LDTOA.
;
; xLDTOA2m-	Reads the system date and converts it to a string as per
;		LDTOA2.
;
;
; inputs:
;
;		CX-	Year (1980..2099)	(LDTOAm only)
;	        DH-	Month (1..12)		(LDTOAm only)
;		DL-	Day (1..31)     	(LDTOAm only)
;		ES:DI-	Points at first byte of buffer to hold date string
;
;		Note: xLDTOAm reads the date from the system clock.
;
; outputs:	es:di-	Points at start of date string.



		public	sl_xLDTOAm
sl_xLDTOAm	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ah			;MS-DOS Get Date opcode
		int	21h			;Go get the system date
		call	far ptr sl_LDTOAm	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xLDTOAm	endp



		public	sl_LDTOAm
sl_LDTOAm	proc	far
		assume	ds:stdgrp

		push	cx
		mov	cx, 14			;Allocate 14 bytes
		call	sl_Malloc
		pop	cx
		jc	BadMalloc
		call	sl_LDTOA
		clc
		ret

BadMalloc:	stc
		ret
sl_LDTOAm	endp

stdlib		ends
		end
