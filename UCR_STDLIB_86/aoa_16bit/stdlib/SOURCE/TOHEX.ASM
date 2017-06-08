StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; ToHex-	Converts a sequence of binary bytes a string representing
;		that sequence in Intel Hex format.
;
; inputs:
;
;	ES:DI-	Points to the sequence of bytes to convert.
;	CX-	Number of bytes to convert.
;	BX-	Base address (load address) of bytes in hex format.
;
; Note: CX should be less than or equal to 32.
;
;
; outputs:
;
;	ES:DI-	Points at a zero terminated string on the heap
;
;	Carry flag is set on return if there was a memory allocation error.
;
; The hex string takes the following form:
;
;	": BB LLHH RR DDDDD...DDD SS <cr> <lf>"
;
;	(note:spaces are added for readability only)
;
; BB 	= byte count which represents the actual number of data bytes.
; LLHH	= L.O. & H.O. bytes of the load address (BX on entry).
; RR	= record type; 00= data record, 01= end record, 02=address record.
;	               (this code only outputs data records).
; D...D = data bytes.
; SS	= Check sum = -(sum of BB, LL, HH, RR, and data bytes)
;
;
		public	sl_ToHex
;
sl_ToHex	proc	far
		push	ds
		push	si
		push	ax
;
		mov	ax, es
		mov	ds, ax
		mov	si, di
;
; Compute the number of bytes we'll need for the hex string:
;	2*bytecnt + 13
;
		push	cx
		shl	cx, 1
		add	cx, 13
		call	sl_malloc
		pop	cx
		jc	BadToHex
		push	es			;Save ptr to string
		push	di
;
		mov	byte ptr es:[di], ":"
		inc	di
;
		mov	ah, 0			;Init checksum
;
; Output RR field:
;
		mov	al, cl			;Get byte cnt
		call	PutHex
;
; Output address here:
;
		mov	al, bl
		call	PutHex
		mov	al, bh
		call	PutHex
;
; Output the record type here:
;
		mov	al, 0
		call	PutHex
;
; Output the data bytes here:
;
PutDataLp:	mov	al, [si]
		call	PutHex
		inc	si
		loop	PutDataLp
;
; Okay, output the checksum here:
;
		mov	al, ah			;Get the checksum
		neg	al			;Negate it.
		call	PutHex
;
; Output the CR LF at the end
;
		mov	byte ptr es:[si], 13	;CR
		mov	byte ptr es:1[si], 10	;LF
;
; And don't forget the zero terminating byte.
;
		mov	byte ptr es:2[si], 0
		clc
;
; Get address of start of string:
;
		pop	di
		pop	es
;
; Okay, quit!
;
BadToHex:	pop	ax
		pop	si
		pop	ds
		ret
;
sl_ToHex	endp
;
;
; PutHex-	Adds AL to AH (to compute checksum), stores AL at ES:DI,
;		and increments DI by one.
;
PutHex		proc
		push	ax
		mov	ah, al
		shr	al, 1
		shr	al, 1
		shr	al, 1
		shr	al, 1
		call	PHex
		mov	al, ah
		and	al, 0fh
		call	PHex
		pop	ax
		add	ah, al			;Compute checksum
		ret
PutHex		endp
;
PHex		proc
		or	al, '0'
		cmp	al, '9'
		jbe	PutIt
		add	al, 7
PutIt:		mov	es:[di], al
		inc	di
		ret
PHex		endp
;
stdlib		ends
		end
