
StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; Argc-		Counts the number of command line arguments
;
; inputs:
;
; Outputs:
;
;	CX-	Contains the number of command line arguments.
;
;
cr		equ	13
;
;
		public	sl_Argc
;
sl_Argc		proc	far
		push	ds
		push	ax
		push	bx

		mov	ah, 62h			;Get PSP DOS call
		int	21h
		mov	ds, bx			;Point DS at PSP.

		mov	bx, 80h			;Pointer to start of cmd line-1
		mov	cx, 0			;Start cnt at zero
CntLoop:	inc	bx			;Move on to next char.
		cmp	byte ptr [bx], ' '	;Skip all spaces here.
		je	CntLoop
		mov	al, [bx]
		cmp	al, cr			;See if carriage return
		je	ArgcDone
;
; We just headed into a word of some sort. Skip all the chars in this argument.
;
		inc	cx			;First, count this argument
;
		cmp	al, '"'			;See if it's a string.
		je	GotString
		cmp	al, "'"
		je	GotString
;
; If not a string, skip to next space or CR.
;
SkipWord:	inc	bx
		cmp	byte ptr [bx], ' '
		je	CntLoop
		cmp	byte ptr [bx], cr
		je	ArgcDone
		jmp	skipWord
;
; If we've got a string, skip to the delimiter or to the end of the line.
;
GotString:	inc	bx
		cmp	al, [bx]		;See if the delimiter
		je	CntLoop
		cmp	byte ptr [bx], cr	;See if EOLN
		jne	GotString
;
; Come down here when we're done:
;
ArgcDone:	pop	bx
		pop	ax
		pop	ds
		ret
sl_Argc		endp
;
;
stdlib		ends
		end
