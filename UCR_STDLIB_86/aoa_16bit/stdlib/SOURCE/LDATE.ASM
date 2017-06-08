StdGrp		group	stdlib,stddata

stddata		segment	para public 'sldata'

		public	sld_Months
sld_Months	db	"   "			;Dummy because we're based
		db	"Jan"			; at one rather than zero.
		db	"Feb"
		db	"Mar"
		db	"Apr"
		db	"May"
		db	"Jun"
		db	"Jul"
		db	"Aug"
		db	"Sep"
		db	"Oct"
		db	"Nov"
		db	"Dec"

stddata		ends



stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_itoa2:far

; LDTOA-	(Date to ASCII) Converts an MS-DOS format date to an ASCII
;    		string (format: MON day, year)
;
; LDTOA2-       As above, but it does not preserve DI, it leaves DI pointing
;		at the zero terminating byte of the string.
;
; xLDTOA-	Reads the system date and converts it to a string as per
;		LDTOA.
;
; xLDTOA2-	Reads the system date and converts it to a string as per
;		LDTOA2.
;
;
; inputs:
;
;		CX-	Year (1980..2099)	(LDTOA/LDTOA2 only)
;	        DH-	Month (1..12)		(LDTOA/LDTOA2 only)
;		DL-	Day (1..31)     	(LDTOA/LDTOA2 only)
;		ES:DI-	Points at first byte of buffer to hold date string
;
;		Note: xLDTOA and xLDTOA2 read the date from the system clock.
;
; outputs:	es:di-	Points at start of date string (LDTOA/xLDTOA).
;		es:di-	Points at zero terminating byte at end of date
;			string (LDTOA2/xLDTOA2 only).
;
; Note: The destination buffer must be large enough to hold the string and
;	zero terminating byte.


		public	sl_xLDTOA
sl_xLDTOA	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ah			;MS-DOS Get Date opcode
		int	21h			;Go get the system date
		call	far ptr sl_LDTOA	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xLDTOA	endp


		public	sl_xLDTOA2
sl_xLDTOA2	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ah			;MS-DOS Get Date opcode
		int	21h			;Go get the system date
		call	far ptr sl_LDTOA2	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xLDTOA2	endp



		public	sl_LDTOA
sl_LDTOA	proc	far
		push	di
		call	far ptr sl_LDTOA2
		pop	di
		ret
sl_LDTOA	endp

		public	sl_LDTOA2
sl_LDTOA2	proc	far
		assume	ds:stdgrp

		pushf
		push	ds
		push	ax
		push	si
		mov	ax, stdgrp
		mov	ds, ax

		cld
		mov	ah, 0
		mov	al, dh
		mov	si, ax			;Compute Month*3
		shl	ax, 1			;si*2
		lea	si, sld_Months[si]	;si*1 + adrs(Months)
		add	si, ax			;si*3 + adrs(Months)

		lodsb				;Copy three chars of
		stosb				; the month from the
		lodsb				; Months array to the
		stosb				; output string.
		lodsb
		stosb
		mov	al, ' '
		stosb

		mov	al, dl			;Okay, process the day
		call	sl_itoa2		; down here.
		mov	al, ','
		stosb
		mov	al, ' '
		stosb

		mov	ax, cx			;Finish up with the
		call	sl_itoa2		; year at this point.

		pop	si
		pop	ax
		pop	ds
		popf
		ret
sl_LDTOA2	endp

stdlib		ends
		end
