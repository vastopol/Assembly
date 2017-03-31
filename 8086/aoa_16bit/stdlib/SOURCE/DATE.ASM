StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_itoa2:far

; DTOA-		(Date to ASCII) Converts an MS-DOS format date to an ASCII
;    		string.
;
; DTOA2-        As above, but it does not preserve DI, it leaves DI pointing
;		at the zero terminating byte of the string.
;
; xDTOA-	Reads the system date and converts it to a string as per
;		DTOA.
;
; xDTOA2-	Reads the system date and converts it to a string as per
;		DTOA2.
;
;
; inputs:
;
;		CX-	Year (1980..2099)	(DTOA/DTOA2 only)
;	        DH-	Month (1..12)		(DTOA/DTOA2 only)
;		DL-	Day (1..31)     	(DTOA/DTOA2 only)
;		ES:DI-	Points at first byte of buffer to hold date string
;
;		Note: xDTOA and xDTOA2 read the date from the system clock.
;
; outputs:	es:di-	Points at start of date string (DTOA/xDTOA).
;		es:di-	Points at zero terminating byte at end of date
;			string (DTOA2/xDTOA2 only).
;
; Note: The destination buffer must be large enough to hold the string and
;	zero terminating byte.


		public	sl_xDTOA
sl_xDTOA	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ah		;MS-DOS Get Date opcode
		int	21h		;Go get the system date
		call	far ptr sl_DTOA	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xDTOA	endp

		public	sl_xDTOA2
sl_xDTOA2	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ah			;MS-DOS Get Date opcode
		int	21h			;Go get the system date
		call	far ptr sl_DTOA2	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xDTOA2	endp


		public	sl_DTOA
sl_DTOA		proc	far
		push	di
		call	far ptr sl_DTOA2
		pop	di
		ret
sl_DTOA		endp

		public	sl_DTOA2
sl_DTOA2	proc	far
		pushf
		push	ax
		push	dx
		cld
		mov	ah, 0
		mov	al, dh
		call	Put2
		stosb
		mov	al, dl
		call	Put2
		stosb

; Only output the last two digits of the year:

		mov	ax, cx
		cmp	ax, 9900
		jb	DateOkay
		mov	ah, 0			;Just to be safe.

DateOkay:	mov     dl, 100
		div	dl
		mov	al, ah
		mov	ah, 0
		call	Put2
		pop	dx
		pop	ax
		popf
		ret
sl_DTOA2	endp

put2		proc	near
		cmp	al, 10
		jae	TwoDigits
		mov	byte ptr es:[di], '0'
		inc	di
TwoDigits:	call	sl_itoa2
		mov	al, '/'
		ret
Put2		endp

stdlib		ends
		end
