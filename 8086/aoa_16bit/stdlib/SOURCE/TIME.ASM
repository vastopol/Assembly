StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_itoa2:far

; TTOA-		(Time to ASCII) Converts an MS-DOS format time to an ASCII
;    		string.
;
; TTOA2-        As above, but it does not preserve DI, it leaves DI pointing
;		at the zero terminating byte of the string.
;
; xTTOA-	Reads the system time and converts it to a string as per
;		TTOA.
;
; xTTOA2-	Reads the system time and converts it to a string as per
;		TTOA2.
;
;
; inputs:
;
;		CH-	Hours (0..23)		(TTOA/TTOA2 only)
;	        CL-	Minutes (0..59)		(TTOA/TTOA2 only)
;		DH-	Seconds (0..59)     	(TTOA/TTOA2 only)
;		DL-	Seconds/100 (0..99)    	(TTOA/TTOA2 only)
;		ES:DI-	Points at first byte of buffer to hold date string
;
;		Note: xTTOA and xTTOA2 read the time from the system clock.
;
; outputs:	es:di-	Points at start of date string (TTOA/xTTOA).
;		es:di-	Points at zero terminating byte at end of date
;			string (TTOA2/xTTOA2 only).
;
; Note: The destination buffer must be large enough to hold the string and
;	zero terminating byte.


		public	sl_xTTOA
sl_xTTOA	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ch		;MS-DOS Get Time opcode
		int	21h		;Go get the system time
		call	far ptr sl_TTOA	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xTTOA	endp

		public	sl_xTTOA2
sl_xTTOA2	proc	far
		push	ax
		push	cx
		push	dx

		mov	ah, 2ch			;MS-DOS Get Time opcode
		int	21h			;Go get the system date
		call	far ptr sl_TTOA2	;Convert it to a string.

		pop	dx
		pop	cx
		pop	ax
		ret
sl_xTTOA2	endp


		public	sl_TTOA
sl_TTOA		proc	far
		push	di
		call	far ptr sl_TTOA2
		pop	di
		ret
sl_TTOA		endp

		public	sl_TTOA2
sl_TTOA2	proc	far
		pushf
		push	ax
		push	dx
		cld

; Output Hours:

		mov	ah, 0
		mov	al, ch
		call	Put2
		stosb

; Output Minutes:

		mov	al, cl
		call	Put2
		stosb

; Output Seconds:

		mov	al, dh
		call	Put2
		pop	dx
		pop	ax
		popf
		ret
sl_TTOA2	endp

put2		proc	near
		cmp	al, 10
		jae	TwoDigits
		mov	byte ptr es:[di], '0'
		inc	di
TwoDigits:	call	sl_itoa2
		mov	al, ':'
		ret
Put2		endp

stdlib		ends
		end
